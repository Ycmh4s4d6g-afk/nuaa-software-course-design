import router from '@ohos.router';
import { BottomTabBar } from '../common/BottomTabBar';
import { HotelCover, HotelListRow, openHotelDetail } from '../common/HotelComponents';
import { AppUtil, HotelApi } from '../common/HotelApi';
import { getBannerImageRes, getUserAvatarRes } from '../common/HotelImageUtil';
import { BANNER_LIST, CITY_LIST, CITY_SELECT_OPTIONS } from '../common/MockData';
import { BannerItem, HotelVO } from '../common/Types';
import { UserSession } from '../common/UserSession';

@Entry
@Component
struct HomePage {
  private readonly bannerHeight: number = 200;
  @State selectedCity: string = '上海';
  @State nickname: string = '用户';
  @State recommendHotels: HotelVO[] = [];
  @State hotHotels: HotelVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    UserSession.init(getContext(this) as Context).then(() => {
      if (AppUtil.redirectIfAdmin()) {
        return;
      }
      this.nickname = UserSession.getUsername().length > 0 ? UserSession.getUsername() : '用户';
      this.loadData();
    });
  }

  onPageShow(): void {
    UserSession.init(getContext(this) as Context).then(() => {
      AppUtil.redirectIfAdmin();
    });
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;
    this.recommendHotels = await HotelApi.getRecommended(10);
    this.hotHotels = await HotelApi.getHotels(this.selectedCity);
    this.isLoading = false;
  }

  private onCityChange(_index: number, value: string): void {
    this.selectedCity = value;
    this.loadData();
  }

  @Builder
  RecommendCard(hotel: HotelVO) {
    Column() {
      HotelCover({ hotel: hotel, coverHeight: 120, radius: 14 })

      Column({ space: 6 }) {
        Text(hotel.hotelName)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#0F172A')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text(`⭐ ${hotel.rating}`)
            .fontSize(12)
            .fontColor('#F97316')
          Text(`${hotel.city}`)
            .fontSize(11)
            .fontColor('#94A3B8')
            .margin({ left: 8 })
        }

        Row() {
          Text('¥')
            .fontSize(12)
            .fontColor('#EF4444')
          Text(`${hotel.minPrice}`)
            .fontSize(18)
            .fontColor('#EF4444')
            .fontWeight(FontWeight.Bold)
          Text(' 起')
            .fontSize(11)
            .fontColor('#94A3B8')
        }
      }
      .width('100%')
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width(180)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .shadow({ radius: 16, color: 'rgba(15,23,42,0.08)', offsetY: 4 })
    .onClick(() => {
      openHotelDetail(hotel);
    })
  }

  @Builder
  TopSearchBar() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text('酒店推荐预订')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text(`你好，${this.nickname}`)
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.88)')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image(getUserAvatarRes())
          .width(44)
          .height(44)
          .borderRadius(22)
          .objectFit(ImageFit.Cover)
          .border({ width: 2, color: 'rgba(255,255,255,0.5)' })
          .onClick(() => {
            router.pushUrl({ url: 'pages/ProfilePage' });
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Row({ space: 10 }) {
        Row({ space: 6 }) {
          Text('📍')
            .fontSize(14)
          Select(CITY_SELECT_OPTIONS)
            .selected(CITY_LIST.indexOf(this.selectedCity))
            .value(this.selectedCity)
            .font({ size: 15, weight: FontWeight.Medium })
            .fontColor('#0F172A')
            .backgroundColor(Color.Transparent)
            .onSelect((_index: number, value: string) => {
              this.onCityChange(_index, value);
            })
        }
        .height(44)
        .padding({ left: 12, right: 12 })
        .backgroundColor(Color.White)
        .borderRadius(12)

        Row() {
          Text('🔍')
            .fontSize(14)
            .margin({ left: 12, right: 8 })
          Text('搜索酒店 / 品牌 / 地标')
            .layoutWeight(1)
            .fontSize(14)
            .fontColor('#94A3B8')
        }
        .layoutWeight(1)
        .height(44)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SearchPage',
            params: { city: this.selectedCity }
          });
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 48, bottom: 20 })
    .linearGradient({
      angle: 120,
      colors: [['#3B82F6', 0.0], ['#2563EB', 0.6], ['#1D4ED8', 1.0]]
    })
  }

  build() {
    Column() {
      this.TopSearchBar()

      Scroll() {
        Column() {
          Swiper() {
            ForEach(BANNER_LIST, (banner: BannerItem) => {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(getBannerImageRes(banner.id))
                  .width('100%')
                  .height(this.bannerHeight)
                  .borderRadius(16)
                  .objectFit(ImageFit.Cover)

                Column({ space: 6 }) {
                  Text(banner.title)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                  Text(banner.subtitle)
                    .fontSize(13)
                    .fontColor('rgba(255,255,255,0.92)')
                }
                .width('100%')
                .padding(20)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0.0], ['rgba(0,0,0,0.55)', 1.0]]
                })
              }
              .width('100%')
              .height(this.bannerHeight)
              .borderRadius(16)
              .clip(true)
            }, (banner: BannerItem) => `${banner.id}`)
          }
          .width('100%')
          .height(this.bannerHeight)
          .autoPlay(true)
          .interval(3500)
          .indicator(true)
          .loop(true)
          .padding({ left: 16, right: 16, top: 16 })

          Column({ space: 12 }) {
            Row() {
              Column({ space: 4 }) {
                Text('为你推荐')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#0F172A')
                Text('精选高评分热门酒店')
                  .fontSize(12)
                  .fontColor('#94A3B8')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Text('更多')
                .fontSize(13)
                .fontColor('#2563EB')
                .onClick(() => {
                  router.pushUrl({ url: 'pages/HotelListPage' });
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.recommendHotels, (hotel: HotelVO) => {
                  this.RecommendCard(hotel)
                }, (hotel: HotelVO) => `rec-${hotel.id}`)
              }
              .padding({ left: 16, right: 16 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .margin({ top: 20 })

          Column({ space: 12 }) {
            Row() {
              Column({ space: 4 }) {
                Text('热门酒店')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#0F172A')
                Text(`${this.selectedCity} · 口碑优选`)
                  .fontSize(12)
                  .fontColor('#94A3B8')
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

            if (this.isLoading) {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#2563EB')
                .margin({ top: 40 })
            } else {
              Column({ space: 12 }) {
                ForEach(this.hotHotels, (hotel: HotelVO) => {
                  Column() {
                    HotelListRow({ hotel: hotel })
                  }
                  .onClick(() => {
                    openHotelDetail(hotel);
                  })
                }, (hotel: HotelVO) => `hot-${hotel.id}`)
              }
              .padding({ left: 16, right: 16 })
            }
          }
          .margin({ top: 20, bottom: 16 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#F4F6FB')

      BottomTabBar({ currentIndex: 0 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
