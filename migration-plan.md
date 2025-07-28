# TeaFarmOps React + Spring Boot REST API 移行計画

## 現在の進捗状況

### ✅ 完了済み
- [x] プロジェクト構造の設計
- [x] バックエンドディレクトリの作成
- [x] React TypeScriptプロジェクトの作成
- [x] 必要なパッケージのインストール
- [x] TypeScript型定義の作成
- [x] APIサービス層の作成

### 🔄 進行中
- [ ] バックエンド REST API 化
- [ ] フロントエンド React 開発

## プロジェクト構造

```
tea-farm-ops/
├── backend/                    # Spring Boot REST API
│   ├── src/main/java/com/teafarmops/
│   │   ├── controllers/        # REST API コントローラー
│   │   ├── entities/          # JPA エンティティ
│   │   ├── repositories/      # データアクセス層
│   │   ├── services/          # ビジネスロジック
│   │   ├── config/            # 設定クラス
│   │   └── dto/               # データ転送オブジェクト
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   └── data.sql
│   └── pom.xml
├── frontend/                   # React TypeScript アプリケーション
│   ├── src/
│   │   ├── components/        # React コンポーネント
│   │   ├── pages/            # ページコンポーネント
│   │   ├── services/         # API サービス ✅
│   │   ├── types/            # TypeScript 型定義 ✅
│   │   ├── hooks/            # カスタムフック
│   │   ├── utils/            # ユーティリティ
│   │   └── styles/           # CSS/SCSS ファイル
│   ├── public/
│   ├── package.json
│   └── tsconfig.json
└── README.md
```

## 次のステップ

### フェーズ1: バックエンド REST API 化（優先度：高）
- [ ] Spring Boot を REST API に変更
- [ ] Thymeleaf コントローラーを REST コントローラーに変換
- [ ] CORS 設定の追加
- [ ] JWT 認証の実装
- [ ] API ドキュメント（Swagger）の追加

### フェーズ2: フロントエンド React 開発（優先度：高）
- [ ] ルーティング設定（React Router）
- [ ] 状態管理（Redux Toolkit）
- [ ] UI ライブラリの設定（Material-UI）
- [ ] 認証コンポーネントの実装
- [ ] ダッシュボードコンポーネントの実装

### フェーズ3: 機能移行（優先度：中）
- [ ] フィールド管理
- [ ] タスク管理
- [ ] 収穫記録
- [ ] 天候観測

### フェーズ4: 最適化・テスト（優先度：低）
- [ ] パフォーマンス最適化
- [ ] ユニットテスト
- [ ] E2E テスト
- [ ] デプロイ設定

## 技術スタック

### バックエンド
- Spring Boot 3.2.0
- Spring Security + JWT
- Spring Data JPA
- PostgreSQL
- Swagger/OpenAPI

### フロントエンド
- React 18 ✅
- TypeScript 5 ✅
- React Router v6
- Redux Toolkit
- Material-UI ✅
- Axios ✅
- Create React App

## メリット

### 開発体験
- 型安全性による開発効率向上 ✅
- モダンな開発ツールチェーン ✅
- 豊富なライブラリエコシステム ✅

### ユーザー体験
- シングルページアプリケーション（SPA）
- リアルタイム更新
- モバイルレスポンシブ対応
- オフライン対応可能

### 保守性
- フロントエンド・バックエンド分離 ✅
- 独立したデプロイ
- スケーラビリティ向上

## 実装済み機能

### TypeScript型定義
- Field, Task, HarvestRecord, WeatherObservation
- TaskStatus, TaskType, TeaGrade 列挙型
- DashboardStats, User, LoginRequest/Response
- 検索・フィルタパラメータ型

### APIサービス層
- 認証関連（login, logout, getCurrentUser）
- CRUD操作（get, create, update, delete）
- 検索・フィルタ機能
- エラーハンドリング
- 認証トークン管理 