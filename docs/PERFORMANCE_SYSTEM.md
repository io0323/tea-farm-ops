# TeaFarmOps パフォーマンス最適化システム

## 概要

TeaFarmOps パフォーマンス最適化システムは、アプリケーションの高速化と効率化を実現する包括的なソリューションです。キャッシュシステム、データベース最適化、Webサーバー最適化を統合し、自動化された監視と最適化機能を提供します。

## 機能

### 🔥 キャッシュシステム最適化
- **Redis** による高速キャッシュ
- **Redis Sentinel** による高可用性
- 自動メモリ管理とクリーンアップ
- パフォーマンステストと監視

### 🗄️ データベース最適化
- **PostgreSQL** 設定最適化
- 自動VACUUMとANALYZE
- インデックス最適化
- クエリパフォーマンス監視

### 🌐 Webサーバー最適化
- **Nginx** 設定最適化
- SSL/TLS最適化
- Gzip圧縮設定
- プロキシ設定最適化

### 📊 包括的監視
- システムリソース監視
- パフォーマンス指標収集
- アラート機能
- 自動レポート生成

## インストール

### 前提条件
- Ubuntu 20.04+ / CentOS 8+ / RHEL 8+
- sudo権限
- インターネット接続

### 1. スクリプトの配置
```bash
# スクリプトを適切なディレクトリに配置
sudo mkdir -p /app/scripts
sudo cp scripts/performance-*.sh /app/scripts/
sudo chmod +x /app/scripts/performance-*.sh
```

### 2. 設定ファイルの配置
```bash
# 設定ファイルを配置
sudo mkdir -p /etc/tea-farm-ops
sudo cp config/performance-config.yml /etc/tea-farm-ops/
```

### 3. 環境変数の設定
```bash
# 環境変数を設定
export REDIS_PASSWORD="your_secure_redis_password"
export DB_PASSWORD="your_secure_db_password"
export EMAIL_PASSWORD="your_email_password"
export SLACK_WEBHOOK_URL="your_slack_webhook_url"
```

### 4. 自動化スケジュールの設定
```bash
# cronジョブを設定
crontab config/performance-crontab
```

## 使用方法

### キャッシュシステム管理

#### Redisのインストールと設定
```bash
# 包括的セットアップ
sudo /app/scripts/performance-cache.sh

# 個別操作
sudo /app/scripts/performance-cache.sh --install    # インストール
sudo /app/scripts/performance-cache.sh --configure  # 設定
sudo /app/scripts/performance-cache.sh --test       # テスト
sudo /app/scripts/performance-cache.sh --monitor    # 監視
sudo /app/scripts/performance-cache.sh --optimize   # 最適化
```

#### Redis設定の詳細
- **メモリ管理**: 256MB制限、LRUポリシー
- **永続化**: RDBスナップショット
- **高可用性**: Sentinel設定
- **セキュリティ**: パスワード認証

### データベース最適化

#### PostgreSQL最適化
```bash
# 包括的最適化
sudo /app/scripts/performance-database.sh

# 個別操作
sudo /app/scripts/performance-database.sh --analyze    # テーブル分析
sudo /app/scripts/performance-database.sh --vacuum     # VACUUM実行
sudo /app/scripts/performance-database.sh --index      # インデックス最適化
sudo /app/scripts/performance-database.sh --configure  # 設定最適化
sudo /app/scripts/performance-database.sh --monitor    # パフォーマンス監視
```

#### 最適化設定
- **shared_buffers**: システムメモリの25%
- **effective_cache_size**: システムメモリの75%
- **work_mem**: システムメモリの2%
- **maintenance_work_mem**: システムメモリの5%

### Nginx最適化

#### Webサーバー最適化
```bash
# 包括的最適化
sudo /app/scripts/performance-nginx.sh

# 個別操作
sudo /app/scripts/performance-nginx.sh --install    # インストール
sudo /app/scripts/performance-nginx.sh --configure  # 設定最適化
sudo /app/scripts/performance-nginx.sh --ssl        # SSL設定
sudo /app/scripts/performance-nginx.sh --gzip       # Gzip設定
sudo /app/scripts/performance-nginx.sh --proxy      # プロキシ設定
sudo /app/scripts/performance-nginx.sh --monitor    # 監視
```

#### 最適化設定
- **worker_processes**: 自動設定
- **worker_connections**: CPUコア数 × 1024
- **keepalive_timeout**: 65秒
- **gzip_comp_level**: 6
- **proxy_cache**: 10GB制限

### 包括的最適化

#### 統合管理
```bash
# 包括的監視と最適化
sudo /app/scripts/performance-optimize.sh

# 個別操作
sudo /app/scripts/performance-optimize.sh --monitor        # 包括的監視
sudo /app/scripts/performance-optimize.sh --test           # パフォーマンステスト
sudo /app/scripts/performance-optimize.sh --optimize       # 包括的最適化
sudo /app/scripts/performance-optimize.sh --report         # レポート生成
sudo /app/scripts/performance-optimize.sh --alert-check    # アラートチェック
sudo /app/scripts/performance-optimize.sh --benchmark      # ベンチマーク
sudo /app/scripts/performance-optimize.sh --load-test      # 負荷テスト
```

## 設定

