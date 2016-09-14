-- 
-- WIre schema for MonetDB
--

CREATE USER "wire" WITH PASSWORD 'changeme' NAME 'wire' SCHEMA "sys";
CREATE SCHEMA "wire" AUTHORIZATION "wire";
ALTER USER "wire" SET SCHEMA "wire";

DROP TABLE "wire".ippacket;
CREATE TABLE "wire".ippacket (
  "id" bigint NOT NULL primary key,
  "recv_date" string,
  "ip_df" varchar(5),
  "ip_dst" varchar(15),
  "ip_hlen" int not null,
  "ip_id" int not null,
  "ip_len" int not null,
  "ip_mf" varchar(5),
  "ip_off" int not null,
  "ip_proto" int not null,
  "ip_src" varchar(15),
  "ip_sum" char(10),
  "ip_tos" int not null,
  "ip_ttl" int not null,
  "ip_ver" int not null 
);
CREATE INDEX index_id_defaultip ON "wire".ippacket(id);
CREATE INDEX index_ip_dst_defaultip ON "wire".ippacket(ip_dst);
CREATE INDEX index_ip_src_defaultip ON "wire".ippacket(ip_src);

DROP TABLE "wire".tcppacket;
CREATE TABLE "wire".tcppacket (
  "id" bigint NOT NULL primary key,
  "recv_date" string,
  "tcp_data_len" int DEFAULT NULL,
  "tcp_dport" int DEFAULT NULL,
  "tcp_ack" char(1) DEFAULT NULL,
  "tcp_fin" char(1) DEFAULT NULL,
  "tcp_syn" char(1)DEFAULT NULL,
  "tcp_rst" char(1) DEFAULT NULL,
  "tcp_psh" char(1) DEFAULT NULL,
  "tcp_urg" char(1) DEFAULT NULL,
  "tcp_off" int DEFAULT NULL,
  "tcp_hlen" int DEFAULT NULL,
  "tcp_seq" bigint DEFAULT NULL,
  "tcp_sum" char(10) DEFAULT NULL,
  "tcp_sport" int DEFAULT NULL,
  "tcp_urp" char(10) DEFAULT NULL,
  "tcp_win" int DEFAULT NULL
);
CREATE INDEX index_id_defaulttcp ON "wire".tcppacket(id);
CREATE INDEX index_tcp_dport_defaulttcp ON "wire".tcppacket(tcp_dport);
CREATE INDEX index_tcp_sport_defaulttcp ON "wire".tcppacket(tcp_sport);

DROP TABLE "wire".udppacket;
CREATE TABLE "wire".udppacket (
  "id" bigint NOT NULL primary key,
  "recv_date" string,
  "udp_dport" int,
  "udp_len" int,
  "udp_sum" char(10) DEFAULT NULL,
  "udp_sport" int DEFAULT NULL
);
CREATE INDEX index_id_defaultudp ON "wire".udppacket(id);
CREATE INDEX index_udp_dport_defaultudp ON "wire".udppacket(udp_dport);
CREATE INDEX index_udp_sport_defaultudp ON "wire".udppacket(udp_sport);
