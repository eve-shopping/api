-- +micrate Up
CREATE TYPE CONTRACT_STRUCTURE_AFFILIATION_ORIGIN AS ENUM ('start', 'end');

CREATE TABLE "contract_structure_affiliations"
(
    "contract_id"    INT                                     NOT NULL REFERENCES "contracts",
    "origin"         CONTRACT_STRUCTURE_AFFILIATION_ORIGIN   NOT NULL,
    "structure_id"   BIGINT                                  NOT NULL REFERENCES "structures",
    "corporation_id" INT                                     NOT NULL REFERENCES "corporations",
    "alliance_id"    INT                                     NULL REFERENCES "alliances",
    PRIMARY KEY ("contract_id", "origin")
);


-- +micrate Down
DROP TYPE "CONTRACT_STRUCTURE_AFFILIATION_ORIGIN";
DROP TABLE "contract_structure_affiliations";
