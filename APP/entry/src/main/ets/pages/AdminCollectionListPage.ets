import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { AdminCollectionVO } from '../common/Types';

@Entry
@Component
struct AdminCollectionListPage {
  @State collections: AdminCollectionVO[] = [];
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
    this.collections = await HotelApi.getAdminCollections();
    this.isLoading = false;
  }

  private getHotelName(item: AdminCollectionVO): string {
    if (item.hotel && item.hotel.hotelName.length > 0) {
      return item.hotel.hotelName;
    }
    return item.hotelName.length > 0 ? item.hotelName : '-';
  }

  private getHotelCity(item: AdminCollectionVO): string {
    if (item.hotel) {
      return item.hotel.city;
    }
    return '-';
  }

  private async deleteItem(item: AdminCollectionVO): Promise<void> {
    const ok = await AppUtil.confirm('确认删除该收藏记录？');
    if (!ok) {
      return;
    }
    const res = await HotelApi.deleteAdminCollection(item.id);
    if (res.code !== 200) {
      AppUtil.toast(res.message || '删除失败');
      return;
    }
    AppUtil.toast('已删除');
    this.loadData();
  }

  build() {
    Column() {
      PageHeader({ title: '收藏管理', showBack: true })

      if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.collections, (item: AdminCollectionVO) => {
              Column({ space: 6 }) {
                Text(this.getHotelName(item))
                  .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#0F172A').width('100%')
                Text(`用户：${item.username}`)
                  .fontSize(13).fontColor('#64748B').width('100%')
                Text(`城市：${this.getHotelCity(item)}`)
                  .fontSize(13).fontColor('#64748B').width('100%')

                Button('删除')
                  .height(32).fontSize(12).fontColor(Color.White).backgroundColor('#EF4444')
                  .onClick(() => { this.deleteItem(item); })
              }
              .width('100%').padding(16).backgroundColor(Color.White).borderRadius(12)
            }, (item: AdminCollectionVO) => `c-${item.id}`)
          }.padding(16)
        }.layoutWeight(1).scrollBar(BarState.Off)
      }
    }.width('100%').height('100%').backgroundColor('#EEF2FF')
  }
}
