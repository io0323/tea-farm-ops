# TeaFarmOps セキュリティシステム

## 概要

TeaFarmOps セキュリティシステムは、ファイアウォール、SSL証明書管理、セキュリティ監査、アクセス制御を統合した包括的なセキュリティソリューションです。

## 機能

### 🔥 ファイアウォール管理
- **UFW設定**: 自動インストール・設定・監視
- **ポート制御**: アプリケーション用ポートの詳細制御
- **レート制限**: ブルートフォース攻撃の防止
- **セキュリティルール**: 不要なサービスの自動拒否

### 🔒 SSL証明書管理
- **Let's Encrypt**: 自動証明書取得・更新
- **セキュリティヘッダー**: HSTS、CSP、X-Frame-Options等
- **証明書監視**: 有効期限の自動チェック
- **暗号化設定**: 最新の暗号化アルゴリズム

### 🔍 セキュリティ監査
- **システム監査**: システム情報・プロセス・サービスの監査
- **ネットワーク監査**: ポート・接続・ファイアウォール状態の監査
- **ユーザー監査**: ユーザー・グループ・権限の監査
- **パッケージ監査**: 更新・脆弱性のチェック
- **ログ監査**: セキュリティログの分析

### 🛡️ アクセス制御
- **SSH強化**: セキュアなSSH設定
- **ユーザー管理**: パスワードポリシー・アカウントロックアウト
- **ファイル権限**: 重要なファイルの権限監査・修正
- **セッション管理**: アクティブセッションの監視

## インストール

### 1. 前提条件
```bash
# 必要なパッケージのインストール
sudo apt-get update
sudo apt-get install -y ufw certbot python3-certbot-nginx tar gzip curl jq

# ディレクトリの作成
sudo mkdir -p /var/log/tea-farm-ops/security
sudo mkdir -p /etc/tea-farm-ops
sudo mkdir -p /etc/ssl/tea-farm-ops

# 権限の設定
sudo chown -R teafarmops:teafarmops /var/log/tea-farm-ops
sudo chown -R root:root /etc/tea-farm-ops
```

### 2. スクリプトの配置
```bash
# スクリプトを実行可能にする
sudo chmod +x scripts/security-*.sh

# 設定ファイルの配置
sudo cp config/security-config.yml /etc/tea-farm-ops/
sudo cp config/security-crontab /etc/tea-farm-ops/
```

### 3. 環境変数の設定
```bash
# 環境変数ファイルの作成
sudo tee /etc/tea-farm-ops/security.env > /dev/null << EOF
# メール設定
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Slack設定
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# データベース設定
DB_PASSWORD=your-secure-password
EOF

# 権限の設定
sudo chmod 600 /etc/tea-farm-ops/security.env
```

## 使用方法

### ファイアウォール管理
```bash
# ファイアウォールのインストールと設定
sudo ./scripts/security-firewall.sh --install --configure

# ファイアウォールの状態確認
sudo ./scripts/security-firewall.sh --status

# 接続テスト
sudo ./scripts/security-firewall.sh --test
```

### SSL証明書管理
```bash
# Certbotのインストールと証明書取得
sudo ./scripts/security-ssl.sh --install --certificate

# 証明書の状態確認
sudo ./scripts/security-ssl.sh --status

# 証明書の更新
sudo ./scripts/security-ssl.sh --renew
```

### セキュリティ監査
```bash
# 完全監査の実行
sudo ./scripts/security-audit.sh --full

# 特定項目の監査
sudo ./scripts/security-audit.sh --system --network --users

# レポート生成
sudo ./scripts/security-audit.sh --report
```

### アクセス制御
```bash
# SSH設定の強化
sudo ./scripts/security-access.sh --ssh

# ユーザー権限管理
sudo ./scripts/security-access.sh --users

# ファイル権限監査
sudo ./scripts/security-access.sh --files

# 権限の修正
sudo ./scripts/security-access.sh --permissions
```

## 設定

### セキュリティ設定ファイル
メインの設定ファイルは `/etc/tea-farm-ops/security-config.yml` です。

```yaml
# ファイアウォール設定
firewall:
  enabled: true
  type: "ufw"
  allowed_ports:
    - port: 22
      protocol: "tcp"
      description: "SSH"
      rate_limit: true

# SSL設定
ssl:
  enabled: true
  provider: "letsencrypt"
  domains:
    - "your-domain.com"
    - "www.your-domain.com"

# SSH設定
ssh:
  enabled: true
  authentication:
    permit_root_login: false
    pubkey_authentication: true
    password_authentication: false
```

### 自動実行スケジュール
```bash
# cronジョブの設定
sudo crontab config/security-crontab
```

## 監視とアラート

### ログファイル
- `/var/log/tea-farm-ops/security/firewall.log` - ファイアウォールログ
- `/var/log/tea-farm-ops/security/ssl.log` - SSL証明書ログ
- `/var/log/tea-farm-ops/security/audit.log` - 監査ログ
- `/var/log/tea-farm-ops/security/access.log` - アクセスログ

### レポートディレクトリ
- `/var/log/tea-farm-ops/security/reports/` - 監査レポート