### 設定ファイル構造
```yaml
# /etc/tea-farm-ops/performance-config.yml

performance:
  enabled: true
  mode: "production"
  auto_optimize: true
  monitoring_interval: 300

cache:
  enabled: true
  type: "redis"
  redis:
    host: "127.0.0.1"
    port: 6379
    max_memory: "256mb"

database:
  enabled: true
  type: "postgresql"
  optimization:
    auto_vacuum: true
    auto_analyze: true

webserver:
  enabled: true
  type: "nginx"
  nginx:
    worker_processes: "auto"
    gzip:
      enabled: true
      level: 6
```

### 環境別設定
- **development**: 軽量設定、監視間隔長め
- **staging**: 本番に近い設定
- **production**: 高負荷対応、詳細監視

## 監視とアラート

### 監視項目
- **システムリソース**: CPU、メモリ、ディスク
- **アプリケーション**: レスポンス時間、エラー率
- **データベース**: 接続数、クエリパフォーマンス
- **キャッシュ**: ヒット率、メモリ使用量
- **Webサーバー**: リクエスト数、エラー率

### アラート設定
```yaml
alerts:
  critical:
    - "cpu_usage > 90%"
    - "memory_usage > 95%"
    - "disk_usage > 95%"
    - "response_time > 5s"
  warning:
    - "cpu_usage > 80%"
    - "memory_usage > 85%"
    - "response_time > 2s"
```

### 通知方法
- **Email**: SMTP経由
- **Slack**: Webhook経由
- **ログ**: ファイル出力

## レポート

### レポート種類
- **日次レポート**: パフォーマンスサマリー
- **週次レポート**: トレンド分析
- **月次レポート**: 包括的分析

### レポート内容
- システムリソース使用状況
- パフォーマンス指標
- 最適化結果
- 推奨事項

## トラブルシューティング

### よくある問題

#### Redis接続エラー
```bash
# Redisサービス状態確認
sudo systemctl status redis-server

# Redis接続テスト
redis-cli ping

# ログ確認
sudo tail -f /var/log/redis/redis-server.log
```

#### PostgreSQL最適化エラー
```bash
# PostgreSQLサービス状態確認
sudo systemctl status postgresql

# 接続テスト
psql -h localhost -U teafarmops -d teafarmops -c "SELECT 1;"

# ログ確認
sudo tail -f /var/log/postgresql/postgresql-*.log
```

#### Nginx設定エラー
```bash
# 設定ファイルテスト
sudo nginx -t

# Nginxサービス状態確認
sudo systemctl status nginx

# ログ確認
sudo tail -f /var/log/nginx/error.log
```

### ログファイル
- **キャッシュ**: `/var/log/tea-farm-ops/performance/cache.log`
- **データベース**: `/var/log/tea-farm-ops/performance/database.log`
- **Nginx**: `/var/log/tea-farm-ops/performance/nginx.log`
- **包括的**: `/var/log/tea-farm-ops/performance/optimize.log`

## メンテナンス

### 定期メンテナンス
- **日次**: VACUUM、キャッシュクリーンアップ
- **週次**: インデックス最適化、パフォーマンステスト
- **月次**: 包括的最適化、ベンチマーク

### バックアップ
- 設定ファイルのバックアップ
- パフォーマンスデータのバックアップ
- ログファイルのローテーション

### アップデート
```bash
# スクリプトの更新
sudo cp new-scripts/performance-*.sh /app/scripts/
sudo chmod +x /app/scripts/performance-*.sh

# 設定ファイルの更新
sudo cp new-config/performance-config.yml /etc/tea-farm-ops/
```

## パフォーマンス指標

### 目標値
- **レスポンス時間**: < 1秒
- **CPU使用率**: < 80%
- **メモリ使用率**: < 85%
- **ディスク使用率**: < 85%
- **キャッシュヒット率**: > 90%

### ベンチマーク結果
- **HTTP リクエスト**: 1000 req/sec
- **データベース接続**: 100 concurrent
- **Redis 操作**: 50000 ops/sec

## セキュリティ

### セキュリティ設定
- **Redis**: パスワード認証、ローカルバインディング
- **PostgreSQL**: SSL接続、アクセス制御
- **Nginx**: セキュリティヘッダー、レート制限

### アクセス制御
- 監視アクセスの制限
- API レート制限
- IP アドレス制限

## 最適化のベストプラクティス

### キャッシュ戦略
1. **適切なTTL設定**: データの性質に応じて
2. **メモリ管理**: 使用量の監視と調整
3. **キー設計**: 効率的なキー命名規則

### データベース最適化
1. **定期的なVACUUM**: デッドタプルの削除
2. **インデックス戦略**: 適切なインデックス設計
3. **クエリ最適化**: スロークエリの特定と改善

### Webサーバー最適化
1. **静的ファイルキャッシュ**: 適切なキャッシュヘッダー
2. **圧縮設定**: Gzip圧縮の活用
3. **接続プール**: 効率的な接続管理

## サポート

### ドキュメント
- このドキュメント
- 各スクリプトのヘルプ（`--help`オプション）
- ログファイル

### トラブルシューティング
1. ログファイルの確認
2. サービス状態の確認
3. 設定ファイルの検証
4. パフォーマンステストの実行

### 連絡先
- 技術サポート: support@your-domain.com
- 緊急時: emergency@your-domain.com

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 更新履歴

### v1.0.0 (2024-01-XX)
- 初回リリース
- キャッシュシステム最適化
- データベース最適化
- Nginx最適化
- 包括的監視システム

---

**TeaFarmOps パフォーマンス最適化システム** - 高速で効率的なアプリケーション運用を実現 