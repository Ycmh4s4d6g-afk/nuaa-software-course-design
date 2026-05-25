import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { BottomTabBar } from '../common/BottomTabBar';
import { ReservationVO } from '../common/Types';

@Entry
@Component
struct ReservationListPage {
  @State reservations: ReservationVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppUtil.redirectIfAdmin()) {
      return;
    }
    if (!AppUtil.requireLogin()) {
      return;
    }
    this.loadReservations();
  }

  private async loadReservations(): Promise<void> {
    this.isLoading = true;
    this.reservations = await HotelApi.getMyReservations();
    this.isLoading = false;
  }

  @Builder
  ReservationCard(item: ReservationVO) {
    Column({ space: 10 }) {
      Row() {
        Text(item.hotelName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(AppUtil.reservationStatusText(item.status))
          .fontSize(12)
          .fontColor(AppUtil.reservationStatusColor(item.status))
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('#F8FAFC')
          .borderRadius(999)
      }
      .width('100%')

      Text(item.roomTypeName)
        .fontSize(13)
        .fontColor('#64748B')
        .width('100%')

      Text(`${item.checkInDate} → ${item.checkOutDate}`)
        .fontSize(13)
        .fontColor('#64748B')
        .width('100%')

      Row() {
        Text(`订单号 ${item.reservationNo}`)
          .fontSize(11)
          .fontColor('#94A3B8')
        Blank()
        Text('¥')
          .fontSize(12)
          .fontColor('#EF4444')
        Text(`${item.totalAmount}`)
          .fontSize(20)
          .fontColor('#EF4444')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 12, color: 'rgba(15,23,42,0.06)', offsetY: 4 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/ReservationDetailPage',
        params: { reservationId: `${item.id}` }
      });
    })
  }

  build() {
    Column() {
      Column() {
        Text('我的订单')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')
        Text('查看与管理您的预订记录')
          .fontSize(13)
          .fontColor('#64748B')
          .margin({ top: 6 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 20, right: 20, top: 48, bottom: 16 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#2563EB')
          .layoutWeight(1)
      } else if (this.reservations.length === 0) {
        Column({ space: 12 }) {
          Text('暂无订单')
            .fontSize(16)
            .fontColor('#64748B')
          Text('完成预订后，订单将显示在这里')
            .fontSize(13)
            .fontColor('#94A3B8')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.reservations, (item: ReservationVO) => {
              this.ReservationCard(item)
            }, (item: ReservationVO) => `res-${item.id}`)
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      BottomTabBar({ currentIndex: 1 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
