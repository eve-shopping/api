-- +micrate Up
CREATE TABLE "sde"."categories"
(
    -- category_id
    "id"        INT  NOT NULL PRIMARY KEY,
    "name"      TEXT NOT NULL,
    "published" BOOL NOT NULL
);

CREATE TABLE "sde"."groups"
(
    -- group_id
    "id"          INT  NOT NULL PRIMARY KEY,
    "name"        TEXT NOT NULL,
    "category_id" INT  NOT NULL REFERENCES "sde"."categories",
    "published"   BOOL NOT NULL
);

CREATE TABLE "sde"."types"
(
    -- type_id
    "id"          INT   NOT NULL PRIMARY KEY,
    "name"        TEXT  NOT NULL,
    "group_id"    INT   NOT NULL REFERENCES "sde"."groups",
    "published"   BOOL  NOT NULL,
    "description" TEXT  NOT NULL,
    "volume"      FLOAT NOT NULL
);


-- +micrate Down
DROP TABLE "sde"."categories";
DROP TABLE "sde"."groups";
DROP TABLE "sde"."types";
