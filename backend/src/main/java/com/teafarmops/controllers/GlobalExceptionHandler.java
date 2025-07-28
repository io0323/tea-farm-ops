package com.teafarmops.controllers;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * グローバル例外ハンドラー
 * アプリケーション全体の例外処理を統一
 */
@ControllerAdvice
public class GlobalExceptionHandler {

  /**
   * RuntimeExceptionの処理
   * @param ex 例外
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @ExceptionHandler(RuntimeException.class)
  public String handleRuntimeException(RuntimeException ex, RedirectAttributes redirectAttributes) {
    redirectAttributes.addFlashAttribute("error", ex.getMessage());
    return "redirect:/";
  }

  /**
   * その他の例外の処理
   * @param ex 例外
   * @param redirectAttributes リダイレクト属性
   * @return リダイレクト先
   */
  @ExceptionHandler(Exception.class)
  public String handleException(Exception ex, RedirectAttributes redirectAttributes) {
    redirectAttributes.addFlashAttribute("error", "予期しないエラーが発生しました: " + ex.getMessage());
    return "redirect:/";
  }
} 