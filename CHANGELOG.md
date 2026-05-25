# 酒店推荐预订系统 — 变更日志

> 版本日期：2026-05-24  
> 目标：Web / App / Spring Boot / MySQL 四端数据统一、业务逻辑对齐美团/携程类真实场景

---

## 一、数据库变更（`hotel_reservation_system.sql`）

| 变更项 | 说明 |
|--------|------|
| `users.status` | 新增枚举值 `CANCELLED`（已注销） |
| `payments.payment_method` | 新增 `WECHAT` / `ALIPAY` / `BANK_CARD` / `SIMULATED` |
| `notifications.notification_type` | 扩展：`ORDER_CREATED`、`PAY_SUCCESS`、`ORDER_CONFIRMED`、`CHECKIN_REMINDER` 等 |

**已有库升级 SQL（按需执行）：**

```sql
ALTER TABLE users MODIFY status ENUM('NORMAL','DISABLED','CANCELLED') NOT NULL DEFAULT 'NORMAL';
ALTER TABLE payments MODIFY payment_method ENUM('ALIPAY','WECHAT','BANK_CARD','SIMULATED') NOT NULL DEFAULT 'SIMULATED';
ALTER TABLE notifications MODIFY notification_type ENUM(
  'RESERVATION_SUCCESS','PAYMENT_SUCCESS','ORDER_CANCELLED','REFUND_PROCESSING','REFUND_SUCCESS',
  'POST_APPROVED','POST_REJECTED','SYSTEM','ORDER_CREATED','PAY_SUCCESS','ORDER_CONFIRMED','CHECKIN_REMINDER'
) NOT NULL DEFAULT 'SYSTEM';
```

---

## 二、新增 / 修改后端接口

### 新增接口

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/admin/notifications/send` | 管理员向指定用户发送通知（别名，同 `/admin/notifications`） |
| PUT | `/api/users/cancel-account` | 用户注销账号（密码验证，状态改 CANCELLED） |
| PUT | `/api/reservations/{id}` | 修改订单（仅 `PENDING_PAYMENT` / `PAID`） |
| GET | `/api/reservations/my/reviewable` | 获取可评论的已完成订单列表 |

### 增强逻辑（已有接口）

| 接口 | 增强内容 |
|------|----------|
| POST `/api/reservations` | 入住日期校验、30 天上限、库存校验、重复预订检测、创建后自动通知 |
| PUT `/api/payments/{id}/pay` | 支付成功发送 `PAY_SUCCESS` 通知 |
| PUT `/api/admin/reservations/{id}/approve` | 确认订单发送 `ORDER_CONFIRMED` 通知 |
| POST `/api/posts` | 仅 `COMPLETED` 订单可评、每单一条、敏感词/联系方式/URL 过滤 |
| POST `/api/auth/login` / `register` | 已注销账号禁止登录与重新注册 |
| GET `/api/admin/stats` | 今日订单、今日营业额、评论审核统计、支付方式统计 |

### 定时任务

- `CheckinReminderScheduler`：每天 09:00 扫描次日入住订单，发送 `CHECKIN_REMINDER` 通知

---

## 三、后端修改文件

```
hotel-backend/src/main/java/com/hotel/reservation/
├── HotelReservationApplication.java          # @EnableScheduling
├── schedule/CheckinReminderScheduler.java      # 入住前一日提醒
├── common/util/ContentFilterUtil.java        # 评论内容过滤
├── controller/
│   ├── AdminController.java                  # /notifications/send
│   ├── UserController.java                   # /cancel-account
│   └── ReservationController.java            # PUT /{id}, GET /my/reviewable
├── service/impl/
│   ├── NotificationServiceImpl.java          # 自动通知 sendAutoNotification
│   ├── ReservationServiceImpl.java             # 校验/改单/库存/重复预订
│   ├── PostServiceImpl.java                  # 评论资格与内容校验
│   ├── AuthServiceImpl.java                  # CANCELLED 登录/注册拦截
│   ├── PaymentServiceImpl.java               # 支付成功通知
│   └── AdminStatsServiceImpl.java            # 管理端统计扩展
└── vo/AdminStatsVO.java                      # 统计字段扩展
```

---

## 四、Web 前端修改文件（`HotelSystem/`）

| 文件 | 变更 |
|------|------|
| `manageNotificationSend.html` | **新增** 管理员发送通知页 |
| `editReservation.html` | **重写** 对接 PUT `/reservations/{id}` |
| `notificationList.html` | 进入页自动全部已读 |
| `reservationDetail.html` | 增加「修改订单」按钮 |
| `createPayment.html` | 微信/支付宝/银行卡支付方式单选 |
| `createReservation.html` | 前端日期校验（不早于今天、≤30 天等） |
| `addPost.html` | 从 `/reservations/my/reviewable` 加载可评订单 |
| `cancelUser.html` | 对接 PUT `/users/cancel-account` |
| `manageReservation.html` | 订单状态筛选 |
| `manageNotification.html` | 增加「发送通知」入口 |
| `adminIndex.html` | 统计卡片扩展 + 发送通知入口 |
| `js/common.js` | 注册 `manageNotificationSend.html` 导航 |

---

## 五、HarmonyOS App 修改文件

**主工程：** `Documents/Hotel_Reservation_Management_System/entry/src/main/ets/`  
**课设同步：** `APP/entry/src/main/ets/`（已同步）

| 文件 | 变更 |
|------|------|
| `common/ApiConfig.ets` | `USE_MOCK=false`，`SERVER_HOST=http://111.229.171.161:8080` |
| `common/HotelApi.ets` | 注销、改单、可评订单、通知已读等 API |
| `common/Types.ets` | `AdminStatsVO`、`CreatePostRequest.reservationId` 等 |
| `pages/CancelAccountPage.ets` | **新增** 注销账号 |
| `pages/EditReservationPage.ets` | **新增** 修改订单 |
| `pages/AdminSendNotificationPage.ets` | **新增** 管理员发通知 |
| `pages/ProfilePage.ets` | 增加「注销账号」入口 |
| `pages/NotificationPage.ets` | 进入页自动全部已读 |
| `pages/CreatePostPage.ets` | 动态加载可评订单，禁用 Mock |
| `pages/PaymentPage.ets` | 增加银行卡支付方式 |
| `pages/ReservationDetailPage.ets` | 增加「修改订单」入口 |
| `pages/AdminHomePage.ets` | 今日订单/营业额/评论/支付方式统计 |
| `resources/base/profile/main_pages.json` | 注册新页面 |

