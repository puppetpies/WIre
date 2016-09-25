--
--  WIre HTTP Body schema for MySQL
--
USE wire;

DROP TABLE http_traffic_json;
CREATE TABLE http_traffic_json (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  guid CHAR(36) NOT NULL,
  recv_date DATE,
  recv_time TIME,
  json_data TEXT
);

DROP TABLE http_traffic_ua;
CREATE TABLE http_traffic_ua (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  family VARCHAR(30),
  major CHAR(10) DEFAULT 'NaN',
  minor CHAR(10) DEFAULT 'NaN',
  os CHAR(30) NOT NULL,
  guid CHAR(36) NOT NULL
);
