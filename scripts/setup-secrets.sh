#!/bin/bash

# GitHub Secrets設定スクリプト
# 使用方法: ./scripts/setup-secrets.sh [environment]

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

# 環境変数
ENVIRONMENT=${1:-production}
REPO_OWNER=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^.]*\).*/\1\/\2/')
GITHUB_TOKEN=${GITHUB_TOKEN:-}

# 設定ファイル
CONFIG_FILE="config/secrets-${ENVIRONMENT}.env"

# ヘルプ表示
show_help() {
    echo "GitHub Secrets設定スクリプト"
    echo ""
    echo "使用方法:"
    echo "  $0 [environment]"
    echo ""
    echo "環境:"
    echo "  production  - 本番環境 (デフォルト)"
    echo "  staging     - ステージング環境"
    echo "  development - 開発環境"
    echo ""
    echo "例:"
    echo "  $0 production"
    echo "  $0 staging"
    echo ""
    echo "必要な環境変数:"
    echo "  GITHUB_TOKEN - GitHub Personal Access Token"
}

# 引数チェック
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# 環境チェック
if [[ ! "$ENVIRONMENT" =~ ^(production|staging|development)$ ]]; then
    log_error "無効な環境: $ENVIRONMENT"
    echo "有効な環境: production, staging, development"
    exit 1
fi

# GitHub Tokenチェック
if [[ -z "$GITHUB_TOKEN" ]]; then
    log_error "GITHUB_TOKENが設定されていません"
    echo "GitHub Personal Access Tokenを設定してください:"
    echo "export GITHUB_TOKEN=your_token_here"
    exit 1
fi

# 設定ファイルチェック
if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "設定ファイルが見つかりません: $CONFIG_FILE"
    echo "設定ファイルを作成してください"
    exit 1
fi

log_info "環境: $ENVIRONMENT"
log_info "リポジトリ: $REPO_OWNER"

# 現在のSecretsを取得
get_current_secrets() {
    log_info "現在のSecretsを取得中..."
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
         "https://api.github.com/repos/$REPO_OWNER/actions/secrets" | \
         jq -r '.secrets[].name' 2>/dev/null || echo ""
}

# Secretを設定
set_secret() {
    local secret_name=$1
    local secret_value=$2
    
    log_info "Secretを設定中: $secret_name"
    
    # 公開鍵を取得
    local public_key=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO_OWNER/actions/secrets/public-key" | \
        jq -r '.key' 2>/dev/null)
    
    if [[ -z "$public_key" ]]; then
        log_error "公開鍵の取得に失敗しました"
        return 1
    fi
    
    # 公開鍵IDを取得
    local key_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO_OWNER/actions/secrets/public-key" | \
        jq -r '.key_id' 2>/dev/null)
    
    # Secretを暗号化
    local encrypted_value=$(echo -n "$secret_value" | openssl enc -aes-256-cbc -a -salt -pass pass:"$public_key" 2>/dev/null || echo "")
    
    if [[ -z "$encrypted_value" ]]; then
        log_error "Secretの暗号化に失敗しました: $secret_name"
        return 1
    fi
    
    # Secretを設定
    local response=$(curl -s -w "%{http_code}" -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO_OWNER/actions/secrets/$secret_name" \
        -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}")
    
    local http_code="${response: -3}"
    local response_body="${response%???}"
    
    if [[ "$http_code" == "204" ]]; then
        log_success "Secret設定完了: $secret_name"
        return 0
    else
        log_error "Secret設定失敗: $secret_name (HTTP: $http_code)"
        echo "レスポンス: $response_body"
        return 1
    fi
}

# 環境別Secretsを設定
set_environment_secrets() {
    log_info "環境別Secretsを設定中..."
    
    if [[ "$ENVIRONMENT" == "production" ]]; then
        # 本番環境用Secrets
        set_secret "DB_HOST" "$PROD_DB_HOST"
        set_secret "DB_USERNAME" "$PROD_DB_USERNAME"
        set_secret "DB_PASSWORD" "$PROD_DB_PASSWORD"
        set_secret "JWT_SECRET" "$PROD_JWT_SECRET"
        set_secret "ADMIN_PASSWORD" "$PROD_ADMIN_PASSWORD"
        set_secret "SLACK_WEBHOOK_URL" "$PROD_SLACK_WEBHOOK_URL"
        set_secret "SENTRY_DSN" "$PROD_SENTRY_DSN"
        
    elif [[ "$ENVIRONMENT" == "staging" ]]; then
        # ステージング環境用Secrets
        set_secret "DB_HOST" "$STAGING_DB_HOST"
        set_secret "DB_USERNAME" "$STAGING_DB_USERNAME"
        set_secret "DB_PASSWORD" "$STAGING_DB_PASSWORD"
        set_secret "JWT_SECRET" "$STAGING_JWT_SECRET"
        set_secret "ADMIN_PASSWORD" "$STAGING_ADMIN_PASSWORD"
        set_secret "SLACK_WEBHOOK_URL" "$STAGING_SLACK_WEBHOOK_URL"
        set_secret "SENTRY_DSN" "$STAGING_SENTRY_DSN"
        
    elif [[ "$ENVIRONMENT" == "development" ]]; then
        # 開発環境用Secrets
        set_secret "DB_HOST" "$DEV_DB_HOST"
        set_secret "DB_USERNAME" "$DEV_DB_USERNAME"
        set_secret "DB_PASSWORD" "$DEV_DB_PASSWORD"
        set_secret "JWT_SECRET" "$DEV_JWT_SECRET"
        set_secret "ADMIN_PASSWORD" "$DEV_ADMIN_PASSWORD"
    fi
}

# 共通Secretsを設定
set_common_secrets() {
    log_info "共通Secretsを設定中..."
    
    # 共通設定
    set_secret "GITHUB_TOKEN" "$GITHUB_TOKEN"
    set_secret "DOCKER_USERNAME" "$DOCKER_USERNAME"
    set_secret "DOCKER_PASSWORD" "$DOCKER_PASSWORD"
    set_secret "DEPLOY_SSH_KEY" "$DEPLOY_SSH_KEY"
    set_secret "DEPLOY_HOST" "$DEPLOY_HOST"
    set_secret "DEPLOY_USER" "$DEPLOY_USER"
}

# 設定ファイルから環境変数を読み込み
load_config() {
    log_info "設定ファイルを読み込み中: $CONFIG_FILE"
    
    if [[ -f "$CONFIG_FILE" ]]; then
        export $(cat "$CONFIG_FILE" | grep -v '^#' | xargs)
        log_success "設定ファイル読み込み完了"
    else
        log_warning "設定ファイルが見つかりません: $CONFIG_FILE"
        log_info "環境変数を手動で設定してください"
    fi
}

# 検証
validate_secrets() {
    log_info "Secrets設定を検証中..."
    
    local current_secrets=$(get_current_secrets)
    local required_secrets=("DB_HOST" "DB_USERNAME" "DB_PASSWORD" "JWT_SECRET")
    
    for secret in "${required_secrets[@]}"; do
        if echo "$current_secrets" | grep -q "^$secret$"; then
            log_success "✓ $secret が設定されています"
        else
            log_error "✗ $secret が設定されていません"
        fi
    done
}

# メイン処理
main() {
    log_info "GitHub Secrets設定を開始します..."
    
    # 設定ファイル読み込み
    load_config
    
    # 共通Secrets設定
    set_common_secrets
    
    # 環境別Secrets設定
    set_environment_secrets
    
    # 検証
    validate_secrets
    
    log_success "GitHub Secrets設定が完了しました！"
}

# スクリプト実行
main "$@" 