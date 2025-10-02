#!/bin/bash

# 健康检查脚本
# 返回 0 表示健康，1 表示不健康

EXIT_CODE=0

echo "?? 开始健康检查..."

# 检查 Xray
if [ "$ENABLE_XRAY" = "true" ]; then
    if pgrep -x "xray" > /dev/null; then
        echo "? Xray 运行正常"
        
        # 检查端口监听
        if netstat -tln | grep -q ":$XRAY_REALITY_PORT "; then
            echo "? Xray Reality 端口 $XRAY_REALITY_PORT 监听正常"
        else
            echo "? Xray Reality 端口 $XRAY_REALITY_PORT 未监听"
            EXIT_CODE=1
        fi
        
        if netstat -tln | grep -q ":$XHTTP_REALITY_PORT "; then
            echo "? Xray HTTP Reality 端口 $XHTTP_REALITY_PORT 监听正常"
        else
            echo "? Xray HTTP Reality 端口 $XHTTP_REALITY_PORT 未监听"
            EXIT_CODE=1
        fi
    else
        echo "? Xray 进程未运行"
        EXIT_CODE=1
    fi
fi

# 检查 WireGuard
if [ "$ENABLE_WIREGUARD" = "true" ]; then
    if ip link show wg0 > /dev/null 2>&1; then
        echo "? WireGuard 接口 wg0 存在"
        
        # 检查端口监听
        if netstat -uln | grep -q ":$WIREGUARD_PORT "; then
            echo "? WireGuard 端口 $WIREGUARD_PORT 监听正常"
        else
            echo "? WireGuard 端口 $WIREGUARD_PORT 未监听"
            EXIT_CODE=1
        fi
    else
        echo "? WireGuard 接口不存在"
        EXIT_CODE=1
    fi
fi

# 检查 OpenVPN
if [ "$ENABLE_OPENVPN" = "true" ]; then
    if pgrep -x "openvpn" > /dev/null; then
        echo "? OpenVPN 运行正常"
        
        # 检查端口监听
        if netstat -uln | grep -q ":$OPENVPN_PORT "; then
            echo "? OpenVPN 端口 $OPENVPN_PORT 监听正常"
        else
            echo "? OpenVPN 端口 $OPENVPN_PORT 未监听"
            EXIT_CODE=1
        fi
    else
        echo "? OpenVPN 进程未运行"
        EXIT_CODE=1
    fi
fi

# 检查 FRP
if [ "$ENABLE_FRP" = "true" ]; then
    if pgrep -x "frps" > /dev/null; then
        echo "? FRP 运行正常"
        
        # 检查端口监听
        if netstat -tln | grep -q ":$FRP_SERVER_PORT "; then
            echo "? FRP 服务器端口 $FRP_SERVER_PORT 监听正常"
        else
            echo "? FRP 服务器端口 $FRP_SERVER_PORT 未监听"
            EXIT_CODE=1
        fi
        
        if netstat -tln | grep -q ":$FRP_ADMIN_PORT "; then
            echo "? FRP 管理端口 $FRP_ADMIN_PORT 监听正常"
        else
            echo "? FRP 管理端口 $FRP_ADMIN_PORT 未监听"
            EXIT_CODE=1
        fi
    else
        echo "? FRP 进程未运行"
        EXIT_CODE=1
    fi
fi

# 检查 RustDesk
if [ "$ENABLE_RUSTDESK" = "true" ]; then
    if pgrep -x "rustdesk-server" > /dev/null; then
        echo "? RustDesk 运行正常"
        
        # 检查端口监听
        for port in 21115 21116 21117 21118 21119; do
            if netstat -tln | grep -q ":$port "; then
                echo "? RustDesk 端口 $port 监听正常"
            else
                echo "? RustDesk 端口 $port 未监听"
                EXIT_CODE=1
            fi
        done
    else
        echo "? RustDesk 进程未运行"
        EXIT_CODE=1
    fi
fi

# 检查 WebUI
if [ "$ENABLE_WEBUI" = "true" ]; then
    if pgrep -f "python3 /webui/app.py" > /dev/null; then
        echo "? WebUI 运行正常"
        
        # 检查端口监听
        if netstat -tln | grep -q ":8080 "; then
            echo "? WebUI 端口 8080 监听正常"
        else
            echo "? WebUI 端口 8080 未监听"
            EXIT_CODE=1
        fi
    else
        echo "? WebUI 进程未运行"
        EXIT_CODE=1
    fi
fi

# 检查磁盘空间
DISK_USAGE=$(df /config | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "??  磁盘使用率过高: $DISK_USAGE%"
    EXIT_CODE=1
else
    echo "? 磁盘空间正常: $DISK_USAGE%"
fi

# 检查内存使用
MEM_USAGE=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
echo "?? 内存使用率: $MEM_USAGE%"

if [ $EXIT_CODE -eq 0 ]; then
    echo "?? 所有服务健康检查通过"
else
    echo "? 部分服务存在问题，请检查日志"
fi

exit $EXIT_CODE