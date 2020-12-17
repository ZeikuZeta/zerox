create table internal.files (
    id uuid primary key default uuid_generate_v4(),
    type text,
    name text,
    blob bytea
);