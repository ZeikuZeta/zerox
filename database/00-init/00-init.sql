create extension if not exists "uuid-ossp";

create role web_anon nologin;

create role authenticator noinherit login password '{{authenticator_password}}';

grant web_anon to authenticator;