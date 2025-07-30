#!/bin/bash

# TeaFarmOps 監視システム強化 - Alertmanagerアラート管理
# 使用方法: ./scripts/monitoring-alertmanager.sh [options]

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
ALERTMANAGER_CONFIG="/etc/alertmanager/alertmanager.yml"
ALERTMANAGER_DATA="/var/lib/alertmanager"
ALERTMANAGER_LOG="/var/log/alertmanager"
ALERTMANAGER_USER="alertmanager"
ALERTMANAGER_VERSION="0.26.0"
LOG_FILE="/var/log/tea-farm-ops/monitoring/alertmanager.log"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps Alertmanagerアラート管理スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -i, --install       Alertmanagerのインストール"
    echo "  -c, --configure     Alertmanagerの設定"
    echo "  -s, --start         Alertmanagerサービスの開始"
    echo "  -t, --test          アラートのテスト"
    echo "  -m, --monitor       監視状態の確認"
    echo "  -n, --notifications 通知設定の管理"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --install         # Alertmanagerインストール"
    echo "  $0 --configure       # Alertmanager設定"
    echo "  $0 --test            # アラートテスト"
}

# 引数解析
INSTALL=false
CONFIGURE=false
START=false
TEST=false
MONITOR=false
NOTIFICATIONS=false
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
        -n|--notifications)
            NOTIFICATIONS=true
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

# Alertmanagerのインストール
install_alertmanager() {
    log_info "Alertmanagerをインストール中..."
    
    if command -v alertmanager >/dev/null 2>&1; then
        log_success "Alertmanagerは既にインストールされています"
        return 0
    fi
    
    # ユーザーの作成
    if ! id "$ALERTMANAGER_USER" &>/dev/null; then
        sudo useradd --no-create-home --shell /bin/false "$ALERTMANAGER_USER"
        log_success "Alertmanagerユーザーが作成されました"
    fi
    
    # ディレクトリの作成
    sudo mkdir -p "$ALERTMANAGER_DATA"
    sudo mkdir -p "$ALERTMANAGER_LOG"
    sudo mkdir -p /etc/alertmanager
    sudo mkdir -p /etc/alertmanager/templates
    
    # 権限の設定
    sudo chown "$ALERTMANAGER_USER:$ALERTMANAGER_USER" "$ALERTMANAGER_DATA"
    sudo chown "$ALERTMANAGER_USER:$ALERTMANAGER_USER" "$ALERTMANAGER_LOG"
    sudo chown "$ALERTMANAGER_USER:$ALERTMANAGER_USER" /etc/alertmanager
    
    # Alertmanagerのダウンロードとインストール
    local download_url="https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
    local temp_dir="/tmp/alertmanager_install"
    
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    log_info "Alertmanager v${ALERTMANAGER_VERSION}をダウンロード中..."
    wget -q "$download_url" -O alertmanager.tar.gz
    
    tar -xzf alertmanager.tar.gz
    cd "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64"
    
    # バイナリのコピー
    sudo cp alertmanager /usr/local/bin/
    sudo cp amtool /usr/local/bin/
    
    # 設定ファイルのコピー
    sudo cp alertmanager.yml /etc/alertmanager/
    
    # 権限の設定
    sudo chown "$ALERTMANAGER_USER:$ALERTMANAGER_USER" /usr/local/bin/alertmanager
    sudo chown "$ALERTMANAGER_USER:$ALERTMANAGER_USER" /usr/local/bin/amtool
    sudo chown "$ALERTMANAGER_USER:$ALERTMANAGER_USER" /etc/alertmanager/alertmanager.yml
    
    # クリーンアップ
    cd /
    rm -rf "$temp_dir"
    
    log_success "Alertmanagerがインストールされました"
}

