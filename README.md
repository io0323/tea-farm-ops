# TeaFarmOps - 茶園運営管理システム

TeaFarmOpsは、茶園の日常的な運営を効率的に管理するためのフルスタックWebアプリケーションです。

## 🎯 主な機能

- **フィールド管理**: 茶園フィールドの情報管理（名前、場所、面積、土壌タイプなど）
- **タスク管理**: 作業タスクのスケジューリングと進捗管理
- **収穫記録**: 収穫量と品質の記録・分析
- **天候観測**: 気象データと害虫観察の記録
- **ダッシュボード**: 運営状況の一覧表示と統計情報

## 🛠️ 技術スタック

- **バックエンド**: Spring Boot 3.2+, Spring Data JPA, Spring Security, Java 17
- **フロントエンド**: React, TypeScript, MUI (Material-UI)
- **データベース**: PostgreSQL
- **ビルドツール**: Maven
- **インフラ**: Docker, Docker Compose, Nginx

## 🚀 セットアップ手順

### 前提条件
- Java 17以上
- Node.js 18以上
- Maven 3.6以上
- PostgreSQL 12以上
- Docker（本番・検証用）

### 1. データベースの準備
```sql
CREATE DATABASE teafarmops;
CREATE USER postgres WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE teafarmops TO postgres;
```

### 2. バックエンドの起動
```bash
cd backend
mvn spring-boot:run
```

### 3. フロントエンドの起動
```bash
cd frontend
npm install
npm start
```

### 4. Dockerによる一括起動（推奨）
```bash
docker-compose up -d
```

### 5. アクセス
- バックエンド: http://localhost:8080
- フロントエンド: http://localhost:3000

## 👤 ログイン情報

- 管理者: `admin` / `admin123`
- 作業員: `user` / `user123`

## 📁 プロジェクト構造（2024年整理後）

```
tea-farm-ops/
├── backend/                 # Spring Boot バックエンド
│   ├── src/main/java/com/teafarmops/
│   │   ├── config/          # セキュリティ・JWT等の設定
│   │   ├── controllers/     # REST APIコントローラー
│   │   ├── dto/             # DTOクラス
│   │   ├── entities/        # JPAエンティティ
│   │   ├── monitoring/      # 監視用サービス
│   │   ├── repositories/    # リポジトリ層
│   │   ├── services/        # サービス層
│   │   └── utils/           # ユーティリティ
│   └── src/main/resources/
│       ├── application.properties など
│       └── templates/       # Thymeleafテンプレート
├── frontend/                # React + TypeScript フロントエンド
│   ├── src/
│   │   ├── components/      # UIコンポーネント
│   │   ├── hooks/           # カスタムフック
│   │   ├── pages/           # 画面ページ
│   │   ├── routes/          # ルーティング
│   │   ├── services/        # APIサービス
│   │   ├── store/           # Reduxストア
│   │   ├── types/           # 型定義
│   │   └── utils/           # ユーティリティ
│   ├── public/
│   └── ...
├── config/                  # 各種設定ファイル
├── docs/                    # ドキュメント
├── monitoring/              # 監視・パフォーマンス関連
├── scripts/                 # 運用・保守スクリプト
├── ssl/                     # SSL証明書
├── docker-compose.yml       # Docker構成
├── nginx.conf               # Nginx設定
└── README.md                # このファイル
```

## ✨ 2024年整理ポイント
- 不要なファイル・重複ディレクトリの削除
- コードコメントの整理・最適化
- インポート・依存関係のクリーンアップ
- プロジェクト構造の明確化
- コードの可読性・保守性向上

## 📝 ライセンス
MIT

## 🤝 貢献
バグ報告や機能要望は、[GitHub Issues](https://github.com/io0323/tea-farm-ops/issues) までお願いします。 