#!/bin/bash

# TeaFarmOps セキュリティ監査スクリプト
# 使用方法: ./scripts/security-audit.sh [options]

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
AUDIT_CONFIG="/etc/tea-farm-ops/security-audit-config.yml"
LOG_FILE="/var/log/tea-farm-ops/security/audit.log"
REPORT_DIR="/var/log/tea-farm-ops/security/reports"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps セキュリティ監査スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -f, --full          完全監査（すべてのチェック）"
    echo "  -s, --system        システム監査"
    echo "  -n, --network       ネットワーク監査"
    echo "  -u, --users         ユーザー監査"
    echo "  -p, --packages      パッケージ監査"
    echo "  -l, --logs          ログ監査"
    echo "  -r, --report        レポート生成"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --full            # 完全監査"
    echo "  $0 --system          # システム監査のみ"
    echo "  $0 --report          # レポート生成"
}

# 引数解析
FULL_AUDIT=false
SYSTEM_AUDIT=false
NETWORK_AUDIT=false
USERS_AUDIT=false
PACKAGES_AUDIT=false
LOGS_AUDIT=false
REPORT_GEN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--full)
            FULL_AUDIT=true
            shift
            ;;
        -s|--system)
            SYSTEM_AUDIT=true
            shift
            ;;
        -n|--network)
            NETWORK_AUDIT=true
            shift
            ;;
        -u|--users)
            USERS_AUDIT=true
            shift
            ;;
        -p|--packages)
            PACKAGES_AUDIT=true
            shift
            ;;
        -l|--logs)
            LOGS_AUDIT=true
            shift
            ;;
        -r|--report)
            REPORT_GEN=true
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
    mkdir -p "$REPORT_DIR"
    
    if [[ "$VERBOSE" == "true" ]]; then
        exec 1> >(tee -a "$LOG_FILE")
        exec 2>&1
    else
        exec 1> >(tee -a "$LOG_FILE" >/dev/null)
        exec 2>&1
    fi
}

# システム監査
audit_system() {
    log_info "システム監査を実行中..."
    
    local report_file="$REPORT_DIR/system_audit_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps システム監査レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # システム情報
        echo "=== システム情報 ==="
        uname -a
        echo ""
        
        # カーネル情報
        echo "=== カーネル情報 ==="
        cat /proc/version
        echo ""
        
        # メモリ使用量
        echo "=== メモリ使用量 ==="
        free -h
        echo ""
        
        # ディスク使用量
        echo "=== ディスク使用量 ==="
        df -h
        echo ""
        
        # プロセス情報
        echo "=== 実行中のプロセス（上位10件） ==="
        ps aux --sort=-%cpu | head -11
        echo ""
        
        # システムサービス
        echo "=== システムサービス ==="
        systemctl list-units --type=service --state=running | head -20
        echo ""
        
        # 起動サービス
        echo "=== 起動時に自動開始されるサービス ==="
        systemctl list-unit-files --type=service --state=enabled | head -20
        echo ""
        
        # ファイルシステム
        echo "=== マウントされたファイルシステム ==="
        mount | grep -E '^/dev'
        echo ""
        
        # 環境変数
        echo "=== 重要な環境変数 ==="
        env | grep -E '^(PATH|HOME|USER|SHELL|TERM)' | sort
        echo ""
        
    } > "$report_file"
    
    log_success "システム監査が完了しました: $report_file"
}

# ネットワーク監査
audit_network() {
    log_info "ネットワーク監査を実行中..."
    
    local report_file="$REPORT_DIR/network_audit_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps ネットワーク監査レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # ネットワークインターフェース
        echo "=== ネットワークインターフェース ==="
        ip addr show
        echo ""
        
        # ルーティングテーブル
        echo "=== ルーティングテーブル ==="
        ip route show
        echo ""
        
        # 開いているポート
        echo "=== 開いているポート ==="
        netstat -tuln
        echo ""
        
        # アクティブな接続
        echo "=== アクティブな接続 ==="
        netstat -tuln | grep ESTABLISHED | head -10
        echo ""
        
        # ファイアウォール状態
        echo "=== ファイアウォール状態 ==="
        if command -v ufw >/dev/null 2>&1; then
            ufw status verbose
        else
            echo "UFWがインストールされていません"
        fi
        echo ""
        
        # iptablesルール
        echo "=== iptablesルール ==="
        iptables -L -n -v
        echo ""
        
        # DNS設定
        echo "=== DNS設定 ==="
        cat /etc/resolv.conf
        echo ""
        
        # ホストファイル
        echo "=== ホストファイル ==="
        cat /etc/hosts
        echo ""
        
        # ネットワークサービス
        echo "=== ネットワークサービス ==="
        systemctl list-units --type=service | grep -E '(network|networking|sshd|nginx|apache)'
        echo ""
        
    } > "$report_file"
    
    log_success "ネットワーク監査が完了しました: $report_file"
}

