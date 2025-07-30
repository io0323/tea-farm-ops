# TeaFarmOps 監視システム強化

## 概要

TeaFarmOps監視システム強化は、Prometheus、Grafana、Alertmanagerを統合した包括的な監視ソリューションです。システム、アプリケーション、インフラストラクチャの包括的な監視、アラート、可視化を提供します。

## システム構成

### コアコンポーネント

#### 1. Prometheus (メトリクス収集)
- **ポート**: 9090
- **役割**: 時系列データベースとメトリクス収集
- **機能**:
  - システムメトリクス収集
  - アプリケーションメトリクス収集
  - カスタムメトリクス対応
  - アラートルール評価

#### 2. Grafana (可視化・ダッシュボード)
- **ポート**: 3001
- **役割**: データ可視化とダッシュボード
- **機能**:
  - リアルタイムダッシュボード
  - カスタムグラフ作成
  - アラート可視化
  - レポート生成

#### 3. Alertmanager (アラート管理)
- **ポート**: 9093
- **役割**: アラート集約と通知
- **機能**:
  - アラート集約
  - 通知ルーティング
  - アラート抑制
  - サイレンス管理

### エクスポーター

#### 1. Node Exporter
- **ポート**: 9100
- **役割**: システムメトリクス収集
- **収集項目**:
  - CPU使用率
  - メモリ使用率
  - ディスク使用率
  - ネットワーク統計
  - システム負荷

#### 2. Redis Exporter
- **ポート**: 9121
- **役割**: Redisメトリクス収集
- **収集項目**:
  - 接続数
  - メモリ使用率
  - コマンド統計
  - キースペース情報

#### 3. PostgreSQL Exporter
- **ポート**: 9187
- **役割**: PostgreSQLメトリクス収集
- **収集項目**:
  - 接続数
  - クエリ統計
  - キャッシュヒット率
  - デッドロック情報

#### 4. Nginx Exporter
- **ポート**: 9113
- **役割**: Nginxメトリクス収集
- **収集項目**:
  - リクエスト数
  - レスポンス時間
  - エラー率
  - 接続数

## インストール

### 前提条件

- Ubuntu 20.04 LTS以上
- 管理者権限
- インターネット接続
- 最低4GB RAM
- 最低20GB 空き容量

### 自動インストール

```bash
# 包括的インストール
sudo ./scripts/monitoring-manage.sh --install

# 個別インストール
sudo ./scripts/monitoring-prometheus.sh --install
sudo ./scripts/monitoring-grafana.sh --install
sudo ./scripts/monitoring-alertmanager.sh --install
```

### 手動インストール

#### 1. Prometheusインストール

```bash
# ユーザー作成
sudo useradd --no-create-home --shell /bin/false prometheus

# ディレクトリ作成
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# ダウンロード・インストール
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar -xzf prometheus-2.45.0.linux-amd64.tar.gz
sudo cp prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.45.0.linux-amd64/promtool /usr/local/bin/
```

#### 2. Grafanaインストール

```bash
# リポジトリ追加
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# インストール
sudo apt-get update
sudo apt-get install -y grafana
```

#### 3. Alertmanagerインストール

```bash
# ダウンロード・インストール
wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz
tar -xzf alertmanager-0.26.0.linux-amd64.tar.gz
sudo cp alertmanager-0.26.0.linux-amd64/alertmanager /usr/local/bin/
sudo cp alertmanager-0.26.0.linux-amd64/amtool /usr/local/bin/
```

## 設定

### 設定ファイル

#### 1. Prometheus設定 (`/etc/prometheus/prometheus.yml`)

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'redis-exporter'
    static_configs:
      - targets: ['localhost:9121']

  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['localhost:9187']

  - job_name: 'nginx-exporter'
    static_configs:
      - targets: ['localhost:9113']
```

#### 2. Grafana設定 (`/etc/grafana/grafana.ini`)

```ini
[server]
http_port = 3001
root_url = http://localhost:3001/

[security]
admin_user = admin
admin_password = teafarmops_grafana_2024

[database]
type = sqlite3
path = /var/lib/grafana/grafana.db
```

#### 3. Alertmanager設定 (`/etc/alertmanager/alertmanager.yml`)

```yaml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alertmanager@teafarmops.local'

