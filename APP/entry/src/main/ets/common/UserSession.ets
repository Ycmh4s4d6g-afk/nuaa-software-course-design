import { preferences } from '@kit.ArkData';
import { LoginUser, MockRegisteredUser } from './Types';

const PREF_NAME = 'hotel_app_session';
const MOCK_USERS_KEY = 'mockRegisteredUsers';

export class UserSession {
  private static pref: preferences.Preferences | null = null;
  private static userId: string = '';
  private static username: string = '';
  private static phone: string = '';
  private static role: string = '';

  static async init(context: Context): Promise<void> {
    UserSession.pref = await preferences.getPreferences(context, PREF_NAME);
    UserSession.userId = `${await UserSession.pref.get('userId', '')}`;
    UserSession.username = `${await UserSession.pref.get('username', '')}`;
    UserSession.phone = `${await UserSession.pref.get('phone', '')}`;
    UserSession.role = `${await UserSession.pref.get('role', '')}`;
  }

  static async saveUser(user: LoginUser): Promise<void> {
    UserSession.userId = `${user.userId}`;
    UserSession.username = user.username;
    UserSession.phone = user.phone;
    UserSession.role = user.role;
    if (UserSession.phone === '13800000000') {
      UserSession.role = 'ADMIN';
    }
    if (UserSession.pref) {
      await UserSession.pref.put('userId', UserSession.userId);
      await UserSession.pref.put('username', UserSession.username);
      await UserSession.pref.put('phone', UserSession.phone);
      await UserSession.pref.put('role', UserSession.role);
      await UserSession.pref.flush();
    }
  }

  static async clear(): Promise<void> {
    UserSession.userId = '';
    UserSession.username = '';
    UserSession.phone = '';
    UserSession.role = '';
    if (UserSession.pref) {
      await UserSession.pref.clear();
      await UserSession.pref.flush();
    }
  }

  static getUserId(): string {
    return UserSession.userId;
  }

  static getUsername(): string {
    return UserSession.username;
  }

  static getPhone(): string {
    return UserSession.phone;
  }

  static getRole(): string {
    return UserSession.role;
  }

  static isLoggedIn(): boolean {
    return UserSession.userId.length > 0;
  }

  /** Mock 模式：持久化注册用户，解决注册后无法登录 */
  static async saveMockRegisteredUser(user: MockRegisteredUser): Promise<void> {
    const list = await UserSession.getMockRegisteredUsers();
    const next: MockRegisteredUser[] = [];
    for (let i = 0; i < list.length; i++) {
      if (list[i].phone !== user.phone) {
        next.push(list[i]);
      }
    }
    next.push(user);
    if (UserSession.pref) {
      await UserSession.pref.put(MOCK_USERS_KEY, JSON.stringify(next));
      await UserSession.pref.flush();
    }
  }

  static async getMockRegisteredUsers(): Promise<MockRegisteredUser[]> {
    if (!UserSession.pref) {
      return [];
    }
    const raw = `${await UserSession.pref.get(MOCK_USERS_KEY, '[]')}`;
    try {
      const parsed = JSON.parse(raw) as MockRegisteredUser[];
      return Array.isArray(parsed) ? parsed : [];
    } catch (_e) {
      return [];
    }
  }

  static async findMockRegisteredUser(phone: string, password: string): Promise<LoginUser | null> {
    const list = await UserSession.getMockRegisteredUsers();
    for (let i = 0; i < list.length; i++) {
      const u = list[i];
      if (u.phone === phone && u.password === password) {
        const loginUser: LoginUser = {
          userId: u.userId,
          username: u.username,
          phone: u.phone,
          role: u.role
        };
        return loginUser;
      }
    }
    return null;
  }
}
