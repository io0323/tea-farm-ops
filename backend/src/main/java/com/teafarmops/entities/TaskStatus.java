package com.teafarmops.entities;

/**
 * タスクステータスの列挙型
 * タスクの進行状況を定義
 */
public enum TaskStatus {
  PENDING("未着手"),
  IN_PROGRESS("進行中"),
  COMPLETED("完了"),
  CANCELLED("キャンセル");

  private final String displayName;

  TaskStatus(String displayName) {
    this.displayName = displayName;
  }

  public String getDisplayName() {
    return displayName;
  }
} 