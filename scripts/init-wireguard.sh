#!/bin/bash

echo "??? ���� WireGuard ����..."

# ���ɷ�������Կ��
if [ ! -f /config/wireguard/server_private.key ]; then
    wg genkey | tee /config/wireguard/server_private.key | wg pubkey > /config/wireguard/server_public.key
    chmod 600 /config/wireguard/server_private.key
fi

SERVER_PRIVATE_KEY=$(cat /config/wireguard/server_private.key)
SERVER_PUBLIC_KEY=$(cat /config/wireguard/server_public.key)

# ���� WireGuard �����ļ�
cat > /config/wireguard/wg0.conf << EOF
[Interface]
PrivateKey = $SERVER_PRIVATE_KEY
Address = $(echo $WIREGUARD_SUBNET | sed 's|0/24|1/24|')
ListenPort = $WIREGUARD_PORT
SaveConfig = true
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Ĭ�Ͽͻ�������
[Peer]
PublicKey = $(wg genkey | tee /config/wireguard/client_private.key | wg pubkey > /config/wireguard/client_public.key && cat /config/wireguard/client_public.key)
AllowedIPs = $(echo $WIREGUARD_SUBNET | sed 's|0/24|2/32|')
EOF

# �����ͻ��������ļ�
cat > /config/wireguard/client.conf << EOF
[Interface]
PrivateKey = $(cat /config/wireguard/client_private.key)
Address = $(echo $WIREGUARD_SUBNET | sed 's|0/24|2/24|')
DNS = 8.8.8.8, 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $DOMAIN:$WIREGUARD_PORT
AllowedIPs = 0.0.0.0/0, ::/0
EOF

echo "? WireGuard �������"
echo "?? �ͻ��������ѱ��浽: /config/wireguard/client.conf"