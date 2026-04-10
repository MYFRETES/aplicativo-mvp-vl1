-- ============================================================
-- Migration: cria tabelas de fretes, paradas e itens com RLS.
-- ============================================================
-- Como usar:
--   Execute este script no SQL Editor do seu projeto Supabase
--   (Database → SQL Editor → New Query).
-- ============================================================

-- 1. Tabela principal de fretes
create table if not exists public.fretes (
  id                  uuid primary key default gen_random_uuid(),
  cliente_id          uuid not null references auth.users (id) on delete cascade,
  status              text not null default 'aberto'
                        check (status in ('aberto', 'aceito', 'em_andamento', 'concluido', 'cancelado')),
  titulo              text,
  descricao           text,
  data_desejada       date,
  periodo             text,
  -- endereço de origem
  origem_cep          text not null,
  origem_endereco     text not null,
  origem_numero       text not null,
  origem_complemento  text,
  origem_bairro       text not null,
  origem_cidade       text not null,
  origem_uf           char(2) not null,
  origem_referencia   text,
  -- endereço de destino
  destino_cep         text not null,
  destino_endereco    text not null,
  destino_numero      text not null,
  destino_complemento text,
  destino_bairro      text not null,
  destino_cidade      text not null,
  destino_uf          char(2) not null,
  destino_referencia  text,
  -- ajudantes / apoio
  qtd_ajudantes       int not null default 0,
  precisa_montagem    boolean not null default false,
  precisa_embalagem   boolean not null default false,
  obs_ajudantes       text,
  criado_em           timestamptz not null default now()
);

-- RLS — fretes
alter table public.fretes enable row level security;

create policy "Cliente insere próprio frete"
  on public.fretes for insert
  with check (auth.uid() = cliente_id);

create policy "Cliente lê próprios fretes"
  on public.fretes for select
  using (auth.uid() = cliente_id);

-- 2. Paradas intermediárias
create table if not exists public.frete_paradas (
  id          uuid primary key default gen_random_uuid(),
  frete_id    uuid not null references public.fretes (id) on delete cascade,
  ordem       int not null,
  cep         text not null,
  endereco    text not null,
  numero      text not null,
  complemento text,
  bairro      text not null,
  cidade      text not null,
  uf          char(2) not null,
  referencia  text
);

-- RLS — frete_paradas
alter table public.frete_paradas enable row level security;

create policy "Cliente insere paradas do próprio frete"
  on public.frete_paradas for insert
  with check (
    exists (
      select 1 from public.fretes
      where fretes.id = frete_id
        and fretes.cliente_id = auth.uid()
    )
  );

create policy "Cliente lê paradas do próprio frete"
  on public.frete_paradas for select
  using (
    exists (
      select 1 from public.fretes
      where fretes.id = frete_id
        and fretes.cliente_id = auth.uid()
    )
  );

-- 3. Itens do frete
create table if not exists public.frete_itens (
  id         uuid primary key default gen_random_uuid(),
  frete_id   uuid not null references public.fretes (id) on delete cascade,
  nome       text not null,
  quantidade int not null default 1,
  categoria  text,
  observacao text
);

-- RLS — frete_itens
alter table public.frete_itens enable row level security;

create policy "Cliente insere itens do próprio frete"
  on public.frete_itens for insert
  with check (
    exists (
      select 1 from public.fretes
      where fretes.id = frete_id
        and fretes.cliente_id = auth.uid()
    )
  );

create policy "Cliente lê itens do próprio frete"
  on public.frete_itens for select
  using (
    exists (
      select 1 from public.fretes
      where fretes.id = frete_id
        and fretes.cliente_id = auth.uid()
    )
  );
