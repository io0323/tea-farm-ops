#!/bin/bash

# TeaFarmOps パフォーマンス最適化 - キャッシュシステム
# 使用方法: ./scripts/performance-cache.sh [options]

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
CACHE_CONFIG="/etc/tea-farm-ops/cache-config.yml"
LOG_FILE="/var/log/tea-farm-ops/performance/cache.log"
REDIS_CONFIG="/etc/redis/redis.conf"
REDIS_SENTINEL_CONFIG="/etc/redis/sentinel.conf"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps キャッシュシステム管理スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -i, --install       Redisのインストール"
    echo "  -c, --configure     Redisの設定"
    echo "  -s, --start         Redisサービスの開始"
    echo "  -t, --test          キャッシュのテスト"
    echo "  -m, --monitor       キャッシュの監視"
    echo "  -o, --optimize      キャッシュの最適化"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --install         # Redisインストール"
    echo "  $0 --configure       # Redis設定"
    echo "  $0 --test            # キャッシュテスト"
}

# 引数解析
INSTALL=false
CONFIGURE=false
START=false
TEST=false
MONITOR=false
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
        -s|--start)
            START=true
            shift
            ;;
        -t|--test)
            TEST=true
            shift
            ;;
        -m|--monitor)
            MONITOR=true
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

# Redisのインストール
install_redis() {
    log_info "Redisをインストール中..."
    
    if command -v redis-server >/dev/null 2>&1; then
        log_success "Redisは既にインストールされています"
        return 0
    fi
    
    # パッケージマネージャーの確認
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y redis-server redis-tools
    elif command -v yum >/dev/null 2>&1; then
        # CentOS/RHEL
        sudo yum install -y redis
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        sudo dnf install -y redis
    else
        log_error "サポートされていないパッケージマネージャーです"
        return 1
    fi
    
    log_success "Redisがインストールされました"
}

# Redisの設定
configure_redis() {
    log_info "Redisを設定中..."
    
    # 設定ファイルのバックアップ
    if [[ -f "$REDIS_CONFIG" ]]; then
        sudo cp "$REDIS_CONFIG" "${REDIS_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Redis設定の最適化
    sudo tee "$REDIS_CONFIG" > /dev/null << EOF
# TeaFarmOps Redis設定 - パフォーマンス最適化

# ネットワーク設定
bind 127.0.0.1
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300

# 一般設定
daemonize yes
supervised systemd
pidfile /var/run/redis/redis-server.pid
loglevel notice
logfile /var/log/redis/redis-server.log
databases 16

# スナップショット設定
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /var/lib/redis

# レプリケーション設定
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-ping-replica-period 10
repl-timeout 60
repl-disable-tcp-nodelay no
repl-backlog-size 1mb
repl-backlog-ttl 3600

# セキュリティ設定
requirepass ${REDIS_PASSWORD:-teafarmops_redis_2024}
maxclients 10000

# メモリ管理
maxmemory 256mb
maxmemory-policy allkeys-lru
maxmemory-samples 5

# 遅延監視
latency-monitor-threshold 100

# 遅延ログ
slowlog-log-slower-than 10000
slowlog-max-len 128

# イベント通知
notify-keyspace-events ""

# 高度な設定
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100

# アクティブ再構成
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
EOF
    
    # Redisディレクトリの作成
    sudo mkdir -p /var/lib/redis
    sudo mkdir -p /var/log/redis
    sudo chown redis:redis /var/lib/redis
    sudo chown redis:redis /var/log/redis
    
    # Redisサービスの有効化
    sudo systemctl enable redis-server
    
    log_success "Redis設定が完了しました"
}

# Redis Sentinelの設定（高可用性）
configure_redis_sentinel() {
    log_info "Redis Sentinelを設定中..."
    
    # Sentinel設定ファイルの作成
    sudo tee "$REDIS_SENTINEL_CONFIG" > /dev/null << EOF
# TeaFarmOps Redis Sentinel設定

port 26379
daemonize yes
pidfile /var/run/redis/redis-sentinel.pid
logfile /var/log/redis/redis-sentinel.log
loglevel notice

# 監視設定
sentinel monitor mymaster 127.0.0.1 6379 2
sentinel auth-pass mymaster ${REDIS_PASSWORD:-teafarmops_redis_2024}
sentinel down-after-milliseconds mymaster 5000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 10000
sentinel notification-script mymaster /etc/redis/notify.sh

# 追加設定
sentinel deny-scripts-reconfig yes
EOF
    
    # Sentinelサービスの有効化
    sudo systemctl enable redis-sentinel
    
    log_success "Redis Sentinel設定が完了しました"
}

