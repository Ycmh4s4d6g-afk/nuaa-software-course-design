import { ApiConfig } from '../common/ApiConfig';
import { PageHeader } from '../common/PageHeader';

@Entry
@Component
struct AboutPage {
  build() {
    Column() {
      PageHeader({ title: '关于应用', showBack: true })

      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 12 }) {
            Column() {
              Text('🏨')
                .fontSize(40)
            }
            .width(80)
            .height(80)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#EFF6FF')
            .borderRadius(20)

            Text('酒店推荐预订系统')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')

            Text('HarmonyOS NEXT 客户端')
              .fontSize(14)
              .fontColor('#64748B')

            Text('版本 1.0.0')
              .fontSize(13)
              .fontColor('#94A3B8')
          }
          .width('100%')
          .padding(28)
          .backgroundColor(Color.White)
          .borderRadius(16)

          Column({ space: 12 }) {
            Text('应用介绍')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
              .width('100%')

            Text('本应用提供酒店搜索、预订、订单管理、收藏与点评等功能，帮助用户便捷完成出行住宿安排。')
              .fontSize(14)
              .fontColor('#64748B')
              .lineHeight(22)
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start)

          Column({ space: 12 }) {
            Text('服务配置')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
              .width('100%')

            Row() {
              Text('API 模式')
                .fontSize(14)
                .fontColor('#94A3B8')
              Blank()
              Text(ApiConfig.USE_MOCK ? '本地 Mock' : '远程服务器')
                .fontSize(14)
                .fontColor('#2563EB')
            }
            .width('100%')

            Row() {
              Text('服务器地址')
                .fontSize(14)
                .fontColor('#94A3B8')
              Blank()
              Text(ApiConfig.SERVER_HOST)
                .fontSize(13)
                .fontColor('#0F172A')
                .maxLines(2)
                .textAlign(TextAlign.End)
                .constraintSize({ maxWidth: '60%' })
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start)

          Text('© 2026 酒店推荐预订系统')
            .fontSize(12)
            .fontColor('#CBD5E1')
            .margin({ top: 8 })
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6FB')
  }
}
