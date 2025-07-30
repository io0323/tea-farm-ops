#!/bin/bash

# バックアップ自動スケジュール実行スクリプト
# 使用方法: ./scripts/backup-scheduler.sh [options]

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
BACKUP_CONFIG_FILE="/etc/tea-farm-ops/backup-config.yml"
LOG_DIR="/var/log/tea-farm-ops/backup"
LOCK_FILE="/var/run/tea-farm-ops-backup.lock"
NOTIFICATION_WEBHOOK=${SLACK_WEBHOOK_URL:-""}

# タイムスタンプ
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DATE=$(date +%Y-%m-%d)

# ヘルプ表示
show_help() {
    echo "バックアップ自動スケジュール実行スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -c, --config FILE   設定ファイル（デフォルト: $BACKUP_CONFIG_FILE）"
    echo "  -d, --daily         日次バックアップ"
    echo "  -w, --weekly        週次バックアップ"
    echo "  -m, --monthly       月次バックアップ"
    echo "  -f, --force         強制実行（ロックファイルを無視）"
    echo "  -v, --verbose       詳細ログ出力"
    echo "  -t, --test          テストモード（実際のバックアップは実行しない）"
    echo ""
    echo "例:"
    echo "  $0 --daily           # 日次バックアップ"
    echo "  $0 --weekly          # 週次バックアップ"
    echo "  $0 --force --daily   # 強制日次バックアップ"
    echo "  $0 --test --daily    # テストモード"
}

# 引数解析
BACKUP_TYPE=""
FORCE=false
VERBOSE=false
TEST_MODE=false
CONFIG_FILE="$BACKUP_CONFIG_FILE"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -d|--daily)
            BACKUP_TYPE="daily"
            shift
            ;;
        -w|--weekly)
            BACKUP_TYPE="weekly"
            shift
            ;;
        -m|--monthly)
            BACKUP_TYPE="monthly"
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -t|--test)
            TEST_MODE=true
            shift
            ;;
        *)
            log_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
    esac
done

# ロックファイルの管理
acquire_lock() {
    if [[ "$FORCE" == "true" ]]; then
        log_warning "強制モード: ロックファイルを無視します"
        return 0
    fi
    
    if [[ -f "$LOCK_FILE" ]]; then
        local pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log_error "バックアップが既に実行中です（PID: $pid）"
            return 1
        else
            log_warning "古いロックファイルを削除します"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    echo $$ > "$LOCK_FILE"
    log_info "ロックファイルを取得しました（PID: $$）"
}

release_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
        log_info "ロックファイルを解放しました"
    fi
}

# 設定ファイルの読み込み
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_warning "設定ファイルが見つかりません: $CONFIG_FILE"
        log_info "デフォルト設定を使用します"
        return 0
    fi
    
    log_info "設定ファイルを読み込み中: $CONFIG_FILE"
    
    # YAMLファイルを読み込み（簡易的な実装）
    if command -v yq >/dev/null 2>&1; then
        # yqが利用可能な場合
        BACKUP_ENABLED=$(yq eval '.backup.enabled' "$CONFIG_FILE" 2>/dev/null || echo "true")
        DAILY_SCHEDULE=$(yq eval '.backup.schedules.daily' "$CONFIG_FILE" 2>/dev/null || echo "02:00")
        WEEKLY_SCHEDULE=$(yq eval '.backup.schedules.weekly' "$CONFIG_FILE" 2>/dev/null || echo "03:00")
        MONTHLY_SCHEDULE=$(yq eval '.backup.schedules.monthly' "$CONFIG_FILE" 2>/dev/null || echo "04:00")
    else
        # デフォルト値を使用
        BACKUP_ENABLED="true"
        DAILY_SCHEDULE="02:00"
        WEEKLY_SCHEDULE="03:00"
        MONTHLY_SCHEDULE="04:00"
    fi
    
    log_success "設定を読み込みました"
}

# ログディレクトリの作成
setup_logging() {
    mkdir -p "$LOG_DIR"
    
    if [[ "$VERBOSE" == "true" ]]; then
        exec 1> >(tee -a "$LOG_DIR/backup_${BACKUP_TYPE}_${TIMESTAMP}.log")
        exec 2>&1
    else
        exec 1> >(tee -a "$LOG_DIR/backup_${BACKUP_TYPE}_${TIMESTAMP}.log" >/dev/null)
        exec 2>&1
    fi
}

