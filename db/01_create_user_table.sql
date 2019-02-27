CREATE TABLE "blog"."users"
(
  id BIGSERIAL NOT NULL CONSTRAINT users_pk PRIMARY KEY,
  first_name TEXT      NOT NULL,
  last_name  TEXT      NOT NULL,
  email      TEXT      NOT NULL,
  password   TEXT      NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  deleted_at TIMESTAMP
);