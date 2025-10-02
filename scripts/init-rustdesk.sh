#!/bin/bash

echo "??? 配置 RustDesk 服务..."

# 创建 RustDesk 配置目录
mkdir -p /config/rustdesk

# 生成密钥对（如果不存在）
if [ ! -f /config/rustdesk/id_ed25519 ]; then
    echo "?? 生成 RustDesk 密钥对..."
    # 使用 OpenSSL 生成 Ed25519 密钥对
    openssl genpkey -algorithm ED25519 -out /config/rustdesk/id_ed25519
    openssl pkey -in /config/rustdesk/id_ed25519 -pubout -out /config/rustdesk/id_ed25519.pub
fi

# 创建启动脚本
cat > /config/rustdesk/run.sh << 'EOF'
#!/bin/bash

# RustDesk 服务器启动脚本

export KEY="$RUSTDESK_KEY"
export RELAY1=21116
export RELAY2=21117
export API=21115
export WEB=8081

# 启动 RustDesk 服务器
exec /usr/local/bin/rustdesk-server \
    --key "$KEY" \
    --relay-server "0.0.0.0:$RELAY1" \
    --relay-server-2 "0.0.0.0:$RELAY2" \
    --api-server "0.0.0.0:$API" \
    --web-server "0.0.0.0:$WEB"
EOF

chmod +x /config/rustdesk/run.sh

# 创建 RustDesk 客户端连接信息文件
cat > /config/rustdesk/client-info.txt << EOF
=== RustDesk 客户端连接信息 ===

服务器地址: $DOMAIN
ID 服务器: $DOMAIN:21116
中继服务器: $DOMAIN:21117
API 服务器: $DOMAIN:21115
密钥: $RUSTDESK_KEY

=== 客户端配置示例 ===
在 RustDesk 客户端中设置:
- ID服务器: $DOMAIN:21116
- 中继服务器: $DOMAIN:21117  
- API服务器: $DOMAIN:21115
- 密钥: $RUSTDESK_KEY

=== 注意 ===
请确保以下端口已开放:
- 21115/tcp (API)
- 21116/tcp (中继1)
- 21116/udp (中继1)
- 21117/tcp (中继2)
- 21118/tcp (文件传输)
- 21119/tcp (网络穿透)
EOF

echo "? RustDesk 配置完成"
echo "?? 公钥: $(cat /config/rustdesk/id_ed25519.pub 2>/dev/null || echo '未生成')"