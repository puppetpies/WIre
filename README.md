# WIre

A packet analyzer written purely in Crystal

![Wire-tcpdata](https://raw.githubusercontent.com/puppetpies/WIre/dbbackends/demos/Wire-tcpdata.png)

## Installation

First you will need the Crystal Language from http://crystal-lang.org

You will need to have are shards to be installed however you should just be able to download the binary if on x86_64
from the bin/ directory.


## Database support

To make wire work with a database all you need is a config.json in your .Wire folder

config.json - Example

```json
{
  "driver":"mysql",
  "host":"localhost",
  "username":"wire",
  "password":"changeme",
  "port":3306,
  "schema":"threatmonitor",
  "tbl_ippacket":"ippacket",
  "tbl_tcppacket":"tcppacket",
  "tbl_udppacket":"udppacket",
  "tbl_http_traffic_json":"http_traffic_json",
  "tbl_http_traffic_ua":"http_traffic_ua"
}
```

# Schemas

Please see the sql directory.

MonetDB, MySQL & Postgres are provided so far.

# Build instructions

```
shards update
make
make install
```

## Usage as root
```
wire -i eth0 -f 'tcp port 8080'


## Development

TODO: Add MonetDB support
TODO: Add MySQL support
TODO: JSON output format

## Contributing

1. Fork it ( https://github.com/puppetpies/WIre/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[WIre]](https://github.com/puppetpies/WIre) Bri in The Sky - creator, maintainer
