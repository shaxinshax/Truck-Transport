-- Truck driver registration app: Supabase schema (draft v2)
-- To make someone an admin: insert into admins (user_id) values ('<their auth user id>');
-- Run in Supabase SQL editor. Auth users come from Supabase Auth (auth.users).

-- ---------- Enums ----------
create type review_status as enum ('pending', 'approved', 'rejected');
create type app_language  as enum ('en', 'ru', 'ka', 'tr');

-- ---------- Document types (add new rows any time; the app picks them up) ----------
create table document_types (
  code        text primary key,
  label_en    text not null,
  label_ru    text not null,
  label_ka    text not null,
  label_tr    text not null,
  for_vehicle text check (for_vehicle in ('truck', 'trailer')), -- null = driver document
  required    boolean not null default false,
  has_expiry  boolean not null default false,
  sort_order  int not null default 100,
  active      boolean not null default true
);

insert into document_types (code, label_en, label_ru, label_ka, label_tr, for_vehicle, required, has_expiry, sort_order) values
 ('driver_license_front', 'Driver''s license (front)', 'Водительское удостоверение (лицевая сторона)', 'მართვის მოწმობა (წინა მხარე)', 'Ehliyet (ön yüz)', null, true, true, 10),
 ('driver_license_back',  'Driver''s license (back)',  'Водительское удостоверение (обратная сторона)', 'მართვის მოწმობა (უკანა მხარე)', 'Ehliyet (arka yüz)', null, true, false, 20),
 ('passport',             'Passport or ID card', 'Паспорт или удостоверение личности', 'პასპორტი ან პირადობის მოწმობა', 'Pasaport veya kimlik kartı', null, true, true, 30),
 ('medical_certificate',  'Medical certificate', 'Медицинская справка', 'სამედიცინო ცნობა', 'Sağlık raporu', null, false, true, 40),
 ('insurance',            'Insurance', 'Страховка', 'დაზღვევა', 'Sigorta', null, false, true, 50),
 ('other',                'Other document', 'Другой документ', 'სხვა დოკუმენტი', 'Diğer belge', null, false, false, 90),
 ('truck_photo',          'Truck photo', 'Фото грузовика', 'სატვირთოს ფოტო', 'Kamyon fotoğrafı', 'truck', true, false, 10),
 ('truck_plate_photo',    'License plate photo', 'Фото номерного знака', 'სახელმწიფო ნომრის ფოტო', 'Plaka fotoğrafı', 'truck', true, false, 20),
 ('truck_registration',   'Vehicle registration certificate', 'Свидетельство о регистрации ТС', 'ავტომობილის რეგისტრაციის მოწმობა', 'Araç ruhsatı', 'truck', true, false, 30),
 ('trailer_photo',        'Trailer photo', 'Фото прицепа', 'მისაბმელის ფოტო', 'Dorse fotoğrafı', 'trailer', false, false, 10),
 ('trailer_plate_photo',  'License plate photo', 'Фото номерного знака', 'სახელმწიფო ნომრის ფოტო', 'Plaka fotoğrafı', 'trailer', false, false, 20),
 ('trailer_registration', 'Trailer registration certificate', 'Свидетельство о регистрации прицепа', 'მისაბმელის რეგისტრაციის მოწმობა', 'Dorse ruhsatı', 'trailer', false, false, 30);

-- ---------- Admins ----------
create table admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from admins where user_id = auth.uid());
$$;

