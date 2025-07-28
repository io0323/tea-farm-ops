# TeaFarmOps - 茶園運営管理システム

TeaFarmOpsは、茶園の日常的な運営を効率的に管理するためのSpring BootベースのWebアプリケーションです。

## 🎯 機能概要

### コア機能
- **フィールド管理**: 茶園フィールドの情報管理（名前、場所、面積、土壌タイプなど）
- **タスク管理**: 作業タスクのスケジューリングと進捗管理
- **収穫記録**: 収穫量と品質の記録・分析
- **天候観測**: 気象データと害虫観察の記録
- **ダッシュボード**: 運営状況の一覧表示と統計情報

### 技術スタック
- **バックエンド**: Spring Boot 3.2.0, Spring Data JPA, Spring Security
- **フロントエンド**: Thymeleaf, Bootstrap 5, Bootstrap Icons
- **データベース**: PostgreSQL
- **ビルドツール**: Maven
- **Java**: 17

## 🚀 セットアップ

### 前提条件
- Java 17以上
- Maven 3.6以上
- PostgreSQL 12以上

### 1. データベースの準備
```sql
CREATE DATABASE teafarmops;
CREATE USER postgres WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE teafarmops TO postgres;
```

### 2. アプリケーションの設定
`src/main/resources/application.properties`を編集して、データベース接続情報を設定してください：

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/teafarmops
spring.datasource.username=postgres
spring.datasource.password=password
```

### 3. アプリケーションの起動
```bash
# プロジェクトのルートディレクトリで実行
mvn spring-boot:run
```

### 4. アクセス
ブラウザで `http://localhost:8080` にアクセスしてください。

## 👤 ログイン情報

### 管理者アカウント
- ユーザー名: `admin`
- パスワード: `admin123`

### 作業員アカウント
- ユーザー名: `worker`
- パスワード: `worker123`

## 📁 プロジェクト構造

```
src/
├── main/
│   ├── java/com/teafarmops/
│   │   ├── controllers/          # Webコントローラー
│   │   │   ├── FieldController.java
│   │   │   ├── TaskController.java
│   │   │   ├── HarvestRecordController.java
│   │   │   ├── WeatherObservationController.java
│   │   │   ├── DashboardController.java
│   │   │   ├── LoginController.java
│   │   │   └── GlobalExceptionHandler.java
│   │   ├── entities/            # JPAエンティティ
│   │   │   ├── Field.java
│   │   │   ├── Task.java
│   │   │   ├── HarvestRecord.java
│   │   │   └── WeatherObservation.java
│   │   ├── repositories/        # データアクセス層
│   │   │   ├── FieldRepository.java
│   │   │   ├── TaskRepository.java
│   │   │   ├── HarvestRecordRepository.java
│   │   │   └── WeatherObservationRepository.java
│   │   ├── services/            # ビジネスロジック
│   │   │   ├── FieldService.java
│   │   │   ├── TaskService.java
│   │   │   ├── HarvestRecordService.java
│   │   │   └── WeatherObservationService.java
│   │   ├── config/              # 設定クラス
│   │   │   └── SecurityConfig.java
│   │   ├── utils/               # ユーティリティ
│   │   │   └── DateUtils.java
│   │   └── TeaFarmOpsApplication.java
│   └── resources/
│       ├── templates/           # Thymeleafテンプレート
│       │   ├── layout.html      # 共通レイアウト
│       │   ├── login.html       # ログイン画面
│       │   ├── dashboard.html   # ダッシュボード
│       │   ├── fields/          # フィールド管理画面
│       │   ├── tasks/           # タスク管理画面
│       │   ├── harvest-records/ # 収穫記録画面
│       │   └── weather-observations/ # 天候観測画面
│       ├── application.properties
│       └── data.sql             # 初期データ
└── test/                        # テストコード
```

## 🎨 UI機能

### ダッシュボード
- フィールド数、総面積、タスク状況の統計表示
- 今月の収穫量、気象データの表示
- 茶葉グレード別収穫量の一覧
- クイックアクションボタン

### フィールド管理
- フィールド一覧表示
- 新規フィールド作成
- フィールド情報編集
- フィールド削除
- 検索機能（名前、場所、土壌タイプ）

### タスク管理
- タスク一覧表示
- 新規タスク作成
- タスク編集・削除
- ステータス管理（未着手、進行中、完了、キャンセル）
- 検索機能（タスクタイプ、ステータス、担当者）

### 収穫記録
- 収穫記録一覧表示
- 新規収穫記録作成
- 収穫量と茶葉グレードの記録
- 検索機能（茶葉グレード）

### 天候観測
- 天候観測記録一覧
- 新規観測記録作成
- 気温、降雨量、湿度の記録
- 害虫観察記録

## 🔧 開発・保守

### コード品質
- 統一されたコーディング規約
- 適切なコメントとドキュメント
- エラーハンドリングの統一
- バリデーション機能

### セキュリティ
- Spring Securityによる認証・認可
- フォームベース認証
- CSRF保護
- セッション管理

### データベース
- JPA/HibernateによるORM
- 自動スキーマ生成
- 初期データの自動投入
- リレーションシップ管理

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🤝 貢献

バグ報告や機能要望は、GitHubのIssuesページでお知らせください。 