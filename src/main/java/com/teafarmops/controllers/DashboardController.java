package com.teafarmops.controllers;

import com.teafarmops.services.FieldService;
import com.teafarmops.services.TaskService;
import com.teafarmops.services.HarvestRecordService;
import com.teafarmops.services.WeatherObservationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import java.time.LocalDate;

/**
 * ダッシュボードコントローラー
 * ダッシュボード関連のWebリクエストを処理
 */
@Controller
public class DashboardController {

  private final FieldService fieldService;
  private final TaskService taskService;
  private final HarvestRecordService harvestRecordService;
  private final WeatherObservationService weatherObservationService;

  @Autowired
  public DashboardController(FieldService fieldService, 
                           TaskService taskService,
                           HarvestRecordService harvestRecordService,
                           WeatherObservationService weatherObservationService) {
    this.fieldService = fieldService;
    this.taskService = taskService;
    this.harvestRecordService = harvestRecordService;
    this.weatherObservationService = weatherObservationService;
  }

  /**
   * ダッシュボードページを表示
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/")
  public String dashboard(Model model) {
    // 基本統計情報
    model.addAttribute("totalFields", fieldService.getFieldCount());
    model.addAttribute("totalArea", fieldService.getTotalArea());
    model.addAttribute("completedTasks", taskService.getCompletedTaskCount());
    model.addAttribute("inProgressTasks", taskService.getInProgressTaskCount());
    model.addAttribute("pendingTasks", taskService.getPendingTaskCount());
    model.addAttribute("totalHarvest", harvestRecordService.getTotalHarvestQuantity());

    // 今月の統計
    LocalDate now = LocalDate.now();
    LocalDate startOfMonth = now.withDayOfMonth(1);
    LocalDate endOfMonth = now.withDayOfMonth(now.lengthOfMonth());

    model.addAttribute("monthlyHarvest", 
                      harvestRecordService.getTotalHarvestQuantityBetween(startOfMonth, endOfMonth));
    model.addAttribute("averageTemperature", 
                      weatherObservationService.getAverageTemperatureBetween(startOfMonth, endOfMonth));
    model.addAttribute("totalRainfall", 
                      weatherObservationService.getTotalRainfallBetween(startOfMonth, endOfMonth));
    model.addAttribute("averageHumidity", 
                      weatherObservationService.getAverageHumidityBetween(startOfMonth, endOfMonth));

    // 茶葉グレード別収穫量
    model.addAttribute("harvestByGrade", harvestRecordService.getTotalHarvestQuantityByGrade());

    return "dashboard";
  }
} 