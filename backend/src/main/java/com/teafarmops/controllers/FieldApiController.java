package com.teafarmops.controllers;

import com.teafarmops.dto.FieldDto;
import com.teafarmops.entities.Field;
import com.teafarmops.services.FieldService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * フィールドREST APIコントローラー
 * フィールド関連のREST APIエンドポイント
 */
@RestController
@RequestMapping("/api/fields")
@CrossOrigin(origins = "*")
public class FieldApiController {

  private final FieldService fieldService;

  @Autowired
  public FieldApiController(FieldService fieldService) {
    this.fieldService = fieldService;
  }

  /**
   * フィールド一覧を取得
   * @param name フィールド名（検索用）
   * @param location 場所（検索用）
   * @param soilType 土壌タイプ（検索用）
   * @return フィールド一覧
   */
  @GetMapping
  public ResponseEntity<List<FieldDto>> getFields(
      @RequestParam(required = false) String name,
      @RequestParam(required = false) String location,
      @RequestParam(required = false) String soilType) {
    
    List<Field> fields;
    if (name != null || location != null || soilType != null) {
      fields = fieldService.searchFields(name, location, soilType);
    } else {
      fields = fieldService.getAllFields();
    }
    
    List<FieldDto> fieldDtos = fields.stream()
        .map(this::convertToDto)
        .collect(Collectors.toList());
    
    return ResponseEntity.ok(fieldDtos);
  }

  /**
   * フィールド詳細を取得
   * @param id フィールドID
   * @return フィールド詳細
   */
  @GetMapping("/{id}")
  public ResponseEntity<FieldDto> getField(@PathVariable Long id) {
    return fieldService.getFieldById(id)
        .map(this::convertToDto)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
  }

  /**
   * フィールドを作成
   * @param fieldDto フィールド情報
   * @return 作成されたフィールド
   */
  @PostMapping
  public ResponseEntity<FieldDto> createField(@Valid @RequestBody FieldDto fieldDto) {
    Field field = convertToEntity(fieldDto);
    Field savedField = fieldService.saveField(field);
    return ResponseEntity.ok(convertToDto(savedField));
  }

  /**
   * フィールドを更新
   * @param id フィールドID
   * @param fieldDto 更新するフィールド情報
   * @return 更新されたフィールド
   */
  @PutMapping("/{id}")
  public ResponseEntity<FieldDto> updateField(@PathVariable Long id, @Valid @RequestBody FieldDto fieldDto) {
    return fieldService.getFieldById(id)
        .map(existingField -> {
          fieldDto.setId(id);
          Field updatedField = convertToEntity(fieldDto);
          Field savedField = fieldService.saveField(updatedField);
          return ResponseEntity.ok(convertToDto(savedField));
        })
        .orElse(ResponseEntity.notFound().build());
  }

  /**
   * フィールドを削除
   * @param id フィールドID
   * @return 削除結果
   */
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteField(@PathVariable Long id) {
    if (fieldService.getFieldById(id).isPresent()) {
      fieldService.deleteField(id);
      return ResponseEntity.noContent().build();
    } else {
      return ResponseEntity.notFound().build();
    }
  }

  /**
   * FieldDtoをFieldエンティティに変換
   * @param fieldDto DTO
   * @return エンティティ
   */
  private Field convertToEntity(FieldDto fieldDto) {
    Field field = new Field();
    field.setId(fieldDto.getId());
    field.setName(fieldDto.getName());
    field.setLocation(fieldDto.getLocation());
    field.setAreaSize(fieldDto.getAreaSize());
    field.setSoilType(fieldDto.getSoilType());
    field.setNotes(fieldDto.getNotes());
    return field;
  }

  /**
   * FieldエンティティをFieldDtoに変換
   * @param field エンティティ
   * @return DTO
   */
  private FieldDto convertToDto(Field field) {
    return new FieldDto(
        field.getId(),
        field.getName(),
        field.getLocation(),
        field.getAreaSize(),
        field.getSoilType(),
        field.getNotes()
    );
  }
} 