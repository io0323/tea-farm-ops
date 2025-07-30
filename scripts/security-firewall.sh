#!/bin/bash

# TeaFarmOps ファイアウォール設定スクリプト
# 使用方法: ./scripts/security-firewall.sh [options]

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
FIREWALL_CONFIG="/etc/tea-farm-ops/firewall-config.yml"
LOG_FILE="/var/log/tea-farm-ops/security/firewall.log"

# ポート設定
PORTS=(
    "22"      # SSH
    "80"      # HTTP
    "443"     # HTTPS
    "8080"    # Spring Boot API
    "3000"    # React Dev Server
    "5432"    # PostgreSQL
    "9090"    # Prometheus
    "3001"    # Grafana
    "9093"    # Alertmanager
)

# ヘルプ表示
show_help() {
    echo "TeaFarmOps ファイアウォール設定スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -i, --install       ファイアウォールのインストール"
    echo "  -c, --configure     ファイアウォールの設定"
    echo "  -s, --status        ファイアウォールの状態確認"
    echo "  -r, --reset         ファイアウォールのリセット"
    echo "  -t, --test          接続テスト"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --install         # ファイアウォールインストール"
    echo "  $0 --configure       # ファイアウォール設定"
    echo "  $0 --status          # 状態確認"
    echo "  $0 --test            # 接続テスト"
}

# 引数解析
INSTALL=false
CONFIGURE=false
STATUS=false
RESET=false
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
        -c|--configure)
            CONFIGURE=true
            shift
            ;;
        -s|--status)
            STATUS=true
            shift
            ;;
        -r|--reset)
            RESET=true
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

# UFWのインストール
install_ufw() {
    log_info "UFWファイアウォールをインストール中..."
    
    if command -v ufw >/dev/null 2>&1; then
        log_success "UFWは既にインストールされています"
        return 0
    fi
    
    # パッケージマネージャーの確認
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y ufw
    elif command -v yum >/dev/null 2>&1; then
        # CentOS/RHEL
        sudo yum install -y ufw
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        sudo dnf install -y ufw
    else
        log_error "サポートされていないパッケージマネージャーです"
        return 1
    fi
    
    log_success "UFWファイアウォールがインストールされました"
}

# UFWの基本設定
configure_ufw() {
    log_info "UFWファイアウォールを設定中..."
    
    # UFWの有効化
    sudo ufw --force enable
    
    # デフォルトポリシーの設定
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # SSH接続の許可（重要：ロックアウトを防ぐ）
    sudo ufw allow ssh
    sudo ufw allow 22/tcp
    
    # HTTP/HTTPSの許可
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    
    # アプリケーション用ポートの許可
    for port in "${PORTS[@]}"; do
        if [[ "$port" != "22" && "$port" != "80" && "$port" != "443" ]]; then
            sudo ufw allow "$port/tcp"
            log_info "ポート $port/tcp を許可しました"
        fi
    done
    
    # 特定のIPアドレスからのアクセス制限（オプション）
    # sudo ufw allow from 192.168.1.0/24 to any port 22
    # sudo ufw allow from 10.0.0.0/8 to any port 5432
    
    # レート制限の設定
    sudo ufw limit ssh
    sudo ufw limit 22/tcp
    
    log_success "UFWファイアウォールの設定が完了しました"
}

# ファイアウォールルールの詳細設定
configure_detailed_rules() {
    log_info "詳細なファイアウォールルールを設定中..."
    
    # アプリケーション固有のルール
    local app_rules=(
        # Spring Boot API
        "allow 8080/tcp comment 'Spring Boot API'"
        # React Dev Server
        "allow 3000/tcp comment 'React Dev Server'"
        # PostgreSQL（ローカルホストのみ）
        "allow from 127.0.0.1 to any port 5432 comment 'PostgreSQL Local'"
        # Prometheus
        "allow 9090/tcp comment 'Prometheus'"
        # Grafana
        "allow 3001/tcp comment 'Grafana'"
        # Alertmanager
        "allow 9093/tcp comment 'Alertmanager'"
    )
    
    for rule in "${app_rules[@]}"; do
        sudo ufw $rule
    done
    
    # 不要なサービスの拒否
    local deny_services=(
        "telnet"
        "ftp"
        "rsh"
        "rlogin"
        "finger"
    )
    
    for service in "${deny_services[@]}"; do
        sudo ufw deny $service
        log_info "サービス $service を拒否しました"
    done
    
    log_success "詳細なファイアウォールルールが設定されました"
}

