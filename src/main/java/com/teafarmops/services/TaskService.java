package com.teafarmops.services;

import com.teafarmops.entities.Field;
import com.teafarmops.entities.Task;
import com.teafarmops.entities.Task.TaskStatus;
import com.teafarmops.repositories.FieldRepository;
import com.teafarmops.repositories.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * タスクサービス
 * タスク関連のビジネスロジックを管理
 */
@Service
@Transactional
public class TaskService {

  private final TaskRepository taskRepository;
  private final FieldRepository fieldRepository;

  @Autowired
  public TaskService(TaskRepository taskRepository, FieldRepository fieldRepository) {
    this.taskRepository = taskRepository;
    this.fieldRepository = fieldRepository;
  }

  /**
   * 全タスクを取得
   * @return タスクリスト
   */
  public List<Task> getAllTasks() {
    return taskRepository.findAll();
  }

  /**
   * IDでタスクを取得
   * @param id タスクID
   * @return タスク（オプショナル）
   */
  public Optional<Task> getTaskById(Long id) {
    return taskRepository.findById(id);
  }

  /**
   * タスクを保存
   * @param task タスク
   * @return 保存されたタスク
   */
  public Task saveTask(Task task) {
    return taskRepository.save(task);
  }

  /**
   * タスクを更新
   * @param id タスクID
   * @param taskDetails 更新するタスク詳細
   * @return 更新されたタスク
   */
  public Task updateTask(Long id, Task taskDetails) {
    Task task = taskRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("タスクが見つかりません: " + id));

    task.setTaskType(taskDetails.getTaskType());
    task.setField(taskDetails.getField());
    task.setAssignedWorker(taskDetails.getAssignedWorker());
    task.setStartDate(taskDetails.getStartDate());
    task.setEndDate(taskDetails.getEndDate());
    task.setStatus(taskDetails.getStatus());
    task.setNotes(taskDetails.getNotes());

    return taskRepository.save(task);
  }

  /**
   * タスクを削除
   * @param id タスクID
   */
  public void deleteTask(Long id) {
    Task task = taskRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("タスクが見つかりません: " + id));
    taskRepository.delete(task);
  }

  /**
   * フィールドIDでタスクを検索
   * @param fieldId フィールドID
   * @return タスクリスト
   */
  public List<Task> getTasksByFieldId(Long fieldId) {
    return taskRepository.findByFieldId(fieldId);
  }

  /**
   * タスクタイプでタスクを検索
   * @param taskType タスクタイプ
   * @return タスクリスト
   */
  public List<Task> getTasksByType(String taskType) {
    return taskRepository.findByTaskType(taskType);
  }

  /**
   * ステータスでタスクを検索
   * @param status タスクステータス
   * @return タスクリスト
   */
  public List<Task> getTasksByStatus(TaskStatus status) {
    return taskRepository.findByStatus(status);
  }

  /**
   * 担当者でタスクを検索
   * @param assignedWorker 担当者名
   * @return タスクリスト
   */
  public List<Task> getTasksByWorker(String assignedWorker) {
    return taskRepository.findByAssignedWorkerContainingIgnoreCase(assignedWorker);
  }

  /**
   * 開始日でタスクを検索
   * @param startDate 開始日
   * @return タスクリスト
   */
  public List<Task> getTasksByStartDate(LocalDate startDate) {
    return taskRepository.findByStartDate(startDate);
  }

  /**
   * 開始日範囲でタスクを検索
   * @param startDate 開始日
   * @param endDate 終了日
   * @return タスクリスト
   */
  public List<Task> getTasksByDateRange(LocalDate startDate, LocalDate endDate) {
    return taskRepository.findByStartDateBetween(startDate, endDate);
  }

  /**
   * 完了タスク数を取得
   * @return 完了タスク数
   */
  public Long getCompletedTaskCount() {
    return taskRepository.getCompletedTaskCount();
  }

  /**
   * 進行中タスク数を取得
   * @return 進行中タスク数
   */
  public Long getInProgressTaskCount() {
    return taskRepository.getInProgressTaskCount();
  }

  /**
   * 未着手タスク数を取得
   * @return 未着手タスク数
   */
  public Long getPendingTaskCount() {
    return taskRepository.getPendingTaskCount();
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