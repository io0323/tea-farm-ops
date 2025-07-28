package com.teafarmops.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

/**
 * フィールドDTO
 * APIリクエスト・レスポンス用のデータ転送オブジェクト
 */
public class FieldDto {

  private Long id;

  @NotBlank(message = "フィールド名は必須です")
  private String name;

  @NotBlank(message = "場所は必須です")
  private String location;

  @NotNull(message = "面積は必須です")
  @Positive(message = "面積は正の数である必要があります")
  private Double areaSize;

  private String soilType;
  private String notes;

  // デフォルトコンストラクタ
  public FieldDto() {}

  // コンストラクタ
  public FieldDto(Long id, String name, String location, Double areaSize, String soilType, String notes) {
    this.id = id;
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
} 