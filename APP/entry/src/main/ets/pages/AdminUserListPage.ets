import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { AdminUserVO } from '../common/Types';

@Entry
@Component
struct AdminUserListPage {
  @State users: AdminUserVO[] = [];
  @State isLoading: boolean = true;
  @State keyword: string = '';

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
    this.users = await HotelApi.getAdminUsers(this.keyword);
    this.isLoading = false;
  }

  private async toggleStatus(user: AdminUserVO, status: string): Promise<void> {
    if (user.role === 'ADMIN') {
      return;
    }
    const msg = status === 'DISABLED' ? '确认禁用该用户？' : '确认恢复该用户？';
    const ok = await AppUtil.confirm(msg);
    if (!ok) {
      return;
    }
    const res = await HotelApi.updateAdminUserStatus(user.id, status);
    if (res.code !== 200) {
      AppUtil.toast(res.message || '操作失败');
      return;
    }
    AppUtil.toast('操作成功');
    this.loadData();
  }

  build() {
    Column() {
      PageHeader({ title: '用户管理', showBack: true })

      Row({ space: 8 }) {
        TextInput({ text: this.keyword, placeholder: '搜索姓名/手机号' })
          .layoutWeight(1)
          .height(40)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => { this.keyword = v; })
        Button('搜索')
          .height(40)
          .fontSize(13)
          .fontColor(Color.White)
          .backgroundColor('#1E40AF')
          .onClick(() => { this.loadData(); })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.users, (user: AdminUserVO) => {
              Column({ space: 8 }) {
                Row() {
                  Text(user.username).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#0F172A').layoutWeight(1)
                  Text(AppUtil.userRoleText(user.role)).fontSize(12).fontColor('#64748B')
                }.width('100%')
                Text(`用户ID：${user.id}`)
                  .fontSize(13)
                  .fontColor('#1E40AF')
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                Text(`手机：${user.phone}`).fontSize(13).fontColor('#64748B').width('100%')
                Text(`状态：${AppUtil.userStatusText(user.status)}`)
                  .fontSize(13).fontColor(user.status === 'NORMAL' ? '#22C55E' : '#EF4444').width('100%')

                if (user.role !== 'ADMIN') {
                  Row({ space: 8 }) {
                    if (user.status === 'NORMAL') {
                      Button('禁用').height(32).fontSize(12).fontColor(Color.White).backgroundColor('#EF4444')
                        .onClick(() => { this.toggleStatus(user, 'DISABLED'); })
                    } else if (user.status === 'DISABLED') {
                      Button('恢复').height(32).fontSize(12).fontColor(Color.White).backgroundColor('#22C55E')
                        .onClick(() => { this.toggleStatus(user, 'NORMAL'); })
                    }
                  }
                }
              }
              .width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
            }, (user: AdminUserVO) => `u-${user.id}`)
          }.padding(16)
        }.layoutWeight(1).scrollBar(BarState.Off)
      }
    }.width('100%').height('100%').backgroundColor('#EEF2FF')
  }
}
