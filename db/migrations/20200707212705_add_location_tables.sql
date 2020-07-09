-- +micrate Up
CREATE TABLE "locations"
(
    -- location_id
    "id"         BIGINT      NOT NULL PRIMARY KEY,
    "system_id"  INT         NOT NULL REFERENCES "sde"."systems",
    "type_id"    INT         NOT NULL REFERENCES "sde"."types",
    "name"       TEXT        NOT NULL,
    "etag"       TEXT        NULL CHECK ( id > 2147483647 ),
    "created_at" timestamptz NOT NULL DEFAULT NOW(),
    "updated_at" timestamptz NOT NULL DEFAULT NOW(),
    "deleted_at" timestamptz NULL
);


-- +micrate Down
DROP TABLE "locations"
