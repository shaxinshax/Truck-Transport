/// Server settings. The publishable key is designed to be public: the
/// database's row level security rules decide what each user may see.
/// Never put a secret / service_role key here.
///
/// Override at build time with --dart-define=SUPABASE_URL=... and
/// --dart-define=SUPABASE_ANON_KEY=..., or force the sample-data preview
/// with --dart-define=DEMO=true.
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://wlqkzhyiptsysuuaahqe.supabase.co',
);
const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_qMRVM3__Gj6_hvA-lJIN4w_5iJaLlLz',
);
const demoMode = bool.fromEnvironment('DEMO');
