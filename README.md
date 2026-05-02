[![Gem Version](https://badge.fury.io/rb/radd.svg)](http://badge.fury.io/rb/radd)

# radd

Minimal dynamic DNS service


## Installation

```
gem install radd
```

## Configuration

```yaml
# radd.yml
ip: 10.1.2.3
http: 127.0.0.1:3000
dns: 0.0.0.0:53
domain: example.com
mname: ns.example.com
rname: hostmaster.example.com
db: radd.sqlite3
```

## Usage

```
radd COMMAND [--config FILE]
```

You must specify one of the following commands:

```
setup        Create the database
add          Add new record
delete       Delete record
list         List available records
start        Run the server
```
