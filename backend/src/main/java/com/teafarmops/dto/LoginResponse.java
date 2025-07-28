package com.teafarmops.dto;

/**
 * ログインレスポンスDTO
 */
public class LoginResponse {

  private String token;
  private UserDto user;

  // デフォルトコンストラクタ
  public LoginResponse() {}

  // コンストラクタ
  public LoginResponse(String token, UserDto user) {
    this.token = token;
    this.user = user;
  }

  // Getter and Setter methods
  public String getToken() {
    return token;
  }

  public void setToken(String token) {
    this.token = token;
  }

  public UserDto getUser() {
    return user;
  }

  public void setUser(UserDto user) {
    this.user = user;
  }
} 