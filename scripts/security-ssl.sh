#!/bin/bash

# TeaFarmOps SSL証明書管理スクリプト
# 使用方法: ./scripts/security-ssl.sh [options]

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
SSL_CONFIG="/etc/tea-farm-ops/ssl-config.yml"
CERT_DIR="/etc/ssl/tea-farm-ops"
WEBROOT="/var/www/html"
LOG_FILE="/var/log/tea-farm-ops/security/ssl.log"

# ドメイン設定
DOMAINS=(
    "your-domain.com"
    "www.your-domain.com"
    "api.your-domain.com"
)

# ヘルプ表示
show_help() {
    echo "TeaFarmOps SSL証明書管理スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -i, --install       Certbotのインストール"
    echo "  -c, --certificate   証明書の取得"
    echo "  -r, --renew         証明書の更新"
    echo "  -s, --status        証明書の状態確認"
    echo "  -t, --test          証明書のテスト"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --install         # Certbotインストール"
    echo "  $0 --certificate     # 証明書取得"
    echo "  $0 --renew           # 証明書更新"
    echo "  $0 --status          # 状態確認"
}

# 引数解析
INSTALL=false
CERTIFICATE=false
RENEW=false
STATUS=false
TEST=false
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
        -c|--certificate)
            CERTIFICATE=true
            shift
            ;;
        -r|--renew)
            RENEW=true
            shift
            ;;
        -s|--status)
            STATUS=true
            shift
            ;;
        -t|--test)
            TEST=true
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
    mkdir -p /var/log/tea-farm-ops/security
    
    if [[ "$VERBOSE" == "true" ]]; then
        exec 1> >(tee -a "$LOG_FILE")
        exec 2>&1
    else
        exec 1> >(tee -a "$LOG_FILE" >/dev/null)
        exec 2>&1
    fi
}

# Certbotのインストール
install_certbot() {
    log_info "Certbotをインストール中..."
    
    if command -v certbot >/dev/null 2>&1; then
        log_success "Certbotは既にインストールされています"
        return 0
    fi
    
    # パッケージマネージャーの確認
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y certbot python3-certbot-nginx
    elif command -v yum >/dev/null 2>&1; then
        # CentOS/RHEL
        sudo yum install -y certbot python3-certbot-nginx
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        sudo dnf install -y certbot python3-certbot-nginx
    else
        log_error "サポートされていないパッケージマネージャーです"
        return 1
    fi
    
    log_success "Certbotがインストールされました"
}

# 証明書ディレクトリの作成
setup_cert_directories() {
    log_info "証明書ディレクトリを設定中..."
    
    sudo mkdir -p "$CERT_DIR"
    sudo mkdir -p "$WEBROOT"
    sudo mkdir -p "$WEBROOT/.well-known/acme-challenge"
    
    # 権限の設定
    sudo chown -R www-data:www-data "$WEBROOT"
    sudo chmod -R 755 "$WEBROOT"
    
    log_success "証明書ディレクトリが設定されました"
}

# 証明書の取得
obtain_certificates() {
    log_info "SSL証明書を取得中..."
    
    # ドメインリストの作成
    local domain_args=""
    for domain in "${DOMAINS[@]}"; do
        domain_args="$domain_args -d $domain"
    done
    
    # 証明書の取得
    if sudo certbot certonly \
        --webroot \
        --webroot-path="$WEBROOT" \
        --email admin@your-domain.com \
        --agree-tos \
        --no-eff-email \
        --expand \
        $domain_args; then
        
        log_success "SSL証明書が取得されました"
        
        # 証明書の配置
        deploy_certificates
    else
        log_error "SSL証明書の取得に失敗しました"
        return 1
    fi
}

# 証明書の配置
deploy_certificates() {
    log_info "証明書を配置中..."
    
    # 証明書ファイルのコピー
    for domain in "${DOMAINS[@]}"; do
        if [[ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]]; then
            sudo cp "/etc/letsencrypt/live/$domain/fullchain.pem" "$CERT_DIR/$domain.crt"
            sudo cp "/etc/letsencrypt/live/$domain/privkey.pem" "$CERT_DIR/$domain.key"
            
            # 権限の設定
            sudo chmod 644 "$CERT_DIR/$domain.crt"
            sudo chmod 600 "$CERT_DIR/$domain.key"
            sudo chown root:root "$CERT_DIR/$domain.crt"
            sudo chown root:root "$CERT_DIR/$domain.key"
            
            log_success "証明書が配置されました: $domain"
        fi
    done
}

