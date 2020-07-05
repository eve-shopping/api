-- +micrate Up
CREATE TABLE "sde"."regions"
(
    -- region_id
    "id"   INT  NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
);

CREATE TABLE "sde"."constellations"
(
    -- constellation_id
    "id"        INT  NOT NULL PRIMARY KEY,
    "region_id" INT  NOT NULL REFERENCES "sde"."regions",
    "name"      TEXT NOT NULL
);

CREATE TABLE "sde"."systems"
(
    -- system_id
    "id"               INT              NOT NULL,
    "constellation_id" INT              NOT NULL REFERENCES "sde"."constellations",
    "region_id"        INT              NOT NULL REFERENCES "sde"."regions",
    "name"             TEXT             NOT NULL,
    "security"         DOUBLE PRECISION NOT NULL
);


-- +micrate Down
DROP TABLE "sde"."regions";
DROP TABLE "sde"."constellations";
DROP TABLE "sde"."systems";