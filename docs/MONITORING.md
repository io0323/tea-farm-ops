# 監視システムドキュメント

## 概要

TeaFarmOpsプロジェクトの監視システムは、Prometheus + Grafana + Alertmanagerを使用して、アプリケーションとインフラの包括的な監視を提供します。

## アーキテクチャ

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   Infrastructure│    │   Monitoring    │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Spring Boot │ │    │ │ PostgreSQL  │ │    │ │ Prometheus  │ │
│ │ (Metrics)   │ │    │ │ (Exporter)  │ │    │ │ (Collector) │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ React App   │ │    │ │ Nginx       │ │    │ │ Grafana     │ │
│ │ (Frontend)  │ │    │ │ (Exporter)  │ │    │ │ (Dashboard) │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Node.js     │ │    │ │ Docker      │ │    │ │ Alertmanager│ │
│ │ (Metrics)   │ │    │ │ (Exporter)  │ │    │ │ (Alerts)    │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 監視対象

### アプリケーション層
- **Spring Boot API**: JVMメトリクス、HTTPリクエスト、レスポンス時間
- **React フロントエンド**: ページビュー、エラー率、パフォーマンス
- **ビジネスメトリクス**: アクティブユーザー、タスク数、フィールド数

### インフラ層
- **PostgreSQL**: 接続数、クエリ実行時間、ロック状況
- **Nginx**: リクエスト数、エラー率、レスポンス時間
- **Docker**: コンテナ状態、リソース使用量
- **システム**: CPU、メモリ、ディスク、ネットワーク

## コンポーネント

### 1. Prometheus
- **役割**: メトリクス収集・保存
- **ポート**: 9090
- **設定**: `monitoring/prometheus/prometheus.yml`
- **アラートルール**: `monitoring/prometheus/rules/alerts.yml`

### 2. Grafana
- **役割**: ダッシュボード・可視化
- **ポート**: 3001
- **デフォルト認証**: admin/admin
- **設定**: `monitoring/grafana/grafana.ini`

### 3. Alertmanager
- **役割**: アラート管理・通知
- **ポート**: 9093
- **設定**: `monitoring/alertmanager/alertmanager.yml`

### 4. Exporters
- **Node Exporter**: システムメトリクス (ポート: 9100)
- **PostgreSQL Exporter**: データベースメトリクス (ポート: 9187)
- **Nginx Exporter**: Webサーバーメトリクス (ポート: 9113)
- **Docker Exporter**: コンテナメトリクス (ポート: 9323)

## セットアップ

### 1. 監視システムの起動

```bash
# 監視システムのみを起動
./scripts/start-monitoring.sh --monitor

# フルスタック（アプリ + 監視）を起動
./scripts/start-monitoring.sh --full

# 監視システムを停止
./scripts/start-monitoring.sh --stop

# 監視システムを再起動
./scripts/start-monitoring.sh --restart
```

### 2. 手動起動

```bash
# Docker Composeで監視サービスを起動
docker-compose --profile monitoring up -d

# 特定のサービスを起動
docker-compose --profile monitoring up -d prometheus grafana alertmanager
```

## ダッシュボード

### TeaFarmOps Overview
- **URL**: http://localhost:3001
- **認証**: admin/admin
- **内容**:
  - システム概要（サービス状態）
  - CPU・メモリ使用率
  - HTTPリクエスト数・レスポンス時間
  - データベース接続数
  - JVMヒープ使用率
  - アクティブユーザー数
  - エラー率
  - ディスク使用率

### カスタムダッシュボード
- **ビジネスメトリクス**: ユーザー活動、タスク進捗
- **パフォーマンス**: API応答時間、データベースクエリ
- **エラー監視**: エラー率、例外発生状況
- **リソース監視**: システムリソース使用量

## アラート

### システムアラート
- **高CPU使用率**: 80%を超えた場合
- **高メモリ使用率**: 85%を超えた場合
- **高ディスク使用率**: 85%を超えた場合

### アプリケーションアラート
- **Spring Boot停止**: アプリケーションが応答しない場合
- **高HTTPエラー率**: 5xxエラーが5%を超えた場合
- **高レスポンス時間**: 95パーセンタイルが2秒を超えた場合

### データベースアラート
- **PostgreSQL停止**: データベースが応答しない場合
- **高接続数**: 80接続を超えた場合
- **遅いクエリ**: 30秒を超えるクエリが実行された場合

### JVMアラート
- **高ヒープ使用率**: 80%を超えた場合
- **高GC時間**: GC時間が増加した場合

## メトリクス

### アプリケーションメトリクス
```promql
# HTTPリクエスト数
rate(http_requests_total[5m])

# レスポンス時間
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# エラー率
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100
```

### システムメトリクス
```promql
# CPU使用率
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# メモリ使用率
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# ディスク使用率
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100
```

