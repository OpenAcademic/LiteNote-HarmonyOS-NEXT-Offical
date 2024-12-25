import { webview } from "@kit.ArkWeb"
import { dataPreferences, store } from "../entryability/EntryAbility"
import { preferences, relationalStore } from "@kit.ArkData"
import { BusinessError } from "@kit.BasicServicesKit"
import { promptAction } from "@kit.ArkUI"
import { Express } from "../entity/express"
import { Port } from "../entity/port"
import { Code } from "../entity/code"
import { List } from "@kit.ArkTS"
import { init } from "@umeng/analytics"

@Observed
export class TongyiDialogConfig {
  message : string
  tongyi: () => void

  constructor(mess:string,t:() => void) {
    this.message = mess
    this.tongyi = t
  }
}

@CustomDialog
export struct AddExpressDialog {
  @State express_input: string = ""
  onClickOK?: () => void;
  controller?: CustomDialogController

  build() {
    Column() {
      Text("添加快递公司")
        .id('AddCodePageHelloWorld')
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center).margin({
        bottom:15
      })

      TextInput({
        placeholder: "请输入短信中的快递（不包含‘快递’）"
      }).width('100%').padding(15).onChange((value: string) => {
        this.express_input = value
        console.info(value);
      })
      // this.last_codes
      Row() {
        Button("添加").width('100%')
      }.width('100%').justifyContent(FlexAlign.Center).margin({
        top: 10
      })
      .onClick(e => {
        if (this.express_input == '') {
          promptAction.showToast({
            message: "您输入的快递为空",
            duration: 1500
          })
          return
        }
        let reg = ''
        if (store!= undefined) {
          let id = Express.insert_express(
            store, new Express(0, this.express_input + "快递", "", this.express_input)
          )
          if (id === -1) {
            return
          }
          if (this.onClickOK) {
            this.onClickOK()
        // 主体
          }
          this.controller?.close()
        }

      })

    }.padding(20).margin(20)
    .width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Start)
  }

}

@CustomDialog
export struct AddPortDialog {
  @State port_local_input: string = ""
  @State port_input: string = ""

  onClickOK?: () => void;
  controller?: CustomDialogController

  build() {
    Column() {
      Text("添加快递驿站")
        .id('AddCodePageHelloWorld')
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center).margin({
        bottom:15
      })

      TextInput({
        placeholder: "请输入短信中的驿站名称（务必一致）"
      }).width('100%').padding(15).onChange((value: string) => {
        this.port_input = value
        console.info(value);
      })
      TextInput({
        placeholder: "请输入短信中的驿站地址"
      }).width('100%').padding(15).onChange((value: string) => {
        this.port_local_input = value
        console.info(value);
      }).margin({
        top:10,
        bottom:10
      })
      // this.last_codes
      Row() {
        Button("添加").width('100%')
      }.width('100%').justifyContent(FlexAlign.Center).margin({
        top: 10
      })
      .onClick(e => {
        if (this.port_input == '') {
          promptAction.showToast({
            message: "您输入的驿站名称为空",
            duration: 1500
          })
          return
        }
        if (this.port_local_input == '') {
          promptAction.showToast({
            message: "您输入的驿站地址为空",
            duration: 1500
          })
          return
        }
        let reg = ''
        // 菜鸟驿站首尔龙山店
        // 大韩民国首尔特别市龙山总统府
        if (store!= undefined) {
          let id = Port.insert_formats(
            store, new Port(0, this.port_input, this.port_local_input , this.port_input)
          )
          if (id === -1) {
            return
          }
          if (this.onClickOK) {
            this.onClickOK()
            // 主体
          }
          this.controller?.close()
        }

      })

    }.padding(20).margin(20)
    .width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Start)
  }

}

@CustomDialog
export struct EditDialog{
  controller?: CustomDialogController
  tongyi?: () => void

  @ObjectLink code:Code
  @State express_regs : string[] = []
  @State expresses : SelectOption[] = []
  @State express_select : number = 0

