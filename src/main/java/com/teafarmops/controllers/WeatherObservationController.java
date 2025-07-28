package com.teafarmops.controllers;

import com.teafarmops.entities.WeatherObservation;
import com.teafarmops.services.FieldService;
import com.teafarmops.services.WeatherObservationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * 天候観測コントローラー
 * 天候観測関連のWebリクエストを処理
 */
@Controller
@RequestMapping("/weather-observations")
public class WeatherObservationController {

  private final WeatherObservationService weatherObservationService;
  private final FieldService fieldService;

  @Autowired
  public WeatherObservationController(WeatherObservationService weatherObservationService, 
                                    FieldService fieldService) {
    this.weatherObservationService = weatherObservationService;
    this.fieldService = fieldService;
  }

  /**
   * 天候観測一覧ページを表示
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping
  public String listWeatherObservations(Model model) {
    model.addAttribute("weatherObservations", weatherObservationService.getAllWeatherObservations());
    return "weather-observations/index";
  }

  /**
   * 天候観測作成フォームを表示
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/new")
  public String showCreateForm(Model model) {
    model.addAttribute("weatherObservation", new WeatherObservation());
    model.addAttribute("fields", fieldService.getAllFields());
    return "weather-observations/create";
  }

  /**
   * 天候観測を作成
   * @param weatherObservation 天候観測
   * @param bindingResult バインディング結果
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping
  public String createWeatherObservation(@Valid @ModelAttribute WeatherObservation weatherObservation, 
                                       BindingResult bindingResult, 
                                       RedirectAttributes redirectAttributes) {
    if (bindingResult.hasErrors()) {
      return "weather-observations/create";
    }

    weatherObservationService.saveWeatherObservation(weatherObservation);
    redirectAttributes.addFlashAttribute("success", "天候観測が正常に作成されました。");
    return "redirect:/weather-observations";
  }

  /**
   * 天候観測詳細ページを表示
   * @param id 天候観測ID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}")
  public String showWeatherObservation(@PathVariable Long id, Model model) {
    WeatherObservation weatherObservation = weatherObservationService.getWeatherObservationById(id)
        .orElseThrow(() -> new RuntimeException("天候観測が見つかりません: " + id));
    model.addAttribute("weatherObservation", weatherObservation);
    return "weather-observations/show";
  }

  /**
   * 天候観測編集フォームを表示
   * @param id 天候観測ID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}/edit")
  public String showEditForm(@PathVariable Long id, Model model) {
    WeatherObservation weatherObservation = weatherObservationService.getWeatherObservationById(id)
        .orElseThrow(() -> new RuntimeException("天候観測が見つかりません: " + id));
    model.addAttribute("weatherObservation", weatherObservation);
    model.addAttribute("fields", fieldService.getAllFields());
    return "weather-observations/edit";
  }

  /**
   * 天候観測を更新
   * @param id 天候観測ID
   * @param weatherObservation 天候観測
   * @param bindingResult バインディング結果
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping("/{id}")
  public String updateWeatherObservation(@PathVariable Long id, 
                                       @Valid @ModelAttribute WeatherObservation weatherObservation, 
                                       BindingResult bindingResult, 
                                       RedirectAttributes redirectAttributes) {
    if (bindingResult.hasErrors()) {
      return "weather-observations/edit";
    }

    weatherObservationService.updateWeatherObservation(id, weatherObservation);
    redirectAttributes.addFlashAttribute("success", "天候観測が正常に更新されました。");
    return "redirect:/weather-observations";
  }

  /**
   * 天候観測削除確認ページを表示
   * @param id 天候観測ID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}/delete")
  public String showDeleteConfirmation(@PathVariable Long id, Model model) {
    WeatherObservation weatherObservation = weatherObservationService.getWeatherObservationById(id)
        .orElseThrow(() -> new RuntimeException("天候観測が見つかりません: " + id));
    model.addAttribute("weatherObservation", weatherObservation);
    return "weather-observations/delete";
  }

  /**
   * 天候観測を削除
   * @param id 天候観測ID
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping("/{id}/delete")
  public String deleteWeatherObservation(@PathVariable Long id, RedirectAttributes redirectAttributes) {
    weatherObservationService.deleteWeatherObservation(id);
    redirectAttributes.addFlashAttribute("success", "天候観測が正常に削除されました。");
    return "redirect:/weather-observations";
  }

  /**
   * 天候観測を検索
   * @param pestsSeen 害虫名
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/search")
  public String searchWeatherObservations(@RequestParam(required = false) String pestsSeen,
                                        Model model) {
    if (pestsSeen != null && !pestsSeen.trim().isEmpty()) {
      model.addAttribute("weatherObservations", 
                        weatherObservationService.getWeatherObservationsByPests(pestsSeen));
    } else {
      model.addAttribute("weatherObservations", 
                        weatherObservationService.getAllWeatherObservations());
    }
    return "weather-observations/index";
  }
} 