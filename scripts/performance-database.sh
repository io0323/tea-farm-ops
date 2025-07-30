#!/bin/bash

# TeaFarmOps パフォーマンス最適化 - データベース最適化
# 使用方法: ./scripts/performance-database.sh [options]

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
DB_CONFIG="/etc/tea-farm-ops/database-config.yml"
LOG_FILE="/var/log/tea-farm-ops/performance/database.log"
POSTGRESQL_CONFIG="/etc/postgresql/*/main/postgresql.conf"
POSTGRESQL_HBA="/etc/postgresql/*/main/pg_hba.conf"

# データベース接続設定
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="teafarmops"
DB_USER="teafarmops"
DB_PASSWORD="${DB_PASSWORD:-teafarmops_2024}"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps データベース最適化スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -a, --analyze       テーブル分析"
    echo "  -v, --vacuum        VACUUM実行"
    echo "  -i, --index         インデックス最適化"
    echo "  -c, --configure     設定最適化"
    echo "  -m, --monitor       パフォーマンス監視"
    echo "  -t, --test          パフォーマンステスト"
    echo "  -o, --optimize      包括的最適化"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --analyze         # テーブル分析"
    echo "  $0 --optimize        # 包括的最適化"
    echo "  $0 --monitor         # パフォーマンス監視"
}

# 引数解析
ANALYZE=false
VACUUM=false
INDEX=false
CONFIGURE=false
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
        -a|--analyze)
            ANALYZE=true
            shift
            ;;
        -v|--vacuum)
            VACUUM=true
            shift
            ;;
        -i|--index)
            INDEX=true
            shift
            ;;
        -c|--configure)
            CONFIGURE=true
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
        --verbose)
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

# データベース接続テスト
test_connection() {
    log_info "データベース接続をテスト中..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
        log_success "データベース接続が成功しました"
        return 0
    else
        log_error "データベース接続に失敗しました"
        return 1
    fi
}

# テーブル分析
analyze_tables() {
    log_info "テーブル分析を実行中..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    echo ""
    echo "=== テーブル統計情報 ==="
    
    # テーブル一覧と統計情報
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            attname,
            n_distinct,
            correlation,
            most_common_vals,
            most_common_freqs
        FROM pg_stats 
        WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
        ORDER BY schemaname, tablename, attname;
    "
    
    echo ""
    echo "=== テーブルサイズ情報 ==="
    
    # テーブルサイズ
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
            pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as index_size
        FROM pg_tables 
        WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
        ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
    "
    
    # ANALYZEの実行
    echo ""
    echo "=== ANALYZE実行中 ==="
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "ANALYZE;"
    
    log_success "テーブル分析が完了しました"
}

# VACUUM実行
vacuum_database() {
    log_info "VACUUMを実行中..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    echo ""
    echo "=== VACUUM実行前の状態 ==="
    
    # デッドタプル情報
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            n_dead_tup,
            n_live_tup,
            round(n_dead_tup * 100.0 / nullif(n_live_tup + n_dead_tup, 0), 2) as dead_percentage
        FROM pg_stat_user_tables 
        WHERE n_dead_tup > 0
        ORDER BY dead_percentage DESC;
    "
    
    echo ""
    echo "=== VACUUM実行中 ==="
    
    # VACUUM ANALYZEの実行
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "VACUUM ANALYZE;"
    
    echo ""
    echo "=== VACUUM実行後の状態 ==="
    
    # 実行後の状態確認
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            n_dead_tup,
            n_live_tup,
            round(n_dead_tup * 100.0 / nullif(n_live_tup + n_dead_tup, 0), 2) as dead_percentage
        FROM pg_stat_user_tables 
        ORDER BY n_dead_tup DESC;
    "
    
    log_success "VACUUMが完了しました"
}

# インデックス最適化
optimize_indexes() {
    log_info "インデックス最適化を実行中..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    echo ""
    echo "=== インデックス使用状況 ==="
    
    # インデックス使用統計
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            indexname,
            idx_scan,
            idx_tup_read,
            idx_tup_fetch,
            pg_size_pretty(pg_relation_size(indexrelid)) as index_size
        FROM pg_stat_user_indexes 
        ORDER BY idx_scan DESC;
    "
    
    echo ""
    echo "=== 未使用インデックス ==="
    
    # 未使用インデックスの検出
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            indexname,
            pg_size_pretty(pg_relation_size(indexrelid)) as index_size
        FROM pg_stat_user_indexes 
        WHERE idx_scan = 0
        ORDER BY pg_relation_size(indexrelid) DESC;
    "
    
    echo ""
    echo "=== 重複インデックス ==="
    
    # 重複インデックスの検出
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            t.schemaname,
            t.tablename,
            array_agg(i.indexname) as duplicate_indexes
        FROM pg_indexes i
        JOIN pg_indexes t ON i.tablename = t.tablename 
            AND i.schemaname = t.schemaname
            AND i.indexdef = t.indexdef
        WHERE i.indexname != t.indexname
        GROUP BY t.schemaname, t.tablename
        HAVING count(*) > 1;
    "
    
    # インデックス再構築
    echo ""
    echo "=== インデックス再構築中 ==="
    
    # 主要なインデックスの再構築
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 'REINDEX INDEX ' || schemaname || '.' || indexname || ';'
        FROM pg_stat_user_indexes 
        WHERE idx_scan > 1000
        ORDER BY idx_scan DESC
        LIMIT 10;
    " | grep "REINDEX" | while read reindex_cmd; do
        echo "実行中: $reindex_cmd"
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "$reindex_cmd"
    done
    
    log_success "インデックス最適化が完了しました"
}

