import { promptAction } from '@kit.ArkUI';
import router from '@ohos.router';
import { ApiConfig } from './ApiConfig';
import { HttpService } from './HttpService';
import {
  ApiResult, ChangePasswordRequest, CollectionRecordVO, CollectionVO, CreateCollectionRequest,
  CreatePaymentRequest,
  CreatePostRequest, CreateReservationRequest, EmptyData, ForgotPasswordRequest,
  HotelVO, LoginRequest, LoginUser, NotificationVO, PageResult, PaymentVO, PostVO,
  RegisterRequest, ReservationVO, RoomTypeVO, UserProfileVO, MockRegisteredUser,
  AdminStatsVO, AdminUserVO, AdminCollectionVO,
  AdminHotelRequest, AuditRemarkRequest, UpdateUserStatusRequest, AdminCreateNotificationRequest,
  AdminCreateRoomTypeRequest, AdminUpdateRoomTypeRequest,
  createEmptyApiResult, createFailResult, createSuccessResult
} from './Types';
import {
  MOCK_HOTELS, MOCK_NOTIFICATIONS, MOCK_POSTS, MOCK_RESERVATIONS, MOCK_USERS,
  addMockCollection, getMockCollectionList,
  getMockHotelById, getMockProfile, getMockReservationById, getMockRoomTypes,
  isMockHotelCollected, removeMockCollection
} from './MockData';
import { UserSession } from './UserSession';
import { enrichDisplayHotels, filterDisplayHotels, sortHotelsByRating } from './HotelDisplayUtil';

const ADMIN_PHONE = '13800000000';

function buildLoginRequest(phone: string, password: string): LoginRequest {
  const req: LoginRequest = { phone: phone, password: password };
  return req;
}

function buildRegisterRequest(phone: string, password: string, username: string): RegisterRequest {
  const req: RegisterRequest = { phone: phone, password: password, username: username };
  return req;
}

function buildChangePasswordRequest(oldPassword: string, newPassword: string): ChangePasswordRequest {
  const req: ChangePasswordRequest = { oldPassword: oldPassword, newPassword: newPassword };
  return req;
}

function buildForgotPasswordRequest(phone: string, newPassword: string): ForgotPasswordRequest {
  const req: ForgotPasswordRequest = { phone: phone, newPassword: newPassword };
  return req;
}

function buildPaymentRequest(reservationId: number, paymentMethod: string): CreatePaymentRequest {
  let method = 'SIMULATED';
  if (paymentMethod === 'WECHAT') {
    method = 'WECHAT';
  } else if (paymentMethod === 'ALIPAY') {
    method = 'ALIPAY';
  }
  const req: CreatePaymentRequest = { reservationId: reservationId, paymentMethod: method };
  return req;
}

function buildCollectionRequest(hotelId: number): CreateCollectionRequest {
  const req: CreateCollectionRequest = { hotelId: hotelId };
  return req;
}

function mapCollectionRecord(record: CollectionRecordVO): CollectionVO {
  const hotel = record.hotel;
  const item: CollectionVO = {
    id: record.id,
    hotelId: record.hotelId,
    hotelName: hotel ? hotel.hotelName : '',
    city: hotel ? hotel.city : '',
    minPrice: hotel ? hotel.minPrice : 0,
    rating: hotel ? hotel.rating : 0
  };
  return item;
}

interface PostRecordVO {
  id: number;
  title: string;
  content: string;
  hotelName: string;
  username: string;
  score?: number;
  rating?: number;
  auditStatus: string;
  createTime?: string;
}

interface NotificationRecordVO {
  id: number;
  title: string;
  content: string;
  status?: string;
  isRead?: boolean;
  createTime?: string;
  userId?: number;
  username?: string;
}

function mapPostRecord(record: PostRecordVO): PostVO {
  let rating = 0;
  if (record.score !== undefined) {
    rating = record.score;
  } else if (record.rating !== undefined) {
    rating = record.rating;
  }
  const item: PostVO = {
    id: record.id,
    title: record.title,
    content: record.content,
    hotelName: record.hotelName ?? '',
    username: record.username ?? '',
    rating: rating,
    auditStatus: record.auditStatus ?? '',
    createTime: record.createTime
  };
  return item;
}

