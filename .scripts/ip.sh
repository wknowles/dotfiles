ipv4intr=$(ifconfig venet0:0 | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1)
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
