package com.teafarmops.controllers;

import com.teafarmops.dto.HarvestRecordDto;
import com.teafarmops.entities.HarvestRecord;
import com.teafarmops.services.HarvestRecordService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 収穫記録REST APIコントローラー
 * 収穫記録関連のREST APIエンドポイント
 */
@RestController
@RequestMapping("/api/harvest-records")
@CrossOrigin(origins = "*")
public class HarvestRecordApiController {

  private final HarvestRecordService harvestRecordService;

  @Autowired
  public HarvestRecordApiController(HarvestRecordService harvestRecordService) {
    this.harvestRecordService = harvestRecordService;
  }

  /**
   * 収穫記録一覧を取得
   * @param teaGrade 茶葉グレード（検索用）
   * @param startDate 開始日（検索用）
   * @param endDate 終了日（検索用）
   * @param fieldId フィールドID（検索用）
   * @return 収穫記録一覧
   */
  @GetMapping
  public ResponseEntity<List<HarvestRecordDto>> getHarvestRecords(
      @RequestParam(required = false) String teaGrade,
      @RequestParam(required = false) String startDate,
      @RequestParam(required = false) String endDate,
      @RequestParam(required = false) Long fieldId) {
    
    List<HarvestRecord> records = harvestRecordService.getAllHarvestRecords();
    
    List<HarvestRecordDto> recordDtos = records.stream()
        .map(this::convertToDto)
        .collect(Collectors.toList());
    
    return ResponseEntity.ok(recordDtos);
  }

  /**
   * 収穫記録詳細を取得
   * @param id 収穫記録ID
   * @return 収穫記録詳細
   */
  @GetMapping("/{id}")
  public ResponseEntity<HarvestRecordDto> getHarvestRecord(@PathVariable Long id) {
    return harvestRecordService.getHarvestRecordById(id)
        .map(this::convertToDto)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
  }

  /**
   * 収穫記録を作成
   * @param recordDto 収穫記録情報
   * @return 作成された収穫記録
   */
  @PostMapping
  public ResponseEntity<HarvestRecordDto> createHarvestRecord(@Valid @RequestBody HarvestRecordDto recordDto) {
    HarvestRecord record = convertToEntity(recordDto);
    HarvestRecord savedRecord = harvestRecordService.saveHarvestRecord(record);
    return ResponseEntity.ok(convertToDto(savedRecord));
  }

  /**
   * 収穫記録を更新
   * @param id 収穫記録ID
   * @param recordDto 更新する収穫記録情報
   * @return 更新された収穫記録
   */
  @PutMapping("/{id}")
  public ResponseEntity<HarvestRecordDto> updateHarvestRecord(@PathVariable Long id, @Valid @RequestBody HarvestRecordDto recordDto) {
    return harvestRecordService.getHarvestRecordById(id)
        .map(existingRecord -> {
          recordDto.setId(id);
          HarvestRecord updatedRecord = convertToEntity(recordDto);
          HarvestRecord savedRecord = harvestRecordService.saveHarvestRecord(updatedRecord);
          return ResponseEntity.ok(convertToDto(savedRecord));
        })
        .orElse(ResponseEntity.notFound().build());
  }

  /**
   * 収穫記録を削除
   * @param id 収穫記録ID
   * @return 削除結果
   */
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteHarvestRecord(@PathVariable Long id) {
    if (harvestRecordService.getHarvestRecordById(id).isPresent()) {
      harvestRecordService.deleteHarvestRecord(id);
      return ResponseEntity.noContent().build();
    } else {
      return ResponseEntity.notFound().build();
    }
  }

  /**
   * HarvestRecordDtoをHarvestRecordエンティティに変換
   * @param recordDto DTO
   * @return エンティティ
   */
  private HarvestRecord convertToEntity(HarvestRecordDto recordDto) {
    HarvestRecord record = new HarvestRecord();
    record.setId(recordDto.getId());
    record.setHarvestDate(recordDto.getHarvestDate());
    record.setQuantityKg(recordDto.getQuantityKg());
    record.setTeaGrade(recordDto.getTeaGrade());
    record.setNotes(recordDto.getNotes());
    
    // フィールドの設定（簡易版）
    if (recordDto.getFieldId() != null) {
      // 実際の実装ではFieldServiceから取得
    }
    
    return record;
  }

  /**
   * HarvestRecordエンティティをHarvestRecordDtoに変換
   * @param record エンティティ
   * @return DTO
   */
  private HarvestRecordDto convertToDto(HarvestRecord record) {
    HarvestRecordDto dto = new HarvestRecordDto();
    dto.setId(record.getId());
    dto.setHarvestDate(record.getHarvestDate());
    dto.setQuantityKg(record.getQuantityKg());
    dto.setTeaGrade(record.getTeaGrade());
    dto.setNotes(record.getNotes());
    
    if (record.getField() != null) {
      dto.setFieldId(record.getField().getId());
      dto.setFieldName(record.getField().getName());
    }
    
    return dto;
  }
} 