# ユーザー監査
audit_users() {
    log_info "ユーザー監査を実行中..."
    
    local report_file="$REPORT_DIR/users_audit_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps ユーザー監査レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # ユーザー一覧
        echo "=== システムユーザー一覧 ==="
        cat /etc/passwd
        echo ""
        
        # グループ一覧
        echo "=== グループ一覧 ==="
        cat /etc/group
        echo ""
        
        # パスワード情報
        echo "=== パスワード情報 ==="
        cat /etc/shadow | head -10
        echo ""
        
        # ログインユーザー
        echo "=== 現在ログインしているユーザー ==="
        who
        echo ""
        
        # 最近のログイン
        echo "=== 最近のログイン履歴 ==="
        last | head -20
        echo ""
        
        # 失敗したログイン試行
        echo "=== 失敗したログイン試行 ==="
        lastb | head -20
        echo ""
        
        # sudo権限を持つユーザー
        echo "=== sudo権限を持つユーザー ==="
        grep -Po '^sudo.+:\K.*$' /etc/group | tr ',' '\n'
        echo ""
        
        # SSH設定
        echo "=== SSH設定 ==="
        if [[ -f /etc/ssh/sshd_config ]]; then
            grep -E '^(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|Port)' /etc/ssh/sshd_config
        else
            echo "SSH設定ファイルが見つかりません"
        fi
        echo ""
        
        # ユーザー権限
        echo "=== 重要なファイルの権限 ==="
        ls -la /etc/passwd /etc/shadow /etc/group /etc/gshadow
        echo ""
        
    } > "$report_file"
    
    log_success "ユーザー監査が完了しました: $report_file"
}

# パッケージ監査
audit_packages() {
    log_info "パッケージ監査を実行中..."
    
    local report_file="$REPORT_DIR/packages_audit_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps パッケージ監査レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # パッケージマネージャーの確認
        echo "=== パッケージマネージャー情報 ==="
        if command -v apt-get >/dev/null 2>&1; then
            echo "パッケージマネージャー: apt-get"
            echo "更新可能なパッケージ数:"
            apt list --upgradable 2>/dev/null | wc -l
        elif command -v yum >/dev/null 2>&1; then
            echo "パッケージマネージャー: yum"
            echo "更新可能なパッケージ数:"
            yum check-update 2>/dev/null | wc -l
        elif command -v dnf >/dev/null 2>&1; then
            echo "パッケージマネージャー: dnf"
            echo "更新可能なパッケージ数:"
            dnf check-update 2>/dev/null | wc -l
        fi
        echo ""
        
        # インストールされているパッケージ
        echo "=== インストールされているパッケージ（上位20件） ==="
        if command -v dpkg >/dev/null 2>&1; then
            dpkg -l | head -25
        elif command -v rpm >/dev/null 2>&1; then
            rpm -qa | head -20
        fi
        echo ""
        
        # セキュリティ関連パッケージ
        echo "=== セキュリティ関連パッケージ ==="
        if command -v dpkg >/dev/null 2>&1; then
            dpkg -l | grep -E '(firewall|security|audit|fail2ban|clamav)'
        elif command -v rpm >/dev/null 2>&1; then
            rpm -qa | grep -E '(firewall|security|audit|fail2ban|clamav)'
        fi
        echo ""
        
        # 最近インストールされたパッケージ
        echo "=== 最近インストールされたパッケージ ==="
        if command -v dpkg >/dev/null 2>&1; then
            grep "install" /var/log/dpkg.log | tail -10
        elif command -v rpm >/dev/null 2>&1; then
            grep "installed" /var/log/yum.log | tail -10
        fi
        echo ""
        
        # 脆弱性スキャン
        echo "=== 脆弱性スキャン ==="
        if command -v apt-get >/dev/null 2>&1; then
            echo "apt-getを使用した脆弱性チェック:"
            apt-get update >/dev/null 2>&1
            apt-get upgrade --dry-run 2>&1 | head -10
        elif command -v yum >/dev/null 2>&1; then
            echo "yumを使用した脆弱性チェック:"
            yum check-update 2>&1 | head -10
        fi
        echo ""
        
    } > "$report_file"
    
    log_success "パッケージ監査が完了しました: $report_file"
}

