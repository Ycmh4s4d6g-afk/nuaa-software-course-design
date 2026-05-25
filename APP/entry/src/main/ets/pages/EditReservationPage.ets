import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { DateUtil } from '../common/DateUtil';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';
import { ReservationVO, RoomTypeVO } from '../common/Types';

@Entry
@Component
struct EditReservationPage {
  @State reservationId: number = 0;
  @State reservation: ReservationVO | null = null;
  @State roomTypes: RoomTypeVO[] = [];
  @State checkInDate: string = '';
  @State checkOutDate: string = '';
  @State roomTypeId: number = 0;
  @State contactPhone: string = '';
  @State isLoading: boolean = true;
  @State isSubmitting: boolean = false;

  aboutToAppear(): void {
    if (!AppUtil.requireLogin()) {
      return;
    }
    const params = router.getParams() as Record<string, string>;
    this.reservationId = Number(params['reservationId'] ?? '0');
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;
    const detail = await HotelApi.getReservationDetail(this.reservationId);
    if (!detail || (detail.status !== 'PENDING_PAYMENT' && detail.status !== 'PAID')) {
      AppUtil.toast('当前订单不可修改');
      router.back();
      return;
    }
    this.reservation = detail;
    this.checkInDate = detail.checkInDate;
    this.checkOutDate = detail.checkOutDate;
    this.roomTypeId = detail.roomTypeId;
    this.contactPhone = detail.contactPhone ?? '';
    this.roomTypes = await HotelApi.getRoomTypes(detail.hotelId);
    this.isLoading = false;
  }

  private async save(): Promise<void> {
    if (!this.reservation) {
      return;
    }
    if (this.contactPhone.trim().length === 0) {
      AppUtil.toast('请填写联系电话');
      return;
    }
    this.isSubmitting = true;
    const res = await HotelApi.updateReservation(this.reservationId, {
      checkInDate: this.checkInDate,
      checkOutDate: this.checkOutDate,
      roomTypeId: this.roomTypeId,
      contactPhone: this.contactPhone.trim()
    });
    this.isSubmitting = false;
    if (res.code !== 200) {
      AppUtil.toast(res.message || '保存失败');
      return;
    }
    AppUtil.toast('订单已更新');
    router.back();
  }

  build() {
    Column() {
      PageHeader({ title: '修改订单', showBack: true })
      if (this.isLoading || !this.reservation) {
        LoadingProgress().width(36).height(36).color('#2563EB').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Text(this.reservation.hotelName).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#0F172A')
            Text(`入住 ${this.checkInDate}`).fontSize(14).fontColor('#64748B')
              .onClick(() => DateUtil.showDatePicker(this.checkInDate, (d) => { this.checkInDate = d; }))
            Text(`离店 ${this.checkOutDate}`).fontSize(14).fontColor('#64748B')
              .onClick(() => DateUtil.showDatePicker(this.checkOutDate, (d) => { this.checkOutDate = d; }))
            ForEach(this.roomTypes, (rt: RoomTypeVO) => {
              Row() {
                Text(rt.roomName).layoutWeight(1).fontColor(this.roomTypeId === rt.id ? '#2563EB' : '#0F172A')
                Text(`¥${rt.price}`).fontColor('#EF4444')
              }
              .width('100%').padding(12)
              .backgroundColor(this.roomTypeId === rt.id ? '#EFF6FF' : '#F8FAFC')
              .borderRadius(10)
              .onClick(() => { this.roomTypeId = rt.id; })
            }, (rt: RoomTypeVO) => `rt-${rt.id}`)
            TextInput({ text: this.contactPhone, placeholder: '联系电话' })
              .width('100%').height(48).backgroundColor('#F8FAFC').borderRadius(12)
              .type(InputType.PhoneNumber)
              .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
              .onChange((v: string) => { this.contactPhone = v; })
            Button(this.isSubmitting ? '保存中...' : '保存修改')
              .width('100%').height(48).fontColor(Color.White).backgroundColor('#2563EB')
              .enabled(!this.isSubmitting)
              .onClick(() => { this.save(); })
          }.padding(16)
        }.layoutWeight(1)
      }
    }.width('100%').height('100%').backgroundColor('#F4F6FB')
  }
}
