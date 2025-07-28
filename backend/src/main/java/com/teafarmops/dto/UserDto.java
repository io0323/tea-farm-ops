package com.teafarmops.dto;

/**
 * ユーザーDTO
 */
public class UserDto {

  private Long id;
  private String username;
  private String role;
  private String email;

  // デフォルトコンストラクタ
  public UserDto() {}

  // コンストラクタ
  public UserDto(Long id, String username, String role, String email) {
    this.id = id;
    this.username = username;
    this.role = role;
    this.email = email;
  }

  // Getter and Setter methods
  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getRole() {
    return role;
  }

  public void setRole(String role) {
    this.role = role;
  }

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }
} 