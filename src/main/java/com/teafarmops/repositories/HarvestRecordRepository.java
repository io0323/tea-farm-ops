package com.teafarmops.repositories;

import com.teafarmops.entities.HarvestRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

/**
 * 収穫記録リポジトリ
 * 収穫記録エンティティのデータアクセス層
 */
@Repository
public interface HarvestRecordRepository extends JpaRepository<HarvestRecord, Long> {

  /**
   * フィールドIDで収穫記録を検索
   * @param fieldId フィールドID
   * @return 収穫記録リスト
   */
  List<HarvestRecord> findByFieldId(Long fieldId);

  /**
   * 収穫日で収穫記録を検索
   * @param harvestDate 収穫日
   * @return 収穫記録リスト
   */
  List<HarvestRecord> findByHarvestDate(LocalDate harvestDate);

  /**
   * 収穫日範囲で収穫記録を検索
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 収穫記録リスト
   */
  List<HarvestRecord> findByHarvestDateBetween(LocalDate startDate, LocalDate endDate);

  /**
   * 茶葉グレードで収穫記録を検索
   * @param teaGrade 茶葉グレード
   * @return 収穫記録リスト
   */
  List<HarvestRecord> findByTeaGrade(String teaGrade);

  /**
   * 総収穫量を取得
   * @return 総収穫量（kg）
   */
  @Query("SELECT SUM(h.quantityKg) FROM HarvestRecord h")
  Double getTotalHarvestQuantity();

  /**
   * 指定期間の総収穫量を取得
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 総収穫量（kg）
   */
  @Query("SELECT SUM(h.quantityKg) FROM HarvestRecord h WHERE h.harvestDate BETWEEN ?1 AND ?2")
  Double getTotalHarvestQuantityBetween(LocalDate startDate, LocalDate endDate);

  /**
   * 茶葉グレード別の総収穫量を取得
   * @return 茶葉グレード別の総収穫量
   */
  @Query("SELECT h.teaGrade, SUM(h.quantityKg) FROM HarvestRecord h GROUP BY h.teaGrade")
  List<Object[]> getTotalHarvestQuantityByGrade();
} 