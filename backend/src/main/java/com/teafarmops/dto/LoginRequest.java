package com.teafarmops.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * ログインリクエストDTO
 */
public class LoginRequest {

  @NotBlank(message = "ユーザー名は必須です")
  private String username;

  @NotBlank(message = "パスワードは必須です")
  private String password;

  // デフォルトコンストラクタ
  public LoginRequest() {}

  // コンストラクタ
  public LoginRequest(String username, String password) {
    this.username = username;
    this.password = password;
  }

  // Getter and Setter methods
  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }
} 