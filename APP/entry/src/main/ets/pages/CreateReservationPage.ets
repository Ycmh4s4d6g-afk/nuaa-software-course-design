import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { DateUtil } from '../common/DateUtil';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';
import { CreateReservationRequest } from '../common/Types';
import { UserSession } from '../common/UserSession';

@Entry
@Component
struct CreateReservationPage {
  @State hotelId: number = 0;
  @State roomTypeId: number = 0;
  @State hotelName: string = '';
  @State roomName: string = '';
  @State price: number = 0;
  @State checkInDate: string = '';
  @State checkOutDate: string = '';
  @State guestCount: number = 1;
  @State roomCount: number = 1;
  @State maxStock: number = 1;
  @State contactName: string = '';
  @State contactPhone: string = '';
  @State isSubmitting: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      if (params.hotelId) {
        this.hotelId = parseInt(params.hotelId);
      }
      if (params.roomTypeId) {
        this.roomTypeId = parseInt(params.roomTypeId);
      }
      this.hotelName = params.hotelName ?? '';
      this.roomName = params.roomName ?? '';
      if (params.price) {
        this.price = parseInt(params.price);
      }
      if (params.maxStock) {
        const stock = parseInt(params.maxStock);
        this.maxStock = stock > 0 ? stock : 1;
      }
    }
    this.contactName = UserSession.getUsername();
    this.contactPhone = UserSession.getPhone();
  }

  private pickCheckInDate(): void {
    DateUtil.showDatePicker(this.checkInDate, (dateStr: string) => {
      this.checkInDate = dateStr;
      if (this.checkOutDate.length > 0 && this.checkOutDate <= this.checkInDate) {
        this.checkOutDate = '';
      }
    });
  }

  private pickCheckOutDate(): void {
    const base = this.checkOutDate.length > 0 ? this.checkOutDate : this.checkInDate;
    DateUtil.showDatePicker(base, (dateStr: string) => {
      if (this.checkInDate.length > 0 && dateStr <= this.checkInDate) {
        AppUtil.toast('离店日期须晚于入住日期');
        return;
      }
      this.checkOutDate = dateStr;
    });
  }

  private async submitReservation(): Promise<void> {
    if (!AppUtil.requireLogin()) {
      return;
    }
    if (this.checkInDate.length === 0 || this.checkOutDate.length === 0) {
      AppUtil.toast('请选择入住和离店日期');
      return;
    }
    if (this.roomCount < 1 || this.roomCount > this.maxStock) {
      AppUtil.toast(`预订间数不能超过剩余 ${this.maxStock} 间`);
      return;
    }
    if (this.contactName.trim().length === 0 || this.contactPhone.trim().length === 0) {
      AppUtil.toast('请填写联系人信息');
      return;
    }
    if (!/^1\d{10}$/.test(this.contactPhone.trim())) {
      AppUtil.toast('请输入正确的联系电话');
      return;
    }

    this.isSubmitting = true;
    const req: CreateReservationRequest = {
      hotelId: this.hotelId,
      roomTypeId: this.roomTypeId,
      checkInDate: this.checkInDate,
      checkOutDate: this.checkOutDate,
      roomCount: this.roomCount,
      guestCount: this.guestCount,
      contactName: this.contactName.trim(),
      contactPhone: this.contactPhone.trim()
    };
    const res = await HotelApi.createReservation(req);
    this.isSubmitting = false;

    if (res.code !== 200 || !res.data) {
      AppUtil.toast(res.message || '预订失败');
      return;
    }

    AppUtil.toast('预订成功，请完成支付');
    router.replaceUrl({
      url: 'pages/PaymentPage',
      params: {
        reservationId: `${res.data.id}`,
        totalAmount: `${res.data.totalAmount}`,
        hotelName: res.data.hotelName
      }
    });
  }

  @Builder
  CheckInDateRow() {
    Column({ space: 8 }) {
      Text('入住日期')
        .fontSize(14)
        .fontColor('#475569')
        .width('100%')
      Row() {
        Text(this.checkInDate.length > 0 ? this.checkInDate : '点击选择入住日期')
          .fontSize(15)
          .fontColor(this.checkInDate.length > 0 ? '#1E293B' : '#94A3B8')
          .layoutWeight(1)
        Text('📅')
          .fontSize(16)
      }
      .width('100%')
      .height(48)
      .padding({ left: 14, right: 14 })
      .backgroundColor('#F8FAFC')
      .borderRadius(12)
      .border({ width: 1, color: '#E2E8F0' })
      .onClick(() => {
        this.pickCheckInDate();
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CheckOutDateRow() {
    Column({ space: 8 }) {
      Text('离店日期')
        .fontSize(14)
        .fontColor('#475569')
        .width('100%')
      Row() {
        Text(this.checkOutDate.length > 0 ? this.checkOutDate : '点击选择离店日期')
          .fontSize(15)
          .fontColor(this.checkOutDate.length > 0 ? '#1E293B' : '#94A3B8')
          .layoutWeight(1)
        Text('📅')
          .fontSize(16)
      }
      .width('100%')
      .height(48)
      .padding({ left: 14, right: 14 })
      .backgroundColor('#F8FAFC')
      .borderRadius(12)
      .border({ width: 1, color: '#E2E8F0' })
      .onClick(() => {
        this.pickCheckOutDate();
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      PageHeader({ title: '填写预订', showBack: true })

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text(this.hotelName)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
            Text(this.roomName)
              .fontSize(14)
              .fontColor('#64748B')
            Text(`参考价 ¥${this.price} / 晚`)
              .fontSize(14)
              .fontColor('#EF4444')
            Text(`剩余可订 ${this.maxStock} 间`)
              .fontSize(13)
              .fontColor(this.maxStock > 0 ? '#22C55E' : '#EF4444')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start)

          Column({ space: 16 }) {
            this.CheckInDateRow()
            this.CheckOutDateRow()

            Column({ space: 8 }) {
              Text('预订间数')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              Row({ space: 16 }) {
                Button('-')
                  .width(44)
                  .height(44)
                  .fontSize(18)
                  .onClick(() => {
                    if (this.roomCount > 1) {
                      this.roomCount--;
                    }
                  })
                Text(`${this.roomCount} 间`)
                  .fontSize(16)
                  .fontColor('#0F172A')
                Button('+')
                  .width(44)
                  .height(44)
                  .fontSize(18)
                  .onClick(() => {
                    if (this.roomCount < this.maxStock) {
                      this.roomCount++;
                    } else {
                      AppUtil.toast(`最多可订 ${this.maxStock} 间`);
                    }
                  })
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Text('入住人数')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              Row({ space: 16 }) {
                Button('-')
                  .width(44)
                  .height(44)
                  .fontSize(18)
                  .onClick(() => {
                    if (this.guestCount > 1) {
                      this.guestCount--;
                    }
                  })
                Text(`${this.guestCount} 人`)
                  .fontSize(16)
                  .fontColor('#0F172A')
                Button('+')
                  .width(44)
                  .height(44)
                  .fontSize(18)
                  .onClick(() => {
                    if (this.guestCount < 6) {
                      this.guestCount++;
                    }
                  })
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Text('联系人')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              TextInput({ text: this.contactName, placeholder: '请输入姓名' })
                .width('100%')
                .height(48)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.contactName = v;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Text('联系电话')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              TextInput({ text: this.contactPhone, placeholder: '请输入手机号' })
                .width('100%')
                .height(48)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .type(InputType.PhoneNumber)
                .maxLength(11)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.contactPhone = v;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)

          Button(this.isSubmitting ? '提交中...' : '提交预订')
            .width('100%')
            .height(50)
            .fontSize(16)
            .fontColor(Color.White)
            .borderRadius(12)
            .enabled(!this.isSubmitting)
            .linearGradient({
              angle: 120,
              colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
            })
            .onClick(() => {
              this.submitReservation();
            })
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
