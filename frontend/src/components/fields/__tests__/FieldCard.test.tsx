import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import FieldCard from '../FieldCard';
import { Field } from '../../../types';

// テスト用のモックデータ
const mockField: Field = {
  id: 1,
  name: 'テストフィールド',
  location: 'テスト場所',
  areaSize: 5.5,
  soilType: '砂質土',
  notes: 'テスト用の備考',
};

const mockOnEdit = jest.fn();
const mockOnDelete = jest.fn();

describe('FieldCard', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('フィールド情報を正しく表示する', () => {
    render(
      <FieldCard
        field={mockField}
        onEdit={mockOnEdit}
        onDelete={mockOnDelete}
      />
    );

    expect(screen.getByText('テストフィールド')).toBeInTheDocument();
    expect(screen.getByText('テスト場所')).toBeInTheDocument();
    expect(screen.getByText('5.5ha')).toBeInTheDocument();
    expect(screen.getByText('砂質土')).toBeInTheDocument();
    expect(screen.getByText('テスト用の備考')).toBeInTheDocument();
  });

  it('編集ボタンをクリックするとonEditが呼ばれる', () => {
    render(
      <FieldCard
        field={mockField}
        onEdit={mockOnEdit}
        onDelete={mockOnDelete}
      />
    );

    const editButton = screen.getByRole('button', { name: /編集/i });
    fireEvent.click(editButton);

    expect(mockOnEdit).toHaveBeenCalledWith(mockField);
    expect(mockOnEdit).toHaveBeenCalledTimes(1);
  });

  it('削除ボタンをクリックするとonDeleteが呼ばれる', () => {
    render(
      <FieldCard
        field={mockField}
        onEdit={mockOnEdit}
        onDelete={mockOnDelete}
      />
    );

    const deleteButton = screen.getByRole('button', { name: /削除/i });
    fireEvent.click(deleteButton);

    expect(mockOnDelete).toHaveBeenCalledWith(mockField);
    expect(mockOnDelete).toHaveBeenCalledTimes(1);
  });

  it('備考がない場合は備考が表示されない', () => {
    const fieldWithoutNotes = { ...mockField, notes: undefined };
    
    render(
      <FieldCard
        field={fieldWithoutNotes}
        onEdit={mockOnEdit}
        onDelete={mockOnDelete}
      />
    );

    expect(screen.queryByText('テスト用の備考')).not.toBeInTheDocument();
  });

  it('土壌タイプがない場合は土壌タイプチップが表示されない', () => {
    const fieldWithoutSoilType = { ...mockField, soilType: undefined };
    
    render(
      <FieldCard
        field={fieldWithoutSoilType}
        onEdit={mockOnEdit}
        onDelete={mockOnDelete}
      />
    );

    expect(screen.queryByText('砂質土')).not.toBeInTheDocument();
  });
}); 