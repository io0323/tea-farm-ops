package com.teafarmops.controllers;

import com.teafarmops.entities.Field;
import com.teafarmops.services.FieldService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * フィールドコントローラー
 * フィールド関連のWebリクエストを処理
 */
@Controller
@RequestMapping("/fields")
public class FieldController {

  private final FieldService fieldService;

  @Autowired
  public FieldController(FieldService fieldService) {
    this.fieldService = fieldService;
  }

  /**
   * フィールド一覧ページを表示
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping
  public String listFields(Model model) {
    model.addAttribute("fields", fieldService.getAllFields());
    return "fields/index";
  }

  /**
   * フィールド作成フォームを表示
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/new")
  public String showCreateForm(Model model) {
    model.addAttribute("field", new Field());
    return "fields/create";
  }

  /**
   * フィールドを作成
   * @param field フィールド
   * @param bindingResult バインディング結果
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping
  public String createField(@Valid @ModelAttribute Field field, 
                           BindingResult bindingResult, 
                           RedirectAttributes redirectAttributes) {
    if (bindingResult.hasErrors()) {
      return "fields/create";
    }

    fieldService.saveField(field);
    redirectAttributes.addFlashAttribute("success", "フィールドが正常に作成されました。");
    return "redirect:/fields";
  }

  /**
   * フィールド詳細ページを表示
   * @param id フィールドID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}")
  public String showField(@PathVariable Long id, Model model) {
    Field field = fieldService.getFieldById(id)
        .orElseThrow(() -> new RuntimeException("フィールドが見つかりません: " + id));
    model.addAttribute("field", field);
    return "fields/show";
  }

  /**
   * フィールド編集フォームを表示
   * @param id フィールドID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}/edit")
  public String showEditForm(@PathVariable Long id, Model model) {
    Field field = fieldService.getFieldById(id)
        .orElseThrow(() -> new RuntimeException("フィールドが見つかりません: " + id));
    model.addAttribute("field", field);
    return "fields/edit";
  }

  /**
   * フィールドを更新
   * @param id フィールドID
   * @param field フィールド
   * @param bindingResult バインディング結果
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping("/{id}")
  public String updateField(@PathVariable Long id, 
                           @Valid @ModelAttribute Field field, 
                           BindingResult bindingResult, 
                           RedirectAttributes redirectAttributes) {
    if (bindingResult.hasErrors()) {
      return "fields/edit";
    }

    fieldService.updateField(id, field);
    redirectAttributes.addFlashAttribute("success", "フィールドが正常に更新されました。");
    return "redirect:/fields";
  }

  /**
   * フィールド削除確認ページを表示
   * @param id フィールドID
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/{id}/delete")
  public String showDeleteConfirmation(@PathVariable Long id, Model model) {
    Field field = fieldService.getFieldById(id)
        .orElseThrow(() -> new RuntimeException("フィールドが見つかりません: " + id));
    model.addAttribute("field", field);
    return "fields/delete";
  }

  /**
   * フィールドを削除
   * @param id フィールドID
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @PostMapping("/{id}/delete")
  public String deleteField(@PathVariable Long id, RedirectAttributes redirectAttributes) {
    fieldService.deleteField(id);
    redirectAttributes.addFlashAttribute("success", "フィールドが正常に削除されました。");
    return "redirect:/fields";
  }

  /**
   * フィールドを検索
   * @param name フィールド名
   * @param location 場所
   * @param soilType 土壌タイプ
   * @param model モデル
   * @return ビュー名
   */
  @GetMapping("/search")
  public String searchFields(@RequestParam(required = false) String name,
                            @RequestParam(required = false) String location,
                            @RequestParam(required = false) String soilType,
                            Model model) {
    if (name != null && !name.trim().isEmpty()) {
      model.addAttribute("fields", fieldService.searchFieldsByName(name));
    } else if (location != null && !location.trim().isEmpty()) {
      model.addAttribute("fields", fieldService.searchFieldsByLocation(location));
    } else if (soilType != null && !soilType.trim().isEmpty()) {
      model.addAttribute("fields", fieldService.searchFieldsBySoilType(soilType));
    } else {
      model.addAttribute("fields", fieldService.getAllFields());
    }
    return "fields/index";
  }
} 