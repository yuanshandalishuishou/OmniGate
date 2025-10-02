#!/bin/bash

# �������ű�
# ���� 0 ��ʾ������1 ��ʾ������

EXIT_CODE=0

echo "?? ��ʼ�������..."

# ��� Xray
if [ "$ENABLE_XRAY" = "true" ]; then
    if pgrep -x "xray" > /dev/null; then
        echo "? Xray ��������"
        
        # ���˿ڼ���
        if netstat -tln | grep -q ":$XRAY_REALITY_PORT "; then
            echo "? Xray Reality �˿� $XRAY_REALITY_PORT ��������"
        else
            echo "? Xray Reality �˿� $XRAY_REALITY_PORT δ����"
            EXIT_CODE=1
        fi
        
        if netstat -tln | grep -q ":$XHTTP_REALITY_PORT "; then
            echo "? Xray HTTP Reality �˿� $XHTTP_REALITY_PORT ��������"
        else
            echo "? Xray HTTP Reality �˿� $XHTTP_REALITY_PORT δ����"
            EXIT_CODE=1
        fi
    else
        echo "? Xray ����δ����"
        EXIT_CODE=1
    fi
fi

# ��� WireGuard
if [ "$ENABLE_WIREGUARD" = "true" ]; then
    if ip link show wg0 > /dev/null 2>&1; then
        echo "? WireGuard �ӿ� wg0 ����"
        
        # ���˿ڼ���
        if netstat -uln | grep -q ":$WIREGUARD_PORT "; then
            echo "? WireGuard �˿� $WIREGUARD_PORT ��������"
        else
            echo "? WireGuard �˿� $WIREGUARD_PORT δ����"
            EXIT_CODE=1
        fi
    else
        echo "? WireGuard �ӿڲ�����"
        EXIT_CODE=1
    fi
fi

# ��� OpenVPN
if [ "$ENABLE_OPENVPN" = "true" ]; then
    if pgrep -x "openvpn" > /dev/null; then
        echo "? OpenVPN ��������"
        
        # ���˿ڼ���
        if netstat -uln | grep -q ":$OPENVPN_PORT "; then
            echo "? OpenVPN �˿� $OPENVPN_PORT ��������"
        else
            echo "? OpenVPN �˿� $OPENVPN_PORT δ����"
            EXIT_CODE=1
        fi
    else
        echo "? OpenVPN ����δ����"
        EXIT_CODE=1
    fi
fi

# ��� FRP
if [ "$ENABLE_FRP" = "true" ]; then
    if pgrep -x "frps" > /dev/null; then
        echo "? FRP ��������"
        
        # ���˿ڼ���
        if netstat -tln | grep -q ":$FRP_SERVER_PORT "; then
            echo "? FRP �������˿� $FRP_SERVER_PORT ��������"
        else
            echo "? FRP �������˿� $FRP_SERVER_PORT δ����"
            EXIT_CODE=1
        fi
        
        if netstat -tln | grep -q ":$FRP_ADMIN_PORT "; then
            echo "? FRP ����˿� $FRP_ADMIN_PORT ��������"
        else
            echo "? FRP ����˿� $FRP_ADMIN_PORT δ����"
            EXIT_CODE=1
        fi
    else
        echo "? FRP ����δ����"
        EXIT_CODE=1
    fi
fi

# ��� RustDesk
if [ "$ENABLE_RUSTDESK" = "true" ]; then
    if pgrep -x "rustdesk-server" > /dev/null; then
        echo "? RustDesk ��������"
        
        # ���˿ڼ���
        for port in 21115 21116 21117 21118 21119; do
            if netstat -tln | grep -q ":$port "; then
                echo "? RustDesk �˿� $port ��������"
            else
                echo "? RustDesk �˿� $port δ����"
                EXIT_CODE=1
            fi
        done
    else
        echo "? RustDesk ����δ����"
        EXIT_CODE=1
    fi
fi

# ��� WebUI
if [ "$ENABLE_WEBUI" = "true" ]; then
    if pgrep -f "python3 /webui/app.py" > /dev/null; then
        echo "? WebUI ��������"
        
        # ���˿ڼ���
        if netstat -tln | grep -q ":8080 "; then
            echo "? WebUI �˿� 8080 ��������"
        else
            echo "? WebUI �˿� 8080 δ����"
            EXIT_CODE=1
        fi
    else
        echo "? WebUI ����δ����"
        EXIT_CODE=1
    fi
fi

# �����̿ռ�
DISK_USAGE=$(df /config | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "??  ����ʹ���ʹ���: $DISK_USAGE%"
    EXIT_CODE=1
else
    echo "? ���̿ռ�����: $DISK_USAGE%"
fi

# ����ڴ�ʹ��
MEM_USAGE=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
echo "?? �ڴ�ʹ����: $MEM_USAGE%"

if [ $EXIT_CODE -eq 0 ]; then
    echo "?? ���з��񽡿����ͨ��"
else
    echo "? ���ַ���������⣬������־"
fi

exit $EXIT_CODE