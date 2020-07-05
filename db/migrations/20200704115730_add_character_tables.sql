-- +micrate Up
CREATE TABLE "alliances"
(
    -- alliance_id
    "id"   INT  NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
);

CREATE TABLE "corporations"
(
    -- corporation_id
    "id"          INT  NOT NULL PRIMARY KEY,
    "name"        TEXT NOT NULL
);

CREATE TABLE "characters"
(
    -- character_id
    "id"             INT  NOT NULL PRIMARY KEY,
    "name"           TEXT NOT NULL
);


-- +micrate Down
DROP TABLE "alliances";
DROP TABLE "corporations";
DROP TABLE "characters";
