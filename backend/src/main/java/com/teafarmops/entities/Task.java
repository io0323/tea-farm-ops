package com.teafarmops.entities;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

/**
 * タスクエンティティ
 * 茶園での作業タスクを管理
 */
@Entity
@Table(name = "tasks")
public class Task {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @NotNull(message = "タスクタイプは必須です")
  @Enumerated(EnumType.STRING)
  @Column(name = "task_type", nullable = false)
  private TaskType taskType;

  @NotNull(message = "フィールドは必須です")
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "field_id", nullable = false)
  private Field field;

  @Column(name = "assigned_worker")
  private String assignedWorker;

  @NotNull(message = "開始日は必須です")
  @Column(name = "start_date", nullable = false)
  private LocalDate startDate;

  @Column(name = "end_date")
  private LocalDate endDate;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private TaskStatus status = TaskStatus.PENDING;

  @Column(columnDefinition = "TEXT")
  private String notes;



  // デフォルトコンストラクタ
  public Task() {}

  // コンストラクタ
  public Task(TaskType taskType, Field field, String assignedWorker, 
              LocalDate startDate, LocalDate endDate, TaskStatus status, String notes) {
    this.taskType = taskType;
    this.field = field;
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

  public Field getField() {
    return field;
  }

  public void setField(Field field) {
    this.field = field;
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