# 証明書の更新
renew_certificates() {
    log_info "SSL証明書を更新中..."
    
    # 証明書の更新
    if sudo certbot renew --quiet; then
        log_success "SSL証明書が更新されました"
        
        # 更新された証明書の配置
        deploy_certificates
        
        # Nginxの再読み込み
        reload_nginx
    else
        log_error "SSL証明書の更新に失敗しました"
        return 1
    fi
}

# Nginxの再読み込み
reload_nginx() {
    log_info "Nginxを再読み込み中..."
    
    if command -v nginx >/dev/null 2>&1; then
        if sudo nginx -t; then
            sudo systemctl reload nginx
            log_success "Nginxが再読み込みされました"
        else
            log_error "Nginx設定のテストに失敗しました"
            return 1
        fi
    else
        log_warning "Nginxが見つかりません"
    fi
}

# 証明書の状態確認
check_certificate_status() {
    log_info "証明書の状態を確認中..."
    
    for domain in "${DOMAINS[@]}"; do
        echo ""
        echo "=== $domain の証明書情報 ==="
        
        if [[ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]]; then
            # 証明書の詳細情報
            echo "証明書ファイル: /etc/letsencrypt/live/$domain/fullchain.pem"
            echo "秘密鍵ファイル: /etc/letsencrypt/live/$domain/privkey.pem"
            
            # 有効期限の確認
            local expiry_date=$(openssl x509 -in "/etc/letsencrypt/live/$domain/fullchain.pem" -noout -enddate | cut -d= -f2)
            echo "有効期限: $expiry_date"
            
            # 残り日数の計算
            local expiry_timestamp=$(date -d "$expiry_date" +%s)
            local current_timestamp=$(date +%s)
            local days_remaining=$(( (expiry_timestamp - current_timestamp) / 86400 ))
            
            if [[ $days_remaining -gt 30 ]]; then
                log_success "証明書は有効です（残り $days_remaining 日）"
            elif [[ $days_remaining -gt 7 ]]; then
                log_warning "証明書の有効期限が近づいています（残り $days_remaining 日）"
            else
                log_error "証明書の有効期限が切れています（残り $days_remaining 日）"
            fi
            
            # 証明書の詳細
            echo ""
            echo "証明書の詳細:"
            openssl x509 -in "/etc/letsencrypt/live/$domain/fullchain.pem" -noout -text | head -20
        else
            log_error "証明書が見つかりません: $domain"
        fi
    done
}

# 証明書のテスト
test_certificates() {
    log_info "証明書をテスト中..."
    
    for domain in "${DOMAINS[@]}"; do
        echo ""
        echo "=== $domain の証明書テスト ==="
        
        # HTTPS接続テスト
        if command -v curl >/dev/null 2>&1; then
            echo "HTTPS接続テスト:"
            if curl -I "https://$domain" 2>/dev/null | head -1; then
                log_success "HTTPS接続が成功しました"
            else
                log_warning "HTTPS接続に失敗しました"
            fi
        fi
        
        # SSL証明書の検証
        if command -v openssl >/dev/null 2>&1; then
            echo "SSL証明書の検証:"
            if echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -dates; then
                log_success "SSL証明書の検証が成功しました"
            else
                log_error "SSL証明書の検証に失敗しました"
            fi
        fi
        
        # 証明書チェーンの検証
        if [[ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]]; then
            echo "証明書チェーンの検証:"
            if openssl verify "/etc/letsencrypt/live/$domain/fullchain.pem"; then
                log_success "証明書チェーンの検証が成功しました"
            else
                log_error "証明書チェーンの検証に失敗しました"
            fi
        fi
    done
}

