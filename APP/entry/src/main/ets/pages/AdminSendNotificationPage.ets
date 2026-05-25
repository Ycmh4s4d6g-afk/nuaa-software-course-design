import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';
import { AdminCreateNotificationRequest, AdminUserVO } from '../common/Types';

@Entry
@Component
struct AdminSendNotificationPage {
  @State users: AdminUserVO[] = [];
  @State selectedUserId: number = 0;
  @State notifyTitle: string = '';
  @State notifyContent: string = '';
  @State isLoading: boolean = true;
  @State isSubmitting: boolean = false;

  aboutToAppear(): void {
    if (!AppUtil.requireAdmin()) {
      return;
    }
    this.loadUsers();
  }

  private async loadUsers(): Promise<void> {
    this.isLoading = true;
    const list = await HotelApi.getAdminUsers('');
    this.users = list.filter((u) => u.status === 'NORMAL' && u.role === 'CUSTOMER');
    if (this.users.length > 0) {
      this.selectedUserId = this.users[0].id;
    }
    this.isLoading = false;
  }

  private async send(): Promise<void> {
    if (this.selectedUserId <= 0 || this.notifyTitle.trim().length === 0 ||
      this.notifyContent.trim().length === 0) {
      AppUtil.toast('请完整填写通知信息');
      return;
    }
    this.isSubmitting = true;
    const req: AdminCreateNotificationRequest = {
      userId: this.selectedUserId,
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
    router.back();
  }

  build() {
    Column() {
      PageHeader({ title: '发送通知', showBack: true })
      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Text('选择用户并填写标题、内容，将实时推送到 App/Web 通知中心')
              .fontSize(13).fontColor('#64748B').width('100%')
            Text('选择用户 *').fontSize(14).fontColor('#475569').width('100%')
            Select(this.users.map((u) => ({ value: `${u.username}（${u.phone}）` })))
              .selected(this.users.findIndex((u) => u.id === this.selectedUserId))
              .onSelect((index: number) => {
                if (index >= 0 && index < this.users.length) {
                  this.selectedUserId = this.users[index].id;
                }
              })
              .width('100%')
            TextInput({ text: this.notifyTitle, placeholder: '通知标题' })
              .width('100%').height(48).backgroundColor('#F8FAFC').borderRadius(12)
              .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
              .onChange((v: string) => { this.notifyTitle = v; })
            TextArea({ text: this.notifyContent, placeholder: '通知内容' })
              .width('100%').height(120).backgroundColor('#F8FAFC').borderRadius(12)
              .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
              .onChange((v: string) => { this.notifyContent = v; })
            Button(this.isSubmitting ? '发送中...' : '发送通知')
              .width('100%').height(48).fontColor(Color.White).backgroundColor('#22C55E')
              .enabled(!this.isSubmitting)
              .onClick(() => { this.send(); })
          }.padding(16)
        }.layoutWeight(1)
      }
    }.width('100%').height('100%').backgroundColor('#EEF2FF')
  }
}
