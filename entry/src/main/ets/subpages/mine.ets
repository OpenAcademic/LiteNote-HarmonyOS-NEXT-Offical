import { List } from "@kit.ArkTS"
import { router } from "@kit.ArkUI"
import { bundleManager } from "@kit.AbilityKit"


class  MenuItemMine{
  name:string = ""
  func:() => void = () => {}

  constructor(name:string,func:()=>void) {
    this.name = name
    this.func=func
  }
}
@Component
export struct MinePage {
  @State menus : MenuItemMine[] = []

  aboutToAppear(): void {
    let n : List<MenuItemMine> = new List()
    let func = ()=>{
      router.pushUrl({
        url:"pages/WebViewPage",
        params:{
          url:"ysxy.html",
          local:true
        }
      })
    }
    n.add(new MenuItemMine(
      "隐私协议",func
    ))
    n.add(new MenuItemMine(
      "设置",()=>{
        router.pushUrl({
          url:"pages/SettingsPage"
        })
      }
    ))
    this.menus = n.convertToArray()

  }

  build() {
    Column(){
      Column(){
        Text("关于我们")
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 10 })
       // Image($r('app.media.logo')).width('50%')
        Text("红宝书").fontSize(50).margin({
          top:20
        }).fontWeight(FontWeight.Bolder)

        Text("v"+bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).versionName+"("+bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).versionCode+")").fontSize(15).margin({
          bottom:20
        }).fontWeight(FontWeight.Bolder)
        Grid(){
          ForEach(this.menus,(item: MenuItemMine) =>{
            GridItem(){
              Row(){
                Text(item.name).fontSize(25)
              }.width('100%').alignItems(VerticalAlign.Center).onClick(e=>{
                item.func()
              })
              .justifyContent(FlexAlign.Center).padding(10)
            }.width('100%')
          })
        }.width('90%').margin('4%').backgroundColor(
          $r('sys.color.ohos_id_color_toolbar_sub_bg')
        ).borderRadius('5%')

      }
      // Image($r('app.media.slogin')).width('50%')
    }.width('100%').height('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(HorizontalAlign.Center).padding({
      top:'20%'
    })
  }
}