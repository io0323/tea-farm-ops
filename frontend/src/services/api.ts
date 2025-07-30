import axios, { AxiosInstance, AxiosResponse } from 'axios';
import {
  Field,
  Task,
  HarvestRecord,
  WeatherObservation,
  DashboardStats,
  LoginRequest,
  LoginResponse,
  User,
  FieldSearchParams,
  TaskSearchParams,
  HarvestRecordSearchParams,
  WeatherObservationSearchParams
} from '../types';

// API クライアントの設定
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // リクエストインターセプター（認証トークンの追加）
    this.client.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('authToken');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // レスポンスインターセプター（エラーハンドリング）
    this.client.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          localStorage.removeItem('authToken');
          localStorage.removeItem('user');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // 認証関連
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response: AxiosResponse<LoginResponse> = await this.client.post('/auth/login', credentials);
    return response.data;
  }

  async logout(): Promise<void> {
    await this.client.post('/auth/logout');
    localStorage.removeItem('authToken');
    localStorage.removeItem('user');
  }

  async getCurrentUser(): Promise<User> {
    const response: AxiosResponse<User> = await this.client.get('/auth/me');
    return response.data;
  }

  // ダッシュボード
  async getDashboardStats(): Promise<DashboardStats> {
    const response: AxiosResponse<DashboardStats> = await this.client.get('/dashboard/stats');
    return response.data;
  }

  // フィールド関連
  async getFields(params?: FieldSearchParams): Promise<Field[]> {
    const response: AxiosResponse<Field[]> = await this.client.get('/fields', { params });
    return response.data;
  }

  async getField(id: number): Promise<Field> {
    const response: AxiosResponse<Field> = await this.client.get(`/fields/${id}`);
    return response.data;
  }

  async createField(field: Omit<Field, 'id'>): Promise<Field> {
    const response: AxiosResponse<Field> = await this.client.post('/fields', field);
    return response.data;
  }

  async updateField(id: number, field: Partial<Field>): Promise<Field> {
    const response: AxiosResponse<Field> = await this.client.put(`/fields/${id}`, field);
    return response.data;
  }

  async deleteField(id: number): Promise<void> {
    await this.client.delete(`/fields/${id}`);
  }

  // タスク関連
  async getTasks(params?: TaskSearchParams): Promise<Task[]> {
    const response: AxiosResponse<Task[]> = await this.client.get('/tasks', { params });
    return response.data;
  }

  async getTask(id: number): Promise<Task> {
    const response: AxiosResponse<Task> = await this.client.get(`/tasks/${id}`);
    return response.data;
  }

  async createTask(task: Omit<Task, 'id'>): Promise<Task> {
    const response: AxiosResponse<Task> = await this.client.post('/tasks', task);
    return response.data;
  }

  async updateTask(id: number, task: Partial<Task>): Promise<Task> {
    const response: AxiosResponse<Task> = await this.client.put(`/tasks/${id}`, task);
    return response.data;
  }

  async deleteTask(id: number): Promise<void> {
    await this.client.delete(`/tasks/${id}`);
  }

  // 収穫記録関連
  async getHarvestRecords(params?: HarvestRecordSearchParams): Promise<HarvestRecord[]> {
    const response: AxiosResponse<HarvestRecord[]> = await this.client.get('/harvest-records', { params });
    return response.data;
  }

  async getHarvestRecord(id: number): Promise<HarvestRecord> {
    const response: AxiosResponse<HarvestRecord> = await this.client.get(`/harvest-records/${id}`);
    return response.data;
  }

  async createHarvestRecord(record: Omit<HarvestRecord, 'id'>): Promise<HarvestRecord> {
    const response: AxiosResponse<HarvestRecord> = await this.client.post('/harvest-records', record);
    return response.data;
  }

  async updateHarvestRecord(id: number, record: Partial<HarvestRecord>): Promise<HarvestRecord> {
    const response: AxiosResponse<HarvestRecord> = await this.client.put(`/harvest-records/${id}`, record);
    return response.data;
  }

  async deleteHarvestRecord(id: number): Promise<void> {
    await this.client.delete(`/harvest-records/${id}`);
  }

  // 天候観測関連
  async getWeatherObservations(params?: WeatherObservationSearchParams): Promise<WeatherObservation[]> {
    const response: AxiosResponse<WeatherObservation[]> = await this.client.get('/weather-observations', { params });
    return response.data;
  }

  async getWeatherObservation(id: number): Promise<WeatherObservation> {
    const response: AxiosResponse<WeatherObservation> = await this.client.get(`/weather-observations/${id}`);
    return response.data;
  }

  async createWeatherObservation(observation: Omit<WeatherObservation, 'id'>): Promise<WeatherObservation> {
    const response: AxiosResponse<WeatherObservation> = await this.client.post('/weather-observations', observation);
    return response.data;
  }

  async updateWeatherObservation(id: number, observation: Partial<WeatherObservation>): Promise<WeatherObservation> {
    const response: AxiosResponse<WeatherObservation> = await this.client.put(`/weather-observations/${id}`, observation);
    return response.data;
  }

  async deleteWeatherObservation(id: number): Promise<void> {
    await this.client.delete(`/weather-observations/${id}`);
  }
}

// シングルトンインスタンス
export const apiClient = new ApiClient();
export default apiClient; 