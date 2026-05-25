import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { PostVO } from '../common/Types';
import { UserSession } from '../common/UserSession';

@Entry
@Component
struct PostListPage {
  @State posts: PostVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    UserSession.init(getContext(this) as Context);
    if (!AppUtil.requireLogin()) {
      return;
    }
    this.loadPosts();
  }

  private async loadPosts(): Promise<void> {
    this.isLoading = true;
    this.posts = await HotelApi.getMyPosts();
    this.isLoading = false;
  }

  build() {
    Column() {
      PageHeader({ title: '我的点评', showBack: true })

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#2563EB')
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            if (this.posts.length === 0) {
              Text('暂无点评，快来分享入住体验吧')
                .fontSize(14)
                .fontColor('#94A3B8')
                .margin({ top: 40 })
            } else {
              ForEach(this.posts, (item: PostVO) => {
                Column({ space: 8 }) {
                  Text(item.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#0F172A')
                    .width('100%')

                  Text(item.content)
                    .fontSize(14)
                    .fontColor('#64748B')
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  Row() {
                    Text(`🏨 ${item.hotelName}`)
                      .fontSize(12)
                      .fontColor('#64748B')
                    Blank()
                    Text(`⭐ ${item.rating}`)
                      .fontSize(12)
                      .fontColor('#F97316')
                  }
                  .width('100%')

                  Row() {
                    Text(item.auditStatus === 'APPROVED' ? '已通过' : item.auditStatus)
                      .fontSize(11)
                      .fontColor(item.auditStatus === 'APPROVED' ? '#22C55E' : '#F97316')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor('#F8FAFC')
                      .borderRadius(6)

                    if (item.createTime) {
                      Text(item.createTime)
                        .fontSize(11)
                        .fontColor('#94A3B8')
                        .margin({ left: 12 })
                    }
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(16)
                .backgroundColor(Color.White)
                .borderRadius(14)
                .shadow({ radius: 10, color: 'rgba(15,23,42,0.05)', offsetY: 3 })
              }, (item: PostVO) => `post-${item.id}`)
            }
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 80 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      Button('+ 发布点评')
        .width('90%')
        .height(48)
        .fontSize(15)
        .fontColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 24 })
        .linearGradient({
          angle: 120,
          colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
        })
        .onClick(() => {
          router.pushUrl({ url: 'pages/CreatePostPage' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
