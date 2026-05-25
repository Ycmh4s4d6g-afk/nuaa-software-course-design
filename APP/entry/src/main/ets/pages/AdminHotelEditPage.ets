import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';
import { AdminHotelRequest } from '../common/Types';

@Entry
@Component
struct AdminHotelEditPage {
  @State hotelId: number = 0;
  @State hotelName: string = '';
  @State hotelType: string = '商务';
  @State city: string = '';
  @State address: string = '';
  @State minPrice: string = '';
  @State rating: string = '4.5';
  @State contactPhone: string = '';
  @State description: string = '';
  @State facilities: string = '';
  @State isLoading: boolean = false;
  @State isSubmitting: boolean = false;

  aboutToAppear(): void {
    if (!AppUtil.requireAdmin()) {
      return;
    }
    const params = router.getParams() as Record<string, string>;
    this.hotelId = Number(params['hotelId'] ?? '0');
    if (this.hotelId > 0) {
      this.loadHotel();
    }
  }

  private async loadHotel(): Promise<void> {
    this.isLoading = true;
    const hotel = await HotelApi.getHotelDetail(this.hotelId);
    if (hotel) {
      this.hotelName = hotel.hotelName;
      this.hotelType = hotel.hotelType;
      this.city = hotel.city;
      this.address = hotel.address ?? '';
      this.minPrice = `${hotel.minPrice}`;
      this.rating = `${hotel.rating}`;
      this.contactPhone = hotel.contactPhone ?? hotel.phone ?? '';
      this.description = hotel.description ?? '';
      this.facilities = hotel.facilities ?? '';
    }
    this.isLoading = false;
  }

  private async submit(): Promise<void> {
    if (this.isSubmitting) {
      return;
    }
    const minPrice = Number(this.minPrice);
    const rating = Number(this.rating);
    if (this.hotelName.trim().length === 0 || this.city.trim().length === 0 ||
      this.address.trim().length === 0 || isNaN(minPrice) || isNaN(rating)) {
      AppUtil.toast('请填写完整信息');
      return;
    }
    const req: AdminHotelRequest = {
      hotelName: this.hotelName.trim(),
      hotelType: this.hotelType.trim().length > 0 ? this.hotelType.trim() : '商务',
      city: this.city.trim(),
      address: this.address.trim(),
      minPrice: minPrice,
      rating: rating,
      contactPhone: this.contactPhone.trim(),
      description: this.description.trim(),
      facilities: this.facilities.trim(),
      isReservable: 1
    };
    this.isSubmitting = true;
    if (this.hotelId > 0) {
      const res = await HotelApi.updateAdminHotel(this.hotelId, req);
      this.isSubmitting = false;
      if (res.code !== 200) {
        AppUtil.toast(res.message || '保存失败');
        return;
      }
      AppUtil.toast('修改成功');
      router.back();
    } else {
      const res = await HotelApi.createAdminHotel(req);
      this.isSubmitting = false;
      if (res.code !== 200 || !res.data) {
        AppUtil.toast(res.message || '保存失败');
        return;
      }
      AppUtil.toast('酒店已添加，请继续添加房型');
      router.replaceUrl({
        url: 'pages/AdminRoomTypeListPage',
        params: {
          hotelId: `${res.data.id}`,
          hotelName: res.data.hotelName
        }
      });
    }
  }

  private goRoomTypesFromEdit(): void {
    if (this.hotelId <= 0) {
      AppUtil.toast('请先保存酒店');
      return;
    }
    router.pushUrl({
      url: 'pages/AdminRoomTypeListPage',
      params: { hotelId: `${this.hotelId}`, hotelName: this.hotelName }
    });
  }

  build() {
    Column() {
      PageHeader({ title: this.hotelId > 0 ? '编辑酒店' : '新增酒店', showBack: true })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Column({ space: 6 }) {
              Text('酒店名称').fontSize(13).fontColor('#475569').width('100%')
              TextInput({ text: this.hotelName, placeholder: '请输入酒店名称' })
                .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => { this.hotelName = v; })
            }.width('100%')

            Column({ space: 6 }) {
              Text('酒店类型').fontSize(13).fontColor('#475569').width('100%')
              TextInput({ text: this.hotelType, placeholder: '度假/商务/豪华' })
                .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => { this.hotelType = v; })
            }.width('100%')

            Column({ space: 6 }) {
              Text('城市').fontSize(13).fontColor('#475569').width('100%')
              TextInput({ text: this.city, placeholder: '如：上海' })
                .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => { this.city = v; })
            }.width('100%')

            Column({ space: 6 }) {
              Text('详细地址').fontSize(13).fontColor('#475569').width('100%')
              TextInput({ text: this.address, placeholder: '请输入地址' })
                .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => { this.address = v; })
            }.width('100%')

            Row({ space: 10 }) {
              Column({ space: 6 }) {
                Text('起始价格').fontSize(13).fontColor('#475569').width('100%')
                TextInput({ text: this.minPrice, placeholder: '499' })
                  .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                  .type(InputType.Number)
                  .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                  .onChange((v: string) => { this.minPrice = v; })
              }.layoutWeight(1)
              Column({ space: 6 }) {
                Text('评分').fontSize(13).fontColor('#475569').width('100%')
                TextInput({ text: this.rating, placeholder: '4.8' })
                  .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                  .type(InputType.Number)
                  .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                  .onChange((v: string) => { this.rating = v; })
              }.layoutWeight(1)
            }.width('100%')

            Column({ space: 6 }) {
              Text('联系电话').fontSize(13).fontColor('#475569').width('100%')
              TextInput({ text: this.contactPhone, placeholder: '酒店电话' })
                .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => { this.contactPhone = v; })
            }.width('100%')

            Column({ space: 6 }) {
              Text('设施（逗号分隔）').fontSize(13).fontColor('#475569').width('100%')
              TextInput({ text: this.facilities, placeholder: 'WiFi,停车场' })
                .width('100%').height(44).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => { this.facilities = v; })
            }.width('100%')

            Column({ space: 6 }) {
              Text('酒店简介').fontSize(13).fontColor('#475569').width('100%')
              TextArea({ text: this.description, placeholder: '酒店介绍' })
                .width('100%').height(100).backgroundColor('#F8FAFC').borderRadius(8)
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR)
                .onChange((v: string) => { this.description = v; })
            }.width('100%')

            Button(this.isSubmitting ? '提交中...' : '保存酒店')
              .width('100%').height(48).fontColor(Color.White).backgroundColor('#1E40AF')
              .enabled(!this.isSubmitting).onClick(() => { this.submit(); })

            if (this.hotelId > 0) {
              Button('管理房型（添加/编辑）')
                .width('100%').height(44).fontSize(14).fontColor('#1E40AF')
                .backgroundColor('#EFF6FF')
                .onClick(() => { this.goRoomTypesFromEdit(); })
            }
          }.padding(16)
        }.layoutWeight(1)
      }
    }.width('100%').height('100%').backgroundColor('#EEF2FF')
  }
}
