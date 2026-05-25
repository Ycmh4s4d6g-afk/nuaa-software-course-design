import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { PaymentVO } from '../common/Types';

@Entry
@Component
struct AdminPaymentListPage {
  @State payments: PaymentVO[] = [];
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
    this.payments = await HotelApi.getAdminPayments();
    this.isLoading = false;
  }

  private async completeRefund(paymentId: number): Promise<void> {
    const ok = await AppUtil.confirm('确认完成退款？');
    if (!ok) {
      return;
    }
    const res = await HotelApi.completeAdminPaymentRefund(paymentId);
    if (res.code !== 200) {
      AppUtil.toast(res.message || '操作失败');
      return;
    }
    AppUtil.toast('退款已完成');
    this.loadData();
  }

  build() {
    Column() {
      PageHeader({ title: '支付记录', showBack: true })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.payments, (item: PaymentVO) => {
              Column({ space: 6 }) {
                Text(item.paymentNo ?? `支付#${item.id}`)
                  .fontSize(15).fontWeight(FontWeight.Bold).fontColor('#0F172A').width('100%')
                Text(`用户：${item.username ?? item.userId ?? '-'}`)
                  .fontSize(13).fontColor('#64748B').width('100%')
                Text(`订单：${item.reservationNo ?? item.reservationId}`)
                  .fontSize(13).fontColor('#64748B').width('100%')
                Text(`金额：¥${item.amount} · ${AppUtil.paymentStatusText(item.paymentStatus)}`)
                  .fontSize(13).fontColor('#EF4444').width('100%')

                if (item.paymentStatus === 'REFUNDING') {
                  Button('完成退款')
                    .height(32).fontSize(12).fontColor(Color.White).backgroundColor('#EF4444')
                    .onClick(() => { this.completeRefund(item.id); })
                }
              }
              .width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
            }, (item: PaymentVO) => `pay-${item.id}`)
          }.padding(16)
        }.layoutWeight(1).scrollBar(BarState.Off)
      }
    }.width('100%').height('100%').backgroundColor('#EEF2FF')
  }
}
