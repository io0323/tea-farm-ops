#!/bin/bash

# TeaFarmOps 監視システム強化 - Grafanaダッシュボード
# 使用方法: ./scripts/monitoring-grafana.sh [options]

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
GRAFANA_CONFIG="/etc/grafana/grafana.ini"
GRAFANA_DATA="/var/lib/grafana"
GRAFANA_LOG="/var/log/grafana"
GRAFANA_USER="grafana"
GRAFANA_VERSION="10.0.3"
LOG_FILE="/var/log/tea-farm-ops/monitoring/grafana.log"

# ヘルプ表示
show_help() {
    echo "TeaFarmOps Grafanaダッシュボード管理スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [options]"
    echo ""
    echo "オプション:"
    echo "  -h, --help          このヘルプを表示"
    echo "  -i, --install       Grafanaのインストール"
    echo "  -c, --configure     Grafanaの設定"
    echo "  -s, --start         Grafanaサービスの開始"
    echo "  -d, --dashboards    ダッシュボードの設定"
    echo "  -t, --test          ダッシュボードのテスト"
    echo "  -m, --monitor       監視状態の確認"
    echo "  -v, --verbose       詳細ログ出力"
    echo ""
    echo "例:"
    echo "  $0 --install         # Grafanaインストール"
    echo "  $0 --configure       # Grafana設定"
    echo "  $0 --dashboards      # ダッシュボード設定"
}

# 引数解析
INSTALL=false
CONFIGURE=false
START=false
DASHBOARDS=false
TEST=false
MONITOR=false
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
        -d|--dashboards)
            DASHBOARDS=true
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

# Grafanaのインストール
install_grafana() {
    log_info "Grafanaをインストール中..."
    
    if command -v grafana-server >/dev/null 2>&1; then
        log_success "Grafanaは既にインストールされています"
        return 0
    fi
    
    # ユーザーの作成
    if ! id "$GRAFANA_USER" &>/dev/null; then
        sudo useradd --no-create-home --shell /bin/false "$GRAFANA_USER"
        log_success "Grafanaユーザーが作成されました"
    fi
    
    # ディレクトリの作成
    sudo mkdir -p "$GRAFANA_DATA"
    sudo mkdir -p "$GRAFANA_LOG"
    sudo mkdir -p /etc/grafana
    sudo mkdir -p /etc/grafana/provisioning/datasources
    sudo mkdir -p /etc/grafana/provisioning/dashboards
    sudo mkdir -p /etc/grafana/provisioning/plugins
    
    # 権限の設定
    sudo chown "$GRAFANA_USER:$GRAFANA_USER" "$GRAFANA_DATA"
    sudo chown "$GRAFANA_USER:$GRAFANA_USER" "$GRAFANA_LOG"
    sudo chown "$GRAFANA_USER:$GRAFANA_USER" /etc/grafana
    
    # Grafanaのダウンロードとインストール
    local download_url="https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}-1.x86_64.rpm"
    
    # パッケージマネージャーの確認
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
        echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
        sudo apt-get update
        sudo apt-get install -y grafana
    elif command -v yum >/dev/null 2>&1; then
        # CentOS/RHEL
        sudo yum install -y "$download_url"
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora
        sudo dnf install -y "$download_url"
    else
        log_error "サポートされていないパッケージマネージャーです"
        return 1
    fi
    
    log_success "Grafanaがインストールされました"
}

