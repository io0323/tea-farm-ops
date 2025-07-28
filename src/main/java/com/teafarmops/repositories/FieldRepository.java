package com.teafarmops.repositories;

import com.teafarmops.entities.Field;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * フィールドリポジトリ
 * フィールドエンティティのデータアクセス層
 */
@Repository
public interface FieldRepository extends JpaRepository<Field, Long> {

  /**
   * 名前でフィールドを検索
   * @param name フィールド名
   * @return フィールドリスト
   */
  List<Field> findByNameContainingIgnoreCase(String name);

  /**
   * 場所でフィールドを検索
   * @param location 場所
   * @return フィールドリスト
   */
  List<Field> findByLocationContainingIgnoreCase(String location);

  /**
   * 土壌タイプでフィールドを検索
   * @param soilType 土壌タイプ
   * @return フィールドリスト
   */
  List<Field> findBySoilType(String soilType);

  /**
   * 総面積を取得
   * @return 総面積（ヘクタール）
   */
  @Query("SELECT SUM(f.areaSize) FROM Field f")
  Double getTotalArea();

  /**
   * フィールド数を取得
   * @return フィールド数
   */
  @Query("SELECT COUNT(f) FROM Field f")
  Long getFieldCount();
} 