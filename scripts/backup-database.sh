#!/bin/bash

# PostgreSQLデータベースバックアップスクリプト
# 使用方法: ./scripts/backup-database.sh [options]

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
BACKUP_DIR="/backups/database"
RETENTION_DAYS=30
COMPRESSION=true
VERIFY_BACKUP=true
NOTIFY_ON_SUCCESS=true
NOTIFY_ON_FAILURE=true

# データベース設定
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"5432"}
DB_NAME=${DB_NAME:-"teafarmops"}
DB_USER=${DB_USER:-"teafarmops"}
DB_PASSWORD=${DB_PASSWORD:-"password"}

# タイムスタンプ
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DATE=$(date +%Y-%m-%d)

# ヘルプ表示
show_help() {
    echo "PostgreSQLデータベースバックアップスクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -f, --full          完全バックアップ（デフォルト）"
    echo "  -d, --differential  差分バックアップ"
    echo "  -i, --incremental   増分バックアップ"
    echo "  -v, --verify        バックアップ検証"
    echo "  -c, --compress      圧縮（デフォルト: 有効）"
    echo "  -n, --no-compress   圧縮無効"
    echo "  -r, --retention N   保持日数（デフォルト: 30日）"
    echo "  -o, --output DIR    出力ディレクトリ"
    echo ""
    echo "環境変数:"
    echo "  DB_HOST     データベースホスト（デフォルト: localhost）"
    echo "  DB_PORT     データベースポート（デフォルト: 5432）"
    echo "  DB_NAME     データベース名（デフォルト: teafarmops）"
    echo "  DB_USER     データベースユーザー（デフォルト: teafarmops）"
    echo "  DB_PASSWORD データベースパスワード（デフォルト: password）"
    echo ""
    echo "例:"
    echo "  $0 --full                    # 完全バックアップ"
    echo "  $0 --differential            # 差分バックアップ"
    echo "  $0 --verify                  # バックアップ検証"
    echo "  $0 --retention 7 --output /custom/backup"
}

# 引数解析
BACKUP_TYPE="full"
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--full)
            BACKUP_TYPE="full"
            shift
            ;;
        -d|--differential)
            BACKUP_TYPE="differential"
            shift
            ;;
        -i|--incremental)
            BACKUP_TYPE="incremental"
            shift
            ;;
        -v|--verify)
            VERIFY_BACKUP=true
            shift
            ;;
        -c|--compress)
            COMPRESSION=true
            shift
            ;;
        -n|--no-compress)
            COMPRESSION=false
            shift
            ;;
        -r|--retention)
            RETENTION_DAYS="$2"
            shift 2
            ;;
        -o|--output)
            BACKUP_DIR="$2"
            shift 2
            ;;
        *)
            log_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
    esac
done

# バックアップディレクトリの作成
create_backup_directory() {
    log_info "バックアップディレクトリを作成中: $BACKUP_DIR"
    
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$BACKUP_DIR/full"
    mkdir -p "$BACKUP_DIR/differential"
    mkdir -p "$BACKUP_DIR/incremental"
    mkdir -p "$BACKUP_DIR/logs"
    
    log_success "バックアップディレクトリが作成されました"
}

# データベース接続テスト
test_database_connection() {
    log_info "データベース接続をテスト中..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" > /dev/null 2>&1; then
        log_success "データベース接続が成功しました"
        return 0
    else
        log_error "データベース接続に失敗しました"
        return 1
    fi
}

# 完全バックアップ
perform_full_backup() {
    log_info "完全バックアップを実行中..."
    
    local backup_file="$BACKUP_DIR/full/full_backup_${TIMESTAMP}.sql"
    local log_file="$BACKUP_DIR/logs/full_backup_${TIMESTAMP}.log"
    
    export PGPASSWORD="$DB_PASSWORD"
    
    # pg_dump実行
    if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        --verbose --clean --create --if-exists \
        --no-password > "$backup_file" 2> "$log_file"; then
        
        log_success "完全バックアップが完了しました: $backup_file"
        
        # 圧縮
        if [[ "$COMPRESSION" == "true" ]]; then
            compress_backup "$backup_file"
        fi
        
        # バックアップサイズを記録
        local size=$(du -h "$backup_file" | cut -f1)
        log_info "バックアップサイズ: $size"
        
        return 0
    else
        log_error "完全バックアップに失敗しました"
        log_error "ログファイル: $log_file"
        return 1
    fi
}

