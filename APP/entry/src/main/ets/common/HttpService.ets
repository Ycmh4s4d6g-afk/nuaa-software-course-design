import { http } from '@kit.NetworkKit';
import { ApiConfig } from './ApiConfig';
import { ApiResult, createFailResult } from './Types';
import { UserSession } from './UserSession';

export class HttpService {
  private static async request<T>(
    method: http.RequestMethod,
    path: string,
    body?: object,
    needAuth: boolean = false
  ): Promise<ApiResult<T>> {
    const httpRequest = http.createHttp();
    const url = `${ApiConfig.API_BASE}${path}`;
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (needAuth && UserSession.getUserId().length > 0) {
      headers['X-User-Id'] = UserSession.getUserId();
    }

    try {
      const response = await httpRequest.request(url, {
        method: method,
        header: headers,
        extraData: body ? JSON.stringify(body) : undefined,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode >= 200 && response.responseCode < 300 && response.result) {
        const json = JSON.parse(response.result as string) as ApiResult<T>;
        return json;
      }

      if (response.result) {
        try {
          const json = JSON.parse(response.result as string) as ApiResult<T>;
          if (json.message && json.message.length > 0) {
            return createFailResult<T>(json.code || response.responseCode, json.message);
          }
        } catch (_e) {
        }
      }

      return createFailResult<T>(response.responseCode, '网络请求失败');
    } catch (err) {
      return createFailResult<T>(-1, `网络异常: ${JSON.stringify(err)}`);
    } finally {
      httpRequest.destroy();
    }
  }

  static get<T>(path: string, needAuth: boolean = false): Promise<ApiResult<T>> {
    return HttpService.request<T>(http.RequestMethod.GET, path, undefined, needAuth);
  }

  static post<T>(path: string, body: object, needAuth: boolean = false): Promise<ApiResult<T>> {
    return HttpService.request<T>(http.RequestMethod.POST, path, body, needAuth);
  }

  static put<T>(path: string, body?: object, needAuth: boolean = false): Promise<ApiResult<T>> {
    return HttpService.request<T>(http.RequestMethod.PUT, path, body, needAuth);
  }

  static delete<T>(path: string, needAuth: boolean = false): Promise<ApiResult<T>> {
    return HttpService.request<T>(http.RequestMethod.DELETE, path, undefined, needAuth);
  }
}
