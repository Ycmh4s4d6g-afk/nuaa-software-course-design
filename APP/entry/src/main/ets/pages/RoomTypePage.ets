import router from '@ohos.router';
import { HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { RoomTypeVO } from '../common/Types';

@Entry
@Component
struct RoomTypePage {
  @State hotelId: number = 0;
  @State hotelName: string = '';
  @State roomTypes: RoomTypeVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      if (params.hotelId) {
        this.hotelId = parseInt(params.hotelId);
      }
      this.hotelName = params.hotelName ?? '';
    }
    this.loadRoomTypes();
  }

  private async loadRoomTypes(): Promise<void> {
    this.isLoading = true;
    this.roomTypes = await HotelApi.getRoomTypes(this.hotelId);
    this.isLoading = false;
  }

  private bookRoom(rt: RoomTypeVO): void {
    router.pushUrl({
      url: 'pages/CreateReservationPage',
      params: {
        hotelId: `${this.hotelId}`,
        roomTypeId: `${rt.id}`,
        hotelName: this.hotelName,
        roomName: rt.roomName,
        price: `${rt.price}`,
        maxStock: `${rt.stock}`
      }
    });
  }

  @Builder
  RoomCard(rt: RoomTypeVO) {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 6 }) {
          Text(rt.roomName)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          Text(`${rt.bedType} · 最多 ${rt.maxGuests} 人`)
            .fontSize(13)
            .fontColor('#64748B')
          if (rt.description) {
            Text(rt.description)
              .fontSize(12)
              .fontColor('#94A3B8')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text(`¥${rt.price}`)
            .fontSize(22)
            .fontColor('#EF4444')
            .fontWeight(FontWeight.Bold)
          Text('/ 晚')
            .fontSize(11)
            .fontColor('#94A3B8')
          Text(`余 ${rt.stock} 间`)
            .fontSize(11)
            .fontColor(rt.stock > 0 ? '#22C55E' : '#EF4444')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Button('预订此房型')
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontColor(Color.White)
        .borderRadius(12)
        .enabled(rt.stock > 0)
        .linearGradient({
          angle: 120,
          colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
        })
        .onClick(() => {
          this.bookRoom(rt);
        })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 12, color: 'rgba(15,23,42,0.06)', offsetY: 4 })
  }

  build() {
    Column() {
      PageHeader({ title: '选择房型', showBack: true })

      if (this.hotelName.length > 0) {
        Text(this.hotelName)
          .fontSize(14)
          .fontColor('#64748B')
          .width('100%')
          .padding({ left: 20, top: 8, bottom: 8 })
          .backgroundColor(Color.White)
      }

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#2563EB')
          .layoutWeight(1)
      } else if (this.roomTypes.length === 0) {
        Column({ space: 8 }) {
          Text('暂无可用房型')
            .fontSize(16)
            .fontColor('#64748B')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.roomTypes, (rt: RoomTypeVO) => {
              this.RoomCard(rt)
            }, (rt: RoomTypeVO) => `rt-${rt.id}`)
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
