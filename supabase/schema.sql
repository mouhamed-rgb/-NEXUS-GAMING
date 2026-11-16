create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (char_length(username) between 3 and 24),
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.communities (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 50),
  description text not null default '',
  is_public boolean not null default true,
  owner_id uuid not null references auth.users(id) on delete cascade,
  rules text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.community_members (
  community_id uuid not null references public.communities(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','moderator','member')),
  joined_at timestamptz not null default now(),
  primary key (community_id, user_id)
);

create table if not exists public.channels (
  id uuid primary key default gen_random_uuid(),
  community_id uuid not null references public.communities(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 40),
  kind text not null default 'text' check (kind in ('text','voice')),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  channel_id uuid not null references public.channels(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 4000),
  created_at timestamptz not null default now()
);

create index if not exists messages_channel_created_idx on public.messages(channel_id, created_at desc);
create index if not exists channels_community_idx on public.channels(community_id);

alter table public.profiles enable row level security;
alter table public.communities enable row level security;
alter table public.community_members enable row level security;
alter table public.channels enable row level security;
alter table public.messages enable row level security;

create policy "profiles readable by signed-in users" on public.profiles for select to authenticated using (true);
create policy "users insert own profile" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "users update own profile" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

create policy "public communities visible; private members only" on public.communities for select to authenticated using (is_public or owner_id = auth.uid() or exists (select 1 from public.community_members m where m.community_id = id and m.user_id = auth.uid()));
create policy "authenticated users create communities" on public.communities for insert to authenticated with check (owner_id = auth.uid());
create policy "owners update communities" on public.communities for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "owners delete communities" on public.communities for delete to authenticated using (owner_id = auth.uid());

create policy "members visible to community members" on public.community_members for select to authenticated using (exists (select 1 from public.community_members mine where mine.community_id = community_id and mine.user_id = auth.uid()));
create policy "users join public communities" on public.community_members for insert to authenticated with check (user_id = auth.uid() and exists (select 1 from public.communities c where c.id = community_id and c.is_public));
create policy "users leave own membership" on public.community_members for delete to authenticated using (user_id = auth.uid());

create policy "channels visible to members or public communities" on public.channels for select to authenticated using (exists (select 1 from public.communities c where c.id = community_id and (c.is_public or exists (select 1 from public.community_members m where m.community_id = c.id and m.user_id = auth.uid()))));
create policy "community owners and moderators create channels" on public.channels for insert to authenticated with check (created_by = auth.uid() and exists (select 1 from public.community_members m where m.community_id = community_id and m.user_id = auth.uid() and m.role in ('owner','moderator')));
create policy "community owners manage channels" on public.channels for delete to authenticated using (exists (select 1 from public.community_members m where m.community_id = community_id and m.user_id = auth.uid() and m.role = 'owner'));

create policy "messages visible to channel community members" on public.messages for select to authenticated using (exists (select 1 from public.channels ch join public.communities c on c.id = ch.community_id where ch.id = channel_id and (c.is_public or exists (select 1 from public.community_members m where m.community_id = c.id and m.user_id = auth.uid()))));
create policy "members send messages" on public.messages for insert to authenticated with check (author_id = auth.uid() and exists (select 1 from public.channels ch join public.communities c on c.id = ch.community_id where ch.id = channel_id and (c.is_public or exists (select 1 from public.community_members m where m.community_id = c.id and m.user_id = auth.uid()))));
create policy "authors delete own messages" on public.messages for delete to authenticated using (author_id = auth.uid());

-- NOTE: Review private-community invitation/join policies and moderation permissions before production.