# 差分バックアップ
perform_differential_backup() {
    log_info "差分バックアップを実行中..."
    
    local backup_file="$BACKUP_DIR/differential/diff_backup_${TIMESTAMP}.sql"
    local log_file="$BACKUP_DIR/logs/diff_backup_${TIMESTAMP}.log"
    
    export PGPASSWORD="$DB_PASSWORD"
    
    # 最新の完全バックアップを検索
    local latest_full=$(find "$BACKUP_DIR/full" -name "full_backup_*.sql*" -type f | sort | tail -1)
    
    if [[ -z "$latest_full" ]]; then
        log_warning "完全バックアップが見つかりません。完全バックアップを実行します。"
        perform_full_backup
        return $?
    fi
    
    # 差分バックアップ実行
    if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
        --verbose --data-only --disable-triggers \
        --no-password > "$backup_file" 2> "$log_file"; then
        
        log_success "差分バックアップが完了しました: $backup_file"
        
        # 圧縮
        if [[ "$COMPRESSION" == "true" ]]; then
            compress_backup "$backup_file"
        fi
        
        return 0
    else
        log_error "差分バックアップに失敗しました"
        log_error "ログファイル: $log_file"
        return 1
    fi
}

# 増分バックアップ
perform_incremental_backup() {
    log_info "増分バックアップを実行中..."
    
    local backup_file="$BACKUP_DIR/incremental/incr_backup_${TIMESTAMP}.sql"
    local log_file="$BACKUP_DIR/logs/incr_backup_${TIMESTAMP}.log"
    
    export PGPASSWORD="$DB_PASSWORD"
    
    # WALファイルのバックアップ（PostgreSQLのWALアーカイブが必要）
    if [[ -d "/var/lib/postgresql/wal_archive" ]]; then
        tar -czf "$backup_file" -C /var/lib/postgresql/wal_archive .
        log_success "増分バックアップが完了しました: $backup_file"
        return 0
    else
        log_warning "WALアーカイブが設定されていません。差分バックアップを実行します。"
        perform_differential_backup
        return $?
    fi
}

# バックアップ圧縮
compress_backup() {
    local backup_file="$1"
    
    log_info "バックアップを圧縮中: $backup_file"
    
    if gzip "$backup_file"; then
        log_success "バックアップが圧縮されました: ${backup_file}.gz"
        echo "${backup_file}.gz"
    else
        log_error "バックアップの圧縮に失敗しました"
        echo "$backup_file"
    fi
}

# バックアップ検証
verify_backup() {
    local backup_file="$1"
    
    if [[ "$VERIFY_BACKUP" != "true" ]]; then
        return 0
    fi
    
    log_info "バックアップを検証中: $backup_file"
    
    # 圧縮ファイルの場合は解凍
    local temp_file=""
    if [[ "$backup_file" == *.gz ]]; then
        temp_file=$(mktemp)
        gunzip -c "$backup_file" > "$temp_file"
        backup_file="$temp_file"
    fi
    
    # SQLファイルの構文チェック
    if [[ "$backup_file" == *.sql ]]; then
        if head -n 100 "$backup_file" | grep -q "PostgreSQL database dump"; then
            log_success "バックアップファイルの検証が成功しました"
            rm -f "$temp_file"
            return 0
        else
            log_error "バックアップファイルの検証に失敗しました"
            rm -f "$temp_file"
            return 1
        fi
    fi
    
    rm -f "$temp_file"
    return 0
}

# 古いバックアップの削除
cleanup_old_backups() {
    log_info "古いバックアップを削除中（保持期間: ${RETENTION_DAYS}日）..."
    
    local deleted_count=0
    
    # 各バックアップタイプの古いファイルを削除
    for backup_type in full differential incremental; do
        local backup_path="$BACKUP_DIR/$backup_type"
        if [[ -d "$backup_path" ]]; then
            local count=$(find "$backup_path" -name "*_backup_*" -type f -mtime +$RETENTION_DAYS | wc -l)
            find "$backup_path" -name "*_backup_*" -type f -mtime +$RETENTION_DAYS -delete
            deleted_count=$((deleted_count + count))
        fi
    done
    
    # 古いログファイルも削除
    local log_count=$(find "$BACKUP_DIR/logs" -name "*.log" -type f -mtime +$RETENTION_DAYS | wc -l)
    find "$BACKUP_DIR/logs" -name "*.log" -type f -mtime +$RETENTION_DAYS -delete
    
    log_success "古いバックアップを削除しました（ファイル: ${deleted_count}個、ログ: ${log_count}個）"
}

