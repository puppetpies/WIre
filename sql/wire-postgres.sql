CREATE USER wire WITH PASSWORD 'changeme';

GRANT INSERT, DELETE ON ippacket TO wire;
GRANT INSERT, DELETE ON tcppacket TO wire;
GRANT INSERT, DELETE ON udppacket TO wire;

CREATE SCHEMA wire AUTHORIZATION wire;

DROP TABLE IF EXISTS wire.ippacket;
CREATE TABLE wire.ippacket (
  id integer UNIQUE NOT NULL
  recv_date TIMESTAMP WITHOUT TIME ZONE,
  ip_df character(5) NOT NULL,
  ip_dst character(15) DEFAULT NULL,
  ip_hlen integer NOT NULL,
  ip_id integer NOT NULL,
  ip_len integer NOT NULL,
  ip_mf character(5) DEFAULT NULL,
  ip_off integer NOT NULL,
  ip_proto integer NOT NULL,
  ip_src character(15) DEFAULT NULL,
  ip_sum character(10) DEFAULT NULL,
  ip_tos integer NOT NULL,
  ip_ttl integer NOT NULL,
  ip_ver integer NOT NULL
);

CREATE TYPE flags AS ENUM ('Y', 'N');
DROP TABLE IF EXISTS wire.tcppacket;
CREATE TABLE wire.tcppacket (
  id integer UNIQUE NOT NULL,
  recv_date TIMESTAMP WITHOUT TIME ZONE,
  tcp_data blob,
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
  tcp_sum character(10) DEFAULT NULL,
  tcp_sport integer DEFAULT NULL,
  tcp_urp character(10) DEFAULT NULL,
  tcp_win character(10) DEFAULT NULL
);

DROP TABLE IF EXISTS wire.udppacket;
CREATE TABLE wire.udppacket (
  id integer UNIQUE NOT NULL,
  recv_date TIMESTAMP WITHOUT TIME ZONE,
  udp_data blob,
  udp_dport integer DEFAULT NULL,
  udp_len integer DEFAULT NULL,
  udp_sum character(10) DEFAULT NULL,
  udp_sport integer DEFAULT NULL
);
