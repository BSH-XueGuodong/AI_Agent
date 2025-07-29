# Socat Commands
- socat TCP-LISTEN:15800,reuseaddr,fork TCP:10.10.99.98:58000
- nohup socat TCP-LISTEN:15800,reuseaddr,fork TCP:10.10.99.98:58000 > /tmp/socat.log 2>&1 &