# Redisサービスの開始
start_redis() {
    log_info "Redisサービスを開始中..."
    
    # Redisサービスの開始
    sudo systemctl start redis-server
    
    # サービスの状態確認
    if sudo systemctl is-active --quiet redis-server; then
        log_success "Redisサービスが開始されました"
    else
        log_error "Redisサービスの開始に失敗しました"
        return 1
    fi
    
    # Sentinelサービスの開始（設定されている場合）
    if [[ -f "$REDIS_SENTINEL_CONFIG" ]]; then
        sudo systemctl start redis-sentinel
        if sudo systemctl is-active --quiet redis-sentinel; then
            log_success "Redis Sentinelサービスが開始されました"
        fi
    fi
}

# キャッシュのテスト
test_cache() {
    log_info "キャッシュをテスト中..."
    
    # Redis接続テスト
    if command -v redis-cli >/dev/null 2>&1; then
        echo ""
        echo "=== Redis接続テスト ==="
        
        # 基本的な接続テスト
        if redis-cli ping | grep -q "PONG"; then
            log_success "Redis接続が成功しました"
        else
            log_error "Redis接続に失敗しました"
            return 1
        fi
        
        # パフォーマンステスト
        echo ""
        echo "=== パフォーマンステスト ==="
        
        # 書き込みテスト
        local start_time=$(date +%s%N)
        for i in {1..1000}; do
            redis-cli set "test_key_$i" "test_value_$i" >/dev/null 2>&1
        done
        local end_time=$(date +%s%N)
        local write_time=$(( (end_time - start_time) / 1000000 ))
        echo "書き込みテスト: 1000件を ${write_time}ms で完了"
        
        # 読み取りテスト
        start_time=$(date +%s%N)
        for i in {1..1000}; do
            redis-cli get "test_key_$i" >/dev/null 2>&1
        done
        end_time=$(date +%s%N)
        local read_time=$(( (end_time - start_time) / 1000000 ))
        echo "読み取りテスト: 1000件を ${read_time}ms で完了"
        
        # クリーンアップ
        redis-cli flushdb >/dev/null 2>&1
        
        # メモリ使用量の確認
        echo ""
        echo "=== メモリ使用量 ==="
        redis-cli info memory | grep -E "(used_memory|used_memory_peak|used_memory_rss)"
        
    else
        log_error "redis-cliが見つかりません"
        return 1
    fi
}

# キャッシュの監視
monitor_cache() {
    log_info "キャッシュを監視中..."
    
    if command -v redis-cli >/dev/null 2>&1; then
        echo ""
        echo "=== Redis統計情報 ==="
        
        # 基本情報
        echo "Redisバージョン:"
        redis-cli info server | grep redis_version
        
        echo ""
        echo "接続情報:"
        redis-cli info clients | grep -E "(connected_clients|blocked_clients)"
        
        echo ""
        echo "メモリ使用量:"
        redis-cli info memory | grep -E "(used_memory_human|used_memory_peak_human|used_memory_rss_human)"
        
        echo ""
        echo "統計情報:"
        redis-cli info stats | grep -E "(total_commands_processed|total_connections_received|keyspace_hits|keyspace_misses)"
        
        echo ""
        echo "キースペース情報:"
        redis-cli info keyspace
        
        # ヒット率の計算
        local hits=$(redis-cli info stats | grep keyspace_hits | cut -d: -f2)
        local misses=$(redis-cli info stats | grep keyspace_misses | cut -d: -f2)
        local total=$((hits + misses))
        
        if [[ $total -gt 0 ]]; then
            local hit_rate=$(echo "scale=2; $hits * 100 / $total" | bc -l 2>/dev/null || echo "0")
            echo ""
            echo "キャッシュヒット率: ${hit_rate}%"
        fi
        
    else
        log_error "redis-cliが見つかりません"
        return 1
    fi
}

