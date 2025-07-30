package com.teafarmops.repositories;

import com.teafarmops.entities.Task;
import com.teafarmops.entities.TaskStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

/**
 * タスクリポジトリ
 * タスクエンティティのデータアクセス層
 */
@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {

  /**
   * フィールドIDでタスクを検索
   * @param fieldId フィールドID
   * @return タスクリスト
   */
  List<Task> findByFieldId(Long fieldId);

  /**
   * タスクタイプでタスクを検索
   * @param taskType タスクタイプ
   * @return タスクリスト
   */
  List<Task> findByTaskType(String taskType);

  /**
   * ステータスでタスクを検索
   * @param status タスクステータス
   * @return タスクリスト
   */
  List<Task> findByStatus(TaskStatus status);

  /**
   * 担当者でタスクを検索
   * @param assignedWorker 担当者名
   * @return タスクリスト
   */
  List<Task> findByAssignedWorkerContainingIgnoreCase(String assignedWorker);

  /**
   * 開始日でタスクを検索
   * @param startDate 開始日
   * @return タスクリスト
   */
  List<Task> findByStartDate(LocalDate startDate);

  /**
   * 開始日範囲でタスクを検索
   * @param startDate 開始日
   * @param endDate 終了日
   * @return タスクリスト
   */
  List<Task> findByStartDateBetween(LocalDate startDate, LocalDate endDate);

  /**
   * 完了タスク数を取得
   * @return 完了タスク数
   */
  @Query("SELECT COUNT(t) FROM Task t WHERE t.status = 'COMPLETED'")
  Long getCompletedTaskCount();

  /**
   * 進行中タスク数を取得
   * @return 進行中タスク数
   */
  @Query("SELECT COUNT(t) FROM Task t WHERE t.status = 'IN_PROGRESS'")
  Long getInProgressTaskCount();

  /**
   * 未着手タスク数を取得
   * @return 未着手タスク数
   */
  @Query("SELECT COUNT(t) FROM Task t WHERE t.status = 'PENDING'")
  Long getPendingTaskCount();
} 