# WIre

A packet analyzer written purely in Crystal

![Wire](https://raw.githubusercontent.com/puppetpies/WIre/b62dfa0975a53d2465de788db09e660d11917e52/demos/Wire.png)

## Installation

First you will need the Crystal Language from http://crystal-lang.org

You will need to have are shards to be installed however you should just be able to download the binary if on x86_64
from the bin/ directory.


```
shards update
make
```

## Usage
```
bin/wire -i eth0 -f 'tcp port 8080'


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
