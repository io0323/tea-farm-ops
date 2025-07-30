#!/bin/bash

# 監視データバックアップスクリプト
# 使用方法: ./scripts/backup-monitoring.sh [options]

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
BACKUP_DIR="/backups/monitoring"
RETENTION_DAYS=30
COMPRESSION=true
VERIFY_BACKUP=true
NOTIFY_ON_SUCCESS=true
NOTIFY_ON_FAILURE=true

# 監視データソース
MONITORING_SOURCES=(
    "/var/lib/prometheus"    # Prometheusデータ
    "/var/lib/grafana"       # Grafanaデータ
    "/var/lib/alertmanager"  # Alertmanagerデータ
    "/etc/prometheus"        # Prometheus設定
    "/etc/grafana"           # Grafana設定
    "/etc/alertmanager"      # Alertmanager設定
)

# タイムスタンプ
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DATE=$(date +%Y-%m-%d)

# ヘルプ表示
show_help() {
    echo "監視データバックアップスクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -a, --all           全監視データバックアップ（デフォルト）"
    echo "  -p, --prometheus    Prometheusデータのみ"
    echo "  -g, --grafana       Grafanaデータのみ"
    echo "  -m, --alertmanager  Alertmanagerデータのみ"
    echo "  -c, --config        設定ファイルのみ"
    echo "  -v, --verify        バックアップ検証"
    echo "  -c, --compress      圧縮（デフォルト: 有効）"
    echo "  -n, --no-compress   圧縮無効"
    echo "  -r, --retention N   保持日数（デフォルト: 30日）"
    echo "  -o, --output DIR    出力ディレクトリ"
    echo ""
    echo "例:"
    echo "  $0 --all                    # 全監視データバックアップ"
    echo "  $0 --prometheus             # Prometheusデータのみ"
    echo "  $0 --grafana                # Grafanaデータのみ"
    echo "  $0 --verify                 # バックアップ検証"
    echo "  $0 --retention 7 --output /custom/backup"
}

# 引数解析
BACKUP_TYPE="all"
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -a|--all)
            BACKUP_TYPE="all"
            shift
            ;;
        -p|--prometheus)
            BACKUP_TYPE="prometheus"
            shift
            ;;
        -g|--grafana)
            BACKUP_TYPE="grafana"
            shift
            ;;
        -m|--alertmanager)
            BACKUP_TYPE="alertmanager"
            shift
            ;;
        -c|--config)
            BACKUP_TYPE="config"
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
    mkdir -p "$BACKUP_DIR/all"
    mkdir -p "$BACKUP_DIR/prometheus"
    mkdir -p "$BACKUP_DIR/grafana"
    mkdir -p "$BACKUP_DIR/alertmanager"
    mkdir -p "$BACKUP_DIR/config"
    mkdir -p "$BACKUP_DIR/logs"
    
    log_success "バックアップディレクトリが作成されました"
}

# 全監視データバックアップ
perform_all_backup() {
    log_info "全監視データバックアップを実行中..."
    
    local backup_file="$BACKUP_DIR/all/all_monitoring_${TIMESTAMP}.tar.gz"
    local log_file="$BACKUP_DIR/logs/all_monitoring_backup_${TIMESTAMP}.log"
    
    # tarコマンドの構築
    local tar_cmd="tar -czf '$backup_file'"
    
    # バックアップ対象を追加
    for source in "${MONITORING_SOURCES[@]}"; do
        if [[ -d "$source" ]] || [[ -f "$source" ]]; then
            tar_cmd="$tar_cmd '$source'"
        else
            log_warning "バックアップ対象が見つかりません: $source"
        fi
    done
    
    # バックアップ実行
    if eval "$tar_cmd" > "$log_file" 2>&1; then
        log_success "全監視データバックアップが完了しました: $backup_file"
        
        # バックアップサイズを記録
        local size=$(du -h "$backup_file" | cut -f1)
        log_info "バックアップサイズ: $size"
        
        echo "$backup_file"
        return 0
    else
        log_error "全監視データバックアップに失敗しました"
        log_error "ログファイル: $log_file"
        return 1
    fi
}

