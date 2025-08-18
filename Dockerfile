# マルチステージビルド
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# フロントエンドの依存関係をインストール
COPY frontend/package*.json ./
RUN npm install

# フロントエンドのソースコードをコピー
COPY frontend/ ./

# フロントエンドをビルド
RUN npm run build

# バックエンドビルド
FROM maven:3.9.11-eclipse-temurin-17 AS backend-builder

WORKDIR /app/backend

# バックエンドの依存関係をインストール
COPY backend/pom.xml ./
RUN mvn dependency:go-offline

# バックエンドのソースコードをコピー
COPY backend/ ./

# バックエンドをビルド
RUN mvn clean package -DskipTests

# 本番環境
FROM eclipse-temurin:17-jre-alpine

# 非rootユーザーを作成
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# 必要なパッケージをインストール
RUN apk add --no-cache curl

# バックエンドJARファイルをコピー
COPY --from=backend-builder /app/backend/target/*.jar app.jar

# フロントエンドのビルドファイルをコピー
COPY --from=frontend-builder /app/frontend/build /app/static

# ファイルの所有者を変更
RUN chown -R appuser:appgroup /app

# 非rootユーザーに切り替え
USER appuser

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# ポートを公開
EXPOSE 8080

# アプリケーションを起動
ENTRYPOINT ["java", "-jar", "app.jar"] 