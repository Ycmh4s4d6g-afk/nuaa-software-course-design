import router from '@ohos.router';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    router.replaceUrl({ url: 'pages/SplashPage' }).catch((err: Error) => {
      console.error(`跳转启动页失败: ${err.message}`);
    });
  }

  build() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#2563EB')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F4F6FB')
  }
}
