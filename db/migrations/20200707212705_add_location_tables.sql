-- +micrate Up
CREATE TABLE "structures"
(
    -- location_id
    "id"         BIGINT      NOT NULL PRIMARY KEY,
    "system_id"  INT         NOT NULL REFERENCES "sde"."systems",
    "type_id"    INT         NOT NULL REFERENCES "sde"."types",
    "name"       TEXT        NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT NOW(),
    "updated_at" timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at" timestamptz NULL
);

CREATE TABLE "sde"."stations"
(
    -- station_id
    "id"         INT      NOT NULL PRIMARY KEY,
    "system_id"  INT         NOT NULL REFERENCES "sde"."systems",
    "type_id"    INT         NOT NULL REFERENCES "sde"."types",
    "name"       TEXT        NOT NULL
);


-- +micrate Down
DROP TABLE "structures"
DROP TABLE "sde"."stations"
