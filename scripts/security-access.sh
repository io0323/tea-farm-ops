#!/bin/bash

# TeaFarmOps アクセス制御スクリプト
# 使用方法: ./scripts/security-access.sh [options]

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
ACCESS_CONFIG="/etc/tea-farm-ops/access-control-config.yml"
LOG_FILE="/var/log/tea-farm-ops/security/access.log"
BACKUP_DIR="/etc/tea-farm-ops/backup/access-control"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps アクセス制御スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -s, --ssh           SSH設定の強化"
    echo "  -u, --users         ユーザー権限管理"
    echo "  -f, --files         ファイル権限監査"
    echo "  -p, --permissions   権限の修正"
    echo "  -a, --audit         アクセス監査"
    echo "  -b, --backup        設定のバックアップ"
    echo "  -r, --restore       設定の復元"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --ssh            # SSH設定強化"
    echo "  $0 --users          # ユーザー権限管理"
    echo "  $0 --audit          # アクセス監査"
}

# 引数解析
SSH_HARDEN=false
USERS_MANAGE=false
FILES_AUDIT=false
PERMISSIONS_FIX=false
ACCESS_AUDIT=false
BACKUP_CONFIG=false
RESTORE_CONFIG=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--ssh)
            SSH_HARDEN=true
            shift
            ;;
        -u|--users)
            USERS_MANAGE=true
            shift
            ;;
        -f|--files)
            FILES_AUDIT=true
            shift
            ;;
        -p|--permissions)
            PERMISSIONS_FIX=true
            shift
            ;;
        -a|--audit)
            ACCESS_AUDIT=true
            shift
            ;;
        -b|--backup)
            BACKUP_CONFIG=true
            shift
            ;;
        -r|--restore)
            RESTORE_CONFIG=true
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
    mkdir -p "$BACKUP_DIR"
    
    if [[ "$VERBOSE" == "true" ]]; then
        exec 1> >(tee -a "$LOG_FILE")
        exec 2>&1
    else
        exec 1> >(tee -a "$LOG_FILE" >/dev/null)
        exec 2>&1
    fi
}

# SSH設定の強化
harden_ssh() {
    log_info "SSH設定を強化中..."
    
    local ssh_config="/etc/ssh/sshd_config"
    local backup_file="$BACKUP_DIR/sshd_config_$(date +%Y%m%d_%H%M%S).bak"
    
    # 現在の設定をバックアップ
    if [[ -f "$ssh_config" ]]; then
        sudo cp "$ssh_config" "$backup_file"
        log_success "SSH設定をバックアップしました: $backup_file"
    fi
    
    # SSH設定の強化
    local ssh_hardening=(
        "# SSH設定の強化 - TeaFarmOps"
        "Port 22"
        "Protocol 2"
        "HostKey /etc/ssh/ssh_host_rsa_key"
        "HostKey /etc/ssh/ssh_host_ecdsa_key"
        "HostKey /etc/ssh/ssh_host_ed25519_key"
        ""
        "# 認証設定"
        "PermitRootLogin no"
        "PubkeyAuthentication yes"
        "PasswordAuthentication no"
        "PermitEmptyPasswords no"
        "ChallengeResponseAuthentication no"
        "UsePAM yes"
        ""
        "# セッション設定"
        "X11Forwarding no"
        "PrintMotd no"
        "PrintLastLog yes"
        "TCPKeepAlive yes"
        "ClientAliveInterval 300"
        "ClientAliveCountMax 2"
        ""
        "# セキュリティ設定"
        "MaxAuthTries 3"
        "MaxSessions 10"
        "LoginGraceTime 60"
        "StrictModes yes"
        "PermitUserEnvironment no"
        "Compression delayed"
        ""
        "# ログ設定"
        "SyslogFacility AUTH"
        "LogLevel INFO"
        ""
        "# 接続制限"
        "AllowUsers teafarmops"
        "DenyUsers root"
        ""
        "# 追加セキュリティ"
        "Banner /etc/issue.net"
        "PermitTunnel no"
        "AllowAgentForwarding no"
        "AllowTcpForwarding no"
        "GatewayPorts no"
        "X11DisplayOffset 10"
        "X11UseLocalhost yes"
        "PermitTTY yes"
        "ForceCommand /usr/sbin/slogin"
        "ChrootDirectory none"
        "UsePrivilegeSeparation sandbox"
        "KeyRegenerationInterval 3600"
        "ServerKeyBits 1024"
        "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
        "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com"
        "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256"
        "HostKeyAlgorithms ssh-rsa,rsa-sha2-512,rsa-sha2-256,ecdsa-sha2-nistp256,ssh-ed25519"
    )
    
    # 新しいSSH設定ファイルの作成
    sudo tee "$ssh_config" > /dev/null << EOF
$(printf '%s\n' "${ssh_hardening[@]}")
EOF
    
    # SSH設定のテスト
    if sudo sshd -t; then
        log_success "SSH設定のテストが成功しました"
        
        # SSHサービスの再起動
        sudo systemctl restart sshd
        log_success "SSHサービスが再起動されました"
    else
        log_error "SSH設定のテストに失敗しました"
        sudo cp "$backup_file" "$ssh_config"
        return 1
    fi
    
    # SSH鍵の生成（存在しない場合）
    generate_ssh_keys
    
    log_success "SSH設定の強化が完了しました"
}