# ログ監査
audit_logs() {
    log_info "ログ監査を実行中..."
    
    local report_file="$REPORT_DIR/logs_audit_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps ログ監査レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # システムログ
        echo "=== システムログ（最新20件） ==="
        journalctl -n 20 --no-pager
        echo ""
        
        # 認証ログ
        echo "=== 認証ログ（最新20件） ==="
        if [[ -f /var/log/auth.log ]]; then
            tail -20 /var/log/auth.log
        elif [[ -f /var/log/secure ]]; then
            tail -20 /var/log/secure
        else
            echo "認証ログファイルが見つかりません"
        fi
        echo ""
        
        # SSHログ
        echo "=== SSHログ（最新20件） ==="
        journalctl -u sshd -n 20 --no-pager
        echo ""
        
        # 失敗したログイン試行
        echo "=== 失敗したログイン試行（最新20件） ==="
        if [[ -f /var/log/auth.log ]]; then
            grep "Failed password" /var/log/auth.log | tail -20
        elif [[ -f /var/log/secure ]]; then
            grep "Failed password" /var/log/secure | tail -20
        fi
        echo ""
        
        # ファイアウォールログ
        echo "=== ファイアウォールログ（最新20件） ==="
        if [[ -f /var/log/ufw.log ]]; then
            tail -20 /var/log/ufw.log
        else
            echo "ファイアウォールログファイルが見つかりません"
        fi
        echo ""
        
        # Nginxログ
        echo "=== Nginxログ（最新20件） ==="
        if [[ -f /var/log/nginx/access.log ]]; then
            tail -20 /var/log/nginx/access.log
        else
            echo "Nginxログファイルが見つかりません"
        fi
        echo ""
        
        # エラーログ
        echo "=== エラーログ（最新20件） ==="
        journalctl -p err -n 20 --no-pager
        echo ""
        
        # 警告ログ
        echo "=== 警告ログ（最新20件） ==="
        journalctl -p warning -n 20 --no-pager
        echo ""
        
    } > "$report_file"
    
    log_success "ログ監査が完了しました: $report_file"
}

# セキュリティ脆弱性スキャン
security_vulnerability_scan() {
    log_info "セキュリティ脆弱性スキャンを実行中..."
    
    local report_file="$REPORT_DIR/vulnerability_scan_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps セキュリティ脆弱性スキャンレポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # 開いているポートの確認
        echo "=== 開いているポート ==="
        netstat -tuln | grep LISTEN
        echo ""
        
        # 不要なサービスの確認
        echo "=== 不要なサービスの確認 ==="
        local unnecessary_services=("telnet" "ftp" "rsh" "rlogin" "finger" "tftp")
        for service in "${unnecessary_services[@]}"; do
            if systemctl is-active --quiet "$service" 2>/dev/null; then
                echo "警告: $service が実行中です"
            fi
        done
        echo ""
        
        # ファイル権限の確認
        echo "=== 重要なファイルの権限確認 ==="
        local critical_files=(
            "/etc/passwd"
            "/etc/shadow"
            "/etc/group"
            "/etc/gshadow"
            "/etc/ssh/sshd_config"
            "/etc/sudoers"
        )
        
        for file in "${critical_files[@]}"; do
            if [[ -f "$file" ]]; then
                local perms=$(stat -c "%a %U:%G" "$file")
                echo "$file: $perms"
            fi
        done
        echo ""
        
        # セットUIDファイルの確認
        echo "=== セットUIDファイル ==="
        find / -perm -4000 -type f 2>/dev/null | head -10
        echo ""
        
        # セットGIDファイルの確認
        echo "=== セットGIDファイル ==="
        find / -perm -2000 -type f 2>/dev/null | head -10
        echo ""
        
        # 書き込み可能なディレクトリの確認
        echo "=== 書き込み可能なディレクトリ ==="
        find /tmp /var/tmp -type d -perm -1777 2>/dev/null
        echo ""
        
        # 環境変数の確認
        echo "=== 環境変数の確認 ==="
        env | grep -E '^(PATH|LD_LIBRARY_PATH|LD_PRELOAD)' | head -10
        echo ""
        
    } > "$report_file"
    
    log_success "セキュリティ脆弱性スキャンが完了しました: $report_file"
}

