-- Borra todo para comenzar con la base de datos desde 0
DROP SCHEMA public cascade; CREATE SCHEMA public;
GRANT all ON SCHEMA public TO postgres;

CREATE EXTENSION pgcrypto;
CREATE EXTENSION postgis;

CREATE TABLE users(
    user_id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid() ,
    username VARCHAR NOT NULL,
    email VARCHAR NOT NULL UNIQUE,
    password VARCHAR NOT NULL,
    description VARCHAR,
    avatar BYTEA,
    type INT NOT NULL,                                      -- Tipo de usuario -> 1. Asistente | 2.Organizador | 0.Admin
    registration_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_access TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE post(
    post_id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(user_id),
    event_id uuid NOT NULL REFERENCES event(event_id),
    content VARCHAR NOT NULL,
    creation_date TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE event(
    event_id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(user_id),
    title VARCHAR NOT NULL,
    description VARCHAR,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    geoloc GEOGRAPHY 
);

CREATE TABLE tag(
    tag_id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL,
    color VARCHAR NOT NULL
)

CREATE TABLE event_tag(
    event_tag_id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id uuid NOT NULL REFERENCES event(event_id),
    tag_id uuid NOT NULL REFERENCES tag(tag_id)
)

CREATE TABLE file(
    file_id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(user_id),
    filename VARCHAR NOT NULL
)

CREATE TABLE event_file(
    event_file_id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id uuid NOT NULL REFERENCES event(event_id),
    file_id uuid NOT NULL REFERENCES file(file_id)
)

CREATE TABLE event_like(
    event_like_id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(user_id),
    event_id uuid NOT NULL REFERENCES event(event_id),
    creation_date TIMESTAMPTZ NOT NULL DEFAULT NOW()
)

