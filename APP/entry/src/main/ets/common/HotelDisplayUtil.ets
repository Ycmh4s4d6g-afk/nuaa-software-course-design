import { MOCK_HOTELS } from './MockData';
import { HotelVO } from './Types';

function isInvalidHotelName(name: string): boolean {
  if (name.length === 0) {
    return true;
  }
  if (name.indexOf('测试') >= 0) {
    return true;
  }
  if (name.indexOf('无登录') >= 0) {
    return true;
  }
  if (name.toLowerCase() === 'test') {
    return true;
  }
  return false;
}

function isInvalidHotelAddress(address: string): boolean {
  if (address.length === 0) {
    return false;
  }
  const lower = address.toLowerCase();
  if (lower === 'test') {
    return true;
  }
  return false;
}

/** 过滤服务器上的测试/脏数据酒店 */
export function filterDisplayHotels(list: HotelVO[]): HotelVO[] {
  const result: HotelVO[] = [];
  for (let i = 0; i < list.length; i++) {
    const hotel = list[i];
    const name = hotel.hotelName ?? '';
    const address = hotel.address ?? '';
    if (isInvalidHotelName(name)) {
      continue;
    }
    if (isInvalidHotelAddress(address)) {
      continue;
    }
    result.push(hotel);
  }
  return result;
}

function hasOfficialHotel(list: HotelVO[], mock: HotelVO): boolean {
  for (let i = 0; i < list.length; i++) {
    if (list[i].id === mock.id) {
      return true;
    }
    if (list[i].city === mock.city && list[i].hotelName.indexOf(mock.city.substring(0, 1)) >= 0) {
      return true;
    }
  }
  return false;
}

/** 用本地正式酒店数据补全展示（北京/广州/深圳等） */
export function enrichDisplayHotels(apiList: HotelVO[]): HotelVO[] {
  const filtered = filterDisplayHotels(apiList);
  const result: HotelVO[] = [];
  for (let i = 0; i < filtered.length; i++) {
    result.push(filtered[i]);
  }
  for (let i = 0; i < MOCK_HOTELS.length; i++) {
    const mock = MOCK_HOTELS[i];
    if (!hasOfficialHotel(result, mock)) {
      result.push(mock);
    }
  }
  return result;
}

export function sortHotelsByRating(list: HotelVO[]): HotelVO[] {
  const sorted = list.slice();
  for (let i = 0; i < sorted.length - 1; i++) {
    for (let j = 0; j < sorted.length - 1 - i; j++) {
      if (sorted[j].rating < sorted[j + 1].rating) {
        const temp = sorted[j];
        sorted[j] = sorted[j + 1];
        sorted[j + 1] = temp;
      }
    }
  }
  return sorted;
}
