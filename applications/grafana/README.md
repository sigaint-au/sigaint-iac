# Grafana

LDAP configuration is done via an `ExternalSecret`

```toml
[[servers]]
host = "ipa-1.syd.sigaint.au ipa-2.syd.sigaint.au ipa-3.syd.sigaint.au"
port = 636
use_ssl = true
start_tls = false

ssl_skip_verify = false
root_ca_cert = " /opt/bitnami/grafana/conf/ldap/ca.crt"

bind_dn = "uid=svc-ldap-bind,cn=users,cn=accounts,dc=sigaint,dc=au"
bind_password = "password"
timeout = 10
search_filter = "(uid=%s)"

search_base_dns = ["dc=sigaint,dc=au"]
group_search_base_dns = ["cn=groups,cn=accounts,dc=sigaint,dc=au"]

# Specify names of the ldap attributes your ldap uses
[servers.attributes]
name = "givenName"
surname = "sn"
username = "uid"
member_of = "memberOf"
email =  "mail"
```