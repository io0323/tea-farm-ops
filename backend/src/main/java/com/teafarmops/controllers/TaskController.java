package com.teafarmops.controllers;

import com.teafarmops.entities.Field;
import com.teafarmops.entities.Task;
import com.teafarmops.entities.TaskStatus;
import com.teafarmops.services.FieldService;
import com.teafarmops.services.TaskService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.util.List;

/**
 * タスクコントローラー
 * タスク関連のWebリクエストを処理
 */
@Controller
@RequestMapping("/tasks")
public class TaskController {

  private final TaskService taskService;
  private final FieldService fieldService;

  @Autowired
  public TaskController(TaskService taskService, FieldService fieldService) {
    this.taskService = taskService;
    this.fieldService = fieldService;
  }

  /**
   * タスク一覧ページを表示
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping
  public String listTasks(Model model) {
    model.addAttribute("tasks", taskService.getAllTasks());
    model.addAttribute("taskStatuses", TaskStatus.values());
    return "tasks/index";
  }

  /**
   * タスク作成フォームを表示
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/new")
  public String showCreateForm(Model model) {
    model.addAttribute("task", new Task());
    model.addAttribute("fields", fieldService.getAllFields());
    model.addAttribute("taskStatuses", TaskStatus.values());
    return "tasks/create";
  }

  /**
   * タスクを作成
   * @param task タスク
   * @param bindingResult バインディング結果
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping
  public String createTask(@Valid @ModelAttribute Task task, 
                          BindingResult bindingResult, 
                          RedirectAttributes redirectAttributes) {
    if (bindingResult.hasErrors()) {
      return "tasks/create";
    }

    taskService.saveTask(task);
    redirectAttributes.addFlashAttribute("success", "タスクが正常に作成されました。");
    return "redirect:/tasks";
  }

  /**
   * タスク詳細ページを表示
   * @param id タスクID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}")
  public String showTask(@PathVariable Long id, Model model) {
    Task task = taskService.getTaskById(id)
        .orElseThrow(() -> new RuntimeException("タスクが見つかりません: " + id));
    model.addAttribute("task", task);
    return "tasks/show";
  }

  /**
   * タスク編集フォームを表示
   * @param id タスクID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}/edit")
  public String showEditForm(@PathVariable Long id, Model model) {
    Task task = taskService.getTaskById(id)
        .orElseThrow(() -> new RuntimeException("タスクが見つかりません: " + id));
    model.addAttribute("task", task);
    model.addAttribute("fields", fieldService.getAllFields());
    model.addAttribute("taskStatuses", TaskStatus.values());
    return "tasks/edit";
  }

  /**
   * タスクを更新
   * @param id タスクID
   * @param task タスク
   * @param bindingResult バインディング結果
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping("/{id}")
  public String updateTask(@PathVariable Long id, 
                          @Valid @ModelAttribute Task task, 
                          BindingResult bindingResult, 
                          RedirectAttributes redirectAttributes) {
    if (bindingResult.hasErrors()) {
      return "tasks/edit";
    }

    taskService.updateTask(id, task);
    redirectAttributes.addFlashAttribute("success", "タスクが正常に更新されました。");
    return "redirect:/tasks";
  }

  /**
   * タスク削除確認ページを表示
   * @param id タスクID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}/delete")
  public String showDeleteConfirmation(@PathVariable Long id, Model model) {
    Task task = taskService.getTaskById(id)
        .orElseThrow(() -> new RuntimeException("タスクが見つかりません: " + id));
    model.addAttribute("task", task);
    return "tasks/delete";
  }

  /**
   * タスクを削除
   * @param id タスクID
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping("/{id}/delete")
  public String deleteTask(@PathVariable Long id, RedirectAttributes redirectAttributes) {
    taskService.deleteTask(id);
    redirectAttributes.addFlashAttribute("success", "タスクが正常に削除されました。");
    return "redirect:/tasks";
  }

  /**
   * タスクを検索
   * @param taskType タスクタイプ
   * @param status ステータス
   * @param assignedWorker 担当者
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/search")
  public String searchTasks(@RequestParam(required = false) String taskType,
                           @RequestParam(required = false) TaskStatus status,
                           @RequestParam(required = false) String assignedWorker,
                           Model model) {
    List<Task> tasks;
    
    if (taskType != null && !taskType.trim().isEmpty()) {
      tasks = taskService.getTasksByType(taskType);
    } else if (status != null) {
      tasks = taskService.getTasksByStatus(status);
    } else if (assignedWorker != null && !assignedWorker.trim().isEmpty()) {
      tasks = taskService.getTasksByWorker(assignedWorker);
    } else {
      tasks = taskService.getAllTasks();
    }
    
    model.addAttribute("tasks", tasks);
    model.addAttribute("taskStatuses", TaskStatus.values());
    return "tasks/index";
  }
} 