# Prometheusデータバックアップ
perform_prometheus_backup() {
    log_info "Prometheusデータバックアップを実行中..."
    
    local backup_file="$BACKUP_DIR/prometheus/prometheus_${TIMESTAMP}.tar.gz"
    local log_file="$BACKUP_DIR/logs/prometheus_backup_${TIMESTAMP}.log"
    
    local prometheus_sources=(
        "/var/lib/prometheus"
        "/etc/prometheus"
    )
    
    local tar_cmd="tar -czf '$backup_file'"
    
    for source in "${prometheus_sources[@]}"; do
        if [[ -d "$source" ]] || [[ -f "$source" ]]; then
            tar_cmd="$tar_cmd '$source'"
        else
            log_warning "Prometheusデータが見つかりません: $source"
        fi
    done
    
    if eval "$tar_cmd" > "$log_file" 2>&1; then
        log_success "Prometheusデータバックアップが完了しました: $backup_file"
        echo "$backup_file"
        return 0
    else
        log_error "Prometheusデータバックアップに失敗しました"
        log_error "ログファイル: $log_file"
        return 1
    fi
}

# Grafanaデータバックアップ
perform_grafana_backup() {
    log_info "Grafanaデータバックアップを実行中..."
    
    local backup_file="$BACKUP_DIR/grafana/grafana_${TIMESTAMP}.tar.gz"
    local log_file="$BACKUP_DIR/logs/grafana_backup_${TIMESTAMP}.log"
    
    local grafana_sources=(
        "/var/lib/grafana"
        "/etc/grafana"
    )
    
    local tar_cmd="tar -czf '$backup_file'"
    
    for source in "${grafana_sources[@]}"; do
        if [[ -d "$source" ]] || [[ -f "$source" ]]; then
            tar_cmd="$tar_cmd '$source'"
        else
            log_warning "Grafanaデータが見つかりません: $source"
        fi
    done
    
    if eval "$tar_cmd" > "$log_file" 2>&1; then
        log_success "Grafanaデータバックアップが完了しました: $backup_file"
        echo "$backup_file"
        return 0
    else
        log_error "Grafanaデータバックアップに失敗しました"
        log_error "ログファイル: $log_file"
        return 1
    fi
}

# Alertmanagerデータバックアップ
perform_alertmanager_backup() {
    log_info "Alertmanagerデータバックアップを実行中..."
    
    local backup_file="$BACKUP_DIR/alertmanager/alertmanager_${TIMESTAMP}.tar.gz"
    local log_file="$BACKUP_DIR/logs/alertmanager_backup_${TIMESTAMP}.log"
    
    local alertmanager_sources=(
        "/var/lib/alertmanager"
        "/etc/alertmanager"
    )
    
    local tar_cmd="tar -czf '$backup_file'"
    
    for source in "${alertmanager_sources[@]}"; do
        if [[ -d "$source" ]] || [[ -f "$source" ]]; then
            tar_cmd="$tar_cmd '$source'"
        else
            log_warning "Alertmanagerデータが見つかりません: $source"
        fi
    done
    
    if eval "$tar_cmd" > "$log_file" 2>&1; then
        log_success "Alertmanagerデータバックアップが完了しました: $backup_file"
        echo "$backup_file"
        return 0
    else
        log_error "Alertmanagerデータバックアップに失敗しました"
        log_error "ログファイル: $log_file"
        return 1
    fi
}

# 設定ファイルバックアップ
perform_config_backup() {
    log_info "監視設定ファイルバックアップを実行中..."
    
    local backup_file="$BACKUP_DIR/config/monitoring_config_${TIMESTAMP}.tar.gz"
    local log_file="$BACKUP_DIR/logs/config_backup_${TIMESTAMP}.log"
    
    local config_sources=(
        "/etc/prometheus"
        "/etc/grafana"
        "/etc/alertmanager"
        "/etc/nginx/nginx.conf"
    )
    
    local tar_cmd="tar -czf '$backup_file'"
    
    for source in "${config_sources[@]}"; do
        if [[ -d "$source" ]] || [[ -f "$source" ]]; then
            tar_cmd="$tar_cmd '$source'"
        else
            log_warning "設定ファイルが見つかりません: $source"
        fi
    done
    
    if eval "$tar_cmd" > "$log_file" 2>&1; then
        log_success "監視設定ファイルバックアップが完了しました: $backup_file"
        echo "$backup_file"
        return 0
    else
        log_error "監視設定ファイルバックアップに失敗しました"
        log_error "ログファイル: $log_file"
        return 1
    fi
}

