CREATE TABLE "blog"."users"
(
    "id"         BIGSERIAL NOT NULL PRIMARY KEY,
    "first_name" TEXT      NOT NULL,
    "last_name"  TEXT      NOT NULL,
    "email"      TEXT      NOT NULL,
    "password"   TEXT      NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT NOW(),
    "updated_at" TIMESTAMP NOT NULL DEFAULT NOW(),
    "deleted_at" TIMESTAMP NULL
);
