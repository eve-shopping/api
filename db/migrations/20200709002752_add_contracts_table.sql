-- +micrate Up
CREATE TYPE CONTRACT_TYPE AS ENUM ('unknown', 'item_exchange', 'auction', 'courier', 'loan');
CREATE TYPE CONTRACT_STATUS AS ENUM ('outstanding', 'in_progress', 'finished_issuer', 'finished_contractor', 'finished', 'cancelled', 'rejected', 'failed', 'deleted', 'reversed', 'unknown');
CREATE TYPE CONTRACT_AVAILABILITY AS ENUM ('public', 'personal', 'corporation', 'alliance');
CREATE TYPE CONTRACT_ORIGIN AS ENUM ('public', 'corporation', 'character');

CREATE TABLE "contracts"
(
    -- contract_id
    "id"                    INT                   NOT NULL PRIMARY KEY,
    "issuer_id"             INT                   NOT NULL REFERENCES "characters",
    "issuer_corporation_id" INT                   NOT NULL REFERENCES "corporations",
    "issuer_alliance_id"    INT                   NULL REFERENCES "alliances",
    "start_location_id"     BIGINT                NOT NULL -- REFERENCES "structures",
    "end_location_id"       BIGINT                NULL -- REFERENCES "structures" -- CHECK ( "type" = 'courier' ),
    "assignee_id"           INT                   NULL REFERENCES "characters" -- CHECK ( "availability" != 'public' ),
    "acceptor_id"           INT                   NULL REFERENCES "characters",
    "title"                 TEXT                  NOT NULL,
    "volume"                DOUBLE PRECISION      NOT NULL,
    "reward"                DOUBLE PRECISION      NULL -- CHECK ( "type" = 'courier' ),
    "collateral"            DOUBLE PRECISION      NULL -- CHECK ( "type" = 'courier' ),
    "price"                 DOUBLE PRECISION      NULL -- CHECK ( "type" = 'item_exchange' OR "type" = 'auction' ),
    "buyout"                DOUBLE PRECISION      NULL -- CHECK ( "type" = 'auction' ),
    "status"                CONTRACT_STATUS       NOT NULL,
    "type"                  CONTRACT_TYPE         NOT NULL,
    "availability"          CONTRACT_AVAILABILITY NOT NULL,
    "origin"                CONTRACT_ORIGIN       NOT NULL,
    "days_to_complete"      INT                   NULL -- CHECK ( "type" = 'courier' ),
    "for_corporation"       BOOLEAN               NOT NULL,
    "date_issued"           TIMESTAMPTZ           NOT NULL,
    "date_accepted"         TIMESTAMPTZ           NULL,
    "date_completed"        TIMESTAMPTZ           NULL,
    "date_expired"          TIMESTAMPTZ           NOT NULL
);


-- +micrate Down
DROP TYPE CONTRACT_TYPE, CONTRACT_STATUS, CONTRACT_AVAILABILITY, CONTRACT_ORIGIN;
DROP TABLE "contracts";
