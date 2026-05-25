import router from '@ohos.router';

@Component
export struct PageHeader {
  @Prop title: string = '';
  @Prop showBack: boolean = true;
  @Prop useGradient: boolean = true;

  build() {
    if (this.useGradient) {
      Column() {
        Row() {
          if (this.showBack) {
            Text('←')
              .fontSize(22)
              .fontColor(Color.White)
              .onClick(() => { router.back(); })
          }
          Text(this.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ left: this.showBack ? 12 : 0 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 48, bottom: 16 })
      }
      .width('100%')
      .linearGradient({
        angle: 120,
        colors: [['#3B82F6', 0.0], ['#2563EB', 1.0]]
      })
    } else {
      Row() {
        if (this.showBack) {
          Text('←')
            .fontSize(22)
            .fontColor('#2563EB')
            .onClick(() => { router.back(); })
        }
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')
          .margin({ left: this.showBack ? 12 : 0 })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 48, bottom: 16 })
      .backgroundColor(Color.White)
    }
  }
}
