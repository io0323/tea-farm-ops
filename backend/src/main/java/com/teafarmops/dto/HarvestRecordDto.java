package com.teafarmops.dto;

import com.teafarmops.entities.TeaGrade;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;

/**
 * 収穫記録DTO
 * APIリクエスト・レスポンス用のデータ転送オブジェクト
 */
public class HarvestRecordDto {

  private Long id;

  private Long fieldId;
  private String fieldName;

  @NotNull(message = "収穫日は必須です")
  private LocalDate harvestDate;

  @NotNull(message = "収穫量は必須です")
  @Positive(message = "収穫量は正の数である必要があります")
  private Double quantityKg;

  @NotNull(message = "茶葉グレードは必須です")
  private TeaGrade teaGrade;

  private String notes;

  // デフォルトコンストラクタ
  public HarvestRecordDto() {}

  // コンストラクタ
  public HarvestRecordDto(Long id, Long fieldId, String fieldName, LocalDate harvestDate, 
                         Double quantityKg, TeaGrade teaGrade, String notes) {
    this.id = id;
    this.fieldId = fieldId;
    this.fieldName = fieldName;
    this.harvestDate = harvestDate;
    this.quantityKg = quantityKg;
    this.teaGrade = teaGrade;
    this.notes = notes;
  }

  // Getter and Setter methods
  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
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

  public LocalDate getHarvestDate() {
    return harvestDate;
  }

  public void setHarvestDate(LocalDate harvestDate) {
    this.harvestDate = harvestDate;
  }

  public Double getQuantityKg() {
    return quantityKg;
  }

  public void setQuantityKg(Double quantityKg) {
    this.quantityKg = quantityKg;
  }

  public TeaGrade getTeaGrade() {
    return teaGrade;
  }

  public void setTeaGrade(TeaGrade teaGrade) {
    this.teaGrade = teaGrade;
  }

  public String getNotes() {
    return notes;
  }

  public void setNotes(String notes) {
    this.notes = notes;
  }
} 