function mapNotificationRecord(record: NotificationRecordVO): NotificationVO {
  let isRead = false;
  if (record.isRead === true) {
    isRead = true;
  } else if (record.status === 'READ') {
    isRead = true;
  }
  const item: NotificationVO = {
    id: record.id,
    title: record.title ?? '',
    content: record.content ?? '',
    isRead: isRead,
    createTime: record.createTime ?? '',
    userId: record.userId,
    username: record.username,
    status: record.status
  };
  return item;
}

interface RoomTypeRecordVO {
  id: number;
  hotelId: number;
  roomTypeName?: string;
  roomName?: string;
  bedType: string;
  capacity?: number;
  maxGuests?: number;
  availableRooms?: number;
  stock?: number;
  totalRooms?: number;
  price: number;
  description?: string;
  status?: string;
}

function mapRoomTypeRecord(record: RoomTypeRecordVO): RoomTypeVO {
  let maxGuests = 2;
  if (record.capacity !== undefined) {
    maxGuests = record.capacity;
  } else if (record.maxGuests !== undefined) {
    maxGuests = record.maxGuests;
  }
  let stock = 0;
  if (record.availableRooms !== undefined) {
    stock = record.availableRooms;
  } else if (record.stock !== undefined) {
    stock = record.stock;
  }
  let roomName = '';
  if (record.roomTypeName !== undefined && record.roomTypeName.length > 0) {
    roomName = record.roomTypeName;
  } else if (record.roomName !== undefined) {
    roomName = record.roomName;
  }
  const item: RoomTypeVO = {
    id: record.id,
    hotelId: record.hotelId,
    roomName: roomName,
    bedType: record.bedType ?? '',
    maxGuests: maxGuests,
    price: record.price,
    stock: stock,
    description: record.description,
    totalRooms: record.totalRooms,
    status: record.status
  };
  return item;
}

export class HotelApi {
  static async login(phone: string, password: string): Promise<ApiResult<LoginUser>> {
    if (ApiConfig.USE_MOCK) {
      for (let i = 0; i < MOCK_USERS.length; i++) {
        const u = MOCK_USERS[i];
        if (u.phone === phone && password === '123456') {
          return createSuccessResult<LoginUser>('success', u);
        }
      }
      const registered = await UserSession.findMockRegisteredUser(phone, password);
      if (registered) {
        return createSuccessResult<LoginUser>('success', registered);
      }
      return createFailResult<LoginUser>(400, '手机号或密码错误');
    }
    return HttpService.post<LoginUser>('/auth/login', buildLoginRequest(phone, password));
  }

  static async register(phone: string, password: string, username: string): Promise<ApiResult<LoginUser>> {
    if (ApiConfig.USE_MOCK) {
      for (let i = 0; i < MOCK_USERS.length; i++) {
        if (MOCK_USERS[i].phone === phone) {
          return createFailResult<LoginUser>(400, '该手机号已注册');
        }
      }
      const existing = await UserSession.getMockRegisteredUsers();
      for (let i = 0; i < existing.length; i++) {
        if (existing[i].phone === phone) {
          return createFailResult<LoginUser>(400, '该手机号已注册');
        }
      }
      const mockUser: MockRegisteredUser = {
        userId: 100 + existing.length,
        username: username,
        phone: phone,
        password: password,
        role: 'CUSTOMER'
      };
      await UserSession.saveMockRegisteredUser(mockUser);
      const loginUser: LoginUser = {
        userId: mockUser.userId,
        username: mockUser.username,
        phone: mockUser.phone,
        role: mockUser.role
      };
      return createSuccessResult<LoginUser>('success', loginUser);
    }
    return HttpService.post<LoginUser>('/auth/register', buildRegisterRequest(phone, password, username));
  }

  static async getRecommended(limit: number = 6): Promise<HotelVO[]> {
    if (ApiConfig.USE_MOCK) {
      return MOCK_HOTELS.slice(0, limit);
    }
    const res = await HttpService.get<HotelVO[]>(`/hotels/recommended?sortBy=rating&limit=20`);
    let list = res.code === 200 && res.data ? res.data : [];
    list = sortHotelsByRating(enrichDisplayHotels(list));
    if (list.length > limit) {
      return list.slice(0, limit);
    }
    return list;
  }