  @State port_regs : string[] = []
  @State ports : SelectOption[] = []
  @State port_select : number = 0
  @State code_input : string = ""
  @State status: boolean = false
  loadSelectOptiopn(){
    // { value: 'aaa', icon: "/common/public_icon.svg" }
    this.express_regs.forEach((value,index)=>{
      this.expresses.push({value:value})
    })
    this.express_select = this.express_regs.indexOf(this.code.express)!=-1?this.express_regs.indexOf(this.code.express):0
    this.port_regs.forEach((value,index)=>{
      this.ports.push({value:value})
    })
    this.port_select = this.port_regs.indexOf(this.code.port)!=-1?this.port_regs.indexOf(this.code.port):0
    this.status = this.code.status == 1
  }
  aboutToAppear(): void {
    if(store != undefined) {
      let mStore = (store as relationalStore.RdbStore);
      let dreg = [
        "中通",
        "圆通",
        "百世",
        "申通",
        "邮政",
        "德邦",
        "韵达",
        "极兔",
        "京东",
        "顺丰",
        "汇通"
      ]
      this.express_regs = dreg.concat(Express.load_all_expresses(mStore))
      this.port_regs = Port.load_all_ports(mStore).convertToArray()
      this.loadSelectOptiopn()


    }
  }
  build() {
    Column() {
      Text("编辑取件码"+this.code.code).fontSize(20).margin(
        {
          top:30
        }
      ).fontWeight(FontWeight.Bolder)
      Row(){
        Text("取件码").fontSize(20).fontWeight(FontWeight.Bolder)
        TextInput({
          placeholder: "请输入短信中的取件码",
          text: this.code.code
        }).width('70%').padding(15).onChange((value: string) => {
          this.code_input = value
          console.info(value);
        })
      }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween).padding(20)
      Row(){
        Text("快递").fontSize(20).fontWeight(FontWeight.Bolder)
        Select(this.expresses)
          .selected(this.express_select)
          .value(this.expresses[this.express_select].value)
          .font({ size: 16, weight: 500 })
          .fontColor('#182431')
          .selectedOptionFont({ size: 16, weight: 400 })
          .optionFont({ size: 16, weight: 400 })
          .onSelect((index: number) => {
            this.express_select = index
            console.info('Select:' + index)
          })
      }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween).padding(20)
      Row(){
        Text("驿站").fontSize(20).fontWeight(FontWeight.Bolder)
        Select(this.ports)
          .selected(this.port_select)
          .value(this.ports[this.port_select].value)
          .font({ size: 16, weight: 500 })
          .fontColor('#182431')
          .selectedOptionFont({ size: 16, weight: 400 })
          .optionFont({ size: 16, weight: 400 })
          .onSelect((index: number) => {
            this.port_select = index
            console.info('Select:' + index)
          })
      }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween).padding(20)


      Row(){
        Button("取消").width('30%').onClick(e=>{
          this.controller?.close()

        }).backgroundColor(Color.Red)
        Button("确定").width('30%').onClick(e=>{
          if (this.code_input == '') {
            promptAction.showToast({
              message: "您输入的取件码为空",
              duration: 1500
            })
            return
          }
          let code2 = new Code(
            0,
            this.code_input,
            this.expresses[this.express_select].value.toString(),
            this.ports[this.port_select].value.toString(),
            this.code.status,
          )

          if (store){
            let num = Code.update_by_code(store,this.code.code,code2)
            if (num){
              promptAction.showToast({
                message: "成功",
                duration: 1500
              })
            }else{
              promptAction.showToast({
                message: "失败",
                duration: 1500
              })
            }
          }else{
            promptAction.showToast({
              message: "失败",
              duration: 1500
            })
          }

          if (this.tongyi){
            this.tongyi()

          }
          this.controller?.close()

        })
      }.width('100%').margin(20).padding({
        left:20,right:20
      }).justifyContent(FlexAlign.SpaceAround)
    }.width('100%').borderRadius(25).alignItems(HorizontalAlign.Center).justifyContent(
      FlexAlign.Start
    ).backgroundColor(Color.Transparent).backgroundBlurStyle(BlurStyle.Regular)
  }
}

@CustomDialog
export struct TongyiDialog {
  controller?: CustomDialogController
  @ObjectLink config:TongyiDialogConfig

  build() {
    Column() {
      Text(this.config.message).fontSize(20).margin(
        {
          top:30
        }
      ).fontWeight(FontWeight.Bolder)
      Row(){
        Button("拒绝").width('30%').onClick(e=>{
          this.controller?.close()

        })
        Button("同意").width('30%').onClick(e=>{
          this.config.tongyi()

          this.controller?.close()


        })
      }.width('100%').margin(20).padding({
        left:20,right:20
      }).justifyContent(FlexAlign.SpaceAround)
    }.width('100%').borderRadius(25).alignItems(HorizontalAlign.Center).justifyContent(
      FlexAlign.Start
    ).backgroundColor(Color.Transparent).backgroundBlurStyle(BlurStyle.Regular)
  }
}
@CustomDialog
export struct PrivacyDialog {
  controller?: CustomDialogController
  @State is_updated : boolean = false
  private webviewController: WebviewController = new webview.WebviewController()

  build() {
    Column() {
      if (!this.is_updated) {
        Text($r('app.string.privacy')).fontSize(30).margin(
          {
            top:30
          }
        ).fontWeight(FontWeight.Bolder)
        Text("我们最近更新了隐私协议").fontSize(15).margin(
          {
            top:10
          }
        ).fontWeight(FontWeight.Bolder)
      }else{
        Text($r('app.string.privacy')).fontSize(30).margin(
          {
            top:30
          }
        ).fontWeight(FontWeight.Bolder)
      }

      Web({
        src: $rawfile('ysxy.html'),
        controller: this.webviewController,
        renderMode: RenderMode.ASYNC_RENDER // 设置渲染模式
      }).width('90%').height(this.is_updated?'80%':'70%').backgroundColor(
        Color.Transparent
      )
      Row(){
        Button("拒绝").width('30%').onClick(e=>{
          if (dataPreferences !== undefined) {
            let mdataPreferences = dataPreferences as  preferences.Preferences
            if (!this.is_updated) {
              mdataPreferences.putSync("is_skip_pa",true)
              console.log("my","is_updated_pa false")

            }else {
              mdataPreferences.putSync("first_open",false)
              console.log("my","first_open false")
            }

            this.controller?.close()
            mdataPreferences.flush((err: BusinessError) => {
              if (err) {
                console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
                return;
              }
              console.info('Succeeded in flushing.');
            })

          }

        })
        Button("同意").width('30%').onClick(e=>{
          if (dataPreferences !== undefined) {
            let mdataPreferences = dataPreferences as  preferences.Preferences

            if (!this.is_updated) {
              mdataPreferences.putSync("is_updated_pa",true)
              console.log("my","is_updated_pa false")
              init()
            }else {
              mdataPreferences.putSync("first_open",false)
              mdataPreferences.putSync("agree",true)
              console.log("my","first_open false")
            }

            mdataPreferences.flush((err: BusinessError) => {
              if (err) {
                console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
                return;
              }
              console.info('Succeeded in flushing.');
            })


            this.controller?.close()

          }

        })
      }.width('100%').margin(20).padding({
        left:20,right:20,bottom:20
      }).justifyContent(FlexAlign.SpaceAround)
    }.width('100%').height('100%').borderRadius(25).alignItems(HorizontalAlign.Center).justifyContent(
      FlexAlign.Start
    )
  }
}