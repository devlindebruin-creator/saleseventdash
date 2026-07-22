-- Agium Sales Dashboard — Supabase schema
-- Voer dit één keer uit in de Supabase SQL Editor van je nieuwe project.

-- ============ EVENTS ============
create table if not exists events (
  id           uuid primary key default gen_random_uuid(),
  name         text unique not null,
  event_date   date,
  sort_order   double precision not null default extract(epoch from now()),
  created_at   timestamptz not null default now()
);

-- ============ CONTACTS ============
create table if not exists contacts (
  id           uuid primary key default gen_random_uuid(),
  event_name   text not null references events(name) on update cascade on delete cascade,
  aanwezig     text,        -- 'Ja' | 'Nee' | null
  organisatie  text,
  contact      text,
  functie      text,
  bm           text,        -- Arno, Joost, Marc, Max, Olaf, Sander, Roberto, Michael
  actie_voor   text,        -- Call, Teams, Visit, Mail
  actie_na     text,
  propositie   text,        -- ABS, AI, Deta, W&S, Kerst, Events, Golf, ABC
  response     text,        -- 'Ja' | 'Nee' | null
  afspraak     text,        -- 'Ja' | 'Nee' | null
  aanvraag     text,        -- 'Ja' | 'Nee' | null
  klant_type   text,        -- 'Nieuw' | 'Bestaand' | null
  opmerkingen  jsonb not null default '[]'::jsonb,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists idx_contacts_event_name on contacts(event_name);

-- Houd updated_at automatisch bij
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_contacts_updated_at on contacts;
create trigger trg_contacts_updated_at
  before update on contacts
  for each row execute function set_updated_at();

-- ============ ROW LEVEL SECURITY ============
-- Let op: dit is een intern tool zonder inlogscherm. Onderstaande policies
-- staan lezen EN schrijven toe voor iedereen die de anon-key heeft (die key
-- staat straks gewoon zichtbaar in de HTML-broncode op GitHub Pages).
-- Prima voor een team-intern dashboard achter een niet voor de hand liggende
-- URL, maar geen echte toegangsbeveiliging. Zie README voor alternatieven.

alter table events enable row level security;
alter table contacts enable row level security;

create policy "public read events" on events
  for select using (true);
create policy "public write events" on events
  for insert with check (true);
create policy "public update events" on events
  for update using (true);
create policy "public delete events" on events
  for delete using (true);

create policy "public read contacts" on contacts
  for select using (true);
create policy "public write contacts" on contacts
  for insert with check (true);
create policy "public update contacts" on contacts
  for update using (true);
create policy "public delete contacts" on contacts
  for delete using (true);

-- ============ REALTIME (optioneel, voor live updates tussen meerdere gebruikers) ============
alter publication supabase_realtime add table events;
alter publication supabase_realtime add table contacts;
