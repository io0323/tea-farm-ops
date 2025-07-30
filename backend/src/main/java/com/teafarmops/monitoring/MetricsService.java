package com.teafarmops.monitoring;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * カスタムメトリクスを収集するサービス
 * ビジネスメトリクスとアプリケーション固有のメトリクスを管理
 */
@Service
public class MetricsService {

    private final MeterRegistry meterRegistry;
    
    // カウンター
    private final Counter loginAttemptsCounter;
    private final Counter successfulLoginsCounter;
    private final Counter failedLoginsCounter;
    private final Counter apiRequestsCounter;
    private final Counter errorsCounter;
    
    // ゲージ
    private final AtomicInteger activeUsersGauge;
    private final AtomicInteger totalFieldsGauge;
    private final AtomicInteger totalTasksGauge;
    private final AtomicInteger pendingTasksGauge;
    
    // タイマー
    private final Timer apiResponseTimeTimer;
    private final Timer databaseQueryTimer;

    @Autowired
    public MetricsService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        
        // カウンターの初期化
        this.loginAttemptsCounter = Counter.builder("tea_farm_ops_login_attempts_total")
                .description("総ログイン試行回数")
                .register(meterRegistry);
                
        this.successfulLoginsCounter = Counter.builder("tea_farm_ops_successful_logins_total")
                .description("成功したログイン回数")
                .register(meterRegistry);
                
        this.failedLoginsCounter = Counter.builder("tea_farm_ops_failed_logins_total")
                .description("失敗したログイン回数")
                .register(meterRegistry);
                
        this.apiRequestsCounter = Counter.builder("tea_farm_ops_api_requests_total")
                .description("APIリクエスト総数")
                .tag("endpoint", "all")
                .register(meterRegistry);
                
        this.errorsCounter = Counter.builder("tea_farm_ops_errors_total")
                .description("アプリケーションエラー総数")
                .register(meterRegistry);
        
        // ゲージの初期化
        this.activeUsersGauge = new AtomicInteger(0);
        this.totalFieldsGauge = new AtomicInteger(0);
        this.totalTasksGauge = new AtomicInteger(0);
        this.pendingTasksGauge = new AtomicInteger(0);
        
        Gauge.builder("tea_farm_ops_active_users", activeUsersGauge, AtomicInteger::get)
                .description("アクティブユーザー数")
                .register(meterRegistry);
                
        Gauge.builder("tea_farm_ops_total_fields", totalFieldsGauge, AtomicInteger::get)
                .description("総フィールド数")
                .register(meterRegistry);
                
        Gauge.builder("tea_farm_ops_total_tasks", totalTasksGauge, AtomicInteger::get)
                .description("総タスク数")
                .register(meterRegistry);
                
        Gauge.builder("tea_farm_ops_pending_tasks", pendingTasksGauge, AtomicInteger::get)
                .description("保留中タスク数")
                .register(meterRegistry);
        
        // タイマーの初期化
        this.apiResponseTimeTimer = Timer.builder("tea_farm_ops_api_response_time")
                .description("APIレスポンス時間")
                .register(meterRegistry);
                
        this.databaseQueryTimer = Timer.builder("tea_farm_ops_database_query_time")
                .description("データベースクエリ実行時間")
                .register(meterRegistry);
    }

    /**
     * ログイン試行を記録
     */
    public void recordLoginAttempt() {
        loginAttemptsCounter.increment();
    }

    /**
     * 成功したログインを記録
     */
    public void recordSuccessfulLogin() {
        successfulLoginsCounter.increment();
    }

    /**
     * 失敗したログインを記録
     */
    public void recordFailedLogin() {
        failedLoginsCounter.increment();
    }

    /**
     * APIリクエストを記録
     * @param endpoint エンドポイント名
     */
    public void recordApiRequest(String endpoint) {
        Counter.builder("tea_farm_ops_api_requests_total")
                .tag("endpoint", endpoint)
                .register(meterRegistry)
                .increment();
        apiRequestsCounter.increment();
    }

    /**
     * エラーを記録
     * @param errorType エラータイプ
     */
    public void recordError(String errorType) {
        Counter.builder("tea_farm_ops_errors_total")
                .tag("error_type", errorType)
                .register(meterRegistry)
                .increment();
        errorsCounter.increment();
    }

    /**
     * アクティブユーザー数を設定
     * @param count ユーザー数
     */
    public void setActiveUsers(int count) {
        activeUsersGauge.set(count);
    }

    /**
     * 総フィールド数を設定
     * @param count フィールド数
     */
    public void setTotalFields(int count) {
        totalFieldsGauge.set(count);
    }

    /**
     * 総タスク数を設定
     * @param count タスク数
     */
    public void setTotalTasks(int count) {
        totalTasksGauge.set(count);
    }

    /**
     * 保留中タスク数を設定
     * @param count タスク数
     */
    public void setPendingTasks(int count) {
        pendingTasksGauge.set(count);
    }

    /**
     * APIレスポンス時間を記録
     * @return Timer.Sample タイマーサンプル
     */
    public Timer.Sample startApiResponseTimer() {
        return Timer.start(meterRegistry);
    }

    /**
     * APIレスポンス時間を停止
     * @param sample タイマーサンプル
     */
    public void stopApiResponseTimer(Timer.Sample sample) {
        sample.stop(apiResponseTimeTimer);
    }

    /**
     * データベースクエリ時間を記録
     * @return Timer.Sample タイマーサンプル
     */
    public Timer.Sample startDatabaseQueryTimer() {
        return Timer.start(meterRegistry);
    }

    /**
     * データベースクエリ時間を停止
     * @param sample タイマーサンプル
     */
    public void stopDatabaseQueryTimer(Timer.Sample sample) {
        sample.stop(databaseQueryTimer);
    }

    /**
     * カスタムメトリクスを記録
     * @param name メトリクス名
     * @param value 値
     * @param tags タグ
     */
    public void recordCustomMetric(String name, double value, String... tags) {
        Gauge.builder(name, () -> value)
                .register(meterRegistry);
    }

    /**
     * カスタムカウンターを記録
     * @param name メトリクス名
     * @param tags タグ
     */
    public void incrementCustomCounter(String name, String... tags) {
        Counter.builder(name)
                .tags(tags)
                .register(meterRegistry)
                .increment();
    }
} 