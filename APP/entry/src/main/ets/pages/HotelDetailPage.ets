import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { HotelCover } from '../common/HotelComponents';
import { PageHeader } from '../common/PageHeader';
import { HotelVO, RoomTypeVO } from '../common/Types';
import { UserSession } from '../common/UserSession';

@Entry
@Component
struct HotelDetailPage {
  @State hotelId: number = 0;
  @State hotel: HotelVO | null = null;
  @State roomTypes: RoomTypeVO[] = [];
  @State isLoading: boolean = true;
  @State isCollected: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.hotelId) {
      this.hotelId = parseInt(params.hotelId);
    }
    this.loadDetail();
  }

  private async loadDetail(): Promise<void> {
    this.isLoading = true;
    const detail = await HotelApi.getHotelDetail(this.hotelId);
    if (detail) {
      this.hotel = detail;
      this.roomTypes = await HotelApi.getRoomTypes(this.hotelId);
      if (UserSession.isLoggedIn()) {
        this.isCollected = await HotelApi.isHotelCollected(this.hotelId);
      }
    }
    this.isLoading = false;
  }

  private goRoomTypes(): void {
    router.pushUrl({
      url: 'pages/RoomTypePage',
      params: { hotelId: `${this.hotelId}`, hotelName: this.hotel?.hotelName ?? '' }
    });
  }

  private goBook(): void {
    if (this.roomTypes.length > 0) {
      const rt = this.roomTypes[0];
      router.pushUrl({
        url: 'pages/CreateReservationPage',
        params: {
          hotelId: `${this.hotelId}`,
          roomTypeId: `${rt.id}`,
          hotelName: this.hotel?.hotelName ?? '',
          roomName: rt.roomName,
          price: `${rt.price}`
        }
      });
    } else {
      AppUtil.toast('暂无可用房型');
    }
  }

  private async collectHotel(): Promise<void> {
    if (!AppUtil.requireLogin()) {
      return;
    }
    if (this.isCollected) {
      AppUtil.toast('您已收藏该酒店');
      return;
    }
    const res = await HotelApi.addCollection(this.hotelId);
    if (res.code !== 200) {
      AppUtil.toast(res.message || '收藏失败');
      return;
    }
    this.isCollected = true;
    AppUtil.toast('已加入收藏');
  }

  @Builder
  RoomPreviewItem(rt: RoomTypeVO) {
    Row() {
      Column({ space: 4 }) {
        Text(rt.roomName)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#0F172A')
        Text(`${rt.bedType} · 最多${rt.maxGuests}人`)
          .fontSize(12)
          .fontColor('#64748B')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(`¥${rt.price}`)
        .fontSize(18)
        .fontColor('#EF4444')
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#F8FAFC')
    .borderRadius(12)
    .margin({ bottom: 8 })
  }

  build() {
    Column() {
      PageHeader({ title: '酒店详情', showBack: true })

      if (this.isLoading || !this.hotel) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#2563EB')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            HotelCover({ hotel: this.hotel!, coverHeight: 200, radius: 16 })
              .margin({ left: 16, right: 16 })

            Column({ space: 10 }) {
              Text(this.hotel.hotelName)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#0F172A')

              Row({ space: 12 }) {
                Text(`⭐ ${this.hotel.rating}`)
                  .fontSize(14)
                  .fontColor('#F97316')
                Text(`${this.hotel.city} · ${this.hotel.hotelType}`)
                  .fontSize(13)
                  .fontColor('#64748B')
              }

              if (this.hotel.address) {
                Text(`📍 ${this.hotel.address}`)
                  .fontSize(13)
                  .fontColor('#64748B')
              }

              if (this.hotel.phone) {
                Text(`📞 ${this.hotel.phone}`)
                  .fontSize(13)
                  .fontColor('#64748B')
              }

              if (this.hotel.description) {
                Text(this.hotel.description)
                  .fontSize(14)
                  .fontColor('#475569')
                  .lineHeight(22)
                  .margin({ top: 8 })
              }

              Row() {
                Text('¥')
                  .fontSize(14)
                  .fontColor('#EF4444')
                Text(`${this.hotel.minPrice}`)
                  .fontSize(28)
                  .fontColor('#EF4444')
                  .fontWeight(FontWeight.Bold)
                Text(' 起 / 晚')
                  .fontSize(13)
                  .fontColor('#94A3B8')
              }
              .margin({ top: 8 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .alignItems(HorizontalAlign.Start)
            .shadow({ radius: 12, color: 'rgba(15,23,42,0.06)', offsetY: 4 })

            Column({ space: 12 }) {
              Row() {
                Text('房型预览')
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#0F172A')
                Blank()
                Text('查看全部 →')
                  .fontSize(13)
                  .fontColor('#2563EB')
                  .onClick(() => {
                    this.goRoomTypes();
                  })
              }
              .width('100%')

              ForEach(this.roomTypes.slice(0, 2), (rt: RoomTypeVO) => {
                this.RoomPreviewItem(rt)
              }, (rt: RoomTypeVO) => `rp-${rt.id}`)
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .alignItems(HorizontalAlign.Start)
          }
          .padding({ bottom: 100 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        Row({ space: 12 }) {
          Button(this.isCollected ? '❤️ 已收藏' : '❤️ 收藏')
            .layoutWeight(1)
            .height(48)
            .fontSize(14)
            .fontColor(this.isCollected ? '#94A3B8' : '#2563EB')
            .backgroundColor(this.isCollected ? '#F1F5F9' : '#EFF6FF')
            .borderRadius(12)
            .enabled(!this.isCollected)
            .onClick(() => {
              this.collectHotel();
            })

          Button('查看房型')
            .layoutWeight(1)
            .height(48)
            .fontSize(14)
            .fontColor('#2563EB')
            .backgroundColor('#EFF6FF')
            .borderRadius(12)
            .onClick(() => {
              this.goRoomTypes();
            })

          Button('立即预订')
            .layoutWeight(1.2)
            .height(48)
            .fontSize(15)
            .fontColor(Color.White)
            .borderRadius(12)
            .linearGradient({
              angle: 120,
              colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
            })
            .onClick(() => {
              this.goBook();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
        .backgroundColor(Color.White)
        .shadow({ radius: 12, color: 'rgba(15,23,42,0.08)', offsetY: -4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
