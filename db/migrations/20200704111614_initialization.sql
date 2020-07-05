-- +micrate Up
CREATE SCHEMA "sde";
ALTER ROLE "eve-shopping" SET SEARCH_PATH TO "public", "sde";


-- +micrate Down
DROP SCHEMA "sde";
ALTER ROLE "eve-shopping" SET SEARCH_PATH TO "public";
