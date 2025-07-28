package com.teafarmops.utils;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * 日付ユーティリティクラス
 * 日付関連の共通処理を提供
 */
public class DateUtils {

  private static final DateTimeFormatter DISPLAY_FORMATTER = DateTimeFormatter.ofPattern("yyyy/MM/dd");
  private static final DateTimeFormatter INPUT_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

  /**
   * 表示用の日付フォーマット
   * @param date 日付
   * @return フォーマットされた日付文字列
   */
  public static String formatForDisplay(LocalDate date) {
    if (date == null) {
      return "-";
    }
    return date.format(DISPLAY_FORMATTER);
  }

  /**
   * 入力用の日付フォーマット
   * @param date 日付
   * @return フォーマットされた日付文字列
   */
  public static String formatForInput(LocalDate date) {
    if (date == null) {
      return "";
    }
    return date.format(INPUT_FORMATTER);
  }

  /**
   * 文字列からLocalDateに変換
   * @param dateString 日付文字列
   * @return LocalDate
   */
  public static LocalDate parseDate(String dateString) {
    if (dateString == null || dateString.trim().isEmpty()) {
      return null;
    }
    return LocalDate.parse(dateString, INPUT_FORMATTER);
  }
} 