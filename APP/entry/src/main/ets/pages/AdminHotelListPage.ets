import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { HotelCover } from '../common/HotelComponents';
import { PageHeader } from '../common/PageHeader';
import { HotelVO } from '../common/Types';

@Entry
@Component
struct AdminHotelListPage {
  @State hotels: HotelVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (!AppUtil.requireAdmin()) {
      return;
    }
    this.loadData();
  }

  onPageShow(): void {
    if (AppUtil.isAdminUser()) {
      this.loadData();
    }
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;
    this.hotels = await HotelApi.getAdminHotels();
    this.isLoading = false;
  }

  private goRoomTypes(hotel: HotelVO): void {
    router.pushUrl({
      url: 'pages/AdminRoomTypeListPage',
      params: { hotelId: `${hotel.id}`, hotelName: hotel.hotelName }
    });
  }

  private goEdit(hotelId: number): void {
    router.pushUrl({
      url: 'pages/AdminHotelEditPage',
      params: { hotelId: `${hotelId}` }
    });
  }

  private async deleteHotel(hotel: HotelVO): Promise<void> {
    const ok = await AppUtil.confirm(`确认删除「${hotel.hotelName}」？`);
    if (!ok) {
      return;
    }
    const res = await HotelApi.deleteAdminHotel(hotel.id);
    if (res.code !== 200) {
      AppUtil.toast(res.message || '删除失败');
      return;
    }
    AppUtil.toast('已删除');
    this.loadData();
  }

  build() {
    Column() {
      PageHeader({ title: '酒店管理', showBack: true })

      Row() {
        Button('+ 新增酒店')
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#22C55E')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/AdminHotelEditPage', params: { hotelId: '0' } });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.hotels, (hotel: HotelVO) => {
              Column({ space: 8 }) {
                HotelCover({ hotel: hotel, coverHeight: 120, radius: 10 })

                Text(hotel.hotelName + (hotel.isReservable === 0 ? '（已下架）' : ''))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#0F172A')
                  .width('100%')

                Text(`${hotel.city} · ${hotel.hotelType}`)
                  .fontSize(13)
                  .fontColor('#64748B')
                  .width('100%')

                Row() {
                  Text(`⭐ ${hotel.rating}`)
                    .fontSize(13)
                    .fontColor('#F97316')
                  Blank()
                  Text(`¥${hotel.minPrice} 起`)
                    .fontSize(14)
                    .fontColor('#EF4444')
                }
                .width('100%')

                Row({ space: 8 }) {
                  Button('房型')
                    .height(32)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .backgroundColor('#0EA5E9')
                    .layoutWeight(1)
                    .onClick(() => {
                      this.goRoomTypes(hotel);
                    })
                  Button('编辑')
                    .height(32)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .backgroundColor('#2563EB')
                    .layoutWeight(1)
                    .onClick(() => {
                      this.goEdit(hotel.id);
                    })
                  Button('删除')
                    .height(32)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .backgroundColor('#EF4444')
                    .layoutWeight(1)
                    .onClick(() => {
                      this.deleteHotel(hotel);
                    })
                }
                .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(12)
            }, (hotel: HotelVO) => `h-${hotel.id}`)
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF2FF')
  }
}
