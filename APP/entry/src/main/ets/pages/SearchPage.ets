import router from '@ohos.router';
import { HotelListRow, openHotelDetail } from '../common/HotelComponents';
import { HotelApi } from '../common/HotelApi';
import { FORM_CARET_COLOR, FORM_PLACEHOLDER_COLOR, FORM_TEXT_COLOR } from '../common/InputStyles';
import { HotelVO, SelectOptionItem } from '../common/Types';
import { PageHeader } from '../common/PageHeader';

const SEARCH_CITY_OPTIONS: SelectOptionItem[] = [
  { value: '全部城市' },
  { value: '上海' },
  { value: '北京' },
  { value: '南京' },
  { value: '杭州' },
  { value: '广州' },
  { value: '深圳' }
];

@Entry
@Component
struct SearchPage {
  @State keyword: string = '';
  @State selectedCity: string = '全部城市';
  @State hotels: HotelVO[] = [];
  @State recommendHotels: HotelVO[] = [];
  @State isLoading: boolean = false;
  @State hasSearched: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.city && params.city.length > 0) {
      this.selectedCity = params.city;
      this.doSearch();
    }
    this.loadRecommend();
  }

  private async loadRecommend(): Promise<void> {
    this.recommendHotels = await HotelApi.getRecommended(6);
  }

  private getCityIndex(): number {
    for (let i = 0; i < SEARCH_CITY_OPTIONS.length; i++) {
      if (SEARCH_CITY_OPTIONS[i].value === this.selectedCity) {
        return i;
      }
    }
    return 0;
  }

  private async doSearch(): Promise<void> {
    this.isLoading = true;
    this.hasSearched = true;
    const city = this.selectedCity !== '全部城市' ? this.selectedCity : undefined;
    const kw = this.keyword.trim().length > 0 ? this.keyword.trim() : undefined;
    this.hotels = await HotelApi.getHotels(city, kw);
    this.isLoading = false;
  }

  private getFilteredRecommend(): HotelVO[] {
    if (!this.hasSearched || this.hotels.length === 0) {
      return this.recommendHotels;
    }
    const result: HotelVO[] = [];
    for (let i = 0; i < this.recommendHotels.length; i++) {
      let exists = false;
      for (let j = 0; j < this.hotels.length; j++) {
        if (this.recommendHotels[i].id === this.hotels[j].id) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        result.push(this.recommendHotels[i]);
      }
    }
    return result;
  }

  @Builder
  RecommendSection() {
    Column({ space: 12 }) {
      Row() {
        Text(this.hasSearched ? '猜你还喜欢' : '为你推荐')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')
        Blank()
        Text(`${this.getFilteredRecommend().length} 家`)
          .fontSize(12)
          .fontColor('#94A3B8')
      }
      .width('100%')

      ForEach(this.getFilteredRecommend(), (hotel: HotelVO) => {
        Column() {
          HotelListRow({ hotel: hotel })
        }
        .onClick(() => {
          openHotelDetail(hotel);
        })
      }, (hotel: HotelVO) => `rec-${hotel.id}`)
    }
    .width('100%')
  }

  build() {
    Column() {
      PageHeader({ title: '搜索酒店', showBack: true })

      Column({ space: 12 }) {
        Row({ space: 10 }) {
          Select(SEARCH_CITY_OPTIONS)
            .selected(this.getCityIndex())
            .value(this.selectedCity)
            .font({ size: 14, weight: FontWeight.Medium })
            .fontColor('#0F172A')
            .backgroundColor('#F8FAFC')
            .onSelect((_index: number, value: string) => {
              this.selectedCity = value;
              this.doSearch();
            })
            .width(110)

          Row() {
            Text('🔍')
              .fontSize(14)
              .margin({ left: 12, right: 8 })
            TextInput({ text: this.keyword, placeholder: '酒店名 / 品牌 / 地标' })
              .layoutWeight(1)
              .height(44)
              .fontSize(14)
              .backgroundColor(Color.Transparent)
              .fontColor(FORM_TEXT_COLOR)
              .placeholderColor(FORM_PLACEHOLDER_COLOR)
              .caretColor(FORM_CARET_COLOR)
              .onChange((v: string) => {
                this.keyword = v;
              })
              .onSubmit(() => {
                this.doSearch();
              })
          }
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F8FAFC')
          .borderRadius(12)
          .border({ width: 1, color: '#E2E8F0' })
        }
        .width('100%')

        Button('搜索')
          .width('100%')
          .height(44)
          .fontSize(15)
          .fontColor(Color.White)
          .borderRadius(12)
          .linearGradient({
            angle: 120,
            colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
          })
          .onClick(() => {
            this.doSearch();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#2563EB')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            if (this.hasSearched && this.hotels.length > 0) {
              Column({ space: 12 }) {
                Text(`搜索结果 · 共 ${this.hotels.length} 家`)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#0F172A')
                  .width('100%')

                ForEach(this.hotels, (hotel: HotelVO) => {
                  Column() {
                    HotelListRow({ hotel: hotel })
                  }
                  .onClick(() => {
                    openHotelDetail(hotel);
                  })
                }, (hotel: HotelVO) => `s-${hotel.id}`)
              }
              .width('100%')
            }

            if (this.hasSearched && this.hotels.length === 0) {
              Column({ space: 8 }) {
                Text('未找到完全匹配的酒店')
                  .fontSize(15)
                  .fontColor('#64748B')
                Text('为您展示推荐酒店')
                  .fontSize(13)
                  .fontColor('#94A3B8')
              }
              .width('100%')
              .padding({ top: 8, bottom: 4 })
            }

            if (!this.hasSearched) {
              Text('输入关键词搜索，或浏览下方推荐酒店')
                .fontSize(13)
                .fontColor('#94A3B8')
                .width('100%')
            }

            if (this.getFilteredRecommend().length > 0) {
              this.RecommendSection()
            }
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
