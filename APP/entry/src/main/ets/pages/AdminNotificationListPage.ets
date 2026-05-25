import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';
import { AdminCreateNotificationRequest, NotificationVO } from '../common/Types';

@Entry
@Component
struct AdminNotificationListPage {
  @State notifications: NotificationVO[] = [];
  @State isLoading: boolean = true;
  @State showForm: boolean = false;
  @State targetUserId: string = '';
  @State notifyTitle: string = '';
  @State notifyContent: string = '';
  @State isSubmitting: boolean = false;

  aboutToAppear(): void {
    if (!AppUtil.requireAdmin()) {
      return;
    }
    this.loadData();
  }

  onPageShow(): void {
    if (AppUtil.isAdminUser()) {
      this.loadData();
    }
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;
    this.notifications = await HotelApi.getAdminNotifications();
    this.isLoading = false;
  }

  private async sendNotification(): Promise<void> {
    const userId = Number(this.targetUserId);
    if (isNaN(userId) || userId <= 0 || this.notifyTitle.trim().length === 0 ||
      this.notifyContent.trim().length === 0) {
      AppUtil.toast('请填写完整通知信息');
      return;
    }
    this.isSubmitting = true;
    const req: AdminCreateNotificationRequest = {
      userId: userId,
      title: this.notifyTitle.trim(),
      content: this.notifyContent.trim(),
      type: 'SYSTEM',
      channel: 'APP'
    };
    const res = await HotelApi.createAdminNotification(req);
    this.isSubmitting = false;
    if (res.code !== 200) {
      AppUtil.toast(res.message || '发送失败');
      return;
    }
    AppUtil.toast('通知已发送');
    this.showForm = false;
    this.targetUserId = '';
    this.notifyTitle = '';
    this.notifyContent = '';
    this.loadData();
  }

  build() {
    Column() {
      PageHeader({ title: '通知中心', showBack: true })

      Row() {
        Button(this.showForm ? '收起表单' : '+ 发送通知')
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#1E40AF')
          .onClick(() => { this.showForm = !this.showForm; })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      if (this.showForm) {
        Column({ space: 10 }) {
          TextInput({ text: this.targetUserId, placeholder: '用户ID（在「用户管理」中查看）' })
            .width('100%').height(40).backgroundColor(Color.White).borderRadius(8)
            .type(InputType.Number)
            .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
            .onChange((v: string) => { this.targetUserId = v; })
          TextInput({ text: this.notifyTitle, placeholder: '通知标题' })
            .width('100%').height(40).backgroundColor(Color.White).borderRadius(8)
            .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
            .onChange((v: string) => { this.notifyTitle = v; })
          TextArea({ text: this.notifyContent, placeholder: '通知内容' })
            .width('100%').height(80).backgroundColor(Color.White).borderRadius(8)
            .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR)
            .onChange((v: string) => { this.notifyContent = v; })
          Button(this.isSubmitting ? '发送中...' : '发送')
            .width('100%').height(40).fontColor(Color.White).backgroundColor('#22C55E')
            .enabled(!this.isSubmitting).onClick(() => { this.sendNotification(); })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })
      }

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.notifications, (item: NotificationVO) => {
              Column({ space: 6 }) {
                Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#0F172A').width('100%')
                Text(`用户：${item.username ?? item.userId ?? '-'}`)
                  .fontSize(12).fontColor('#94A3B8').width('100%')
                Text(item.content).fontSize(13).fontColor('#64748B').width('100%')
                Text(`${item.createTime} · ${item.isRead ? '已读' : '未读'}`)
                  .fontSize(12).fontColor('#94A3B8').width('100%')
              }
              .width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
            }, (item: NotificationVO) => `n-${item.id}`)
          }.padding(16)
        }.layoutWeight(1).scrollBar(BarState.Off)
      }
    }.width('100%').height('100%').backgroundColor('#EEF2FF')
  }
}
