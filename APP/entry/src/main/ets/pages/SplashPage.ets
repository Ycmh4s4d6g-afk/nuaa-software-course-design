import router from '@ohos.router';
import { AppUtil } from '../common/HotelApi';
import { LoginUser } from '../common/Types';
import { UserSession } from '../common/UserSession';

@Entry
@Component
struct SplashPage {
  private timerId: number = -1;

  aboutToAppear(): void {
    UserSession.init(getContext(this) as Context).then(() => {
      this.timerId = setTimeout(() => {
        if (UserSession.isLoggedIn()) {
          const user: LoginUser = {
            userId: Number(UserSession.getUserId()),
            username: UserSession.getUsername(),
            phone: UserSession.getPhone(),
            role: UserSession.getRole()
          };
          AppUtil.routeAfterLogin(user);
          return;
        }
        router.replaceUrl({ url: 'pages/LoginPage' }).catch((err: Error) => {
          console.error(`跳转登录页失败: ${err.message}`);
        });
      }, 1000);
    });
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
    }
  }

  build() {
    Column({ space: 20 }) {
      Column() {
        Text('🏨')
          .fontSize(40)
      }
      .width(88)
      .height(88)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(255,255,255,0.22)')
      .borderRadius(24)
      .border({ width: 1, color: 'rgba(255,255,255,0.35)' })

      Text('酒店推荐预订系统')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text('发现合适酒店，轻松完成预订')
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.88)')

      LoadingProgress()
        .width(36)
        .height(36)
        .color(Color.White)
        .margin({ top: 24 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .linearGradient({
      angle: 120,
      colors: [['#3B82F6', 0.0], ['#2563EB', 0.6], ['#1D4ED8', 1.0]]
    })
  }
}