route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'tea-farm-ops-team'

receivers:
  - name: 'tea-farm-ops-team'
    email_configs:
      - to: 'team@teafarmops.local'
```

### 自動設定

```bash
# 包括的設定
sudo ./scripts/monitoring-manage.sh --configure

# 個別設定
sudo ./scripts/monitoring-prometheus.sh --configure
sudo ./scripts/monitoring-grafana.sh --configure
sudo ./scripts/monitoring-alertmanager.sh --configure
```

## 使用方法

### サービスの開始

```bash
# 包括的開始
sudo ./scripts/monitoring-manage.sh --start

# 個別開始
sudo systemctl start prometheus
sudo systemctl start grafana-server
sudo systemctl start alertmanager
```

### サービスの停止

```bash
sudo systemctl stop prometheus grafana-server alertmanager
```

### サービスの再起動

```bash
sudo systemctl restart prometheus grafana-server alertmanager
```

### サービスの状態確認

```bash
# 包括的状態確認
sudo ./scripts/monitoring-manage.sh --monitor

# 個別状態確認
sudo systemctl status prometheus
sudo systemctl status grafana-server
sudo systemctl status alertmanager
```

## ダッシュボード

### システムオーバービュー

- **CPU使用率**: リアルタイムCPU使用率表示
- **メモリ使用率**: メモリ使用状況の可視化
- **ディスク使用率**: ストレージ使用状況
- **システム負荷**: システム負荷の推移
- **ネットワークトラフィック**: ネットワーク使用状況

### データベース監視

- **接続数**: アクティブ接続数の監視
- **クエリ統計**: クエリ実行統計
- **キャッシュヒット率**: データベースキャッシュ効率
- **デッドロック**: デッドロック発生状況
- **レプリケーションラグ**: レプリケーション遅延

### キャッシュ監視

- **接続数**: Redis接続数
- **メモリ使用率**: Redisメモリ使用状況
- **コマンド統計**: コマンド実行統計
- **ヒット率**: キャッシュヒット率
- **キー数**: 保存キー数

### Webサーバー監視

- **リクエスト数**: HTTPリクエスト統計
- **レスポンス時間**: レスポンス時間分布
- **エラー率**: HTTPエラー率
- **接続数**: アクティブ接続数
- **帯域幅**: ネットワーク帯域使用量

## アラート

### システムアラート

#### 高CPU使用率
- **条件**: CPU使用率 > 80%
- **期間**: 5分間
- **重要度**: 警告
- **アクション**: リソース使用状況の確認

#### 高メモリ使用率
- **条件**: メモリ使用率 > 85%
- **期間**: 5分間
- **重要度**: 警告
- **アクション**: メモリ使用状況の確認

#### 高ディスク使用率
- **条件**: ディスク使用率 > 85%
- **期間**: 5分間
- **重要度**: 警告
- **アクション**: ストレージ拡張の検討

### データベースアラート

#### 高接続数
- **条件**: 接続数 > 80
- **期間**: 5分間
- **重要度**: 警告
- **アクション**: 接続プールの確認

#### デッドロック発生
- **条件**: デッドロック > 0.1/分
- **期間**: 5分間
- **重要度**: 警告
- **アクション**: クエリ最適化の検討

### キャッシュアラート

#### 高メモリ使用率
- **条件**: メモリ使用率 > 80%
- **期間**: 5分間
- **重要度**: 警告
- **アクション**: キャッシュサイズの調整

#### 低ヒット率
- **条件**: ヒット率 < 80%
- **期間**: 5分間
- **重要度**: 警告
- **アクション**: キャッシュ戦略の見直し

## 通知設定

### メール通知

```yaml
receivers:
  - name: 'tea-farm-ops-team'
    email_configs:
      - to: 'team@teafarmops.local'
        send_resolved: true
        headers:
          subject: 'TeaFarmOps Alert: {{ .GroupLabels.alertname }}'
```

### Slack通知

```yaml
receivers:
  - name: 'tea-farm-ops-team'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR_WEBHOOK'
        channel: '#tea-farm-ops-alerts'
        title: 'TeaFarmOps Alert: {{ .GroupLabels.alertname }}'
```

### Webhook通知

```yaml
receivers:
  - name: 'tea-farm-ops-team'
    webhook_configs:
      - url: 'http://localhost:8080/webhook'
        send_resolved: true
