sudo modprobe batman-adv

# Restart the interface configuration
sudo ip addr flush bat0
sudo ifconfig bat0 down
sudo ifconfig wlan0 down
sudo /etc/init.d/networking restart

sleep 2

sudo batctl if add wlan0
# Setting node as gateway
sudo batctl gw_mode server

# Port forwarding between wlan0 and Ethernet
sudo sysctl -w net.ipv4.ip_forward=1
ETH=`ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2a;getline}' | head -n 1`
sudo iptables -t nat -A POSTROUTING -o $ETH -j MASQUERADE
sudo iptables -A FORWARD -i $ETH -o bat0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i bat0 -o $ETH -j ACCEPT

# Activate the interface for B.A.T.M.A.N
sudo ifconfig wlan0 up
sudo ifconfig bat0 up

sudo service isc-dhcp-server start
sudo systemctl enable isc-dhcp-server
