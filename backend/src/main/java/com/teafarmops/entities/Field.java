package com.teafarmops.entities;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.util.ArrayList;
import java.util.List;

/**
 * 茶園フィールドエンティティ
 * 茶園の各フィールドの情報を管理
 */
@Entity
@Table(name = "fields")
public class Field {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @NotBlank(message = "フィールド名は必須です")
  @Column(nullable = false)
  private String name;

  @NotBlank(message = "場所は必須です")
  @Column(nullable = false)
  private String location;

  @NotNull(message = "面積は必須です")
  @Positive(message = "面積は正の数である必要があります")
  @Column(name = "area_size", nullable = false)
  private Double areaSize;

  @Column(name = "soil_type")
  private String soilType;

  @Column(columnDefinition = "TEXT")
  private String notes;

  @OneToMany(mappedBy = "field", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  private List<Task> tasks = new ArrayList<>();

  @OneToMany(mappedBy = "field", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  private List<HarvestRecord> harvestRecords = new ArrayList<>();

  @OneToMany(mappedBy = "field", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
  private List<WeatherObservation> weatherObservations = new ArrayList<>();

  // デフォルトコンストラクタ
  public Field() {}

  // コンストラクタ
  public Field(String name, String location, Double areaSize, String soilType, String notes) {
    this.name = name;
    this.location = location;
    this.areaSize = areaSize;
    this.soilType = soilType;
    this.notes = notes;
  }

  // Getter and Setter methods
  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getLocation() {
    return location;
  }

  public void setLocation(String location) {
    this.location = location;
  }

  public Double getAreaSize() {
    return areaSize;
  }

  public void setAreaSize(Double areaSize) {
    this.areaSize = areaSize;
  }

  public String getSoilType() {
    return soilType;
  }

  public void setSoilType(String soilType) {
    this.soilType = soilType;
  }

  public String getNotes() {
    return notes;
  }

  public void setNotes(String notes) {
    this.notes = notes;
  }

  public List<Task> getTasks() {
    return tasks;
  }

  public void setTasks(List<Task> tasks) {
    this.tasks = tasks;
  }

  public List<HarvestRecord> getHarvestRecords() {
    return harvestRecords;
  }

  public void setHarvestRecords(List<HarvestRecord> harvestRecords) {
    this.harvestRecords = harvestRecords;
  }

  public List<WeatherObservation> getWeatherObservations() {
    return weatherObservations;
  }

  public void setWeatherObservations(List<WeatherObservation> weatherObservations) {
    this.weatherObservations = weatherObservations;
  }
} 