# GitHub Secrets 設定ガイド

このドキュメントでは、GitHub Actionsで使用するSecretsの設定方法を説明します。

## 必要なSecrets

### 1. 基本設定

#### `GITHUB_TOKEN`
- **説明**: GitHub Actionsで自動的に提供されるトークン
- **設定方法**: 自動設定（変更不要）
- **用途**: リポジトリへのアクセス、Docker Registryへのログイン

### 2. データベース設定

#### `DB_HOST`
- **説明**: 本番データベースのホスト名
- **例**: `your-db-host.com`
- **用途**: 本番環境へのデプロイ時

#### `DB_USERNAME`
- **説明**: データベースユーザー名
- **例**: `teafarmops`
- **用途**: 本番環境へのデプロイ時

#### `DB_PASSWORD`
- **説明**: データベースパスワード
- **例**: `your-secure-password`
- **用途**: 本番環境へのデプロイ時

### 3. アプリケーション設定

#### `JWT_SECRET`
- **説明**: JWTトークンの署名用シークレット
- **例**: `your-super-secret-jwt-key-here`
- **用途**: 認証トークンの生成・検証

#### `SPRING_PROFILES_ACTIVE`
- **説明**: Spring Bootのプロファイル
- **例**: `production`
- **用途**: 本番環境の設定

### 4. 通知設定

#### `SLACK_WEBHOOK_URL`
- **説明**: Slack通知用のWebhook URL
- **例**: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX`
- **用途**: デプロイ通知、エラー通知

#### `EMAIL_SMTP_HOST`
- **説明**: メール通知用SMTPホスト
- **例**: `smtp.gmail.com`
- **用途**: メール通知

#### `EMAIL_SMTP_PORT`
- **説明**: メール通知用SMTPポート
- **例**: `587`
- **用途**: メール通知

#### `EMAIL_USERNAME`
- **説明**: メール通知用ユーザー名
- **例**: `notifications@yourcompany.com`
- **用途**: メール通知

#### `EMAIL_PASSWORD`
- **説明**: メール通知用パスワード
- **例**: `your-email-password`
- **用途**: メール通知

### 5. デプロイ設定

#### `DEPLOY_SSH_KEY`
- **説明**: デプロイ先サーバーへのSSH秘密鍵
- **用途**: サーバーへのデプロイ

#### `DEPLOY_HOST`
- **説明**: デプロイ先サーバーのホスト名
- **例**: `your-server.com`
- **用途**: サーバーへのデプロイ

#### `DEPLOY_USER`
- **説明**: デプロイ先サーバーのユーザー名
- **例**: `deploy`
- **用途**: サーバーへのデプロイ

### 6. 監視設定

#### `SENTRY_DSN`
- **説明**: Sentryエラー追跡用DSN
- **例**: `https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@xxxxx.ingest.sentry.io/xxxxx`
- **用途**: エラー追跡

#### `NEW_RELIC_LICENSE_KEY`
- **説明**: New Relic監視用ライセンスキー
- **例**: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
- **用途**: アプリケーションモニタリング

## 設定方法

### 1. GitHubリポジトリでSecretsを設定

1. リポジトリの **Settings** タブをクリック
2. 左サイドバーの **Secrets and variables** → **Actions** をクリック
3. **New repository secret** ボタンをクリック
4. 各Secretsを追加

### 2. 環境別のSecrets設定

#### 本番環境用
1. **Settings** → **Environments** をクリック
2. **New environment** で `production` を作成
3. **Environment secrets** で本番環境専用のSecretsを設定

#### ステージング環境用
1. **Settings** → **Environments** をクリック
2. **New environment** で `staging` を作成
3. **Environment secrets** でステージング環境専用のSecretsを設定

## セキュリティベストプラクティス

### 1. 強力なパスワードの使用
- 最低16文字以上
- 大文字・小文字・数字・記号を含む
- 辞書に載っている単語を避ける

### 2. 定期的な更新
- 3ヶ月ごとにパスワードを更新
- 使用していないSecretsを削除
- アクセス権限の定期的な見直し

### 3. 最小権限の原則
- 必要最小限の権限のみ付与
- 環境別に適切な権限を設定
- 不要な権限は削除

### 4. 監査ログの確認
- GitHub Actionsの実行ログを定期的に確認
- 異常なアクセスがないかチェック
- 失敗したジョブの原因を調査

## トラブルシューティング

### よくある問題

#### 1. Secretsが見つからない
```
Error: Required secret 'DB_PASSWORD' not found
```
**解決方法**: GitHub Secretsに正しく設定されているか確認

#### 2. 権限エラー
```
Error: Permission denied (publickey)
```
**解決方法**: SSH鍵が正しく設定されているか確認

#### 3. 環境変数が読み込めない
```
Error: Environment variable not set
```
**解決方法**: ワークフローで環境変数が正しく参照されているか確認

### デバッグ方法

#### 1. ワークフローログの確認
- Actions タブでワークフローの実行ログを確認
- エラーメッセージを詳しく読む
- 各ステップの出力を確認

#### 2. ローカルテスト
- ワークフローをローカルでテスト
- 環境変数をローカルで設定してテスト
- スクリプトを個別に実行してテスト

#### 3. 段階的デプロイ
- まずステージング環境でテスト
- 問題がなければ本番環境にデプロイ
- ロールバック手順を準備

## 参考リンク

- [GitHub Secrets 公式ドキュメント](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Environments 公式ドキュメント](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [GitHub Actions セキュリティベストプラクティス](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions) 