-- ---------- Drivers ----------
create table drivers (
  id                 uuid primary key references auth.users(id) on delete cascade,
  first_name         text not null,
  last_name          text not null,
  date_of_birth      date,
  phone              text,
  email              text,
  citizenship        text,          -- ISO 3166 alpha-2, e.g. GE, TR, RU
  address            text,
  city               text,
  country            text,
  preferred_language app_language not null default 'en',
  profile_photo_path text,          -- path in 'driver-files' bucket
  -- Driver's license
  license_number     text,
  license_categories text[] default '{}',   -- e.g. {C, CE}
  license_country    text,
  license_issued_at  date,
  license_expires_at date,
  -- Passport / ID
  passport_number    text,
  passport_expires_at date,
  -- Review
  status             review_status not null default 'pending',
  review_note        text,
  reviewed_by        uuid references auth.users(id),
  reviewed_at        timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

-- ---------- Vehicles (truck and trailer) ----------
create table vehicles (
  id            uuid primary key default gen_random_uuid(),
  driver_id     uuid not null references drivers(id) on delete cascade,
  kind          text not null check (kind in ('truck', 'trailer')),
  make          text,
  model         text,
  year          int check (year between 1950 and 2100),
  plate_number  text not null,
  plate_country text,
  vin           text,
  trailer_type  text,               -- tent, refrigerated, flatbed, tanker...
  status        review_status not null default 'pending',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index on vehicles(driver_id);

-- ---------- Documents & photos ----------
create table documents (
  id           uuid primary key default gen_random_uuid(),
  driver_id    uuid not null references drivers(id) on delete cascade,
  vehicle_id   uuid references vehicles(id) on delete cascade,
  type         text not null references document_types(code),
  storage_path text not null,       -- '<driver_id>/<uuid>.<ext>' in 'driver-files'
  mime_type    text,
  size_bytes   bigint,
  expires_at   date,
  status       review_status not null default 'pending',
  review_note  text,
  reviewed_by  uuid references auth.users(id),
  reviewed_at  timestamptz,
  created_at   timestamptz not null default now()
);
create index on documents(driver_id);

-- ---------- updated_at trigger ----------
create or replace function touch_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;
create trigger drivers_touch  before insert or update on drivers  for each row execute function touch_updated_at();
create trigger vehicles_touch before insert or update on vehicles for each row execute function touch_updated_at();

-- Drivers cannot change their own review fields; edits reset status to pending.
create or replace function protect_review_fields() returns trigger language plpgsql as $$
begin
  if not is_admin() then
    new.status := 'pending';
    if tg_table_name in ('drivers', 'documents') then
      if tg_op = 'INSERT' then
        new.review_note := null; new.reviewed_by := null; new.reviewed_at := null;
      else
        new.review_note := old.review_note;
        new.reviewed_by := old.reviewed_by;
        new.reviewed_at := old.reviewed_at;
      end if;
    end if;
  end if;
  return new;
end $$;
create trigger drivers_protect   before insert or update on drivers   for each row execute function protect_review_fields();
create trigger vehicles_protect  before insert or update on vehicles  for each row execute function protect_review_fields();
create trigger documents_protect before insert or update on documents for each row execute function protect_review_fields();

-- ---------- Row Level Security ----------
alter table admins    enable row level security;
alter table document_types enable row level security;
alter table drivers   enable row level security;
alter table vehicles  enable row level security;
alter table documents enable row level security;

create policy "admins read admins" on admins for select using (is_admin());
create policy "everyone reads document types" on document_types for select using (auth.role() = 'authenticated');
create policy "admins manage document types" on document_types for all using (is_admin()) with check (is_admin());

create policy "driver own row"  on drivers for all
  using (id = auth.uid() or is_admin()) with check (id = auth.uid() or is_admin());

create policy "driver own vehicles" on vehicles for all
  using (driver_id = auth.uid() or is_admin()) with check (driver_id = auth.uid() or is_admin());

create policy "driver own documents" on documents for all
  using (driver_id = auth.uid() or is_admin()) with check (driver_id = auth.uid() or is_admin());

-- ---------- Storage (private bucket) ----------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('driver-files', 'driver-files', false, 10485760,
        array['image/jpeg', 'image/png', 'image/heic', 'application/pdf'])
on conflict (id) do nothing;

-- Files live under a folder named after the driver's user id.
create policy "driver files read" on storage.objects for select
  using (bucket_id = 'driver-files' and ((storage.foldername(name))[1] = auth.uid()::text or is_admin()));
create policy "driver files write" on storage.objects for insert
  with check (bucket_id = 'driver-files' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "driver files delete" on storage.objects for delete
  using (bucket_id = 'driver-files' and ((storage.foldername(name))[1] = auth.uid()::text or is_admin()));
