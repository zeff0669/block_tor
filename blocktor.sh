#!/bin/bash
apt install ipset -y

URL="https://www.dan.me.uk/torlist/"
touch /root/full.tor

# Baixe a lista de IPs da rede Tor e filtre linhas comentadas e com ":"
wget -q -O /root/full.tor "$URL"
sed -e '/^#/d' -e '/:/d' /root/full.tor 

# Cria o conjunto de IPs tor-nodes
ipset create tor-nodes iphash

# Adiciona IPs ao conjunto e bloqueia no iptables
while IFS= read -r IP; do
    ipset -q -A tor-nodes $IP
done < /root/full.tor

# Aplica a regra iptables para bloquear acesso desses IPs
iptables -A INPUT -m set --match-set tor-nodes src -j DROP