# PostgreSQL設定最適化
configure_postgresql() {
    log_info "PostgreSQL設定を最適化中..."
    
    # 設定ファイルの検索
    local config_file=$(find /etc/postgresql -name "postgresql.conf" 2>/dev/null | head -1)
    
    if [[ -z "$config_file" ]]; then
        log_error "PostgreSQL設定ファイルが見つかりません"
        return 1
    fi
    
    # 設定ファイルのバックアップ
    sudo cp "$config_file" "${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    echo ""
    echo "=== 現在の設定 ==="
    
    # 現在の設定値を確認
    local current_settings=(
        "shared_buffers"
        "effective_cache_size"
        "work_mem"
        "maintenance_work_mem"
        "checkpoint_completion_target"
        "wal_buffers"
        "default_statistics_target"
        "random_page_cost"
        "effective_io_concurrency"
        "max_connections"
    )
    
    for setting in "${current_settings[@]}"; do
        local value=$(grep "^$setting" "$config_file" | cut -d'=' -f2 | tr -d ' ' || echo "未設定")
        echo "$setting = $value"
    done
    
    echo ""
    echo "=== 最適化設定の適用 ==="
    
    # システムメモリの取得
    local total_memory=$(free -m | awk 'NR==2{printf "%.0f", $2}')
    local shared_buffers=$((total_memory * 25 / 100))
    local effective_cache_size=$((total_memory * 75 / 100))
    local work_mem=$((total_memory * 2 / 100))
    local maintenance_work_mem=$((total_memory * 5 / 100))
    
    # 設定の更新
    sudo sed -i "s/^#*shared_buffers.*/shared_buffers = ${shared_buffers}MB/" "$config_file"
    sudo sed -i "s/^#*effective_cache_size.*/effective_cache_size = ${effective_cache_size}MB/" "$config_file"
    sudo sed -i "s/^#*work_mem.*/work_mem = ${work_mem}MB/" "$config_file"
    sudo sed -i "s/^#*maintenance_work_mem.*/maintenance_work_mem = ${maintenance_work_mem}MB/" "$config_file"
    sudo sed -i "s/^#*checkpoint_completion_target.*/checkpoint_completion_target = 0.9/" "$config_file"
    sudo sed -i "s/^#*wal_buffers.*/wal_buffers = 16MB/" "$config_file"
    sudo sed -i "s/^#*default_statistics_target.*/default_statistics_target = 100/" "$config_file"
    sudo sed -i "s/^#*random_page_cost.*/random_page_cost = 1.1/" "$config_file"
    sudo sed -i "s/^#*effective_io_concurrency.*/effective_io_concurrency = 200/" "$config_file"
    
    echo "システムメモリ: ${total_memory}MB"
    echo "shared_buffers: ${shared_buffers}MB"
    echo "effective_cache_size: ${effective_cache_size}MB"
    echo "work_mem: ${work_mem}MB"
    echo "maintenance_work_mem: ${maintenance_work_mem}MB"
    
    # PostgreSQLサービスの再起動
    echo ""
    echo "=== PostgreSQLサービスの再起動 ==="
    sudo systemctl restart postgresql
    
    log_success "PostgreSQL設定最適化が完了しました"
}