# Alertmanagerの設定
configure_alertmanager() {
    log_info "Alertmanagerを設定中..."
    
    # 設定ファイルのバックアップ
    if [[ -f "$ALERTMANAGER_CONFIG" ]]; then
        sudo cp "$ALERTMANAGER_CONFIG" "${ALERTMANAGER_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Alertmanager設定ファイルの作成
    sudo tee "$ALERTMANAGER_CONFIG" > /dev/null << EOF
# TeaFarmOps Alertmanager設定

global:
  resolve_timeout: 5m
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alertmanager@teafarmops.local'
  smtp_auth_username: 'alertmanager@teafarmops.local'
  smtp_auth_password: 'teafarmops_alert_2024'
  smtp_require_tls: false

# テンプレートファイルの設定
templates:
  - '/etc/alertmanager/templates/*.tmpl'

# ルート設定
route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'tea-farm-ops-team'
  routes:
    - match:
        severity: critical
      receiver: 'tea-farm-ops-critical'
      continue: true
    - match:
        severity: warning
      receiver: 'tea-farm-ops-warning'
      continue: true
    - match:
        service: database
      receiver: 'tea-farm-ops-database'
      continue: true
    - match:
        service: cache
      receiver: 'tea-farm-ops-cache'
      continue: true
    - match:
        service: webserver
      receiver: 'tea-farm-ops-webserver'
      continue: true

# 受信者設定
receivers:
  - name: 'tea-farm-ops-team'
    email_configs:
      - to: 'team@teafarmops.local'
        send_resolved: true
        headers:
          subject: 'TeaFarmOps Alert: {{ .GroupLabels.alertname }}'
        html: |
          <h2>TeaFarmOps Alert</h2>
          <p><strong>Alert:</strong> {{ .GroupLabels.alertname }}</p>
          <p><strong>Severity:</strong> {{ .GroupLabels.severity }}</p>
          <p><strong>Service:</strong> {{ .GroupLabels.service }}</p>
          <p><strong>Summary:</strong> {{ .CommonAnnotations.summary }}</p>
          <p><strong>Description:</strong> {{ .CommonAnnotations.description }}</p>
          <p><strong>Started:</strong> {{ .StartsAt }}</p>
          {{ if .EndsAt }}<p><strong>Ended:</strong> {{ .EndsAt }}</p>{{ end }}
          <hr>
          <p><small>TeaFarmOps Monitoring System</small></p>
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR_SLACK_WEBHOOK'
        channel: '#tea-farm-ops-alerts'
        title: 'TeaFarmOps Alert: {{ .GroupLabels.alertname }}'
        text: |
          *Alert:* {{ .GroupLabels.alertname }}
          *Severity:* {{ .GroupLabels.severity }}
          *Service:* {{ .GroupLabels.service }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
          *Started:* {{ .StartsAt }}
          {{ if .EndsAt }}*Ended:* {{ .EndsAt }}{{ end }}
        send_resolved: true

  - name: 'tea-farm-ops-critical'
    email_configs:
      - to: 'critical@teafarmops.local'
        send_resolved: true
        headers:
          subject: '🚨 CRITICAL: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        html: |
          <h2 style="color: red;">🚨 CRITICAL ALERT</h2>
          <p><strong>Alert:</strong> {{ .GroupLabels.alertname }}</p>
          <p><strong>Severity:</strong> {{ .GroupLabels.severity }}</p>
          <p><strong>Service:</strong> {{ .GroupLabels.service }}</p>
          <p><strong>Summary:</strong> {{ .CommonAnnotations.summary }}</p>
          <p><strong>Description:</strong> {{ .CommonAnnotations.description }}</p>
          <p><strong>Started:</strong> {{ .StartsAt }}</p>
          {{ if .EndsAt }}<p><strong>Ended:</strong> {{ .EndsAt }}</p>{{ end }}
          <hr>
          <p><small>TeaFarmOps Monitoring System - IMMEDIATE ACTION REQUIRED</small></p>
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR_SLACK_WEBHOOK'
        channel: '#tea-farm-ops-critical'
        title: '🚨 CRITICAL: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        text: |
          🚨 *CRITICAL ALERT*
          *Alert:* {{ .GroupLabels.alertname }}
          *Severity:* {{ .GroupLabels.severity }}
          *Service:* {{ .GroupLabels.service }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
          *Started:* {{ .StartsAt }}
          {{ if .EndsAt }}*Ended:* {{ .EndsAt }}{{ end }}
          *IMMEDIATE ACTION REQUIRED*
        send_resolved: true

  - name: 'tea-farm-ops-warning'
    email_configs:
      - to: 'warnings@teafarmops.local'
        send_resolved: true
        headers:
          subject: '⚠️ WARNING: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        html: |
          <h2 style="color: orange;">⚠️ WARNING ALERT</h2>
          <p><strong>Alert:</strong> {{ .GroupLabels.alertname }}</p>
          <p><strong>Severity:</strong> {{ .GroupLabels.severity }}</p>
          <p><strong>Service:</strong> {{ .GroupLabels.service }}</p>
          <p><strong>Summary:</strong> {{ .CommonAnnotations.summary }}</p>
          <p><strong>Description:</strong> {{ .CommonAnnotations.description }}</p>
          <p><strong>Started:</strong> {{ .StartsAt }}</p>
          {{ if .EndsAt }}<p><strong>Ended:</strong> {{ .EndsAt }}</p>{{ end }}
          <hr>
          <p><small>TeaFarmOps Monitoring System</small></p>
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR_SLACK_WEBHOOK'
        channel: '#tea-farm-ops-warnings'
        title: '⚠️ WARNING: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        text: |
          ⚠️ *WARNING ALERT*
          *Alert:* {{ .GroupLabels.alertname }}
          *Severity:* {{ .GroupLabels.severity }}
          *Service:* {{ .GroupLabels.service }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
          *Started:* {{ .StartsAt }}
          {{ if .EndsAt }}*Ended:* {{ .EndsAt }}{{ end }}
        send_resolved: true

  - name: 'tea-farm-ops-database'
    email_configs:
      - to: 'database@teafarmops.local'
        send_resolved: true
        headers:
          subject: '🗄️ DATABASE: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        html: |
          <h2 style="color: blue;">🗄️ DATABASE ALERT</h2>
          <p><strong>Alert:</strong> {{ .GroupLabels.alertname }}</p>
          <p><strong>Severity:</strong> {{ .GroupLabels.severity }}</p>
          <p><strong>Service:</strong> {{ .GroupLabels.service }}</p>
          <p><strong>Summary:</strong> {{ .CommonAnnotations.summary }}</p>
          <p><strong>Description:</strong> {{ .CommonAnnotations.description }}</p>
          <p><strong>Started:</strong> {{ .StartsAt }}</p>
          {{ if .EndsAt }}<p><strong>Ended:</strong> {{ .EndsAt }}</p>{{ end }}
          <hr>
          <p><small>TeaFarmOps Database Monitoring</small></p>
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR_SLACK_WEBHOOK'
        channel: '#tea-farm-ops-database'
        title: '🗄️ DATABASE: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        text: |
          🗄️ *DATABASE ALERT*
          *Alert:* {{ .GroupLabels.alertname }}
          *Severity:* {{ .GroupLabels.severity }}
          *Service:* {{ .GroupLabels.service }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
          *Started:* {{ .StartsAt }}
          {{ if .EndsAt }}*Ended:* {{ .EndsAt }}{{ end }}
        send_resolved: true

  - name: 'tea-farm-ops-cache'
    email_configs:
      - to: 'cache@teafarmops.local'
        send_resolved: true
        headers:
          subject: '🔥 CACHE: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        html: |
          <h2 style="color: red;">🔥 CACHE ALERT</h2>
          <p><strong>Alert:</strong> {{ .GroupLabels.alertname }}</p>
          <p><strong>Severity:</strong> {{ .GroupLabels.severity }}</p>
          <p><strong>Service:</strong> {{ .GroupLabels.service }}</p>
          <p><strong>Summary:</strong> {{ .CommonAnnotations.summary }}</p>
          <p><strong>Description:</strong> {{ .CommonAnnotations.description }}</p>
          <p><strong>Started:</strong> {{ .StartsAt }}</p>
          {{ if .EndsAt }}<p><strong>Ended:</strong> {{ .EndsAt }}</p>{{ end }}
          <hr>
          <p><small>TeaFarmOps Cache Monitoring</small></p>
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR_SLACK_WEBHOOK'
        channel: '#tea-farm-ops-cache'
        title: '🔥 CACHE: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        text: |
          🔥 *CACHE ALERT*
          *Alert:* {{ .GroupLabels.alertname }}
          *Severity:* {{ .GroupLabels.severity }}
          *Service:* {{ .GroupLabels.service }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
          *Started:* {{ .StartsAt }}
          {{ if .EndsAt }}*Ended:* {{ .EndsAt }}{{ end }}
        send_resolved: true

  - name: 'tea-farm-ops-webserver'
    email_configs:
      - to: 'webserver@teafarmops.local'
        send_resolved: true
        headers:
          subject: '🌐 WEBSERVER: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        html: |
          <h2 style="color: green;">🌐 WEBSERVER ALERT</h2>
          <p><strong>Alert:</strong> {{ .GroupLabels.alertname }}</p>
          <p><strong>Severity:</strong> {{ .GroupLabels.severity }}</p>
          <p><strong>Service:</strong> {{ .GroupLabels.service }}</p>
          <p><strong>Summary:</strong> {{ .CommonAnnotations.summary }}</p>
          <p><strong>Description:</strong> {{ .CommonAnnotations.description }}</p>
          <p><strong>Started:</strong> {{ .StartsAt }}</p>
          {{ if .EndsAt }}<p><strong>Ended:</strong> {{ .EndsAt }}</p>{{ end }}
          <hr>
          <p><small>TeaFarmOps Web Server Monitoring</small></p>
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR_SLACK_WEBHOOK'
        channel: '#tea-farm-ops-webserver'
        title: '🌐 WEBSERVER: TeaFarmOps Alert - {{ .GroupLabels.alertname }}'
        text: |
          🌐 *WEBSERVER ALERT*
          *Alert:* {{ .GroupLabels.alertname }}
          *Severity:* {{ .GroupLabels.severity }}
          *Service:* {{ .GroupLabels.service }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
          *Started:* {{ .StartsAt }}
          {{ if .EndsAt }}*Ended:* {{ .EndsAt }}{{ end }}
        send_resolved: true

# 抑制設定
inhibit_rules:
  # 同じインスタンスの複数のアラートを抑制
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
  
  # データベースダウン時は関連アラートを抑制
  - source_match:
      alertname: 'DatabaseDown'
    target_match:
      service: 'database'
    equal: ['instance']
  
  # キャッシュダウン時は関連アラートを抑制
  - source_match:
      alertname: 'CacheDown'
    target_match:
      service: 'cache'
    equal: ['instance']
  
  # Webサーバーダウン時は関連アラートを抑制
  - source_match:
      alertname: 'WebServerDown'
    target_match:
      service: 'webserver'
    equal: ['instance']

# 時間設定
time_intervals:
  - name: workdays
    time_intervals:
      - weekdays: ['monday:friday']
        times:
          - start_time: 09:00
            end_time: 17:00
  - name: weekends
    time_intervals:
      - weekdays: ['saturday', 'sunday']
  - name: nights
    time_intervals:
      - times:
          - start_time: 22:00
            end_time: 06:00
        weekdays: ['monday:sunday']

# 通知設定
notification_configs:
  - name: 'tea-farm-ops-team'
    email_configs:
      - to: 'team@teafarmops.local'
        send_resolved: true
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR_SLACK_WEBHOOK'
        channel: '#tea-farm-ops-alerts'
        send_resolved: true
EOF
    
    # 権限の設定
    sudo chown "$ALERTMANAGER_USER:$ALERTMANAGER_USER" "$ALERTMANAGER_CONFIG"
    
    log_success "Alertmanager設定が完了しました"
}

# 通知設定の管理
configure_notifications() {
    log_info "通知設定を管理中..."
    
    # メール通知設定
    log_info "メール通知設定を確認中..."
    
    # Postfixの設定確認
    if command -v postfix >/dev/null 2>&1; then
        log_success "Postfixがインストールされています"
        
        # Postfix設定の確認
        if sudo systemctl is-active --quiet postfix; then
            log_success "Postfixサービスが稼働中です"
        else
            log_warning "Postfixサービスが停止中です。開始しますか？"
            read -p "Postfixを開始しますか？ (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo systemctl start postfix
                sudo systemctl enable postfix
                log_success "Postfixが開始されました"
            fi
        fi
    else
        log_warning "Postfixがインストールされていません"
        read -p "Postfixをインストールしますか？ (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt-get update
            sudo apt-get install -y postfix
            log_success "Postfixがインストールされました"
        fi
    fi
    
    # Slack通知設定
    log_info "Slack通知設定を確認中..."
    
    echo ""
    echo "=== Slack通知設定 ==="
    echo "Slack通知を有効にするには、以下の手順を実行してください："
    echo ""
    echo "1. Slackワークスペースでアプリを作成"
    echo "2. Incoming Webhooksを有効化"
    echo "3. Webhook URLを取得"
    echo "4. 設定ファイルの 'YOUR_SLACK_WEBHOOK' を実際のURLに置換"
    echo ""
    echo "現在の設定ファイル: $ALERTMANAGER_CONFIG"
    echo ""
    
    # Webhook URLの入力
    read -p "Slack Webhook URLを入力してください（スキップする場合はEnter）: " slack_webhook
    if [[ -n "$slack_webhook" ]]; then
        # 設定ファイルの更新
        sudo sed -i "s|YOUR_SLACK_WEBHOOK|$slack_webhook|g" "$ALERTMANAGER_CONFIG"
        log_success "Slack Webhook URLが設定されました"
    else
        log_warning "Slack通知は設定されていません"
    fi
    
    # メールアドレスの設定
    echo ""
    echo "=== メール通知設定 ==="
    read -p "チーム通知用メールアドレスを入力してください: " team_email
    if [[ -n "$team_email" ]]; then
        sudo sed -i "s|team@teafarmops.local|$team_email|g" "$ALERTMANAGER_CONFIG"
        log_success "チーム通知メールが設定されました: $team_email"
    fi
    
    read -p "クリティカルアラート用メールアドレスを入力してください: " critical_email
    if [[ -n "$critical_email" ]]; then
        sudo sed -i "s|critical@teafarmops.local|$critical_email|g" "$ALERTMANAGER_CONFIG"
        log_success "クリティカル通知メールが設定されました: $critical_email"
    fi
    
    log_success "通知設定が完了しました"
}

# systemdサービスの作成
create_systemd_service() {
    log_info "systemdサービスを作成中..."
    
    sudo tee /etc/systemd/system/alertmanager.service > /dev/null << EOF
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=$ALERTMANAGER_USER
Group=$ALERTMANAGER_USER
Type=simple
ExecStart=/usr/local/bin/alertmanager \\
    --config.file=/etc/alertmanager/alertmanager.yml \\
    --storage.path=$ALERTMANAGER_DATA \\
    --data.retention=120h \\
    --web.listen-address=0.0.0.0:9093 \\
    --web.external-url=http://localhost:9093 \\
    --log.level=info \\
    --log.format=json

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # systemdの再読み込み
    sudo systemctl daemon-reload
    sudo systemctl enable alertmanager
    
    log_success "systemdサービスが作成されました"
}

# Alertmanagerサービスの開始
start_alertmanager() {
    log_info "Alertmanagerサービスを開始中..."
    
    # 設定ファイルの検証
    if /usr/local/bin/amtool check-config "$ALERTMANAGER_CONFIG"; then
        log_success "Alertmanager設定ファイルの検証が成功しました"
    else
        log_error "Alertmanager設定ファイルの検証に失敗しました"
        return 1
    fi
    
    # サービスの開始
    sudo systemctl start alertmanager
    
    # サービスの状態確認
    if sudo systemctl is-active --quiet alertmanager; then
        log_success "Alertmanagerサービスが開始されました"
    else
        log_error "Alertmanagerサービスの開始に失敗しました"
        return 1
    fi
    
    # 起動待機
    log_info "Alertmanagerの起動を待機中..."
    sleep 10
    
    log_success "Alertmanagerが開始されました"
}

# アラートのテスト
test_alerts() {
    log_info "アラートをテスト中..."
    
    echo ""
    echo "=== Alertmanager接続テスト ==="
    
    # Alertmanager接続テスト
    if curl -s http://localhost:9093/api/v1/status | grep -q "status"; then
        log_success "Alertmanager API接続が成功しました"
    else
        log_error "Alertmanager API接続に失敗しました"
    fi
    
    echo ""
    echo "=== テストアラートの送信 ==="
    
    # テストアラートの送信
    local test_alert='{
        "status": "firing",
        "alerts": [
            {
                "status": "firing",
                "labels": {
                    "alertname": "TestAlert",
                    "severity": "warning",
                    "service": "test",
                    "instance": "localhost:9090"
                },
                "annotations": {
                    "summary": "Test alert for TeaFarmOps",
                    "description": "This is a test alert to verify Alertmanager configuration"
                },
                "startsAt": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
                "endsAt": "'$(date -u -d '+5 minutes' +%Y-%m-%dT%H:%M:%S.000Z)'",
                "generatorURL": "http://localhost:9090/graph?g0.expr=up"
            }
        ]
    }'
    
    local response=$(curl -s -X POST http://localhost:9093/api/v1/alerts -H "Content-Type: application/json" -d "$test_alert")
    
    if echo "$response" | grep -q "success"; then
        log_success "テストアラートが送信されました"
    else
        log_error "テストアラートの送信に失敗しました"
        echo "レスポンス: $response"
    fi
    
    echo ""
    echo "=== アラート状態の確認 ==="
    
    # アラート状態の確認
    local alerts=$(curl -s http://localhost:9093/api/v1/alerts | jq '.data.alerts | length' 2>/dev/null || echo "0")
    echo "アクティブアラート数: $alerts"
    
    # アラート詳細の表示
    if [[ $alerts -gt 0 ]]; then
        echo ""
        echo "アラート詳細:"
        curl -s http://localhost:9093/api/v1/alerts | jq '.data.alerts[] | {alertname: .labels.alertname, severity: .labels.severity, status: .status}' 2>/dev/null || echo "アラート詳細を取得できませんでした"
    fi
    
    log_success "アラートのテストが完了しました"
}

# 監視状態の確認
monitor_status() {
    log_info "Alertmanager監視状態を確認中..."
    
    echo ""
    echo "=== Alertmanagerサービス状態 ==="
    
    if sudo systemctl is-active --quiet alertmanager; then
        echo "✅ Alertmanager: 稼働中"
    else
        echo "❌ Alertmanager: 停止中"
    fi
    
    echo ""
    echo "=== ポート監視 ==="
    
    if ss -tuln | grep -q ":9093 "; then
        echo "✅ ポート 9093: 開いている"
    else
        echo "❌ ポート 9093: 閉じている"
    fi
    
    echo ""
    echo "=== Alertmanager統計 ==="
    
    # Alertmanager統計
    local version=$(curl -s http://localhost:9093/api/v1/status | jq -r '.versionInfo.version' 2>/dev/null || echo "N/A")
    echo "Alertmanagerバージョン: $version"
    
    local alerts=$(curl -s http://localhost:9093/api/v1/alerts | jq '.data.alerts | length' 2>/dev/null || echo "0")
    echo "アクティブアラート数: $alerts"
    
    local silences=$(curl -s http://localhost:9093/api/v1/silences | jq '.data | length' 2>/dev/null || echo "0")
    echo "アクティブサイレンス数: $silences"
    
    echo ""
    echo "=== アクセス情報 ==="
    echo "Alertmanager UI: http://localhost:9093"
    echo "API エンドポイント: http://localhost:9093/api/v1"
    
    echo ""
    echo "=== 通知設定確認 ==="
    
    # 通知設定の確認
    local config=$(curl -s http://localhost:9093/api/v1/status/config | jq -r '.config' 2>/dev/null)
    if [[ -n "$config" ]]; then
        echo "設定ファイルが正常に読み込まれています"
    else
        echo "設定ファイルの読み込みに問題があります"
    fi
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps Alertmanagerアラート管理を開始します..."
    
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
        install_alertmanager
        create_systemd_service
    fi
    
    if [[ "$CONFIGURE" == "true" ]]; then
        configure_alertmanager
    fi
    
    if [[ "$NOTIFICATIONS" == "true" ]]; then
        configure_notifications
    fi
    
    if [[ "$START" == "true" ]]; then
        start_alertmanager
    fi
    
    if [[ "$TEST" == "true" ]]; then
        test_alerts
    fi
    
    if [[ "$MONITOR" == "true" ]]; then
        monitor_status
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$INSTALL" == "false" && "$CONFIGURE" == "false" && "$START" == "false" && "$TEST" == "false" && "$MONITOR" == "false" && "$NOTIFICATIONS" == "false" ]]; then
        log_info "デフォルト動作: 包括的セットアップを実行"
        install_alertmanager
        create_systemd_service
        configure_alertmanager
        configure_notifications
        start_alertmanager
        test_alerts
        monitor_status
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "Alertmanagerアラート管理が完了しました（実行時間: ${duration}秒）"
    log_info "Alertmanager UI: http://localhost:9093"
    log_info "ログファイル: $LOG_FILE"
}

# スクリプト実行
main "$@" 