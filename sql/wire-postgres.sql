--
--  WIre schema for Postgres tested on 9.5.4
--
SET search_path TO wire;

CREATE USER wire WITH PASSWORD 'changeme';
CREATE SCHEMA wire AUTHORIZATION wire;

DROP TABLE IF EXISTS wire.ippacket;
CREATE TABLE wire.ippacket (
  id SERIAL,
  guid char(36) NOT NULL,
  recv_date DATE,
  recv_time TIME,
  ip_df VARCHAR(5),
  ip_dst VARCHAR(15) DEFAULT NULL,
  ip_hlen integer NOT NULL,
  ip_id integer NOT NULL,
  ip_len integer NOT NULL,
  ip_mf VARCHAR(5) DEFAULT NULL,
  ip_off integer,
  ip_proto integer NOT NULL,
  ip_src VARCHAR(15) DEFAULT NULL,
  ip_sum VARCHAR(10) DEFAULT NULL,
  ip_tos integer NOT NULL,
  ip_ttl integer NOT NULL,
  ip_ver integer NOT NULL
);
GRANT SELECT, INSERT, DELETE ON wire.ippacket TO wire;
CREATE UNIQUE INDEX ippacket_guid ON wire.ippacket (guid);

DROP TABLE IF EXISTS wire.tcppacket;
DROP TYPE IF EXISTS flags;
CREATE TYPE flags AS ENUM ('true', 'false');
CREATE TABLE wire.tcppacket (
  id SERIAL,
  guid char(36) NOT NULL,
  recv_date DATE,
  recv_time TIME,
  tcp_data bytea,
  tcp_data_len integer DEFAULT NULL,
  tcp_dport integer DEFAULT NULL,
  tcp_ack flags DEFAULT NULL,
  tcp_fin flags DEFAULT NULL,
  tcp_syn flags DEFAULT NULL,
  tcp_rst flags DEFAULT NULL,
  tcp_psh flags DEFAULT NULL,
  tcp_urg flags DEFAULT NULL,
  tcp_off integer DEFAULT NULL,
  tcp_hlen integer DEFAULT NULL,
  tcp_seq bigint DEFAULT NULL,
  tcp_sum VARCHAR(10) DEFAULT NULL,
  tcp_sport integer DEFAULT NULL,
  tcp_urp VARCHAR(10) DEFAULT NULL,
  tcp_win VARCHAR(10) DEFAULT NULL
);
GRANT SELECT, INSERT, DELETE ON wire.tcppacket TO wire;
CREATE UNIQUE INDEX tcppacket_guid ON wire.tcppacket (guid);

DROP TABLE IF EXISTS wire.udppacket;
CREATE TABLE wire.udppacket (
  id SERIAL,
  guid char(36) NOT NULL,
  recv_date DATE,
  recv_time TIME,
  udp_data bytea,
  udp_dport integer DEFAULT NULL,
  udp_len integer DEFAULT NULL,
  udp_sum VARCHAR(10) DEFAULT NULL,
  udp_sport integer DEFAULT NULL
);
GRANT SELECT, INSERT, DELETE ON wire.udppacket TO wire;
CREATE UNIQUE INDEX udppacket_guid ON wire.udppacket (guid);
