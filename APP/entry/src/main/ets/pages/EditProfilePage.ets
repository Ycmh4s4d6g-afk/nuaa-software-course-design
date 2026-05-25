import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { getUserAvatarRes } from '../common/HotelImageUtil';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';
@Entry
@Component
struct EditProfilePage {
  @State username: string = '';
  @State email: string = '';
  @State phone: string = '';
  @State gender: string = '';
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (!AppUtil.requireLogin()) {
      return;
    }
    this.loadProfile();
  }

  private async loadProfile(): Promise<void> {
    this.isLoading = true;
    const profile = await HotelApi.getProfile();
    this.username = profile.username;
    this.email = profile.email ?? '';
    this.phone = profile.phone;
    this.gender = profile.gender ?? '';
    this.isLoading = false;
  }

  private saveProfile(): void {
    if (this.username.trim().length === 0) {
      AppUtil.toast('昵称不能为空');
      return;
    }
    AppUtil.toast('资料已保存');
    router.back();
  }

  build() {
    Column() {
      PageHeader({ title: '编辑资料', showBack: true })

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#2563EB')
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Column() {
              Image(getUserAvatarRes())
                .width(80)
                .height(80)
                .borderRadius(40)
                .objectFit(ImageFit.Cover)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .margin({ bottom: 8 })

            Column({ space: 8 }) {
              Text('昵称')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              TextInput({ text: this.username, placeholder: '请输入昵称' })
                .width('100%')
                .height(48)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.username = v;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Text('邮箱')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              TextInput({ text: this.email, placeholder: '请输入邮箱' })
                .width('100%')
                .height(48)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.email = v;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Text('手机号')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              Text(this.phone)
                .fontSize(15)
                .fontColor('#94A3B8')
                .width('100%')
                .height(48)
                .backgroundColor('#F1F5F9')
                .borderRadius(12)
                .padding({ left: 14 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Text('性别')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              TextInput({ text: this.gender, placeholder: '男 / 女' })
                .width('100%')
                .height(48)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.gender = v;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Button('保存')
              .width('100%')
              .height(50)
              .fontSize(16)
              .fontColor(Color.White)
              .borderRadius(12)
              .margin({ top: 12 })
              .linearGradient({
                angle: 120,
                colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
              })
              .onClick(() => {
                this.saveProfile();
              })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .margin({ left: 16, right: 16, top: 16 })
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
