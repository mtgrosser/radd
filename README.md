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
rname: hostmaster@example.com
db: radd.sqlite3
```

#### ip
The nameserver's public IP

#### http
`ÌP:port` the HTTP server should listen on, default: `127.0.0.1:3003`

#### dns
`IP:port` the DNS server should listen on, default: `0.0.0.0:53`

#### domain
Your domain where subdomains are the dynamic hostnames

#### mname
Hostname of the nameserver

#### rname
Email address of the nameserver contact, default: `hostmaster@DOMAIN`

#### ttl
TTL of the dynamic A records

#### db
Path to the zone db, default: `radd.sqlite3`


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

## Deployment

The HTTP server should be exposed via a reverse proxy like Nginx, which provides SSL encryption.

The DNS ports (53/udp, 53/tcp) can be exposed directly when using `systemd` 


## Updating a record via HTTP

In order to update a record, an authorized request must be made to the `/update` endpoint.

The hostname is determined by the HTTP user name.
The IP address can be supplied by the `ip` parameter, otherwise, the remote IP of the request will be used:

```
# use remote IP
https://dyndns.example.com/update
```

```
https://dyndns.example.com/update?ip=10.20.30.40
```
