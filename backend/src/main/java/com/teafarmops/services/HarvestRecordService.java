package com.teafarmops.services;

import com.teafarmops.entities.Field;
import com.teafarmops.entities.HarvestRecord;
import com.teafarmops.repositories.FieldRepository;
import com.teafarmops.repositories.HarvestRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * 収穫記録サービス
 * 収穫記録関連のビジネスロジックを管理
 */
@Service
@Transactional
public class HarvestRecordService {

  private final HarvestRecordRepository harvestRecordRepository;
  private final FieldRepository fieldRepository;

  @Autowired
  public HarvestRecordService(HarvestRecordRepository harvestRecordRepository, 
                             FieldRepository fieldRepository) {
    this.harvestRecordRepository = harvestRecordRepository;
    this.fieldRepository = fieldRepository;
  }

  /**
   * 全収穫記録を取得
   * @return 収穫記録リスト
   */
  public List<HarvestRecord> getAllHarvestRecords() {
    return harvestRecordRepository.findAll();
  }

  /**
   * IDで収穫記録を取得
   * @param id 収穫記録ID
   * @return 収穫記録（オプショナル）
   */
  public Optional<HarvestRecord> getHarvestRecordById(Long id) {
    return harvestRecordRepository.findById(id);
  }

  /**
   * 収穫記録を保存
   * @param harvestRecord 収穫記録
   * @return 保存された収穫記録
   */
  public HarvestRecord saveHarvestRecord(HarvestRecord harvestRecord) {
    return harvestRecordRepository.save(harvestRecord);
  }

  /**
   * 収穫記録を更新
   * @param id 収穫記録ID
   * @param harvestRecordDetails 更新する収穫記録詳細
   * @return 更新された収穫記録
   */
  public HarvestRecord updateHarvestRecord(Long id, HarvestRecord harvestRecordDetails) {
    HarvestRecord harvestRecord = harvestRecordRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("収穫記録が見つかりません: " + id));

    harvestRecord.setField(harvestRecordDetails.getField());
    harvestRecord.setHarvestDate(harvestRecordDetails.getHarvestDate());
    harvestRecord.setQuantityKg(harvestRecordDetails.getQuantityKg());
    harvestRecord.setTeaGrade(harvestRecordDetails.getTeaGrade());
    harvestRecord.setNotes(harvestRecordDetails.getNotes());

    return harvestRecordRepository.save(harvestRecord);
  }

  /**
   * 収穫記録を削除
   * @param id 収穫記録ID
   */
  public void deleteHarvestRecord(Long id) {
    HarvestRecord harvestRecord = harvestRecordRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("収穫記録が見つかりません: " + id));
    harvestRecordRepository.delete(harvestRecord);
  }

  /**
   * フィールドIDで収穫記録を検索
   * @param fieldId フィールドID
   * @return 収穫記録リスト
   */
  public List<HarvestRecord> getHarvestRecordsByFieldId(Long fieldId) {
    return harvestRecordRepository.findByFieldId(fieldId);
  }

  /**
   * 収穫日で収穫記録を検索
   * @param harvestDate 収穫日
   * @return 収穫記録リスト
   */
  public List<HarvestRecord> getHarvestRecordsByDate(LocalDate harvestDate) {
    return harvestRecordRepository.findByHarvestDate(harvestDate);
  }

  /**
   * 収穫日範囲で収穫記録を検索
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 収穫記録リスト
   */
  public List<HarvestRecord> getHarvestRecordsByDateRange(LocalDate startDate, LocalDate endDate) {
    return harvestRecordRepository.findByHarvestDateBetween(startDate, endDate);
  }

  /**
   * 茶葉グレードで収穫記録を検索
   * @param teaGrade 茶葉グレード
   * @return 収穫記録リスト
   */
  public List<HarvestRecord> getHarvestRecordsByGrade(String teaGrade) {
    return harvestRecordRepository.findByTeaGrade(teaGrade);
  }

  /**
   * 総収穫量を取得
   * @return 総収穫量（kg）
   */
  public Double getTotalHarvestQuantity() {
    return harvestRecordRepository.getTotalHarvestQuantity();
  }

  /**
   * 指定期間の総収穫量を取得
   * @param startDate 開始日
   * @param endDate 終了日
   * @return 総収穫量（kg）
   */
  public Double getTotalHarvestQuantityBetween(LocalDate startDate, LocalDate endDate) {
    return harvestRecordRepository.getTotalHarvestQuantityBetween(startDate, endDate);
  }

  /**
   * 茶葉グレード別の総収穫量を取得
   * @return 茶葉グレード別の総収穫量
   */
  public List<Object[]> getTotalHarvestQuantityByGrade() {
    return harvestRecordRepository.getTotalHarvestQuantityByGrade();
  }

  /**
   * フィールドIDでフィールドを取得
   * @param fieldId フィールドID
   * @return フィールド（オプショナル）
   */
  public Optional<Field> getFieldById(Long fieldId) {
    return fieldRepository.findById(fieldId);
  }
} 