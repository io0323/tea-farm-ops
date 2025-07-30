#!/bin/bash

# TeaFarmOps 監視システム強化 - Prometheus監視
# 使用方法: ./scripts/monitoring-prometheus.sh [options]

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
PROMETHEUS_CONFIG="/etc/prometheus/prometheus.yml"
PROMETHEUS_DATA="/var/lib/prometheus"
PROMETHEUS_LOG="/var/log/prometheus"
PROMETHEUS_USER="prometheus"
PROMETHEUS_VERSION="2.45.0"
LOG_FILE="/var/log/tea-farm-ops/monitoring/prometheus.log"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps Prometheus監視システム管理スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -i, --install       Prometheusのインストール"
    echo "  -c, --configure     Prometheusの設定"
    echo "  -s, --start         Prometheusサービスの開始"
    echo "  -t, --test          監視のテスト"
    echo "  -m, --monitor       監視状態の確認"
    echo "  -e, --exporters     エクスポーターの設定"
    echo "  -r, --rules         アラートルールの設定"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --install         # Prometheusインストール"
    echo "  $0 --configure       # Prometheus設定"
    echo "  $0 --test            # 監視テスト"
}

# 引数解析
INSTALL=false
CONFIGURE=false
START=false
TEST=false
MONITOR=false
EXPORTERS=false
RULES=false
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
        -e|--exporters)
            EXPORTERS=true
            shift
            ;;
        -r|--rules)
            RULES=true
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

# Prometheusのインストール
install_prometheus() {
    log_info "Prometheusをインストール中..."
    
    if command -v prometheus >/dev/null 2>&1; then
        log_success "Prometheusは既にインストールされています"
        return 0
    fi
    
    # ユーザーの作成
    if ! id "$PROMETHEUS_USER" &>/dev/null; then
        sudo useradd --no-create-home --shell /bin/false "$PROMETHEUS_USER"
        log_success "Prometheusユーザーが作成されました"
    fi
    
    # ディレクトリの作成
    sudo mkdir -p "$PROMETHEUS_DATA"
    sudo mkdir -p "$PROMETHEUS_LOG"
    sudo mkdir -p /etc/prometheus
    sudo mkdir -p /etc/prometheus/rules
    sudo mkdir -p /etc/prometheus/file_sd
    
    # 権限の設定
    sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" "$PROMETHEUS_DATA"
    sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" "$PROMETHEUS_LOG"
    sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" /etc/prometheus
    
    # Prometheusのダウンロードとインストール
    local download_url="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
    local temp_dir="/tmp/prometheus_install"
    
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    log_info "Prometheus v${PROMETHEUS_VERSION}をダウンロード中..."
    wget -q "$download_url" -O prometheus.tar.gz
    
    tar -xzf prometheus.tar.gz
    cd "prometheus-${PROMETHEUS_VERSION}.linux-amd64"
    
    # バイナリのコピー
    sudo cp prometheus /usr/local/bin/
    sudo cp promtool /usr/local/bin/
    
    # 設定ファイルのコピー
    sudo cp prometheus.yml /etc/prometheus/
    sudo cp -r console_libraries /etc/prometheus/
    sudo cp -r consoles /etc/prometheus/
    
    # 権限の設定
    sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" /usr/local/bin/prometheus
    sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" /usr/local/bin/promtool
    sudo chown -R "$PROMETHEUS_USER:$PROMETHEUS_USER" /etc/prometheus
    
    # クリーンアップ
    cd /
    rm -rf "$temp_dir"
    
    log_success "Prometheusがインストールされました"
}

