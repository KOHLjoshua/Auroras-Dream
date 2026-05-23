// ================================================================
// Aurora Notes — Supabase Configuration
//
// HOW TO SET UP:
//   1. Create a free project at https://supabase.com
//   2. Copy this file to config.js  (config.js is gitignored)
//   3. Fill in your Project URL and anon/public key below
//      (find them at: Supabase dashboard → Settings → API)
//   4. Run schema.sql in your Supabase SQL Editor
//   5. In Supabase → Authentication → Settings:
//      - Disable "Enable email confirmations" for local dev
//        (or handle the email flow in production)
//   6. Open index.html — auth and persistence are now live
//
// NOTE: The anon key is designed to be public. Security comes
//       from Row-Level Security policies defined in schema.sql.
// ================================================================

window.AURORA_CONFIG = {
  supabaseUrl: 'YOUR_SUPABASE_PROJECT_URL',   // e.g. https://xxxx.supabase.co
  supabaseKey: 'YOUR_SUPABASE_ANON_PUBLIC_KEY' // starts with eyJ...
};
