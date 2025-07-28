package com.teafarmops.dto;

import com.teafarmops.entities.TaskStatus;
import com.teafarmops.entities.TaskType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

/**
 * タスクDTO
 * APIリクエスト・レスポンス用のデータ転送オブジェクト
 */
public class TaskDto {

  private Long id;

  @NotNull(message = "タスクタイプは必須です")
  private TaskType taskType;

  private Long fieldId;
  private String fieldName;

  @NotBlank(message = "担当者は必須です")
  private String assignedWorker;

  @NotNull(message = "開始日は必須です")
  private LocalDate startDate;

  @NotNull(message = "終了日は必須です")
  private LocalDate endDate;

  @NotNull(message = "ステータスは必須です")
  private TaskStatus status;

  private String notes;

  // デフォルトコンストラクタ
  public TaskDto() {}

  // コンストラクタ
  public TaskDto(Long id, TaskType taskType, Long fieldId, String fieldName, 
                String assignedWorker, LocalDate startDate, LocalDate endDate, 
                TaskStatus status, String notes) {
    this.id = id;
    this.taskType = taskType;
    this.fieldId = fieldId;
    this.fieldName = fieldName;
    this.assignedWorker = assignedWorker;
    this.startDate = startDate;
    this.endDate = endDate;
    this.status = status;
    this.notes = notes;
  }

  // Getter and Setter methods
  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public TaskType getTaskType() {
    return taskType;
  }

  public void setTaskType(TaskType taskType) {
    this.taskType = taskType;
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

  public String getAssignedWorker() {
    return assignedWorker;
  }

  public void setAssignedWorker(String assignedWorker) {
    this.assignedWorker = assignedWorker;
  }

  public LocalDate getStartDate() {
    return startDate;
  }

  public void setStartDate(LocalDate startDate) {
    this.startDate = startDate;
  }

  public LocalDate getEndDate() {
    return endDate;
  }

  public void setEndDate(LocalDate endDate) {
    this.endDate = endDate;
  }

  public TaskStatus getStatus() {
    return status;
  }

  public void setStatus(TaskStatus status) {
    this.status = status;
  }

  public String getNotes() {
    return notes;
  }

  public void setNotes(String notes) {
    this.notes = notes;
  }
} 