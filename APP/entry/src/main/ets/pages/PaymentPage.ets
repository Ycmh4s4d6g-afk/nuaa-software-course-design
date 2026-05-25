import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';

interface PaymentMethodItem {
  id: string;
  name: string;
  icon: string;
  desc: string;
}

const PAYMENT_METHODS: PaymentMethodItem[] = [
  { id: 'WECHAT', name: '微信支付', icon: '💚', desc: '模拟微信安全支付' },
  { id: 'ALIPAY', name: '支付宝', icon: '💙', desc: '模拟支付宝快捷支付' },
  { id: 'BANK_CARD', name: '银行卡', icon: '🏦', desc: '模拟银行卡支付' },
  { id: 'SIMULATED', name: '模拟支付', icon: '💳', desc: '课程演示专用通道' }
];

@Entry
@Component
struct PaymentPage {
  @State reservationId: number = 0;
  @State totalAmount: number = 0;
  @State hotelName: string = '';
  @State selectedMethod: string = 'WECHAT';
  @State isPaying: boolean = false;
  @State payStatusText: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      if (params.reservationId) {
        this.reservationId = parseInt(params.reservationId);
      }
      if (params.totalAmount) {
        this.totalAmount = parseFloat(params.totalAmount);
      }
      this.hotelName = params.hotelName ?? '';
    }
  }

  private getMethodName(): string {
    for (let i = 0; i < PAYMENT_METHODS.length; i++) {
      if (PAYMENT_METHODS[i].id === this.selectedMethod) {
        return PAYMENT_METHODS[i].name;
      }
    }
    return '支付';
  }

  private async confirmPay(): Promise<void> {
    if (this.isPaying || this.reservationId <= 0) {
      return;
    }

    this.isPaying = true;
    this.payStatusText = `正在调起${this.getMethodName()}...`;
    AppUtil.toast(this.payStatusText);

    const res = await HotelApi.payReservation(this.reservationId, this.selectedMethod);
    this.isPaying = false;
    this.payStatusText = '';

    if (res.code !== 200) {
      AppUtil.toast(res.message || '支付失败');
      return;
    }

    const amount = res.data && res.data.amount ? res.data.amount : this.totalAmount;
    AppUtil.toast(`${this.getMethodName()}成功，已支付 ¥${amount}`);
    router.replaceUrl({ url: 'pages/ReservationListPage' });
  }

  build() {
    Column() {
      PageHeader({ title: '订单支付', showBack: true })

      Column({ space: 20 }) {
        Column({ space: 8 }) {
          Text('支付金额')
            .fontSize(14)
            .fontColor('#64748B')
          Text(`¥${this.totalAmount}`)
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor('#EF4444')
          if (this.hotelName.length > 0) {
            Text(this.hotelName)
              .fontSize(14)
              .fontColor('#94A3B8')
          }
          Text('订单号：' + this.reservationId)
            .fontSize(12)
            .fontColor('#CBD5E1')
        }
        .width('100%')
        .padding(28)
        .backgroundColor(Color.White)
        .borderRadius(16)

        Column({ space: 12 }) {
          Text('选择支付方式')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
            .width('100%')

          Text('以下均为模拟支付，不会产生真实扣款')
            .fontSize(12)
            .fontColor('#94A3B8')
            .width('100%')

          ForEach(PAYMENT_METHODS, (method: PaymentMethodItem) => {
            Row() {
              Text(method.icon)
                .fontSize(22)
              Column({ space: 4 }) {
                Text(method.name)
                  .fontSize(15)
                  .fontColor('#0F172A')
                Text(method.desc)
                  .fontSize(11)
                  .fontColor('#94A3B8')
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
              .layoutWeight(1)

              if (this.selectedMethod === method.id) {
                Text('✓')
                  .fontSize(18)
                  .fontColor('#2563EB')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.selectedMethod === method.id ? '#EFF6FF' : Color.White)
            .borderRadius(12)
            .border({
              width: 1,
              color: this.selectedMethod === method.id ? '#2563EB' : '#E2E8F0'
            })
            .onClick(() => {
              this.selectedMethod = method.id;
            })
          }, (method: PaymentMethodItem) => method.id)
        }
        .width('100%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(16)

        if (this.payStatusText.length > 0) {
          Text(this.payStatusText)
            .fontSize(14)
            .fontColor('#2563EB')
            .width('100%')
            .textAlign(TextAlign.Center)
        }

        Button(this.isPaying ? '支付处理中...' : `确认支付 ¥${this.totalAmount}`)
          .width('100%')
          .height(52)
          .fontSize(17)
          .fontColor(Color.White)
          .borderRadius(12)
          .enabled(!this.isPaying)
          .linearGradient({
            angle: 120,
            colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
          })
          .onClick(() => {
            this.confirmPay();
          })
      }
      .padding({ left: 16, right: 16, top: 20 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