### アラート設定
```yaml
notifications:
  email:
    enabled: true
    smtp_server: "smtp.gmail.com"
    to_addresses:
      - "admin@your-domain.com"
  
  slack:
    enabled: true
    webhook_url: "${SLACK_WEBHOOK_URL}"
    channel: "#security-alerts"
```

## トラブルシューティング

### よくある問題

#### 1. ファイアウォールが有効にならない
```bash
# UFWの状態確認
sudo ufw status verbose

# ログの確認
sudo tail -f /var/log/ufw.log

# 手動で有効化
sudo ufw --force enable
```

#### 2. SSL証明書の取得に失敗
```bash
# Certbotのログ確認
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# 手動で証明書取得
sudo certbot certonly --webroot --webroot-path=/var/www/html -d your-domain.com
```

#### 3. SSH接続ができない
```bash
# SSH設定のテスト
sudo sshd -t

# SSHサービスの状態確認
sudo systemctl status sshd

# ログの確認
sudo tail -f /var/log/auth.log
```

#### 4. セキュリティ監査でエラーが発生
```bash
# 権限の確認
sudo ls -la /var/log/tea-farm-ops/security/

# ディスク容量の確認
df -h /var/log/tea-farm-ops/security/

# 手動で監査実行
sudo ./scripts/security-audit.sh --verbose
```

### ログの確認方法
```bash
# リアルタイムログ監視
sudo tail -f /var/log/tea-farm-ops/security/*.log

# エラーログの検索
sudo grep -i "error" /var/log/tea-farm-ops/security/*.log

# 警告ログの検索
sudo grep -i "warning" /var/log/tea-farm-ops/security/*.log
```

## メンテナンス

### 定期メンテナンス

#### 日次メンテナンス
- セキュリティログの確認
- ファイアウォール状態の確認
- SSL証明書の有効期限チェック

#### 週次メンテナンス
- セキュリティ監査の実行
- パッケージ更新の確認
- バックアップの整合性チェック

#### 月次メンテナンス
- 包括的セキュリティレポートの生成
- セキュリティ設定の見直し
- 古いログファイルのクリーンアップ

### バックアップと復元

#### 設定のバックアップ
```bash
# セキュリティ設定のバックアップ
sudo ./scripts/security-access.sh --backup

# 手動バックアップ
sudo tar -czf security_backup_$(date +%Y%m%d).tar.gz \
  /etc/tea-farm-ops/security-config.yml \
  /etc/ssh/sshd_config \
  /etc/ufw/
```

#### 設定の復元
```bash
# セキュリティ設定の復元
sudo ./scripts/security-access.sh --restore

# 手動復元
sudo tar -xzf security_backup_YYYYMMDD.tar.gz -C /
sudo systemctl restart sshd
sudo ufw reload
```

## セキュリティベストプラクティス

### 1. 強力なパスワードポリシー
- 最小12文字
- 大文字・小文字・数字・特殊文字を含む
- 90日で更新
- 過去5回のパスワードを再利用禁止

### 2. 多要素認証
- SSH鍵認証の使用
- パスワード認証の無効化
- 公開鍵の適切な管理

### 3. 最小権限の原則
- 必要最小限の権限のみ付与
- 定期的な権限の見直し
- 不要なユーザーの無効化

### 4. 定期的な監査
- 自動化されたセキュリティ監査
- 脆弱性スキャンの実行
- セキュリティレポートの確認

### 5. インシデント対応
- セキュリティインシデントの検知
- 自動対応の設定
- エスカレーション手順の整備

## パフォーマンス最適化

### 1. スキャン最適化
- 並行スキャン数の制限
- タイムアウト設定の調整
- リソース使用量の監視

### 2. ログ最適化
- ログローテーションの設定
- 古いログファイルの自動削除
- ログ圧縮の有効化

### 3. 通知最適化
- 重要度に応じた通知設定
- 通知頻度の調整
- 通知チャンネルの最適化

## コンプライアンス

### GDPR対応
- データ暗号化
- アクセスログの保持
- データ保持期間の設定

### SOX対応
- 監査証跡の保持
- アクセス制御の実装
- セキュリティ監査の実行

### NIST Cybersecurity Framework
- Identify（識別）
- Protect（保護）
- Detect（検知）
- Respond（対応）
- Recover（復旧）

## 緊急時対応

### 1. セキュリティインシデントの検知
- 自動監視システムによる検知
- アラートの即座通知
- インシデントの分類と優先度付け

### 2. 自動対応
- 疑わしいIPアドレスの自動ブロック
- 侵害されたアカウントの自動無効化
- 影響を受けたシステムの自動分離

### 3. 手動対応
- インシデントの詳細調査
- 影響範囲の特定
- 復旧手順の実行

### 4. 事後対応
- インシデントレポートの作成
- 再発防止策の実装
- セキュリティ設定の見直し

## サポート

### ドキュメント
- このドキュメント
- 各スクリプトのヘルプ（`--help`オプション）
- ログファイルの詳細

### トラブルシューティング
- ログファイルの確認
- 設定ファイルの検証
- 手動テストの実行

### 更新とメンテナンス
- 定期的なセキュリティ更新
- 新機能の追加
- バグ修正の適用 