---

## 六、核心业务逻辑说明

### 1. 管理员发送通知
- 管理员选择用户 + 标题 + 内容 → 写入 `notifications` 表，`status=UNREAD`
- Web/App 用户进入通知页 → 自动标记已读

### 2. 注销账号
- 二次确认 + 密码验证 → `users.status=CANCELLED` → 清除登录态
- 已注销账号：禁止登录、禁止同手机号重新注册

### 3. 订单修改
- **可改状态：** `PENDING_PAYMENT`（未支付）、`PAID`（待确认）
- **可改字段：** 入住日期、离店日期、房型、联系电话
- **不可改：** 已确认/已完成/已退款等状态
- 修改时同步调整房型库存

### 4. 自动通知
| 触发时机 | 通知类型 |
|----------|----------|
| 创建订单 | `ORDER_CREATED` |
| 支付成功 | `PAY_SUCCESS` |
| 管理员确认 | `ORDER_CONFIRMED` |
| 入住前一日 09:00 | `CHECKIN_REMINDER` |

### 5. 预订校验（前后端双重）
1. 入住日期 ≥ 今天  
2. 离店日期 > 入住日期  
3. 入住天数 ≤ 30 天  
4. 库存不足禁止预订  
5. 同一用户同一酒店同房型日期重叠禁止重复预订  

### 6. 支付方式
- 微信 `WECHAT` / 支付宝 `ALIPAY` / 银行卡 `BANK_CARD`
- 创建支付时保存 `payment_method`

### 7. 评论规则
- 仅 `COMPLETED` 订单用户可评，每单一条
- 必须关联对应酒店与 `reservationId`
- 禁止联系方式、广告词、二维码、URL；敏感词过滤

---

## 七、部署说明

