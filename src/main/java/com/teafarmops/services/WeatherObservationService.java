package com.teafarmops.services;

import com.teafarmops.entities.Field;
import com.teafarmops.entities.WeatherObservation;
import com.teafarmops.repositories.FieldRepository;
import com.teafarmops.repositories.WeatherObservationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * 天候観測サービス
 * 天候観測関連のビジネスロジックを管理
 */
@Service
@Transactional
public class WeatherObservationService {

  private final WeatherObservationRepository weatherObservationRepository;
  private final FieldRepository fieldRepository;

  @Autowired
  public WeatherObservationService(WeatherObservationRepository weatherObservationRepository, 
                                 FieldRepository fieldRepository) {
    this.weatherObservationRepository = weatherObservationRepository;
    this.fieldRepository = fieldRepository;
  }

  /**
   * 全天候観測を取得
   * @return 天候観測リスト
   */
  public List<WeatherObservation> getAllWeatherObservations() {
    return weatherObservationRepository.findAll();
  }

  /**
   * IDで天候観測を取得
   * @param id 天候観測ID
   * @return 天候観測（オプショナル）
   */
  public Optional<WeatherObservation> getWeatherObservationById(Long id) {
    return weatherObservationRepository.findById(id);
  }

  /**
   * 天候観測を保存
   * @param weatherObservation 天候観測
   * @return 保存された天候観測
   */
  public WeatherObservation saveWeatherObservation(WeatherObservation weatherObservation) {
    return weatherObservationRepository.save(weatherObservation);
  }

  /**
   * 天候観測を更新
   * @param id 天候観測ID
   * @param weatherObservationDetails 更新する天候観測詳細
   * @return 更新された天候観測
   */
  public WeatherObservation updateWeatherObservation(Long id, WeatherObservation weatherObservationDetails) {
    WeatherObservation weatherObservation = weatherObservationRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("天候観測が見つかりません: " + id));

    weatherObservation.setDate(weatherObservationDetails.getDate());
    weatherObservation.setField(weatherObservationDetails.getField());
    weatherObservation.setTemperature(weatherObservationDetails.getTemperature());
    weatherObservation.setRainfall(weatherObservationDetails.getRainfall());
    weatherObservation.setHumidity(weatherObservationDetails.getHumidity());
    weatherObservation.setPestsSeen(weatherObservationDetails.getPestsSeen());
    weatherObservation.setNotes(weatherObservationDetails.getNotes());

    return weatherObservationRepository.save(weatherObservation);
  }

  /**
   * 天候観測を削除
   * @param id 天候観測ID
   */
  public void deleteWeatherObservation(Long id) {
    WeatherObservation weatherObservation = weatherObservationRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("天候観測が見つかりません: " + id));
    weatherObservationRepository.delete(weatherObservation);
  }

  /**
   * フィールドIDで天候観測を検索
   * @param fieldId フィールドID
   * @return 天候観測リスト
   */
  public List<WeatherObservation> getWeatherObservationsByFieldId(Long fieldId) {
    return weatherObservationRepository.findByFieldId(fieldId);
  }

  /**
   * 観測日で天候観測を検索
   * @param date 観測日
   * @return 天候観測リスト
   */
  public List<WeatherObservation> getWeatherObservationsByDate(LocalDate date) {
    return weatherObservationRepository.findByDate(date);
  }

  /**
   * 観測日範囲で天候観測を検索
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 天候観測リスト
   */
  public List<WeatherObservation> getWeatherObservationsByDateRange(LocalDate startDate, LocalDate endDate) {
    return weatherObservationRepository.findByDateBetween(startDate, endDate);
  }

  /**
   * 害虫が確認された観測を検索
   * @param pestsSeen 害虫名
   * @return 天候観測リスト
   */
  public List<WeatherObservation> getWeatherObservationsByPests(String pestsSeen) {
    return weatherObservationRepository.findByPestsSeenContainingIgnoreCase(pestsSeen);
  }

  /**
   * 指定期間の平均気温を取得
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 平均気温
   */
  public Double getAverageTemperatureBetween(LocalDate startDate, LocalDate endDate) {
    return weatherObservationRepository.getAverageTemperatureBetween(startDate, endDate);
  }

  /**
   * 指定期間の総降雨量を取得
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 総降雨量
   */
  public Double getTotalRainfallBetween(LocalDate startDate, LocalDate endDate) {
    return weatherObservationRepository.getTotalRainfallBetween(startDate, endDate);
  }

  /**
   * 指定期間の平均湿度を取得
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 平均湿度
   */
  public Double getAverageHumidityBetween(LocalDate startDate, LocalDate endDate) {
    return weatherObservationRepository.getAverageHumidityBetween(startDate, endDate);
  }

  /**
   * フィールドIDでフィールドを取得
   * @param fieldId フィールドID
   * @return フィールド（オプショナル）
   */
  public Optional<Field> getFieldById(Long fieldId) {
    return fieldRepository.findById(fieldId);
  }
} 