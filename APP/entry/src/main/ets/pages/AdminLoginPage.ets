import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { UserSession } from '../common/UserSession';

@Entry
@Component
struct AdminLoginPage {
  @State phone: string = '';
  @State password: string = '';
  @State isPasswordVisible: boolean = false;
  @State isSubmitting: boolean = false;

  aboutToAppear(): void {
    UserSession.init(getContext(this) as Context);
  }

  private async handleLogin(): Promise<void> {
    if (this.isSubmitting) {
      return;
    }
    const phone = this.phone.trim();
    if (phone.length === 0 || this.password.length === 0) {
      AppUtil.toast('请输入管理员账号和密码');
      return;
    }
    if (this.password.length < 6) {
      AppUtil.toast('密码长度不能少于6位');
      return;
    }

    this.isSubmitting = true;
    const res = await HotelApi.login(phone, this.password);
    this.isSubmitting = false;

    if (res.code !== 200 || !res.data) {
      AppUtil.toast(res.message || '登录失败');
      return;
    }
    if (res.data.role !== 'ADMIN' && res.data.phone !== '13800000000') {
      AppUtil.toast('该账号不是管理员，请使用用户登录');
      return;
    }

    if (res.data.phone === '13800000000') {
      res.data.role = 'ADMIN';
    }

    await UserSession.saveUser(res.data);
    AppUtil.toast(`欢迎，${res.data.username}`);
    router.replaceUrl({ url: 'pages/AdminHomePage' });
  }

  build() {
    Column() {
      Column() {
        Column({ space: 14 }) {
          Row() {
            Column() {
              Text('🛡️')
                .fontSize(28)
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('rgba(255,255,255,0.15)')
            .borderRadius(20)

            Column({ space: 6 }) {
              Text('管理员后台')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text('酒店管理 · 用户审核 · 订单监控')
                .fontSize(13)
                .fontColor('rgba(255,255,255,0.88)')
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 16 })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 56, bottom: 36 })
      }
      .width('100%')
      .linearGradient({
        angle: 120,
        colors: [['#1E3A8A', 0.0], ['#1E40AF', 0.6], ['#172554', 1.0]]
      })

      Scroll() {
        Column() {
          Column({ space: 20 }) {
            Column({ space: 8 }) {
              Text('管理员登录')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#0F172A')
                .width('100%')
                .textAlign(TextAlign.Center)
              Text('仅限管理员账号进入后台')
                .fontSize(13)
                .fontColor('#64748B')
                .width('100%')
                .textAlign(TextAlign.Center)
              Text('测试账号：13800000000 / 123456')
                .fontSize(12)
                .fontColor('#94A3B8')
                .width('100%')
                .textAlign(TextAlign.Center)
            }

            Column({ space: 8 }) {
              Text('账号')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              TextInput({ text: this.phone, placeholder: '管理员手机号' })
                .width('100%')
                .height(48)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .padding({ left: 14, right: 14 })
                .type(InputType.PhoneNumber)
                .maxLength(11)
                .fontColor(FORM_TEXT_COLOR)
                .placeholderColor(FORM_PLACEHOLDER_COLOR)
                .caretColor(FORM_CARET_COLOR)
                .onChange((v: string) => {
                  this.phone = v;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Text('密码')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              Row() {
                TextInput({ text: this.password, placeholder: '登录密码' })
                  .layoutWeight(1)
                  .height(48)
                  .backgroundColor(Color.Transparent)
                  .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                  .fontColor(FORM_TEXT_COLOR)
                  .placeholderColor(FORM_PLACEHOLDER_COLOR)
                  .caretColor(FORM_CARET_COLOR)
                  .onChange((v: string) => {
                    this.password = v;
                  })
                Text(this.isPasswordVisible ? '隐藏' : '显示')
                  .fontSize(13)
                  .fontColor('#1E40AF')
                  .margin({ right: 8 })
                  .onClick(() => {
                    this.isPasswordVisible = !this.isPasswordVisible;
                  })
              }
              .width('100%')
              .padding({ left: 14, right: 8 })
              .backgroundColor('#F8FAFC')
              .borderRadius(12)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Button(this.isSubmitting ? '登录中...' : '登录后台')
              .width('100%')
              .height(50)
              .fontSize(16)
              .fontColor(Color.White)
              .borderRadius(12)
              .enabled(!this.isSubmitting)
              .backgroundColor('#1E40AF')
              .onClick(() => {
                this.handleLogin();
              })

            Text('← 返回用户登录')
              .fontSize(14)
              .fontColor('#1E40AF')
              .width('100%')
              .textAlign(TextAlign.Center)
              .onClick(() => {
                router.replaceUrl({ url: 'pages/LoginPage' });
              })
          }
          .width('100%')
          .padding(28)
          .backgroundColor(Color.White)
          .borderRadius(20)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 24, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF2FF')
  }
}
