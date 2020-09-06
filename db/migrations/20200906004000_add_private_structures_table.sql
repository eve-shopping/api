-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE "private_structures"
(
    -- structure_id
    "id"         BIGINT      NOT NULL PRIMARY KEY,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE "private_structures";