# 自動更新の設定
setup_auto_renewal() {
    log_info "自動更新を設定中..."
    
    # cronジョブの追加
    local cron_job="0 12 * * * /usr/bin/certbot renew --quiet && /usr/bin/systemctl reload nginx"
    
    # 既存のcronジョブを確認
    if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
        (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
        log_success "自動更新のcronジョブが追加されました"
    else
        log_info "自動更新のcronジョブは既に設定されています"
    fi
    
    # systemdタイマーの設定（オプション）
    if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl enable certbot.timer
        sudo systemctl start certbot.timer
        log_success "certbotタイマーが有効化されました"
    fi
}

# 証明書のバックアップ
backup_certificates() {
    log_info "証明書をバックアップ中..."
    
    local backup_dir="/etc/tea-farm-ops/backup/ssl"
    local backup_file="$backup_dir/certificates_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    sudo mkdir -p "$backup_dir"
    
    # 証明書のバックアップ
    sudo tar -czf "$backup_file" -C /etc/letsencrypt live
    
    # 権限の設定
    sudo chown root:root "$backup_file"
    sudo chmod 600 "$backup_file"
    
    log_success "証明書がバックアップされました: $backup_file"
}

# 証明書の復元
restore_certificates() {
    log_info "証明書を復元中..."
    
    local backup_dir="/etc/tea-farm-ops/backup/ssl"
    local latest_backup=$(ls -t "$backup_dir"/certificates_*.tar.gz 2>/dev/null | head -1)
    
    if [[ -z "$latest_backup" ]]; then
        log_error "バックアップファイルが見つかりません"
        return 1
    fi
    
    log_info "最新のバックアップを使用: $latest_backup"
    
    # 復元の実行
    sudo tar -xzf "$latest_backup" -C /etc/letsencrypt
    
    # 証明書の配置
    deploy_certificates
    
    # Nginxの再読み込み
    reload_nginx
    
    log_success "証明書が復元されました"
}

# セキュリティヘッダーの設定
configure_security_headers() {
    log_info "セキュリティヘッダーを設定中..."
    
    # Nginx設定ファイルの作成
    local nginx_config="/etc/nginx/sites-available/tea-farm-ops-ssl"
    
    sudo tee "$nginx_config" > /dev/null << EOF
server {
    listen 80;
    server_name ${DOMAINS[*]};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAINS[*]};
    
    # SSL証明書
    ssl_certificate /etc/letsencrypt/live/${DOMAINS[0]}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAINS[0]}/privkey.pem;
    
    # SSL設定
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # セキュリティヘッダー
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https:; frame-ancestors 'none';" always;
    
    # ルートディレクトリ
    root $WEBROOT;
    index index.html index.htm;
    
    # ACMEチャレンジ
    location /.well-known/acme-challenge/ {
        root $WEBROOT;
    }
    
    # アプリケーション
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # APIプロキシ
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    
    # 設定ファイルの有効化
    sudo ln -sf "$nginx_config" /etc/nginx/sites-enabled/
    
    # Nginx設定のテスト
    if sudo nginx -t; then
        sudo systemctl reload nginx
        log_success "セキュリティヘッダーが設定されました"
    else
        log_error "Nginx設定のテストに失敗しました"
        return 1
    fi
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps SSL証明書管理を開始します..."
    
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
        install_certbot
        setup_cert_directories
        setup_auto_renewal
    fi
    
    if [[ "$CERTIFICATE" == "true" ]]; then
        obtain_certificates
        configure_security_headers
        backup_certificates
    fi
    
    if [[ "$RENEW" == "true" ]]; then
        renew_certificates
        backup_certificates
    fi
    
    if [[ "$STATUS" == "true" ]]; then
        check_certificate_status
    fi
    
    if [[ "$TEST" == "true" ]]; then
        test_certificates
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$INSTALL" == "false" && "$CERTIFICATE" == "false" && "$RENEW" == "false" && "$STATUS" == "false" && "$TEST" == "false" ]]; then
        log_info "デフォルト動作: インストールと証明書取得を実行"
        install_certbot
        setup_cert_directories
        obtain_certificates
        configure_security_headers
        setup_auto_renewal
        backup_certificates
        check_certificate_status
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "SSL証明書管理が完了しました（実行時間: ${duration}秒）"
    log_info "ログファイル: $LOG_FILE"
}

# スクリプト実行
main "$@" 