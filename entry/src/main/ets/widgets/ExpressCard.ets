import { EditDialog, TongyiDialog, TongyiDialogConfig } from "../dialog/started"
import { Code } from "../entity/code"
import { Express } from "../entity/express"
import { Port } from "../entity/port"
import { store } from "../entryability/EntryAbility"
import { name2png } from "../utils/name2pg"
import { promptAction } from "@kit.ArkUI"
import { PublicUtils } from "../utils/pu"
import { relationalStore } from "@kit.ArkData"


@Component
export struct CodeCard {
  @ObjectLink code:Code
  @State orstatus : number = 0
  onClickOK?: () => void;
  dx : number = 0
  dy : number = 0
  @State left : boolean = false
  tongyi = ()=>{
    if (store){
      let res = Code.delete_by_id(store,this.code.code)
      if (res){
        promptAction.showToast({
          message: "删除成功",
          duration: 1500
        })
      }else{
        promptAction.showToast({
          message: "删除失败",
          duration: 1500
        })
      }
      if (this.onClickOK){
        this.onClickOK()

      }
    }
  }
  qujian = ()=>{
    if (store){
      let res = Code.update_by_id(store,this.code.code,this.code.status)
      if (res){
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
      if (this.onClickOK){
        this.onClickOK()
        this.orstatus = this.orstatus==1?0:1

      }
    }
  }


  qujiandialogController: CustomDialogController | null = null
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TongyiDialog({
      config: new TongyiDialogConfig(
        "您是否同意删除该驿站",
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
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    backgroundBlurStyle:BlurStyle.Thick,
    cornerRadius: 20,
  })
  editDialogController: CustomDialogController | null = null

  aboutToAppear(): void {
    this.orstatus = this.code.status
    this.qujiandialogController = new CustomDialogController({
      builder: TongyiDialog({
        config: new TongyiDialogConfig(
          this.code.status==1?"您是要撤销":"您是要取件",
          this.qujian
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
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      gridCount: 4,
      backgroundBlurStyle:BlurStyle.Thick,
      cornerRadius: 20,
    })
    this.editDialogController = new CustomDialogController({
      builder: EditDialog({
        code:this.code,
        tongyi:()=> {
          if (this.onClickOK){

            this.onClickOK()
          }
        }
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
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      gridCount: 4,
      backgroundBlurStyle:BlurStyle.Thick,
      cornerRadius: 20,
    })
  }
  build() {
    Row(){
      Column(){
        Row(){
          Image(name2png(this.code.express)).width(30).height(30)
          Text(this.code.express + "快递").fontColor(this.orstatus==1?Color.Gray:Color.Black).fontSize(16)
            .fontWeight(FontWeight.Bolder).maxLines(1)
        }.alignItems(VerticalAlign.Center)
        Row(){
          Text(this.code.code).fontSize(30).fontColor(this.orstatus==1?Color.Gray:Color.Black)
            .fontWeight(FontWeight.Bolder).maxLines(1)
            .decoration({ type:this.orstatus===1?TextDecorationType.LineThrough:TextDecorationType.None
            ,color:Color.Black})
        }.alignItems(VerticalAlign.Center)
        Text(this.code.port).fontSize(16).fontColor(this.orstatus==1?Color.Gray:Color.Black)
          .maxLines(1)
          .decoration({ type:this.orstatus===1?TextDecorationType.LineThrough:TextDecorationType.None
          ,color:Color.Black})
        Text(PublicUtils.getDateTime(this.code.timestemp as number, 'null')).fontColor(this.orstatus==1?Color.Gray:Color.Black).fontSize(16).maxLines(1)
      }.alignItems(HorizontalAlign.Start).width(this.left?'60%':'80%')
      if (this.left){
        Row({space:10}){
          Button("编辑").backgroundColor(
            Color.Green
          ).onClick(e=>{
            if (this.editDialogController != null) {
              this.editDialogController.open()
            }
          })
          Button("删除").backgroundColor(
            Color.Red
          ).onClick(e=>{
            if (this.dialogController != null) {
              this.dialogController.open()
            }
          })
        }.width('20%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start)
      }else{
        Row(){
          Button(this.orstatus==1?"撤销":"取件").onClick(e=>{
            if (this.qujiandialogController){
              this.qujiandialogController.open()
            }

          })
        }.width('20%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.End)
      }
    }.width('100%')
    .onTouch((event?: TouchEvent) => {
      if(event){
        if (event.type === TouchType.Down) {
          this.dx = event.touches[0].x
          this.dy = event.touches[0].y
        }
        if (event.type === TouchType.Up) {
          let ndx = event.touches[0].x
          let ndy = event.touches[0].y
          let ddx = ndx - this.dx
          let ddy = ndy - this.dy

          let ddy_true = (ddy >= -20 && ddy <= 20)
          let ddx_true = (ddx <= -50)
          let ddx_right = (ddx >=50)
          if (ddy_true && ddx_true){
            console.info("left","左滑")
            this.left = true
          }
          if (ddy_true && ddx_right){
            this.left = false
          }

        }
        if (event.type === TouchType.Move) {

        }

      }
    })

  }
}

@Component
export struct ExpressCard {
  @ObjectLink express:Express
  onClickOK?: () => void;
  dx : number = 0
  dy : number = 0
  @State left : boolean = false
  tongyi = ()=>{
    if (store){
      console.info("dfds",this.express.express)
      let res = Express.delete_by_id(store,this.express.express)
      if (res){
        promptAction.showToast({
          message: "删除成功",
          duration: 1500
        })
      }else{
        promptAction.showToast({
          message: "删除失败",
          duration: 1500
        })
      }
      if (this.onClickOK){
        this.onClickOK()

      }
    }
  }

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TongyiDialog({
      config: new TongyiDialogConfig(
        "您是否同意删除该快递",
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
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: true,
    backgroundBlurStyle:BlurStyle.Thick,
    cornerRadius: 20,
  })
  build() {
    Row(){
      Column(){
        Row(){
          Text(this.express.express)
            .fontWeight(FontWeight.Bolder).fontSize(30).maxLines(1)
           .textOverflow({
            overflow:TextOverflow.Ellipsis
          }).width(this.left?'80%':'100%')
          if (this.left){
            Button("删除").backgroundColor(
              Color.Red
            ).onClick(e=>{
              if (this.dialogController != null) {
                this.dialogController.open()
              }
            })
          }
        }.alignItems(VerticalAlign.Center).margin({
          top:9,bottom:9,right:9
        }).justifyContent(FlexAlign.SpaceBetween)
      }.alignItems(HorizontalAlign.Start).width('100%')
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).onTouch((event?: TouchEvent) => {
      if(event){
        if (event.type === TouchType.Down) {
          this.dx = event.touches[0].x
          this.dy = event.touches[0].y
        }
        if (event.type === TouchType.Up) {
          let ndx = event.touches[0].x
          let ndy = event.touches[0].y
          let ddx = ndx - this.dx
          let ddy = ndy - this.dy

          let ddy_true = (ddy >= -20 && ddy <= 20)
          let ddx_true = (ddx <= -50)
          let ddx_right = (ddx >=50)
          if (ddy_true && ddx_true){
            console.info("left","左滑")
            this.left = true
          }
          if (ddy_true && ddx_right){
            this.left = false
          }

        }
        if (event.type === TouchType.Move) {

        }

      }
    })
  }
}
@Component
export struct EmptyCard{
  build() {
    Column(){
      Image($r('app.media.empty')).width(200).height(200)
      Text("内容为空").fontSize(35).fontWeight(FontWeight.Bolder)
    }.height('80%').width('100%')
    .alignItems(HorizontalAlign.Center).margin({
      top:'15%'
    })
    .justifyContent(FlexAlign.Center)
  }
}
@Component
export struct PortCard {
  @ObjectLink port:Port
  onClickOK?: () => void;
  dx : number = 0
  dy : number = 0
  @State left : boolean = false
  tongyi = ()=>{
    if (store){
      console.info(
        this.port.port,
        this.port.id,
        this.port.port_local
      )
      let res = Port.delete_by_id(store,this.port.port)
      if (res){
        promptAction.showToast({
          message: "删除成功",
          duration: 1500
        })
      }else{
        promptAction.showToast({
          message: "删除失败",
          duration: 1500
        })
      }
      if (this.onClickOK){
        this.onClickOK()

      }
    }
  }

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TongyiDialog({
      config: new TongyiDialogConfig(
        "您是否同意删除该驿站",
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
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: true,
    backgroundBlurStyle:BlurStyle.Thick,
    cornerRadius: 20,
  })
  build() {
    Row(){
      Row(){
        Column(){
          Text(this.port.port).fontSize(30).maxLines(1)
            .fontWeight(FontWeight.Bolder).textOverflow({
            overflow:TextOverflow.Ellipsis
          })
          Text(this.port.port_local).fontSize(15).maxLines(2).textOverflow({
            overflow:TextOverflow.Ellipsis
          })
        }.width(this.left?'80%':'100%').alignItems(HorizontalAlign.Start).justifyContent(
          FlexAlign.Start
        )
        if (this.left){
          Button("删除").backgroundColor(
            Color.Red
          ).onClick(e=>{
            if (this.dialogController != null) {
              this.dialogController.open()
            }
          })
        }
      }.alignItems(VerticalAlign.Center).width('100%').justifyContent(
        FlexAlign.SpaceBetween
      )
    }.justifyContent(FlexAlign.Center).onClick(e=>{
    })
    .onTouch((event?: TouchEvent) => {
      if(event){
        if (event.type === TouchType.Down) {
          this.dx = event.touches[0].x
          this.dy = event.touches[0].y
        }
        if (event.type === TouchType.Up) {
          let ndx = event.touches[0].x
          let ndy = event.touches[0].y
          let ddx = ndx - this.dx
          let ddy = ndy - this.dy

          let ddy_true = (ddy >= -20 && ddy <= 20)
          let ddx_true = (ddx <= -50)
          let ddx_right = (ddx >=50)
          if (ddy_true && ddx_true){
            console.info("left","左滑")
            this.left = true
          }
          if (ddy_true && ddx_right){
            this.left = false
          }

        }
        if (event.type === TouchType.Move) {

        }

      }
    })
  }
}