  static async getHotels(city?: string, keyword?: string): Promise<HotelVO[]> {
    if (ApiConfig.USE_MOCK) {
      let list = MOCK_HOTELS;
      if (city && city.length > 0) {
        list = list.filter((h: HotelVO) => h.city === city);
      }
      if (keyword && keyword.length > 0) {
        list = list.filter((h: HotelVO) =>
        h.hotelName.includes(keyword) || h.city.includes(keyword) || h.hotelType.includes(keyword));
      }
      return list;
    }
    let path = '/hotels?page=1&size=50';
    if (city) {
      path += `&city=${encodeURIComponent(city)}`;
    }
    if (keyword) {
      path += `&keyword=${encodeURIComponent(keyword)}`;
    }
    const res = await HttpService.get<PageResult<HotelVO>>(path);
    let list = res.code === 200 && res.data ? res.data.records : [];
    list = enrichDisplayHotels(list);
    if (city && city.length > 0) {
      const cityList: HotelVO[] = [];
      for (let i = 0; i < list.length; i++) {
        if (list[i].city === city) {
          cityList.push(list[i]);
        }
      }
      return cityList;
    }
    return list;
  }

  static async getHotelDetail(id: number): Promise<HotelVO | undefined> {
    if (ApiConfig.USE_MOCK) {
      return getMockHotelById(id);
    }
    const res = await HttpService.get<HotelVO>(`/hotels/${id}`);
    return res.code === 200 ? res.data : undefined;
  }

  static async getRoomTypes(hotelId: number): Promise<RoomTypeVO[]> {
    if (ApiConfig.USE_MOCK) {
      return getMockRoomTypes(hotelId);
    }
    const res = await HttpService.get<RoomTypeRecordVO[]>(`/hotels/${hotelId}/room-types`);
    if (res.code !== 200 || !res.data) {
      return [];
    }
    const list: RoomTypeVO[] = [];
    for (let i = 0; i < res.data.length; i++) {
      list.push(mapRoomTypeRecord(res.data[i]));
    }
    return list;
  }

  static async getMyReservations(): Promise<ReservationVO[]> {
    if (ApiConfig.USE_MOCK) {
      return MOCK_RESERVATIONS;
    }
    const res = await HttpService.get<PageResult<ReservationVO>>('/reservations/my?page=1&size=50', true);
    return res.code === 200 && res.data ? res.data.records : [];
  }

  static async getReservationDetail(id: number): Promise<ReservationVO | undefined> {
    if (ApiConfig.USE_MOCK) {
      return getMockReservationById(id);
    }
    const res = await HttpService.get<ReservationVO>(`/reservations/${id}`, true);
    return res.code === 200 ? res.data : undefined;
  }

  static async createReservation(req: CreateReservationRequest): Promise<ApiResult<ReservationVO>> {
    if (ApiConfig.USE_MOCK) {
      const hotel = getMockHotelById(req.hotelId);
      const hotelName = hotel ? hotel.hotelName : '酒店';
      const newRes: ReservationVO = {
        id: 99,
        reservationNo: 'R20260599999',
        hotelId: req.hotelId,
        hotelName: hotelName,
        roomTypeName: '所选房型',
        checkInDate: req.checkInDate,
        checkOutDate: req.checkOutDate,
        totalAmount: 680,
        status: 'PENDING_PAYMENT',
        contactName: req.contactName,
        contactPhone: req.contactPhone
      };
      return createSuccessResult<ReservationVO>('success', newRes);
    }
    return HttpService.post<ReservationVO>('/reservations', req, true);
  }

  static async payReservation(reservationId: number, paymentMethod: string = 'SIMULATED'): Promise<ApiResult<PaymentVO>> {
    if (ApiConfig.USE_MOCK) {
      const mockPay: PaymentVO = {
        id: 1,
        reservationId: reservationId,
        amount: 0,
        paymentMethod: paymentMethod,
        paymentStatus: 'PAID'
      };
      return createSuccessResult<PaymentVO>('支付成功', mockPay);
    }

    const createRes = await HttpService.post<PaymentVO>('/payments',
      buildPaymentRequest(reservationId, paymentMethod), true);

    let paymentId = 0;
    if (createRes.code === 200 && createRes.data) {
      paymentId = createRes.data.id;
    } else if (createRes.message && createRes.message.indexOf('待支付') >= 0) {
      const existRes = await HttpService.get<PaymentVO>(`/payments/reservation/${reservationId}`, true);
      if (existRes.code === 200 && existRes.data) {
        paymentId = existRes.data.id;
      } else {
        return createFailResult<PaymentVO>(existRes.code, existRes.message || '获取支付记录失败');
      }
    } else {
      return createFailResult<PaymentVO>(createRes.code, createRes.message || '创建支付失败');
    }

    return HttpService.put<PaymentVO>(`/payments/${paymentId}/pay`, undefined, true);
  }

