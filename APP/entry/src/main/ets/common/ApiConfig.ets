/**
 * API 配置
 * USE_MOCK = true  → 本地假数据（无需网络）
 * USE_MOCK = false → 请求服务器 http://111.229.171.161:8080
 */
export class ApiConfig {
  static readonly SERVER_HOST: string = 'http://111.229.171.161:8080';
  static readonly API_BASE: string = `${ApiConfig.SERVER_HOST}/api`;
  /** 切换为 false 即可接入服务器 */
  static readonly USE_MOCK: boolean = false;
}
