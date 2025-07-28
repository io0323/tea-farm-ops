package com.teafarmops.controllers;

import com.teafarmops.dto.WeatherObservationDto;
import com.teafarmops.entities.WeatherObservation;
import com.teafarmops.services.WeatherObservationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 天候観測REST APIコントローラー
 * 天候観測関連のREST APIエンドポイント
 */
@RestController
@RequestMapping("/api/weather-observations")
@CrossOrigin(origins = "*")
public class WeatherObservationApiController {

  private final WeatherObservationService weatherObservationService;

  @Autowired
  public WeatherObservationApiController(WeatherObservationService weatherObservationService) {
    this.weatherObservationService = weatherObservationService;
  }

  /**
   * 天候観測一覧を取得
   * @param startDate 開始日（検索用）
   * @param endDate 終了日（検索用）
   * @param fieldId フィールドID（検索用）
   * @return 天候観測一覧
   */
  @GetMapping
  public ResponseEntity<List<WeatherObservationDto>> getWeatherObservations(
      @RequestParam(required = false) String startDate,
      @RequestParam(required = false) String endDate,
      @RequestParam(required = false) Long fieldId) {
    
    List<WeatherObservation> observations = weatherObservationService.getAllWeatherObservations();
    
    List<WeatherObservationDto> observationDtos = observations.stream()
        .map(this::convertToDto)
        .collect(Collectors.toList());
    
    return ResponseEntity.ok(observationDtos);
  }

  /**
   * 天候観測詳細を取得
   * @param id 天候観測ID
   * @return 天候観測詳細
   */
  @GetMapping("/{id}")
  public ResponseEntity<WeatherObservationDto> getWeatherObservation(@PathVariable Long id) {
    return weatherObservationService.getWeatherObservationById(id)
        .map(this::convertToDto)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
  }

  /**
   * 天候観測を作成
   * @param observationDto 天候観測情報
   * @return 作成された天候観測
   */
  @PostMapping
  public ResponseEntity<WeatherObservationDto> createWeatherObservation(@Valid @RequestBody WeatherObservationDto observationDto) {
    WeatherObservation observation = convertToEntity(observationDto);
    WeatherObservation savedObservation = weatherObservationService.saveWeatherObservation(observation);
    return ResponseEntity.ok(convertToDto(savedObservation));
  }

  /**
   * 天候観測を更新
   * @param id 天候観測ID
   * @param observationDto 更新する天候観測情報
   * @return 更新された天候観測
   */
  @PutMapping("/{id}")
  public ResponseEntity<WeatherObservationDto> updateWeatherObservation(@PathVariable Long id, @Valid @RequestBody WeatherObservationDto observationDto) {
    return weatherObservationService.getWeatherObservationById(id)
        .map(existingObservation -> {
          observationDto.setId(id);
          WeatherObservation updatedObservation = convertToEntity(observationDto);
          WeatherObservation savedObservation = weatherObservationService.saveWeatherObservation(updatedObservation);
          return ResponseEntity.ok(convertToDto(savedObservation));
        })
        .orElse(ResponseEntity.notFound().build());
  }

  /**
   * 天候観測を削除
   * @param id 天候観測ID
   * @return 削除結果
   */
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteWeatherObservation(@PathVariable Long id) {
    if (weatherObservationService.getWeatherObservationById(id).isPresent()) {
      weatherObservationService.deleteWeatherObservation(id);
      return ResponseEntity.noContent().build();
    } else {
      return ResponseEntity.notFound().build();
    }
  }

  /**
   * WeatherObservationDtoをWeatherObservationエンティティに変換
   * @param observationDto DTO
   * @return エンティティ
   */
  private WeatherObservation convertToEntity(WeatherObservationDto observationDto) {
    WeatherObservation observation = new WeatherObservation();
    observation.setId(observationDto.getId());
    observation.setDate(observationDto.getDate());
    observation.setTemperature(observationDto.getTemperature());
    observation.setRainfall(observationDto.getRainfall());
    observation.setHumidity(observationDto.getHumidity());
    observation.setPestsSeen(observationDto.getPestsSeen());
    observation.setNotes(observationDto.getNotes());
    
    // フィールドの設定（簡易版）
    if (observationDto.getFieldId() != null) {
      // 実際の実装ではFieldServiceから取得
    }
    
    return observation;
  }

  /**
   * WeatherObservationエンティティをWeatherObservationDtoに変換
   * @param observation エンティティ
   * @return DTO
   */
  private WeatherObservationDto convertToDto(WeatherObservation observation) {
    WeatherObservationDto dto = new WeatherObservationDto();
    dto.setId(observation.getId());
    dto.setDate(observation.getDate());
    dto.setTemperature(observation.getTemperature());
    dto.setRainfall(observation.getRainfall());
    dto.setHumidity(observation.getHumidity());
    dto.setPestsSeen(observation.getPestsSeen());
    dto.setNotes(observation.getNotes());
    
    if (observation.getField() != null) {
      dto.setFieldId(observation.getField().getId());
      dto.setFieldName(observation.getField().getName());
    }
    
    return dto;
  }
} 