# Prometheusの設定
configure_prometheus() {
    log_info "Prometheusを設定中..."
    
    # 設定ファイルのバックアップ
    if [[ -f "$PROMETHEUS_CONFIG" ]]; then
        sudo cp "$PROMETHEUS_CONFIG" "${PROMETHEUS_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Prometheus設定ファイルの作成
    sudo tee "$PROMETHEUS_CONFIG" > /dev/null << EOF
# TeaFarmOps Prometheus設定

global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'tea-farm-ops'

rule_files:
  - "/etc/prometheus/rules/*.yml"

scrape_configs:
  # Prometheus自身の監視
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    metrics_path: /metrics
    scrape_interval: 15s

  # Node Exporter (システムメトリクス)
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
    scrape_interval: 15s

  # Redis Exporter
  - job_name: 'redis-exporter'
    static_configs:
      - targets: ['localhost:9121']
    scrape_interval: 15s

  # PostgreSQL Exporter
  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['localhost:9187']
    scrape_interval: 15s

  # Nginx Exporter
  - job_name: 'nginx-exporter'
    static_configs:
      - targets: ['localhost:9113']
    scrape_interval: 15s

  # Spring Boot Application
  - job_name: 'spring-boot-app'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: /actuator/prometheus
    scrape_interval: 15s

  # React Application (フロントエンドメトリクス)
  - job_name: 'react-app'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: /metrics
    scrape_interval: 30s

  # カスタムメトリクス
  - job_name: 'custom-metrics'
    static_configs:
      - targets: ['localhost:9091']
    scrape_interval: 30s

  # ファイルベースサービスディスカバリ
  - job_name: 'file-sd-targets'
    file_sd_configs:
      - files:
        - '/etc/prometheus/file_sd/*.yml'
    scrape_interval: 30s

# アラートマネージャーの設定
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093

# リモートストレージ設定（オプション）
remote_write:
  - url: "http://localhost:9201/write"
    remote_timeout: 30s

remote_read:
  - url: "http://localhost:9201/read"
    remote_timeout: 30s

# ストレージ設定
storage:
  tsdb:
    path: /var/lib/prometheus
    retention.time: 15d
    retention.size: 50GB
    wal:
      retention.period: 2h
      retention.size: 5GB

# 外部URL設定
external_url: 'http://localhost:9090'

# 管理API設定
enable_admin_api: true
enable_lifecycle: true

# ログ設定
log.level: info
log.format: json

# メトリクス設定
web.enable-lifecycle: true
web.enable-admin-api: true
web.console.templates: /etc/prometheus/consoles
web.console.libraries: /etc/prometheus/console_libraries
web.page-title: "TeaFarmOps Prometheus"
web.cors.origin: "*"
EOF
    
    # 設定ファイルの権限設定
    sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" "$PROMETHEUS_CONFIG"
    
    log_success "Prometheus設定が完了しました"
}

# systemdサービスの作成
create_systemd_service() {
    log_info "systemdサービスを作成中..."
    
    sudo tee /etc/systemd/system/prometheus.service > /dev/null << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$PROMETHEUS_USER
Group=$PROMETHEUS_USER
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file=/etc/prometheus/prometheus.yml \\
    --storage.tsdb.path=$PROMETHEUS_DATA \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries \\
    --web.listen-address=0.0.0.0:9090 \\
    --web.enable-lifecycle \\
    --web.enable-admin-api \\
    --log.level=info \\
    --log.format=json

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # systemdの再読み込み
    sudo systemctl daemon-reload
    sudo systemctl enable prometheus
    
    log_success "systemdサービスが作成されました"
}

