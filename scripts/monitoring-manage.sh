#!/bin/bash

# TeaFarmOps 監視システム強化 - 包括的管理スクリプト
# 使用方法: ./scripts/monitoring-manage.sh [options]

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
CONFIG_FILE="/etc/tea-farm-ops/monitoring-config.yml"
LOG_FILE="/var/log/tea-farm-ops/monitoring/manage.log"
SCRIPTS_DIR="/app/scripts"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps 監視システム包括的管理スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -i, --install       監視システムの完全インストール"
    echo "  -c, --configure     監視システムの設定"
    echo "  -s, --start         監視システムの開始"
    echo "  -t, --test          監視システムのテスト"
    echo "  -m, --monitor       監視状態の確認"
    echo "  -r, --report        監視レポートの生成"
    echo "  -b, --backup        監視システムのバックアップ"
    echo "  -u, --update        監視システムの更新"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --install         # 完全インストール"
    echo "  $0 --configure       # システム設定"
    echo "  $0 --test            # システムテスト"
}

# 引数解析
INSTALL=false
CONFIGURE=false
START=false
TEST=false
MONITOR=false
REPORT=false
BACKUP=false
UPDATE=false
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
        -r|--report)
            REPORT=true
            shift
            ;;
        -b|--backup)
            BACKUP=true
            shift
            ;;
        -u|--update)
            UPDATE=true
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
    mkdir -p /var/log/tea-farm-ops/monitoring
    
    if [[ "$VERBOSE" == "true" ]]; then
        exec 1> >(tee -a "$LOG_FILE")
        exec 2>&1
    else
        exec 1> >(tee -a "$LOG_FILE" >/dev/null)
        exec 2>&1
    fi
}

# 設定ファイルの確認
check_config() {
    log_info "設定ファイルを確認中..."
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "設定ファイルが見つかりません: $CONFIG_FILE"
        return 1
    fi
    
    # YAML構文チェック
    if command -v yq >/dev/null 2>&1; then
        if yq eval '.' "$CONFIG_FILE" >/dev/null 2>&1; then
            log_success "設定ファイルの構文が正常です"
        else
            log_error "設定ファイルの構文にエラーがあります"
            return 1
        fi
    else
        log_warning "yqがインストールされていません。設定ファイルの構文チェックをスキップします"
    fi
    
    log_success "設定ファイルの確認が完了しました"
}

# 監視システムの完全インストール
install_monitoring_system() {
    log_info "監視システムの完全インストールを開始します..."
    
    # 1. Prometheusのインストール
    log_info "1/4: Prometheusをインストール中..."
    if "$SCRIPTS_DIR/monitoring-prometheus.sh" --install; then
        log_success "Prometheusのインストールが完了しました"
    else
        log_error "Prometheusのインストールに失敗しました"
        return 1
    fi
    
    # 2. Grafanaのインストール
    log_info "2/4: Grafanaをインストール中..."
    if "$SCRIPTS_DIR/monitoring-grafana.sh" --install; then
        log_success "Grafanaのインストールが完了しました"
    else
        log_error "Grafanaのインストールに失敗しました"
        return 1
    fi
    
    # 3. Alertmanagerのインストール
    log_info "3/4: Alertmanagerをインストール中..."
    if "$SCRIPTS_DIR/monitoring-alertmanager.sh" --install; then
        log_success "Alertmanagerのインストールが完了しました"
    else
        log_error "Alertmanagerのインストールに失敗しました"
        return 1
    fi
    
    # 4. 設定ファイルの配置
    log_info "4/4: 設定ファイルを配置中..."
    if [[ -f "$CONFIG_FILE" ]]; then
        sudo cp "$CONFIG_FILE" /etc/tea-farm-ops/
        log_success "設定ファイルが配置されました"
    else
        log_warning "設定ファイルが見つかりません。手動で配置してください"
    fi
    
    log_success "監視システムの完全インストールが完了しました"
}

