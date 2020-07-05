-- +micrate Up
CREATE TABLE "sde"."categories"
(
    -- category_id
    "id"        INT     NOT NULL PRIMARY KEY,
    "name"      TEXT    NOT NULL,
    "published" BOOLEAN NOT NULL
);

CREATE TABLE "sde"."groups"
(
    -- group_id
    "id"          INT     NOT NULL PRIMARY KEY,
    "category_id" INT     NOT NULL REFERENCES "sde"."categories",
    "name"        TEXT    NOT NULL,
    "published"   BOOLEAN NOT NULL
);

CREATE TABLE "sde"."types"
(
    -- type_id
    "id"          INT     NOT NULL PRIMARY KEY,
    "group_id"    INT     NOT NULL REFERENCES "sde"."groups",
    "name"        TEXT    NOT NULL,
    "description" TEXT    NOT NULL,
    "volume"      REAL    NOT NULL,
    "published"   BOOLEAN NOT NULL
);


-- +micrate Down
DROP TABLE "sde"."categories";
DROP TABLE "sde"."groups";
DROP TABLE "sde"."types";
