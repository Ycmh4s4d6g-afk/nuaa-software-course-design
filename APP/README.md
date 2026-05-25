# 酒店推荐预订系统 — HarmonyOS NEXT App

> 可直接导入 DevEco Studio 5.x 编译运行  
> 对应 Web 版：`HotelSystem/` + 后端 API：`hotel-backend/API.md`

---

## 一、工程结构（与 DevEco 标准一致）

```
APP/
├── AppScope/                          # 应用级配置
│   ├── app.json5
│   └── resources/base/
│       ├── element/string.json
│       └── media/app_icon.png
├── entry/                             # 主模块
│   ├── hvigorfile.ts
│   ├── oh-package.json5
│   └── src/main/
│       ├── module.json5               # 模块配置 + INTERNET 权限
│       ├── ets/
│       │   ├── entryability/
│       │   │   └── EntryAbility.ets   # 入口 Ability
│       │   ├── common/                # 公共模块（DevEco 中在 ets 下）
│       │   │   ├── ApiConfig.ets      # ★ 服务器地址 / Mock 开关
│       │   │   ├── HttpService.ets    # HTTP 请求封装
│       │   │   ├── HotelApi.ets       # 业务 API（Mock + 服务器）
│       │   │   ├── MockData.ets       # 本地假数据
│       │   │   ├── UserSession.ets    # 登录态（Preferences）
│       │   │   ├── Types.ets          # 类型定义
│       │   │   ├── BottomTabBar.ets   # 底部 Tab
│       │   │   ├── PageHeader.ets     # 页头
│       │   │   └── HotelComponents.ets
│       │   └── pages/                 # 21 个页面
│       └── resources/base/
│           ├── element/string.json
│           ├── element/color.json
│           ├── media/icon.png
│           └── profile/main_pages.json
├── build-profile.json5
├── hvigorfile.ts
└── oh-package.json5
```

---

## 二、导入 DevEco Studio

### 方式 A：直接打开（推荐）

1. DevEco Studio → **File → Open**
2. 选择本目录 `APP/`（含 `build-profile.json5` 的根目录）
3. 等待 Sync 完成
4. 连接模拟器或真机 → 点击 **Run**

### 方式 B：复制到已有工程

将以下内容覆盖/合并到你的工程：

| 源路径 | 目标 |
|--------|------|
| `APP/entry/src/main/ets/*` | `entry/src/main/ets/` |
| `APP/entry/src/main/resources/*` | `entry/src/main/resources/` |
| `APP/entry/src/main/module.json5` | `entry/src/main/module.json5` |
| `APP/AppScope/*` | `AppScope/` |

---

## 三、服务器 / Mock 切换

编辑 **`entry/src/main/ets/common/ApiConfig.ets`**：

```typescript
export class ApiConfig {
  static readonly SERVER_HOST: string = 'http://111.229.171.161:8080';
  static readonly API_BASE: string = `${ApiConfig.SERVER_HOST}/api`;
  /** true=本地假数据  false=请求服务器 */
  static readonly USE_MOCK: boolean = true;
}
```

| 模式 | USE_MOCK | 说明 |
|------|----------|------|
| 离线演示 | `true` | 无需网络，使用 MockData |
| 联调服务器 | `false` | 请求 `http://111.229.171.161:8080/api` |

认证方式与 Web 版一致：登录后请求头携带 `X-User-Id`。

---

## 四、测试账号（Mock / 服务器通用）

| 手机号 | 密码 | 昵称 |
|--------|------|------|
| 13900000001 | 123456 | 张三 |
| 13900000002 | 123456 | 李四 |

---

## 五、页面流程

```
Index → SplashPage(1s) → LoginPage → HomePage
                              ↓
                         RegisterPage

HomePage → SearchPage / HotelDetailPage → RoomTypePage
         → CreateReservationPage → PaymentPage → ReservationListPage

底部 Tab：HomePage | ReservationListPage | CollectionPage | ProfilePage
ProfilePage → EditProfile / ChangePassword / Notification / PostList / About
```

---

## 六、API 对照（第二阶段接入）

与 `hotel-backend/API.md` 一致，主要接口：

- `POST /auth/login`、`POST /auth/register`
- `GET /hotels/recommended`、`GET /hotels`、`GET /hotels/{id}`
- `GET /hotels/{id}/room-types`
- `POST /reservations`、`GET /reservations/my`
- `POST /payments`、`PUT /payments/{id}/pay`
- `GET /collections/my`、`GET /posts/my`、`GET /notifications/my`
- `GET /users/me`、`PUT /users/change-password`

---

## 七、常见问题

**1. 找不到 common 目录？**  
在 DevEco 中展开 `entry/src/main/ets/common`，与 `pages` 同级。

**2. 编译报 icon 缺失？**  
确认存在 `entry/src/main/resources/base/media/icon.png` 和 `AppScope/resources/base/media/app_icon.png`。

**3. 酒店图片放在哪里？**  
将 JPG 放入 **`entry/src/main/resources/base/media/`**，文件名必须用**英文+下划线**：

| 原文件名 | 放入 media 后的文件名 | 对应酒店 id |
|----------|----------------------|-------------|
| 杭州西湖.jpg | `hangzhou_xihu.jpg` | 1 |
| 上海外滩.jpg | `shanghai_waitan.jpg` | 2 |
| 紫峰大厦.jpg | `zijin_tower.jpg` | 3 |

代码中通过 `$r('app.media.hangzhou_xihu')` 引用，逻辑在 `common/HotelImageUtil.ets`。  
**不要**使用中文文件名，HarmonyOS 资源名不支持中文。

**4. 真机无法访问服务器？**  
- 将 `USE_MOCK` 改为 `false`  
- 确认手机能访问 `111.229.171.161:8080`  
- `module.json5` 已声明 `ohos.permission.INTERNET`

**4. SDK 版本？**  
`build-profile.json5` 默认 `compatibleSdkVersion: 5.0.0(12)`，可在 DevEco 中按本机 SDK 调整。

---

## 八、打包安装到手机

1. DevEco → **Build → Build Hap(s)/APP(s) → Build APP(s)**
2. 产物在 `entry/build/default/outputs/default/`
3. 或通过 USB 调试直接 Run 到真机
