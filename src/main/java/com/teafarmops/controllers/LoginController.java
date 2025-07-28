package com.teafarmops.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * ログインコントローラー
 * ログイン関連のWebリクエストを処理
 */
@Controller
public class LoginController {

  /**
   * ログインページを表示
   * @return ビュー名
   */
  @GetMapping("/login")
  public String login() {
    return "login";
  }
} 