### ビジネスメトリクス
```promql
# アクティブユーザー数
tea_farm_ops_active_users

# エラー率
rate(tea_farm_ops_errors_total[5m])

# ログイン成功率
rate(tea_farm_ops_successful_logins_total[5m]) / rate(tea_farm_ops_login_attempts_total[5m]) * 100
```

## 通知設定

### Slack通知
- **チャンネル**: #tea-farm-ops-alerts
- **重要度別**:
  - Critical: #tea-farm-ops-critical
  - Warning: #tea-farm-ops-warnings

### メール通知
- **宛先**: admin@your-domain.com
- **送信者**: alertmanager@your-domain.com
- **SMTP**: smtp.gmail.com:587

## メンテナンス

### データ保持期間
- **Prometheus**: 200時間（約8日）
- **Grafana**: 永続化（SQLite）
- **Alertmanager**: 永続化

### バックアップ
```bash
# Prometheusデータのバックアップ
docker cp tea-farm-ops-prometheus:/prometheus ./backup/prometheus

# Grafana設定のバックアップ
docker cp tea-farm-ops-grafana:/var/lib/grafana ./backup/grafana
```

### ログローテーション
```bash
# ログファイルのローテーション設定
logrotate /etc/logrotate.d/tea-farm-ops-monitoring
```

## トラブルシューティング

### よくある問題

#### 1. Prometheusがメトリクスを収集できない
```bash
# ターゲットの状態を確認
curl http://localhost:9090/api/v1/targets

# 設定ファイルの構文チェック
docker exec tea-farm-ops-prometheus promtool check config /etc/prometheus/prometheus.yml
```

#### 2. Grafanaにダッシュボードが表示されない
```bash
# データソースの接続を確認
curl http://localhost:3001/api/datasources

# プロビジョニング設定を確認
docker exec tea-farm-ops-grafana cat /etc/grafana/provisioning/datasources/prometheus.yml
```

#### 3. アラートが発報されない
```bash
# アラートルールの状態を確認
curl http://localhost:9090/api/v1/rules

# Alertmanagerの設定を確認
docker exec tea-farm-ops-alertmanager amtool check-config /etc/alertmanager/alertmanager.yml
```

### デバッグ方法

#### 1. メトリクス収集の確認
```bash
# Spring Bootメトリクスエンドポイント
curl http://localhost:8080/actuator/prometheus

# Node Exporterメトリクス
curl http://localhost:9100/metrics

# PostgreSQL Exporterメトリクス
curl http://localhost:9187/metrics
```

#### 2. ログの確認
```bash
# Prometheusログ
docker logs tea-farm-ops-prometheus

# Grafanaログ
docker logs tea-farm-ops-grafana

# Alertmanagerログ
docker logs tea-farm-ops-alertmanager
```

#### 3. 設定の確認
```bash
# Prometheus設定
docker exec tea-farm-ops-prometheus cat /etc/prometheus/prometheus.yml

# Grafana設定
docker exec tea-farm-ops-grafana cat /etc/grafana/grafana.ini

# Alertmanager設定
docker exec tea-farm-ops-alertmanager cat /etc/alertmanager/alertmanager.yml
```

## パフォーマンス最適化

### 1. メトリクス収集間隔の調整
```yaml
# prometheus.yml
scrape_interval: 15s  # デフォルト
scrape_interval: 30s  # 負荷軽減
scrape_interval: 60s  # 大幅軽減
```

### 2. データ保持期間の調整
```yaml
# prometheus.yml
storage:
  tsdb:
    retention.time: 200h  # デフォルト
    retention.time: 7d    # 1週間
    retention.time: 30d   # 1ヶ月
```

### 3. アラート間隔の調整
```yaml
# alertmanager.yml
route:
  group_wait: 30s      # グループ待機時間
  group_interval: 5m   # グループ間隔
  repeat_interval: 12h # 繰り返し間隔
```

## セキュリティ

### 1. 認証設定
```ini
# grafana.ini
[security]
admin_user = admin
admin_password = strong-password
secret_key = your-secret-key
```

### 2. ネットワーク分離
```yaml
# docker-compose.yml
networks:
  monitoring:
    driver: bridge
    internal: true  # 外部からのアクセスを制限
```

### 3. TLS設定
```yaml
# prometheus.yml
tls_config:
  ca_file: /etc/prometheus/certs/ca.crt
  cert_file: /etc/prometheus/certs/prometheus.crt
  key_file: /etc/prometheus/certs/prometheus.key
```

## 参考資料

- [Prometheus 公式ドキュメント](https://prometheus.io/docs/)
- [Grafana 公式ドキュメント](https://grafana.com/docs/)
- [Alertmanager 公式ドキュメント](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html) 