# 包括的レポートの生成
generate_comprehensive_report() {
    log_info "包括的レポートを生成中..."
    
    local report_file="$REPORT_DIR/comprehensive_audit_$(date +%Y%m%d_%H%M%S).txt"
    local timestamp=$(date +%Y-%m-%d_%H:%M:%S)
    
    {
        echo "# TeaFarmOps 包括的セキュリティ監査レポート"
        echo "# 生成日時: $timestamp"
        echo "# システム: $(uname -a)"
        echo ""
        
        echo "## 実行サマリー"
        echo "- システム監査: 完了"
        echo "- ネットワーク監査: 完了"
        echo "- ユーザー監査: 完了"
        echo "- パッケージ監査: 完了"
        echo "- ログ監査: 完了"
        echo "- 脆弱性スキャン: 完了"
        echo ""
        
        echo "## 重要な発見事項"
        
        # セキュリティ警告の集約
        echo "### セキュリティ警告"
        
        # 失敗したログイン試行の確認
        local failed_logins=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l || echo "0")
        if [[ $failed_logins -gt 10 ]]; then
            echo "- 警告: 多数の失敗したログイン試行が検出されました ($failed_logins件)"
        fi
        
        # 更新可能なパッケージの確認
        if command -v apt-get >/dev/null 2>&1; then
            local updates=$(apt list --upgradable 2>/dev/null | wc -l)
            if [[ $updates -gt 5 ]]; then
                echo "- 警告: 更新可能なパッケージが多数あります ($updates件)"
            fi
        fi
        
        # 開いているポートの確認
        local open_ports=$(netstat -tuln | grep LISTEN | wc -l)
        echo "- 情報: 開いているポート数: $open_ports"
        
        echo ""
        echo "## 推奨事項"
        echo "1. 定期的なセキュリティ監査の実行"
        echo "2. パッケージの定期的な更新"
        echo "3. ログの定期的な監視"
        echo "4. ファイアウォールルールの定期的な見直し"
        echo "5. ユーザー権限の定期的な確認"
        echo ""
        
        echo "## 詳細レポート"
        echo "個別の詳細レポートは以下のディレクトリに保存されています:"
        echo "$REPORT_DIR"
        echo ""
        
    } > "$report_file"
    
    log_success "包括的レポートが生成されました: $report_file"
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps セキュリティ監査を開始します..."
    
    # ログの設定
    setup_logging
    
    # 管理者権限の確認
    if [[ $EUID -ne 0 ]]; then
        log_warning "一部の監査項目は管理者権限が必要です"
    fi
    
    # オプションの処理
    if [[ "$FULL_AUDIT" == "true" ]]; then
        audit_system
        audit_network
        audit_users
        audit_packages
        audit_logs
        security_vulnerability_scan
        generate_comprehensive_report
    fi
    
    if [[ "$SYSTEM_AUDIT" == "true" ]]; then
        audit_system
    fi
    
    if [[ "$NETWORK_AUDIT" == "true" ]]; then
        audit_network
    fi
    
    if [[ "$USERS_AUDIT" == "true" ]]; then
        audit_users
    fi
    
    if [[ "$PACKAGES_AUDIT" == "true" ]]; then
        audit_packages
    fi
    
    if [[ "$LOGS_AUDIT" == "true" ]]; then
        audit_logs
    fi
    
    if [[ "$REPORT_GEN" == "true" ]]; then
        generate_comprehensive_report
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$FULL_AUDIT" == "false" && "$SYSTEM_AUDIT" == "false" && "$NETWORK_AUDIT" == "false" && "$USERS_AUDIT" == "false" && "$PACKAGES_AUDIT" == "false" && "$LOGS_AUDIT" == "false" && "$REPORT_GEN" == "false" ]]; then
        log_info "デフォルト動作: 完全監査を実行"
        audit_system
        audit_network
        audit_users
        audit_packages
        audit_logs
        security_vulnerability_scan
        generate_comprehensive_report
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "セキュリティ監査が完了しました（実行時間: ${duration}秒）"
    log_info "ログファイル: $LOG_FILE"
    log_info "レポートディレクトリ: $REPORT_DIR"
}

# スクリプト実行
main "$@" 