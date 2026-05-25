import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { NotificationVO } from '../common/Types';
import { UserSession } from '../common/UserSession';

@Entry
@Component
struct NotificationPage {
  @State notifications: NotificationVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    UserSession.init(getContext(this) as Context);
    if (!AppUtil.requireLogin()) {
      return;
    }
    this.loadAndMarkRead();
  }

  private async loadAndMarkRead(): Promise<void> {
    this.isLoading = true;
    await HotelApi.markAllNotificationsRead();
    this.notifications = await HotelApi.getMyNotifications();
    this.isLoading = false;
  }

  build() {
    Column() {
      PageHeader({ title: '消息通知', showBack: true })

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#2563EB')
          .layoutWeight(1)
      } else if (this.notifications.length === 0) {
        Column({ space: 8 }) {
          Text('暂无通知')
            .fontSize(16)
            .fontColor('#64748B')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.notifications, (item: NotificationVO) => {
              Column({ space: 8 }) {
                Row() {
                  Text(item.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#0F172A')
                    .layoutWeight(1)

                  if (!item.isRead) {
                    Text('●')
                      .fontSize(10)
                      .fontColor('#2563EB')
                  }
                }
                .width('100%')

                Text(item.content)
                  .fontSize(14)
                  .fontColor('#64748B')
                  .width('100%')

                Text(item.createTime)
                  .fontSize(12)
                  .fontColor('#94A3B8')
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(14)
              .shadow({ radius: 10, color: 'rgba(15,23,42,0.05)', offsetY: 3 })
            }, (item: NotificationVO) => `ntf-${item.id}`)
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
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
