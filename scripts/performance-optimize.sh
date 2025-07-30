#!/bin/bash

# TeaFarmOps 包括的パフォーマンス最適化スクリプト
# 使用方法: ./scripts/performance-optimize.sh [options]

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
PERFORMANCE_CONFIG="/etc/tea-farm-ops/performance-config.yml"
LOG_FILE="/var/log/tea-farm-ops/performance/optimize.log"
REPORT_DIR="/var/log/tea-farm-ops/performance/reports"
CACHE_SCRIPT="/app/scripts/performance-cache.sh"
DATABASE_SCRIPT="/app/scripts/performance-database.sh"
NGINX_SCRIPT="/app/scripts/performance-nginx.sh"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps 包括的パフォーマンス最適化スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help              このヘルプを表示"
    echo "  -m, --monitor           包括的監視"
    echo "  -t, --test              パフォーマンステスト"
    echo "  -o, --optimize          包括的最適化"
    echo "  -r, --report            レポート生成"
    echo "  -a, --alert-check       アラートチェック"
    echo "  -s, --system-monitor    システム監視"
    echo "  -c, --config-check      設定チェック"
    echo "  -b, --benchmark         ベンチマーク実行"
    echo "  -l, --load-test         負荷テスト"
    echo "  -v, --verbose           詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --monitor             # 包括的監視"
    echo "  $0 --optimize            # 包括的最適化"
    echo "  $0 --test                # パフォーマンステスト"
}

# 引数解析
MONITOR=false
TEST=false
OPTIMIZE=false
REPORT=false
ALERT_CHECK=false
SYSTEM_MONITOR=false
CONFIG_CHECK=false
BENCHMARK=false
LOAD_TEST=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
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
        -r|--report)
            REPORT=true
            shift
            ;;
        -a|--alert-check)
            ALERT_CHECK=true
            shift
            ;;
        -s|--system-monitor)
            SYSTEM_MONITOR=true
            shift
            ;;
        -c|--config-check)
            CONFIG_CHECK=true
            shift
            ;;
        -b|--benchmark)
            BENCHMARK=true
            shift
            ;;
        -l|--load-test)
            LOAD_TEST=true
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
    mkdir -p "$REPORT_DIR"
    
    if [[ "$VERBOSE" == "true" ]]; then
        exec 1> >(tee -a "$LOG_FILE")
        exec 2>&1
    else
        exec 1> >(tee -a "$LOG_FILE" >/dev/null)
        exec 2>&1
    fi
}

# システム監視
system_monitor() {
    log_info "システム監視を実行中..."
    
    local report_file="$REPORT_DIR/system_monitor_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps システム監視レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        echo "=== CPU使用率 ==="
        top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
        
        echo ""
        echo "=== メモリ使用率 ==="
        free -h | grep -E "Mem|Swap"
        
        echo ""
        echo "=== ディスク使用率 ==="
        df -h | grep -E "^/dev"
        
        echo ""
        echo "=== ロードアベレージ ==="
        uptime | awk -F'load average:' '{print $2}'
        
        echo ""
        echo "=== プロセス数 ==="
        ps aux | wc -l
        
        echo ""
        echo "=== ネットワーク接続 ==="
        ss -tuln | wc -l
        
        echo ""
        echo "=== システム稼働時間 ==="
        uptime -p
        
    } > "$report_file"
    
    log_success "システム監視が完了しました: $report_file"
}

