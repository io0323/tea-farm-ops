// フィールド関連の型定義
export interface Field {
  id: number;
  name: string;
  location: string;
  areaSize: number;
  soilType?: string;
  notes?: string;
  createdAt?: string;
  updatedAt?: string;
}

// タスク関連の型定義
export enum TaskStatus {
  PENDING = "PENDING",
  IN_PROGRESS = "IN_PROGRESS",
  COMPLETED = "COMPLETED",
  CANCELLED = "CANCELLED",
}

export enum TaskType {
  PLANTING = "PLANTING",
  FERTILIZING = "FERTILIZING",
  PEST_CONTROL = "PEST_CONTROL",
  HARVESTING = "HARVESTING",
  PRUNING = "PRUNING",
  IRRIGATION = "IRRIGATION",
  OTHER = "OTHER",
}

export interface Task {
  id: number;
  taskType: TaskType;
  fieldId: number;
  fieldName: string;
  assignedWorker: string;
  startDate: string;
  endDate: string;
  status: TaskStatus;
  notes?: string;
  createdAt?: string;
  updatedAt?: string;
}

// 収穫記録関連の型定義
export enum TeaGrade {
  PREMIUM = "PREMIUM",
  HIGH = "HIGH",
  MEDIUM = "MEDIUM",
  STANDARD = "STANDARD",
}

export interface HarvestRecord {
  id: number;
  fieldId: number;
  fieldName: string;
  harvestDate: string;
  quantityKg: number;
  teaGrade: TeaGrade;
  notes?: string;
  createdAt?: string;
  updatedAt?: string;
}

// 天候観測関連の型定義
export interface WeatherObservation {
  id: number;
  date: string;
  fieldId: number;
  fieldName: string;
  temperature: number;
  rainfall: number;
  humidity: number;
  pestsSeen?: string;
  notes?: string;
  createdAt?: string;
  updatedAt?: string;
}

// ダッシュボード統計の型定義
export interface DashboardStats {
  totalFields: number;
  totalArea: number;
  completedTasks: number;
  inProgressTasks: number;
  pendingTasks: number;
  totalHarvest: number;
  monthlyHarvest: number;
  averageTemperature: number;
  totalRainfall: number;
  averageHumidity: number;
  harvestByGrade: Record<TeaGrade, number>;
}

// 認証関連の型定義
export interface User {
  id: number;
  username: string;
  role: "ADMIN" | "WORKER";
  email?: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

// API レスポンスの型定義
export interface ApiResponse<T> {
  data: T;
  message?: string;
  success: boolean;
}

export interface PaginatedResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  currentPage: number;
  size: number;
}

// 検索・フィルタ関連の型定義
export interface FieldSearchParams {
  name?: string;
  location?: string;
  soilType?: string;
}

export interface TaskSearchParams {
  taskType?: TaskType;
  status?: TaskStatus;
  assignedWorker?: string;
  startDate?: string;
  endDate?: string;
}

export interface HarvestRecordSearchParams {
  teaGrade?: TeaGrade;
  startDate?: string;
  endDate?: string;
  fieldId?: number;
}

export interface WeatherObservationSearchParams {
  startDate?: string;
  endDate?: string;
  fieldId?: number;
}
