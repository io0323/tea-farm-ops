# TeaFarmOps バックアップシステム

## 概要

TeaFarmOps バックアップシステムは、データベース、アプリケーションファイル、監視データの包括的なバックアップと復旧機能を提供します。

## 機能

### 🔄 バックアップ機能
- **データベースバックアップ**: PostgreSQL完全・差分・増分バックアップ
- **ファイルバックアップ**: アプリケーションファイル、設定ファイル、ログ
- **監視データバックアップ**: Prometheus、Grafana、Alertmanagerデータ
- **自動スケジュール**: 日次・週次・月次バックアップ
- **圧縮・暗号化**: ストレージ効率とセキュリティ

### 🔍 検証・監視機能
- **バックアップ検証**: 整合性チェック、復旧テスト
- **自動通知**: Slack、メール通知
- **統計レポート**: バックアップ成功率、サイズ、時間
- **ディスク監視**: 容量不足警告

### 🔧 復旧機能
- **データベース復旧**: 完全・部分復旧
- **ファイル復旧**: 選択的復旧
- **災害復旧**: システム全体の復旧
- **復旧テスト**: 定期的な復旧テスト

## アーキテクチャ

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   アプリケーション   │    │   バックアップ     │    │   ストレージ      │
│                │    │   スクリプト      │    │                │
│  - Spring Boot │───▶│  - Database     │───▶│  - Local Disk   │
│  - React       │    │  - Files        │    │  - Cloud Storage│
│  - PostgreSQL  │    │  - Monitoring   │    │  - NAS          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   監視・通知     │
                       │                │
                       │  - Prometheus  │
                       │  - Grafana     │
                       │  - Slack       │
                       └─────────────────┘
```

## インストール

### 1. 前提条件
```bash
# 必要なパッケージのインストール
sudo apt-get update
sudo apt-get install -y postgresql-client tar gzip curl jq

# ディレクトリの作成
sudo mkdir -p /backups/{database,files,monitoring}
sudo mkdir -p /var/log/tea-farm-ops/backup
sudo mkdir -p /etc/tea-farm-ops

# 権限の設定
sudo chown -R teafarmops:teafarmops /backups
sudo chown -R teafarmops:teafarmops /var/log/tea-farm-ops
```

### 2. スクリプトの配置
```bash
# スクリプトを実行可能にする
chmod +x scripts/backup-*.sh
chmod +x scripts/restore-*.sh

# 設定ファイルの配置
sudo cp config/backup-config.yml /etc/tea-farm-ops/
sudo cp config/crontab /etc/tea-farm-ops/
```

### 3. 環境変数の設定
```bash
# データベース設定
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=teafarmops
export DB_USER=teafarmops
export DB_PASSWORD=your_password

# 通知設定
export SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

### 4. cron設定
```bash
# cron設定の適用
crontab /etc/tea-farm-ops/crontab

# cronサービスの確認
sudo systemctl status cron
```

## 使用方法

### 手動バックアップ

#### データベースバックアップ
```bash
# 完全バックアップ
./scripts/backup-database.sh --full

# 差分バックアップ
./scripts/backup-database.sh --differential

# 増分バックアップ
./scripts/backup-database.sh --incremental

# 検証付きバックアップ
./scripts/backup-database.sh --full --verify
```

#### ファイルバックアップ
```bash
# 全ファイルバックアップ
./scripts/backup-files.sh --all

# 設定ファイルのみ
./scripts/backup-files.sh --config

# アップロードファイルのみ
./scripts/backup-files.sh --uploads

# 監視データのみ
./scripts/backup-files.sh --monitoring
```

#### 監視データバックアップ
```bash
# 全監視データ
./scripts/backup-monitoring.sh --all

# Prometheusデータのみ
./scripts/backup-monitoring.sh --prometheus

# Grafanaデータのみ
./scripts/backup-monitoring.sh --grafana
```

### 自動バックアップ

#### スケジュール実行
```bash
# 日次バックアップ
./scripts/backup-scheduler.sh --daily

# 週次バックアップ
./scripts/backup-scheduler.sh --weekly

# 月次バックアップ
./scripts/backup-scheduler.sh --monthly

# テストモード
./scripts/backup-scheduler.sh --test --daily
```

### 復旧

#### データベース復旧
```bash
# 基本的な復旧
./scripts/restore-database.sh backup_file.sql

# 強制復旧
./scripts/restore-database.sh --force backup_file.sql

# 復旧前バックアップ作成
./scripts/restore-database.sh --backup-first backup_file.sql

# 復旧後検証
./scripts/restore-database.sh --verify backup_file.sql
```

## 設定

### バックアップ設定ファイル
```yaml
# /etc/tea-farm-ops/backup-config.yml
backup:
  enabled: true
  schedules:
    daily: "02:00"
    weekly: "03:00"
    monthly: "04:00"

database:
  connection:
    host: "localhost"
    port: 5432
    name: "teafarmops"
    user: "teafarmops"
    password: "${DB_PASSWORD}"
  
  backup:
    compression: true
    verification: true
    retention_days: 30
```

### 環境変数
```bash
# データベース設定
DB_HOST=localhost
DB_PORT=5432
DB_NAME=teafarmops
DB_USER=teafarmops
DB_PASSWORD=your_password

# 通知設定
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# クラウドストレージ設定（オプション）
AWS_ACCESS_KEY=your_access_key
AWS_SECRET_KEY=your_secret_key
```

## 監視・通知

### バックアップ監視
- **成功率**: バックアップの成功/失敗率
- **実行時間**: バックアップの実行時間
- **サイズ**: バックアップファイルのサイズ
- **エラー率**: エラーの発生率