# エクスポーターの設定
configure_exporters() {
    log_info "エクスポーターを設定中..."
    
    # Node Exporter (システムメトリクス)
    if ! command -v node_exporter >/dev/null 2>&1; then
        log_info "Node Exporterをインストール中..."
        
        # Node Exporterのダウンロード
        local node_exporter_version="1.6.1"
        local node_exporter_url="https://github.com/prometheus/node_exporter/releases/download/v${node_exporter_version}/node_exporter-${node_exporter_version}.linux-amd64.tar.gz"
        
        cd /tmp
        wget -q "$node_exporter_url" -O node_exporter.tar.gz
        tar -xzf node_exporter.tar.gz
        sudo cp "node_exporter-${node_exporter_version}.linux-amd64/node_exporter" /usr/local/bin/
        sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" /usr/local/bin/node_exporter
        
        # Node Exporterサービス
        sudo tee /etc/systemd/system/node_exporter.service > /dev/null << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$PROMETHEUS_USER
Group=$PROMETHEUS_USER
Type=simple
ExecStart=/usr/local/bin/node_exporter \\
    --web.listen-address=:9100 \\
    --collector.systemd \\
    --collector.processes \\
    --collector.filesystem \\
    --collector.netdev \\
    --collector.meminfo \\
    --collector.cpu \\
    --collector.diskstats \\
    --collector.loadavg \\
    --collector.uname \\
    --collector.vmstat \\
    --collector.filefd \\
    --collector.netstat \\
    --collector.textfile.directory=/etc/prometheus/textfile_collector

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable node_exporter
        
        log_success "Node Exporterがインストールされました"
    fi
    
    # Redis Exporter
    if ! command -v redis_exporter >/dev/null 2>&1; then
        log_info "Redis Exporterをインストール中..."
        
        # Redis Exporterのダウンロード
        local redis_exporter_version="1.55.0"
        local redis_exporter_url="https://github.com/oliver006/redis_exporter/releases/download/v${redis_exporter_version}/redis_exporter-v${redis_exporter_version}.linux-amd64.tar.gz"
        
        cd /tmp
        wget -q "$redis_exporter_url" -O redis_exporter.tar.gz
        tar -xzf redis_exporter.tar.gz
        sudo cp redis_exporter /usr/local/bin/
        sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" /usr/local/bin/redis_exporter
        
        # Redis Exporterサービス
        sudo tee /etc/systemd/system/redis_exporter.service > /dev/null << EOF
[Unit]
Description=Redis Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$PROMETHEUS_USER
Group=$PROMETHEUS_USER
Type=simple
ExecStart=/usr/local/bin/redis_exporter \\
    --redis.addr=redis://localhost:6379 \\
    --redis.password=teafarmops_redis_2024 \\
    --web.listen-address=:9121 \\
    --namespace=redis

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable redis_exporter
        
        log_success "Redis Exporterがインストールされました"
    fi
    
    # PostgreSQL Exporter
    if ! command -v postgres_exporter >/dev/null 2>&1; then
        log_info "PostgreSQL Exporterをインストール中..."
        
        # PostgreSQL Exporterのダウンロード
        local postgres_exporter_version="0.15.0"
        local postgres_exporter_url="https://github.com/prometheus-community/postgres_exporter/releases/download/v${postgres_exporter_version}/postgres_exporter-${postgres_exporter_version}.linux-amd64.tar.gz"
        
        cd /tmp
        wget -q "$postgres_exporter_url" -O postgres_exporter.tar.gz
        tar -xzf postgres_exporter.tar.gz
        sudo cp postgres_exporter /usr/local/bin/
        sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" /usr/local/bin/postgres_exporter
        
        # PostgreSQL Exporterサービス
        sudo tee /etc/systemd/system/postgres_exporter.service > /dev/null << EOF
[Unit]
Description=PostgreSQL Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$PROMETHEUS_USER
Group=$PROMETHEUS_USER
Type=simple
Environment=DATA_SOURCE_NAME="postgresql://teafarmops:teafarmops_2024@localhost:5432/teafarmops?sslmode=disable"
ExecStart=/usr/local/bin/postgres_exporter \\
    --web.listen-address=:9187 \\
    --extend.query-path=/etc/prometheus/postgres_queries.yml

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        # PostgreSQLクエリ設定
        sudo tee /etc/prometheus/postgres_queries.yml > /dev/null << EOF
pg_replication:
  query: "SELECT CASE WHEN NOT pg_is_in_recovery() THEN 0 ELSE GREATEST (0, EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()))) END AS lag"
  master: true
  metrics:
    - lag:
        usage: "GAUGE"
        description: "Replication lag behind master in seconds"

pg_stat_activity:
  query: |
    SELECT
      state,
      count(*) as count
    FROM pg_stat_activity
    GROUP BY state
  metrics:
    - state:
        usage: "LABEL"
        description: "Connection state"
    - count:
        usage: "GAUGE"
        description: "Number of connections in this state"

pg_stat_database:
  query: |
    SELECT
      datname,
      numbackends,
      xact_commit,
      xact_rollback,
      blks_read,
      blks_hit,
      tup_returned,
      tup_fetched,
      tup_inserted,
      tup_updated,
      tup_deleted,
      temp_files,
      temp_bytes,
      deadlocks,
      blk_read_time,
      blk_write_time
    FROM pg_stat_database
  metrics:
    - datname:
        usage: "LABEL"
        description: "Name of the database"
    - numbackends:
        usage: "GAUGE"
        description: "Number of backends currently connected to this database"
    - xact_commit:
        usage: "COUNTER"
        description: "Number of transactions in this database that have been committed"
    - xact_rollback:
        usage: "COUNTER"
        description: "Number of transactions in this database that have been rolled back"
    - blks_read:
        usage: "COUNTER"
        description: "Number of disk blocks read in this database"
    - blks_hit:
        usage: "COUNTER"
        description: "Number of times disk blocks were found already in the buffer cache"
    - tup_returned:
        usage: "COUNTER"
        description: "Number of rows returned by queries in this database"
    - tup_fetched:
        usage: "COUNTER"
        description: "Number of rows fetched by queries in this database"
    - tup_inserted:
        usage: "COUNTER"
        description: "Number of rows inserted by queries in this database"
    - tup_updated:
        usage: "COUNTER"
        description: "Number of rows updated by queries in this database"
    - tup_deleted:
        usage: "COUNTER"
        description: "Number of rows deleted by queries in this database"
    - temp_files:
        usage: "COUNTER"
        description: "Number of temporary files created by queries in this database"
    - temp_bytes:
        usage: "COUNTER"
        description: "Total amount of data written to temporary files by queries in this database"
    - deadlocks:
        usage: "COUNTER"
        description: "Number of deadlocks detected in this database"
    - blk_read_time:
        usage: "COUNTER"
        description: "Time spent reading data file blocks by backends in this database"
    - blk_write_time:
        usage: "COUNTER"
        description: "Time spent writing data file blocks by backends in this database"
EOF
        
        sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" /etc/prometheus/postgres_queries.yml
        
        sudo systemctl daemon-reload
        sudo systemctl enable postgres_exporter
        
        log_success "PostgreSQL Exporterがインストールされました"
    fi
    
    # Nginx Exporter
    if ! command -v nginx-prometheus-exporter >/dev/null 2>&1; then
        log_info "Nginx Exporterをインストール中..."
        
        # Nginx Exporterのダウンロード
        local nginx_exporter_version="0.11.0"
        local nginx_exporter_url="https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v${nginx_exporter_version}/nginx-prometheus-exporter_${nginx_exporter_version}_linux_amd64.tar.gz"
        
        cd /tmp
        wget -q "$nginx_exporter_url" -O nginx_exporter.tar.gz
        tar -xzf nginx_exporter.tar.gz
        sudo cp nginx-prometheus-exporter /usr/local/bin/nginx-prometheus-exporter
        sudo chown "$PROMETHEUS_USER:$PROMETHEUS_USER" /usr/local/bin/nginx-prometheus-exporter
        
        # Nginx Exporterサービス
        sudo tee /etc/systemd/system/nginx_exporter.service > /dev/null << EOF
[Unit]
Description=Nginx Prometheus Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$PROMETHEUS_USER
Group=$PROMETHEUS_USER
Type=simple
ExecStart=/usr/local/bin/nginx-prometheus-exporter \\
    -nginx.scrape-uri=http://localhost/nginx_status \\
    -web.listen-address=:9113

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable nginx_exporter
        
        log_success "Nginx Exporterがインストールされました"
    fi
    
    log_success "エクスポーターの設定が完了しました"
}