# SSH鍵の生成
generate_ssh_keys() {
    log_info "SSH鍵を生成中..."
    
    local ssh_dir="/home/teafarmops/.ssh"
    local key_file="$ssh_dir/id_ed25519"
    
    # SSHディレクトリの作成
    sudo mkdir -p "$ssh_dir"
    sudo chown teafarmops:teafarmops "$ssh_dir"
    sudo chmod 700 "$ssh_dir"
    
    # 鍵が存在しない場合のみ生成
    if [[ ! -f "$key_file" ]]; then
        sudo -u teafarmops ssh-keygen -t ed25519 -f "$key_file" -N "" -C "teafarmops@$(hostname)"
        log_success "SSH鍵が生成されました: $key_file"
    else
        log_info "SSH鍵は既に存在します: $key_file"
    fi
    
    # authorized_keysファイルの作成
    local auth_keys="$ssh_dir/authorized_keys"
    if [[ ! -f "$auth_keys" ]]; then
        sudo touch "$auth_keys"
        sudo chown teafarmops:teafarmops "$auth_keys"
        sudo chmod 600 "$auth_keys"
        log_info "authorized_keysファイルが作成されました"
    fi
}

# ユーザー権限管理
manage_users() {
    log_info "ユーザー権限を管理中..."
    
    local report_file="$BACKUP_DIR/users_audit_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps ユーザー権限監査レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # システムユーザーの確認
        echo "=== システムユーザー一覧 ==="
        awk -F: '$3 < 1000 {print $1 ":" $3 ":" $7}' /etc/passwd
        echo ""
        
        # 一般ユーザーの確認
        echo "=== 一般ユーザー一覧 ==="
        awk -F: '$3 >= 1000 {print $1 ":" $3 ":" $7}' /etc/passwd
        echo ""
        
        # sudo権限を持つユーザー
        echo "=== sudo権限を持つユーザー ==="
        grep -Po '^sudo.+:\K.*$' /etc/group | tr ',' '\n'
        echo ""
        
        # パスワード期限の確認
        echo "=== パスワード期限情報 ==="
        chage -l teafarmops 2>/dev/null || echo "teafarmopsユーザーが見つかりません"
        echo ""
        
        # ロックされたアカウント
        echo "=== ロックされたアカウント ==="
        passwd -S -a | grep LK
        echo ""
        
    } > "$report_file"
    
    # 不要なユーザーの無効化
    disable_unnecessary_users
    
    # パスワードポリシーの設定
    configure_password_policy
    
    log_success "ユーザー権限管理が完了しました: $report_file"
}

# 不要なユーザーの無効化
disable_unnecessary_users() {
    log_info "不要なユーザーを無効化中..."
    
    # 無効化するユーザーのリスト
    local users_to_disable=(
        "games"
        "lp"
        "news"
        "uucp"
        "proxy"
        "www-data"
        "backup"
        "list"
        "irc"
        "gnats"
        "nobody"
    )
    
    for user in "${users_to_disable[@]}"; do
        if id "$user" &>/dev/null; then
            # ユーザーをロック
            sudo passwd -l "$user" 2>/dev/null || true
            # シェルを無効化
            sudo chsh -s /usr/sbin/nologin "$user" 2>/dev/null || true
            log_info "ユーザー $user を無効化しました"
        fi
    done
}

# パスワードポリシーの設定
configure_password_policy() {
    log_info "パスワードポリシーを設定中..."
    
    local login_defs="/etc/login.defs"
    local backup_file="$BACKUP_DIR/login.defs_$(date +%Y%m%d_%H%M%S).bak"
    
    # 現在の設定をバックアップ
    sudo cp "$login_defs" "$backup_file"
    
    # パスワードポリシーの設定
    sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' "$login_defs"
    sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 1/' "$login_defs"
    sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 7/' "$login_defs"
    sudo sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 12/' "$login_defs"
    
    # PAM設定の強化
    configure_pam
    
    log_success "パスワードポリシーが設定されました"
}

