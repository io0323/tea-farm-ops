# マルチステージビルド
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# フロントエンドの依存関係をインストール
COPY frontend/package*.json ./
RUN npm ci --only=production

# フロントエンドのソースコードをコピー
COPY frontend/ ./

# フロントエンドをビルド
RUN npm run build

# バックエンドビルド
FROM maven:3.8.4-openjdk-17 AS backend-builder

WORKDIR /app/backend

# バックエンドの依存関係をインストール
COPY backend/pom.xml ./
RUN mvn dependency:go-offline

# バックエンドのソースコードをコピー
COPY backend/ ./

# バックエンドをビルド
RUN mvn clean package -DskipTests

# 本番環境
FROM openjdk:17-jre-alpine

WORKDIR /app

# 必要なパッケージをインストール
RUN apk add --no-cache curl

# バックエンドJARファイルをコピー
COPY --from=backend-builder /app/backend/target/*.jar app.jar

# フロントエンドのビルドファイルをコピー
COPY --from=frontend-builder /app/frontend/build /app/static

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# ポートを公開
EXPOSE 8080

# アプリケーションを起動
ENTRYPOINT ["java", "-jar", "app.jar"] 