import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { PageHeader } from '../common/PageHeader';
import { CreatePostRequest, ReservationVO } from '../common/Types';

@Entry
@Component
struct CreatePostPage {
  @State reviewable: ReservationVO[] = [];
  @State selectedIndex: number = 0;
  @State title: string = '';
  @State content: string = '';
  @State score: number = 5;
  @State isSubmitting: boolean = false;
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (!AppUtil.requireLogin()) {
      return;
    }
    this.loadReviewable();
  }

  private async loadReviewable(): Promise<void> {
    this.isLoading = true;
    this.reviewable = await HotelApi.getReviewableReservations();
    this.isLoading = false;
  }

  private async submitPost(): Promise<void> {
    if (this.reviewable.length === 0) {
      AppUtil.toast('暂无已完成订单可评论');
      return;
    }
    if (this.title.trim().length === 0 || this.content.trim().length === 0) {
      AppUtil.toast('请填写标题和内容');
      return;
    }
    const order = this.reviewable[this.selectedIndex];
    this.isSubmitting = true;
    const req: CreatePostRequest = {
      hotelId: order.hotelId,
      reservationId: order.id,
      title: this.title.trim(),
      content: this.content.trim(),
      score: this.score
    };
    const res = await HotelApi.createPost(req);
    this.isSubmitting = false;
    if (res.code !== 200) {
      AppUtil.toast(res.message || '发布失败');
      return;
    }
    AppUtil.toast('发布成功，等待审核');
    router.replaceUrl({ url: 'pages/PostListPage' });
  }

  build() {
    Column() {
      PageHeader({ title: '发布点评', showBack: true })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#2563EB').layoutWeight(1)
      } else if (this.reviewable.length === 0) {
        Column({ space: 8 }) {
          Text('暂无已完成订单')
            .fontSize(16)
            .fontColor('#64748B')
          Text('仅「已完成」订单可发表评论')
            .fontSize(13)
            .fontColor('#94A3B8')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Column({ space: 8 }) {
              Text('选择已完成订单')
                .fontSize(14)
                .fontColor('#475569')
                .width('100%')
              ForEach(this.reviewable, (order: ReservationVO, index: number) => {
                Row() {
                  Column({ space: 4 }) {
                    Text(order.hotelName)
                      .fontSize(15)
                      .fontColor(this.selectedIndex === index ? '#2563EB' : '#0F172A')
                    Text(`${order.reservationNo} · ${order.checkInDate}`)
                      .fontSize(12)
                      .fontColor('#94A3B8')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  if (this.selectedIndex === index) {
                    Text('✓').fontColor('#2563EB')
                  }
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.selectedIndex === index ? '#EFF6FF' : '#F8FAFC')
                .borderRadius(10)
                .onClick(() => { this.selectedIndex = index; })
              }, (order: ReservationVO) => `rv-${order.id}`)
            }
            .width('100%')

            TextInput({ text: this.title, placeholder: '评论标题' })
              .width('100%').height(48).backgroundColor('#F8FAFC').borderRadius(12)
              .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR).caretColor(FORM_CARET_COLOR)
              .onChange((v: string) => { this.title = v; })

            TextArea({ text: this.content, placeholder: '分享真实入住体验（勿含联系方式/广告）' })
              .width('100%').height(120).backgroundColor('#F8FAFC').borderRadius(12)
              .fontColor(FORM_TEXT_COLOR).placeholderColor(FORM_PLACEHOLDER_COLOR)
              .onChange((v: string) => { this.content = v; })

            Button(this.isSubmitting ? '提交中...' : '提交点评')
              .width('100%').height(48).fontColor(Color.White).backgroundColor('#2563EB')
              .enabled(!this.isSubmitting)
              .onClick(() => { this.submitPost(); })
          }
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
