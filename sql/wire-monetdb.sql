-- 
-- WIre schema for MonetDB
--

CREATE USER "wire" WITH PASSWORD 'changeme' NAME 'wire' SCHEMA "sys";
CREATE SCHEMA "wire" AUTHORIZATION "wire";
ALTER USER "wire" SET SCHEMA "wire";

DROP TABLE "wire".ippacket;
CREATE TABLE "wire".ippacket (
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) NOT NULL primary key,
  "guid" CHAR(36) NOT NULL,
  "recv_date" date,
  "recv_time" time,
  "ip_df" varchar(5),
  "ip_dst" varchar(15),
  "ip_hlen" int not null,
  "ip_id" int not null,
  "ip_len" int not null,
  "ip_mf" varchar(5),
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
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) NOT NULL primary key,
  "guid" CHAR(36) NOT NULL,
  "recv_date" date,
  "recv_time" time,
  "tcp_data_len" int DEFAULT NULL,
  "tcp_dport" int DEFAULT NULL,
  "tcp_ack" char(5) DEFAULT NULL,
  "tcp_fin" char(5) DEFAULT NULL,
  "tcp_syn" char(5) DEFAULT NULL,
  "tcp_rst" char(5) DEFAULT NULL,
  "tcp_psh" char(5) DEFAULT NULL,
  "tcp_urg" char(5) DEFAULT NULL,
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
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) NOT NULL primary key,
  "guid" CHAR(36) NOT NULL,
  "recv_date" date,
  "recv_time" time,
  "udp_dport" int,
  "udp_len" int,
  "udp_sum" char(10) DEFAULT NULL,
  "udp_sport" int DEFAULT NULL
);
CREATE INDEX index_id_defaultudp ON "wire".udppacket(id);
CREATE INDEX index_udp_dport_defaultudp ON "wire".udppacket(udp_dport);
CREATE INDEX index_udp_sport_defaultudp ON "wire".udppacket(udp_sport);
