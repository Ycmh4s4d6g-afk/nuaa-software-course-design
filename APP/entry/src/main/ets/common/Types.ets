/** 统一 API 响应 */
export interface ApiResult<T> {
  code: number;
  message: string;
  data?: T;
}

export interface EmptyData {
  ok: boolean;
}

export interface PageResult<T> {
  records: T[];
  total: number;
  page: number;
  size: number;
}

export interface LoginUser {
  userId: number;
  username: string;
  phone: string;
  role: string;
  token?: string;
}

export interface LoginRequest {
  phone: string;
  password: string;
}

export interface RegisterRequest {
  phone: string;
  password: string;
  username: string;
}

export interface ChangePasswordRequest {
  oldPassword: string;
  newPassword: string;
}

export interface ForgotPasswordRequest {
  phone: string;
  newPassword: string;
}

export interface HotelVO {
  id: number;
  hotelName: string;
  city: string;
  hotelType: string;
  rating: number;
  minPrice: number;
  collectionCount?: number;
  address?: string;
  phone?: string;
  description?: string;
  imageColorStart?: string;
  imageColorEnd?: string;
  imageEmoji?: string;
  tag?: string;
  imageRes?: Resource;
  contactPhone?: string;
  coverImageUrl?: string;
  isReservable?: number;
  facilities?: string;
}

export interface AdminHotelRequest {
  hotelName: string;
  hotelType: string;
  city: string;
  address: string;
  description?: string;
  facilities?: string;
  contactPhone?: string;
  coverImageUrl?: string;
  rating: number;
  minPrice: number;
  isReservable?: number;
}

export interface AuditRemarkRequest {
  auditRemark?: string;
}

export interface UpdateUserStatusRequest {
  status: string;
}

export interface AdminCreateNotificationRequest {
  userId: number;
  reservationId?: number;
  title: string;
  content: string;
  type: string;
  channel?: string;
}

export interface AdminCreateRoomTypeRequest {
  roomTypeName: string;
  bedType?: string;
  capacity: number;
  totalRooms: number;
  price: number;
  breakfastIncluded?: number;
  description?: string;
}

export interface AdminUpdateRoomTypeRequest {
  roomTypeName: string;
  bedType?: string;
  capacity: number;
  totalRooms: number;
  availableRooms: number;
  price: number;
  breakfastIncluded?: number;
  description?: string;
  status?: string;
}

export interface RoomTypeVO {
  id: number;
  hotelId: number;
  roomName: string;
  bedType: string;
  maxGuests: number;
  price: number;
  stock: number;
  description?: string;
  totalRooms?: number;
  status?: string;
}

export interface ReservationVO {
  id: number;
  reservationNo: string;
  hotelId: number;
  hotelName: string;
  roomTypeName: string;
  checkInDate: string;
  checkOutDate: string;
  totalAmount: number;
  status: string;
  contactName?: string;
  contactPhone?: string;
  username?: string;
}

export interface CollectionVO {
  id: number;
  hotelId: number;
  hotelName: string;
  city: string;
  minPrice: number;
  rating: number;
}

/** 服务端收藏列表嵌套酒店信息 */
export interface CollectionHotelVO {
  id: number;
  hotelName: string;
  city: string;
  hotelType?: string;
  rating: number;
  minPrice: number;
}

export interface CollectionRecordVO {
  id: number;
  hotelId: number;
  hotel?: CollectionHotelVO;
}

export interface CreateCollectionRequest {
  hotelId: number;
}

/** Mock 本地注册用户 */
export interface MockRegisteredUser {
  userId: number;
  username: string;
  phone: string;
  password: string;
  role: string;
}

export interface AdminStatsVO {
  userCount: number;
  hotelCount: number;
  reservationCount: number;
  postCount: number;
  collectionCount: number;
  paymentCount: number;
  paidAmountTotal: number;
  pendingPostCount: number;
  pendingReservationCount: number;
  approvedPostCount?: number;
  rejectedPostCount?: number;
  todayReservationCount?: number;
  todayPaidAmount?: number;
  paymentMethodStats?: PaymentMethodStatVO[];
}

export interface PaymentMethodStatVO {
  paymentMethod: string;
  count: number;
  amount: number;
}

export interface AdminUserVO {
  id: number;
  username: string;
  phone: string;
  email?: string;
  role: string;
  status: string;
}

export interface AdminCollectionVO {
  id: number;
  userId: number;
  username: string;
  hotelId: number;
  hotelName: string;
  createTime?: string;
  hotel?: CollectionHotelVO;
}

export interface PostVO {
  id: number;
  title: string;
  content: string;
  hotelName: string;
  username: string;
  rating: number;
  auditStatus: string;
  createTime?: string;
}

export interface NotificationVO {
  id: number;
  title: string;
  content: string;
  isRead: boolean;
  createTime: string;
  userId?: number;
  username?: string;
  status?: string;
}

export interface UserProfileVO {
  userId: number;
  username: string;
  phone: string;
  email?: string;
  gender?: string;
  role: string;
}

export interface BannerItem {
  id: number;
  title: string;
  subtitle: string;
  colorStart: string;
  colorEnd: string;
}

export interface SelectOptionItem {
  value: string;
}

export interface CreateReservationRequest {
  hotelId: number;
  roomTypeId: number;
  checkInDate: string;
  checkOutDate: string;
  guestCount: number;
  contactName: string;
  contactPhone: string;
}

export interface CreatePaymentRequest {
  reservationId: number;
  paymentMethod: string;
}

export interface PaymentVO {
  id: number;
  reservationId: number;
  amount: number;
  paymentMethod: string;
  paymentStatus: string;
  paymentNo?: string;
  reservationNo?: string;
  userId?: number;
  username?: string;
  hotelName?: string;
}

export interface CreatePostRequest {
  hotelId: number;
  reservationId: number;
  title: string;
  content: string;
  score: number;
}

/** 构造空酒店对象（ArkTS 禁止匿名对象字面量作默认值） */
export function createEmptyHotel(): HotelVO {
  const hotel: HotelVO = {
    id: 0,
    hotelName: '',
    city: '',
    hotelType: '',
    rating: 0,
    minPrice: 0
  };
  return hotel;
}

/** 构造空 API 成功响应 */
export function createEmptyApiResult(message: string): ApiResult<EmptyData> {
  const data: EmptyData = { ok: true };
  const result: ApiResult<EmptyData> = { code: 200, message: message, data: data };
  return result;
}

/** 构造 API 失败响应（无 data） */
export function createFailResult<T>(code: number, message: string): ApiResult<T> {
  const result: ApiResult<T> = { code: code, message: message };
  return result;
}

/** 构造 API 成功响应 */
export function createSuccessResult<T>(message: string, data: T): ApiResult<T> {
  const result: ApiResult<T> = { code: 200, message: message, data: data };
  return result;
}
