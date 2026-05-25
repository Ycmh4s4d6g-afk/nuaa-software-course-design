import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { BottomTabBar } from '../common/BottomTabBar';
import { getUserAvatarRes } from '../common/HotelImageUtil';
import { UserProfileVO } from '../common/Types';
import { UserSession } from '../common/UserSession';

interface MenuItem {
  title: string;
  icon: string;
  url: string;
}

@Entry
@Component
struct ProfilePage {
  @State profile: UserProfileVO | null = null;
  @State isLoading: boolean = true;

  private menuItems: MenuItem[] = [
    { title: '编辑资料', icon: '✏️', url: 'pages/EditProfilePage' },
    { title: '修改密码', icon: '🔒', url: 'pages/ChangePasswordPage' },
    { title: '消息通知', icon: '🔔', url: 'pages/NotificationPage' },
    { title: '我的点评', icon: '📝', url: 'pages/PostListPage' },
    { title: '注销账号', icon: '⚠️', url: 'pages/CancelAccountPage' },
    { title: '关于应用', icon: 'ℹ️', url: 'pages/AboutPage' }
  ];

  aboutToAppear(): void {
    if (AppUtil.redirectIfAdmin()) {
      return;
    }
    if (!AppUtil.requireLogin()) {
      return;
    }
    this.loadProfile();
  }

  private async loadProfile(): Promise<void> {
    this.isLoading = true;
    this.profile = await HotelApi.getProfile();
    this.isLoading = false;
  }

  private async logout(): Promise<void> {
    await UserSession.clear();
    AppUtil.toast('已退出登录');
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  @Builder
  MenuRow(item: MenuItem) {
    Row() {
      Text(item.icon)
        .fontSize(20)
      Text(item.title)
        .fontSize(15)
        .fontColor('#0F172A')
        .margin({ left: 14 })
        .layoutWeight(1)
      Text('›')
        .fontSize(20)
        .fontColor('#CBD5E1')
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      router.pushUrl({ url: item.url });
    })
  }

  build() {
    Column() {
      Column() {
        if (this.isLoading) {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#2563EB')
        } else {
          Row() {
            Image(getUserAvatarRes())
              .width(72)
              .height(72)
              .borderRadius(36)
              .objectFit(ImageFit.Cover)
              .border({ width: 2, color: 'rgba(255,255,255,0.6)' })

            Column({ space: 6 }) {
              Text(this.profile?.username ?? UserSession.getUsername())
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text(this.profile?.phone ?? UserSession.getPhone())
                .fontSize(14)
                .fontColor('rgba(255,255,255,0.88)')
              if (this.profile?.email) {
                Text(this.profile.email)
                  .fontSize(12)
                  .fontColor('rgba(255,255,255,0.75)')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 16 })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 48, bottom: 28 })
      .linearGradient({
        angle: 120,
        colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
      })

      Scroll() {
        Column({ space: 0 }) {
          ForEach(this.menuItems, (item: MenuItem) => {
            Column() {
              this.MenuRow(item)
              Divider()
                .color('#F1F5F9')
                .margin({ left: 50 })
            }
          }, (item: MenuItem) => item.url)

          Button('退出登录')
            .width('100%')
            .height(48)
            .fontSize(15)
            .fontColor('#EF4444')
            .backgroundColor('#FEF2F2')
            .borderRadius(12)
            .margin({ top: 24 })
            .onClick(() => {
              this.logout();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 20, topRight: 20 })
        .margin({ top: -12 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      BottomTabBar({ currentIndex: 3 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
