import router from '@ohos.router';
import { AppUtil } from './HotelApi';

@Component
export struct BottomTabBar {
  @Prop currentIndex: number = 0;

  private goTab(index: number): void {
    if (AppUtil.isAdminUser()) {
      AppUtil.redirectIfAdmin();
      return;
    }
    if (index === this.currentIndex) {
      return;
    }

    let url = 'pages/HomePage';
    if (index === 1) {
      url = 'pages/ReservationListPage';
    } else if (index === 2) {
      url = 'pages/CollectionPage';
    } else if (index === 3) {
      url = 'pages/ProfilePage';
    }

    router.replaceUrl({ url: url }).catch((err: Error) => {
      console.error(`Tab 跳转失败: ${err.message}`);
    });
  }

  @Builder
  TabItem(index: number, icon: string, label: string) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(20)
      Text(label)
        .fontSize(11)
        .fontColor(this.currentIndex === index ? '#2563EB' : '#94A3B8')
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
    }
    .layoutWeight(1)
    .padding({ top: 8, bottom: 8 })
    .onClick(() => {
      this.goTab(index);
    })
  }

  build() {
    Row() {
      this.TabItem(0, '🏠', '首页')
      this.TabItem(1, '📄', '订单')
      this.TabItem(2, '❤️', '收藏')
      this.TabItem(3, '👤', '我的')
    }
    .width('100%')
    .height(64)
    .padding({ left: 8, right: 8, bottom: 8 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 12,
      color: 'rgba(15, 23, 42, 0.08)',
      offsetX: 0,
      offsetY: -2
    })
  }
}
