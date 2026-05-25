import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { PostVO } from '../common/Types';

@Entry
@Component
struct AdminPostListPage {
  @State posts: PostVO[] = [];
  @State isLoading: boolean = true;

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
    this.posts = await HotelApi.getAdminPosts();
    this.isLoading = false;
  }

  private async approvePost(postId: number): Promise<void> {
    const res = await HotelApi.approveAdminPost(postId, '审核通过');
    if (res.code !== 200) {
      AppUtil.toast(res.message || '审核失败');
      return;
    }
    AppUtil.toast('已通过');
    this.loadData();
  }

  private async rejectPost(postId: number): Promise<void> {
    const res = await HotelApi.rejectAdminPost(postId, '内容不符合规范');
    if (res.code !== 200) {
      AppUtil.toast(res.message || '操作失败');
      return;
    }
    AppUtil.toast('已拒绝');
    this.loadData();
  }

  private async deletePost(postId: number): Promise<void> {
    const ok = await AppUtil.confirm('确认删除该评论？');
    if (!ok) {
      return;
    }
    const res = await HotelApi.deleteAdminPost(postId);
    if (res.code !== 200) {
      AppUtil.toast(res.message || '删除失败');
      return;
    }
    AppUtil.toast('已删除');
    this.loadData();
  }

  build() {
    Column() {
      PageHeader({ title: '评论审核', showBack: true })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.posts, (item: PostVO) => {
              Column({ space: 8 }) {
                Row() {
                  Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#0F172A').layoutWeight(1)
                  Text(AppUtil.postAuditText(item.auditStatus))
                    .fontSize(11)
                    .fontColor(item.auditStatus === 'APPROVED' ? '#22C55E' : '#F97316')
                }.width('100%')

                Text(item.content).fontSize(13).fontColor('#64748B').width('100%')
                Text(`${item.username} · ${item.hotelName} · ⭐${item.rating}`)
                  .fontSize(12).fontColor('#94A3B8').width('100%')

                Row({ space: 8 }) {
                  if (item.auditStatus === 'PENDING') {
                    Button('通过')
                      .height(32).fontSize(12).fontColor(Color.White).backgroundColor('#22C55E').layoutWeight(1)
                      .onClick(() => { this.approvePost(item.id); })
                    Button('拒绝')
                      .height(32).fontSize(12).fontColor(Color.White).backgroundColor('#F97316').layoutWeight(1)
                      .onClick(() => { this.rejectPost(item.id); })
                  }
                  Button('删除')
                    .height(32).fontSize(12).fontColor(Color.White).backgroundColor('#EF4444').layoutWeight(1)
                    .onClick(() => { this.deletePost(item.id); })
                }.width('100%')
              }
              .width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
            }, (item: PostVO) => `p-${item.id}`)
          }.padding(16)
        }.layoutWeight(1).scrollBar(BarState.Off)
      }
    }.width('100%').height('100%').backgroundColor('#EEF2FF')
  }
}
