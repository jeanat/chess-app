# Chess w/ Friends

Two files make up the whole app:

- `schema.sql` — run once inside Supabase to create the database tables.
- `index.html` — the entire app (login, dashboard, board, live sync). Edit the two placeholder values near the top (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) before deploying.

No build step, no npm install, no command line. See the deployment walkthrough in chat for exact click-by-click steps.

## What this MVP includes
- Email magic-link sign-in (no passwords)
- Create a game, get a shareable invite link, anyone with the link can join as your opponent
- Real chess rules enforced (legal moves, checkmate/draw detection)
- Live sync: if both players have the game open, moves appear instantly
- Async-friendly: close the tab anytime, come back later, the game is exactly as you left it
- Dashboard showing whose turn it is across all your games

## Known limits (v1 — can be added later)
- No push/email notification when it's your turn — you check the dashboard
- No draw-offer or resign confirmation dialog (resign is one click)
- Pawn promotion always defaults to queen
- No spectator-safe hiding of in-progress opponent info
