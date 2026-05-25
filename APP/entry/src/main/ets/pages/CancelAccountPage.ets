import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';
import { UserSession } from '../common/UserSession';

@Entry
@Component
struct CancelAccountPage {
  @State password: string = '';
  @State isSubmitting: boolean = false;

  private async submitCancel(): Promise<void> {
    if (!AppUtil.requireLogin()) {
      return;
    }
    if (this.password.length === 0) {
      AppUtil.toast('请输入密码确认');
      return;
    }
    const ok = await AppUtil.confirm('注销后账号不可恢复，确定继续？');
    if (!ok) {
      return;
    }
    this.isSubmitting = true;
    const res = await HotelApi.cancelAccount(this.password);
    this.isSubmitting = false;
    if (res.code !== 200) {
      AppUtil.toast(res.message || '注销失败');
      return;
    }
    await UserSession.clear();
    AppUtil.toast('账号已注销');
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    Column() {
      PageHeader({ title: '注销账号', showBack: true })

      Column({ space: 16 }) {
        Text('注销后账号状态变为 CANCELLED，无法再次登录或注册同一手机号。')
          .fontSize(14)
          .fontColor('#64748B')
          .width('100%')

        TextInput({ text: this.password, placeholder: '请输入当前密码' })
          .width('100%')
          .height(48)
          .type(InputType.Password)
          .backgroundColor('#F8FAFC')
          .borderRadius(12)
          .padding({ left: 14, right: 14 })
          .fontColor(FORM_TEXT_COLOR)
          .placeholderColor(FORM_PLACEHOLDER_COLOR)
          .caretColor(FORM_CARET_COLOR)
          .onChange((v: string) => { this.password = v; })

        Button(this.isSubmitting ? '处理中...' : '确认注销')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#EF4444')
          .enabled(!this.isSubmitting)
          .onClick(() => { this.submitCancel(); })
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .margin({ left: 16, right: 16, top: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
