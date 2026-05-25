import { HotelListRow, openHotelDetail } from '../common/HotelComponents';
import { HotelApi } from '../common/HotelApi';
import { CITY_LIST, CITY_SELECT_OPTIONS } from '../common/MockData';
import { PageHeader } from '../common/PageHeader';
import { HotelVO } from '../common/Types';

interface FilterOption {
  value: string;
}

const TYPE_OPTIONS: FilterOption[] = [
  { value: '全部类型' },
  { value: '豪华' },
  { value: '高档' },
  { value: '商务' },
  { value: '度假' }
];

const SORT_OPTIONS: FilterOption[] = [
  { value: '默认排序' },
  { value: '价格升序' },
  { value: '价格降序' },
  { value: '评分优先' }
];

@Entry
@Component
struct HotelListPage {
  @State selectedCity: string = '上海';
  @State selectedType: string = '全部类型';
  @State selectedSort: string = '默认排序';
  @State hotels: HotelVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadHotels();
  }

  private async loadHotels(): Promise<void> {
    this.isLoading = true;
    let list = await HotelApi.getHotels(this.selectedCity);
    if (this.selectedType !== '全部类型') {
      list = list.filter((h: HotelVO) => h.hotelType === this.selectedType);
    }
    if (this.selectedSort === '价格升序') {
      list.sort((a: HotelVO, b: HotelVO) => a.minPrice - b.minPrice);
    } else if (this.selectedSort === '价格降序') {
      list.sort((a: HotelVO, b: HotelVO) => b.minPrice - a.minPrice);
    } else if (this.selectedSort === '评分优先') {
      list.sort((a: HotelVO, b: HotelVO) => b.rating - a.rating);
    }
    this.hotels = list;
    this.isLoading = false;
  }

  build() {
    Column() {
      PageHeader({ title: '酒店列表', showBack: true })

      Row({ space: 8 }) {
        Select(CITY_SELECT_OPTIONS)
          .selected(CITY_LIST.indexOf(this.selectedCity))
          .value(this.selectedCity)
          .font({ size: 13 })
          .onSelect((_i: number, v: string) => {
            this.selectedCity = v;
            this.loadHotels();
          })
          .layoutWeight(1)

        Select(TYPE_OPTIONS)
          .selected(0)
          .value(this.selectedType)
          .font({ size: 13 })
          .onSelect((_i: number, v: string) => {
            this.selectedType = v;
            this.loadHotels();
          })
          .layoutWeight(1)

        Select(SORT_OPTIONS)
          .selected(0)
          .value(this.selectedSort)
          .font({ size: 13 })
          .onSelect((_i: number, v: string) => {
            this.selectedSort = v;
            this.loadHotels();
          })
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#2563EB')
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.hotels, (hotel: HotelVO) => {
              Column() {
                HotelListRow({ hotel: hotel })
              }
              .onClick(() => {
                openHotelDetail(hotel);
              })
            }, (hotel: HotelVO) => `list-${hotel.id}`)
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 24 })
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
