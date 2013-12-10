CREATE DATABASE json_to_xls;

CREATE ROLE json_to_xls_role;

GRANT ALL PRIVILEGES ON DATABASE json_to_xls TO json_to_xls_role;

CREATE USER json_to_xls_user WITH NOSUPERUSER LOGIN ROLE json_to_xls_role PASSWORD 'bottlebuttermilk';