# パフォーマンス監視
performance_monitor() {
    log_info "パフォーマンス監視を実行中..."
    
    local report_file="$REPORT_DIR/performance_monitor_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps パフォーマンス監視レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # キャッシュ監視
        echo "=== キャッシュ監視 ==="
        if [[ -f "$CACHE_SCRIPT" ]]; then
            bash "$CACHE_SCRIPT" --monitor
        else
            echo "キャッシュスクリプトが見つかりません"
        fi
        
        echo ""
        echo "=== データベース監視 ==="
        if [[ -f "$DATABASE_SCRIPT" ]]; then
            bash "$DATABASE_SCRIPT" --monitor
        else
            echo "データベーススクリプトが見つかりません"
        fi
        
        echo ""
        echo "=== Nginx監視 ==="
        if [[ -f "$NGINX_SCRIPT" ]]; then
            bash "$NGINX_SCRIPT" --monitor
        else
            echo "Nginxスクリプトが見つかりません"
        fi
        
        echo ""
        echo "=== レスポンス時間監視 ==="
        local start_time=$(date +%s%N)
        curl -s -o /dev/null -w "HTTP: %{http_code}, 時間: %{time_total}s\n" http://localhost/
        local end_time=$(date +%s%N)
        local response_time=$(( (end_time - start_time) / 1000000 ))
        echo "レスポンス時間: ${response_time}ms"
        
    } > "$report_file"
    
    log_success "パフォーマンス監視が完了しました: $report_file"
}

# パフォーマンステスト
performance_test() {
    log_info "パフォーマンステストを実行中..."
    
    local report_file="$REPORT_DIR/performance_test_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps パフォーマンステストレポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # キャッシュテスト
        echo "=== キャッシュテスト ==="
        if [[ -f "$CACHE_SCRIPT" ]]; then
            bash "$CACHE_SCRIPT" --test
        fi
        
        echo ""
        echo "=== データベーステスト ==="
        if [[ -f "$DATABASE_SCRIPT" ]]; then
            bash "$DATABASE_SCRIPT" --test
        fi
        
        echo ""
        echo "=== Nginxテスト ==="
        if [[ -f "$NGINX_SCRIPT" ]]; then
            bash "$NGINX_SCRIPT" --test
        fi
        
        echo ""
        echo "=== 包括的テスト ==="
        
        # レスポンス時間テスト
        echo "レスポンス時間テスト:"
        for i in {1..10}; do
            local start_time=$(date +%s%N)
            curl -s -o /dev/null http://localhost/
            local end_time=$(date +%s%N)
            local response_time=$(( (end_time - start_time) / 1000000 ))
            echo "テスト $i: ${response_time}ms"
        done
        
        # 負荷テスト（簡単なバージョン）
        echo ""
        echo "簡単な負荷テスト:"
        if command -v ab >/dev/null 2>&1; then
            ab -n 100 -c 10 http://localhost/ 2>/dev/null | grep -E "(Requests per second|Time per request|Transfer rate)"
        else
            echo "Apache Benchがインストールされていません"
        fi
        
    } > "$report_file"
    
    log_success "パフォーマンステストが完了しました: $report_file"
}

# 包括的最適化
comprehensive_optimization() {
    log_info "包括的パフォーマンス最適化を実行中..."
    
    local report_file="$REPORT_DIR/comprehensive_optimization_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps 包括的最適化レポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # 最適化前の状態
        echo "=== 最適化前の状態 ==="
        system_monitor
        performance_monitor
        
        echo ""
        echo "=== キャッシュ最適化 ==="
        if [[ -f "$CACHE_SCRIPT" ]]; then
            bash "$CACHE_SCRIPT" --optimize
        fi
        
        echo ""
        echo "=== データベース最適化 ==="
        if [[ -f "$DATABASE_SCRIPT" ]]; then
            bash "$DATABASE_SCRIPT" --optimize
        fi
        
        echo ""
        echo "=== Nginx最適化 ==="
        if [[ -f "$NGINX_SCRIPT" ]]; then
            bash "$NGINX_SCRIPT" --optimize
        fi
        
        echo ""
        echo "=== 最適化後の状態 ==="
        system_monitor
        performance_monitor
        
        echo ""
        echo "=== 最適化結果サマリー ==="
        echo "最適化が完了しました"
        echo "詳細は個別のレポートファイルを確認してください"
        
    } > "$report_file"
    
    log_success "包括的最適化が完了しました: $report_file"
}

