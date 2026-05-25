/**
 * 图片资源映射
 * 图片目录：entry/src/main/resources/base/media/
 */

function matchHotelName(name: string, keyword: string): boolean {
  return name.indexOf(keyword) >= 0;
}

/** 酒店 id / 名称 → 图片资源 */
export function getHotelImageRes(hotelId: number, hotelName: string = ''): Resource {
  const name = hotelName;
  if (matchHotelName(name, '西湖') || matchHotelName(name, '杭州')) {
    return $r('app.media.hangzhou_xihu');
  }
  if (matchHotelName(name, '外滩') || (matchHotelName(name, '上海') && hotelId <= 2)) {
    return $r('app.media.shanghai_waitan');
  }
  if (matchHotelName(name, '紫峰') || matchHotelName(name, '南京')) {
    return $r('app.media.zijin_tower');
  }
  if (matchHotelName(name, '北京') || matchHotelName(name, '三里屯')) {
    return $r('app.media.beijing');
  }
  if (matchHotelName(name, '广州') || matchHotelName(name, '珠江')) {
    return $r('app.media.guangzhou');
  }
  if (matchHotelName(name, '深圳') || matchHotelName(name, '深圳湾')) {
    return $r('app.media.shenzhen');
  }

  if (hotelId === 1) {
    return $r('app.media.hangzhou_xihu');
  }
  if (hotelId === 2) {
    return $r('app.media.shanghai_waitan');
  }
  if (hotelId === 3) {
    return $r('app.media.zijin_tower');
  }
  if (hotelId === 4) {
    return $r('app.media.beijing');
  }
  if (hotelId === 5) {
    return $r('app.media.guangzhou');
  }
  if (hotelId === 6) {
    return $r('app.media.shenzhen');
  }
  return $r('app.media.hangzhou_xihu');
}

export function hasHotelImage(_hotelId: number): boolean {
  return true;
}

/** Banner id → 图片资源（chunjing / dujia / chailv） */
export function getBannerImageRes(bannerId: number): Resource {
  if (bannerId === 1) {
    return $r('app.media.chunjing');
  }
  if (bannerId === 2) {
    return $r('app.media.dujia');
  }
  if (bannerId === 3) {
    return $r('app.media.chailv');
  }
  return $r('app.media.chunjing');
}

/** 用户默认头像 */
export function getUserAvatarRes(): Resource {
  return $r('app.media.yonghu');
}