# キャッシュの最適化
optimize_cache() {
    log_info "キャッシュを最適化中..."
    
    if command -v redis-cli >/dev/null 2>&1; then
        # メモリ使用量の最適化
        echo ""
        echo "=== メモリ最適化 ==="
        
        # 現在のメモリ使用量
        local current_memory=$(redis-cli info memory | grep used_memory_human | cut -d: -f2)
        echo "現在のメモリ使用量: $current_memory"
        
        # 不要なキーの削除
        echo "不要なキーの削除中..."
        redis-cli --scan --pattern "temp_*" | xargs -r redis-cli del
        redis-cli --scan --pattern "session_*" | xargs -r redis-cli del
        
        # メモリフラグメンテーションの解消
        echo "メモリフラグメンテーションの解消中..."
        redis-cli memory purge
        
        # 最適化後のメモリ使用量
        local optimized_memory=$(redis-cli info memory | grep used_memory_human | cut -d: -f2)
        echo "最適化後のメモリ使用量: $optimized_memory"
        
        # 設定の最適化
        echo ""
        echo "=== 設定最適化 ==="
        
        # メモリポリシーの確認
        local memory_policy=$(redis-cli config get maxmemory-policy | tail -1)
        echo "現在のメモリポリシー: $memory_policy"
        
        # 推奨設定の適用
        redis-cli config set maxmemory-policy allkeys-lru
        redis-cli config set maxmemory-samples 10
        
        log_success "キャッシュの最適化が完了しました"
        
    else
        log_error "redis-cliが見つかりません"
        return 1
    fi
}

# キャッシュパフォーマンステスト
performance_test() {
    log_info "キャッシュパフォーマンステストを実行中..."
    
    local test_script="/tmp/redis_performance_test.lua"
    
    # パフォーマンステストスクリプトの作成
    cat > "$test_script" << 'EOF'
-- Redis パフォーマンステストスクリプト
local start_time = redis.call('TIME')[1]
local operations = 10000

-- 書き込みテスト
for i = 1, operations do
    redis.call('SET', 'perf_test_key_' .. i, 'perf_test_value_' .. i)
end

local write_time = redis.call('TIME')[1] - start_time

-- 読み取りテスト
start_time = redis.call('TIME')[1]
for i = 1, operations do
    redis.call('GET', 'perf_test_key_' .. i)
end

local read_time = redis.call('TIME')[1] - start_time

-- 結果の出力
return {write_time, read_time, operations}
EOF
    
    # テストの実行
    if command -v redis-cli >/dev/null 2>&1; then
        echo ""
        echo "=== パフォーマンステスト結果 ==="
        
        local result=$(redis-cli --eval "$test_script")
        local write_time=$(echo "$result" | cut -d' ' -f1)
        local read_time=$(echo "$result" | cut -d' ' -f2)
        local operations=$(echo "$result" | cut -d' ' -f3)
        
        echo "書き込みテスト: ${operations}件を ${write_time}秒 で完了"
        echo "読み取りテスト: ${operations}件を ${read_time}秒 で完了"
        
        # スループットの計算
        local write_throughput=$(echo "scale=2; $operations / $write_time" | bc -l 2>/dev/null || echo "0")
        local read_throughput=$(echo "scale=2; $operations / $read_time" | bc -l 2>/dev/null || echo "0")
        
        echo "書き込みスループット: ${write_throughput} ops/sec"
        echo "読み取りスループット: ${read_throughput} ops/sec"
        
        # クリーンアップ
        redis-cli --scan --pattern "perf_test_*" | xargs -r redis-cli del
        rm -f "$test_script"
        
    else
        log_error "redis-cliが見つかりません"
        return 1
    fi
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps キャッシュシステム管理を開始します..."
    
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
        install_redis
    fi
    
    if [[ "$CONFIGURE" == "true" ]]; then
        configure_redis
        configure_redis_sentinel
    fi
    
    if [[ "$START" == "true" ]]; then
        start_redis
    fi
    
    if [[ "$TEST" == "true" ]]; then
        test_cache
        performance_test
    fi
    
    if [[ "$MONITOR" == "true" ]]; then
        monitor_cache
    fi
    
    if [[ "$OPTIMIZE" == "true" ]]; then
        optimize_cache
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$INSTALL" == "false" && "$CONFIGURE" == "false" && "$START" == "false" && "$TEST" == "false" && "$MONITOR" == "false" && "$OPTIMIZE" == "false" ]]; then
        log_info "デフォルト動作: インストールと設定を実行"
        install_redis
        configure_redis
        configure_redis_sentinel
        start_redis
        test_cache
        monitor_cache
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "キャッシュシステム管理が完了しました（実行時間: ${duration}秒）"
    log_info "ログファイル: $LOG_FILE"
}

# スクリプト実行
main "$@" 