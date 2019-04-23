CREATE TABLE "blog"."articles"
(
  id         BIGSERIAL NOT NULL CONSTRAINT articles_pk PRIMARY KEY,
  user_id    BIGINT    NOT NULL CONSTRAINT articles_users_id_fk REFERENCES "blog"."users",
  title      TEXT      NOT NULL,
  body       TEXT      NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  deleted_at TIMESTAMP
);
