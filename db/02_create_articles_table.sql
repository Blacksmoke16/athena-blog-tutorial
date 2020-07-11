CREATE TABLE "blog"."articles"
(
    "id"         BIGSERIAL NOT NULL PRIMARY KEY,
    "user_id"    BIGINT    NOT NULL REFERENCES "blog"."users",
    "title"      TEXT      NOT NULL,
    "body"       TEXT      NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMP NOT NULL DEFAULT NOW(),
    "deleted_at" TIMESTAMP NULL
);
