import router from '@ohos.router';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { PageHeader } from '../common/PageHeader';
import { RoomTypeVO } from '../common/Types';

@Entry
@Component
struct AdminRoomTypeListPage {
  @State hotelId: number = 0;
  @State hotelName: string = '';
  @State roomTypes: RoomTypeVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (!AppUtil.requireAdmin()) {
      return;
    }
    const params = router.getParams() as Record<string, string>;
    this.hotelId = Number(params['hotelId'] ?? '0');
    this.hotelName = params['hotelName'] ?? '酒店';
    if (this.hotelId > 0) {
      this.loadData();
    }
  }

  onPageShow(): void {
    if (AppUtil.isAdminUser() && this.hotelId > 0) {
      this.loadData();
    }
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;
    this.roomTypes = await HotelApi.getRoomTypes(this.hotelId);
    this.isLoading = false;
  }

  private goEdit(roomTypeId: number): void {
    router.pushUrl({
      url: 'pages/AdminRoomTypeEditPage',
      params: {
        hotelId: `${this.hotelId}`,
        hotelName: this.hotelName,
        roomTypeId: `${roomTypeId}`
      }
    });
  }

  private goAdd(): void {
    router.pushUrl({
      url: 'pages/AdminRoomTypeEditPage',
      params: {
        hotelId: `${this.hotelId}`,
        hotelName: this.hotelName,
        roomTypeId: '0'
      }
    });
  }

  private async deleteRoom(rt: RoomTypeVO): Promise<void> {
    const ok = await AppUtil.confirm(`确认删除房型「${rt.roomName}」？`);
    if (!ok) {
      return;
    }
    const res = await HotelApi.deleteAdminRoomType(rt.id);
    if (res.code !== 200) {
      AppUtil.toast(res.message || '删除失败');
      return;
    }
    AppUtil.toast('已删除');
    this.loadData();
  }

  build() {
    Column() {
      PageHeader({ title: '房型管理', showBack: true })

      Text(this.hotelName)
        .fontSize(14)
        .fontColor('#64748B')
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })

      Row() {
        Button('+ 添加房型')
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#22C55E')
          .onClick(() => {
            this.goAdd();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8 })

      if (this.hotelId <= 0) {
        Text('请先保存酒店信息')
          .fontSize(14)
          .fontColor('#EF4444')
          .layoutWeight(1)
      } else if (this.isLoading) {
        LoadingProgress().width(36).height(36).color('#1E40AF').layoutWeight(1)
      } else if (this.roomTypes.length === 0) {
        Column({ space: 8 }) {
          Text('暂无房型')
            .fontSize(15)
            .fontColor('#64748B')
          Text('用户预订前必须先添加至少一个房型')
            .fontSize(13)
            .fontColor('#94A3B8')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.roomTypes, (rt: RoomTypeVO) => {
              Column({ space: 8 }) {
                Text(rt.roomName.length > 0 ? rt.roomName : '未命名房型')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#0F172A')
                  .width('100%')
                Text(`${rt.bedType} · ${rt.maxGuests}人 · ¥${rt.price}/晚`)
                  .fontSize(13)
                  .fontColor('#64748B')
                  .width('100%')
                Text(`总${rt.totalRooms ?? rt.stock}间 · 可订${rt.stock}间`)
                  .fontSize(12)
                  .fontColor('#94A3B8')
                  .width('100%')

                Row({ space: 8 }) {
                  Button('编辑')
                    .height(32)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .backgroundColor('#2563EB')
                    .layoutWeight(1)
                    .onClick(() => {
                      this.goEdit(rt.id);
                    })
                  Button('删除')
                    .height(32)
                    .fontSize(12)
                    .fontColor(Color.White)
                    .backgroundColor('#EF4444')
                    .layoutWeight(1)
                    .onClick(() => {
                      this.deleteRoom(rt);
                    })
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
            }, (rt: RoomTypeVO) => `rt-${rt.id}`)
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF2FF')
  }
}
