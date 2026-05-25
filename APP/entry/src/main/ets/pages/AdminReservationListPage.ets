import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { ReservationVO } from '../common/Types';

@Entry
@Component
struct AdminReservationListPage {
  @State reservations: ReservationVO[] = [];
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
    this.reservations = await HotelApi.getAdminReservations();
    this.isLoading = false;
  }

  private async approve(item: ReservationVO): Promise<void> {
    const res = await HotelApi.approveAdminReservation(item.id, '订单审核通过');
    if (res.code !== 200) {
      AppUtil.toast(res.message || '审核失败');
      return;
    }
    AppUtil.toast('已通过');
    this.loadData();
  }

  private async reject(item: ReservationVO): Promise<void> {
    const ok = await AppUtil.confirm('确认拒绝该订单？');
    if (!ok) {
      return;
    }
    const res = await HotelApi.rejectAdminReservation(item.id, '订单审核未通过');
    if (res.code !== 200) {
      AppUtil.toast(res.message || '操作失败');
      return;
    }
    AppUtil.toast('已拒绝');
    this.loadData();
  }

  build() {
    Column() {
      PageHeader({ title: '订单管理', showBack: true })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.reservations, (item: ReservationVO) => {
              Column({ space: 8 }) {
                Row() {
                  Text(item.hotelName).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#0F172A').layoutWeight(1)
                  Text(AppUtil.reservationStatusText(item.status))
                    .fontSize(12).fontColor(AppUtil.reservationStatusColor(item.status))
                }.width('100%')

                Text(`订单号：${item.reservationNo}`).fontSize(12).fontColor('#94A3B8').width('100%')
                Text(`用户：${item.username ?? item.contactName ?? '-'}`).fontSize(13).fontColor('#64748B').width('100%')
                Text(`${item.checkInDate} → ${item.checkOutDate}`).fontSize(13).fontColor('#64748B').width('100%')
                Text(`¥${item.totalAmount}`).fontSize(15).fontColor('#EF4444').fontWeight(FontWeight.Medium).width('100%')

                if (item.status === 'PAID') {
                  Row({ space: 8 }) {
                    Button('审核通过')
                      .height(32).fontSize(12).fontColor(Color.White).backgroundColor('#22C55E').layoutWeight(1)
                      .onClick(() => { this.approve(item); })
                    Button('拒绝')
                      .height(32).fontSize(12).fontColor(Color.White).backgroundColor('#EF4444').layoutWeight(1)
                      .onClick(() => { this.reject(item); })
                  }.width('100%')
                }
              }
              .width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
            }, (item: ReservationVO) => `r-${item.id}`)
          }.padding(16)
        }.layoutWeight(1).scrollBar(BarState.Off)
      }
    }.width('100%').height('100%').backgroundColor('#EEF2FF')
  }
}
