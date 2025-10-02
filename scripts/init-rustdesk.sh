#!/bin/bash

echo "??? ���� RustDesk ����..."

# ���� RustDesk ����Ŀ¼
mkdir -p /config/rustdesk

# ������Կ�ԣ���������ڣ�
if [ ! -f /config/rustdesk/id_ed25519 ]; then
    echo "?? ���� RustDesk ��Կ��..."
    # ʹ�� OpenSSL ���� Ed25519 ��Կ��
    openssl genpkey -algorithm ED25519 -out /config/rustdesk/id_ed25519
    openssl pkey -in /config/rustdesk/id_ed25519 -pubout -out /config/rustdesk/id_ed25519.pub
fi

# ���������ű�
cat > /config/rustdesk/run.sh << 'EOF'
#!/bin/bash

# RustDesk �����������ű�

export KEY="$RUSTDESK_KEY"
export RELAY1=21116
export RELAY2=21117
export API=21115
export WEB=8081

# ���� RustDesk ������
exec /usr/local/bin/rustdesk-server \
    --key "$KEY" \
    --relay-server "0.0.0.0:$RELAY1" \
    --relay-server-2 "0.0.0.0:$RELAY2" \
    --api-server "0.0.0.0:$API" \
    --web-server "0.0.0.0:$WEB"
EOF

chmod +x /config/rustdesk/run.sh

# ���� RustDesk �ͻ���������Ϣ�ļ�
cat > /config/rustdesk/client-info.txt << EOF
=== RustDesk �ͻ���������Ϣ ===

��������ַ: $DOMAIN
ID ������: $DOMAIN:21116
�м̷�����: $DOMAIN:21117
API ������: $DOMAIN:21115
��Կ: $RUSTDESK_KEY

=== �ͻ�������ʾ�� ===
�� RustDesk �ͻ���������:
- ID������: $DOMAIN:21116
- �м̷�����: $DOMAIN:21117  
- API������: $DOMAIN:21115
- ��Կ: $RUSTDESK_KEY

=== ע�� ===
��ȷ�����¶˿��ѿ���:
- 21115/tcp (API)
- 21116/tcp (�м�1)
- 21116/udp (�м�1)
- 21117/tcp (�м�2)
- 21118/tcp (�ļ�����)
- 21119/tcp (���紩͸)
EOF

echo "? RustDesk �������"
echo "?? ��Կ: $(cat /config/rustdesk/id_ed25519.pub 2>/dev/null || echo 'δ����')"