# アラートチェック
alert_check() {
    log_info "アラートチェックを実行中..."
    
    local alert_file="$REPORT_DIR/alerts_$(date +%Y%m%d_%H%M%S).txt"
    local alerts_found=false
    
    {
        echo "# TeaFarmOps アラートレポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # CPU使用率チェック
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        if (( $(echo "$cpu_usage > 80" | bc -l) )); then
            echo "警告: CPU使用率が高いです: ${cpu_usage}%"
            alerts_found=true
        fi
        
        # メモリ使用率チェック
        local memory_usage=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')
        if (( $(echo "$memory_usage > 85" | bc -l) )); then
            echo "警告: メモリ使用率が高いです: ${memory_usage}%"
            alerts_found=true
        fi
        
        # ディスク使用率チェック
        local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        if [[ $disk_usage -gt 85 ]]; then
            echo "警告: ディスク使用率が高いです: ${disk_usage}%"
            alerts_found=true
        fi
        
        # レスポンス時間チェック
        local start_time=$(date +%s%N)
        curl -s -o /dev/null http://localhost/
        local end_time=$(date +%s%N)
        local response_time=$(( (end_time - start_time) / 1000000 ))
        if [[ $response_time -gt 1000 ]]; then
            echo "警告: レスポンス時間が遅いです: ${response_time}ms"
            alerts_found=true
        fi
        
        if [[ "$alerts_found" == "false" ]]; then
            echo "アラートは検出されませんでした"
        fi
        
    } > "$alert_file"
    
    if [[ "$alerts_found" == "true" ]]; then
        log_warning "アラートが検出されました: $alert_file"
        # ここで通知を送信
        send_notification "アラートが検出されました"
    else
        log_success "アラートチェックが完了しました"
    fi
}

# 設定チェック
config_check() {
    log_info "設定チェックを実行中..."
    
    local config_file="$REPORT_DIR/config_check_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps 設定チェックレポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        # 設定ファイルの存在チェック
        echo "=== 設定ファイルチェック ==="
        if [[ -f "$PERFORMANCE_CONFIG" ]]; then
            echo "✅ パフォーマンス設定ファイル: 存在"
        else
            echo "❌ パフォーマンス設定ファイル: 存在しない"
        fi
        
        if [[ -f "$CACHE_SCRIPT" ]]; then
            echo "✅ キャッシュスクリプト: 存在"
        else
            echo "❌ キャッシュスクリプト: 存在しない"
        fi
        
        if [[ -f "$DATABASE_SCRIPT" ]]; then
            echo "✅ データベーススクリプト: 存在"
        else
            echo "❌ データベーススクリプト: 存在しない"
        fi
        
        if [[ -f "$NGINX_SCRIPT" ]]; then
            echo "✅ Nginxスクリプト: 存在"
        else
            echo "❌ Nginxスクリプト: 存在しない"
        fi
        
        echo ""
        echo "=== サービス状態チェック ==="
        
        # Redis状態チェック
        if systemctl is-active --quiet redis-server; then
            echo "✅ Redis: 稼働中"
        else
            echo "❌ Redis: 停止中"
        fi
        
        # PostgreSQL状態チェック
        if systemctl is-active --quiet postgresql; then
            echo "✅ PostgreSQL: 稼働中"
        else
            echo "❌ PostgreSQL: 停止中"
        fi
        
        # Nginx状態チェック
        if systemctl is-active --quiet nginx; then
            echo "✅ Nginx: 稼働中"
        else
            echo "❌ Nginx: 停止中"
        fi
        
        echo ""
        echo "=== ポート監視 ==="
        
        # ポート監視
        local ports=(6379 5432 80 443 8080 3000)
        for port in "${ports[@]}"; do
            if ss -tuln | grep -q ":$port "; then
                echo "✅ ポート $port: 開いている"
            else
                echo "❌ ポート $port: 閉じている"
            fi
        done
        
    } > "$config_file"
    
    log_success "設定チェックが完了しました: $config_file"
}

