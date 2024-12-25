import { webview } from '@kit.ArkWeb'
import { url } from '@kit.ArkTS'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct WebViewPage {
  @State url: string  = ""
  @State local: boolean = true

  private webviewController: WebviewController = new webview.WebviewController()
  // 页面每次显示时都会调用该函数，这里用于测试接收页面传参
  onPageShow(): void {
    if (router.getParams() !== undefined && router.getParams() !== null) {
      let record = router.getParams() as Record<string, string | boolean>;
      if (record !== undefined && record !== null) {
        let msg = record['url']
        this.url = msg as string
        this.local = record['local'] as boolean
        console.log("sd",this.url,this.local)
        console.log("sd2",record['url'],record['local'])

      }
    }
  }

  aboutToAppear(): void {
  }
  build() {
    Column() {
      Text($r('app.string.privacy')).fontSize(30).margin(
        {
          top:30
        }
      ).fontWeight(FontWeight.Bolder).width("100%").textAlign(TextAlign.Center)
      if (this.url){
        Web({
          src: $rawfile(this.url) ,
          controller: this.webviewController,
          renderMode: RenderMode.ASYNC_RENDER // 设置渲染模式
        }).width('100%').height('90%').padding({
          bottom:20
        })
      }else{
        LoadingProgress()
      }

    }
    .height('100%')
    .width('100%').backgroundColor(
      Color.Transparent
    )
  }
}