  static async getMyCollections(): Promise<CollectionVO[]> {
    if (ApiConfig.USE_MOCK) {
      return getMockCollectionList();
    }
    const res = await HttpService.get<PageResult<CollectionRecordVO>>('/collections/my?page=1&size=50', true);
    if (res.code !== 200 || !res.data) {
      return [];
    }
    const list: CollectionVO[] = [];
    const records = res.data.records;
    for (let i = 0; i < records.length; i++) {
      list.push(mapCollectionRecord(records[i]));
    }
    return list;
  }

  static async addCollection(hotelId: number): Promise<ApiResult<CollectionVO>> {
    if (ApiConfig.USE_MOCK) {
      const item = addMockCollection(hotelId);
      if (!item) {
        return createFailResult<CollectionVO>(400, '您已收藏过该酒店');
      }
      return createSuccessResult<CollectionVO>('收藏成功', item);
    }
    const res = await HttpService.post<CollectionRecordVO>('/collections', buildCollectionRequest(hotelId), true);
    if (res.code !== 200 || !res.data) {
      return createFailResult<CollectionVO>(res.code, res.message || '收藏失败');
    }
    return createSuccessResult<CollectionVO>('收藏成功', mapCollectionRecord(res.data));
  }

  static async removeCollection(collectionId: number): Promise<ApiResult<EmptyData>> {
    if (ApiConfig.USE_MOCK) {
      if (!removeMockCollection(collectionId)) {
        return createFailResult<EmptyData>(404, '收藏不存在');
      }
      return createEmptyApiResult('已取消收藏');
    }
    return HttpService.delete<EmptyData>(`/collections/${collectionId}`, true);
  }

  static async isHotelCollected(hotelId: number): Promise<boolean> {
    if (ApiConfig.USE_MOCK) {
      return isMockHotelCollected(hotelId);
    }
    const res = await HttpService.get<boolean>(`/collections/check?hotelId=${hotelId}`, true);
    return res.code === 200 && res.data === true;
  }

  static async getMyPosts(): Promise<PostVO[]> {
    if (ApiConfig.USE_MOCK) {
      return MOCK_POSTS;
    }
    const res = await HttpService.get<PageResult<PostRecordVO>>('/posts/my?page=1&size=50', true);
    if (res.code !== 200 || !res.data) {
      return [];
    }
    const list: PostVO[] = [];
    const records = res.data.records;
    for (let i = 0; i < records.length; i++) {
      list.push(mapPostRecord(records[i]));
    }
    return list;
  }

  static async createPost(req: CreatePostRequest): Promise<ApiResult<EmptyData>> {
    if (ApiConfig.USE_MOCK) {
      return createEmptyApiResult('发布成功');
    }
    return HttpService.post<EmptyData>('/posts', req, true);
  }

  static async getMyNotifications(): Promise<NotificationVO[]> {
    if (ApiConfig.USE_MOCK) {
      return MOCK_NOTIFICATIONS;
    }
    const res = await HttpService.get<PageResult<NotificationRecordVO>>('/notifications/my?page=1&size=50', true);
    if (res.code !== 200 || !res.data) {
      return [];
    }
    const list: NotificationVO[] = [];
    const records = res.data.records;
    for (let i = 0; i < records.length; i++) {
      list.push(mapNotificationRecord(records[i]));
    }
    return list;
  }

  static async markAllNotificationsRead(): Promise<void> {
    if (ApiConfig.USE_MOCK) {
      return;
    }
    await HttpService.put<EmptyData>('/notifications/read-all', undefined, true);
  }

