  quit() {
  echo -n question | $ANYBAR
  exit
}

trap quit EXIT

ANYBAR="nc -4u -w0 localhost 1738"

while true; do
  if ping -c 60 -t 60 -o 185.164.136.111 &> /dev/null; then
    echo -n green | $ANYBAR
    sleep 60
  else
    echo -n exclamation | $ANYBAR
  fi
done
