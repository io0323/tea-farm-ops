package com.teafarmops.entities;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.time.LocalDate;

/**
 * 収穫記録エンティティ
 * 茶園での収穫記録を管理
 */
@Entity
@Table(name = "harvest_records")
public class HarvestRecord {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @NotNull(message = "フィールドは必須です")
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "field_id", nullable = false)
  private Field field;

  @NotNull(message = "収穫日は必須です")
  @Column(name = "harvest_date", nullable = false)
  private LocalDate harvestDate;

  @NotNull(message = "収穫量は必須です")
  @Positive(message = "収穫量は正の数である必要があります")
  @Column(name = "quantity_kg", nullable = false)
  private Double quantityKg;

  @NotBlank(message = "茶葉グレードは必須です")
  @Column(name = "tea_grade", nullable = false)
  private String teaGrade;

  @Column(columnDefinition = "TEXT")
  private String notes;

  // デフォルトコンストラクタ
  public HarvestRecord() {}

  // コンストラクタ
  public HarvestRecord(Field field, LocalDate harvestDate, Double quantityKg, 
                       String teaGrade, String notes) {
    this.field = field;
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

  public Field getField() {
    return field;
  }

  public void setField(Field field) {
    this.field = field;
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

  public String getTeaGrade() {
    return teaGrade;
  }

  public void setTeaGrade(String teaGrade) {
    this.teaGrade = teaGrade;
  }

  public String getNotes() {
    return notes;
  }

  public void setNotes(String notes) {
    this.notes = notes;
  }
} 