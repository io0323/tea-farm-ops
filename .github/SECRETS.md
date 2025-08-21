# GitHub Secrets設定ガイド

## 概要

このガイドでは、TeaFarmOpsプロジェクトのGitHub Secrets設定について説明します。GitHub Secretsを使用することで、機密情報を安全に管理し、CI/CDパイプラインで利用できます。

## 前提条件

- GitHub Personal Access Token（`repo`権限が必要）
- 管理者権限を持つGitHubアカウント
- コマンドライン環境（bash、curl、jq）

## 必要なSecrets

### 必須Secrets

| Secret名 | 説明 | 例 |
|----------|------|-----|
| `DB_HOST` | データベースホスト | `your-db-host.com` |
| `DB_USERNAME` | データベースユーザー名 | `teafarmops_prod` |
| `DB_PASSWORD` | データベースパスワード | `strong-password-here` |
| `JWT_SECRET` | JWT署名用シークレット | `your-jwt-secret-key` |
| `GITHUB_TOKEN` | GitHub Personal Access Token | `ghp_xxxxxxxx` |
| `GHCR_PAT` | GitHub Container Registry用Personal Access Token（組織パッケージpush用） | `ghp_xxxxxxxx` |

**注意:** `GHCR_PAT` は組織のGitHub Container Registryにパッケージをpushするために必要です。デフォルトの `GITHUB_TOKEN` では組織レベルのパッケージ作成権限が不足するため、`write:packages` 権限を持つPersonal Access Tokenが必要です。

### オプションSecrets

| Secret名 | 説明 | 例 |
|----------|------|-----|
| `ADMIN_PASSWORD` | 管理者パスワード | `admin-password` |
| `SLACK_WEBHOOK_URL` | Slack通知用Webhook | `https://hooks.slack.com/...` |
| `SENTRY_DSN` | Sentryエラー追跡用DSN | `https://xxx@sentry.io/xxx` |
| `DOCKER_USERNAME` | Docker Hubユーザー名 | `your-docker-username` |
| `DOCKER_PASSWORD` | Docker Hubパスワード | `your-docker-password` |
| `DEPLOY_SSH_KEY` | デプロイ用SSH秘密鍵 | `-----BEGIN OPENSSH PRIVATE KEY-----` |
| `DEPLOY_HOST` | デプロイ先サーバーホスト | `your-server.com` |
| `DEPLOY_USER` | デプロイ用ユーザー名 | `deploy` |

## 設定手順

### 1. 環境変数の設定

```bash
# GitHub Personal Access Tokenを設定
export GITHUB_TOKEN=ghp_your-token-here

# 設定ファイルから環境変数を読み込み
export $(cat config/secrets-production.env | grep -v '^#' | xargs)
```

### 2. 自動設定スクリプトの実行

```bash
# スクリプトに実行権限を付与
chmod +x scripts/setup-secrets.sh

# 本番環境用Secretsを設定
./scripts/setup-secrets.sh production

# ステージング環境用Secretsを設定
./scripts/setup-secrets.sh staging
```

### 3. 手動設定（推奨）

#### GitHub Web UIでの設定

1. GitHubリポジトリページにアクセス
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret**をクリック
4. 各Secretを個別に設定

#### コマンドラインでの設定

```bash
# 個別Secretの設定例
./scripts/setup-secrets.sh production DB_HOST your-db-host.com
./scripts/setup-secrets.sh production DB_PASSWORD your-password
```

### 4. 設定の検証

```bash
# スクリプトに実行権限を付与
chmod +x scripts/verify-secrets.sh

# Secrets設定を検証
./scripts/verify-secrets.sh production
```

## 環境別設定

### 本番環境

```bash
# 本番環境用設定ファイルを使用
source config/secrets-production.env
./scripts/setup-secrets.sh production
```

### ステージング環境

```bash
# ステージング環境用設定ファイルを使用
source config/secrets-staging.env
./scripts/setup-secrets.sh staging
```

### 開発環境

```bash
# 開発環境用設定ファイルを使用
source config/secrets-development.env
./scripts/setup-secrets.sh development
```

## セキュリティベストプラクティス

### 1. パスワード生成

```bash
# 強力なパスワードの生成
openssl rand -base64 32

# JWT Secretの生成
openssl rand -hex 64
```

### 2. ファイル権限の設定

```bash
# 設定ファイルの権限を制限
chmod 600 config/secrets-*.env
chmod 600 scripts/setup-secrets.sh
chmod 600 scripts/verify-secrets.sh
```

### 3. 環境変数の管理

```bash
# 機密情報を含む環境変数をクリア
unset DB_PASSWORD JWT_SECRET GITHUB_TOKEN
```

## トラブルシューティング

### よくある問題

#### 1. 権限エラー

```
[ERROR] Secrets取得に失敗しました
```

**解決方法:**
- GitHub Personal Access Tokenの権限を確認
- `repo`権限が付与されているか確認

#### 2. 暗号化エラー

```
[ERROR] Secretの暗号化に失敗しました
```

**解決方法:**
- OpenSSLがインストールされているか確認
- 公開鍵の取得に成功しているか確認

#### 3. 設定ファイルが見つからない

```
[ERROR] 設定ファイルが見つかりません
```

**解決方法:**
- 設定ファイルのパスを確認
- ファイルが存在するか確認

### デバッグ方法

```bash
# 詳細ログを有効化
export DEBUG=true
./scripts/setup-secrets.sh production

# 個別Secretのテスト
curl -H "Authorization: token $GITHUB_TOKEN" \
     "https://api.github.com/repos/$REPO_OWNER/actions/secrets"
```

## 定期メンテナンス

### 1. Secrets更新

```bash
# 3ヶ月ごとにパスワードを更新
./scripts/update-secrets.sh production

# 使用していないSecretsを削除
./scripts/cleanup-secrets.sh
```

### 2. セキュリティ監査

```bash
# 定期的なセキュリティチェック
./scripts/verify-secrets.sh production
./scripts/security-audit.sh
```

### 3. バックアップ

```bash
# Secrets設定のバックアップ
./scripts/backup-secrets.sh

# 復旧テスト
./scripts/restore-secrets.sh
```

## 参考資料

- [GitHub Secrets API Documentation](https://docs.github.com/en/rest/actions/secrets)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [OpenSSL Documentation](https://www.openssl.org/docs/)

## サポート

問題が発生した場合は、以下を確認してください：

1. ログファイルの確認
2. GitHub APIの制限確認
3. ネットワーク接続の確認
4. 権限設定の確認

詳細なサポートが必要な場合は、プロジェクトのIssuesページで報告してください。 