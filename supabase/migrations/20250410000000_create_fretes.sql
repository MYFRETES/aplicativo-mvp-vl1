-- ============================================================
-- BLOCO 3 — Tabelas para solicitação de frete
-- ============================================================
-- Execute no SQL Editor do seu projeto Supabase
-- (Database → SQL Editor → New Query).
-- ============================================================

-- 1. Tabela principal de fretes
create table if not exists public.fretes (
  id                  uuid primary key default gen_random_uuid(),
  cliente_id          uuid not null references auth.users (id) on delete cascade,

  -- Dados iniciais
  titulo              text,
  descricao           text,
  data_desejada       date,
  periodo             text,

  -- Origem
  origem_cep          text not null,
  origem_endereco     text not null,
  origem_numero       text not null,
  origem_complemento  text,
  origem_bairro       text not null,
  origem_cidade       text not null,
  origem_uf           char(2) not null,
  origem_referencia   text,

  -- Destino
  destino_cep         text not null,
  destino_endereco    text not null,
  destino_numero      text not null,
  destino_complemento text,
  destino_bairro      text not null,
  destino_cidade      text not null,
  destino_uf          char(2) not null,
  destino_referencia  text,

  -- Apoio de carga
  qtd_ajudantes       integer not null default 0,
  precisa_montagem    boolean not null default false,
  precisa_embalagem   boolean not null default false,
  observacoes_gerais  text,

  -- Status
  status              text not null default 'aberto'
                        check (status in ('aberto', 'em_andamento', 'concluido', 'cancelado')),
  criado_em           timestamptz not null default now()
);

-- 2. Row Level Security — fretes
alter table public.fretes enable row level security;

create policy "Cliente insere próprios fretes"
  on public.fretes for insert
  with check (auth.uid() = cliente_id);

create policy "Cliente lê próprios fretes"
  on public.fretes for select
  using (auth.uid() = cliente_id);

create policy "Cliente atualiza próprios fretes"
  on public.fretes for update
  using (auth.uid() = cliente_id);

-- 3. Paradas intermediárias
create table if not exists public.frete_paradas (
  id          uuid primary key default gen_random_uuid(),
  frete_id    uuid not null references public.fretes (id) on delete cascade,
  ordem       integer not null,
  cep         text not null,
  endereco    text not null,
  numero      text not null,
  complemento text,
  bairro      text not null,
  cidade      text not null,
  uf          char(2) not null,
  referencia  text
);

-- 4. Row Level Security — frete_paradas (via frete)
alter table public.frete_paradas enable row level security;

create policy "Cliente insere paradas dos próprios fretes"
  on public.frete_paradas for insert
  with check (
    exists (
      select 1 from public.fretes
      where id = frete_id and cliente_id = auth.uid()
    )
  );

create policy "Cliente lê paradas dos próprios fretes"
  on public.frete_paradas for select
  using (
    exists (
      select 1 from public.fretes
      where id = frete_id and cliente_id = auth.uid()
    )
  );

-- 5. Itens do frete
create table if not exists public.frete_itens (
  id         uuid primary key default gen_random_uuid(),
  frete_id   uuid not null references public.fretes (id) on delete cascade,
  ordem      integer not null,
  nome       text not null,
  quantidade integer not null default 1 check (quantidade > 0),
  categoria  text,
  observacao text
);

-- 6. Row Level Security — frete_itens (via frete)
alter table public.frete_itens enable row level security;

create policy "Cliente insere itens dos próprios fretes"
  on public.frete_itens for insert
  with check (
    exists (
      select 1 from public.fretes
      where id = frete_id and cliente_id = auth.uid()
    )
  );

create policy "Cliente lê itens dos próprios fretes"
  on public.frete_itens for select
  using (
    exists (
      select 1 from public.fretes
      where id = frete_id and cliente_id = auth.uid()
    )
  );