# Grafanaの設定
configure_grafana() {
    log_info "Grafanaを設定中..."
    
    # 設定ファイルのバックアップ
    if [[ -f "$GRAFANA_CONFIG" ]]; then
        sudo cp "$GRAFANA_CONFIG" "${GRAFANA_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Grafana設定ファイルの作成
    sudo tee "$GRAFANA_CONFIG" > /dev/null << EOF
# TeaFarmOps Grafana設定

[server]
protocol = http
http_addr = 0.0.0.0
http_port = 3001
domain = localhost
root_url = http://localhost:3001/
serve_from_sub_path = false
enable_gzip = true

[database]
type = sqlite3
path = /var/lib/grafana/grafana.db

[security]
admin_user = admin
admin_password = teafarmops_grafana_2024
disable_initial_admin_creation = false
login_remember_days = 7
cookie_username = grafana_user
cookie_remember_name = grafana_remember
disable_gravatar = false
data_source_proxy_whitelist = 
disable_brute_force_login_protection = false

[users]
allow_sign_up = false
allow_org_create = false
auto_assign_org = true
auto_assign_org_role = Viewer
verify_email_enabled = false
login_hint = email or username
default_theme = dark

[auth.anonymous]
enabled = false
org_name = Main Org.
org_role = Viewer

[auth.basic]
enabled = true

[auth.ldap]
enabled = false
config_file = /etc/grafana/ldap.toml
allow_sign_up = true

[log]
mode = console file
level = info
format = text
file = /var/log/grafana/grafana.log
max_size = 100MB
max_days = 7
max_files = 10

[paths]
data = /var/lib/grafana
logs = /var/log/grafana
plugins = /var/lib/grafana/plugins
provisioning = /etc/grafana/provisioning

[metrics]
enabled = true
interval_seconds = 10

[snapshots]
external_enabled = true
external_snapshot_url = https://snapshots-origin.raintank.io
external_snapshot_name = Publish to snapshot.raintank.io
snapshot_remove_expired = true

[alerting]
enabled = true
execute_alerts = true
error_or_timeout = alerting
nodata_or_nullvalues = alerting
evaluation_timeout_seconds = 30
notification_timeout_seconds = 30
max_attempts = 3

[unified_alerting]
enabled = true

[explore]
enabled = true

[help]
enabled = true
type = external
path = https://grafana.com/docs/grafana/latest/

[profile]
enabled = false

[analytics]
reporting_enabled = true
check_for_updates = true
google_analytics_ua_id = 
google_tag_manager_id = 

[security]
disable_initial_admin_creation = false
admin_user = admin
admin_password = teafarmops_grafana_2024
login_remember_days = 7
cookie_username = grafana_user
cookie_remember_name = grafana_remember
disable_gravatar = false
data_source_proxy_whitelist = 
disable_brute_force_login_protection = false

[emails]
welcome_email_on_sign_up = false
templates_pattern = emails/*.html
content_types = text/html

[log]
mode = console file
level = info
format = text
file = /var/log/grafana/grafana.log
max_size = 100MB
max_days = 7
max_files = 10

[metrics]
enabled = true
interval_seconds = 10
basic_auth_username = 
basic_auth_password = 
metrics_graphite_address = 
metrics_graphite_prefix = 

[grafana_net]
url = https://grafana.net
EOF
    
    # 権限の設定
    sudo chown "$GRAFANA_USER:$GRAFANA_USER" "$GRAFANA_CONFIG"
    
    log_success "Grafana設定が完了しました"
}

# データソースの設定
configure_datasources() {
    log_info "データソースを設定中..."
    
    # Prometheusデータソース
    sudo tee /etc/grafana/provisioning/datasources/prometheus.yml > /dev/null << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
    editable: true
    jsonData:
      timeInterval: "15s"
      queryTimeout: "60s"
      httpMethod: "POST"
    secureJsonData: {}
EOF
    
    # PostgreSQLデータソース
    sudo tee /etc/grafana/provisioning/datasources/postgresql.yml > /dev/null << EOF
apiVersion: 1

datasources:
  - name: PostgreSQL
    type: postgres
    access: proxy
    url: localhost:5432
    database: teafarmops
    user: teafarmops
    secureJsonData:
      password: teafarmops_2024
    jsonData:
      sslmode: disable
      maxOpenConns: 100
      maxIdleConns: 100
      connMaxLifetime: 14400
      postgresVersion: 1200
      timescaledb: false
EOF
    
    # Redisデータソース
    sudo tee /etc/grafana/provisioning/datasources/redis.yml > /dev/null << EOF
apiVersion: 1

datasources:
  - name: Redis
    type: redis-datasource
    access: proxy
    url: redis://localhost:6379
    jsonData:
      client: standalone
      poolSize: 5
      timeout: 10
      pingInterval: 0
      pipelineWindow: 0
    secureJsonData:
      password: teafarmops_redis_2024
EOF
    
    # 権限の設定
    sudo chown -R "$GRAFANA_USER:$GRAFANA_USER" /etc/grafana/provisioning
    
    log_success "データソースが設定されました"
}

# ダッシュボードの設定
configure_dashboards() {
    log_info "ダッシュボードを設定中..."
    
    # システムオーバービューダッシュボード
    sudo tee /etc/grafana/provisioning/dashboards/system_overview.yml > /dev/null << EOF
apiVersion: 1

providers:
  - name: 'system_overview'
    orgId: 1
    folder: 'System'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards/system
EOF
    
    # システムダッシュボードディレクトリの作成
    sudo mkdir -p /etc/grafana/provisioning/dashboards/system
    
    # システムオーバービューダッシュボードJSON
    sudo tee /etc/grafana/provisioning/dashboards/system/system_overview.json > /dev/null << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "TeaFarmOps System Overview",
    "tags": ["system", "overview"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "CPU Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 85}
              ]
            },
            "unit": "percent"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 85}
              ]
            },
            "unit": "percent"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 0}
      },
      {
        "id": 3,
        "title": "Disk Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "(node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 85}
              ]
            },
            "unit": "percent"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 12, "y": 0}
      },
      {
        "id": 4,
        "title": "System Load",
        "type": "graph",
        "targets": [
          {
            "expr": "node_load1",
            "legendFormat": "1m",
            "refId": "A"
          },
          {
            "expr": "node_load5",
            "legendFormat": "5m",
            "refId": "B"
          },
          {
            "expr": "node_load15",
            "legendFormat": "15m",
            "refId": "C"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "id": 5,
        "title": "Network Traffic",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(node_network_receive_bytes_total[5m])",
            "legendFormat": "{{device}} - Receive",
            "refId": "A"
          },
          {
            "expr": "rate(node_network_transmit_bytes_total[5m])",
            "legendFormat": "{{device}} - Transmit",
            "refId": "B"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
EOF
    
    # データベースダッシュボード
    sudo tee /etc/grafana/provisioning/dashboards/system/database_overview.json > /dev/null << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "TeaFarmOps Database Overview",
    "tags": ["database", "postgresql"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Active Connections",
        "type": "stat",
        "targets": [
          {
            "expr": "pg_stat_database_numbackends",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 50},
                {"color": "red", "value": 80}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Transactions per Second",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(pg_stat_database_xact_commit[5m]) + rate(pg_stat_database_xact_rollback[5m])",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "reqps"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 0}
      },
      {
        "id": 3,
        "title": "Cache Hit Ratio",
        "type": "stat",
        "targets": [
          {
            "expr": "pg_stat_database_blks_hit / (pg_stat_database_blks_hit + pg_stat_database_blks_read) * 100",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "red", "value": null},
                {"color": "yellow", "value": 80},
                {"color": "green", "value": 95}
              ]
            },
            "unit": "percent"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 12, "y": 0}
      },
      {
        "id": 4,
        "title": "Database Size",
        "type": "stat",
        "targets": [
          {
            "expr": "pg_database_size_bytes",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "bytes"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 18, "y": 0}
      },
      {
        "id": 5,
        "title": "Active Queries",
        "type": "graph",
        "targets": [
          {
            "expr": "pg_stat_activity_count{state=\"active\"}",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "id": 6,
        "title": "Deadlocks",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(pg_stat_database_deadlocks[5m])",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
EOF
    
    # キャッシュダッシュボード
    sudo tee /etc/grafana/provisioning/dashboards/system/cache_overview.json > /dev/null << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "TeaFarmOps Cache Overview",
    "tags": ["cache", "redis"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Connected Clients",
        "type": "stat",
        "targets": [
          {
            "expr": "redis_connected_clients",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 50},
                {"color": "red", "value": 100}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Memory Usage",
        "type": "stat",
        "targets": [
          {
            "expr": "redis_memory_used_bytes / redis_memory_max_bytes * 100",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 70},
                {"color": "red", "value": 85}
              ]
            },
            "unit": "percent"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 0}
      },
      {
        "id": 3,
        "title": "Commands per Second",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(redis_commands_processed_total[5m])",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "reqps"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 12, "y": 0}
      },
      {
        "id": 4,
        "title": "Hit Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "redis_keyspace_hits / (redis_keyspace_hits + redis_keyspace_misses) * 100",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "red", "value": null},
                {"color": "yellow", "value": 80},
                {"color": "green", "value": 95}
              ]
            },
            "unit": "percent"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 18, "y": 0}
      },
      {
        "id": 5,
        "title": "Commands Over Time",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(redis_commands_processed_total[5m])",
            "legendFormat": "Commands/sec",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "id": 6,
        "title": "Memory Usage Over Time",
        "type": "graph",
        "targets": [
          {
            "expr": "redis_memory_used_bytes",
            "legendFormat": "Memory Used",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
EOF
    
    # Webサーバーダッシュボード
    sudo tee /etc/grafana/provisioning/dashboards/system/webserver_overview.json > /dev/null << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "TeaFarmOps Web Server Overview",
    "tags": ["webserver", "nginx"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Requests per Second",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(nginx_http_requests_total[5m])",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "reqps"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Active Connections",
        "type": "stat",
        "targets": [
          {
            "expr": "nginx_http_connections_active",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 500},
                {"color": "red", "value": 1000}
              ]
            }
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 0}
      },
      {
        "id": 3,
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(nginx_http_requests_total{status=~\"5..\"}[5m]) / rate(nginx_http_requests_total[5m]) * 100",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 1},
                {"color": "red", "value": 5}
              ]
            },
            "unit": "percent"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 12, "y": 0}
      },
      {
        "id": 4,
        "title": "Response Time",
        "type": "stat",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(nginx_http_request_duration_seconds_bucket[5m]))",
            "refId": "A"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 0.5},
                {"color": "red", "value": 1}
              ]
            },
            "unit": "s"
          }
        },
        "gridPos": {"h": 8, "w": 6, "x": 18, "y": 0}
      },
      {
        "id": 5,
        "title": "Requests Over Time",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(nginx_http_requests_total[5m])",
            "legendFormat": "Requests/sec",
            "refId": "A"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "id": 6,
        "title": "Response Time Distribution",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.5, rate(nginx_http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "50th percentile",
            "refId": "A"
          },
          {
            "expr": "histogram_quantile(0.95, rate(nginx_http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile",
            "refId": "B"
          },
          {
            "expr": "histogram_quantile(0.99, rate(nginx_http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "99th percentile",
            "refId": "C"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "30s"
  }
}
EOF
    
    # 権限の設定
    sudo chown -R "$GRAFANA_USER:$GRAFANA_USER" /etc/grafana/provisioning
    
    log_success "ダッシュボードが設定されました"
}

# Grafanaサービスの開始
start_grafana() {
    log_info "Grafanaサービスを開始中..."
    
    # サービスの開始
    sudo systemctl start grafana-server
    
    # サービスの状態確認
    if sudo systemctl is-active --quiet grafana-server; then
        log_success "Grafanaサービスが開始されました"
    else
        log_error "Grafanaサービスの開始に失敗しました"
        return 1
    fi
    
    # 起動待機
    log_info "Grafanaの起動を待機中..."
    sleep 10
    
    log_success "Grafanaが開始されました"
}

# ダッシュボードのテスト
test_dashboards() {
    log_info "ダッシュボードをテスト中..."
    
    echo ""
    echo "=== Grafana接続テスト ==="
    
    # Grafana接続テスト
    if curl -s http://localhost:3001/api/health | grep -q "ok"; then
        log_success "Grafana API接続が成功しました"
    else
        log_error "Grafana API接続に失敗しました"
    fi
    
    echo ""
    echo "=== データソース接続テスト ==="
    
    # データソース接続テスト
    local datasources=(
        "http://localhost:3001/api/datasources/name/Prometheus:Prometheus"
        "http://localhost:3001/api/datasources/name/PostgreSQL:PostgreSQL"
        "http://localhost:3001/api/datasources/name/Redis:Redis"
    )
    
    for ds in "${datasources[@]}"; do
        local name=$(echo "$ds" | cut -d: -f2)
        if curl -s "$ds" | grep -q "id"; then
            log_success "$name データソース接続が成功しました"
        else
            log_warning "$name データソース接続に失敗しました"
        fi
    done
    
    echo ""
    echo "=== ダッシュボード確認 ==="
    
    # ダッシュボード確認
    local dashboards=(
        "TeaFarmOps System Overview"
        "TeaFarmOps Database Overview"
        "TeaFarmOps Cache Overview"
        "TeaFarmOps Web Server Overview"
    )
    
    for dashboard in "${dashboards[@]}"; do
        local result=$(curl -s "http://localhost:3001/api/search?query=$dashboard" | grep -c "title")
        if [[ $result -gt 0 ]]; then
            log_success "ダッシュボード '$dashboard' が存在します"
        else
            log_warning "ダッシュボード '$dashboard' が見つかりません"
        fi
    done
    
    log_success "ダッシュボードのテストが完了しました"
}

# 監視状態の確認
monitor_status() {
    log_info "Grafana監視状態を確認中..."
    
    echo ""
    echo "=== Grafanaサービス状態 ==="
    
    if sudo systemctl is-active --quiet grafana-server; then
        echo "✅ Grafana: 稼働中"
    else
        echo "❌ Grafana: 停止中"
    fi
    
    echo ""
    echo "=== ポート監視 ==="
    
    if ss -tuln | grep -q ":3001 "; then
        echo "✅ ポート 3001: 開いている"
    else
        echo "❌ ポート 3001: 閉じている"
    fi
    
    echo ""
    echo "=== Grafana統計 ==="
    
    # Grafana統計
    local version=$(curl -s http://localhost:3001/api/health | jq -r '.version' 2>/dev/null || echo "N/A")
    echo "Grafanaバージョン: $version"
    
    local datasource_count=$(curl -s http://localhost:3001/api/datasources | jq 'length' 2>/dev/null || echo "0")
    echo "データソース数: $datasource_count"
    
    local dashboard_count=$(curl -s http://localhost:3001/api/search | jq 'length' 2>/dev/null || echo "0")
    echo "ダッシュボード数: $dashboard_count"
    
    echo ""
    echo "=== アクセス情報 ==="
    echo "Grafana URL: http://localhost:3001"
    echo "デフォルトユーザー: admin"
    echo "デフォルトパスワード: teafarmops_grafana_2024"
}

# メイン処理
main() {
    local start_time=$(date +%s)
    
    log_info "TeaFarmOps Grafanaダッシュボード管理を開始します..."
    
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
        install_grafana
    fi
    
    if [[ "$CONFIGURE" == "true" ]]; then
        configure_grafana
        configure_datasources
    fi
    
    if [[ "$DASHBOARDS" == "true" ]]; then
        configure_dashboards
    fi
    
    if [[ "$START" == "true" ]]; then
        start_grafana
    fi
    
    if [[ "$TEST" == "true" ]]; then
        test_dashboards
    fi
    
    if [[ "$MONITOR" == "true" ]]; then
        monitor_status
    fi
    
    # デフォルト動作（オプションが指定されていない場合）
    if [[ "$INSTALL" == "false" && "$CONFIGURE" == "false" && "$START" == "false" && "$TEST" == "false" && "$MONITOR" == "false" && "$DASHBOARDS" == "false" ]]; then
        log_info "デフォルト動作: 包括的セットアップを実行"
        install_grafana
        configure_grafana
        configure_datasources
        configure_dashboards
        start_grafana
        test_dashboards
        monitor_status
    fi
    
    # 完了通知
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "Grafanaダッシュボード管理が完了しました（実行時間: ${duration}秒）"
    log_info "Grafana UI: http://localhost:3001"
    log_info "ログファイル: $LOG_FILE"
}

# スクリプト実行
main "$@" 