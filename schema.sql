-- ================================================================
-- Aurora Notes — Supabase Schema
-- Run this entire file in your Supabase project's SQL Editor.
-- ================================================================

-- ── Profiles ─────────────────────────────────────────────────────
-- One row per auth.users entry. Created at registration.
CREATE TABLE IF NOT EXISTS profiles (
  id        UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  pen_name  TEXT UNIQUE NOT NULL
              CHECK (char_length(pen_name) BETWEEN 2 AND 30),
  avatar    TEXT NOT NULL DEFAULT '🌙',
  bio       TEXT CHECK (char_length(bio) <= 300),
  role      TEXT NOT NULL DEFAULT 'writer'
              CHECK (role IN ('reader', 'writer', 'owner')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Posts ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS posts (
  id         BIGSERIAL PRIMARY KEY,
  author_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title      TEXT CHECK (char_length(title) <= 120),
  body       TEXT NOT NULL CHECK (char_length(body) BETWEEN 1 AND 6000),
  type       TEXT NOT NULL CHECK (type IN ('thought','poem','story','audio')),
  category   TEXT NOT NULL CHECK (category IN ('fresh','deep','audio','midnight')),
  audio_url  TEXT,
  moods      TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS posts_updated_at ON posts;
CREATE TRIGGER posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Reactions ────────────────────────────────────────────────────
-- One row per (post, user, emoji) — enforced unique to prevent spam.
CREATE TABLE IF NOT EXISTS reactions (
  id       BIGSERIAL PRIMARY KEY,
  post_id  BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id  UUID   NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  emoji    TEXT   NOT NULL CHECK (emoji IN ('🌌','✨','🌠','🌙')),
  UNIQUE (post_id, user_id, emoji)
);

-- ── Comments ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS comments (
  id         BIGSERIAL PRIMARY KEY,
  post_id    BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id  UUID   NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  body       TEXT   NOT NULL CHECK (char_length(body) BETWEEN 1 AND 600),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ================================================================
-- Row-Level Security
-- ================================================================

ALTER TABLE profiles  ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts     ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments  ENABLE ROW LEVEL SECURITY;

-- ── profiles ─────────────────────────────────────────────────────
CREATE POLICY "profiles_select" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "profiles_insert" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- ── posts ────────────────────────────────────────────────────────
CREATE POLICY "posts_select" ON posts
  FOR SELECT USING (true);

CREATE POLICY "posts_insert" ON posts
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL
    AND author_id = auth.uid()
  );

CREATE POLICY "posts_update" ON posts
  FOR UPDATE USING (author_id = auth.uid());

CREATE POLICY "posts_delete" ON posts
  FOR DELETE USING (
    author_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'owner'
    )
  );

-- ── reactions ────────────────────────────────────────────────────
CREATE POLICY "reactions_select" ON reactions
  FOR SELECT USING (true);

CREATE POLICY "reactions_insert" ON reactions
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL
    AND user_id = auth.uid()
  );

CREATE POLICY "reactions_delete" ON reactions
  FOR DELETE USING (user_id = auth.uid());

-- ── comments ────────────────────────────────────────────────────
CREATE POLICY "comments_select" ON comments
  FOR SELECT USING (true);

CREATE POLICY "comments_insert" ON comments
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL
    AND author_id = auth.uid()
  );

CREATE POLICY "comments_delete" ON comments
  FOR DELETE USING (
    author_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'owner'
    )
  );

-- ================================================================
-- Grant owner role to a specific user (run manually after signing up)
-- Replace the email below with your own.
-- ================================================================
-- UPDATE profiles
--   SET role = 'owner'
-- WHERE id = (SELECT id FROM auth.users WHERE email = 'your@email.com');
