package com.teafarmops.repositories;

import com.teafarmops.entities.WeatherObservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

/**
 * 天候観測リポジトリ
 * 天候観測エンティティのデータアクセス層
 */
@Repository
public interface WeatherObservationRepository extends JpaRepository<WeatherObservation, Long> {

  /**
   * フィールドIDで天候観測を検索
   * @param fieldId フィールドID
   * @return 天候観測リスト
   */
  List<WeatherObservation> findByFieldId(Long fieldId);

  /**
   * 観測日で天候観測を検索
   * @param date 観測日
   * @return 天候観測リスト
   */
  List<WeatherObservation> findByDate(LocalDate date);

  /**
   * 観測日範囲で天候観測を検索
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 天候観測リスト
   */
  List<WeatherObservation> findByDateBetween(LocalDate startDate, LocalDate endDate);

  /**
   * 害虫が確認された観測を検索
   * @param pestsSeen 害虫名
   * @return 天候観測リスト
   */
  List<WeatherObservation> findByPestsSeenContainingIgnoreCase(String pestsSeen);

  /**
   * 指定期間の平均気温を取得
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 平均気温
   */
  @Query("SELECT AVG(w.temperature) FROM WeatherObservation w WHERE w.date BETWEEN ?1 AND ?2")
  Double getAverageTemperatureBetween(LocalDate startDate, LocalDate endDate);

  /**
   * 指定期間の総降雨量を取得
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 総降雨量
   */
  @Query("SELECT SUM(w.rainfall) FROM WeatherObservation w WHERE w.date BETWEEN ?1 AND ?2")
  Double getTotalRainfallBetween(LocalDate startDate, LocalDate endDate);

  /**
   * 指定期間の平均湿度を取得
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 平均湿度
   */
  @Query("SELECT AVG(w.humidity) FROM WeatherObservation w WHERE w.date BETWEEN ?1 AND ?2")
  Double getAverageHumidityBetween(LocalDate startDate, LocalDate endDate);
} 