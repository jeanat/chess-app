-- =========================================================
-- Chess w/ Friends — Supabase schema
-- Paste this whole file into Supabase's SQL Editor and click "Run".
-- =========================================================

-- Profiles: one row per signed-up user
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  display_name text not null,
  school text,
  created_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "Profiles are viewable by everyone"
  on profiles for select using (true);

create policy "Users can insert their own profile"
  on profiles for insert with check (auth.uid() = id);

create policy "Users can update their own profile"
  on profiles for update using (auth.uid() = id);

-- Games: one row per chess game
create table games (
  id uuid primary key default gen_random_uuid(),
  invite_code text unique not null default substr(md5(random()::text), 1, 8),
  white_id uuid references profiles(id),
  black_id uuid references profiles(id),
  status text not null default 'waiting',      -- waiting | active | finished
  turn text not null default 'w',               -- w | b
  fen text not null default 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
  pgn text not null default '',
  winner text,                                   -- w | b | draw
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table games enable row level security;

create policy "Games are viewable by anyone with the link"
  on games for select using (true);

create policy "A signed-in user can create a game as white"
  on games for insert with check (auth.uid() = white_id);

create policy "A second player can join an open game"
  on games for update using (status = 'waiting' and black_id is null);

create policy "Players can update their own game"
  on games for update using (auth.uid() = white_id or auth.uid() = black_id);

-- Moves: full move history per game
create table moves (
  id uuid primary key default gen_random_uuid(),
  game_id uuid references games(id) on delete cascade,
  move_number int not null,
  san text not null,
  fen_after text not null,
  played_by uuid references profiles(id),
  played_at timestamptz default now()
);

alter table moves enable row level security;

create policy "Moves are viewable by anyone with the link"
  on moves for select using (true);

create policy "Players can add moves to their own games"
  on moves for insert with check (
    exists (
      select 1 from games g
      where g.id = game_id
        and (g.white_id = auth.uid() or g.black_id = auth.uid())
    )
  );

-- Realtime: let the app subscribe to live game updates
alter publication supabase_realtime add table games;
alter publication supabase_realtime add table moves;
