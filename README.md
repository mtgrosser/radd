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
origin: domains.example.com
ip: 10.1.2.3
mname: ns.example.com
rname: hostmaster.example.com
ttl: 300
http: 127.0.0.1:3000
dns: 0.0.0.0:53
db: radd.sqlite3
```

#### origin
Your domain where subdomains are the dynamic hostnames

#### ip
The nameserver's public IP

#### mname
Hostname of the nameserver, must not be a subdomain of `origin`

#### rname
Email address of the nameserver contact, default: `hostmaster.ORIGIN`

#### ttl
TTL of the dynamic A records, default: `300`

#### http
`ÌP:port` the HTTP server should listen on, default: `127.0.0.1:3003`

#### dns
`IP:port` the DNS server should listen on, default: `0.0.0.0:53`

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

### Webserver
The HTTP server should be exposed via a reverse proxy like Nginx, which provides SSL encryption.

### Nameserver
The DNS ports (53/udp, 53/tcp) can be exposed directly when using `systemd` to run `radd`.
The provided unit file (`radd.service`) includes the necessary directives which enable an unprivileged user
to access port 53.

### DNS configuration
You need to set your dynamic DNS server as the authoritative nameserver for the used (sub)domain:

```
NS  ddns.example.com   ns.example.com.   86400
```

## Updating a record via HTTP

In order to update a record, an authorized request must be made to the `/update` endpoint.

The hostname is determined by the HTTP user name.
The IP address can be supplied by the `ip` parameter, otherwise, the remote IP of the request will be used:

```
# use remote IP
curl --user "hostname:password" https://ddns.example.com/update
```

```
# use given IP
curl --user "hostname:password" https://ddns.example.com/update?ip=10.20.30.40
```
