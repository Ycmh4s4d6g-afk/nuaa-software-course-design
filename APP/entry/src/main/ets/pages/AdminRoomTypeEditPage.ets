import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';
import { AdminCreateRoomTypeRequest, AdminUpdateRoomTypeRequest } from '../common/Types';

@Entry
@Component
struct AdminRoomTypeEditPage {
  @State hotelId: number = 0;
  @State hotelName: string = '';
  @State roomTypeId: number = 0;
  @State roomTypeName: string = '';
  @State bedType: string = '1张大床';
  @State capacity: string = '2';
  @State totalRooms: string = '10';
  @State availableRooms: string = '10';
  @State price: string = '';
  @State description: string = '';
  @State isLoading: boolean = false;
  @State isSubmitting: boolean = false;

  aboutToAppear(): void {
    if (!AppUtil.requireAdmin()) {
      return;
    }
    const params = router.getParams() as Record<string, string>;
    this.hotelId = Number(params['hotelId'] ?? '0');
    this.hotelName = params['hotelName'] ?? '';
    this.roomTypeId = Number(params['roomTypeId'] ?? '0');
    if (this.roomTypeId > 0 && this.hotelId > 0) {
      this.loadRoomType();
    }
  }

  private async loadRoomType(): Promise<void> {
    this.isLoading = true;
    const list = await HotelApi.getRoomTypes(this.hotelId);
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === this.roomTypeId) {
        const rt = list[i];
        this.roomTypeName = rt.roomName;
        this.bedType = rt.bedType;
        this.capacity = `${rt.maxGuests}`;
        this.totalRooms = `${rt.totalRooms ?? rt.stock}`;
        this.availableRooms = `${rt.stock}`;
        this.price = `${rt.price}`;
        this.description = rt.description ?? '';
        break;
      }
    }
    this.isLoading = false;
  }

  private async submit(): Promise<void> {
    if (this.isSubmitting || this.hotelId <= 0) {
      return;
    }
    const cap = Number(this.capacity);
    const total = Number(this.totalRooms);
    const avail = Number(this.availableRooms);
    const pr = Number(this.price);
    if (this.roomTypeName.trim().length === 0 || isNaN(cap) || isNaN(total) || isNaN(avail) || isNaN(pr)) {
      AppUtil.toast('请填写完整房型信息');
      return;
    }

    this.isSubmitting = true;
    if (this.roomTypeId > 0) {
      const req: AdminUpdateRoomTypeRequest = {
        roomTypeName: this.roomTypeName.trim(),
        bedType: this.bedType.trim(),
        capacity: cap,
        totalRooms: total,
        availableRooms: avail,
        price: pr,
        breakfastIncluded: 1,
        description: this.description.trim(),
        status: 'AVAILABLE'
      };
      const res = await HotelApi.updateAdminRoomType(this.roomTypeId, req);
      this.isSubmitting = false;
      if (res.code !== 200) {
        AppUtil.toast(res.message || '保存失败');
        return;
      }
    } else {
      const req: AdminCreateRoomTypeRequest = {
        roomTypeName: this.roomTypeName.trim(),
        bedType: this.bedType.trim(),
        capacity: cap,
        totalRooms: total,
        price: pr,
        breakfastIncluded: 1,
        description: this.description.trim()
      };
      const res = await HotelApi.createAdminRoomType(this.hotelId, req);
      this.isSubmitting = false;
      if (res.code !== 200) {
        AppUtil.toast(res.message || '添加失败');
        return;
      }
    }
    AppUtil.toast(this.roomTypeId > 0 ? '修改成功' : '房型已添加');
    router.back();
  }

  build() {
    Column() {
      PageHeader({ title: this.roomTypeId > 0 ? '编辑房型' : '添加房型', showBack: true })

      Text(`${this.hotelName}`)
        .fontSize(13)
        .fontColor('#64748B')
        .width('100%')
        .padding({ left: 16, top: 6 })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            Column({ space: 6 }) {
              Text('房型名称').fontSize(13).fontColor('#475569').width('100%')
              TextInput({ text: this.roomTypeName, placeholder: '如：商务大床房' })
                .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => { this.roomTypeName = v; })
            }.width('100%')

            Column({ space: 6 }) {
              Text('床型').fontSize(13).fontColor('#475569').width('100%')
              TextInput({ text: this.bedType, placeholder: '1张大床' })
                .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => { this.bedType = v; })
            }.width('100%')

            Row({ space: 10 }) {
              Column({ space: 6 }) {
                Text('可住人数').fontSize(13).fontColor('#475569').width('100%')
                TextInput({ text: this.capacity, placeholder: '2' })
                  .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                  .type(InputType.Number)
                  .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                  .onChange((v: string) => { this.capacity = v; })
              }.layoutWeight(1)
              Column({ space: 6 }) {
                Text('每晚价格').fontSize(13).fontColor('#475569').width('100%')
                TextInput({ text: this.price, placeholder: '399' })
                  .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                  .type(InputType.Number)
                  .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                  .onChange((v: string) => { this.price = v; })
              }.layoutWeight(1)
            }.width('100%')

            Row({ space: 10 }) {
              Column({ space: 6 }) {
                Text('房间总数').fontSize(13).fontColor('#475569').width('100%')
                TextInput({ text: this.totalRooms, placeholder: '10' })
                  .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                  .type(InputType.Number)
                  .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                  .onChange((v: string) => { this.totalRooms = v; })
              }.layoutWeight(1)
              Column({ space: 6 }) {
                Text('可预订数').fontSize(13).fontColor('#475569').width('100%')
                TextInput({ text: this.availableRooms, placeholder: '10' })
                  .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                  .type(InputType.Number)
                  .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                  .onChange((v: string) => { this.availableRooms = v; })
              }.layoutWeight(1)
            }.width('100%')

            Column({ space: 6 }) {
              Text('房型说明').fontSize(13).fontColor('#475569').width('100%')
              TextArea({ text: this.description, placeholder: '含早餐、可取消等' })
                .width('100%').height(80).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR)
                .onChange((v: string) => { this.description = v; })
            }.width('100%')

            Button(this.isSubmitting ? '提交中...' : '保存房型')
              .width('100%').height(48).fontColor(Color.White).backgroundColor('#1E40AF')
              .enabled(!this.isSubmitting)
              .onClick(() => { this.submit(); })
          }
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF2FF')
  }
}
