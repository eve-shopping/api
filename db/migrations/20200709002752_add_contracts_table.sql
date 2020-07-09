-- +micrate Up
CREATE TYPE contract_type AS ENUM ('unknown', 'item_exchange', 'auction', 'courier', 'loan');
CREATE TYPE contract_status AS ENUM ('outstanding', 'in_progress', 'finished_issuer', 'finished_contractor', 'finished', 'cancelled', 'rejected', 'failed', 'deleted', 'reversed', 'unknown');
CREATE TYPE contract_availability AS ENUM ('public', 'personal', 'corporation', 'alliance');
CREATE TYPE contract_origin AS ENUM ('public', 'corporation', 'character');

CREATE TABLE "contracts"
(
    -- contract_id
    "id"                                  INT                   NOT NULL PRIMARY KEY,
    "issuer_id"                           INT                   NOT NULL REFERENCES "characters",
    "issuer_corporation_id"               INT                   NOT NULL REFERENCES "corporations",
    "issuer_alliance_id"                  INT                   NULL REFERENCES "alliances",
    "start_location_id"                   BIGINT                NOT NULL REFERENCES "locations",
    "start_location_owner_corporation_id" INT                   NOT NULL REFERENCES "corporations",
    "start_location_owner_alliance_id"    INT                   NULL REFERENCES "alliances",
    "end_location_id"                     BIGINT                NULL REFERENCES "locations" CHECK ( type = 'courier' ),
    "end_location_owner_corporation_id"   INT                   NULL REFERENCES "corporations" CHECK ( type = 'courier' ),
    "end_location_owner_alliance_id"      INT                   NULL REFERENCES "alliances" CHECK ( type = 'courier' ),
    "assignee_id"                         INT                   NULL REFERENCES "characters" CHECK ( availability != 'public' ),
    "acceptor_id"                         INT                   NULL REFERENCES "characters",
    "title"                               TEXT                  NOT NULL,
    "volume"                              DOUBLE PRECISION      NOT NULL,
    "reward"                              DOUBLE PRECISION      NULL CHECK ( type = 'courier' ),
    "collateral"                          DOUBLE PRECISION      NULL CHECK ( type = 'courier' ),
    "price"                               DOUBLE PRECISION      NULL CHECK ( type = 'item_exchange' OR type = 'auction' ),
    "buyout"                              DOUBLE PRECISION      NULL CHECK ( type = 'auction' ),
    "status"                              contract_status       NOT NULL,
    "type"                                contract_type         NOT NULL,
    "availability"                        contract_availability NOT NULL,
    "origin"                              contract_origin       NOT NULL,
    "days_to_complete"                    INT                   NULL CHECK ( type = 'courier' ),
    "for_corporation"                     BOOLEAN               NOT NULL,
    "date_issued"                         timestamptz           NOT NULL,
    "date_accepted"                       timestamptz           NULL,
    "date_completed"                      timestamptz           NULL,
    "date_expired"                        timestamptz           NOT NULL
);


-- +micrate Down
DROP TYPE contract_type, contract_status, contract_availability, contract_origin;
DROP TABLE "contracts";
