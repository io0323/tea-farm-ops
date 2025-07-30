#!/bin/bash

# TeaFarmOps パフォーマンス最適化 - Nginx最適化
# 使用方法: ./scripts/performance-nginx.sh [options]

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 設定
NGINX_CONFIG="/etc/nginx/nginx.conf"
NGINX_SITES="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
LOG_FILE="/var/log/tea-farm-ops/performance/nginx.log"
CACHE_DIR="/var/cache/nginx"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps Nginx最適化スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -i, --install       Nginxのインストール"
    echo "  -c, --configure     Nginxの設定最適化"
    echo "  -s, --ssl           SSL設定の最適化"
    echo "  -g, --gzip          Gzip圧縮の設定"
    echo "  -p, --proxy         プロキシ設定の最適化"
    echo "  -m, --monitor       パフォーマンス監視"
    echo "  -t, --test          パフォーマンステスト"
    echo "  -o, --optimize      包括的最適化"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --install         # Nginxインストール"
    echo "  $0 --optimize        # 包括的最適化"
    echo "  $0 --monitor         # パフォーマンス監視"
}

# 引数解析
INSTALL=false
CONFIGURE=false
SSL=false
GZIP=false
PROXY=false
MONITOR=false
TEST=false
OPTIMIZE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--install)
            INSTALL=true
            shift
            ;;
        -c|--configure)
            CONFIGURE=true
            shift
            ;;
        -s|--ssl)
            SSL=true
            shift
            ;;
        -g|--gzip)
            GZIP=true
            shift
            ;;
        -p|--proxy)
            PROXY=true
            shift
            ;;
        -m|--monitor)
            MONITOR=true
            shift
            ;;
        -t|--test)
            TEST=true
            shift
            ;;
        -o|--optimize)
            OPTIMIZE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            log_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
    esac
done

# ログディレクトリの作成
setup_logging() {
    mkdir -p /var/log/tea-farm-ops/performance
    
    if [[ "$VERBOSE" == "true" ]]; then
        exec 1> >(tee -a "$LOG_FILE")
        exec 2>&1
    else
        exec 1> >(tee -a "$LOG_FILE" >/dev/null)
        exec 2>&1
    fi
}

# Nginxのインストール
install_nginx() {
    log_info "Nginxをインストール中..."
    
    if command -v nginx >/dev/null 2>&1; then
        log_success "Nginxは既にインストールされています"
        return 0
    fi
    
    # パッケージマネージャーの確認
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y nginx nginx-extras
    elif command -v yum >/dev/null 2>&1; then
        # CentOS/RHEL
        sudo yum install -y nginx
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        sudo dnf install -y nginx
    else
        log_error "サポートされていないパッケージマネージャーです"
        return 1
    fi
    
    # Nginxサービスの有効化
    sudo systemctl enable nginx
    
    log_success "Nginxがインストールされました"
}

