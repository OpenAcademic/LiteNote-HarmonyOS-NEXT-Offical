import { systemDateTime } from "@kit.BasicServicesKit"
import { List } from "@kit.ArkTS"
import { PublicUtils } from "../utils/pu"
import { store } from "../entryability/EntryAbility"
import { Code, CompareItem } from "../entity/code"
import { promptAction } from "@kit.ArkUI"


@Component
export struct OverLookPage {
  @State all_datas : string[] = []
  @State haved_lists : List<string> = new List()
  @State all_infos : number[] = []
  @State codes_by_str: CompareItem[] = []
  @State select_str : string = ""

  gene_50day_ago_strs(){
    let curr  : number = systemDateTime.getTime(false)
    let currtime : number = systemDateTime.getTime(false) - 49*24*60*60*1000
    let day_ago = 0
    let dates  = new List<string>()
    while (currtime<curr){
      currtime += 24*60*60*1000

      let str = PublicUtils.getDateTime2(currtime)
      dates.add(str)
      console.log("cha",str,(curr-currtime)/60/60/24)
    }
    this.all_datas = dates.convertToArray()
  }
  aboutToAppear(): void {
    this.gene_50day_ago_strs()
    if (store){
      this.haved_lists = Code.load_graph(store)
      this.all_infos = Code.load_alls(store)
    }


  }

  loadcodes_by_str(str:string) {
    if (this.haved_lists.getIndexOf(str) !== -1) {
      if (store) {
        this.codes_by_str = Code.load_graph_by_str(store, str)
        this.select_str = str
      }
    }else{
      promptAction.showToast({
        message: "没有内容哦",
        duration: 1500
      })
    }


  }
  build() {
    Column(){
      Text("总览")
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 20, bottom: 10 })
      Row(){
        Column(){
          Image($r('app.media.all')).width(40).height(40).margin(5)
          Column(){
            Text('全部快递')
            Text(this.all_infos[0]+' 个')
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        Column(){
          Image($r('app.media.dqj')).width(40).height(40).margin(5)
          Column(){
            Text('待取件')
            Text(this.all_infos[1]+' 个')
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        Column(){
          Image($r('app.media.all')).width(40).height(40).margin(5)
          Column(){
            Text('未取件')
            Text(this.all_infos[2]+' 个')
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
      }.width('100%').backgroundColor(
        $r('sys.color.ohos_id_color_toolbar_sub_bg')
      ).borderRadius(15).margin({
        bottom:15,top:15
      }).justifyContent(FlexAlign.SpaceAround).alignItems(VerticalAlign.Center).padding({
        top:20,bottom:20
      })
      Column(){
        Scroll(){
          Grid() {
            ForEach(this.all_datas, (item: string,position:number) => {
              GridItem() {
                Button(' ').width(30).height(30).buttonStyle(ButtonStyleMode.NORMAL).type(ButtonType.Normal)
                  .borderRadius(12).onClick(e=>{
                    this.loadcodes_by_str(item)
                }).backgroundColor(
                  this.haved_lists.getLastIndexOf(item)!=-1?Color.Green:Color.Gray
                )
              }
            }, (item: string) => item)
          }.padding(20).height(200).rowsGap(2).columnsGap(2)
          .layoutDirection(GridDirection.Column)
        }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

      }.width('100%').backgroundColor(
        $r('sys.color.ohos_id_color_toolbar_sub_bg')
      ).borderRadius(15)
      if (this.codes_by_str.length!==0){
        Text(this.select_str).fontColor(Color.Black).padding({
          top:15
        }).textAlign(TextAlign.Start).fontSize(25).padding(10).width('100%').fontWeight(FontWeight.Bolder)
          .borderRadius(15)
        Scroll(){
          Grid() {
            ForEach(this.codes_by_str, (item: CompareItem,position:number) => {
              GridItem() {
                Text(item.value.toString()).fontColor(Color.Black).textAlign(TextAlign.Start).fontSize(25).padding(15).width('100%')
                  .borderRadius(15).onClick(e=>{
                }).backgroundColor(
                  $r('sys.color.ohos_id_color_toolbar_sub_bg')
                ).margin({
                  top:5
                })
              }
            }, (item: CompareItem) => item.key.toString())
          }.width('100%').rowsGap(2).columnsGap(2).padding({
            top:5
          })
          .layoutDirection(GridDirection.Row)
        }.scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off)
      }
    }.width('90%').height('100%').margin('5%')

  }
}