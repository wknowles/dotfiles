# LowEndSpirit "What's my IP?"
# 07/10/13
#By CSa

ipv6addr=$(ip addr show dev venet0 | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d')
ipv4intr=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
nodeaddr=$(wget -qO- ipecho.net/plain)
ports=${ipv4intr#*.*.*.}

echo Your external IPv6 address is:
echo $ipv6addr
echo
echo Your internal IPv4 address is:
echo $ipv4intr
echo
echo Your external IPv4 address is:
echo $nodeaddr
echo
echo Your LowEndSprit is reachable on these ports:
echo [$nodeaddr]:$ports\01 - $ports\20
