import {
  BannerItem, CollectionVO, HotelVO, LoginUser, NotificationVO,
  PostVO, ReservationVO, RoomTypeVO, SelectOptionItem, UserProfileVO
} from './Types';

export const CITY_LIST: string[] = ['上海', '北京', '南京', '杭州', '广州', '深圳'];

export function buildCitySelectOptions(): SelectOptionItem[] {
  const options: SelectOptionItem[] = [];
  for (let i = 0; i < CITY_LIST.length; i++) {
    const item: SelectOptionItem = { value: CITY_LIST[i] };
    options.push(item);
  }
  return options;
}

export const CITY_SELECT_OPTIONS: SelectOptionItem[] = buildCitySelectOptions();

export const BANNER_LIST: BannerItem[] = [
  { id: 1, title: '春季出行特惠', subtitle: '精选高星酒店 · 限时优惠', colorStart: '#2563EB', colorEnd: '#7C3AED' },
  { id: 2, title: '周末轻奢度假', subtitle: '近郊精品酒店推荐', colorStart: '#0EA5E9', colorEnd: '#2563EB' },
  { id: 3, title: '商务差旅优选', subtitle: '近地铁 · 含早餐 · 免费取消', colorStart: '#F97316', colorEnd: '#EF4444' }
];

export const MOCK_USERS: LoginUser[] = [
  { userId: 2, username: '张三', phone: '13900000001', role: 'CUSTOMER' },
  { userId: 3, username: '李四', phone: '13900000002', role: 'CUSTOMER' },
  { userId: 1, username: '管理员', phone: '13800000000', role: 'ADMIN' }
];

export const MOCK_HOTELS: HotelVO[] = [
  {
    id: 1, hotelName: '杭州西湖湖景酒店', city: '杭州', hotelType: '度假', rating: 4.8, minPrice: 399,
    collectionCount: 520, address: '杭州市西湖区北山街1号', phone: '0571-88880001',
    description: '靠近西湖景区，适合旅游入住。',
    imageColorStart: '#047857', imageColorEnd: '#34D399', imageEmoji: '🌿', tag: '湖景'
  },
  {
    id: 2, hotelName: '上海外滩商务酒店', city: '上海', hotelType: '商务', rating: 4.6, minPrice: 499,
    collectionCount: 890, address: '上海市黄浦区中山东一路88号', phone: '021-66660001',
    description: '靠近外滩和地铁站，适合商务出行。',
    imageColorStart: '#1E3A8A', imageColorEnd: '#3B82F6', imageEmoji: '🏨', tag: '江景'
  },
  {
    id: 3, hotelName: '紫峰大厦城市酒店', city: '南京', hotelType: '商务', rating: 4.5, minPrice: 359,
    collectionCount: 410, address: '南京市鼓楼区中山北路1号', phone: '025-55550001',
    description: '位于城市中心，交通便利。',
    imageColorStart: '#065F46', imageColorEnd: '#10B981', imageEmoji: '🏙️', tag: '地标'
  },
  {
    id: 4, hotelName: '北京三里屯洲际酒店', city: '北京', hotelType: '高档', rating: 4.8, minPrice: 899,
    collectionCount: 760, address: '北京市朝阳区三里屯路1号', phone: '010-65918888',
    description: '潮流商圈核心，购物餐饮一应俱全。',
    imageColorStart: '#7C2D12', imageColorEnd: '#EA580C', imageEmoji: '🌆', tag: '商圈'
  },
  {
    id: 5, hotelName: '广州珠江新城W酒店', city: '广州', hotelType: '豪华', rating: 4.8, minPrice: 1188,
    collectionCount: 630, address: '广州市天河区珠江新城', phone: '020-66288888',
    description: '珠江新城CBD，现代设计感十足。',
    imageColorStart: '#581C87', imageColorEnd: '#A855F7', imageEmoji: '✨', tag: '网红'
  },
  {
    id: 6, hotelName: '深圳湾安达仕酒店', city: '深圳', hotelType: '高档', rating: 4.6, minPrice: 988,
    collectionCount: 540, address: '深圳市南山区科苑南路2600号', phone: '0755-88889999',
    description: '深圳湾一线海景，品质住宿体验。',
    imageColorStart: '#0F172A', imageColorEnd: '#475569', imageEmoji: '🌊', tag: '海景'
  }
];

export const MOCK_ROOM_TYPES: RoomTypeVO[] = [
  { id: 1, hotelId: 1, roomName: '豪华湖景大床房', bedType: '大床1.8m', maxGuests: 2, price: 680, stock: 5, description: '西湖景观，含双早' },
  { id: 2, hotelId: 1, roomName: '行政套房', bedType: '大床2.0m', maxGuests: 3, price: 1280, stock: 2, description: '独立客厅，行政礼遇' },
  { id: 3, hotelId: 2, roomName: '外滩景观房', bedType: '大床2.0m', maxGuests: 2, price: 1688, stock: 3, description: '正面外滩江景' },
  { id: 4, hotelId: 3, roomName: '商务标准间', bedType: '双床1.2m', maxGuests: 2, price: 359, stock: 10, description: '高性价比商务房' },
  { id: 5, hotelId: 4, roomName: '时尚大床房', bedType: '大床1.8m', maxGuests: 2, price: 899, stock: 6, description: '三里屯核心位置' }
];

