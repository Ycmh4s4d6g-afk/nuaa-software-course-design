import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isSubmitting: boolean = false;

  private async handleRegister(): Promise<void> {
    if (this.isSubmitting) {
      return;
    }
    const phone = this.phone.trim();
    const username = this.username.trim();
    if (username.length === 0 || phone.length === 0 || this.password.length === 0) {
      AppUtil.toast('请填写完整注册信息');
      return;
    }
    if (!/^1\d{10}$/.test(phone)) {
      AppUtil.toast('请输入正确的11位手机号');
      return;
    }
    if (this.password.length < 6) {
      AppUtil.toast('密码长度不能少于6位');
      return;
    }
    if (this.password !== this.confirmPassword) {
      AppUtil.toast('两次输入的密码不一致');
      return;
    }

    this.isSubmitting = true;
    const res = await HotelApi.register(phone, this.password, username);
    this.isSubmitting = false;

    if (res.code !== 200) {
      AppUtil.toast(res.message || '注册失败');
      return;
    }

    AppUtil.toast('注册成功，请登录');
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  @Builder
  InputField(label: string, placeholder: string, fieldType: number) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#475569')
        .fontWeight(FontWeight.Medium)
        .width('100%')

      TextInput({
        text: fieldType === 0 ? this.username :
          (fieldType === 1 ? this.phone : (fieldType === 2 ? this.password : this.confirmPassword)),
        placeholder: placeholder
      })
        .width('100%')
        .height(48)
        .fontSize(15)
        .backgroundColor('#F8FAFC')
        .borderRadius(12)
        .border({ width: 1, color: '#E2E8F0' })
        .padding({ left: 14, right: 14 })
        .type(fieldType >= 2 ? InputType.Password : (fieldType === 1 ? InputType.PhoneNumber : InputType.Normal))
        .maxLength(fieldType === 1 ? 11 : 32)
        .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
        .onChange((value: string) => {
          if (fieldType === 0) {
            this.username = value;
          } else if (fieldType === 1) {
            this.phone = value;
          } else if (fieldType === 2) {
            this.password = value;
          } else {
            this.confirmPassword = value;
          }
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      PageHeader({ title: '注册账户', showBack: true })

      Scroll() {
        Column() {
          Column({ space: 20 }) {
            Column({ space: 8 }) {
              Text('创建新账户')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#0F172A')
                .width('100%')
                .textAlign(TextAlign.Center)

              Text('注册后即可预订酒店、管理订单与收藏')
                .fontSize(13)
                .fontColor('#64748B')
                .width('100%')
                .textAlign(TextAlign.Center)
            }

            this.InputField('昵称', '请输入昵称', 0)
            this.InputField('手机号', '请输入手机号', 1)
            this.InputField('密码', '请设置密码（至少6位）', 2)
            this.InputField('确认密码', '请再次输入密码', 3)

            Button(this.isSubmitting ? '注册中...' : '注册')
              .width('100%')
              .height(50)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .borderRadius(12)
              .enabled(!this.isSubmitting)
              .linearGradient({
                angle: 120,
                colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
              })
              .onClick(() => {
                this.handleRegister();
              })

            Row() {
              Text('已有账户？')
                .fontSize(14)
                .fontColor('#64748B')
              Text('立即登录')
                .fontSize(14)
                .fontColor('#2563EB')
                .fontWeight(FontWeight.Medium)
                .margin({ left: 6 })
                .onClick(() => {
                  router.replaceUrl({ url: 'pages/LoginPage' });
                })
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .width('100%')
          .padding(28)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius: 24,
            color: 'rgba(15, 23, 42, 0.08)',
            offsetY: 8
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 24, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