# 監視システムの設定
configure_monitoring_system() {
    log_info "監視システムの設定を開始します..."
    
    # 1. Prometheusの設定
    log_info "1/4: Prometheusを設定中..."
    if "$SCRIPTS_DIR/monitoring-prometheus.sh" --configure; then
        log_success "Prometheusの設定が完了しました"
    else
        log_error "Prometheusの設定に失敗しました"
        return 1
    fi
    
    # 2. Grafanaの設定
    log_info "2/4: Grafanaを設定中..."
    if "$SCRIPTS_DIR/monitoring-grafana.sh" --configure; then
        log_success "Grafanaの設定が完了しました"
    else
        log_error "Grafanaの設定に失敗しました"
        return 1
    fi
    
    # 3. Alertmanagerの設定
    log_info "3/4: Alertmanagerを設定中..."
    if "$SCRIPTS_DIR/monitoring-alertmanager.sh" --configure; then
        log_success "Alertmanagerの設定が完了しました"
    else
        log_error "Alertmanagerの設定に失敗しました"
        return 1
    fi
    
    # 4. 通知設定
    log_info "4/4: 通知設定を構成中..."
    if "$SCRIPTS_DIR/monitoring-alertmanager.sh" --notifications; then
        log_success "通知設定が完了しました"
    else
        log_warning "通知設定に問題があります"
    fi
    
    log_success "監視システムの設定が完了しました"
}

# 監視システムの開始
start_monitoring_system() {
    log_info "監視システムを開始します..."
    
    # 1. Prometheusの開始
    log_info "1/4: Prometheusを開始中..."
    if "$SCRIPTS_DIR/monitoring-prometheus.sh" --start; then
        log_success "Prometheusが開始されました"
    else
        log_error "Prometheusの開始に失敗しました"
        return 1
    fi
    
    # 2. Grafanaの開始
    log_info "2/4: Grafanaを開始中..."
    if "$SCRIPTS_DIR/monitoring-grafana.sh" --start; then
        log_success "Grafanaが開始されました"
    else
        log_error "Grafanaの開始に失敗しました"
        return 1
    fi
    
    # 3. Alertmanagerの開始
    log_info "3/4: Alertmanagerを開始中..."
    if "$SCRIPTS_DIR/monitoring-alertmanager.sh" --start; then
        log_success "Alertmanagerが開始されました"
    else
        log_error "Alertmanagerの開始に失敗しました"
        return 1
    fi
    
    # 4. 起動確認
    log_info "4/4: 起動確認中..."
    sleep 10
    
    local services=("prometheus" "grafana-server" "alertmanager")
    for service in "${services[@]}"; do
        if sudo systemctl is-active --quiet "$service"; then
            log_success "$service が正常に稼働中です"
        else
            log_error "$service の起動に失敗しました"
        fi
    done
    
    log_success "監視システムが開始されました"
}

# 監視システムのテスト
test_monitoring_system() {
    log_info "監視システムをテストします..."
    
    # 1. Prometheusのテスト
    log_info "1/4: Prometheusをテスト中..."
    if "$SCRIPTS_DIR/monitoring-prometheus.sh" --test; then
        log_success "Prometheusのテストが成功しました"
    else
        log_error "Prometheusのテストに失敗しました"
    fi
    
    # 2. Grafanaのテスト
    log_info "2/4: Grafanaをテスト中..."
    if "$SCRIPTS_DIR/monitoring-grafana.sh" --test; then
        log_success "Grafanaのテストが成功しました"
    else
        log_error "Grafanaのテストに失敗しました"
    fi
    
    # 3. Alertmanagerのテスト
    log_info "3/4: Alertmanagerをテスト中..."
    if "$SCRIPTS_DIR/monitoring-alertmanager.sh" --test; then
        log_success "Alertmanagerのテストが成功しました"
    else
        log_error "Alertmanagerのテストに失敗しました"
    fi
    
    # 4. 統合テスト
    log_info "4/4: 統合テストを実行中..."
    test_integration
    
    log_success "監視システムのテストが完了しました"
}

# 統合テスト
test_integration() {
    log_info "統合テストを実行中..."
    
    # 接続テスト
    local endpoints=(
        "http://localhost:9090/api/v1/status/config:Prometheus"
        "http://localhost:3001/api/health:Grafana"
        "http://localhost:9093/api/v1/status:Alertmanager"
    )
    
    for endpoint in "${endpoints[@]}"; do
        local url=$(echo "$endpoint" | cut -d: -f1-2)
        local name=$(echo "$endpoint" | cut -d: -f3)
        
        if curl -s "$url" | grep -q "status\|ok"; then
            log_success "$name 接続が成功しました"
        else
            log_error "$name 接続に失敗しました"
        fi
    done
    
    # データフローテスト
    log_info "データフローをテスト中..."
    
    # PrometheusからGrafanaへのデータフロー
    local prometheus_metrics=$(curl -s "http://localhost:9090/api/v1/label/__name__/values" | jq '.data | length' 2>/dev/null || echo "0")
    if [[ $prometheus_metrics -gt 0 ]]; then
        log_success "Prometheusで $prometheus_metrics 個のメトリクスが収集されています"
    else
        log_warning "Prometheusでメトリクスが収集されていません"
    fi
    
    # Grafanaダッシュボードの確認
    local grafana_dashboards=$(curl -s "http://localhost:3001/api/search" | jq 'length' 2>/dev/null || echo "0")
    if [[ $grafana_dashboards -gt 0 ]]; then
        log_success "Grafanaで $grafana_dashboards 個のダッシュボードが設定されています"
    else
        log_warning "Grafanaでダッシュボードが設定されていません"
    fi
    
    # Alertmanagerアラートの確認
    local alertmanager_alerts=$(curl -s "http://localhost:9093/api/v1/alerts" | jq '.data.alerts | length' 2>/dev/null || echo "0")
    log_info "Alertmanagerで $alertmanager_alerts 個のアラートが管理されています"
}

