#!/bin/bash

# PostgreSQLデータベース復旧スクリプト
# 使用方法: ./scripts/restore-database.sh [options]

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
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"5432"}
DB_NAME=${DB_NAME:-"teafarmops"}
DB_USER=${DB_USER:-"teafarmops"}
DB_PASSWORD=${DB_PASSWORD:-"password"}

# タイムスタンプ
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ヘルプ表示
show_help() {
    echo "PostgreSQLデータベース復旧スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options] <backup_file>"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -f, --force         強制復旧（確認なし）"
    echo "  -d, --dry-run       ドライラン（実際の復旧は行わない）"
    echo "  -v, --verify        復旧後の検証"
    echo "  -c, --create-db     データベースが存在しない場合は作成"
    echo "  -b, --backup-first  復旧前に現在のデータベースをバックアップ"
    echo ""
    echo "環境変数:"
    echo "  DB_HOST     データベースホスト（デフォルト: localhost）"
    echo "  DB_PORT     データベースポート（デフォルト: 5432）"
    echo "  DB_NAME     データベース名（デフォルト: teafarmops）"
    echo "  DB_USER     データベースユーザー（デフォルト: teafarmops）"
    echo "  DB_PASSWORD データベースパスワード（デフォルト: password）"
    echo ""
    echo "例:"
    echo "  $0 backup_file.sql              # 基本的な復旧"
    echo "  $0 --force backup_file.sql      # 強制復旧"
    echo "  $0 --dry-run backup_file.sql    # ドライラン"
    echo "  $0 --verify backup_file.sql     # 復旧後の検証"
}

# 引数解析
FORCE=false
DRY_RUN=false
VERIFY_RESTORE=false
CREATE_DB=false
BACKUP_FIRST=false
BACKUP_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verify)
            VERIFY_RESTORE=true
            shift
            ;;
        -c|--create-db)
            CREATE_DB=true
            shift
            ;;
        -b|--backup-first)
            BACKUP_FIRST=true
            shift
            ;;
        -*)
            log_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$BACKUP_FILE" ]]; then
                BACKUP_FILE="$1"
            else
                log_error "複数のバックアップファイルが指定されています"
                exit 1
            fi
            shift
            ;;
    esac
done

# バックアップファイルの検証
validate_backup_file() {
    if [[ -z "$BACKUP_FILE" ]]; then
        log_error "バックアップファイルが指定されていません"
        show_help
        exit 1
    fi
    
    if [[ ! -f "$BACKUP_FILE" ]]; then
        log_error "バックアップファイルが見つかりません: $BACKUP_FILE"
        exit 1
    fi
    
    log_success "バックアップファイルが検証されました: $BACKUP_FILE"
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

# データベースの存在確認
check_database_exists() {
    log_info "データベースの存在を確認中..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';" | grep -q 1; then
        log_success "データベースが存在します: $DB_NAME"
        return 0
    else
        log_warning "データベースが存在しません: $DB_NAME"
        return 1
    fi
}

# データベースの作成
create_database() {
    log_info "データベースを作成中: $DB_NAME"
    
    export PGPASSWORD="$DB_PASSWORD"
    
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME;" > /dev/null 2>&1; then
        log_success "データベースが作成されました: $DB_NAME"
        return 0
    else
        log_error "データベースの作成に失敗しました: $DB_NAME"
        return 1
    fi
}

# 復旧前のバックアップ
backup_current_database() {
    if [[ "$BACKUP_FIRST" != "true" ]]; then
        return 0
    fi
    
    log_info "復旧前に現在のデータベースをバックアップ中..."
    
    local backup_file="$BACKUP_DIR/pre_restore_backup_${TIMESTAMP}.sql"
    
    export PGPASSWORD="$DB_PASSWORD"
    
    if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" > "$backup_file" 2>/dev/null; then
        log_success "復旧前バックアップが作成されました: $backup_file"
        return 0
    else
        log_warning "復旧前バックアップの作成に失敗しました"
        return 1
    fi
}

# 復旧の実行
perform_restore() {
    log_info "データベース復旧を実行中..."
    
    local log_file="/tmp/restore_${TIMESTAMP}.log"
    
    export PGPASSWORD="$DB_PASSWORD"
    
    # 圧縮ファイルの場合は解凍
    local restore_file="$BACKUP_FILE"
    if [[ "$BACKUP_FILE" == *.gz ]]; then
        log_info "圧縮ファイルを解凍中..."
        restore_file="/tmp/restore_${TIMESTAMP}.sql"
        gunzip -c "$BACKUP_FILE" > "$restore_file"
    fi
    
    # ドライランの場合
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "ドライラン: 復旧コマンドを表示"
        echo "psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME < $restore_file"
        return 0
    fi
    
    # 実際の復旧実行
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" < "$restore_file" > "$log_file" 2>&1; then
        log_success "データベース復旧が完了しました"
        
        # 一時ファイルの削除
        if [[ "$restore_file" != "$BACKUP_FILE" ]]; then
            rm -f "$restore_file"
        fi
        
        return 0
    else
        log_error "データベース復旧に失敗しました"
        log_error "ログファイル: $log_file"
        
        # 一時ファイルの削除
        if [[ "$restore_file" != "$BACKUP_FILE" ]]; then
            rm -f "$restore_file"
        fi
        
        return 1
    fi
}

# 復旧後の検証
verify_restore() {
    if [[ "$VERIFY_RESTORE" != "true" ]]; then
        return 0
    fi
    
    log_info "復旧後の検証を実行中..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    # テーブルの存在確認
    local table_count=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | tr -d ' ')
    
    if [[ "$table_count" -gt 0 ]]; then
        log_success "復旧検証が成功しました（テーブル数: $table_count）"
        return 0
    else
        log_error "復旧検証に失敗しました（テーブルが見つかりません）"
        return 1
    fi
}

# 確認プロンプト
confirm_restore() {
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    
    echo ""
    log_warning "⚠️  データベース復旧の確認"
    echo "データベース: $DB_NAME@$DB_HOST:$DB_PORT"
    echo "バックアップファイル: $BACKUP_FILE"
    echo ""
    echo "この操作により、現在のデータベースの内容が上書きされます。"
    echo "続行しますか？ (y/N): "
    
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        log_info "復旧がキャンセルされました"
        exit 0
    fi
}

# メイン処理
main() {
    log_info "PostgreSQLデータベース復旧を開始します..."
    log_info "データベース: $DB_NAME@$DB_HOST:$DB_PORT"
    log_info "バックアップファイル: $BACKUP_FILE"
    
    # バックアップファイルの検証
    validate_backup_file
    
    # データベース接続テスト
    if ! test_database_connection; then
        exit 1
    fi
    
    # データベースの存在確認
    if ! check_database_exists; then
        if [[ "$CREATE_DB" == "true" ]]; then
            if ! create_database; then
                exit 1
            fi
        else
            log_error "データベースが存在しません。--create-dbオプションを使用してください。"
            exit 1
        fi
    fi
    
    # 復旧前のバックアップ
    backup_current_database
    
    # 確認プロンプト
    confirm_restore
    
    # 復旧の実行
    if ! perform_restore; then
        exit 1
    fi
    
    # 復旧後の検証
    if ! verify_restore; then
        log_warning "復旧検証に失敗しましたが、復旧は完了しています"
    fi
    
    log_success "データベース復旧が完了しました！"
}

# スクリプト実行
main "$@" 