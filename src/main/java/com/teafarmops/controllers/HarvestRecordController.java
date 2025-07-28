package com.teafarmops.controllers;

import com.teafarmops.entities.HarvestRecord;
import com.teafarmops.services.FieldService;
import com.teafarmops.services.HarvestRecordService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * 収穫記録コントローラー
 * 収穫記録関連のWebリクエストを処理
 */
@Controller
@RequestMapping("/harvest-records")
public class HarvestRecordController {

  private final HarvestRecordService harvestRecordService;
  private final FieldService fieldService;

  @Autowired
  public HarvestRecordController(HarvestRecordService harvestRecordService, 
                               FieldService fieldService) {
    this.harvestRecordService = harvestRecordService;
    this.fieldService = fieldService;
  }

  /**
   * 収穫記録一覧ページを表示
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping
  public String listHarvestRecords(Model model) {
    model.addAttribute("harvestRecords", harvestRecordService.getAllHarvestRecords());
    return "harvest-records/index";
  }

  /**
   * 収穫記録作成フォームを表示
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/new")
  public String showCreateForm(Model model) {
    model.addAttribute("harvestRecord", new HarvestRecord());
    model.addAttribute("fields", fieldService.getAllFields());
    return "harvest-records/create";
  }

  /**
   * 収穫記録を作成
   * @param harvestRecord 収穫記録
   * @param bindingResult バインディング結果
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping
  public String createHarvestRecord(@Valid @ModelAttribute HarvestRecord harvestRecord, 
                                   BindingResult bindingResult, 
                                   RedirectAttributes redirectAttributes) {
    if (bindingResult.hasErrors()) {
      return "harvest-records/create";
    }

    harvestRecordService.saveHarvestRecord(harvestRecord);
    redirectAttributes.addFlashAttribute("success", "収穫記録が正常に作成されました。");
    return "redirect:/harvest-records";
  }

  /**
   * 収穫記録詳細ページを表示
   * @param id 収穫記録ID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}")
  public String showHarvestRecord(@PathVariable Long id, Model model) {
    HarvestRecord harvestRecord = harvestRecordService.getHarvestRecordById(id)
        .orElseThrow(() -> new RuntimeException("収穫記録が見つかりません: " + id));
    model.addAttribute("harvestRecord", harvestRecord);
    return "harvest-records/show";
  }

  /**
   * 収穫記録編集フォームを表示
   * @param id 収穫記録ID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}/edit")
  public String showEditForm(@PathVariable Long id, Model model) {
    HarvestRecord harvestRecord = harvestRecordService.getHarvestRecordById(id)
        .orElseThrow(() -> new RuntimeException("収穫記録が見つかりません: " + id));
    model.addAttribute("harvestRecord", harvestRecord);
    model.addAttribute("fields", fieldService.getAllFields());
    return "harvest-records/edit";
  }

  /**
   * 収穫記録を更新
   * @param id 収穫記録ID
   * @param harvestRecord 収穫記録
   * @param bindingResult バインディング結果
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping("/{id}")
  public String updateHarvestRecord(@PathVariable Long id, 
                                   @Valid @ModelAttribute HarvestRecord harvestRecord, 
                                   BindingResult bindingResult, 
                                   RedirectAttributes redirectAttributes) {
    if (bindingResult.hasErrors()) {
      return "harvest-records/edit";
    }

    harvestRecordService.updateHarvestRecord(id, harvestRecord);
    redirectAttributes.addFlashAttribute("success", "収穫記録が正常に更新されました。");
    return "redirect:/harvest-records";
  }

  /**
   * 収穫記録削除確認ページを表示
   * @param id 収穫記録ID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}/delete")
  public String showDeleteConfirmation(@PathVariable Long id, Model model) {
    HarvestRecord harvestRecord = harvestRecordService.getHarvestRecordById(id)
        .orElseThrow(() -> new RuntimeException("収穫記録が見つかりません: " + id));
    model.addAttribute("harvestRecord", harvestRecord);
    return "harvest-records/delete";
  }

  /**
   * 収穫記録を削除
   * @param id 収穫記録ID
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping("/{id}/delete")
  public String deleteHarvestRecord(@PathVariable Long id, RedirectAttributes redirectAttributes) {
    harvestRecordService.deleteHarvestRecord(id);
    redirectAttributes.addFlashAttribute("success", "収穫記録が正常に削除されました。");
    return "redirect:/harvest-records";
  }

  /**
   * 収穫記録を検索
   * @param teaGrade 茶葉グレード
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/search")
  public String searchHarvestRecords(@RequestParam(required = false) String teaGrade,
                                    Model model) {
    if (teaGrade != null && !teaGrade.trim().isEmpty()) {
      model.addAttribute("harvestRecords", harvestRecordService.getHarvestRecordsByGrade(teaGrade));
    } else {
      model.addAttribute("harvestRecords", harvestRecordService.getAllHarvestRecords());
    }
    return "harvest-records/index";
  }
} 