# 監視状態の確認
monitor_status() {
    log_info "監視システムの状態を確認します..."
    
    echo ""
    echo "=== 監視システム全体状態 ==="
    
    # サービス状態
    local services=("prometheus" "grafana-server" "alertmanager" "node_exporter" "redis_exporter" "postgres_exporter" "nginx_exporter")
    for service in "${services[@]}"; do
        if sudo systemctl is-active --quiet "$service"; then
            echo "✅ $service: 稼働中"
        else
            echo "❌ $service: 停止中"
        fi
    done
    
    echo ""
    echo "=== ポート監視 ==="
    
    # ポート状態
    local ports=(9090 3001 9093 9100 9121 9187 9113)
    for port in "${ports[@]}"; do
        if ss -tuln | grep -q ":$port "; then
            echo "✅ ポート $port: 開いている"
        else
            echo "❌ ポート $port: 閉じている"
        fi
    done
    
    echo ""
    echo "=== システム統計 ==="
    
    # Prometheus統計
    local prometheus_metrics=$(curl -s "http://localhost:9090/api/v1/label/__name__/values" | jq '.data | length' 2>/dev/null || echo "0")
    echo "Prometheusメトリクス数: $prometheus_metrics"
    
    local prometheus_targets=$(curl -s "http://localhost:9090/api/v1/targets" | jq '.data.activeTargets | length' 2>/dev/null || echo "0")
    echo "Prometheusターゲット数: $prometheus_targets"
    
    # Grafana統計
    local grafana_dashboards=$(curl -s "http://localhost:3001/api/search" | jq 'length' 2>/dev/null || echo "0")
    echo "Grafanaダッシュボード数: $grafana_dashboards"
    
    local grafana_datasources=$(curl -s "http://localhost:3001/api/datasources" | jq 'length' 2>/dev/null || echo "0")
    echo "Grafanaデータソース数: $grafana_datasources"
    
    # Alertmanager統計
    local alertmanager_alerts=$(curl -s "http://localhost:9093/api/v1/alerts" | jq '.data.alerts | length' 2>/dev/null || echo "0")
    echo "Alertmanagerアラート数: $alertmanager_alerts"
    
    local alertmanager_silences=$(curl -s "http://localhost:9093/api/v1/silences" | jq '.data | length' 2>/dev/null || echo "0")
    echo "Alertmanagerサイレンス数: $alertmanager_silences"
    
    echo ""
    echo "=== アクセス情報 ==="
    echo "Prometheus UI: http://localhost:9090"
    echo "Grafana UI: http://localhost:3001 (admin/teafarmops_grafana_2024)"
    echo "Alertmanager UI: http://localhost:9093"
    
    echo ""
    echo "=== システムリソース ==="
    
    # システムリソース
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "CPU使用率: ${cpu_usage}%"
    
    local memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    echo "メモリ使用率: ${memory_usage}%"
    
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    echo "ディスク使用率: ${disk_usage}%"
    
    local load_average=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | cut -d',' -f1)
    echo "システム負荷: $load_average"
}

