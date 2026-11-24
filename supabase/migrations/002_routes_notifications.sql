-- Routes (trip planning) and in-app notifications.
-- Run once in the Supabase SQL editor after schema.sql.

-- ---------- Routes ----------
-- A driver tells us where they go and when they arrive / become free.
create type route_status as enum ('planned', 'on_the_way', 'done', 'cancelled');

create table routes (
  id              uuid primary key default gen_random_uuid(),
  driver_id       uuid not null references drivers(id) on delete cascade,
  vehicle_id      uuid references vehicles(id) on delete set null,
  from_city       text not null,
  from_country    text,
  to_city         text not null,
  to_country      text,
  depart_at       timestamptz,          -- when leaving the start point
  arrive_from     timestamptz,          -- arrival window at destination: earliest
  arrive_to       timestamptz,          -- ... latest
  free_for_cargo  boolean not null default true,  -- looking for a load at the destination
  note            text,
  status          route_status not null default 'planned',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index routes_driver_idx on routes (driver_id);
create index routes_arrive_idx on routes (arrive_from);

create trigger routes_touch before insert or update on routes for each row execute function touch_updated_at();

alter table routes enable row level security;
create policy "driver own routes" on routes for all
  using (driver_id = auth.uid() or is_admin()) with check (driver_id = auth.uid() or is_admin());

-- ---------- Notifications ----------
-- The app shows the text in the reader's language from `kind` + `data`.
create table notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  kind       text not null,   -- driver_approved, driver_rejected, doc_rejected, new_driver, new_route
  data       jsonb not null default '{}',
  read_at    timestamptz,
  created_at timestamptz not null default now()
);
create index notifications_user_idx on notifications (user_id, created_at desc);

alter table notifications enable row level security;
create policy "read own notifications" on notifications for select using (user_id = auth.uid());
create policy "mark own notifications read" on notifications for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "delete own notifications" on notifications for delete using (user_id = auth.uid());
-- Rows are created only by the triggers below (security definer), never directly by apps.

create or replace function notify_admins(p_kind text, p_data jsonb) returns void
language sql security definer set search_path = public as $$
  insert into notifications (user_id, kind, data) select user_id, p_kind, p_data from admins;
$$;

create or replace function on_driver_change() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then
    perform notify_admins('new_driver', jsonb_build_object('driver_id', new.id, 'name', new.first_name || ' ' || new.last_name));
  elsif new.status is distinct from old.status and new.status in ('approved', 'rejected') then
    insert into notifications (user_id, kind, data)
    values (new.id, 'driver_' || new.status::text, jsonb_build_object('note', new.review_note));
  end if;
  return new;
end $$;
create trigger drivers_notify after insert or update on drivers for each row execute function on_driver_change();

create or replace function on_document_change() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.status = 'rejected' and old.status is distinct from 'rejected' then
    insert into notifications (user_id, kind, data)
    values (new.driver_id, 'doc_rejected', jsonb_build_object('type', new.type, 'note', new.review_note));
  end if;
  return new;
end $$;
create trigger documents_notify after update on documents for each row execute function on_document_change();

create or replace function on_route_added() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_name text;
begin
  select first_name || ' ' || last_name into v_name from drivers where id = new.driver_id;
  perform notify_admins('new_route', jsonb_build_object(
    'driver_id', new.driver_id, 'name', v_name, 'from', new.from_city, 'to', new.to_city, 'arrive_from', new.arrive_from));
  return new;
end $$;
create trigger routes_notify after insert on routes for each row execute function on_route_added();

-- Let the app receive new notifications instantly.
alter publication supabase_realtime add table notifications;

-- ---------- Live location ----------
-- One row per driver with their latest position while "Share my location" is on.
create table driver_locations (
  driver_id  uuid primary key references drivers(id) on delete cascade,
  lat        double precision not null,
  lng        double precision not null,
  speed_kmh  real,
  heading    real,
  sharing    boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table driver_locations enable row level security;
create policy "driver own location" on driver_locations for all
  using (driver_id = auth.uid() or is_admin()) with check (driver_id = auth.uid());