# PAM設定の強化
configure_pam() {
    log_info "PAM設定を強化中..."
    
    local common_password="/etc/pam.d/common-password"
    local backup_file="$BACKUP_DIR/common-password_$(date +%Y%m%d_%H%M%S).bak"
    
    if [[ -f "$common_password" ]]; then
        # 現在の設定をバックアップ
        sudo cp "$common_password" "$backup_file"
        
        # パスワード複雑性の設定
        sudo sed -i 's/password.*requisite.*pam_pwquality.so.*/password requisite pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' "$common_password"
        
        log_success "PAM設定が強化されました"
    fi
}

# ファイル権限監査
audit_file_permissions() {
    log_info "ファイル権限を監査中..."
    
    local report_file="$BACKUP_DIR/file_permissions_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps ファイル権限監査レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # 重要なシステムファイルの権限
        echo "=== 重要なシステムファイルの権限 ==="
        local critical_files=(
            "/etc/passwd"
            "/etc/shadow"
            "/etc/group"
            "/etc/gshadow"
            "/etc/ssh/sshd_config"
            "/etc/sudoers"
            "/etc/hosts"
            "/etc/resolv.conf"
            "/etc/fstab"
            "/etc/crontab"
        )
        
        for file in "${critical_files[@]}"; do
            if [[ -f "$file" ]]; then
                local perms=$(stat -c "%a %U:%G %n" "$file")
                echo "$perms"
            fi
        done
        echo ""
        
        # セットUIDファイル
        echo "=== セットUIDファイル ==="
        find / -perm -4000 -type f 2>/dev/null | head -20
        echo ""
        
        # セットGIDファイル
        echo "=== セットGIDファイル ==="
        find / -perm -2000 -type f 2>/dev/null | head -20
        echo ""
        
        # 書き込み可能なファイル
        echo "=== 全ユーザー書き込み可能なファイル ==="
        find / -perm -002 -type f 2>/dev/null | head -20
        echo ""
        
        # アプリケーションファイルの権限
        echo "=== アプリケーションファイルの権限 ==="
        if [[ -d "/app" ]]; then
            find /app -type f -exec stat -c "%a %U:%G %n" {} \; | head -20
        fi
        echo ""
        
    } > "$report_file"
    
    log_success "ファイル権限監査が完了しました: $report_file"
}

# 権限の修正
fix_permissions() {
    log_info "ファイル権限を修正中..."
    
    # 重要なファイルの権限修正
    local critical_files=(
        "/etc/passwd:644:root:root"
        "/etc/shadow:600:root:root"
        "/etc/group:644:root:root"
        "/etc/gshadow:600:root:root"
        "/etc/ssh/sshd_config:600:root:root"
        "/etc/sudoers:440:root:root"
        "/etc/hosts:644:root:root"
        "/etc/resolv.conf:644:root:root"
        "/etc/fstab:644:root:root"
        "/etc/crontab:644:root:root"
    )
    
    for file_info in "${critical_files[@]}"; do
        IFS=':' read -r file perms owner group <<< "$file_info"
        
        if [[ -f "$file" ]]; then
            sudo chmod "$perms" "$file"
            sudo chown "$owner:$group" "$file"
            log_info "権限を修正しました: $file ($perms $owner:$group)"
        fi
    done
    
    # アプリケーションディレクトリの権限修正
    if [[ -d "/app" ]]; then
        sudo chown -R teafarmops:teafarmops /app
        sudo find /app -type d -exec chmod 755 {} \;
        sudo find /app -type f -exec chmod 644 {} \;
        log_info "アプリケーションディレクトリの権限を修正しました"
    fi
    
    # ログディレクトリの権限修正
    sudo chown -R root:root /var/log/tea-farm-ops
    sudo chmod -R 755 /var/log/tea-farm-ops
    log_info "ログディレクトリの権限を修正しました"
    
    log_success "ファイル権限の修正が完了しました"
}

