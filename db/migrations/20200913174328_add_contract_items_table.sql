-- +micrate Up
CREATE TABLE "contract_items"
(
    -- record_id
    "id"                  BIGINT  NOT NULL PRIMARY KEY,
    "contract_id"         INT     NOT NULL REFERENCES "contracts",
    "type_id"             INT     NOT NULL REFERENCES "sde"."types",
    "quantity"            INT     NOT NULL,
    "is_included"         BOOLEAN NOT NULL,
    "item_id"             BIGINT  NULL,
    "is_blueprint_copy"   BOOLEAN NOT NULL DEFAULT FALSE,
    "runs"                INT     NULL,
    "material_efficiency" INT     NULL,
    "time_efficiency"     INT     NULL
);


-- +micrate Down
DROP TABLE "contract_items";