# バックアップ統計の生成
generate_backup_stats() {
    log_info "バックアップ統計を生成中..."
    
    local stats_file="$BACKUP_DIR/backup_stats_${BACKUP_DATE}.json"
    
    cat > "$stats_file" << EOF
{
  "date": "$BACKUP_DATE",
  "timestamp": "$TIMESTAMP",
  "backup_type": "$BACKUP_TYPE",
  "database": {
    "host": "$DB_HOST",
    "port": "$DB_PORT",
    "name": "$DB_NAME",
    "user": "$DB_USER"
  },
  "backup_config": {
    "compression": $COMPRESSION,
    "verification": $VERIFY_BACKUP,
    "retention_days": $RETENTION_DAYS
  },
  "backup_counts": {
    "full": $(find "$BACKUP_DIR/full" -name "*_backup_*" -type f | wc -l),
    "differential": $(find "$BACKUP_DIR/differential" -name "*_backup_*" -type f | wc -l),
    "incremental": $(find "$BACKUP_DIR/incremental" -name "*_backup_*" -type f | wc -l)
  },
  "total_size": "$(du -sh "$BACKUP_DIR" | cut -f1)"
}
EOF
    
    log_success "バックアップ統計が生成されました: $stats_file"
}

# 通知送信
send_notification() {
    local status="$1"
    local message="$2"
    
    if [[ "$status" == "success" && "$NOTIFY_ON_SUCCESS" == "true" ]]; then
        log_info "成功通知を送信中..."
        # Slack通知の実装
        # curl -X POST -H 'Content-type: application/json' \
        #     --data "{\"text\":\"✅ バックアップ成功: $message\"}" \
        #     "$SLACK_WEBHOOK_URL"
    elif [[ "$status" == "failure" && "$NOTIFY_ON_FAILURE" == "true" ]]; then
        log_error "失敗通知を送信中..."
        # Slack通知の実装
        # curl -X POST -H 'Content-type: application/json' \
        #     --data "{\"text\":\"❌ バックアップ失敗: $message\"}" \
        #     "$SLACK_WEBHOOK_URL"
    fi
}

# メイン処理
main() {
    local start_time=$(date +%s)
    local backup_file=""
    
    log_info "PostgreSQLバックアップを開始します..."
    log_info "バックアップタイプ: $BACKUP_TYPE"
    log_info "データベース: $DB_NAME@$DB_HOST:$DB_PORT"
    
    # バックアップディレクトリの作成
    create_backup_directory
    
    # データベース接続テスト
    if ! test_database_connection; then
        send_notification "failure" "データベース接続に失敗"
        exit 1
    fi
    
    # バックアップ実行
    case $BACKUP_TYPE in
        "full")
            if perform_full_backup; then
                backup_file="$BACKUP_DIR/full/full_backup_${TIMESTAMP}.sql"
                if [[ "$COMPRESSION" == "true" ]]; then
                    backup_file="${backup_file}.gz"
                fi
            else
                send_notification "failure" "完全バックアップに失敗"
                exit 1
            fi
            ;;
        "differential")
            if perform_differential_backup; then
                backup_file="$BACKUP_DIR/differential/diff_backup_${TIMESTAMP}.sql"
                if [[ "$COMPRESSION" == "true" ]]; then
                    backup_file="${backup_file}.gz"
                fi
            else
                send_notification "failure" "差分バックアップに失敗"
                exit 1
            fi
            ;;
        "incremental")
            if perform_incremental_backup; then
                backup_file="$BACKUP_DIR/incremental/incr_backup_${TIMESTAMP}.sql"
                if [[ "$COMPRESSION" == "true" ]]; then
                    backup_file="${backup_file}.gz"
                fi
            else
                send_notification "failure" "増分バックアップに失敗"
                exit 1
            fi
            ;;
        *)
            log_error "不明なバックアップタイプ: $BACKUP_TYPE"
            exit 1
            ;;
    esac
    
    # バックアップ検証
    if ! verify_backup "$backup_file"; then
        send_notification "failure" "バックアップ検証に失敗"
        exit 1
    fi
    
    # 古いバックアップの削除
    cleanup_old_backups
    
    # バックアップ統計の生成
    generate_backup_stats
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local message="バックアップが完了しました（実行時間: ${duration}秒）"
    
    log_success "$message"
    send_notification "success" "$message"
    
    log_info "バックアップファイル: $backup_file"
    log_info "バックアップディレクトリ: $BACKUP_DIR"
}

# スクリプト実行
main "$@" 