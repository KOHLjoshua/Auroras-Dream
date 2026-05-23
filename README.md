# Aurora Notes

> *your inner world matters and deserves space*

A creative writing community — poems, thoughts, stories, audio recordings — built on a cosmic corkboard with aurora borealis visuals. No metrics, no follower counts. Just writing.

---

## Quick Start (no backend needed)

Open `index.html` in any browser. The app runs in **demo mode** with pre-seeded posts and full visual effects — nothing persists between sessions.

---

## Full Setup with Supabase (persistence + auth)

### 1 — Create a Supabase project
Go to [supabase.com](https://supabase.com) → New Project (free tier works).

### 2 — Run the schema
In your Supabase dashboard → **SQL Editor** → paste and run the full contents of [`schema.sql`](schema.sql).

### 3 — Configure credentials
```bash
cp config.example.js config.js
```
Open `config.js` and fill in your **Project URL** and **anon/public key** from:
> Supabase dashboard → Settings → API

### 3a — Create the audio storage bucket (for audio posts)
In Supabase → **Storage** → New bucket:
- Name: `audio`
- Public bucket: **on**

Then in **Storage → Policies**, add a policy on the `audio` bucket:
- `INSERT`: authenticated users only (`auth.uid() IS NOT NULL`)
- `SELECT`: public (`true`)

### 3b — Enable Realtime (for live updates)
In your Supabase dashboard → **Database → Replication**, enable Realtime for the `posts`, `reactions`, and `comments` tables.

Or run this in the SQL Editor:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE posts, reactions, comments;
```

### 4 — Auth settings (optional for local dev)
In Supabase → **Authentication → Settings**:
- Disable **"Enable email confirmations"** while developing locally so sign-up is instant.
- Re-enable and configure a redirect URL before going to production.

### 5 — Open the app
Open `index.html` (serve via any static server for best results):
```bash
npx serve .
# or
python -m http.server 8000
```

### 6 — Make yourself owner
After your first sign-up, run this in the Supabase SQL Editor (replace the email):
```sql
UPDATE profiles
  SET role = 'owner'
WHERE id = (SELECT id FROM auth.users WHERE email = 'your@email.com');
```

---

## Tech Stack

| Layer | Tech |
|---|---|
| Frontend | Vanilla JS + CSS — no build step |
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth (email + password) |
| Storage | Supabase Storage *(Phase 4 — audio)* |
| Fonts | Crimson Pro + Caveat (Google Fonts) |

---

## Build Phases

| Phase | Status | What |
|---|---|---|
| 1 | ✅ Done | Backend schema, Auth (register / login / logout), real data layer |
| 2 | ✅ Done | Real post CRUD (edit, delete), pagination |
| 3 | ✅ Done | Reactions + comments fully persisted, real-time updates via Supabase Realtime |
| 4 | ✅ Done | Audio recording (MediaRecorder API), real waveform viz, Supabase Storage upload |
| 5 | ✅ Done | User profiles, shareable post URLs (#post/id), client-side hash routing |
| 6 | ✅ Done | Full-text search (title, body, author, moods) + mood tag filtering |
| 4 | ⬜ | Audio recording + upload + real waveform |
| 5 | ⬜ | User profiles, shareable post URLs, routing |
| 6 | ⬜ | Full-text search, tag-based filtering |
| 7 | ⬜ | Notifications, owner/moderation dashboard |
| 8 | ⬜ | Settings page, accessibility pass, PWA polish |

---

## Project Structure

```
Aurorian/
├── index.html          Main app (vanilla JS + CSS, single file)
├── config.js           Your Supabase credentials (gitignored)
├── config.example.js   Credential template — copy → config.js
├── schema.sql          Full database schema + RLS policies
└── README.md
```

---

## Demo Mode

When `config.js` is missing or contains placeholder values, the app runs in demo mode:
- Pre-seeded posts from fictional writers
- All visual effects active (aurora, particles, time-of-day)
- Reactions and comments work locally but reset on refresh
- A small banner indicates demo mode

---

*Built with vanilla JS — no frameworks, no bundler, no build step.*