# バックアップ実行
run_backup() {
    local backup_script="$1"
    local backup_args="$2"
    
    log_info "バックアップスクリプトを実行中: $backup_script $backup_args"
    
    if [[ "$TEST_MODE" == "true" ]]; then
        log_info "テストモード: 実際のバックアップは実行しません"
        echo "実行予定: $backup_script $backup_args"
        return 0
    fi
    
    if [[ -f "$backup_script" ]]; then
        if bash "$backup_script" $backup_args; then
            log_success "バックアップが成功しました: $backup_script"
            return 0
        else
            log_error "バックアップが失敗しました: $backup_script"
            return 1
        fi
    else
        log_error "バックアップスクリプトが見つかりません: $backup_script"
        return 1
    fi
}

# 日次バックアップ
perform_daily_backup() {
    log_info "日次バックアップを開始します..."
    
    local success_count=0
    local total_count=0
    
    # データベース差分バックアップ
    total_count=$((total_count + 1))
    if run_backup "./scripts/backup-database.sh" "--differential --verify"; then
        success_count=$((success_count + 1))
    fi
    
    # ファイルバックアップ（設定ファイルのみ）
    total_count=$((total_count + 1))
    if run_backup "./scripts/backup-files.sh" "--config --verify"; then
        success_count=$((success_count + 1))
    fi
    
    # 監視データバックアップ（設定のみ）
    total_count=$((total_count + 1))
    if run_backup "./scripts/backup-monitoring.sh" "--config --verify"; then
        success_count=$((success_count + 1))
    fi
    
    log_info "日次バックアップ完了: $success_count/$total_count 成功"
    return $((total_count - success_count))
}

# 週次バックアップ
perform_weekly_backup() {
    log_info "週次バックアップを開始します..."
    
    local success_count=0
    local total_count=0
    
    # データベース完全バックアップ
    total_count=$((total_count + 1))
    if run_backup "./scripts/backup-database.sh" "--full --verify"; then
        success_count=$((success_count + 1))
    fi
    
    # ファイルバックアップ（全ファイル）
    total_count=$((total_count + 1))
    if run_backup "./scripts/backup-files.sh" "--all --verify"; then
        success_count=$((success_count + 1))
    fi
    
    # 監視データバックアップ（全データ）
    total_count=$((total_count + 1))
    if run_backup "./scripts/backup-monitoring.sh" "--all --verify"; then
        success_count=$((success_count + 1))
    fi
    
    log_info "週次バックアップ完了: $success_count/$total_count 成功"
    return $((total_count - success_count))
}

# 月次バックアップ
perform_monthly_backup() {
    log_info "月次バックアップを開始します..."
    
    local success_count=0
    local total_count=0
    
    # データベース完全バックアップ
    total_count=$((total_count + 1))
    if run_backup "./scripts/backup-database.sh" "--full --verify"; then
        success_count=$((success_count + 1))
    fi
    
    # ファイルバックアップ（全ファイル）
    total_count=$((total_count + 1))
    if run_backup "./scripts/backup-files.sh" "--all --verify"; then
        success_count=$((success_count + 1))
    fi
    
    # 監視データバックアップ（全データ）
    total_count=$((total_count + 1))
    if run_backup "./scripts/backup-monitoring.sh" "--all --verify"; then
        success_count=$((success_count + 1))
    fi
    
    # 古いバックアップのクリーンアップ
    total_count=$((total_count + 1))
    if cleanup_old_backups; then
        success_count=$((success_count + 1))
    fi
    
    log_info "月次バックアップ完了: $success_count/$total_count 成功"
    return $((total_count - success_count))
}

# 古いバックアップのクリーンアップ
cleanup_old_backups() {
    log_info "古いバックアップをクリーンアップ中..."
    
    local retention_days=90  # 月次バックアップは90日保持
    
    # 各バックアップディレクトリの古いファイルを削除
    local backup_dirs=("/backups/database" "/backups/files" "/backups/monitoring")
    local deleted_count=0
    
    for dir in "${backup_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local count=$(find "$dir" -name "*.tar.gz" -o -name "*.sql*" -type f -mtime +$retention_days | wc -l)
            find "$dir" -name "*.tar.gz" -o -name "*.sql*" -type f -mtime +$retention_days -delete
            deleted_count=$((deleted_count + count))
        fi
    done
    
    log_success "古いバックアップを削除しました（$deleted_count個）"
    return 0
}

