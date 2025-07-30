package com.teafarmops.entities;

/**
 * 茶葉グレードの列挙型
 * 収穫された茶葉の品質グレードを定義
 */
public enum TeaGrade {
  PREMIUM("プレミアム"),
  HIGH("高級"),
  MEDIUM("中級"),
  STANDARD("標準");

  private final String displayName;

  TeaGrade(String displayName) {
    this.displayName = displayName;
  }

  public String getDisplayName() {
    return displayName;
  }
} 