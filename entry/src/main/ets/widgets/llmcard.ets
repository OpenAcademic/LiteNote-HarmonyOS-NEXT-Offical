import { TongyiDialog, TongyiDialogConfig } from "../dialog/started";
import { delHistoriy, HistListData } from "../service/api";
import { PublicUtils } from "../utils/pu";
import { promptAction, router } from "@kit.ArkUI";


@Component
export struct LLMHistoryCard {
  @ObjectLink history: HistListData
  @State orstatus: number = 0
  onClickOK?: () => void;
  dx: number = 0
  dy: number = 0
  @State left: boolean = false
  tongyi = async ()=>{
    if (this.history){
      const res = await delHistoriy(this.history.cid)
      if (res){
        promptAction.showToast({
          message: "删除成功",
          duration: 1500
        })
      }

    }

    if (this.onClickOK){
      this.onClickOK()

    }
  }
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TongyiDialog({
      config: new TongyiDialogConfig(
        "您是否同意删除该历史记录",
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

  build() {
    Row(){
      Column(){
        Row(){
          Text(this.history.status===1?"已完成":"未完成").fontColor(this.orstatus==1?Color.Gray:Color.Black).fontSize(16)
            .fontWeight(FontWeight.Bolder).maxLines(1)
        }.alignItems(VerticalAlign.Center)

        Text(this.history.prompts).fontSize(18).fontColor(this.orstatus==1?Color.Gray:Color.Black)
          .maxLines(4).textOverflow({overflow:TextOverflow.Ellipsis}).width("100%")
          .decoration({ type:this.orstatus===1?TextDecorationType.LineThrough:TextDecorationType.None
          ,color:Color.Black})
        Text("生成时间:"+this.history.createTime?.split("T")[0]).fontColor(this.orstatus==1?Color.Gray:Color.Black).fontSize(16).maxLines(1)
      }.alignItems(HorizontalAlign.Start).width(this.left?'80%':'100%').onClick(e=>{
        router.pushUrl({
          url:"pages/LLMPage",
          params:{
            read:true,
            cid:this.history.cid
          }
        })
      })
      if (this.left){
        Row({space:10}){
          Button("删除").backgroundColor(
            Color.Red
          ).onClick(e=>{
            if (this.history.status===0){
              promptAction.showToast({
                message: "未生成完成的暂不能删除",
                duration: 1500
              })
              return
            }
            if (this.dialogController != null) {
              this.dialogController.open()
            }
          })
        }.width('20%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start)
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