# 通知送信
send_notification() {
    local status="$1"
    local message="$2"
    local backup_type="$3"
    
    if [[ -z "$NOTIFICATION_WEBHOOK" ]]; then
        log_warning "通知Webhookが設定されていません"
        return 0
    fi
    
    local emoji=""
    local color=""
    
    if [[ "$status" == "success" ]]; then
        emoji="✅"
        color="good"
    else
        emoji="❌"
        color="danger"
    fi
    
    local payload=$(cat << EOF
{
  "text": "$emoji バックアップ通知",
  "attachments": [
    {
      "color": "$color",
      "fields": [
        {
          "title": "ステータス",
          "value": "$status",
          "short": true
        },
        {
          "title": "タイプ",
          "value": "$backup_type",
          "short": true
        },
        {
          "title": "メッセージ",
          "value": "$message",
          "short": false
        }
      ],
      "footer": "TeaFarmOps Backup System",
      "ts": $(date +%s)
    }
  ]
}
EOF
)
    
    if curl -X POST -H 'Content-type: application/json' \
        --data "$payload" "$NOTIFICATION_WEBHOOK" >/dev/null 2>&1; then
        log_success "通知を送信しました"
    else
        log_error "通知の送信に失敗しました"
    fi
}

# バックアップ統計の生成
generate_backup_report() {
    log_info "バックアップレポートを生成中..."
    
    local report_file="$LOG_DIR/backup_report_${BACKUP_TYPE}_${BACKUP_DATE}.json"
    
    # バックアップ統計を収集
    local db_backups=$(find /backups/database -name "*.sql*" -type f | wc -l)
    local file_backups=$(find /backups/files -name "*.tar.gz" -type f | wc -l)
    local monitoring_backups=$(find /backups/monitoring -name "*.tar.gz" -type f | wc -l)
    
    local total_size=$(du -sh /backups 2>/dev/null | cut -f1 || echo "0")
    
    cat > "$report_file" << EOF
{
  "date": "$BACKUP_DATE",
  "timestamp": "$TIMESTAMP",
  "backup_type": "$BACKUP_TYPE",
  "statistics": {
    "database_backups": $db_backups,
    "file_backups": $file_backups,
    "monitoring_backups": $monitoring_backups,
    "total_size": "$total_size"
  },
  "system_info": {
    "hostname": "$(hostname)",
    "disk_usage": "$(df -h /backups | tail -1 | awk '{print $5}')"
  }
}
EOF
    
    log_success "バックアップレポートが生成されました: $report_file"
}

# メイン処理
main() {
    local start_time=$(date +%s)
    local exit_code=0
    
    log_info "バックアップスケジューラーを開始します..."
    log_info "バックアップタイプ: $BACKUP_TYPE"
    log_info "設定ファイル: $CONFIG_FILE"
    
    # ロックファイルの取得
    if ! acquire_lock; then
        exit 1
    fi
    
    # 終了時のクリーンアップ
    trap 'release_lock; exit $exit_code' EXIT INT TERM
    
    # 設定の読み込み
    load_config
    
    # ログの設定
    setup_logging
    
    # バックアップタイプの確認
    if [[ -z "$BACKUP_TYPE" ]]; then
        log_error "バックアップタイプが指定されていません"
        show_help
        exit 1
    fi
    
    # バックアップ実行
    case $BACKUP_TYPE in
        "daily")
            if perform_daily_backup; then
                log_success "日次バックアップが完了しました"
                send_notification "success" "日次バックアップが正常に完了しました" "daily"
            else
                log_error "日次バックアップでエラーが発生しました"
                send_notification "failure" "日次バックアップでエラーが発生しました" "daily"
                exit_code=1
            fi
            ;;
        "weekly")
            if perform_weekly_backup; then
                log_success "週次バックアップが完了しました"
                send_notification "success" "週次バックアップが正常に完了しました" "weekly"
            else
                log_error "週次バックアップでエラーが発生しました"
                send_notification "failure" "週次バックアップでエラーが発生しました" "weekly"
                exit_code=1
            fi
            ;;
        "monthly")
            if perform_monthly_backup; then
                log_success "月次バックアップが完了しました"
                send_notification "success" "月次バックアップが正常に完了しました" "monthly"
            else
                log_error "月次バックアップでエラーが発生しました"
                send_notification "failure" "月次バックアップでエラーが発生しました" "monthly"
                exit_code=1
            fi
            ;;
        *)
            log_error "不明なバックアップタイプ: $BACKUP_TYPE"
            exit_code=1
            ;;
    esac
    
    # バックアップレポートの生成
    generate_backup_report
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local message="バックアップが完了しました（実行時間: ${duration}秒）"
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "$message"
    else
        log_error "$message（エラーあり）"
    fi
    
    exit $exit_code
}

# スクリプト実行
main "$@" 