### 后端
```bash
cd hotel-backend
mvn clean package -DskipTests
# 上传 target/hotel-reservation-*.jar 到服务器并重启
java -jar hotel-reservation-*.jar --spring.datasource.password=Hotel@2025
```

### Web（Nginx root 为 `/var/www/html`）
```bash
cp -r HotelSystem/* /var/www/html/
```

### MySQL
- 新环境：直接导入 `hotel_reservation_system.sql`
- 已有库：执行上方 ALTER 语句

### App
- DevEco Studio 打开 `Documents/Hotel_Reservation_Management_System` 或课设 `APP/`
- 确认 `ApiConfig.USE_MOCK = false`

---

## 八、完整测试步骤

### 准备工作
1. 启动 MySQL，导入/升级数据库  
2. 启动 Spring Boot（8080）  
3. Web：`python3 -m http.server 5500` 或部署到 Nginx  
4. App 连接 `http://111.229.171.161:8080`

**测试账号：**
- 管理员：`13800000000` / `123456`
- 普通用户：`13900000001` / `123456`（以库中实际数据为准）

---

### 测试 1：管理员发送通知
1. 管理员登录 Web → `adminIndex.html` →「发送通知」  
2. 选择用户、填写标题内容 → 发送  
3. 用户 Web 打开 `notificationList.html` → 应看到新通知且自动变已读  
4. App 打开「通知中心」→ 同步显示，进入后自动已读  
5. 管理端 `manageNotification.html` 可查看发送记录  

### 测试 2：注销账号
1. Web：`getUserInfo.html` →「注销账号」→ 输入密码 → 确认  
2. App：`ProfilePage` →「注销账号」→ 同样流程  
3. 尝试用该账号登录 → 应提示账号已注销  
4. 尝试同手机号注册 → 应被拒绝  

### 测试 3：订单修改
1. 创建订单（状态 `PENDING_PAYMENT`）  
2. Web/App 订单详情 →「修改订单」  
3. 修改入住/离店/房型/电话 → 保存成功  
4. 支付后（`PAID`）仍可修改  
5. 管理员确认后（`CONFIRMED`）→ 修改按钮应不可用  

### 测试 4：自动通知
1. 创建订单 → 用户收到 `ORDER_CREATED`  
2. 完成支付 → 收到 `PAY_SUCCESS`  
3. 管理员审核通过 → 收到 `ORDER_CONFIRMED`  
4. 将订单入住日设为明天，等待或手动触发定时任务 → 收到 `CHECKIN_REMINDER`  

### 测试 5：预订校验
1. 入住日期选昨天 → 前后端均应拦截  
2. 离店 ≤ 入住 → 拦截  
3. 入住超过 30 天 → 拦截  
4. 库存为 0 的房型 → 拦截  
5. 同一酒店同房型重叠日期再订 → 拦截  

### 测试 6：支付方式
1. Web `createPayment.html` / App `PaymentPage` 选择不同支付方式  
2. 支付成功后查 `payments` 表 → `payment_method` 正确  
3. 管理端 `adminIndex.html` / App `AdminHomePage` → 支付方式统计更新  

### 测试 7：评论限制
1. 未完成订单 → 评论入口不可用  
2. 完成订单 → 可评论一次  
3. 同一订单再次评论 → 被拒绝  
4. 内容含手机号/URL/广告词 → 被拒绝  

### 测试 8：四端数据同步
1. Web 创建订单 → App 订单列表即时可见  
2. App 支付 → Web 订单状态同步  
3. 管理员 Web 审核 → App 通知与状态同步  
4. 确认全链路无 MockData 参与（`ApiConfig.USE_MOCK=false`）  

### 测试 9：管理后台增强
1. `manageReservation.html` 按状态筛选订单  
2. `adminIndex.html` 查看：今日订单数、今日营业额、评论通过/驳回、支付方式统计  
3. App `AdminHomePage` 统计与 Web 一致  

---

## 九、已知说明

- 支付为**模拟支付**（课程设计），但支付方式选择与记录逻辑完整  
- 入住前一日提醒依赖 Spring Boot 定时任务持续运行  
- 服务器 Web 需同步到 Nginx 目录 `/var/www/html`，非仅 `hotel-deploy`  

---

*本 CHANGELOG 由本次业务完善任务自动生成。*