  static async cancelAccount(password: string): Promise<ApiResult<EmptyData>> {
    if (ApiConfig.USE_MOCK) {
      return createEmptyApiResult('账号已注销');
    }
    return HttpService.put<EmptyData>('/users/cancel-account', { password: password }, true);
  }

  static async getReviewableReservations(): Promise<ReservationVO[]> {
    if (ApiConfig.USE_MOCK) {
      return [];
    }
    const res = await HttpService.get<ReservationVO[]>('/reservations/my/reviewable', true);
    return res.code === 200 && res.data ? res.data : [];
  }

  static async updateReservation(id: number, body: Record<string, Object>): Promise<ApiResult<ReservationVO>> {
    if (ApiConfig.USE_MOCK) {
      return createSuccessResult<ReservationVO>(MOCK_RESERVATIONS[0]);
    }
    return HttpService.put<ReservationVO>(`/reservations/${id}`, body, true);
  }

  static async getProfile(): Promise<UserProfileVO> {
    if (ApiConfig.USE_MOCK) {
      return getMockProfile();
    }
    const res = await HttpService.get<UserProfileVO>('/users/me', true);
    return res.code === 200 && res.data ? res.data : getMockProfile();
  }

  static async changePassword(oldPassword: string, newPassword: string): Promise<ApiResult<EmptyData>> {
    if (ApiConfig.USE_MOCK) {
      return createEmptyApiResult('密码修改成功');
    }
    return HttpService.put<EmptyData>('/users/change-password', buildChangePasswordRequest(oldPassword, newPassword), true);
  }

  static async forgotPassword(phone: string, newPassword: string): Promise<ApiResult<EmptyData>> {
    if (ApiConfig.USE_MOCK) {
      return createEmptyApiResult('密码已重置');
    }
    return HttpService.put<EmptyData>('/users/forgot-password', buildForgotPasswordRequest(phone, newPassword));
  }

  static async getAdminStats(): Promise<AdminStatsVO | null> {
    if (ApiConfig.USE_MOCK) {
      const stats: AdminStatsVO = {
        userCount: 3,
        hotelCount: 6,
        reservationCount: 2,
        postCount: 2,
        collectionCount: 2,
        paymentCount: 2,
        paidAmountTotal: 1360,
        pendingPostCount: 0,
        pendingReservationCount: 1
      };
      return stats;
    }
    const res = await HttpService.get<AdminStatsVO>('/admin/stats', true);
    return res.code === 200 && res.data ? res.data : null;
  }

  static async getAdminUsers(keyword: string = ''): Promise<AdminUserVO[]> {
    if (ApiConfig.USE_MOCK) {
      const list: AdminUserVO[] = [];
      for (let i = 0; i < MOCK_USERS.length; i++) {
        const u = MOCK_USERS[i];
        list.push({
          id: u.userId,
          username: u.username,
          phone: u.phone,
          role: u.role,
          status: 'NORMAL'
        });
      }
      return list;
    }
    let path = '/admin/users?page=1&size=50';
    if (keyword.length > 0) {
      path += `&keyword=${encodeURIComponent(keyword)}`;
    }
    const res = await HttpService.get<PageResult<AdminUserVO>>(path, true);
    return res.code === 200 && res.data ? res.data.records : [];
  }

  static async getAdminHotels(): Promise<HotelVO[]> {
    if (ApiConfig.USE_MOCK) {
      return MOCK_HOTELS;
    }
    const res = await HttpService.get<PageResult<HotelVO>>('/admin/hotels?page=1&size=50', true);
    if (res.code !== 200 || !res.data) {
      return [];
    }
    return res.data.records;
  }

  static async getAdminReservations(): Promise<ReservationVO[]> {
    if (ApiConfig.USE_MOCK) {
      return MOCK_RESERVATIONS;
    }
    const res = await HttpService.get<PageResult<ReservationVO>>('/admin/reservations?page=1&size=50', true);
    return res.code === 200 && res.data ? res.data.records : [];
  }

  static async getAdminPosts(): Promise<PostVO[]> {
    if (ApiConfig.USE_MOCK) {
      return MOCK_POSTS;
    }
    const res = await HttpService.get<PageResult<PostRecordVO>>('/admin/posts?page=1&size=50', true);
    if (res.code !== 200 || !res.data) {
      return [];
    }
    const list: PostVO[] = [];
    const records = res.data.records;
    for (let i = 0; i < records.length; i++) {
      list.push(mapPostRecord(records[i]));
    }
    return list;
  }