# Nginx設定の最適化
configure_nginx() {
    log_info "Nginx設定を最適化中..."
    
    # 設定ファイルのバックアップ
    if [[ -f "$NGINX_CONFIG" ]]; then
        sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # システム情報の取得
    local cpu_cores=$(nproc)
    local total_memory=$(free -m | awk 'NR==2{printf "%.0f", $2}')
    local worker_connections=$((cpu_cores * 1024))
    
    # 最適化されたNginx設定
    sudo tee "$NGINX_CONFIG" > /dev/null << EOF
# TeaFarmOps Nginx設定 - パフォーマンス最適化

user www-data;
worker_processes auto;
worker_cpu_affinity auto;
worker_rlimit_nofile 65535;

# エラーログ
error_log /var/log/nginx/error.log warn;
pid /run/nginx.pid;

# イベント設定
events {
    use epoll;
    worker_connections ${worker_connections};
    multi_accept on;
    accept_mutex off;
}

# HTTP設定
http {
    # 基本設定
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # ログ設定
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    # パフォーマンス設定
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    keepalive_requests 100;
    types_hash_max_size 2048;
    server_tokens off;
    
    # バッファ設定
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;
    output_buffers 1 32k;
    postpone_output 1460;
    
    # タイムアウト設定
    client_header_timeout 3m;
    client_body_timeout 3m;
    send_timeout 3m;
    
    # Gzip圧縮設定
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    # キャッシュ設定
    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    
    # マイクロキャッシュ設定
    fastcgi_cache_path /tmp/nginx_cache levels=1:2 keys_zone=my_cache:10m max_size=10g inactive=60m use_temp_path=off;
    fastcgi_cache_key "\$request_method\$request_uri";
    fastcgi_cache_use_stale error timeout invalid_header http_500;
    fastcgi_cache_valid 200 60m;
    
    # セキュリティ設定
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    
    # レート制限
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone \$binary_remote_addr zone=login:10m rate=1r/s;
    
    # アップストリーム設定
    upstream backend {
        least_conn;
        server 127.0.0.1:8080 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # アップストリーム設定（WebSocket用）
    upstream websocket {
        server 127.0.0.1:8080;
    }
    
    # サーバー設定のインクルード
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
    
    # キャッシュディレクトリの作成
    sudo mkdir -p "$CACHE_DIR"
    sudo chown www-data:www-data "$CACHE_DIR"
    
    # Nginx設定のテスト
    if sudo nginx -t; then
        log_success "Nginx設定のテストが成功しました"
        
        # Nginxサービスの再起動
        sudo systemctl reload nginx
        log_success "Nginxサービスが再読み込みされました"
    else
        log_error "Nginx設定のテストに失敗しました"
        return 1
    fi
    
    log_success "Nginx設定最適化が完了しました"
}

# SSL設定の最適化
configure_ssl() {
    log_info "SSL設定を最適化中..."
    
    # SSL設定ファイルの作成
    local ssl_config="/etc/nginx/conf.d/ssl-optimization.conf"
    
    sudo tee "$ssl_config" > /dev/null << EOF
# SSL最適化設定

# SSL設定
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_session_tickets off;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;

# HSTS
add_header Strict-Transport-Security "max-age=63072000" always;

# SSL設定の最適化
ssl_buffer_size 4k;
ssl_dhparam /etc/ssl/certs/dhparam.pem;
EOF
    
    # DHパラメータの生成（初回のみ）
    if [[ ! -f /etc/ssl/certs/dhparam.pem ]]; then
        log_info "DHパラメータを生成中..."
        sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    fi
    
    log_success "SSL設定最適化が完了しました"
}

# Gzip圧縮の設定
configure_gzip() {
    log_info "Gzip圧縮を設定中..."
    
    # Gzip設定ファイルの作成
    local gzip_config="/etc/nginx/conf.d/gzip.conf"
    
    sudo tee "$gzip_config" > /dev/null << EOF
# Gzip圧縮設定

gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_proxied any;
gzip_comp_level 6;
gzip_buffers 16 8k;
gzip_http_version 1.1;
gzip_types
    text/plain
    text/css
    text/xml
    text/javascript
    text/x-component
    application/json
    application/javascript
    application/xml+rss
    application/atom+xml
    application/x-font-ttf
    application/vnd.ms-fontobject
    font/opentype
    image/svg+xml
    image/x-icon;
EOF
    
    log_success "Gzip圧縮設定が完了しました"
}

# プロキシ設定の最適化
configure_proxy() {
    log_info "プロキシ設定を最適化中..."
    
    # プロキシ設定ファイルの作成
    local proxy_config="/etc/nginx/conf.d/proxy.conf"
    
    sudo tee "$proxy_config" > /dev/null << EOF
# プロキシ最適化設定

# プロキシバッファ設定
proxy_buffering on;
proxy_buffer_size 4k;
proxy_buffers 8 4k;
proxy_busy_buffers_size 8k;
proxy_temp_file_write_size 8k;

# プロキシヘッダー設定
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;
proxy_set_header X-Forwarded-Host \$host;
proxy_set_header X-Forwarded-Port \$server_port;

# プロキシタイムアウト設定
proxy_connect_timeout 60s;
proxy_send_timeout 60s;
proxy_read_timeout 60s;

# プロキシキャッシュ設定
proxy_cache_path /var/cache/nginx/proxy levels=1:2 keys_zone=proxy_cache:10m max_size=10g inactive=60m use_temp_path=off;
proxy_cache_key "\$scheme\$request_method\$host\$request_uri";
proxy_cache_valid 200 302 10m;
proxy_cache_valid 404 1m;
proxy_cache_use_stale error timeout invalid_header http_500 http_502 http_503 http_504;

# WebSocket設定
proxy_http_version 1.1;
proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection "upgrade";
EOF
    
    log_success "プロキシ設定最適化が完了しました"
}

# サイト設定の作成
create_site_config() {
    log_info "サイト設定を作成中..."
    
    local site_config="$NGINX_SITES/tea-farm-ops"
    
    sudo tee "$site_config" > /dev/null << EOF
# TeaFarmOps サイト設定

# HTTP設定
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # セキュリティヘッダー
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    
    # レート制限
    limit_req zone=api burst=20 nodelay;
    
    # 静的ファイルのキャッシュ
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # APIプロキシ
    location /api/ {
        proxy_pass http://backend;
        proxy_cache proxy_cache;
        proxy_cache_valid 200 10m;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout invalid_header http_500 http_502 http_503 http_504;
        
        # レート制限
        limit_req zone=api burst=20 nodelay;
    }
    
    # WebSocketプロキシ
    location /ws/ {
        proxy_pass http://websocket;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # 静的ファイル配信
    location / {
        root /var/www/html;
        try_files \$uri \$uri/ /index.html;
        
        # キャッシュ設定
        expires 1h;
        add_header Cache-Control "public";
    }
    
    # ヘルスチェック
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}

# HTTPS設定
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # SSL証明書
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # SSL設定のインクルード
    include /etc/nginx/conf.d/ssl-optimization.conf;
    
    # セキュリティヘッダー
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https:; frame-ancestors 'none';";
    
    # レート制限
    limit_req zone=api burst=20 nodelay;
    
    # 静的ファイルのキャッシュ
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # APIプロキシ
    location /api/ {
        proxy_pass http://backend;
        proxy_cache proxy_cache;
        proxy_cache_valid 200 10m;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout invalid_header http_500 http_502 http_503 http_504;
        
        # レート制限
        limit_req zone=api burst=20 nodelay;
    }
    
    # WebSocketプロキシ
    location /ws/ {
        proxy_pass http://websocket;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # 静的ファイル配信
    location / {
        root /var/www/html;
        try_files \$uri \$uri/ /index.html;
        
        # キャッシュ設定
        expires 1h;
        add_header Cache-Control "public";
    }
    
    # ヘルスチェック
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF
    
    # サイトの有効化
    sudo ln -sf "$site_config" "$NGINX_ENABLED/"
    
    log_success "サイト設定が作成されました"
}

# パフォーマンス監視
monitor_performance() {
    log_info "Nginxパフォーマンスを監視中..."
    
    echo ""
    echo "=== Nginxプロセス情報 ==="
    
    # プロセス情報
    ps aux | grep nginx | grep -v grep
    
    echo ""
    echo "=== Nginx接続統計 ==="
    
    # 接続統計
    if command -v ss >/dev/null 2>&1; then
        ss -tuln | grep :80
        ss -tuln | grep :443
    fi
    
    echo ""
    echo "=== Nginxアクセスログ統計 ==="
    
    # アクセスログ統計
    if [[ -f /var/log/nginx/access.log ]]; then
        echo "総リクエスト数: $(wc -l < /var/log/nginx/access.log)"
        echo "今日のリクエスト数: $(grep "$(date +%Y-%m-%d)" /var/log/nginx/access.log | wc -l)"
        echo "1分間のリクエスト数: $(tail -1000 /var/log/nginx/access.log | grep "$(date '+%d/%b/%Y:%H:%M')" | wc -l)"
    fi
    
    echo ""
    echo "=== Nginxエラーログ ==="
    
    # エラーログの確認
    if [[ -f /var/log/nginx/error.log ]]; then
        echo "最新のエラー（最新10件）:"
        sudo tail -10 /var/log/nginx/error.log
    fi
    
    echo ""
    echo "=== Nginx設定情報 ==="
    
    # 設定情報
    nginx -V 2>&1 | head -5
    
    echo ""
    echo "=== キャッシュ使用状況 ==="
    
    # キャッシュ使用状況
    if [[ -d "$CACHE_DIR" ]]; then
        echo "キャッシュディレクトリサイズ: $(du -sh "$CACHE_DIR" 2>/dev/null || echo 'N/A')"
    fi
}

# パフォーマンステスト
performance_test() {
    log_info "Nginxパフォーマンステストを実行中..."
    
    echo ""
    echo "=== レスポンス時間テスト ==="
    
    # レスポンス時間テスト
    local test_urls=(
        "http://localhost/"
        "http://localhost/health"
        "http://localhost/api/health"
    )
    
    for url in "${test_urls[@]}"; do
        echo "テスト: $url"
        curl -w "時間: %{time_total}s, ステータス: %{http_code}\n" -o /dev/null -s "$url"
    done
    
    echo ""
    echo "=== 負荷テスト ==="
    
    # 簡単な負荷テスト
    if command -v ab >/dev/null 2>&1; then
        echo "Apache Bench負荷テスト（100リクエスト、10同時接続）:"
        ab -n 100 -c 10 http://localhost/ 2>/dev/null | grep -E "(Requests per second|Time per request|Transfer rate)"
    else
        echo "Apache Benchがインストールされていません"
    fi
    
    echo ""
    echo "=== Gzip圧縮テスト ==="
    
    # Gzip圧縮テスト
    local test_file="/var/www/html/test.html"
    if [[ -f "$test_file" ]]; then
        local original_size=$(stat -c%s "$test_file")
        local compressed_size=$(gzip -c "$test_file" | wc -c)
        local compression_ratio=$(echo "scale=2; (1 - $compressed_size / $original_size) * 100" | bc -l 2>/dev/null || echo "0")
        echo "ファイル: $test_file"
        echo "元サイズ: ${original_size} bytes"
        echo "圧縮後サイズ: ${compressed_size} bytes"
        echo "圧縮率: ${compression_ratio}%"
    fi
}

# 包括的最適化
comprehensive_optimization() {
    log_info "包括的Nginx最適化を実行中..."
    
    # 各最適化の実行
    configure_nginx
    configure_ssl
    configure_gzip
    configure_proxy
    create_site_config
    
    # 設定のテスト
    if sudo nginx -t; then
        sudo systemctl reload nginx
        log_success "Nginx設定が再読み込みされました"
    else
        log_error "Nginx設定のテストに失敗しました"
        return 1
    fi
    
    echo ""
    echo "=== 最適化後のパフォーマンス確認 ==="
    monitor_performance
    
    log_success "包括的Nginx最適化が完了しました"
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps Nginx最適化を開始します..."
    
    # ログの設定
    setup_logging
    
    # 管理者権限の確認
    if [[ $EUID -ne 0 ]]; then
        log_error "このスクリプトは管理者権限で実行する必要があります"
        echo "sudo $0 [options] を使用してください"
        exit 1
    fi
    
    # オプションの処理
    if [[ "$INSTALL" == "true" ]]; then
        install_nginx
    fi
    
    if [[ "$CONFIGURE" == "true" ]]; then
        configure_nginx
    fi
    
    if [[ "$SSL" == "true" ]]; then
        configure_ssl
    fi
    
    if [[ "$GZIP" == "true" ]]; then
        configure_gzip
    fi
    
    if [[ "$PROXY" == "true" ]]; then
        configure_proxy
    fi
    
    if [[ "$MONITOR" == "true" ]]; then
        monitor_performance
    fi
    
    if [[ "$TEST" == "true" ]]; then
        performance_test
    fi
    
    if [[ "$OPTIMIZE" == "true" ]]; then
        comprehensive_optimization
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$INSTALL" == "false" && "$CONFIGURE" == "false" && "$SSL" == "false" && "$GZIP" == "false" && "$PROXY" == "false" && "$MONITOR" == "false" && "$TEST" == "false" && "$OPTIMIZE" == "false" ]]; then
        log_info "デフォルト動作: 包括的最適化を実行"
        comprehensive_optimization
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "Nginx最適化が完了しました（実行時間: ${duration}秒）"
    log_info "ログファイル: $LOG_FILE"
}

# スクリプト実行
main "$@" 