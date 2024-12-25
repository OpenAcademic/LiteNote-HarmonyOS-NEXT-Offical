import { bundleManager } from '@kit.AbilityKit';

@Entry
@Component
struct AppInfoPage {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Column() {
        Column() {
          Text("关于红宝书")
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 20, bottom: 10 })
          // Image($r('app.media.logo')).width('50%')
          Row(){
            Text("红").fontSize(50).fontWeight(FontWeight.Bolder).fontColor(Color.Red)
            Text("宝书").fontSize(50).fontWeight(FontWeight.Bolder).fontColor(Color.Blue)

          }.width('100%').margin({
            top:20
          }).justifyContent(FlexAlign.Center)
          Text("您的万能工具箱").fontSize(15).margin({
            bottom:10
          }).fontWeight(FontWeight.Bolder)
          Column(){
            Row(){
              Text("版本编号").fontSize(15).margin(20).fontWeight(FontWeight.Bolder)
              Text(bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).versionName).fontSize(15).margin(20).fontWeight(FontWeight.Bolder).fontSize(15).margin(20).fontWeight(FontWeight.Bolder)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
            Row(){
              Text("版本代码").fontSize(15).margin(20).fontWeight(FontWeight.Bolder)
              Text(bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).versionCode.toString()).fontSize(15).margin(20).fontWeight(FontWeight.Bolder)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
            Row(){
              Text("构建类型").fontSize(15).margin(20).fontWeight(FontWeight.Bolder)
              Text(bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).appInfo.releaseType.toString()).fontSize(15).margin(20).fontWeight(FontWeight.Bolder).fontSize(15).margin(20).fontWeight(FontWeight.Bolder)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
            Row(){
              Text("安装来源").fontSize(15).margin(20).fontWeight(FontWeight.Bolder)
              Text(bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).appInfo.installSource.toString()).fontSize(15).margin(20).fontWeight(FontWeight.Bolder).fontSize(15).margin(20).fontWeight(FontWeight.Bolder)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)


          }.width('90%').padding(10).backgroundColor(
            $r('sys.color.ohos_id_color_sub_background')
          ).margin(10).borderRadius(20)



        }.alignItems(HorizontalAlign.Center)
      }
    }
    .height('100%')
    .width('100%')
  }
}