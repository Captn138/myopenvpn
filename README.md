# myopenvpn
Collection of configuration files for a simple OpenVPN server over TCP/443 and UDP/1194 and client

⚠️ | Windows users: follow the tutorial at https://shebangthedolphins.net/fr/vpn_openvpn_windows_server.html (french). I added a newclient.ps1 script in this repo.
:---: | :---

## TODO
 - Unifier toute la configuration serveur et client en un seul fichier

## Prerequisites
### Install OpenVPN
Generally available with every package manager, else see [the doc](https://openvpn.net/).


### Install Easy-RSA
Generally bundled with OpenVPN, else see [the GitHub](https://github.com/OpenVPN/easy-rsa/releases/latest).

Copy or link the directory to `/etc/openvpn/easy-rsa`.

⚠️ | The paths I use here for Easy-RSA are the paths I used for my configuration. You can use other paths, but don't forget to change them in every file.
:---: | :---

### Install iptables
Generally available with every package manager.


### Download this repo
Place the `tcpserver.conf` and/or `udpserver.conf` in the `/etc/openvpn/server` directory. In my configuration, I run both server so I can have a fallback TCP/443 VPN when UDP/1194 is unavailable (mostly due to firewalls restrictions). Feel free to look at my scripts and modify them according to your needs.

place the `base.conf` and `newclient` in the `/etc/openvpn/client`directory.


## Generate server secrets
Go into your easy-rsa directory:
```sh
cd /etc/openvpn/easy-rsa
```
Initialize the PKI:
```sh
./easyrsa init-pki
```
Build your Certificate Authority (if you already have a CA, then just place it into `./pki/ca.crt`):
```sh
./easy-rsa build-ca nopass
```
Build yout server certificate and key (here `server` is the name you give to the server, in this configuration it will generate `server.crt` and `server.key`):
```sh
./easyrsa build-server-full server
```
Build your Diffie-Hellman parameters (here `dh` is the name you give to the file, in this configuration it will generate `dh.pem`):
```sh
./easyrsa gen-dh dh
```
OPTIONAL: Generate a TLS key (if you don't want to use a TLS key, don't forget to remove the `tls-auth`, `remote-cert-tls` and `key-direction`from every file):
```sh
openvpn --genkey --secret ta.key
```

## Generate the client files
Go into the client directory:
```sh
cd /etc/openvpn/client
```
Use my script to generate a client file (in this example, we'll call it `cli01`):
```sh
./newclient cli01
```
The generated `.ovpn` files will be stored in `/etc/openvpn/client/cli01/cli01-tcp.ovpn` and `/etc/openvpn/client/cli01/cli01-udp.ovpn`. These are the only files you need to copy to your client.


## Start the server
The command to start the server is the following:
```sh
/usr/sbin/openvpn /etc/openvpn/server/tcpserver.conf
```
and
```sh
/usr/sbin/openvpn /etc/openvpn/server/udpserver.conf
```
⚠️ | This command must be run as root
:---: | :---

I strongly recommand setting up a systemd service (with User=root and Wants=network-online.target).

## Enable traffic forwarding

### IP forwarding
To enable ip forwarding, run
```sh
sysctl -w net.ipv4.ip_forward=1
```
and to make it a permanent setting, run
```sh
sed -i 's/\#net.ipv4.ip_forward = 1/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
```

### NAT
To enable NAT for your virtual network, run
```sh
iptables -I FORWARD -i tun0 -s 10.8.0.0/24 -j ACCEPT
iptables -t nat -I POSTROUTING -s 10.8.0.0/24 -j MASQUERADE
```
where here tun0 is the virtual interface bound to my virtual network 10.8.0.0/24.

No need to restart the server after that.

To make these iptables rules persistent accross reboots, take a look at what your distro can use, such as iptables-persistent for example.