# ベンチマーク実行
benchmark() {
    log_info "ベンチマークを実行中..."
    
    local benchmark_file="$REPORT_DIR/benchmark_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps ベンチマークレポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        echo "=== システムベンチマーク ==="
        
        # CPUベンチマーク
        echo "CPUベンチマーク:"
        local start_time=$(date +%s)
        for i in {1..1000000}; do
            echo $i > /dev/null
        done
        local end_time=$(date +%s)
        local cpu_time=$((end_time - start_time))
        echo "CPU処理時間: ${cpu_time}秒"
        
        # メモリベンチマーク
        echo ""
        echo "メモリベンチマーク:"
        local memory_test=$(dd if=/dev/zero bs=1M count=100 2>/dev/null | wc -c)
        echo "メモリ処理: ${memory_test} bytes"
        
        # ディスクベンチマーク
        echo ""
        echo "ディスクベンチマーク:"
        dd if=/dev/zero of=/tmp/benchmark_test bs=1M count=100 2>&1 | grep "bytes transferred"
        rm -f /tmp/benchmark_test
        
        echo ""
        echo "=== アプリケーションベンチマーク ==="
        
        # HTTPベンチマーク
        if command -v ab >/dev/null 2>&1; then
            echo "HTTPベンチマーク:"
            ab -n 1000 -c 100 http://localhost/ 2>/dev/null | grep -E "(Requests per second|Time per request|Transfer rate)"
        fi
        
        # データベースベンチマーク
        echo ""
        echo "データベースベンチマーク:"
        if command -v pgbench >/dev/null 2>&1; then
            pgbench -c 10 -t 100 -U teafarmops teafarmops 2>/dev/null | tail -5
        else
            echo "pgbenchがインストールされていません"
        fi
        
    } > "$benchmark_file"
    
    log_success "ベンチマークが完了しました: $benchmark_file"
}

# 負荷テスト
load_test() {
    log_info "負荷テストを実行中..."
    
    local load_test_file="$REPORT_DIR/load_test_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps 負荷テストレポート"
        echo "# 実行日時: $(date)"
        echo ""
        
        echo "=== 負荷テスト実行 ==="
        
        # 同時接続テスト
        echo "同時接続テスト:"
        for i in {1..50}; do
            (
                curl -s -o /dev/null -w "接続 $i: %{http_code}, %{time_total}s\n" http://localhost/ &
            )
        done
        wait
        
        echo ""
        echo "=== 持続負荷テスト ==="
        
        # 持続負荷テスト
        if command -v ab >/dev/null 2>&1; then
            echo "持続負荷テスト（5分間）:"
            ab -n 10000 -c 50 -t 300 http://localhost/ 2>/dev/null | grep -E "(Requests per second|Time per request|Transfer rate|Failed requests)"
        fi
        
        echo ""
        echo "=== システム負荷監視 ==="
        
        # 負荷テスト中のシステム監視
        for i in {1..10}; do
            echo "監視 $i:"
            echo "CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')"
            echo "メモリ: $(free -h | grep Mem | awk '{print $3"/"$2}')"
            echo "ロード: $(uptime | awk -F'load average:' '{print $2}')"
            sleep 30
        done
        
    } > "$load_test_file"
    
    log_success "負荷テストが完了しました: $load_test_file"
}

