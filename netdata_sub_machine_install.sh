#!/bin/bash

# 读取主服务器地址和端口
read -p "Enter the master Netdata server address (e.g., 192.168.1.100): " MASTER_HOST
read -p "Enter the master Netdata server port (default is 19999): " MASTER_PORT
MASTER_PORT=${MASTER_PORT:-19999}

# 生成随机API密钥
API_KEY=$(uuidgen)

# 生成唯一的机器标识符(UUID)
MACHINE_UUID=$(uuidgen)

# 机器名称（使用主机名或自定义）
MACHINE_NAME=$(hostname)

# 安装 Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --non-interactive --disable-telemetry

# 配置从服务器向主服务器的 stream
cat <<EOF | sudo tee /etc/netdata/stream.conf
[stream]
    enabled = yes
    destination = $MASTER_HOST:$MASTER_PORT
    api key = $API_KEY
    timeout seconds = 60
    default port = 19999
    buffer size bytes = 1048576
    reconnect delay seconds = 5
    initial clock resync iterations = 60
    hostname = $MACHINE_NAME
    machine guid = $MACHINE_UUID
EOF

# 关闭Netdata的Web界面
sudo tee /etc/netdata/netdata.conf > /dev/null <<EOT
[web]
    mode = none
EOT

# 重启Netdata服务应用配置
sudo systemctl restart netdata

# 输出必要的配置信息
echo "Configure your master Netdata server by adding this to the stream.conf:"
echo "[${MACHINE_NAME}]"
echo "    enabled = yes"
echo "    api key = $API_KEY"
echo "    default port = 19999"
echo "    buffer size bytes = 1048576"
echo "    reconnect delay seconds = 5"
echo "    hostname = ${MACHINE_NAME}"
echo "    machine guid = ${MACHINE_UUID}"