# パフォーマンス監視
monitor_performance() {
    log_info "データベースパフォーマンスを監視中..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    echo ""
    echo "=== 接続情報 ==="
    
    # アクティブ接続数
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            count(*) as active_connections,
            count(*) * 100.0 / max_conn as connection_percentage
        FROM pg_stat_activity, (SELECT setting::int as max_conn FROM pg_settings WHERE name = 'max_connections') as max_connections;
    "
    
    echo ""
    echo "=== クエリ統計 ==="
    
    # クエリ統計
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            datname,
            numbackends,
            xact_commit,
            xact_rollback,
            blks_read,
            blks_hit,
            round(blks_hit * 100.0 / nullif(blks_hit + blks_read, 0), 2) as cache_hit_ratio
        FROM pg_stat_database 
        WHERE datname = '$DB_NAME';
    "
    
    echo ""
    echo "=== テーブルアクセス統計 ==="
    
    # テーブルアクセス統計
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            schemaname,
            tablename,
            seq_scan,
            seq_tup_read,
            idx_scan,
            idx_tup_fetch,
            n_tup_ins,
            n_tup_upd,
            n_tup_del,
            n_live_tup,
            n_dead_tup
        FROM pg_stat_user_tables 
        ORDER BY seq_scan + idx_scan DESC;
    "
    
    echo ""
    echo "=== スロークエリ ==="
    
    # スロークエリの検出（log_statementがallの場合）
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SHOW log_statement;" | grep -q "all"; then
        echo "スロークエリログが有効です"
        sudo tail -20 /var/log/postgresql/postgresql-*.log | grep "duration:"
    else
        echo "スロークエリログが無効です"
    fi
    
    echo ""
    echo "=== ロック情報 ==="
    
    # ロック情報
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT 
            locktype,
            database,
            relation::regclass,
            page,
            tuple,
            virtualxid,
            transactionid,
            classid,
            objid,
            objsubid,
            virtualtransaction,
            pid,
            mode,
            granted
        FROM pg_locks 
        WHERE NOT granted;
    "
}

# パフォーマンステスト
performance_test() {
    log_info "データベースパフォーマンステストを実行中..."
    
    export PGPASSWORD="$DB_PASSWORD"
    
    echo ""
    echo "=== 読み取りパフォーマンステスト ==="
    
    # 読み取りテスト
    local start_time=$(date +%s%N)
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        SELECT count(*) FROM (
            SELECT * FROM pg_tables 
            WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
            LIMIT 1000
        ) as test_query;
    " >/dev/null 2>&1
    local end_time=$(date +%s%N)
    local read_time=$(( (end_time - start_time) / 1000000 ))
    echo "読み取りテスト: ${read_time}ms"
    
    echo ""
    echo "=== 書き込みパフォーマンステスト ==="
    
    # テストテーブルの作成
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        CREATE TEMP TABLE perf_test (
            id SERIAL PRIMARY KEY,
            data TEXT,
            created_at TIMESTAMP DEFAULT NOW()
        );
    " >/dev/null 2>&1
    
    # 書き込みテスト
    start_time=$(date +%s%N)
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        INSERT INTO perf_test (data) 
        SELECT 'test_data_' || generate_series(1, 1000);
    " >/dev/null 2>&1
    end_time=$(date +%s%N)
    local write_time=$(( (end_time - start_time) / 1000000 ))
    echo "書き込みテスト: 1000件を ${write_time}ms で完了"
    
    # クリーンアップ
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "DROP TABLE perf_test;" >/dev/null 2>&1
    
    echo ""
    echo "=== インデックスパフォーマンステスト ==="
    
    # インデックス効果のテスト
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        EXPLAIN (ANALYZE, BUFFERS) 
        SELECT * FROM pg_tables 
        WHERE schemaname = 'public' 
        LIMIT 10;
    "
}

# 包括的最適化
comprehensive_optimization() {
    log_info "包括的データベース最適化を実行中..."
    
    # 接続テスト
    if ! test_connection; then
        return 1
    fi
    
    # 各最適化の実行
    analyze_tables
    vacuum_database
    optimize_indexes
    configure_postgresql
    
    echo ""
    echo "=== 最適化後のパフォーマンス確認 ==="
    monitor_performance
    
    log_success "包括的データベース最適化が完了しました"
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps データベース最適化を開始します..."
    
    # ログの設定
    setup_logging
    
    # 管理者権限の確認
    if [[ $EUID -ne 0 ]]; then
        log_warning "一部の操作は管理者権限が必要です"
    fi
    
    # オプションの処理
    if [[ "$ANALYZE" == "true" ]]; then
        analyze_tables
    fi
    
    if [[ "$VACUUM" == "true" ]]; then
        vacuum_database
    fi
    
    if [[ "$INDEX" == "true" ]]; then
        optimize_indexes
    fi
    
    if [[ "$CONFIGURE" == "true" ]]; then
        configure_postgresql
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
    if [[ "$ANALYZE" == "false" && "$VACUUM" == "false" && "$INDEX" == "false" && "$CONFIGURE" == "false" && "$MONITOR" == "false" && "$TEST" == "false" && "$OPTIMIZE" == "false" ]]; then
        log_info "デフォルト動作: 包括的最適化を実行"
        comprehensive_optimization
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "データベース最適化が完了しました（実行時間: ${duration}秒）"
    log_info "ログファイル: $LOG_FILE"
}

# スクリプト実行
main "$@" 