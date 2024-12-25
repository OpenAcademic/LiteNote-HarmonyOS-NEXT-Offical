import { List } from "@kit.ArkTS"
import { router } from "@kit.ArkUI"
import { bundleManager } from "@kit.AbilityKit"
import { getUserInfo, UserInfo } from "../service/api"
import { TongyiDialog, TongyiDialogConfig } from "../dialog/started"
import { dataPreferences } from "../entryability/EntryAbility"
import { BusinessError } from "@kit.BasicServicesKit"
import { preferences } from "@kit.ArkData"
import { removekey } from "../service/kv"


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
  @State skey : string  = ""
  @ObjectLink userinfo : UserInfo
  @Link have_userinfo : boolean
  tongyi = async ()=>{
    if (await removekey("userKey")){
      let  p = await getUserInfo()
      if (p){
        this.userinfo = p
      } else{
        this.have_userinfo = false
      }
    }

  }
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TongyiDialog({
      config: new TongyiDialogConfig(
        "您是否同意退出登录",
        this.tongyi
      )
    }),
    openAnimation: {
      duration: 1200,
      curve: Curve.LinearOutSlowIn,
      delay: 500,
      playMode: PlayMode.Alternate,
      onFinish: () => {
        console.info('play end')
      }
    },
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    backgroundBlurStyle:BlurStyle.Thick,
    cornerRadius: 20,
  })

  async onPageShow() {

  }


  async aboutToAppear() {
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
      "更多设置",()=>{
      router.pushUrl({
        url:"pages/SettingsPage"
      })
    }
    ))
    n.add(new MenuItemMine(
      "隐私协议",func
    ))
    n.add(new MenuItemMine(
      "用户协议",() =>{
      router.pushUrl({
        url:"pages/WebViewPage",
        params:{
          url:"yhxy.html",
          local:true
        }
      })
    }
    ))

    n.add(new MenuItemMine(
      "关于应用",() =>{
      router.pushUrl({
        url:"pages/AppInfoPage",

      })
    }
    ))

    n.add(new MenuItemMine(
      "退出登录",() =>{
      if (this.have_userinfo){
        if (this.dialogController){
          this.dialogController.open()
        }
      }

    }
    ))
    this.menus = n.convertToArray()



  }

  build() {
    Column(){
      Column(){

        if (this.have_userinfo){
          Column(){
            Image(this.userinfo.userImage).size(
              {
                width:100,
                height:100
              }
            ).borderRadius(
              99999
            )
            Text(this.userinfo.userNickName)
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 20, bottom: 10 })
          }.width('100%').justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }else{
          Text("您还没有登陆哦")
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 20, bottom: 10 })
          Button(){
            Text("去登陆")
          }.width('50%').fontColor(Color.White).padding(10).margin({
            bottom:25
          }).onClick(e=>{

            router.pushUrl({
              url:"pages/LoginPage",

            })
          })
        }

        Grid(){
          ForEach(this.menus,(item: MenuItemMine) =>{
            GridItem(){
              Row(){
                Text(item.name).fontSize(20)
              }.width('100%').alignItems(VerticalAlign.Center).onClick(e=>{
                item.func()
              })
              .justifyContent(FlexAlign.Center).padding(15)
            }.width('100%')
          })
        }.width('90%').margin('4%').backgroundColor(
          $r('sys.color.ohos_id_color_toolbar_sub_bg')
        ).borderRadius('5%')
        Text("AI生成式服务由百度文心大模型提供").fontSize(15)
          .fontWeight(FontWeight.Lighter).fontColor(Color.Gray)
          .fontStyle(FontStyle.Italic)
        Text("Powered by BAIDU AI").fontSize(15)
          .fontWeight(FontWeight.Lighter).fontColor(Color.Gray)
          .fontStyle(FontStyle.Italic)

      }
      // Image($r('app.media.slogin')).width('50%')
    }.width('100%').height('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(HorizontalAlign.Center).padding({
      top:'20%'
    })
  }
}