# 監視レポートの生成
generate_report() {
    log_info "監視レポートを生成します..."
    
    local report_file="/var/log/tea-farm-ops/monitoring/report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "TeaFarmOps 監視システムレポート"
        echo "生成日時: $(date)"
        echo "========================================"
        echo ""
        
        echo "1. システム概要"
        echo "----------------"
        echo "OS: $(uname -a)"
        echo "ホスト名: $(hostname)"
        echo "稼働時間: $(uptime -p)"
        echo ""
        
        echo "2. 監視サービス状態"
        echo "-------------------"
        local services=("prometheus" "grafana-server" "alertmanager" "node_exporter" "redis_exporter" "postgres_exporter" "nginx_exporter")
        for service in "${services[@]}"; do
            if sudo systemctl is-active --quiet "$service"; then
                echo "✅ $service: 稼働中"
            else
                echo "❌ $service: 停止中"
            fi
        done
        echo ""
        
        echo "3. システム統計"
        echo "---------------"
        local prometheus_metrics=$(curl -s "http://localhost:9090/api/v1/label/__name__/values" | jq '.data | length' 2>/dev/null || echo "0")
        echo "Prometheusメトリクス数: $prometheus_metrics"
        
        local grafana_dashboards=$(curl -s "http://localhost:3001/api/search" | jq 'length' 2>/dev/null || echo "0")
        echo "Grafanaダッシュボード数: $grafana_dashboards"
        
        local alertmanager_alerts=$(curl -s "http://localhost:9093/api/v1/alerts" | jq '.data.alerts | length' 2>/dev/null || echo "0")
        echo "Alertmanagerアラート数: $alertmanager_alerts"
        echo ""
        
        echo "4. システムリソース"
        echo "------------------"
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        echo "CPU使用率: ${cpu_usage}%"
        
        local memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        echo "メモリ使用率: ${memory_usage}%"
        
        local disk_usage=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
        echo "ディスク使用率: ${disk_usage}%"
        echo ""
        
        echo "5. アクセス情報"
        echo "---------------"
        echo "Prometheus UI: http://localhost:9090"
        echo "Grafana UI: http://localhost:3001"
        echo "Alertmanager UI: http://localhost:9093"
        echo ""
        
        echo "6. 設定情報"
        echo "-----------"
        echo "設定ファイル: $CONFIG_FILE"
        echo "ログディレクトリ: /var/log/tea-farm-ops/monitoring"
        echo "スクリプトディレクトリ: $SCRIPTS_DIR"
        echo ""
        
        echo "7. 推奨事項"
        echo "-----------"
        if [[ $cpu_usage -gt 80 ]]; then
            echo "⚠️ CPU使用率が高いです。リソースの見直しを検討してください。"
        fi
        if [[ $memory_usage -gt 85 ]]; then
            echo "⚠️ メモリ使用率が高いです。メモリの増設を検討してください。"
        fi
        if [[ $disk_usage -gt 85 ]]; then
            echo "⚠️ ディスク使用率が高いです。ストレージの拡張を検討してください。"
        fi
        if [[ $alertmanager_alerts -gt 10 ]]; then
            echo "⚠️ アラート数が多いです。アラートルールの見直しを検討してください。"
        fi
        echo ""
        
        echo "レポート終了"
        echo "生成日時: $(date)"
        
    } > "$report_file"
    
    log_success "監視レポートが生成されました: $report_file"
    
    # レポートの内容を表示
    if [[ "$VERBOSE" == "true" ]]; then
        cat "$report_file"
    fi
}

# 監視システムのバックアップ
backup_monitoring_system() {
    log_info "監視システムのバックアップを開始します..."
    
    local backup_dir="/var/backups/tea-farm-ops/monitoring/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # 1. 設定ファイルのバックアップ
    log_info "1/4: 設定ファイルをバックアップ中..."
    sudo cp -r /etc/prometheus "$backup_dir/"
    sudo cp -r /etc/grafana "$backup_dir/"
    sudo cp -r /etc/alertmanager "$backup_dir/"
    sudo cp "$CONFIG_FILE" "$backup_dir/" 2>/dev/null || true
    log_success "設定ファイルのバックアップが完了しました"
    
    # 2. データのバックアップ
    log_info "2/4: データをバックアップ中..."
    sudo cp -r /var/lib/prometheus "$backup_dir/"
    sudo cp -r /var/lib/grafana "$backup_dir/"
    sudo cp -r /var/lib/alertmanager "$backup_dir/"
    log_success "データのバックアップが完了しました"
    
    # 3. ログのバックアップ
    log_info "3/4: ログをバックアップ中..."
    sudo cp -r /var/log/prometheus "$backup_dir/" 2>/dev/null || true
    sudo cp -r /var/log/grafana "$backup_dir/" 2>/dev/null || true
    sudo cp -r /var/log/alertmanager "$backup_dir/" 2>/dev/null || true
    sudo cp -r /var/log/tea-farm-ops/monitoring "$backup_dir/"
    log_success "ログのバックアップが完了しました"
    
    # 4. バックアップの圧縮
    log_info "4/4: バックアップを圧縮中..."
    cd /var/backups/tea-farm-ops/monitoring
    sudo tar -czf "$(basename "$backup_dir").tar.gz" "$(basename "$backup_dir")"
    sudo rm -rf "$backup_dir"
    
    local backup_size=$(du -h "$(basename "$backup_dir").tar.gz" | cut -f1)
    log_success "バックアップが完了しました: $(basename "$backup_dir").tar.gz ($backup_size)"
    
    # 古いバックアップの削除（30日以上前）
    find /var/backups/tea-farm-ops/monitoring -name "*.tar.gz" -mtime +30 -delete 2>/dev/null || true
}

