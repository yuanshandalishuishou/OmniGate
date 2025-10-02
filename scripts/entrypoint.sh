#!/bin/bash
set -e

echo "=== 🌟 OmniGate 全能网关初始化开始 ==="
echo "=== Omnipotent Network Gateway Starting ==="

# 创建配置目录
mkdir -p /config/{cert,xray,wireguard,openvpn,frp,rustdesk,logs}

# 检查默认密码安全性
check_default_passwords() {
    local changed=false
    if [ "$WIREGUARD_ADMIN_PASSWORD" = "liyongjie" ]; then
        echo "⚠️  警告: WireGuard 管理密码为默认值，建议修改!"
        changed=true
    fi
    if [ "$FRP_ADMIN_PASSWORD" = "liyongjie" ]; then
        echo "⚠️  警告: FRP 管理密码为默认值，建议修改!"
        changed=true
    fi
    if [ "$RUSTDESK_KEY" = "liyongjie" ]; then
        echo "⚠️  警告: RustDesk 密钥为默认值，建议修改!"
        changed=true
    fi
    if [ "$changed" = true ]; then
        echo "💡 提示: 请通过环境变量设置安全的密码"
        echo "💡 Tip: Set secure passwords via environment variables"
    fi
}

# 生成 Reality 密钥对
generate_reality_keys() {
    if [ ! -f /config/xray/reality_private.key ]; then
        echo "🔑 生成 Reality 密钥对..."
        /usr/local/bin/xray x25519 > /config/xray/reality_keys.txt
        cat /config/xray/reality_keys.txt | grep Private | awk '{print $3}' > /config/xray/reality_private.key
        cat /config/xray/reality_keys.txt | grep Public | awk '{print $3}' > /config/xray/reality_public.key
        echo "✅ Reality 密钥对生成完成"
    fi
}

# 初始化各服务配置
init_services() {
    echo "🛠️ 初始化服务配置..."
    
    # 证书管理
    /scripts/init-certs.sh
    
    # 各服务配置
    [ "$ENABLE_XRAY" = "true" ] && /scripts/init-xray.sh
    [ "$ENABLE_WIREGUARD" = "true" ] && /scripts/init-wireguard.sh
    [ "$ENABLE_OPENVPN" = "true" ] && /scripts/init-openvpn.sh
    [ "$ENABLE_FRP" = "true" ] && /scripts/init-frp.sh
    [ "$ENABLE_RUSTDESK" = "true" ] && /scripts/init-rustdesk.sh
    
    echo "✅ 服务配置初始化完成"
}

# 显示配置信息
show_config_info() {
    echo ""
    echo "=== 🎯 OmniGate 服务配置信息 ==="
    echo "=== 🎯 OmniGate Service Configuration ==="
    
    if [ "$ENABLE_XRAY" = "true" ]; then
        echo "📡 Xray Reality:"
        echo "   端口: $XRAY_REALITY_PORT (Reality)"
        echo "   端口: $XHTTP_REALITY_PORT (HTTP Reality)"
        echo "   公钥: $(cat /config/xray/reality_public.key 2>/dev/null || echo '未生成')"
    fi
    
    if [ "$ENABLE_WIREGUARD" = "true" ]; then
        echo "🔐 WireGuard:"
        echo "   服务端口: $WIREGUARD_PORT/udp"
        echo "   管理界面: http://$DOMAIN:$WIREGUARD_ADMIN_PORT"
        echo "   管理密码: $WIREGUARD_ADMIN_PASSWORD"
        echo "   子网: $WIREGUARD_SUBNET"
    fi
    
    if [ "$ENABLE_OPENVPN" = "true" ]; then
        echo "🔒 OpenVPN:"
        echo "   服务端口: $OPENVPN_PORT/udp"
        echo "   用户名: $OPENVPN_USERNAME"
        echo "   子网: $OPENVPN_SUBNET"
    fi
    
    if [ "$ENABLE_FRP" = "true" ]; then
        echo "🌐 FRP Server:"
        echo "   服务端口: $FRP_SERVER_PORT"
        echo "   管理界面: http://$DOMAIN:$FRP_ADMIN_PORT"
        echo "   管理密码: $FRP_ADMIN_PASSWORD"
    fi
    
    if [ "$ENABLE_RUSTDESK" = "true" ]; then
        echo "🖥️  RustDesk:"
        echo "   端口: 21115-21119/tcp, 21116/udp"
        echo "   密钥: $RUSTDESK_KEY"
    fi
    
    if [ "$ENABLE_WEBUI" = "true" ]; then
        echo "🖥️  OmniGate Web管理界面:"
        echo "   地址: http://$DOMAIN:8080"
    fi
    
    echo ""
    echo "⚠️  注意: 请确保上述端口已在防火墙中开放"
    echo "📁 配置文件持久化在: /config"
    echo ""
    echo "🚀 OmniGate 初始化完成，服务启动中..."
    echo "🚀 OmniGate initialization complete, starting services..."
}

# 主执行流程
main() {
    check_default_passwords
    generate_reality_keys
    init_services
    show_config_info
    
    echo "🚀 启动 OmniGate 服务管理器..."
    exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
}

# 捕获信号，优雅退出
trap 'echo "正在停止 OmniGate 服务..."; kill -TERM $(jobs -p); wait' SIGTERM SIGINT

main "$@"