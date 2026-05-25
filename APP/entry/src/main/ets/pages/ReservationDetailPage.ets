import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { ReservationVO } from '../common/Types';

@Entry
@Component
struct ReservationDetailPage {
  @State reservationId: number = 0;
  @State reservation: ReservationVO | null = null;
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.reservationId) {
      this.reservationId = parseInt(params.reservationId);
    }
    this.loadDetail();
  }

  private async loadDetail(): Promise<void> {
    this.isLoading = true;
    const detail = await HotelApi.getReservationDetail(this.reservationId);
    if (detail) {
      this.reservation = detail;
    }
    this.isLoading = false;
  }

  private goPay(): void {
    if (!this.reservation) {
      return;
    }
    router.pushUrl({
      url: 'pages/PaymentPage',
      params: {
        reservationId: `${this.reservation.id}`,
        totalAmount: `${this.reservation.totalAmount}`,
        hotelName: this.reservation.hotelName
      }
    });
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#94A3B8')
        .width(90)
      Text(value)
        .fontSize(14)
        .fontColor('#0F172A')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  build() {
    Column() {
      PageHeader({ title: '订单详情', showBack: true })

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#2563EB')
          .layoutWeight(1)
      } else if (!this.reservation) {
        Column() {
          Text('订单不存在')
            .fontSize(16)
            .fontColor('#64748B')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Column({ space: 8 }) {
              Text(this.reservation.hotelName)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#0F172A')

              Text(AppUtil.reservationStatusText(this.reservation.status))
                .fontSize(14)
                .fontColor(AppUtil.reservationStatusColor(this.reservation.status))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('#F8FAFC')
                .borderRadius(8)
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .alignItems(HorizontalAlign.Start)

            Column() {
              this.InfoRow('订单号', this.reservation.reservationNo)
              this.InfoRow('房型', this.reservation.roomTypeName)
              this.InfoRow('入住', this.reservation.checkInDate)
              this.InfoRow('离店', this.reservation.checkOutDate)
              if (this.reservation.contactName) {
                this.InfoRow('联系人', this.reservation.contactName)
              }
              if (this.reservation.contactPhone) {
                this.InfoRow('电话', this.reservation.contactPhone)
              }
              Divider().color('#F1F5F9')
              Row() {
                Text('订单金额')
                  .fontSize(14)
                  .fontColor('#94A3B8')
                Blank()
                Text(`¥${this.reservation.totalAmount}`)
                  .fontSize(24)
                  .fontColor('#EF4444')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .padding({ top: 12 })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .backgroundColor(Color.White)
            .borderRadius(16)
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 100 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        if (this.reservation.status === 'PENDING_PAYMENT') {
          Row({ space: 12 }) {
            Button('立即支付')
              .layoutWeight(1)
              .height(50)
              .fontSize(16)
              .fontColor(Color.White)
              .borderRadius(12)
              .linearGradient({ angle: 120, colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]] })
              .onClick(() => { this.goPay(); })
            Button('修改订单')
              .layoutWeight(1)
              .height(50)
              .fontSize(16)
              .fontColor('#2563EB')
              .backgroundColor('#EFF6FF')
              .borderRadius(12)
              .onClick(() => {
                router.pushUrl({ url: 'pages/EditReservationPage', params: { reservationId: `${this.reservation!.id}` } });
              })
          }
          .width('90%')
          .margin({ bottom: 24 })
        } else if (this.reservation.status === 'PAID') {
          Button('修改订单')
            .width('90%')
            .height(50)
            .fontSize(16)
            .fontColor('#2563EB')
            .backgroundColor('#EFF6FF')
            .borderRadius(12)
            .margin({ bottom: 24 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/EditReservationPage', params: { reservationId: `${this.reservation!.id}` } });
            })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
