# Mettre toutes les VMs sous le réseau VMnet8 (NAT) et retirer le DHCP automatique dans "Virtual Networking Editor".

# nano /etc/network/interfaces
auto lo ens33
iface lo inet loopback

auto ens33
iface ens33 inet static
address 192.168.10.5
netmask 255.255.255.0

dns-nameservers 192.168.10.4 192.168.10.5
dns-search carnofluxe.domain

# nano /etc/bind/named.conf.local
zone "carnofluxe.domain" {
                type master;
                allow-transfer { 192.168.10.4;};
                file "/etc/bind/db.carnofluxe.domain";
        };

zone "10.168.192.in-addr.arpa" {
                type master;
                allow-transfer { 192.168.10.4;};
                file "/etc/bind/db.carnofluxe.domain.rev";
        };

# nano /etc/bind/db.carnofluxe.domain
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA    ns1.carnofluxe.domain. admin.ns1.carnofluxe.domain. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

@               IN      NS      ns1.carnofluxe.domain.
@               IN      NS      ns2.carnofluxe.domain.
ns1             IN      A       192.168.10.5
ns2             IN      A       192.168.10.4

# nano /etc/bind/db.carnofluxe.domain.rev
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA    ns1.carnofluxe.domain. admin.ns1.carnofluxe.domain. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

@               IN      NS      ns1.carnofluxe.domain.
@               IN      NS      ns2.carnofluxe.domain.
5               IN      PTR     ns1.carnofluxe.domain.
4               IN      PTR     ns2.carnofluxe.domain.

# SUR LE DNS SLAVE:

# nano /etc/network/interfaces
auto lo ens33
iface lo inet loopback

auto ens33
iface ens33 inet static
address 192.168.10.4
netmask 255.255.255.0

dns-nameservers 192.168.10.4 192.168.10.5
dns-search carnofluxe.domain

# nano /etc/bind/named.conf.local
zone "carnofluxe.domain" {
                type slave;
                masters { 192.168.10.5;};
                file "/var/cache/bind/db.carnofluxe.domain";
        };

zone "10.168.192.in-addr.arpa" {
                type slave;
                masters { 192.168.10.5;};
                file "/var/cache/bind/db.carnofluxe.domain.rev";
        };

# Redémarragemarage du DNS:
systemctl restart bind9

# Arrêt du DNS:
systemctl stop bind9

# Vérifier que le DNS fonction:
systemctl status bind9
