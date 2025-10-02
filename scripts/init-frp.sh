#!/bin/bash

echo "🛠️ 配置 FRP 服务..."

# 生成 FRP Token
if [ ! -f /config/frp/token ]; then
    openssl rand -hex 16 > /config/frp/token
fi
FRP_TOKEN=$(cat /config/frp/token)

# 创建 FRP 服务器配置
cat > /config/frp/frps.ini << EOF
[common]
bind_addr = 0.0.0.0
bind_port = $FRP_SERVER_PORT
bind_udp_port = $FRP_SERVER_PORT
kcp_bind_port = $FRP_SERVER_PORT

# 仪表盘配置
dashboard_addr = 0.0.0.0
dashboard_port = $FRP_ADMIN_PORT
dashboard_user = admin
dashboard_pwd = $FRP_ADMIN_PASSWORD

# 认证配置
token = $FRP_TOKEN
authentication_method = token

# 日志配置
log_file = /config/logs/frps.log
log_level = $LOG_LEVEL
log_max_days = 3

# 高级配置
max_pool_count = 50
max_ports_per_client = 0
tls_only = false
tcp_mux = true

# 子域名配置
subdomain_host = $DOMAIN
vhost_http_port = 80
vhost_https_port = 443

# 特权模式配置
privilege_mode = true
privilege_token = $FRP_TOKEN
EOF

# 创建 FRP 客户端示例配置
cat > /config/frp/frpc-example.ini << EOF
# FRP 客户端示例配置
[common]
server_addr = $DOMAIN
server_port = $FRP_SERVER_PORT
token = $FRP_TOKEN

# SSH 示例
[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000

# HTTP 示例
[web]
type = http
local_ip = 127.0.0.1
local_port = 80
custom_domains = www.$DOMAIN

# HTTPS 示例
[web-https]
type = https
local_ip = 127.0.0.1
local_port = 443
custom_domains = secure.$DOMAIN
EOF

echo "✅ FRP 配置完成"
echo "🔑 FRP Token: $FRP_TOKEN"
echo "📊 管理面板: http://$DOMAIN:$FRP_ADMIN_PORT (admin/$FRP_ADMIN_PASSWORD)"