import router from '@ohos.router';
import { HotelVO } from './Types';
import { getHotelImageRes } from './HotelImageUtil';
import { createEmptyHotel } from './Types';

@Component
export struct HotelCover {
  @Prop hotel: HotelVO = createEmptyHotel();
  @Prop coverHeight: number = 120;
  @Prop radius: number = 14;

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(getHotelImageRes(this.hotel.id, this.hotel.hotelName))
        .width('100%')
        .height(this.coverHeight)
        .borderRadius(this.radius)
        .objectFit(ImageFit.Cover)

      if (this.hotel.tag) {
        Row() {
          Text(this.hotel.tag)
            .fontSize(11)
            .fontColor(Color.White)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('rgba(0,0,0,0.35)')
            .borderRadius(999)
        }
        .width('100%')
        .padding({ left: 12, bottom: 12 })
      }
    }
    .width('100%')
    .height(this.coverHeight)
    .clip(true)
  }
}

@Component
export struct HotelListRow {
  @Prop hotel: HotelVO = createEmptyHotel();

  build() {
    Row({ space: 12 }) {
      HotelCover({ hotel: this.hotel, coverHeight: 100, radius: 12 })
        .width(100)

      Column({ space: 6 }) {
        Text(this.hotel.hotelName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${this.hotel.city} · ${this.hotel.hotelType}`)
          .fontSize(12)
          .fontColor('#64748B')

        Row() {
          Text(`⭐ ${this.hotel.rating}`)
            .fontSize(13)
            .fontColor('#F97316')
          Blank()
          Text('¥')
            .fontSize(12)
            .fontColor('#EF4444')
          Text(`${this.hotel.minPrice}`)
            .fontSize(20)
            .fontColor('#EF4444')
            .fontWeight(FontWeight.Bold)
          Text(' 起')
            .fontSize(11)
            .fontColor('#94A3B8')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 12, color: 'rgba(15,23,42,0.06)', offsetY: 4 })
  }
}

export function openHotelDetail(hotel: HotelVO): void {
  router.pushUrl({
    url: 'pages/HotelDetailPage',
    params: {
      hotelId: `${hotel.id}`,
      hotelName: hotel.hotelName,
      city: hotel.city,
      rating: `${hotel.rating}`,
      minPrice: `${hotel.minPrice}`
    }
  });
}