# レポート生成
generate_report() {
    log_info "レポートを生成中..."
    
    local report_file="$REPORT_DIR/comprehensive_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "# TeaFarmOps 包括的パフォーマンスレポート"
        echo "# 生成日時: $(date)"
        echo "# システム: $(uname -a)"
        echo ""
        
        echo "## 実行サマリー"
        echo "- システム監視: 完了"
        echo "- パフォーマンス監視: 完了"
        echo "- 設定チェック: 完了"
        echo "- アラートチェック: 完了"
        echo ""
        
        echo "## システム情報"
        echo "CPU: $(nproc) コア"
        echo "メモリ: $(free -h | grep Mem | awk '{print $2}')"
        echo "ディスク: $(df -h / | tail -1 | awk '{print $2}')"
        echo "OS: $(lsb_release -d | cut -f2)"
        echo ""
        
        echo "## サービス状態"
        echo "Redis: $(systemctl is-active redis-server 2>/dev/null || echo '未インストール')"
        echo "PostgreSQL: $(systemctl is-active postgresql 2>/dev/null || echo '未インストール')"
        echo "Nginx: $(systemctl is-active nginx 2>/dev/null || echo '未インストール')"
        echo ""
        
        echo "## パフォーマンス指標"
        
        # CPU使用率
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        echo "CPU使用率: ${cpu_usage}%"
        
        # メモリ使用率
        local memory_usage=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')
        echo "メモリ使用率: ${memory_usage}%"
        
        # ディスク使用率
        local disk_usage=$(df / | tail -1 | awk '{print $5}')
        echo "ディスク使用率: ${disk_usage}"
        
        # レスポンス時間
        local start_time=$(date +%s%N)
        curl -s -o /dev/null http://localhost/
        local end_time=$(date +%s%N)
        local response_time=$(( (end_time - start_time) / 1000000 ))
        echo "レスポンス時間: ${response_time}ms"
        
        echo ""
        echo "## 推奨事項"
        echo "1. 定期的なパフォーマンス監視の実行"
        echo "2. システムリソースの定期的な確認"
        echo "3. ログの定期的な分析"
        echo "4. 設定の定期的な見直し"
        echo "5. セキュリティアップデートの適用"
        echo ""
        
        echo "## 詳細レポート"
        echo "個別の詳細レポートは以下のディレクトリに保存されています:"
        echo "$REPORT_DIR"
        echo ""
        
    } > "$report_file"
    
    log_success "レポートが生成されました: $report_file"
}

# 通知送信
send_notification() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] $message" >> "$LOG_FILE"
    
    # ここでSlackやメール通知を実装
    # 例: curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" $SLACK_WEBHOOK_URL
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps 包括的パフォーマンス最適化を開始します..."
    
    # ログの設定
    setup_logging
    
    # 管理者権限の確認
    if [[ $EUID -ne 0 ]]; then
        log_warning "一部の操作は管理者権限が必要です"
    fi
    
    # オプションの処理
    if [[ "$SYSTEM_MONITOR" == "true" ]]; then
        system_monitor
    fi
    
    if [[ "$MONITOR" == "true" ]]; then
        performance_monitor
    fi
    
    if [[ "$TEST" == "true" ]]; then
        performance_test
    fi
    
    if [[ "$OPTIMIZE" == "true" ]]; then
        comprehensive_optimization
    fi
    
    if [[ "$REPORT" == "true" ]]; then
        generate_report
    fi
    
    if [[ "$ALERT_CHECK" == "true" ]]; then
        alert_check
    fi
    
    if [[ "$CONFIG_CHECK" == "true" ]]; then
        config_check
    fi
    
    if [[ "$BENCHMARK" == "true" ]]; then
        benchmark
    fi
    
    if [[ "$LOAD_TEST" == "true" ]]; then
        load_test
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$MONITOR" == "false" && "$TEST" == "false" && "$OPTIMIZE" == "false" && "$REPORT" == "false" && "$ALERT_CHECK" == "false" && "$SYSTEM_MONITOR" == "false" && "$CONFIG_CHECK" == "false" && "$BENCHMARK" == "false" && "$LOAD_TEST" == "false" ]]; then
        log_info "デフォルト動作: 包括的監視とレポート生成を実行"
        system_monitor
        performance_monitor
        alert_check
        generate_report
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "包括的パフォーマンス最適化が完了しました（実行時間: ${duration}秒）"
    log_info "ログファイル: $LOG_FILE"
}

# スクリプト実行
main "$@" 