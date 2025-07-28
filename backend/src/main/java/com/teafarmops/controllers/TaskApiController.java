package com.teafarmops.controllers;

import com.teafarmops.dto.TaskDto;
import com.teafarmops.entities.Task;
import com.teafarmops.services.TaskService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * タスクREST APIコントローラー
 * タスク関連のREST APIエンドポイント
 */
@RestController
@RequestMapping("/api/tasks")
@CrossOrigin(origins = "*")
public class TaskApiController {

  private final TaskService taskService;

  @Autowired
  public TaskApiController(TaskService taskService) {
    this.taskService = taskService;
  }

  /**
   * タスク一覧を取得
   * @param taskType タスクタイプ（検索用）
   * @param status ステータス（検索用）
   * @param assignedWorker 担当者（検索用）
   * @return タスク一覧
   */
  @GetMapping
  public ResponseEntity<List<TaskDto>> getTasks(
      @RequestParam(required = false) String taskType,
      @RequestParam(required = false) String status,
      @RequestParam(required = false) String assignedWorker) {
    
    List<Task> tasks = taskService.getAllTasks();
    
    List<TaskDto> taskDtos = tasks.stream()
        .map(this::convertToDto)
        .collect(Collectors.toList());
    
    return ResponseEntity.ok(taskDtos);
  }

  /**
   * タスク詳細を取得
   * @param id タスクID
   * @return タスク詳細
   */
  @GetMapping("/{id}")
  public ResponseEntity<TaskDto> getTask(@PathVariable Long id) {
    return taskService.getTaskById(id)
        .map(this::convertToDto)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
  }

  /**
   * タスクを作成
   * @param taskDto タスク情報
   * @return 作成されたタスク
   */
  @PostMapping
  public ResponseEntity<TaskDto> createTask(@Valid @RequestBody TaskDto taskDto) {
    Task task = convertToEntity(taskDto);
    Task savedTask = taskService.saveTask(task);
    return ResponseEntity.ok(convertToDto(savedTask));
  }

  /**
   * タスクを更新
   * @param id タスクID
   * @param taskDto 更新するタスク情報
   * @return 更新されたタスク
   */
  @PutMapping("/{id}")
  public ResponseEntity<TaskDto> updateTask(@PathVariable Long id, @Valid @RequestBody TaskDto taskDto) {
    return taskService.getTaskById(id)
        .map(existingTask -> {
          taskDto.setId(id);
          Task updatedTask = convertToEntity(taskDto);
          Task savedTask = taskService.saveTask(updatedTask);
          return ResponseEntity.ok(convertToDto(savedTask));
        })
        .orElse(ResponseEntity.notFound().build());
  }

  /**
   * タスクを削除
   * @param id タスクID
   * @return 削除結果
   */
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
    if (taskService.getTaskById(id).isPresent()) {
      taskService.deleteTask(id);
      return ResponseEntity.noContent().build();
    } else {
      return ResponseEntity.notFound().build();
    }
  }

  /**
   * TaskDtoをTaskエンティティに変換
   * @param taskDto DTO
   * @return エンティティ
   */
  private Task convertToEntity(TaskDto taskDto) {
    Task task = new Task();
    task.setId(taskDto.getId());
    task.setTaskType(taskDto.getTaskType());
    task.setAssignedWorker(taskDto.getAssignedWorker());
    task.setStartDate(taskDto.getStartDate());
    task.setEndDate(taskDto.getEndDate());
    task.setStatus(taskDto.getStatus());
    task.setNotes(taskDto.getNotes());
    
    // フィールドの設定（簡易版）
    if (taskDto.getFieldId() != null) {
      // 実際の実装ではFieldServiceから取得
    }
    
    return task;
  }

  /**
   * TaskエンティティをTaskDtoに変換
   * @param task エンティティ
   * @return DTO
   */
  private TaskDto convertToDto(Task task) {
    TaskDto dto = new TaskDto();
    dto.setId(task.getId());
    dto.setTaskType(task.getTaskType());
    dto.setAssignedWorker(task.getAssignedWorker());
    dto.setStartDate(task.getStartDate());
    dto.setEndDate(task.getEndDate());
    dto.setStatus(task.getStatus());
    dto.setNotes(task.getNotes());
    
    if (task.getField() != null) {
      dto.setFieldId(task.getField().getId());
      dto.setFieldName(task.getField().getName());
    }
    
    return dto;
  }
} 