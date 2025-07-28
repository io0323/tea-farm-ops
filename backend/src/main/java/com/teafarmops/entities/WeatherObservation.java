package com.teafarmops.entities;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

/**
 * 天候観測エンティティ
 * 茶園での天候と観察記録を管理
 */
@Entity
@Table(name = "weather_observations")
public class WeatherObservation {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @NotNull(message = "観測日は必須です")
  @Column(nullable = false)
  private LocalDate date;

  @NotNull(message = "フィールドは必須です")
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "field_id", nullable = false)
  private Field field;

  @Column(precision = 5)
  private Double temperature;

  @Column(precision = 5)
  private Double rainfall;

  @Column(precision = 5)
  private Double humidity;

  @Column(name = "pests_seen")
  private String pestsSeen;

  @Column(columnDefinition = "TEXT")
  private String notes;

  // デフォルトコンストラクタ
  public WeatherObservation() {}

  // コンストラクタ
  public WeatherObservation(LocalDate date, Field field, Double temperature, 
                           Double rainfall, Double humidity, String pestsSeen, String notes) {
    this.date = date;
    this.field = field;
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

  public Field getField() {
    return field;
  }

  public void setField(Field field) {
    this.field = field;
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