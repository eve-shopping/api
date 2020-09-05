-- +micrate Up
create schema "blog";
ALTER ROLE "blog_user" SET SEARCH_PATH TO "blog";


-- +micrate Down
DROP SCHEMA "sde";
ALTER ROLE "eve-shopping" SET SEARCH_PATH TO "public";
