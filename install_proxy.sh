wget --no-check-certificate https://raw.github.com/SnoyIatk/3proxy/master/3proxyinstall.sh

chmod +x 3proxyinstall.sh

./3proxyinstall.sh

read -p "Enter proxy username: " username;

read -p "Enter proxy password: " password;

sed -i "s|user:CL:password|$username:CL:$password|g" /etc/3proxy/.proxyauth

sudo systemctl daemon-reload
sudo systemctl enable 3proxy
sudo systemctl start 3proxy