### 通知設定
```bash
# Slack通知
export SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# メール通知
export MAILTO=admin@your-domain.com
```

### アラート条件
- バックアップ失敗
- ディスク容量不足（80%以上）
- バックアップ時間超過（60分以上）
- 復旧失敗

## トラブルシューティング

### よくある問題

#### 1. データベース接続エラー
```bash
# 接続テスト
pg_isready -h localhost -p 5432 -U teafarmops

# 環境変数確認
echo $DB_PASSWORD
```

#### 2. 権限エラー
```bash
# ディレクトリ権限確認
ls -la /backups/
ls -la /var/log/tea-farm-ops/

# 権限修正
sudo chown -R teafarmops:teafarmops /backups
sudo chmod -R 755 /backups
```

#### 3. ディスク容量不足
```bash
# ディスク使用量確認
df -h /backups

# 古いバックアップ削除
find /backups -name "*.tar.gz" -mtime +30 -delete
```

#### 4. cron実行エラー
```bash
# cronログ確認
tail -f /var/log/cron

# 手動実行テスト
./scripts/backup-scheduler.sh --daily --verbose
```

### ログファイル
```bash
# バックアップログ
tail -f /var/log/tea-farm-ops/backup/backup_daily_*.log

# cronログ
tail -f /var/log/tea-farm-ops/backup/cron_daily.log

# システムログ
journalctl -u cron -f
```

## メンテナンス

### 定期メンテナンス

#### 週次メンテナンス
```bash
# バックアップ検証
./scripts/backup-verify.sh

# 古いバックアップ削除
./scripts/backup-cleanup.sh

# 統計レポート生成
./scripts/backup-report.sh
```

#### 月次メンテナンス
```bash
# 復旧テスト
./scripts/restore-database.sh --test backup_file.sql

# 設定ファイル更新
sudo cp config/backup-config.yml /etc/tea-farm-ops/

# ログローテーション
logrotate /etc/logrotate.d/tea-farm-ops-backup
```

### パフォーマンス最適化

#### バックアップ最適化
```yaml
# 並行バックアップ数
max_concurrent_backups: 2

# タイムアウト設定
timeout_minutes: 60

# メモリ制限
memory_limit_mb: 512
```

#### ストレージ最適化
```bash
# 圧縮率向上
gzip -9 backup_file.sql

# 重複排除
rdfind -deleteduplicates true /backups/

# アーカイブ
tar -czf archive_$(date +%Y%m).tar.gz /backups/
```

## セキュリティ

### アクセス制御
```bash
# ファイル権限
chmod 600 /backups/*.sql
chmod 600 /backups/*.tar.gz

# ディレクトリ権限
chmod 700 /backups/
chmod 700 /var/log/tea-farm-ops/backup/

# 所有者設定
chown teafarmops:teafarmops /backups/
```

### 暗号化
```bash
# バックアップファイル暗号化
gpg --encrypt --recipient admin@your-domain.com backup_file.sql

# 設定ファイル暗号化
gpg --encrypt --recipient admin@your-domain.com backup-config.yml
```

### 監査ログ
```bash
# アクセスログ
auditctl -w /backups/ -p wa -k backup_access

# 変更ログ
auditctl -w /etc/tea-farm-ops/backup-config.yml -p wa -k backup_config
```

## 災害復旧

### 復旧手順

#### 1. システム復旧
```bash
# システム停止
sudo systemctl stop tea-farm-ops

# データベース復旧
./scripts/restore-database.sh --force latest_backup.sql

# ファイル復旧
tar -xzf latest_files_backup.tar.gz -C /

# システム再起動
sudo systemctl start tea-farm-ops
```

#### 2. 監視システム復旧
```bash
# Prometheus復旧
tar -xzf latest_monitoring_backup.tar.gz -C /

# Grafana復旧
sudo systemctl restart grafana-server

# Alertmanager復旧
sudo systemctl restart alertmanager
```

### 復旧テスト
```bash
# 月次復旧テスト
./scripts/disaster-recovery-test.sh

# 復旧時間測定
time ./scripts/restore-database.sh test_backup.sql
```

## ベストプラクティス

### バックアップ戦略
1. **3-2-1ルール**: 3つのコピー、2つのメディア、1つのオフサイト
2. **段階的バックアップ**: 日次・週次・月次の組み合わせ
3. **検証**: 定期的なバックアップ検証と復旧テスト
4. **文書化**: 復旧手順の文書化と更新

### パフォーマンス
1. **並行処理**: 複数バックアップの並行実行
2. **圧縮**: 効率的な圧縮アルゴリズムの使用
3. **差分バックアップ**: 変更分のみのバックアップ
4. **スケジュール**: 低負荷時間帯での実行

### セキュリティ
1. **暗号化**: 機密データの暗号化
2. **アクセス制御**: 最小権限の原則
3. **監査**: アクセスログの記録
4. **テスト**: 定期的なセキュリティテスト

## サポート

### ログ分析
```bash
# エラーログの確認
grep -i error /var/log/tea-farm-ops/backup/*.log

# 成功ログの確認
grep -i success /var/log/tea-farm-ops/backup/*.log

# 実行時間の分析
grep "実行時間" /var/log/tea-farm-ops/backup/*.log
```

### 統計情報
```bash
# バックアップ統計
./scripts/backup-stats.sh

# ディスク使用量
du -sh /backups/*

# ファイル数
find /backups -type f | wc -l
```

### 連絡先
- **技術サポート**: tech-support@your-domain.com
- **緊急時**: emergency@your-domain.com
- **ドキュメント**: https://docs.your-domain.com/backup 