```

## メトリクス

### システムメトリクス

#### CPU関連
- `node_cpu_seconds_total`: CPU使用時間
- `node_cpu_seconds_total{mode="idle"}`: アイドル時間
- `rate(node_cpu_seconds_total[5m])`: CPU使用率

#### メモリ関連
- `node_memory_MemTotal_bytes`: 総メモリ
- `node_memory_MemAvailable_bytes`: 利用可能メモリ
- `node_memory_MemUsed_bytes`: 使用メモリ

#### ディスク関連
- `node_filesystem_size_bytes`: ファイルシステムサイズ
- `node_filesystem_avail_bytes`: 利用可能容量
- `node_filesystem_used_bytes`: 使用容量

#### ネットワーク関連
- `node_network_receive_bytes_total`: 受信バイト数
- `node_network_transmit_bytes_total`: 送信バイト数
- `rate(node_network_receive_bytes_total[5m])`: 受信レート

### アプリケーションメトリクス

#### Spring Boot
- `http_server_requests_total`: HTTPリクエスト数
- `http_server_requests_seconds`: レスポンス時間
- `jvm_memory_used_bytes`: JVMメモリ使用量
- `jvm_gc_collection_seconds`: GC時間

#### Redis
- `redis_connected_clients`: 接続クライアント数
- `redis_memory_used_bytes`: メモリ使用量
- `redis_commands_processed_total`: 処理コマンド数
- `redis_keyspace_hits`: キャッシュヒット数

#### PostgreSQL
- `pg_stat_database_numbackends`: 接続数
- `pg_stat_database_xact_commit`: コミット数
- `pg_stat_database_deadlocks`: デッドロック数
- `pg_stat_activity_count`: アクティブクエリ数

## ログ管理

### ログローテーション

```bash
# ログローテーション設定
sudo ./scripts/monitoring-logrotate.sh --daily

# ログクリーンアップ
sudo ./scripts/monitoring-cleanup.sh --logs
```

### ログレベル

- **DEBUG**: 詳細なデバッグ情報
- **INFO**: 一般的な情報
- **WARN**: 警告メッセージ
- **ERROR**: エラーメッセージ

### ログファイル

- `/var/log/prometheus/prometheus.log`: Prometheusログ
- `/var/log/grafana/grafana.log`: Grafanaログ
- `/var/log/alertmanager/alertmanager.log`: Alertmanagerログ
- `/var/log/tea-farm-ops/monitoring/`: 統合ログ

## バックアップ

### 自動バックアップ

```bash
# 包括的バックアップ
sudo ./scripts/monitoring-manage.sh --backup

# 個別バックアップ
sudo ./scripts/monitoring-backup.sh --full
```

### バックアップ内容

- 設定ファイル
- データベース
- ログファイル
- ダッシュボード設定

### バックアップスケジュール

- **日次**: 完全バックアップ
- **週次**: 増分バックアップ
- **月次**: 差分バックアップ

## パフォーマンス最適化

### Prometheus最適化

```yaml
# ストレージ設定
storage:
  tsdb:
    retention.time: 15d
    retention.size: 50GB
    wal:
      retention.period: 2h
      retention.size: 5GB

# スクレイプ設定
global:
  scrape_interval: 15s
  evaluation_interval: 15s
```

### Grafana最適化

```ini
[performance]
max_concurrent_connections = 100
max_connections_per_host = 10
connection_timeout = 30
read_timeout = 60
write_timeout = 60
```

### Alertmanager最適化

```yaml
global:
  resolve_timeout: 5m

route:
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
```

## セキュリティ

### 認証・認可

#### Grafana認証
```ini
[security]
admin_user = admin
admin_password = teafarmops_grafana_2024
disable_initial_admin_creation = false
allow_sign_up = false
```

#### Prometheus認証
```yaml
# 基本認証
basic_auth_users:
  admin: $2y$10$hashed_password
```

### ネットワークセキュリティ

#### ファイアウォール設定
```bash
# 必要なポートのみ開放
sudo ufw allow 9090/tcp  # Prometheus
sudo ufw allow 3001/tcp  # Grafana
sudo ufw allow 9093/tcp  # Alertmanager
```

#### TLS設定
```yaml
# HTTPS設定
tls_config:
  cert_file: /etc/ssl/certs/monitoring.crt
  key_file: /etc/ssl/private/monitoring.key
