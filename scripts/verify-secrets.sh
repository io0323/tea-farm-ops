#!/bin/bash

# GitHub Secrets検証スクリプト
# 使用方法: ./scripts/verify-secrets.sh [environment]

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

# 必要なSecrets
REQUIRED_SECRETS=(
    "DB_HOST"
    "DB_USERNAME"
    "DB_PASSWORD"
    "JWT_SECRET"
    "GITHUB_TOKEN"
    "GHCR_PAT"
)

OPTIONAL_SECRETS=(
    "ADMIN_PASSWORD"
    "SLACK_WEBHOOK_URL"
    "SENTRY_DSN"
    "DOCKER_USERNAME"
    "DOCKER_PASSWORD"
    "DEPLOY_SSH_KEY"
    "DEPLOY_HOST"
    "DEPLOY_USER"
)

# ヘルプ表示
show_help() {
    echo "GitHub Secrets検証スクリプト"
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

log_info "環境: $ENVIRONMENT"
log_info "リポジトリ: $REPO_OWNER"

# 現在のSecretsを取得
get_current_secrets() {
    log_info "現在のSecretsを取得中..."
    
    local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO_OWNER/actions/secrets")
    
    if [[ $? -ne 0 ]]; then
        log_error "Secrets取得に失敗しました"
        return 1
    fi
    
    echo "$response" | jq -r '.secrets[].name' 2>/dev/null || echo ""
}

# 環境別Secretsを取得
get_environment_secrets() {
    local current_secrets=$1
    
    if [[ "$ENVIRONMENT" == "production" ]]; then
        echo "$current_secrets" | grep -E "^(DB_HOST|DB_USERNAME|DB_PASSWORD|JWT_SECRET|ADMIN_PASSWORD|SLACK_WEBHOOK_URL|SENTRY_DSN)$" || true
    elif [[ "$ENVIRONMENT" == "staging" ]]; then
        echo "$current_secrets" | grep -E "^(DB_HOST|DB_USERNAME|DB_PASSWORD|JWT_SECRET|ADMIN_PASSWORD|SLACK_WEBHOOK_URL|SENTRY_DSN)$" || true
    elif [[ "$ENVIRONMENT" == "development" ]]; then
        echo "$current_secrets" | grep -E "^(DB_HOST|DB_USERNAME|DB_PASSWORD|JWT_SECRET|ADMIN_PASSWORD)$" || true
    fi
}

# 共通Secretsを取得
get_common_secrets() {
    local current_secrets=$1
    echo "$current_secrets" | grep -E "^(GITHUB_TOKEN|DOCKER_USERNAME|DOCKER_PASSWORD|DEPLOY_SSH_KEY|DEPLOY_HOST|DEPLOY_USER)$" || true
}

# Secretsの検証
verify_secrets() {
    local current_secrets=$1
    local required_secrets=("${REQUIRED_SECRETS[@]}")
    local optional_secrets=("${OPTIONAL_SECRETS[@]}")
    
    local missing_required=()
    local missing_optional=()
    local found_secrets=()
    
    # 必須Secretsの検証
    for secret in "${required_secrets[@]}"; do
        if echo "$current_secrets" | grep -q "^$secret$"; then
            found_secrets+=("$secret")
        else
            missing_required+=("$secret")
        fi
    done
    
    # オプションSecretsの検証
    for secret in "${optional_secrets[@]}"; do
        if echo "$current_secrets" | grep -q "^$secret$"; then
            found_secrets+=("$secret")
        else
            missing_optional+=("$secret")
        fi
    done
    
    # 結果表示
    echo ""
    log_info "=== Secrets検証結果 ==="
    
    if [[ ${#found_secrets[@]} -gt 0 ]]; then
        log_success "設定済みSecrets (${#found_secrets[@]}個):"
        for secret in "${found_secrets[@]}"; do
            echo "  ✓ $secret"
        done
    fi
    
    if [[ ${#missing_required[@]} -gt 0 ]]; then
        log_error "不足している必須Secrets (${#missing_required[@]}個):"
        for secret in "${missing_required[@]}"; do
            echo "  ✗ $secret"
        done
    fi
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        log_warning "不足しているオプションSecrets (${#missing_optional[@]}個):"
        for secret in "${missing_optional[@]}"; do
            echo "  ? $secret"
        done
    fi
    
    # 環境別Secretsの詳細
    echo ""
    log_info "=== 環境別Secrets ==="
    local env_secrets=$(get_environment_secrets "$current_secrets")
    if [[ -n "$env_secrets" ]]; then
        log_success "$ENVIRONMENT環境用Secrets:"
        echo "$env_secrets" | while read secret; do
            echo "  ✓ $secret"
        done
    else
        log_warning "$ENVIRONMENT環境用Secretsが設定されていません"
    fi
    
    # 共通Secretsの詳細
    echo ""
    log_info "=== 共通Secrets ==="
    local common_secrets=$(get_common_secrets "$current_secrets")
    if [[ -n "$common_secrets" ]]; then
        log_success "共通Secrets:"
        echo "$common_secrets" | while read secret; do
            echo "  ✓ $secret"
        done
    else
        log_warning "共通Secretsが設定されていません"
    fi
    
    # 結果サマリー
    echo ""
    log_info "=== 検証サマリー ==="
    local total_secrets=$(echo "$current_secrets" | wc -l)
    local required_count=${#REQUIRED_SECRETS[@]}
    local optional_count=${#OPTIONAL_SECRETS[@]}
    local total_expected=$((required_count + optional_count))
    
    echo "総Secrets数: $total_secrets"
    echo "必須Secrets数: $required_count"
    echo "オプションSecrets数: $optional_count"
    echo "期待される総数: $total_expected"
    
    if [[ ${#missing_required[@]} -eq 0 ]]; then
        log_success "✓ すべての必須Secretsが設定されています"
        return 0
    else
        log_error "✗ 必須Secretsが不足しています"
        return 1
    fi
}

# セキュリティチェック
security_check() {
    log_info "=== セキュリティチェック ==="
    
    # 環境変数の漏洩チェック
    local env_vars=$(env | grep -i -E "(password|secret|token|key)" | wc -l)
    if [[ $env_vars -gt 0 ]]; then
        log_warning "環境変数に機密情報が含まれている可能性があります"
        echo "機密情報を含む環境変数数: $env_vars"
    else
        log_success "✓ 環境変数に機密情報の漏洩は検出されませんでした"
    fi
    
    # ファイル権限チェック
    if [[ -f "config/secrets-${ENVIRONMENT}.env" ]]; then
        local file_perms=$(stat -c "%a" "config/secrets-${ENVIRONMENT}.env")
        if [[ "$file_perms" != "600" ]]; then
            log_warning "設定ファイルの権限が適切ではありません: $file_perms"
            echo "推奨権限: 600 (所有者のみ読み書き)"
        else
            log_success "✓ 設定ファイルの権限が適切です"
        fi
    fi
}

# 推奨事項の表示
show_recommendations() {
    log_info "=== 推奨事項 ==="
    
    echo "1. 定期的なSecrets更新:"
    echo "   - 3ヶ月ごとにパスワードを更新"
    echo "   - 使用していないSecretsを削除"
    echo ""
    
    echo "2. セキュリティ強化:"
    echo "   - 強力なパスワードの使用"
    echo "   - 最小権限の原則"
    echo "   - アクセスログの監視"
    echo ""
    
    echo "3. 監視・アラート:"
    echo "   - Secrets変更の通知設定"
    echo "   - 異常アクセスの検出"
    echo "   - 定期的なセキュリティ監査"
    echo ""
    
    echo "4. バックアップ:"
    echo "   - Secrets設定のバックアップ"
    echo "   - 復旧手順の文書化"
    echo "   - 定期復旧テストの実施"
}

# メイン処理
main() {
    log_info "GitHub Secrets検証を開始します..."
    
    # 現在のSecretsを取得
    local current_secrets=$(get_current_secrets)
    if [[ $? -ne 0 ]]; then
        log_error "Secrets取得に失敗しました"
        exit 1
    fi
    
    # Secretsの検証
    verify_secrets "$current_secrets"
    local verify_result=$?
    
    # セキュリティチェック
    security_check
    
    # 推奨事項の表示
    show_recommendations
    
    # 結果サマリー
    echo ""
    if [[ $verify_result -eq 0 ]]; then
        log_success "GitHub Secrets検証が完了しました！"
        log_success "すべての必須Secretsが正しく設定されています。"
    else
        log_error "GitHub Secrets検証で問題が見つかりました。"
        log_error "不足しているSecretsを設定してください。"
        exit 1
    fi
}

# スクリプト実行
main "$@" 