#!/bin/bash

echo "🛠️ 配置 OpenVPN 服务..."

# 创建配置目录
mkdir -p /config/openvpn/ccd

# 生成 PKI (证书机构)
if [ ! -f /config/openvpn/pki/ca.crt ]; then
    echo "🔐 生成 OpenVPN PKI..."
    mkdir -p /config/openvpn/pki
    
    # 生成 CA
    openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=AllInOne/CN=AllInOne CA" \
        -keyout /config/openvpn/pki/ca.key \
        -out /config/openvpn/pki/ca.crt

    # 生成服务器证书
    openssl req -new -newkey rsa:2048 -nodes \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=AllInOne/CN=OpenVPN Server" \
        -keyout /config/openvpn/pki/server.key \
        -out /config/openvpn/pki/server.csr

    openssl x509 -req -in /config/openvpn/pki/server.csr \
        -CA /config/openvpn/pki/ca.crt -CAkey /config/openvpn/pki/ca.key -CAcreateserial \
        -out /config/openvpn/pki/server.crt -days 3650

    # 生成 Diffie-Hellman 参数
    openssl dhparam -out /config/openvpn/pki/dh.pem 2048

    # 生成 TLS 认证密钥
    openvpn --genkey --secret /config/openvpn/pki/ta.key
fi

# 创建 OpenVPN 服务器配置文件
cat > /config/openvpn/server.conf << EOF
port $OPENVPN_PORT
proto udp
dev tun
ca /config/openvpn/pki/ca.crt
cert /config/openvpn/pki/server.crt
key /config/openvpn/pki/server.key
dh /config/openvpn/pki/dh.pem
server $(echo $OPENVPN_SUBNET | sed 's|0/24|0 255.255.255.0|')
ifconfig-pool-persist /config/openvpn/ipp.txt
client-config-dir /config/openvpn/ccd
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 208.67.222.222"
keepalive 10 120
tls-auth /config/openvpn/pki/ta.key 0
cipher AES-256-CBC
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status /config/logs/openvpn-status.log
log /config/logs/openvpn.log
verb 3
explicit-exit-notify 1
max-clients 100
client-to-client
duplicate-cn
EOF

# 创建默认客户端配置
if [ ! -f /config/openvpn/pki/client.crt ]; then
    echo "📄 生成客户端证书..."
    openssl req -new -newkey rsa:2048 -nodes \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=AllInOne/CN=OpenVPN Client" \
        -keyout /config/openvpn/pki/client.key \
        -out /config/openvpn/pki/client.csr

    openssl x509 -req -in /config/openvpn/pki/client.csr \
        -CA /config/openvpn/pki/ca.crt -CAkey /config/openvpn/pki/ca.key -CAcreateserial \
        -out /config/openvpn/pki/client.crt -days 3650
fi

# 创建客户端配置文件
cat > /config/openvpn/client.ovpn << EOF
client
dev tun
proto udp
remote $DOMAIN $OPENVPN_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
verb 3
key-direction 1

<ca>
$(cat /config/openvpn/pki/ca.crt)
</ca>

<cert>
$(cat /config/openvpn/pki/client.crt)
</cert>

<key>
$(cat /config/openvpn/pki/client.key)
</key>

<tls-auth>
$(cat /config/openvpn/pki/ta.key)
</tls-auth>
EOF

# 创建用户认证脚本
cat > /config/openvpn/auth.sh << 'EOF'
#!/bin/bash
# OpenVPN 用户认证脚本

USERNAME="$1"
PASSWORD="$2"

# 简单的用户名密码验证
if [ "$USERNAME" = "$OPENVPN_USERNAME" ] && [ "$PASSWORD" = "$OPENVPN_PASSWORD" ]; then
    exit 0
else
    exit 1
fi
EOF

chmod +x /config/openvpn/auth.sh

# 在配置文件中添加用户认证
echo "script-security 2" >> /config/openvpn/server.conf
echo "auth-user-pass-verify /config/openvpn/auth.sh via-file" >> /config/openvpn/server.conf

echo "✅ OpenVPN 配置完成"
echo "📁 客户端配置文件: /config/openvpn/client.ovpn"