```

## トラブルシューティング

### よくある問題

#### 1. Prometheusが起動しない

```bash
# 設定ファイルの検証
promtool check config /etc/prometheus/prometheus.yml

# ログの確認
sudo journalctl -u prometheus -f

# 権限の確認
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
```

#### 2. Grafanaにアクセスできない

```bash
# サービスの状態確認
sudo systemctl status grafana-server

# ポートの確認
sudo netstat -tlnp | grep 3001

# ファイアウォールの確認
sudo ufw status
```

#### 3. アラートが送信されない

```bash
# Alertmanagerの状態確認
sudo systemctl status alertmanager

# 設定ファイルの検証
amtool check-config /etc/alertmanager/alertmanager.yml

# 通知のテスト
curl -X POST http://localhost:9093/api/v1/alerts
```

### ログ分析

```bash
# エラーログの確認
sudo grep ERROR /var/log/prometheus/prometheus.log
sudo grep ERROR /var/log/grafana/grafana.log
sudo grep ERROR /var/log/alertmanager/alertmanager.log

# リアルタイムログ監視
sudo tail -f /var/log/tea-farm-ops/monitoring/*.log
```

### パフォーマンス診断

```bash
# システムリソース確認
sudo ./scripts/monitoring-performance.sh --diagnostic

# メトリクス収集状況確認
curl http://localhost:9090/api/v1/status/targets

# ストレージ使用状況確認
du -sh /var/lib/prometheus
du -sh /var/lib/grafana
```

## メンテナンス

### 定期メンテナンス

#### 日次メンテナンス
- ログローテーション
- バックアップ実行
- システム状態確認

#### 週次メンテナンス
- パフォーマンス分析
- アラートルール見直し
- セキュリティチェック

#### 月次メンテナンス
- システム更新
- 容量計画
- ドキュメント更新

### 更新手順

```bash
# 包括的更新
sudo ./scripts/monitoring-manage.sh --update

# 個別更新
sudo ./scripts/monitoring-prometheus.sh --update
sudo ./scripts/monitoring-grafana.sh --update
sudo ./scripts/monitoring-alertmanager.sh --update
```

## 監視項目

### システム監視

- **CPU使用率**: 80%以上でアラート
- **メモリ使用率**: 85%以上でアラート
- **ディスク使用率**: 85%以上でアラート
- **システム負荷**: 5以上でアラート
- **ネットワークエラー**: 0.1/分以上でアラート

### アプリケーション監視

- **レスポンス時間**: 2秒以上でアラート
- **エラー率**: 5%以上でアラート
- **JVMメモリ**: 85%以上でアラート
- **GC時間**: 0.1秒以上でアラート

### データベース監視

- **接続数**: 80以上でアラート
- **デッドロック**: 0.1/分以上でアラート
- **レプリケーションラグ**: 30秒以上でアラート
- **キャッシュヒット率**: 80%未満でアラート

### キャッシュ監視

- **接続数**: 100以上でアラート
- **メモリ使用率**: 80%以上でアラート
- **キー数**: 1,000,000以上でアラート
- **ヒット率**: 80%未満でアラート

## レポート

### 自動レポート生成

```bash
# 日次レポート
sudo ./scripts/monitoring-report.sh --daily

# 週次レポート
sudo ./scripts/monitoring-report.sh --weekly

# 月次レポート
sudo ./scripts/monitoring-report.sh --monthly
```

### レポート内容

- システム概要
- サービス状態
- パフォーマンス統計
- アラート履歴
- 推奨事項

## 統合

### 外部システム統合

#### Slack統合
```yaml
slack_configs:
  - api_url: 'https://hooks.slack.com/services/YOUR_WEBHOOK'
    channel: '#tea-farm-ops-alerts'
    title: 'TeaFarmOps Alert: {{ .GroupLabels.alertname }}'
```

#### メール統合
```yaml
email_configs:
  - to: 'team@teafarmops.local'
    send_resolved: true
    headers:
      subject: 'TeaFarmOps Alert: {{ .GroupLabels.alertname }}'
```

#### Webhook統合
```yaml
webhook_configs:
  - url: 'http://localhost:8080/webhook'
    send_resolved: true
```

### API統合

#### Prometheus API
```bash
# メトリクス取得
curl http://localhost:9090/api/v1/query?query=up

# ターゲット状態確認
curl http://localhost:9090/api/v1/targets

# アラート確認
curl http://localhost:9090/api/v1/alerts
```

#### Grafana API
```bash
# ダッシュボード一覧
curl http://localhost:3001/api/search

# データソース一覧
curl http://localhost:3001/api/datasources

# ユーザー一覧
curl http://localhost:3001/api/admin/users
```

#### Alertmanager API
```bash
# アラート確認
curl http://localhost:9093/api/v1/alerts

# サイレンス確認
curl http://localhost:9093/api/v1/silences

# 設定確認
curl http://localhost:9093/api/v1/status/config
```

## ベストプラクティス

### 設定管理

1. **設定ファイルのバージョン管理**
   - Gitで設定ファイルを管理
   - 変更履歴の記録
   - ロールバック機能の準備

2. **環境別設定**
   - 開発環境
   - ステージング環境
   - 本番環境

3. **設定検証**
   - デプロイ前の設定検証
   - 構文チェック
   - 機能テスト

### パフォーマンス最適化

1. **リソース管理**
   - 適切なストレージサイズ設定
   - メモリ使用量の監視
   - CPU使用率の最適化

2. **データ保持**
   - 適切な保持期間設定
   - データ圧縮の活用
   - 古いデータの削除

3. **スクレイプ間隔**
   - 重要度に応じた間隔設定
   - システム負荷の考慮
   - データ精度のバランス

### セキュリティ

1. **認証・認可**
   - 強力なパスワード設定
   - 多要素認証の活用
   - 最小権限の原則

2. **ネットワークセキュリティ**
   - ファイアウォール設定
   - VPN接続の活用
   - 暗号化通信の使用

3. **監査ログ**
   - アクセスログの記録
   - 変更履歴の追跡
   - セキュリティイベントの監視

### 運用管理

1. **監視の監視**
   - 監視システム自体の監視
   - 自己診断機能の活用
   - 冗長化の実装

2. **自動化**
   - 自動バックアップ
   - 自動復旧機能
   - 自動スケーリング

3. **ドキュメント管理**
   - 設定ドキュメントの整備
   - 運用手順書の作成
   - トラブルシューティングガイド

## サポート

### ログファイル

- `/var/log/tea-farm-ops/monitoring/manage.log`: 管理スクリプトログ
- `/var/log/tea-farm-ops/monitoring/prometheus.log`: Prometheusログ
- `/var/log/tea-farm-ops/monitoring/grafana.log`: Grafanaログ
- `/var/log/tea-farm-ops/monitoring/alertmanager.log`: Alertmanagerログ

### 設定ファイル

- `/etc/tea-farm-ops/monitoring-config.yml`: 統合設定ファイル
- `/etc/prometheus/prometheus.yml`: Prometheus設定
- `/etc/grafana/grafana.ini`: Grafana設定
- `/etc/alertmanager/alertmanager.yml`: Alertmanager設定

### スクリプト

- `scripts/monitoring-manage.sh`: 包括的管理スクリプト
- `scripts/monitoring-prometheus.sh`: Prometheus管理スクリプト
- `scripts/monitoring-grafana.sh`: Grafana管理スクリプト
- `scripts/monitoring-alertmanager.sh`: Alertmanager管理スクリプト

### アクセス情報

- **Prometheus UI**: http://localhost:9090
- **Grafana UI**: http://localhost:3001
  - ユーザー: admin
  - パスワード: teafarmops_grafana_2024
- **Alertmanager UI**: http://localhost:9093

### 緊急時連絡先

- **技術サポート**: support@teafarmops.local
- **緊急時**: +1-555-0123
- **Slack**: #tea-farm-ops-support

## 更新履歴

### v1.0.0 (2024-01-XX)
- 初回リリース
- Prometheus、Grafana、Alertmanager統合
- 基本的な監視機能
- アラート機能
- ダッシュボード機能

### 今後の予定

- **v1.1.0**: 高度なアラート機能
- **v1.2.0**: 自動復旧機能
- **v1.3.0**: 機械学習による異常検知
- **v2.0.0**: マイクロサービス対応 