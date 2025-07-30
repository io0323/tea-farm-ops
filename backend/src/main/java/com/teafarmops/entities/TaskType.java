package com.teafarmops.entities;

/**
 * タスクタイプの列挙型
 * 茶園での作業タイプを定義
 */
public enum TaskType {
  PLANTING("植栽"),
  FERTILIZING("施肥"),
  PEST_CONTROL("害虫防除"),
  HARVESTING("収穫"),
  PRUNING("剪定"),
  IRRIGATION("灌水"),
  OTHER("その他");

  private final String displayName;

  TaskType(String displayName) {
    this.displayName = displayName;
  }

  public String getDisplayName() {
    return displayName;
  }
} 