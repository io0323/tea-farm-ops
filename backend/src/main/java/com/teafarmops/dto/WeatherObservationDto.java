package com.teafarmops.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

/**
 * 天候観測DTO
 * APIリクエスト・レスポンス用のデータ転送オブジェクト
 */
public class WeatherObservationDto {

  private Long id;

  @NotNull(message = "観測日は必須です")
  private LocalDate date;

  private Long fieldId;
  private String fieldName;

  @NotNull(message = "気温は必須です")
  private Double temperature;

  @NotNull(message = "降水量は必須です")
  private Double rainfall;

  @NotNull(message = "湿度は必須です")
  private Double humidity;

  private String pestsSeen;
  private String notes;

  // デフォルトコンストラクタ
  public WeatherObservationDto() {}

  // コンストラクタ
  public WeatherObservationDto(Long id, LocalDate date, Long fieldId, String fieldName,
                              Double temperature, Double rainfall, Double humidity,
                              String pestsSeen, String notes) {
    this.id = id;
    this.date = date;
    this.fieldId = fieldId;
    this.fieldName = fieldName;
    this.temperature = temperature;
    this.rainfall = rainfall;
    this.humidity = humidity;
    this.pestsSeen = pestsSeen;
    this.notes = notes;
  }

  // Getter and Setter methods
  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public LocalDate getDate() {
    return date;
  }

  public void setDate(LocalDate date) {
    this.date = date;
  }

  public Long getFieldId() {
    return fieldId;
  }

  public void setFieldId(Long fieldId) {
    this.fieldId = fieldId;
  }

  public String getFieldName() {
    return fieldName;
  }

  public void setFieldName(String fieldName) {
    this.fieldName = fieldName;
  }

  public Double getTemperature() {
    return temperature;
  }

  public void setTemperature(Double temperature) {
    this.temperature = temperature;
  }

  public Double getRainfall() {
    return rainfall;
  }

  public void setRainfall(Double rainfall) {
    this.rainfall = rainfall;
  }

  public Double getHumidity() {
    return humidity;
  }

  public void setHumidity(Double humidity) {
    this.humidity = humidity;
  }

  public String getPestsSeen() {
    return pestsSeen;
  }

  public void setPestsSeen(String pestsSeen) {
    this.pestsSeen = pestsSeen;
  }

  public String getNotes() {
    return notes;
  }

  public void setNotes(String notes) {
    this.notes = notes;
  }
} 