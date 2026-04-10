-- ============================================================
-- Trigger: cria automaticamente um registro em `profiles`
-- sempre que um novo usuário é inserido em `auth.users`.
-- ============================================================
-- Como usar:
--   Execute este script no SQL Editor do seu projeto Supabase
--   (Database → SQL Editor → New Query).
-- ============================================================

-- 1. Tabela de perfis
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  email       text,
  nome_completo text,
  telefone    text,
  perfil      text not null default 'cliente' check (perfil in ('cliente', 'motorista')),
  criado_em   timestamptz not null default now()
);

-- 2. Row Level Security
alter table public.profiles enable row level security;

create policy "Usuário lê seu próprio perfil"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Usuário atualiza seu próprio perfil"
  on public.profiles for update
  using (auth.uid() = id);

-- 3. Função acionada pelo trigger
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, nome_completo, telefone, perfil)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'nome_completo', ''),
    coalesce(new.raw_user_meta_data->>'telefone', ''),
    coalesce(new.raw_user_meta_data->>'perfil', 'cliente')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- 4. Trigger em auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
