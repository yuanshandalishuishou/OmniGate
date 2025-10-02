#!/bin/bash

echo "🛠️ 配置 Xray 服务..."

# 生成 UUID
if [ ! -f /config/xray/uuid ]; then
    uuidgen > /config/xray/uuid
fi
XRAY_UUID=$(cat /config/xray/uuid)
REALITY_PUBLIC_KEY=$(cat /config/xray/reality_public.key)

# 创建 Xray 配置文件
cat > /config/xray/config.json << EOF
{
    "log": {
        "loglevel": "$LOG_LEVEL",
        "access": "/config/logs/xray-access.log",
        "error": "/config/logs/xray-error.log"
    },
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "rules": []
    },
    "inbounds": [
        {
            "port": $XRAY_REALITY_PORT,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$XRAY_UUID",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": false,
                    "dest": "www.google.com:443",
                    "xver": 0,
                    "serverNames": [
                        "www.google.com"
                    ],
                    "privateKey": "$(cat /config/xray/reality_private.key)",
                    "shortIds": [
                        "",
                        "ffffffff"
                    ]
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        },
        {
            "port": $XHTTP_REALITY_PORT,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$XRAY_UUID"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": false,
                    "dest": "www.apple.com:443",
                    "xver": 0,
                    "serverNames": [
                        "www.apple.com"
                    ],
                    "privateKey": "$(cat /config/xray/reality_private.key)",
                    "shortIds": [
                        "",
                        "eeeeeeee"
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ]
}
EOF

echo "✅ Xray 配置完成"