  static async getAdminPayments(): Promise<PaymentVO[]> {
    if (ApiConfig.USE_MOCK) {
      return [];
    }
    const res = await HttpService.get<PageResult<PaymentVO>>('/admin/payments?page=1&size=50', true);
    return res.code === 200 && res.data ? res.data.records : [];
  }

  static async getAdminCollections(): Promise<AdminCollectionVO[]> {
    if (ApiConfig.USE_MOCK) {
      return [];
    }
    const res = await HttpService.get<PageResult<AdminCollectionVO>>('/admin/collections?page=1&size=50', true);
    return res.code === 200 && res.data ? res.data.records : [];
  }

  static async getAdminNotifications(): Promise<NotificationVO[]> {
    if (ApiConfig.USE_MOCK) {
      return MOCK_NOTIFICATIONS;
    }
    const res = await HttpService.get<PageResult<NotificationRecordVO>>('/admin/notifications?page=1&size=50', true);
    if (res.code !== 200 || !res.data) {
      return [];
    }
    const list: NotificationVO[] = [];
    const records = res.data.records;
    for (let i = 0; i < records.length; i++) {
      list.push(mapNotificationRecord(records[i]));
    }
    return list;
  }

  static async updateAdminUserStatus(userId: number, status: string): Promise<ApiResult<EmptyData>> {
    const req: UpdateUserStatusRequest = { status: status };
    return HttpService.put<EmptyData>(`/admin/users/${userId}/status`, req, true);
  }

  static async createAdminHotel(req: AdminHotelRequest): Promise<ApiResult<HotelVO>> {
    return HttpService.post<HotelVO>('/admin/hotels', req, true);
  }

  static async updateAdminHotel(hotelId: number, req: AdminHotelRequest): Promise<ApiResult<HotelVO>> {
    return HttpService.put<HotelVO>(`/admin/hotels/${hotelId}`, req, true);
  }

  static async deleteAdminHotel(hotelId: number): Promise<ApiResult<EmptyData>> {
    return HttpService.delete<EmptyData>(`/admin/hotels/${hotelId}`, true);
  }

  static async approveAdminPost(postId: number, remark: string = ''): Promise<ApiResult<PostVO>> {
    const req: AuditRemarkRequest = { auditRemark: remark };
    return HttpService.put<PostVO>(`/admin/posts/${postId}/approve`, req, true);
  }

  static async rejectAdminPost(postId: number, remark: string = ''): Promise<ApiResult<PostVO>> {
    const req: AuditRemarkRequest = { auditRemark: remark };
    return HttpService.put<PostVO>(`/admin/posts/${postId}/reject`, req, true);
  }

  static async deleteAdminPost(postId: number): Promise<ApiResult<EmptyData>> {
    return HttpService.delete<EmptyData>(`/admin/posts/${postId}`, true);
  }

  static async approveAdminReservation(reservationId: number, remark: string = ''): Promise<ApiResult<ReservationVO>> {
    const req: AuditRemarkRequest = { auditRemark: remark };
    return HttpService.put<ReservationVO>(`/admin/reservations/${reservationId}/approve`, req, true);
  }

  static async rejectAdminReservation(reservationId: number, remark: string = ''): Promise<ApiResult<ReservationVO>> {
    const req: AuditRemarkRequest = { auditRemark: remark };
    return HttpService.put<ReservationVO>(`/admin/reservations/${reservationId}/reject`, req, true);
  }

  static async completeAdminPaymentRefund(paymentId: number): Promise<ApiResult<PaymentVO>> {
    return HttpService.put<PaymentVO>(`/admin/payments/${paymentId}/complete-refund`, undefined, true);
  }

  static async deleteAdminCollection(collectionId: number): Promise<ApiResult<EmptyData>> {
    return HttpService.delete<EmptyData>(`/admin/collections/${collectionId}`, true);
  }

  static async createAdminNotification(req: AdminCreateNotificationRequest): Promise<ApiResult<NotificationVO>> {
    return HttpService.post<NotificationVO>('/admin/notifications', req, true);
  }

