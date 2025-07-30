#!/bin/bash

# 監視システム起動スクリプト
# 使用方法: ./scripts/start-monitoring.sh

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

# ヘルプ表示
show_help() {
    echo "監視システム起動スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help     このヘルプを表示"
    echo "  -f, --full      フルスタック（アプリ + 監視）を起動"
    echo "  -m, --monitor   監視システムのみを起動"
    echo "  -s, --stop      監視システムを停止"
    echo "  -r, --restart   監視システムを再起動"
    echo ""
    echo "例:"
    echo "  $0 --full       # アプリケーション + 監視システム"
    echo "  $0 --monitor    # 監視システムのみ"
    echo "  $0 --stop       # 監視システムを停止"
}

# 引数チェック
MODE="monitor"
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--full)
            MODE="full"
            shift
            ;;
        -m|--monitor)
            MODE="monitor"
            shift
            ;;
        -s|--stop)
            MODE="stop"
            shift
            ;;
        -r|--restart)
            MODE="restart"
            shift
            ;;
        *)
            log_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
    esac
done

# 監視システムの起動
start_monitoring() {
    log_info "監視システムを起動中..."
    
    # Docker Composeで監視サービスを起動
    docker-compose --profile monitoring up -d
    
    log_success "監視システムが起動しました"
    log_info "アクセスURL:"
    log_info "  Prometheus: http://localhost:9090"
    log_info "  Grafana:    http://localhost:3001 (admin/admin)"
    log_info "  Alertmanager: http://localhost:9093"
}

# フルスタックの起動
start_full_stack() {
    log_info "フルスタック（アプリケーション + 監視）を起動中..."
    
    # アプリケーションを起動
    docker-compose --profile production up -d
    
    # 監視システムを起動
    docker-compose --profile monitoring up -d
    
    log_success "フルスタックが起動しました"
    log_info "アクセスURL:"
    log_info "  アプリケーション: https://localhost"
    log_info "  API:         http://localhost:8080"
    log_info "  Prometheus:  http://localhost:9090"
    log_info "  Grafana:     http://localhost:3001 (admin/admin)"
    log_info "  Alertmanager: http://localhost:9093"
}

# 監視システムの停止
stop_monitoring() {
    log_info "監視システムを停止中..."
    
    docker-compose --profile monitoring down
    
    log_success "監視システムが停止しました"
}

# 監視システムの再起動
restart_monitoring() {
    log_info "監視システムを再起動中..."
    
    stop_monitoring
    sleep 5
    start_monitoring
}

# ヘルスチェック
health_check() {
    log_info "ヘルスチェックを実行中..."
    
    # Prometheus
    if curl -s http://localhost:9090/-/healthy > /dev/null; then
        log_success "✓ Prometheus: 正常"
    else
        log_error "✗ Prometheus: 異常"
    fi
    
    # Grafana
    if curl -s http://localhost:3001/api/health > /dev/null; then
        log_success "✓ Grafana: 正常"
    else
        log_error "✗ Grafana: 異常"
    fi
    
    # Alertmanager
    if curl -s http://localhost:9093/-/healthy > /dev/null; then
        log_success "✓ Alertmanager: 正常"
    else
        log_error "✗ Alertmanager: 異常"
    fi
}

# メイン処理
main() {
    case $MODE in
        "monitor")
            start_monitoring
            sleep 10
            health_check
            ;;
        "full")
            start_full_stack
            sleep 15
            health_check
            ;;
        "stop")
            stop_monitoring
            ;;
        "restart")
            restart_monitoring
            sleep 10
            health_check
            ;;
        *)
            log_error "不明なモード: $MODE"
            exit 1
            ;;
    esac
}

# スクリプト実行
main "$@" 