export const MOCK_RESERVATIONS: ReservationVO[] = [
  {
    id: 1, reservationNo: 'R20260501001', hotelId: 1, hotelName: '杭州西湖国宾馆',
    roomTypeName: '豪华湖景大床房', checkInDate: '2026-06-01', checkOutDate: '2026-06-03',
    totalAmount: 1360, status: 'CONFIRMED', contactName: '张三', contactPhone: '13900000001'
  },
  {
    id: 2, reservationNo: 'R20260501002', hotelId: 3, hotelName: '紫峰大厦城市酒店',
    roomTypeName: '商务标准间', checkInDate: '2026-06-10', checkOutDate: '2026-06-11',
    totalAmount: 359, status: 'PENDING_PAYMENT', contactName: '张三', contactPhone: '13900000001'
  }
];

export const MOCK_COLLECTIONS: CollectionVO[] = [
  { id: 1, hotelId: 2, hotelName: '上海外滩华尔道夫酒店', city: '上海', minPrice: 1688, rating: 4.9 },
  { id: 2, hotelId: 3, hotelName: '紫峰大厦城市酒店', city: '南京', minPrice: 359, rating: 4.5 }
];

let mockCollectionList: CollectionVO[] = MOCK_COLLECTIONS.slice();
let mockCollectionNextId: number = 100;

export function getMockCollectionList(): CollectionVO[] {
  return mockCollectionList.slice();
}

export function addMockCollection(hotelId: number): CollectionVO | null {
  for (let i = 0; i < mockCollectionList.length; i++) {
    if (mockCollectionList[i].hotelId === hotelId) {
      return null;
    }
  }
  const hotel = getMockHotelById(hotelId);
  if (!hotel) {
    return null;
  }
  const item: CollectionVO = {
    id: mockCollectionNextId++,
    hotelId: hotel.id,
    hotelName: hotel.hotelName,
    city: hotel.city,
    minPrice: hotel.minPrice,
    rating: hotel.rating
  };
  mockCollectionList.push(item);
  return item;
}

export function removeMockCollection(collectionId: number): boolean {
  const next: CollectionVO[] = [];
  let removed = false;
  for (let i = 0; i < mockCollectionList.length; i++) {
    if (mockCollectionList[i].id === collectionId) {
      removed = true;
    } else {
      next.push(mockCollectionList[i]);
    }
  }
  mockCollectionList = next;
  return removed;
}

export function isMockHotelCollected(hotelId: number): boolean {
  for (let i = 0; i < mockCollectionList.length; i++) {
    if (mockCollectionList[i].hotelId === hotelId) {
      return true;
    }
  }
  return false;
}

export const MOCK_POSTS: PostVO[] = [
  {
    id: 1, title: '西湖边的完美周末', content: '环境非常好，服务也很周到，强烈推荐！',
    hotelName: '杭州西湖国宾馆', username: '张三', rating: 5, auditStatus: 'APPROVED', createTime: '2026-05-20 14:30'
  },
  {
    id: 2, title: '商务出差好选择', content: '交通便利，房间干净整洁，性价比不错。',
    hotelName: '紫峰大厦城市酒店', username: '李四', rating: 4, auditStatus: 'APPROVED', createTime: '2026-05-18 09:15'
  }
];

export const MOCK_NOTIFICATIONS: NotificationVO[] = [
  { id: 1, title: '订单已确认', content: '您的订单 R20260501001 已确认，祝您入住愉快。', isRead: false, createTime: '2026-05-22 10:00' },
  { id: 2, title: '支付提醒', content: '您有一笔待支付订单，请尽快完成支付。', isRead: true, createTime: '2026-05-21 16:30' }
];

export function getMockHotelById(id: number): HotelVO | undefined {
  for (let i = 0; i < MOCK_HOTELS.length; i++) {
    if (MOCK_HOTELS[i].id === id) {
      return MOCK_HOTELS[i];
    }
  }
  return undefined;
}

export function getMockRoomTypes(hotelId: number): RoomTypeVO[] {
  const list: RoomTypeVO[] = [];
  for (let i = 0; i < MOCK_ROOM_TYPES.length; i++) {
    if (MOCK_ROOM_TYPES[i].hotelId === hotelId) {
      list.push(MOCK_ROOM_TYPES[i]);
    }
  }
  return list;
}

export function getMockReservationById(id: number): ReservationVO | undefined {
  for (let i = 0; i < MOCK_RESERVATIONS.length; i++) {
    if (MOCK_RESERVATIONS[i].id === id) {
      return MOCK_RESERVATIONS[i];
    }
  }
  return undefined;
}

export function getMockProfile(): UserProfileVO {
  return {
    userId: 2,
    username: '张三',
    phone: '13900000001',
    email: 'zhangsan@example.com',
    gender: '男',
    role: 'CUSTOMER'
  };
}
