import { Field, Task, HarvestRecord, WeatherObservation } from "../types";

/**
 * CSVデータを生成する
 * @param data エクスポートするデータ
 * @param headers ヘッダー情報
 * @returns CSV文字列
 */
export const generateCSV = (
  data: any[],
  headers: { key: string; label: string }[],
): string => {
  // ヘッダー行
  const headerRow = headers.map((h) => h.label).join(",");

  // データ行
  const dataRows = data.map((item) =>
    headers
      .map((h) => {
        const value = item[h.key];
        // カンマや改行を含む場合はダブルクォートで囲む
        if (
          typeof value === "string" &&
          (value.includes(",") || value.includes("\n") || value.includes('"'))
        ) {
          return `"${value.replace(/"/g, '""')}"`;
        }
        return value || "";
      })
      .join(","),
  );

  return [headerRow, ...dataRows].join("\n");
};

/**
 * CSVファイルをダウンロードする
 * @param csvContent CSVコンテンツ
 * @param filename ファイル名
 */
export const downloadCSV = (csvContent: string, filename: string): void => {
  const blob = new Blob(["\uFEFF" + csvContent], {
    type: "text/csv;charset=utf-8;",
  });
  const link = document.createElement("a");

  if (link.download !== undefined) {
    const url = URL.createObjectURL(blob);
    link.setAttribute("href", url);
    link.setAttribute("download", filename);
    link.style.visibility = "hidden";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
};

/**
 * フィールドデータをCSVエクスポート
 * @param fields フィールドデータ
 */
export const exportFieldsToCSV = (fields: Field[]): void => {
  const headers = [
    { key: "name", label: "フィールド名" },
    { key: "location", label: "場所" },
    { key: "areaSize", label: "面積(ha)" },
    { key: "soilType", label: "土壌タイプ" },
    { key: "notes", label: "備考" },
  ];

  const csvContent = generateCSV(fields, headers);
  downloadCSV(
    csvContent,
    `fields_${new Date().toISOString().split("T")[0]}.csv`,
  );
};

/**
 * タスクデータをCSVエクスポート
 * @param tasks タスクデータ
 */
export const exportTasksToCSV = (tasks: Task[]): void => {
  const headers = [
    { key: "taskType", label: "タスクタイプ" },
    { key: "assignedWorker", label: "担当者" },
    { key: "startDate", label: "開始日" },
    { key: "endDate", label: "終了日" },
    { key: "status", label: "ステータス" },
    { key: "notes", label: "備考" },
  ];

  const csvContent = generateCSV(tasks, headers);
  downloadCSV(
    csvContent,
    `tasks_${new Date().toISOString().split("T")[0]}.csv`,
  );
};

/**
 * 収穫記録データをCSVエクスポート
 * @param records 収穫記録データ
 */
export const exportHarvestRecordsToCSV = (records: HarvestRecord[]): void => {
  const headers = [
    { key: "harvestDate", label: "収穫日" },
    { key: "quantityKg", label: "収穫量(kg)" },
    { key: "teaGrade", label: "茶葉グレード" },
    { key: "notes", label: "備考" },
  ];

  const csvContent = generateCSV(records, headers);
  downloadCSV(
    csvContent,
    `harvest_records_${new Date().toISOString().split("T")[0]}.csv`,
  );
};

/**
 * 天候観測データをCSVエクスポート
 * @param observations 天候観測データ
 */
export const exportWeatherObservationsToCSV = (
  observations: WeatherObservation[],
): void => {
  const headers = [
    { key: "date", label: "観測日" },
    { key: "temperature", label: "気温(°C)" },
    { key: "rainfall", label: "降水量(mm)" },
    { key: "humidity", label: "湿度(%)" },
    { key: "pestsSeen", label: "害虫の有無" },
    { key: "notes", label: "備考" },
  ];

  const csvContent = generateCSV(observations, headers);
  downloadCSV(
    csvContent,
    `weather_observations_${new Date().toISOString().split("T")[0]}.csv`,
  );
};

/**
 * 全データを一括エクスポート
 * @param data 全データ
 */
export const exportAllDataToCSV = (data: {
  fields: Field[];
  tasks: Task[];
  harvestRecords: HarvestRecord[];
  weatherObservations: WeatherObservation[];
}): void => {
  // const timestamp = new Date().toISOString().split('T')[0];

  exportFieldsToCSV(data.fields);
  setTimeout(() => exportTasksToCSV(data.tasks), 100);
  setTimeout(() => exportHarvestRecordsToCSV(data.harvestRecords), 200);
  setTimeout(
    () => exportWeatherObservationsToCSV(data.weatherObservations),
    300,
  );
};
