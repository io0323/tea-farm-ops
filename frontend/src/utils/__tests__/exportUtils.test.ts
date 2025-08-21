import {
  generateCSV,
  downloadCSV,
  exportFieldsToCSV,
  exportTasksToCSV,
} from "../exportUtils";
import { Field, Task, TaskType, TaskStatus } from "../../types";

// モックデータ
const mockFields: Field[] = [
  {
    id: 1,
    name: "テストフィールド1",
    location: "テスト場所1",
    areaSize: 5.5,
    soilType: "砂質土",
    notes: "テスト備考1",
  },
  {
    id: 2,
    name: "テストフィールド2",
    location: "テスト場所2",
    areaSize: 3.2,
    soilType: "粘土質土",
    notes: undefined,
  },
];

const mockTasks: Task[] = [
  {
    id: 1,
    taskType: TaskType.PLANTING,
    fieldId: mockFields[0].id,
    fieldName: mockFields[0].name,
    assignedWorker: "田中太郎",
    startDate: "2024-01-01",
    endDate: "2024-01-31",
    status: TaskStatus.IN_PROGRESS,
    notes: "テストタスク1",
  },
];

// URL.createObjectURLのモック
const mockCreateObjectURL = jest.fn();
const mockRevokeObjectURL = jest.fn();

// document.createElementのモック
const mockLink = {
  download: "test.csv",
  setAttribute: jest.fn(),
  click: jest.fn(),
  style: {},
};

describe("exportUtils", () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // グローバルオブジェクトのモック
    global.URL.createObjectURL =
      mockCreateObjectURL.mockReturnValue("blob:mock-url");
    global.URL.revokeObjectURL = mockRevokeObjectURL;
    global.document.createElement = jest.fn(() => mockLink as any);
    global.document.body.appendChild = jest.fn();
    global.document.body.removeChild = jest.fn();
  });

  describe("generateCSV", () => {
    it("正しいCSVデータを生成する", () => {
      const headers = [
        { key: "name", label: "名前" },
        { key: "value", label: "値" },
      ];

      const data = [
        { name: "テスト1", value: "値1" },
        { name: "テスト2", value: "値2" },
      ];

      const result = generateCSV(data, headers);

      expect(result).toBe("名前,値\nテスト1,値1\nテスト2,値2");
    });

    it("カンマを含むデータを正しくエスケープする", () => {
      const headers = [
        { key: "name", label: "名前" },
        { key: "description", label: "説明" },
      ];

      const data = [{ name: "テスト", description: "説明,カンマあり" }];

      const result = generateCSV(data, headers);

      expect(result).toBe('名前,説明\nテスト,"説明,カンマあり"');
    });

    it("改行を含むデータを正しくエスケープする", () => {
      const headers = [
        { key: "name", label: "名前" },
        { key: "description", label: "説明" },
      ];

      const data = [{ name: "テスト", description: "説明\n改行あり" }];

      const result = generateCSV(data, headers);

      expect(result).toBe('名前,説明\nテスト,"説明\n改行あり"');
    });
  });

  describe("downloadCSV", () => {
    it("CSVファイルをダウンロードする", () => {
      const csvContent = "名前,値\nテスト,値1";
      const filename = "test.csv";

      downloadCSV(csvContent, filename);

      expect(mockCreateObjectURL).toHaveBeenCalled();
      expect(mockLink.setAttribute).toHaveBeenCalledWith(
        "href",
        expect.any(String),
      );
      expect(mockLink.setAttribute).toHaveBeenCalledWith("download", filename);
      expect(mockLink.click).toHaveBeenCalled();
      expect(global.document.body.appendChild).toHaveBeenCalledWith(mockLink);
      expect(global.document.body.removeChild).toHaveBeenCalledWith(mockLink);
    });
  });

  describe("exportFieldsToCSV", () => {
    it("フィールドデータをCSVエクスポートする", () => {
      exportFieldsToCSV(mockFields);

      expect(mockCreateObjectURL).toHaveBeenCalled();
      expect(mockLink.setAttribute).toHaveBeenCalledWith(
        "download",
        expect.stringContaining("fields_"),
      );
    });
  });

  describe("exportTasksToCSV", () => {
    it("タスクデータをCSVエクスポートする", () => {
      exportTasksToCSV(mockTasks);

      expect(mockCreateObjectURL).toHaveBeenCalled();
      expect(mockLink.setAttribute).toHaveBeenCalledWith(
        "download",
        expect.stringContaining("tasks_"),
      );
    });
  });
});
