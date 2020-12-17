--
-- Organization and Organizations_Auth type
--

create type organization_tier_type as enum ('free', 'bronze', 'silver', 'gold');

create type organization_status_type as enum ('active', 'suspended', 'disabled');

create type organization_role_type as enum ('viewer', 'member', 'manager', 'owner');

--
-- Organizations System
--

create function internal.get_user_role(o_id uuid)
returns text as $$
declare
    a_id uuid;
    role_t organization_role_type;
begin
    select id into a_id
    from api.accounts
    where role_string = current_user;

    select role_type into role_t
    from api.organizations_auths
    where account_id = a_id and organization_id = o_id;

    return role_t;
end;
$$ language plpgsql;

create table api.organizations (
    id uuid primary key default uuid_generate_v4(),
    description text not null default 'My Organization',
    logo uuid references internal.files,
    tier_type organization_tier_type not null default 'free',
    status_type organization_status_type not null default 'active'
);

insert into api.organizations (description) values ('My Organization');

alter table api.organizations enable row level security;

-- Administrator can see all rows and add any rows.
create policy zerox_all on api.organizations to zerox using (true) with check (true);

-- Viewer and member of an organization can only select this organization.
create policy viewer on api.organizations for select using (internal.get_user_role(id) = 'viewer');
create policy member on api.organizations for select using (internal.get_user_role(id) = 'member');

-- Manager of an organization can select and update this organization.
create policy manager_select on api.organizations for select using (internal.get_user_role(id) = 'manager');
create policy manager_update on api.organizations for update using (internal.get_user_role(id) = 'manager') with check (internal.get_user_role(id) = 'manager');

-- Owner of an organization can select, update and delete this organization.
create policy owner_select on api.organizations for select using (internal.get_user_role(id) = 'owner');
create policy owner_update on api.organizations for update using (internal.get_user_role(id) = 'owner') with check (internal.get_user_role(id) = 'owner');
create policy owner_delete on api.organizations for delete using (internal.get_user_role(id) = 'owner');

-- All user can insert or update only description and logo but select all field.
grant select, insert (description, logo), update (description, logo), delete on api.organizations to PUBLIC;

-- Admin can select, insert, update and delete anything.
grant select, insert, update, delete on api.organizations to zerox;


--
-- Organizations Authorization System
--

create table api.organizations_auths (
    id uuid primary key default uuid_generate_v4(),
    organization_id uuid references api.organizations not null,
    account_id uuid references api.accounts not null,
    role_type organization_role_type not null,
    unique (organization_id, account_id)
);

alter table api.organizations_auths enable row level security;

-- Administrator can see all rows and add any rows.
create policy zerox_all on api.organizations_auths to zerox using (true) with check (true);

-- Viewer and member of an organization can only select auths of this organization.
create policy viewer on api.organizations_auths for select using (internal.get_user_role(organization_id) = 'viewer');
create policy member on api.organizations_auths for select using (internal.get_user_role(organization_id) = 'member');

-- Manager can select, update, insert or delete (except for owner)
create policy manager_select on api.organizations_auths for select using (internal.get_user_role(organization_id) = 'manager');
create policy manager_insert on api.organizations_auths for insert with check (internal.get_user_role(organization_id) = 'manager' and role_type != 'owner');
create policy manager_update on api.organizations_auths for update using (internal.get_user_role(organization_id) = 'manager')
    with check (internal.get_user_role(organization_id) = 'manager' and role_type != 'owner');
create policy manager_delete on api.organizations_auths for delete using (internal.get_user_role(organization_id) = 'manager' and role_type != 'owner');

-- Owner can select, update, insert or delete
create policy owner_select on api.organizations_auths for select using (internal.get_user_role(organization_id) = 'owner');
create policy owner_insert on api.organizations_auths for insert with check (internal.get_user_role(organization_id) = 'owner');
create policy owner_update on api.organizations_auths for update using (internal.get_user_role(organization_id) = 'owner')
    with check (internal.get_user_role(organization_id) = 'owner');
create policy owner_delete on api.organizations_auths for delete using (internal.get_user_role(organization_id) = 'owner');

grant select, insert, update, delete on api.organizations_auths to PUBLIC;


--
-- TRIGGERS
--

-- Create a organizations_auth 'owner' for each insert in organizations table
create function internal.insert_organization_owner() returns trigger as $$
declare
    a_id uuid;
begin
    select id into a_id
    from api.accounts
    where role_string = current_user;

    -- UNSAFE, maybe change ROLE
    insert into api.organizations_auths (organization_id, account_id, role_type) values (NEW.id, a_id, 'owner');

    return NULL;
end;
$$ language plpgsql;

create trigger trigger_insert_organization_owner
    after insert on api.organizations
    for each row execute procedure internal.insert_organization_owner();