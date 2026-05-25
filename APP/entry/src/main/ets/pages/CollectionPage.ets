import { AppUtil, HotelApi } from '../common/HotelApi';
import { BottomTabBar } from '../common/BottomTabBar';
import { HotelListRow, openHotelDetail } from '../common/HotelComponents';
import { getMockHotelById } from '../common/MockData';
import { CollectionVO, HotelVO } from '../common/Types';

@Entry
@Component
struct CollectionPage {
  @State collections: CollectionVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppUtil.redirectIfAdmin()) {
      return;
    }
    if (!AppUtil.requireLogin()) {
      return;
    }
    this.loadCollections();
  }

  private async loadCollections(): Promise<void> {
    this.isLoading = true;
    this.collections = await HotelApi.getMyCollections();
    this.isLoading = false;
  }

  private async removeCollection(item: CollectionVO): Promise<void> {
    const res = await HotelApi.removeCollection(item.id);
    if (res.code !== 200) {
      AppUtil.toast(res.message || '取消收藏失败');
      return;
    }
    AppUtil.toast('已取消收藏');
    await this.loadCollections();
  }

  private toHotelVO(item: CollectionVO): HotelVO {
    const mock = getMockHotelById(item.hotelId);
    if (mock) {
      return mock;
    }
    const hotel: HotelVO = {
      id: item.hotelId,
      hotelName: item.hotelName,
      city: item.city,
      hotelType: '酒店',
      rating: item.rating,
      minPrice: item.minPrice
    };
    return hotel;
  }

  build() {
    Column() {
      Column() {
        Text('我的收藏')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')
        Text('快速查看您收藏的酒店')
          .fontSize(13)
          .fontColor('#64748B')
          .margin({ top: 6 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 20, right: 20, top: 48, bottom: 16 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#2563EB')
          .layoutWeight(1)
      } else if (this.collections.length === 0) {
        Column({ space: 12 }) {
          Text('❤️')
            .fontSize(48)
          Text('暂无收藏')
            .fontSize(16)
            .fontColor('#64748B')
          Text('收藏酒店后将显示在这里')
            .fontSize(13)
            .fontColor('#94A3B8')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.collections, (item: CollectionVO) => {
              Column({ space: 8 }) {
                Column() {
                  HotelListRow({ hotel: this.toHotelVO(item) })
                }
                .onClick(() => {
                  openHotelDetail(this.toHotelVO(item));
                })

                Button('取消收藏')
                  .width('100%')
                  .height(40)
                  .fontSize(14)
                  .fontColor('#EF4444')
                  .backgroundColor('#FEF2F2')
                  .borderRadius(10)
                  .onClick(() => {
                    this.removeCollection(item);
                  })
              }
            }, (item: CollectionVO) => `col-${item.id}`)
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      BottomTabBar({ currentIndex: 2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