# 監視システムの更新
update_monitoring_system() {
    log_info "監視システムの更新を開始します..."
    
    # 1. 設定ファイルのバックアップ
    log_info "1/5: 現在の設定をバックアップ中..."
    backup_monitoring_system
    
    # 2. サービスの停止
    log_info "2/5: サービスを停止中..."
    sudo systemctl stop prometheus grafana-server alertmanager 2>/dev/null || true
    sudo systemctl stop node_exporter redis_exporter postgres_exporter nginx_exporter 2>/dev/null || true
    
    # 3. コンポーネントの更新
    log_info "3/5: コンポーネントを更新中..."
    "$SCRIPTS_DIR/monitoring-prometheus.sh" --install
    "$SCRIPTS_DIR/monitoring-grafana.sh" --install
    "$SCRIPTS_DIR/monitoring-alertmanager.sh" --install
    
    # 4. 設定の再適用
    log_info "4/5: 設定を再適用中..."
    "$SCRIPTS_DIR/monitoring-prometheus.sh" --configure
    "$SCRIPTS_DIR/monitoring-grafana.sh" --configure
    "$SCRIPTS_DIR/monitoring-alertmanager.sh" --configure
    
    # 5. サービスの再開始
    log_info "5/5: サービスを再開始中..."
    "$SCRIPTS_DIR/monitoring-prometheus.sh" --start
    "$SCRIPTS_DIR/monitoring-grafana.sh" --start
    "$SCRIPTS_DIR/monitoring-alertmanager.sh" --start
    
    log_success "監視システムの更新が完了しました"
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps 監視システム包括的管理を開始します..."
    
    # ログの設定
    setup_logging
    
    # 管理者権限の確認
    if [[ $EUID -ne 0 ]]; then
        log_error "このスクリプトは管理者権限で実行する必要があります"
        echo "sudo $0 [options] を使用してください"
        exit 1
    fi
    
    # 設定ファイルの確認
    check_config
    
    # オプションの処理
    if [[ "$INSTALL" == "true" ]]; then
        install_monitoring_system
    fi
    
    if [[ "$CONFIGURE" == "true" ]]; then
        configure_monitoring_system
    fi
    
    if [[ "$START" == "true" ]]; then
        start_monitoring_system
    fi
    
    if [[ "$TEST" == "true" ]]; then
        test_monitoring_system
    fi
    
    if [[ "$MONITOR" == "true" ]]; then
        monitor_status
    fi
    
    if [[ "$REPORT" == "true" ]]; then
        generate_report
    fi
    
    if [[ "$BACKUP" == "true" ]]; then
        backup_monitoring_system
    fi
    
    if [[ "$UPDATE" == "true" ]]; then
        update_monitoring_system
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$INSTALL" == "false" && "$CONFIGURE" == "false" && "$START" == "false" && "$TEST" == "false" && "$MONITOR" == "false" && "$REPORT" == "false" && "$BACKUP" == "false" && "$UPDATE" == "false" ]]; then
        log_info "デフォルト動作: 包括的セットアップを実行"
        install_monitoring_system
        configure_monitoring_system
        start_monitoring_system
        test_monitoring_system
        monitor_status
        generate_report
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "監視システム包括的管理が完了しました（実行時間: ${duration}秒）"
    log_info "ログファイル: $LOG_FILE"
    
    echo ""
    echo "=== アクセス情報 ==="
    echo "Prometheus UI: http://localhost:9090"
    echo "Grafana UI: http://localhost:3001 (admin/teafarmops_grafana_2024)"
    echo "Alertmanager UI: http://localhost:9093"
    echo ""
    echo "=== 次のステップ ==="
    echo "1. ブラウザでGrafana UIにアクセス"
    echo "2. データソースとダッシュボードを確認"
    echo "3. アラートルールをカスタマイズ"
    echo "4. 通知設定を完了"
}

# スクリプト実行
main "$@" 