# アラートルールの設定
configure_alert_rules() {
    log_info "アラートルールを設定中..."
    
    # システムアラートルール
    sudo tee /etc/prometheus/rules/system_alerts.yml > /dev/null << EOF
groups:
  - name: system_alerts
    rules:
      # CPU使用率アラート
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 5 minutes"

      # メモリ使用率アラート
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85% for more than 5 minutes"

      # ディスク使用率アラート
      - alert: HighDiskUsage
        expr: (node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High disk usage detected"
          description: "Disk usage is above 85% for more than 5 minutes"

      # システム負荷アラート
      - alert: HighSystemLoad
        expr: node_load1 > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High system load detected"
          description: "System load is above 5 for more than 5 minutes"

      # ネットワークエラーアラート
      - alert: NetworkErrors
        expr: rate(node_network_receive_errs_total[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Network errors detected"
          description: "Network receive errors are occurring"

      # ファイルディスクリプタ不足アラート
      - alert: FileDescriptorExhaustion
        expr: node_filefd_allocated / node_filefd_maximum * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "File descriptor exhaustion detected"
          description: "File descriptor usage is above 80%"
EOF
    
    # データベースアラートルール
    sudo tee /etc/prometheus/rules/database_alerts.yml > /dev/null << EOF
groups:
  - name: database_alerts
    rules:
      # PostgreSQL接続数アラート
      - alert: HighPostgreSQLConnections
        expr: pg_stat_database_numbackends > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High PostgreSQL connections detected"
          description: "PostgreSQL has more than 80 active connections"

      # PostgreSQLデッドロックアラート
      - alert: PostgreSQLDeadlocks
        expr: rate(pg_stat_database_deadlocks[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "PostgreSQL deadlocks detected"
          description: "PostgreSQL is experiencing deadlocks"

      # PostgreSQLレプリケーションラグアラート
      - alert: PostgreSQLReplicationLag
        expr: pg_replication_lag > 30
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "PostgreSQL replication lag detected"
          description: "PostgreSQL replication lag is above 30 seconds"

      # PostgreSQLスロークエリアラート
      - alert: PostgreSQLSlowQueries
        expr: rate(pg_stat_activity_count{state="active"}[5m]) > 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "PostgreSQL slow queries detected"
          description: "PostgreSQL has more than 10 active queries"
EOF
    
    # キャッシュアラートルール
    sudo tee /etc/prometheus/rules/cache_alerts.yml > /dev/null << EOF
groups:
  - name: cache_alerts
    rules:
      # Redis接続数アラート
      - alert: HighRedisConnections
        expr: redis_connected_clients > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High Redis connections detected"
          description: "Redis has more than 100 connected clients"

      # Redisメモリ使用率アラート
      - alert: HighRedisMemoryUsage
        expr: redis_memory_used_bytes / redis_memory_max_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High Redis memory usage detected"
          description: "Redis memory usage is above 80%"

      # Redisキー数アラート
      - alert: HighRedisKeys
        expr: redis_db_keys > 1000000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High Redis keys detected"
          description: "Redis has more than 1 million keys"

      # Redisエラーアラート
      - alert: RedisErrors
        expr: rate(redis_commands_processed_total[5m]) > 0 and rate(redis_commands_processed_total[5m]) < rate(redis_commands_total[5m])
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis errors detected"
          description: "Redis is experiencing command errors"
EOF
    
    # Webサーバーアラートルール
    sudo tee /etc/prometheus/rules/webserver_alerts.yml > /dev/null << EOF
groups:
  - name: webserver_alerts
    rules:
      # Nginxエラー率アラート
      - alert: HighNginxErrorRate
        expr: rate(nginx_http_requests_total{status=~"5.."}[5m]) / rate(nginx_http_requests_total[5m]) * 100 > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High Nginx error rate detected"
          description: "Nginx error rate is above 5%"

      # Nginxレスポンス時間アラート
      - alert: HighNginxResponseTime
        expr: histogram_quantile(0.95, rate(nginx_http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High Nginx response time detected"
          description: "Nginx 95th percentile response time is above 1 second"

      # Nginx接続数アラート
      - alert: HighNginxConnections
        expr: nginx_http_connections_active > 1000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High Nginx connections detected"
          description: "Nginx has more than 1000 active connections"
EOF
    
    # アプリケーションアラートルール
    sudo tee /etc/prometheus/rules/application_alerts.yml > /dev/null << EOF
groups:
  - name: application_alerts
    rules:
      # Spring Bootアプリケーションアラート
      - alert: SpringBootDown
        expr: up{job="spring-boot-app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Spring Boot application is down"
          description: "Spring Boot application has been down for more than 1 minute"

      # Spring Bootレスポンス時間アラート
      - alert: SpringBootSlowResponse
        expr: histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Spring Boot slow response detected"
          description: "Spring Boot 95th percentile response time is above 2 seconds"

      # Spring Bootエラー率アラート
      - alert: SpringBootHighErrorRate
        expr: rate(http_server_requests_total{status=~"5.."}[5m]) / rate(http_server_requests_total[5m]) * 100 > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Spring Boot high error rate detected"
          description: "Spring Boot error rate is above 5%"

      # JVMメモリ使用率アラート
      - alert: HighJVMMemoryUsage
        expr: jvm_memory_used_bytes / jvm_memory_max_bytes * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High JVM memory usage detected"
          description: "JVM memory usage is above 85%"

      # JVM GC時間アラート
      - alert: HighJVMGCTime
        expr: rate(jvm_gc_collection_seconds_sum[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High JVM GC time detected"
          description: "JVM garbage collection time is high"
EOF
    
    # 権限の設定
    sudo chown -R "$PROMETHEUS_USER:$PROMETHEUS_USER" /etc/prometheus/rules
    
    log_success "アラートルールが設定されました"
}

# Prometheusサービスの開始
start_prometheus() {
    log_info "Prometheusサービスを開始中..."
    
    # 設定ファイルの検証
    if sudo /usr/local/bin/promtool check config "$PROMETHEUS_CONFIG"; then
        log_success "Prometheus設定ファイルの検証が成功しました"
    else
        log_error "Prometheus設定ファイルの検証に失敗しました"
        return 1
    fi
    
    # サービスの開始
    sudo systemctl start prometheus
    sudo systemctl start node_exporter
    sudo systemctl start redis_exporter
    sudo systemctl start postgres_exporter
    sudo systemctl start nginx_exporter
    
    # サービスの状態確認
    local services=("prometheus" "node_exporter" "redis_exporter" "postgres_exporter" "nginx_exporter")
    for service in "${services[@]}"; do
        if sudo systemctl is-active --quiet "$service"; then
            log_success "$service サービスが開始されました"
        else
            log_error "$service サービスの開始に失敗しました"
        fi
    done
    
    log_success "Prometheus監視システムが開始されました"
}

# 監視のテスト
test_monitoring() {
    log_info "監視システムをテスト中..."
    
    echo ""
    echo "=== Prometheus接続テスト ==="
    
    # Prometheus接続テスト
    if curl -s http://localhost:9090/api/v1/status/config | grep -q "status"; then
        log_success "Prometheus API接続が成功しました"
    else
        log_error "Prometheus API接続に失敗しました"
    fi
    
    echo ""
    echo "=== エクスポーター接続テスト ==="
    
    # 各エクスポーターのテスト
    local exporters=(
        "http://localhost:9100/metrics:Node Exporter"
        "http://localhost:9121/metrics:Redis Exporter"
        "http://localhost:9187/metrics:PostgreSQL Exporter"
        "http://localhost:9113/metrics:Nginx Exporter"
    )
    
    for exporter in "${exporters[@]}"; do
        local url=$(echo "$exporter" | cut -d: -f1-2)
        local name=$(echo "$exporter" | cut -d: -f3)
        
        if curl -s "$url" | grep -q "prometheus"; then
            log_success "$name 接続が成功しました"
        else
            log_error "$name 接続に失敗しました"
        fi
    done
    
    echo ""
    echo "=== メトリクス収集テスト ==="
    
    # メトリクス収集テスト
    local metrics=(
        "up"
        "node_cpu_seconds_total"
        "node_memory_MemTotal_bytes"
        "redis_connected_clients"
        "pg_stat_database_numbackends"
        "nginx_http_requests_total"
    )
    
    for metric in "${metrics[@]}"; do
        local result=$(curl -s "http://localhost:9090/api/v1/query?query=$metric" | grep -c "result")
        if [[ $result -gt 0 ]]; then
            log_success "メトリクス $metric が収集されています"
        else
            log_warning "メトリクス $metric が収集されていません"
        fi
    done
    
    log_success "監視システムのテストが完了しました"
}

# 監視状態の確認
monitor_status() {
    log_info "監視状態を確認中..."
    
    echo ""
    echo "=== サービス状態 ==="
    
    local services=("prometheus" "node_exporter" "redis_exporter" "postgres_exporter" "nginx_exporter")
    for service in "${services[@]}"; do
        if sudo systemctl is-active --quiet "$service"; then
            echo "✅ $service: 稼働中"
        else
            echo "❌ $service: 停止中"
        fi
    done
    
    echo ""
    echo "=== ポート監視 ==="
    
    local ports=(9090 9100 9121 9187 9113)
    for port in "${ports[@]}"; do
        if ss -tuln | grep -q ":$port "; then
            echo "✅ ポート $port: 開いている"
        else
            echo "❌ ポート $port: 閉じている"
        fi
    done
    
    echo ""
    echo "=== メトリクス統計 ==="
    
    # メトリクス統計
    local total_metrics=$(curl -s "http://localhost:9090/api/v1/label/__name__/values" | jq '.data | length' 2>/dev/null || echo "0")
    echo "総メトリクス数: $total_metrics"
    
    # ターゲット状態
    local targets=$(curl -s "http://localhost:9090/api/v1/targets" | jq '.data.activeTargets | length' 2>/dev/null || echo "0")
    echo "アクティブターゲット数: $targets"
    
    # アラート状態
    local alerts=$(curl -s "http://localhost:9090/api/v1/alerts" | jq '.data.alerts | length' 2>/dev/null || echo "0")
    echo "アクティブアラート数: $alerts"
    
    echo ""
    echo "=== ストレージ情報 ==="
    
    # ストレージ情報
    local storage_info=$(curl -s "http://localhost:9090/api/v1/status/storage" 2>/dev/null)
    if [[ -n "$storage_info" ]]; then
        echo "ストレージ情報:"
        echo "$storage_info" | jq '.' 2>/dev/null || echo "$storage_info"
    else
        echo "ストレージ情報を取得できませんでした"
    fi
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps Prometheus監視システム管理を開始します..."
    
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
        install_prometheus
        create_systemd_service
    fi
    
    if [[ "$CONFIGURE" == "true" ]]; then
        configure_prometheus
    fi
    
    if [[ "$EXPORTERS" == "true" ]]; then
        configure_exporters
    fi
    
    if [[ "$RULES" == "true" ]]; then
        configure_alert_rules
    fi
    
    if [[ "$START" == "true" ]]; then
        start_prometheus
    fi
    
    if [[ "$TEST" == "true" ]]; then
        test_monitoring
    fi
    
    if [[ "$MONITOR" == "true" ]]; then
        monitor_status
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$INSTALL" == "false" && "$CONFIGURE" == "false" && "$START" == "false" && "$TEST" == "false" && "$MONITOR" == "false" && "$EXPORTERS" == "false" && "$RULES" == "false" ]]; then
        log_info "デフォルト動作: 包括的セットアップを実行"
        install_prometheus
        create_systemd_service
        configure_prometheus
        configure_exporters
        configure_alert_rules
        start_prometheus
        test_monitoring
        monitor_status
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "Prometheus監視システム管理が完了しました（実行時間: ${duration}秒）"
    log_info "Prometheus UI: http://localhost:9090"
    log_info "ログファイル: $LOG_FILE"
}

# スクリプト実行
main "$@" 