# ファイアウォールの状態確認
check_firewall_status() {
    log_info "ファイアウォールの状態を確認中..."
    
    echo ""
    echo "=== UFW ステータス ==="
    sudo ufw status verbose
    
    echo ""
    echo "=== アクティブなルール ==="
    sudo ufw status numbered
    
    echo ""
    echo "=== ポートスキャン結果 ==="
    for port in "${PORTS[@]}"; do
        if netstat -tuln | grep -q ":$port "; then
            log_success "ポート $port は開いています"
        else
            log_warning "ポート $port は閉じています"
        fi
    done
}

# ファイアウォールのリセット
reset_firewall() {
    log_warning "ファイアウォールをリセットしますか？"
    echo "この操作により、すべてのカスタムルールが削除されます。"
    echo "続行しますか？ (y/N): "
    
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        log_info "ファイアウォールをリセット中..."
        sudo ufw --force reset
        log_success "ファイアウォールがリセットされました"
    else
        log_info "リセットがキャンセルされました"
    fi
}

# 接続テスト
test_connections() {
    log_info "接続テストを実行中..."
    
    local test_hosts=(
        "localhost"
        "127.0.0.1"
    )
    
    for host in "${test_hosts[@]}"; do
        echo ""
        echo "=== $host への接続テスト ==="
        
        for port in "${PORTS[@]}"; do
            if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
                log_success "✓ $host:$port に接続可能"
            else
                log_warning "✗ $host:$port に接続不可"
            fi
        done
    done
}

# セキュリティスキャン
security_scan() {
    log_info "セキュリティスキャンを実行中..."
    
    # 開いているポートの確認
    echo ""
    echo "=== 開いているポート ==="
    sudo netstat -tuln | grep LISTEN
    
    # 接続中のセッション
    echo ""
    echo "=== アクティブな接続 ==="
    sudo netstat -tuln | grep ESTABLISHED | head -10
    
    # ファイアウォールログの確認
    echo ""
    echo "=== ファイアウォールログ（最新10件） ==="
    sudo tail -10 /var/log/ufw.log 2>/dev/null || echo "ログファイルが見つかりません"
}

# ファイアウォール設定のバックアップ
backup_firewall_config() {
    log_info "ファイアウォール設定をバックアップ中..."
    
    local backup_dir="/etc/tea-farm-ops/backup"
    local backup_file="$backup_dir/firewall_config_$(date +%Y%m%d_%H%M%S).txt"
    
    mkdir -p "$backup_dir"
    
    {
        echo "# TeaFarmOps ファイアウォール設定バックアップ"
        echo "# 作成日時: $(date)"
        echo ""
        echo "=== UFW ステータス ==="
        sudo ufw status verbose
        echo ""
        echo "=== アクティブなルール ==="
        sudo ufw status numbered
        echo ""
        echo "=== システム情報 ==="
        uname -a
        echo ""
        echo "=== ネットワーク設定 ==="
        ip addr show
    } > "$backup_file"
    
    log_success "ファイアウォール設定がバックアップされました: $backup_file"
}

# ファイアウォール設定の復元
restore_firewall_config() {
    log_info "ファイアウォール設定を復元中..."
    
    local backup_dir="/etc/tea-farm-ops/backup"
    local latest_backup=$(ls -t "$backup_dir"/firewall_config_*.txt 2>/dev/null | head -1)
    
    if [[ -z "$latest_backup" ]]; then
        log_error "バックアップファイルが見つかりません"
        return 1
    fi
    
    log_info "最新のバックアップを使用: $latest_backup"
    
    # 復元手順の表示
    echo ""
    echo "復元手順:"
    echo "1. 現在の設定をバックアップ"
    echo "2. ファイアウォールをリセット"
    echo "3. バックアップから設定を復元"
    echo ""
    echo "続行しますか？ (y/N): "
    
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        backup_firewall_config
        reset_firewall
        configure_ufw
        configure_detailed_rules
        log_success "ファイアウォール設定が復元されました"
    else
        log_info "復元がキャンセルされました"
    fi
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps ファイアウォール設定を開始します..."
    
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
        install_ufw
    fi
    
    if [[ "$CONFIGURE" == "true" ]]; then
        configure_ufw
        configure_detailed_rules
        backup_firewall_config
    fi
    
    if [[ "$STATUS" == "true" ]]; then
        check_firewall_status
        security_scan
    fi
    
    if [[ "$RESET" == "true" ]]; then
        reset_firewall
    fi
    
    if [[ "$TEST" == "true" ]]; then
        test_connections
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$INSTALL" == "false" && "$CONFIGURE" == "false" && "$STATUS" == "false" && "$RESET" == "false" && "$TEST" == "false" ]]; then
        log_info "デフォルト動作: インストールと設定を実行"
        install_ufw
        configure_ufw
        configure_detailed_rules
        backup_firewall_config
        check_firewall_status
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "ファイアウォール設定が完了しました（実行時間: ${duration}秒）"
    log_info "ログファイル: $LOG_FILE"
}

# スクリプト実行
main "$@" 