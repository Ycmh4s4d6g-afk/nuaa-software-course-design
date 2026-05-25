import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { AdminStatsVO, PaymentMethodStatVO } from '../common/Types';
import { UserSession } from '../common/UserSession';

interface AdminMenuItem {
  title: string;
  desc: string;
  icon: string;
  url: string;
}

@Entry
@Component
struct AdminHomePage {
  @State stats: AdminStatsVO | null = null;
  @State isLoading: boolean = true;
  @State adminName: string = '';

  private menuItems: AdminMenuItem[] = [
    { title: '用户管理', desc: '查看用户账号与状态', icon: '👤', url: 'pages/AdminUserListPage' },
    { title: '酒店管理', desc: '查看与维护酒店信息', icon: '🏩', url: 'pages/AdminHotelListPage' },
    { title: '订单管理', desc: '审核预订与订单状态', icon: '📑', url: 'pages/AdminReservationListPage' },
    { title: '评论审核', desc: '管理酒店评价与审核', icon: '📝', url: 'pages/AdminPostListPage' },
    { title: '支付记录', desc: '查看订单支付流水', icon: '💰', url: 'pages/AdminPaymentListPage' },
    { title: '收藏管理', desc: '查看用户收藏记录', icon: '⭐', url: 'pages/AdminCollectionListPage' },
    { title: '通知中心', desc: '系统通知与消息', icon: '🔔', url: 'pages/AdminNotificationListPage' },
    { title: '发送通知', desc: '向指定用户发送通知', icon: '📨', url: 'pages/AdminSendNotificationPage' }
  ];

  aboutToAppear(): void {
    UserSession.init(getContext(this) as Context).then(() => {
      if (!AppUtil.requireAdmin()) {
        return;
      }
      this.adminName = UserSession.getUsername();
      this.loadStats();
    });
  }

  onPageShow(): void {
    if (AppUtil.isAdminUser()) {
      this.loadStats();
    }
  }

  private async loadStats(): Promise<void> {
    this.isLoading = true;
    this.stats = await HotelApi.getAdminStats();
    this.isLoading = false;
  }

  private async logout(): Promise<void> {
    await UserSession.clear();
    AppUtil.toast('已退出管理员登录');
    router.replaceUrl({ url: 'pages/AdminLoginPage' });
  }

  @Builder
  StatCard(label: string, value: string) {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E40AF')
      Text(label)
        .fontSize(12)
        .fontColor('#64748B')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  MenuCard(item: AdminMenuItem) {
    Column({ space: 8 }) {
      Text(item.icon)
        .fontSize(36)
      Text(item.title)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0F172A')
      Text(item.desc)
        .fontSize(12)
        .fontColor('#64748B')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 12, color: 'rgba(15,23,42,0.06)', offsetY: 4 })
    .onClick(() => {
      router.pushUrl({ url: item.url });
    })
  }

  build() {
    Column() {
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text('管理后台')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Text(`您好，${this.adminName}`)
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.88)')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('退出')
            .fontSize(14)
            .fontColor(Color.White)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('rgba(255,255,255,0.18)')
            .borderRadius(8)
            .onClick(() => {
              this.logout();
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 48, bottom: 20 })
      .linearGradient({
        angle: 120,
        colors: [['#1E3A8A', 0.0], ['#1E40AF', 1.0]]
      })

      Scroll() {
        Column({ space: 16 }) {
          if (this.isLoading) {
            LoadingProgress()
              .width(36)
              .height(36)
              .color('#1E40AF')
          } else if (this.stats) {
            Column({ space: 12 }) {
              Text('数据概览')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#0F172A')
                .width('100%')

              Row({ space: 10 }) {
                Column() {
                  this.StatCard('用户数', `${this.stats.userCount}`)
                }
                .layoutWeight(1)
                Column() {
                  this.StatCard('酒店数', `${this.stats.hotelCount}`)
                }
                .layoutWeight(1)
              }
              .width('100%')

              Row({ space: 10 }) {
                Column() {
                  this.StatCard('订单数', `${this.stats.reservationCount}`)
                }
                .layoutWeight(1)
                Column() {
                  this.StatCard('待审订单', `${this.stats.pendingReservationCount}`)
                }
                .layoutWeight(1)
              }
              .width('100%')

              Row({ space: 10 }) {
                Column() {
                  this.StatCard('已支付总额', `¥${this.stats.paidAmountTotal}`)
                }
                .layoutWeight(1)
                Column() {
                  this.StatCard('待审评论', `${this.stats.pendingPostCount}`)
                }
                .layoutWeight(1)
              }
              .width('100%')

              Row({ space: 10 }) {
                Column() {
                  this.StatCard('今日订单', `${this.stats.todayReservationCount ?? 0}`)
                }
                .layoutWeight(1)
                Column() {
                  this.StatCard('今日营业额', `¥${this.stats.todayPaidAmount ?? 0}`)
                }
                .layoutWeight(1)
              }
              .width('100%')

              Row({ space: 10 }) {
                Column() {
                  this.StatCard('评论已通过', `${this.stats.approvedPostCount ?? 0}`)
                }
                .layoutWeight(1)
                Column() {
                  this.StatCard('评论已驳回', `${this.stats.rejectedPostCount ?? 0}`)
                }
                .layoutWeight(1)
              }
              .width('100%')

              if (this.stats.paymentMethodStats && this.stats.paymentMethodStats.length > 0) {
                Column({ space: 8 }) {
                  Text('支付方式统计')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#475569')
                    .width('100%')
                  ForEach(this.stats.paymentMethodStats, (item: PaymentMethodStatVO) => {
                    Row() {
                      Text(item.paymentMethod)
                        .fontSize(13)
                        .fontColor('#64748B')
                        .layoutWeight(1)
                      Text(`${item.count}笔 / ¥${item.amount}`)
                        .fontSize(13)
                        .fontColor('#1E40AF')
                    }
                    .width('100%')
                    .padding(10)
                    .backgroundColor('#F8FAFC')
                    .borderRadius(8)
                  }, (item) => item.paymentMethod)
                }
                .width('100%')
              }
            }
            .width('100%')
          }

          Column({ space: 12 }) {
            Text('管理功能')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
              .width('100%')

            ForEach(this.menuItems, (item: AdminMenuItem) => {
              this.MenuCard(item)
            }, (item: AdminMenuItem) => item.url)
          }
          .width('100%')
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#EEF2FF')
    }
    .width('100%')
    .height('100%')
  }
}