# アクセス監査
audit_access() {
    log_info "アクセス監査を実行中..."
    
    local report_file="$BACKUP_DIR/access_audit_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps アクセス監査レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # 現在のログインユーザー
        echo "=== 現在ログインしているユーザー ==="
        who
        echo ""
        
        # 最近のログイン履歴
        echo "=== 最近のログイン履歴 ==="
        last | head -20
        echo ""
        
        # 失敗したログイン試行
        echo "=== 失敗したログイン試行 ==="
        lastb | head -20
        echo ""
        
        # SSH接続の確認
        echo "=== SSH接続の確認 ==="
        ss -tuln | grep :22
        echo ""
        
        # アクティブなSSHセッション
        echo "=== アクティブなSSHセッション ==="
        ss -tuln | grep ESTABLISHED | grep :22
        echo ""
        
        # ファイルアクセスログ
        echo "=== ファイルアクセスログ（最新20件） ==="
        journalctl -f /var/log/auth.log | grep -E "(opened|accessed)" | tail -20
        echo ""
        
        # sudo使用履歴
        echo "=== sudo使用履歴 ==="
        journalctl | grep sudo | tail -20
        echo ""
        
    } > "$report_file"
    
    log_success "アクセス監査が完了しました: $report_file"
}

# 設定のバックアップ
backup_configurations() {
    log_info "設定をバックアップ中..."
    
    local backup_file="$BACKUP_DIR/config_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # 重要な設定ファイルのバックアップ
    sudo tar -czf "$backup_file" \
        /etc/ssh/sshd_config \
        /etc/passwd \
        /etc/shadow \
        /etc/group \
        /etc/gshadow \
        /etc/sudoers \
        /etc/login.defs \
        /etc/pam.d/common-password \
        /etc/hosts \
        /etc/resolv.conf \
        /etc/fstab \
        /etc/crontab \
        2>/dev/null || true
    
    # 権限の設定
    sudo chown root:root "$backup_file"
    sudo chmod 600 "$backup_file"
    
    log_success "設定がバックアップされました: $backup_file"
}

# 設定の復元
restore_configurations() {
    log_info "設定を復元中..."
    
    local backup_dir="$BACKUP_DIR"
    local latest_backup=$(ls -t "$backup_dir"/config_backup_*.tar.gz 2>/dev/null | head -1)
    
    if [[ -z "$latest_backup" ]]; then
        log_error "バックアップファイルが見つかりません"
        return 1
    fi
    
    log_info "最新のバックアップを使用: $latest_backup"
    
    # 復元の確認
    echo ""
    log_warning "設定を復元しますか？"
    echo "この操作により、現在の設定が上書きされます。"
    echo "続行しますか？ (y/N): "
    
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # 復元の実行
        sudo tar -xzf "$latest_backup" -C /
        
        # SSHサービスの再起動
        sudo systemctl restart sshd
        
        log_success "設定が復元されました"
    else
        log_info "復元がキャンセルされました"
    fi
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps アクセス制御を開始します..."
    
    # ログの設定
    setup_logging
    
    # 管理者権限の確認
    if [[ $EUID -ne 0 ]]; then
        log_error "このスクリプトは管理者権限で実行する必要があります"
        echo "sudo $0 [options] を使用してください"
        exit 1
    fi
    
    # オプションの処理
    if [[ "$SSH_HARDEN" == "true" ]]; then
        backup_configurations
        harden_ssh
    fi
    
    if [[ "$USERS_MANAGE" == "true" ]]; then
        manage_users
    fi
    
    if [[ "$FILES_AUDIT" == "true" ]]; then
        audit_file_permissions
    fi
    
    if [[ "$PERMISSIONS_FIX" == "true" ]]; then
        fix_permissions
    fi
    
    if [[ "$ACCESS_AUDIT" == "true" ]]; then
        audit_access
    fi
    
    if [[ "$BACKUP_CONFIG" == "true" ]]; then
        backup_configurations
    fi
    
    if [[ "$RESTORE_CONFIG" == "true" ]]; then
        restore_configurations
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$SSH_HARDEN" == "false" && "$USERS_MANAGE" == "false" && "$FILES_AUDIT" == "false" && "$PERMISSIONS_FIX" == "false" && "$ACCESS_AUDIT" == "false" && "$BACKUP_CONFIG" == "false" && "$RESTORE_CONFIG" == "false" ]]; then
        log_info "デフォルト動作: 完全なアクセス制御を実行"
        backup_configurations
        harden_ssh
        manage_users
        audit_file_permissions
        fix_permissions
        audit_access
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "アクセス制御が完了しました（実行時間: ${duration}秒）"
    log_info "ログファイル: $LOG_FILE"
    log_info "バックアップディレクトリ: $BACKUP_DIR"
}

# スクリプト実行
main "$@" 