create table api.accounts (
    id uuid primary key default uuid_generate_v4(),
    first_name text not null,
    last_name text not null,
    email text not null unique,
    birth_date date,
    role_string text not null unique
);

alter table api.accounts enable row level security;

create policy api_accounts_all on api.accounts
    using (current_user = role_string)
    with check (current_user = role_string);

-- All user can insert or update only description and logo but select all field.
grant select on api.accounts to PUBLIC;

-- Admin can select, insert, update and delete anything.
grant select, insert, update, delete on api.accounts to zerox;