# バックアップ検証
verify_backup() {
    local backup_file="$1"
    
    if [[ "$VERIFY_BACKUP" != "true" ]]; then
        return 0
    fi
    
    log_info "バックアップを検証中: $backup_file"
    
    # tar.gzファイルの整合性チェック
    if [[ "$backup_file" == *.tar.gz ]]; then
        if tar -tzf "$backup_file" > /dev/null 2>&1; then
            log_success "バックアップファイルの検証が成功しました"
            return 0
        else
            log_error "バックアップファイルの検証に失敗しました"
            return 1
        fi
    fi
    
    return 0
}

# 古いバックアップの削除
cleanup_old_backups() {
    log_info "古いバックアップを削除中（保持期間: ${RETENTION_DAYS}日）..."
    
    local deleted_count=0
    
    # 各バックアップタイプの古いファイルを削除
    for backup_type in all prometheus grafana alertmanager config; do
        local backup_path="$BACKUP_DIR/$backup_type"
        if [[ -d "$backup_path" ]]; then
            local count=$(find "$backup_path" -name "*.tar.gz" -type f -mtime +$RETENTION_DAYS | wc -l)
            find "$backup_path" -name "*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete
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
  "backup_config": {
    "compression": $COMPRESSION,
    "verification": $VERIFY_BACKUP,
    "retention_days": $RETENTION_DAYS
  },
  "backup_counts": {
    "all": $(find "$BACKUP_DIR/all" -name "*.tar.gz" -type f | wc -l),
    "prometheus": $(find "$BACKUP_DIR/prometheus" -name "*.tar.gz" -type f | wc -l),
    "grafana": $(find "$BACKUP_DIR/grafana" -name "*.tar.gz" -type f | wc -l),
    "alertmanager": $(find "$BACKUP_DIR/alertmanager" -name "*.tar.gz" -type f | wc -l),
    "config": $(find "$BACKUP_DIR/config" -name "*.tar.gz" -type f | wc -l)
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
        #     --data "{\"text\":\"✅ 監視データバックアップ成功: $message\"}" \
        #     "$SLACK_WEBHOOK_URL"
    elif [[ "$status" == "failure" && "$NOTIFY_ON_FAILURE" == "true" ]]; then
        log_error "失敗通知を送信中..."
        # Slack通知の実装
        # curl -X POST -H 'Content-type: application/json' \
        #     --data "{\"text\":\"❌ 監視データバックアップ失敗: $message\"}" \
        #     "$SLACK_WEBHOOK_URL"
    fi
}

# メイン処理
main() {
    local start_time=$(date +%s)
    local backup_file=""
    
    log_info "監視データバックアップを開始します..."
    log_info "バックアップタイプ: $BACKUP_TYPE"
    
    # バックアップディレクトリの作成
    create_backup_directory
    
    # バックアップ実行
    case $BACKUP_TYPE in
        "all")
            if backup_file=$(perform_all_backup); then
                log_success "全監視データバックアップが完了しました"
            else
                send_notification "failure" "全監視データバックアップに失敗"
                exit 1
            fi
            ;;
        "prometheus")
            if backup_file=$(perform_prometheus_backup); then
                log_success "Prometheusデータバックアップが完了しました"
            else
                send_notification "failure" "Prometheusデータバックアップに失敗"
                exit 1
            fi
            ;;
        "grafana")
            if backup_file=$(perform_grafana_backup); then
                log_success "Grafanaデータバックアップが完了しました"
            else
                send_notification "failure" "Grafanaデータバックアップに失敗"
                exit 1
            fi
            ;;
        "alertmanager")
            if backup_file=$(perform_alertmanager_backup); then
                log_success "Alertmanagerデータバックアップが完了しました"
            else
                send_notification "failure" "Alertmanagerデータバックアップに失敗"
                exit 1
            fi
            ;;
        "config")
            if backup_file=$(perform_config_backup); then
                log_success "監視設定ファイルバックアップが完了しました"
            else
                send_notification "failure" "監視設定ファイルバックアップに失敗"
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
    local message="監視データバックアップが完了しました（実行時間: ${duration}秒）"
    
    log_success "$message"
    send_notification "success" "$message"
    
    log_info "バックアップファイル: $backup_file"
    log_info "バックアップディレクトリ: $BACKUP_DIR"
}

# スクリプト実行
main "$@" 