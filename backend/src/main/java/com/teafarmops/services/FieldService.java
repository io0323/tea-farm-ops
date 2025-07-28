package com.teafarmops.services;

import com.teafarmops.entities.Field;
import com.teafarmops.repositories.FieldRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

/**
 * フィールドサービス
 * フィールド関連のビジネスロジックを管理
 */
@Service
@Transactional
public class FieldService {

  private final FieldRepository fieldRepository;

  @Autowired
  public FieldService(FieldRepository fieldRepository) {
    this.fieldRepository = fieldRepository;
  }

  /**
   * 全フィールドを取得
   * @return フィールドリスト
   */
  public List<Field> getAllFields() {
    return fieldRepository.findAll();
  }

  /**
   * IDでフィールドを取得
   * @param id フィールドID
   * @return フィールド（オプショナル）
   */
  public Optional<Field> getFieldById(Long id) {
    return fieldRepository.findById(id);
  }

  /**
   * フィールドを保存
   * @param field フィールド
   * @return 保存されたフィールド
   */
  public Field saveField(Field field) {
    return fieldRepository.save(field);
  }

  /**
   * フィールドを更新
   * @param id フィールドID
   * @param fieldDetails 更新するフィールド詳細
   * @return 更新されたフィールド
   */
  public Field updateField(Long id, Field fieldDetails) {
    Field field = fieldRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("フィールドが見つかりません: " + id));

    field.setName(fieldDetails.getName());
    field.setLocation(fieldDetails.getLocation());
    field.setAreaSize(fieldDetails.getAreaSize());
    field.setSoilType(fieldDetails.getSoilType());
    field.setNotes(fieldDetails.getNotes());

    return fieldRepository.save(field);
  }

  /**
   * フィールドを削除
   * @param id フィールドID
   */
  public void deleteField(Long id) {
    Field field = fieldRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("フィールドが見つかりません: " + id));
    fieldRepository.delete(field);
  }

  /**
   * 名前でフィールドを検索
   * @param name フィールド名
   * @return フィールドリスト
   */
  public List<Field> searchFieldsByName(String name) {
    return fieldRepository.findByNameContainingIgnoreCase(name);
  }

  /**
   * 場所でフィールドを検索
   * @param location 場所
   * @return フィールドリスト
   */
  public List<Field> searchFieldsByLocation(String location) {
    return fieldRepository.findByLocationContainingIgnoreCase(location);
  }

  /**
   * 土壌タイプでフィールドを検索
   * @param soilType 土壌タイプ
   * @return フィールドリスト
   */
  public List<Field> searchFieldsBySoilType(String soilType) {
    return fieldRepository.findBySoilType(soilType);
  }

  /**
   * 複数条件でフィールドを検索
   * @param name フィールド名
   * @param location 場所
   * @param soilType 土壌タイプ
   * @return フィールドリスト
   */
  public List<Field> searchFields(String name, String location, String soilType) {
    if (name != null && !name.trim().isEmpty()) {
      return searchFieldsByName(name);
    } else if (location != null && !location.trim().isEmpty()) {
      return searchFieldsByLocation(location);
    } else if (soilType != null && !soilType.trim().isEmpty()) {
      return searchFieldsBySoilType(soilType);
    } else {
      return getAllFields();
    }
  }

  /**
   * 総面積を取得
   * @return 総面積（ヘクタール）
   */
  public Double getTotalArea() {
    return fieldRepository.getTotalArea();
  }

  /**
   * フィールド数を取得
   * @return フィールド数
   */
  public Long getFieldCount() {
    return fieldRepository.getFieldCount();
  }
} 