import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';

@Entry
@Component
struct ChangePasswordPage {
  @State mode: number = 0;
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State phone: string = '';
  @State resetPassword: string = '';
  @State isSubmitting: boolean = false;

  private async submitChange(): Promise<void> {
    if (this.oldPassword.length === 0 || this.newPassword.length === 0) {
      AppUtil.toast('请填写完整密码信息');
      return;
    }
    if (this.newPassword.length < 6) {
      AppUtil.toast('新密码至少6位');
      return;
    }
    if (this.newPassword !== this.confirmPassword) {
      AppUtil.toast('两次新密码不一致');
      return;
    }

    this.isSubmitting = true;
    const res = await HotelApi.changePassword(this.oldPassword, this.newPassword);
    this.isSubmitting = false;

    if (res.code !== 200) {
      AppUtil.toast(res.message || '修改失败');
      return;
    }
    AppUtil.toast('密码修改成功');
    router.back();
  }

  private async submitForgot(): Promise<void> {
    const phone = this.phone.trim();
    if (!/^1\d{10}$/.test(phone)) {
      AppUtil.toast('请输入正确的手机号');
      return;
    }
    if (this.resetPassword.length < 6) {
      AppUtil.toast('新密码至少6位');
      return;
    }

    this.isSubmitting = true;
    const res = await HotelApi.forgotPassword(phone, this.resetPassword);
    this.isSubmitting = false;

    if (res.code !== 200) {
      AppUtil.toast(res.message || '重置失败');
      return;
    }
    AppUtil.toast('密码已重置，请登录');
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    Column() {
      PageHeader({ title: '密码管理', showBack: true })

      Row({ space: 0 }) {
        Text('修改密码')
          .fontSize(15)
          .fontColor(this.mode === 0 ? '#2563EB' : '#64748B')
          .fontWeight(this.mode === 0 ? FontWeight.Bold : FontWeight.Normal)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 14, bottom: 14 })
          .border({
            width: { bottom: 2 },
            color: this.mode === 0 ? '#2563EB' : Color.Transparent
          })
          .onClick(() => {
            this.mode = 0;
          })

        Text('忘记密码')
          .fontSize(15)
          .fontColor(this.mode === 1 ? '#2563EB' : '#64748B')
          .fontWeight(this.mode === 1 ? FontWeight.Bold : FontWeight.Normal)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 14, bottom: 14 })
          .border({
            width: { bottom: 2 },
            color: this.mode === 1 ? '#2563EB' : Color.Transparent
          })
          .onClick(() => {
            this.mode = 1;
          })
      }
      .width('100%')
      .backgroundColor(Color.White)

      Scroll() {
        Column({ space: 16 }) {
          if (this.mode === 0) {
            Column({ space: 12 }) {
              TextInput({ text: this.oldPassword, placeholder: '当前密码' })
                .width('100%')
                .height(48)
                .type(InputType.Password)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.oldPassword = v;
                })

              TextInput({ text: this.newPassword, placeholder: '新密码（至少6位）' })
                .width('100%')
                .height(48)
                .type(InputType.Password)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.newPassword = v;
                })

              TextInput({ text: this.confirmPassword, placeholder: '确认新密码' })
                .width('100%')
                .height(48)
                .type(InputType.Password)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.confirmPassword = v;
                })
            }

            Button(this.isSubmitting ? '提交中...' : '确认修改')
              .width('100%')
              .height(50)
              .fontColor(Color.White)
              .borderRadius(12)
              .enabled(!this.isSubmitting)
              .linearGradient({
                angle: 120,
                colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
              })
              .onClick(() => {
                this.submitChange();
              })
          } else {
            Column({ space: 12 }) {
              TextInput({ text: this.phone, placeholder: '注册手机号' })
                .width('100%')
                .height(48)
                .type(InputType.PhoneNumber)
                .maxLength(11)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.phone = v;
                })

              TextInput({ text: this.resetPassword, placeholder: '设置新密码（至少6位）' })
                .width('100%')
                .height(48)
                .type(InputType.Password)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.resetPassword = v;
                })
            }

            Button(this.isSubmitting ? '提交中...' : '重置密码')
              .width('100%')
              .height(50)
              .fontColor(Color.White)
              .borderRadius(12)
              .enabled(!this.isSubmitting)
              .linearGradient({
                angle: 120,
                colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
              })
              .onClick(() => {
                this.submitForgot();
              })
          }
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
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
