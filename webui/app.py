#!/usr/bin/env python3
from flask import Flask, render_template, jsonify, request, send_file
import json
import os
import subprocess
import psutil
import threading
from datetime import datetime

app = Flask(__name__)

# �����ļ�·��
CONFIG_DIR = "/config"

def get_service_status(service_name):
    """��ȡ����״̬"""
    try:
        result = subprocess.run(
            ["supervisorctl", "status", service_name],
            capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return "δ֪״̬"

def get_config():
    """��ȡ������Ϣ"""
    config = {}
    
    # ��ȡ Xray ����
    try:
        with open(f"{CONFIG_DIR}/xray/reality_public.key", "r") as f:
            config['xray_public_key'] = f.read().strip()
    except:
        config['xray_public_key'] = "δ����"
    
    # ��ȡ WireGuard ����
    try:
        with open(f"{CONFIG_DIR}/wireguard/server_public.key", "r") as f:
            config['wireguard_public_key'] = f.read().strip()
    except:
        config['wireguard_public_key'] = "δ����"
    
    # ��ȡϵͳ��Ϣ
    config['domain'] = os.getenv('DOMAIN', 'rustdesk.i-erp.net.cn')
    config['wireguard_admin_port'] = os.getenv('WIREGUARD_ADMIN_PORT', '11211')
    config['frp_admin_port'] = os.getenv('FRP_ADMIN_PORT', '7500')
    
    return config

def get_system_info():
    """��ȡϵͳ��Ϣ"""
    # CPU ʹ����
    cpu_percent = psutil.cpu_percent(interval=1)
    
    # �ڴ�ʹ����
    memory = psutil.virtual_memory()
    
    # ����ʹ����
    disk = psutil.disk_usage(CONFIG_DIR)
    
    # ������Ϣ
    net_io = psutil.net_io_counters()
    
    return {
        'cpu_percent': cpu_percent,
        'memory_total': round(memory.total / (1024**3), 2),
        'memory_used': round(memory.used / (1024**3), 2),
        'memory_percent': memory.percent,
        'disk_total': round(disk.total / (1024**3), 2),
        'disk_used': round(disk.used / (1024**3), 2),
        'disk_percent': disk.percent,
        'bytes_sent': round(net_io.bytes_sent / (1024**2), 2),
        'bytes_recv': round(net_io.bytes_recv / (1024**2), 2),
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }

@app.route('/')
def index():
    """��ҳ"""
    services = {
        'xray': get_service_status('xray'),
        'wireguard': get_service_status('wireguard'),
        'openvpn': get_service_status('openvpn'),
        'frp': get_service_status('frp'),
        'rustdesk': get_service_status('rustdesk'),
        'webui': get_service_status('webui')
    }
    
    config = get_config()
    system_info = get_system_info()
    
    return render_template('index.html', 
                         services=services, 
                         config=config,
                         system_info=system_info)

@app.route('/api/services')
def api_services():
    """API: ��ȡ����״̬"""
    services = {
        'xray': get_service_status('xray'),
        'wireguard': get_service_status('wireguard'),
        'openvpn': get_service_status('openvpn'),
        'frp': get_service_status('frp'),
        'rustdesk': get_service_status('rustdesk'),
        'webui': get_service_status('webui')
    }
    return jsonify(services)

@app.route('/api/config')
def api_config():
    """API: ��ȡ������Ϣ"""
    config = get_config()
    return jsonify(config)

@app.route('/api/system')
def api_system():
    """API: ��ȡϵͳ��Ϣ"""
    system_info = get_system_info()
    return jsonify(system_info)

@app.route('/api/restart/<service_name>', methods=['POST'])
def restart_service(service_name):
    """API: ��������"""
    try:
        result = subprocess.run(
            ["supervisorctl", "restart", service_name],
            capture_output=True, text=True, check=True
        )
        return jsonify({"status": "success", "message": result.stdout})
    except subprocess.CalledProcessError as e:
        return jsonify({"status": "error", "message": e.stderr}), 500

@app.route('/api/logs/<service_name>')
def get_logs(service_name):
    """API: ��ȡ������־"""
    log_file = f"{CONFIG_DIR}/logs/{service_name}.out.log"
    try:
        with open(log_file, 'r') as f:
            logs = f.read()
        return jsonify({"status": "success", "logs": logs})
    except FileNotFoundError:
        return jsonify({"status": "error", "message": "��־�ļ�������"}), 404

@app.route('/download/<file_type>')
def download_file(file_type):
    """���������ļ�"""
    file_map = {
        'wireguard': f"{CONFIG_DIR}/wireguard/client.conf",
        'openvpn': f"{CONFIG_DIR}/openvpn/client.ovpn",
        'frp-client': f"{CONFIG_DIR}/frp/frpc-example.ini",
        'rustdesk-info': f"{CONFIG_DIR}/rustdesk/client-info.txt"
    }
    
    if file_type in file_map and os.path.exists(file_map[file_type]):
        return send_file(file_map[file_type], as_attachment=True)
    else:
        return "�ļ�������", 404

@app.route('/about')
def about():
    """����ҳ��"""
    return jsonify({
        "name": "OmniGate",
        "version": "1.0.0",
        "description": "Omnipotent Network Gateway - All-in-One Network Services Container",
        "services": [
            "Xray Reality Proxy",
            "WireGuard VPN", 
            "OpenVPN",
            "FRP Server",
            "RustDesk Server",
            "Web Management Interface"
        ]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)