  static async createAdminRoomType(hotelId: number, req: AdminCreateRoomTypeRequest): Promise<ApiResult<RoomTypeVO>> {
    return HttpService.post<RoomTypeVO>(`/admin/hotels/${hotelId}/room-types`, req, true);
  }

  static async updateAdminRoomType(roomTypeId: number, req: AdminUpdateRoomTypeRequest): Promise<ApiResult<RoomTypeVO>> {
    return HttpService.put<RoomTypeVO>(`/admin/room-types/${roomTypeId}`, req, true);
  }

  static async deleteAdminRoomType(roomTypeId: number): Promise<ApiResult<EmptyData>> {
    return HttpService.delete<EmptyData>(`/admin/room-types/${roomTypeId}`, true);
  }
}
export class AppUtil {
  static toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: 2000 });
  }

  static async confirm(message: string): Promise<boolean> {
    try {
      const result = await promptAction.showDialog({
        title: '请确认',
        message: message,
        buttons: [
          { text: '取消', color: '#64748B' },
          { text: '确定', color: '#EF4444' }
        ]
      });
      return result.index === 1;
    } catch (_e) {
      return false;
    }
  }

  static isAdminUser(): boolean {
    if (UserSession.getRole() === 'ADMIN') {
      return true;
    }
    return UserSession.getPhone() === ADMIN_PHONE;
  }

  static isAdminLoginUser(user: LoginUser): boolean {
    if (user.role === 'ADMIN') {
      return true;
    }
    return user.phone === ADMIN_PHONE;
  }

  static requireLogin(): boolean {
    if (!UserSession.isLoggedIn()) {
      AppUtil.toast('请先登录');
      router.replaceUrl({ url: 'pages/LoginPage' });
      return false;
    }
    return true;
  }

  static requireAdmin(): boolean {
    if (!AppUtil.requireLogin()) {
      return false;
    }
    if (!AppUtil.isAdminUser()) {
      AppUtil.toast('请使用管理员账号登录');
      router.replaceUrl({ url: 'pages/AdminLoginPage' });
      return false;
    }
    return true;
  }

  static routeAfterLogin(user: LoginUser): void {
    if (AppUtil.isAdminLoginUser(user)) {
      router.replaceUrl({ url: 'pages/AdminHomePage' });
      return;
    }
    router.replaceUrl({ url: 'pages/HomePage' });
  }

  static redirectIfAdmin(): boolean {
    if (AppUtil.isAdminUser()) {
      router.replaceUrl({ url: 'pages/AdminHomePage' });
      return true;
    }
    return false;
  }

  static userRoleText(role: string): string {
    if (role === 'ADMIN') {
      return '管理员';
    }
    if (role === 'CUSTOMER') {
      return '普通用户';
    }
    return role;
  }

  static userStatusText(status: string): string {
    if (status === 'NORMAL') {
      return '正常';
    }
    if (status === 'DISABLED') {
      return '已禁用';
    }
    return status;
  }

  static reservationStatusText(status: string): string {
    if (status === 'PENDING_PAYMENT') return '待付款';
    if (status === 'PAID') return '已支付';
    if (status === 'CONFIRMED') return '已确认';
    if (status === 'COMPLETED') return '已完成';
    if (status === 'CANCELLED') return '已取消';
    return status;
  }

  static reservationStatusColor(status: string): string {
    if (status === 'PENDING_PAYMENT') return '#EF4444';
    if (status === 'CONFIRMED') return '#2563EB';
    if (status === 'COMPLETED') return '#22C55E';
    if (status === 'CANCELLED') return '#94A3B8';
    return '#64748B';
  }

  static postAuditText(status: string): string {
    if (status === 'APPROVED') {
      return '已通过';
    }
    if (status === 'PENDING') {
      return '待审核';
    }
    if (status === 'REJECTED') {
      return '已拒绝';
    }
    return status;
  }

  static paymentStatusText(status: string): string {
    if (status === 'PAID') {
      return '已支付';
    }
    if (status === 'UNPAID') {
      return '未支付';
    }
    if (status === 'REFUNDING') {
      return '退款中';
    }
    if (status === 'REFUNDED') {
      return '已退款';
    }
    return status;
  }
}
