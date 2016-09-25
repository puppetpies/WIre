--
--  WIre HTTP Body schema for MonetDB
--
SET SCHEMA "wire";

DROP TABLE "wire".http_traffic_json;
CREATE TABLE "wire".http_traffic_json (
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) PRIMARY KEY,
  guid CHAR(36) NOT NULL,
  recv_date DATE,
  recv_time TIME,
  json_data JSON
);

CREATE INDEX index_traffic_json_id ON "wire".http_traffic_json(id);
CREATE INDEX index_traffic_json_guid ON "wire".http_traffic_json(guid);

DROP TABLE "wire".http_traffic_ua;
CREATE TABLE "wire".http_traffic_ua (
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) PRIMARY KEY,
  family VARCHAR(30),
  major CHAR(10) DEFAULT 'NaN',
  minor CHAR(10) DEFAULT 'NaN',
  os CHAR(30) NOT NULL,
  guid CHAR(36) NOT NULL
);

CREATE INDEX index_traffic_ua_id ON "wire".http_traffic_ua(id);
CREATE INDEX index_traffic_ua_guid ON "wire".http_traffic_ua(guid);
