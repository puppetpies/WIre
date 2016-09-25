--
--  WIre HTTP Body schema for Postgres
--
SET search_path TO wire;

DROP TABLE IF EXISTS http_traffic_json;
CREATE TABLE http_traffic_json (
  id integer UNIQUE NOT NULL,
  guid character(36) NOT NULL,
  recv_date DATE,
  recv_time TIME,
  json_data TEXT
);

DROP TABLE IF EXISTS http_traffic_ua;
CREATE TABLE http_traffic_ua (
  id integer UNIQUE NOT NULL,
  family VARCHAR(30),
  major VARCHAR(10) DEFAULT 'NaN',
  minor VARCHAR(10) DEFAULT 'NaN',
  os VARCHAR(30) NOT NULL,
  guid VARCHAR(36) NOT NULL
);
