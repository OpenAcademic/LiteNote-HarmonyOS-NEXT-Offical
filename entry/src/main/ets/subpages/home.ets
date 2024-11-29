import { CircleShape, promptAction, router } from "@kit.ArkUI"
import { Code, CompareItem } from "../entity/code"
import { Express } from "../entity/express"
import { Port } from "../entity/port"
import { store } from "../entryability/EntryAbility"
import { relationalStore } from "@kit.ArkData"
import { List } from "@kit.ArkTS"
import { name2png } from "../utils/name2pg"
import { it } from "@ohos/hypium"
import { CodeCard, EmptyCard, ExpressCard, PortCard } from "../widgets/ExpressCard"
import { AddExpressDialog, AddPortDialog } from "../dialog/started"
import { AddCodeDialog } from "../pages/AddCodePage"

@Component
export struct HomePage {
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()
  @State page : number = 1
  @State pageSize: number = 10

  @State lists:Code[]|Port[] | Express[]  = []
  @State statuses :  string[] = [
    "全部","未取件","已取件"
  ]
  @State status : number = -1
  @State isok : boolean= false
  @State isreflash : boolean= false

  addExpressDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AddExpressDialog({
      onClickOK:() => {
        this.isok = false
        this.onload()
        this.isok = true
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
  addPortDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AddPortDialog({
      onClickOK:() => {
        this.isok = false
        this.onload()
        this.isok = true
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
  addCodeDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AddCodeDialog({
      onClickOK:() => {
        this.isok = false
        this.onload()
        this.isok = true
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
    autoCancel: false,

    customStyle: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    backgroundBlurStyle:BlurStyle.Thick,
    cornerRadius: 20,
  })

  aboutToAppear(): void {
    this.onload()
    this.isok = true
  }

  onload(){
    this.lists = []
    this.page = 1
    this.pageSize = 15
    let options = new List<CompareItem>()
    if (store){
      let mSTore = store as relationalStore.RdbStore
      if (this.currentIndex == 0){
        if (this.status!=-1){
          options.add(
            new CompareItem("status",this.status)
          )
        }


        this.lists=Code.load_by_resultSet(
          mSTore,options,this.page,this.pageSize
        ).convertToArray() as Code[]

        console.info("ddsf",this.lists.length)
      }
      else if (this.currentIndex == 1){
        this.lists=Express.load_by_resultSet(
          mSTore,options,this.page,this.pageSize
        ).convertToArray() as Express[]
      }else if (this.currentIndex == 2){
        this.lists=Port.load_by_resultSet(
          mSTore,options,this.page,this.pageSize
        ).convertToArray()as Port[]
      }
    }
    console.info("dfdfdsf",this.lists.length)



  }
  nextPage(){
    this.isok = false
    this.page += 1
    let options = new List<CompareItem>()
    if (store){
      let mSTore = store as relationalStore.RdbStore
      if (this.currentIndex == 0){
        if (this.status!=-1){
          options.add(
            new CompareItem("status",this.status)
          )
        }
        let new_list = Code.load_by_resultSet(
          mSTore,options,this.page,this.pageSize
        ).convertToArray()
        if (new_list.length === 0){
          promptAction.showToast({
            message: "已经没有更多了",
            duration: 1500
          })
          this.page-=1
          this.isok = true

          return
        }
        this.lists = (this.lists  as Code[] ).concat(new_list as Code[]) as Code[]
      } else if (this.currentIndex == 1){
        let new_list = Express.load_by_resultSet(
          mSTore,options,this.page,this.pageSize
        ).convertToArray()
        if (new_list.length === 0){
          promptAction.showToast({
            message: "已经没有更多了",
            duration: 1500
          })
          this.page-=1
          this.isok = true

          return
        }
        this.lists = (this.lists  as Express[] ).concat(new_list as Express[]) as Express[]
      }else if (this.currentIndex == 2) {
        let new_list = Port.load_by_resultSet(
          mSTore, options, this.page, this.pageSize
        ).convertToArray()
        if (new_list.length === 0) {
          promptAction.showToast({
            message: "已经没有更多了",
            duration: 1500
          })
          this.page -= 1
          this.isok = true

          return
        }
        this.lists = (this.lists as Port[]).concat(new_list as Port[]) as Port[]
      }
    }
    console.info("dfdfdsf",this.lists.length)
    this.isok = true
  }

  build() {
    Scroll() {

      Column({ space: 5 }) {

        if (this.isok){
          Stack({}) {
            Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.currentIndex }) {
              TabContent() {

                  Column(){
                    if (this.isreflash){
                      LoadingProgress().width(50).height(50)
                    }
                    Grid() {
                      ForEach(this.statuses, (item: string,position:number) => {
                        GridItem() {
                          Button(item).width(80).height(40)
                            .borderRadius(15).backgroundColor(
                            position-1==this.status?Color.Blue:Color.Gray
                          ).onClick(e=>{
                            this.status = position -1
                            this.isok = false
                            this.onload()
                            this.isok = true

                          })

                        }
                        .borderRadius(15)
                      }, (item: string) => item)
                    }.padding(20)
                    .height('10%').width('100%').columnsGap(10)
                    .rowsGap(10)

                    .cellLength(0)
                    .layoutDirection(GridDirection.Row)
                    if (this.lists.length == 0){
                      EmptyCard()
                    }else{
                    Grid() {
                      ForEach(this.lists, (item: Code) => {
                        GridItem() {
                          CodeCard({
                            code: item,
                            onClickOK: () =>{
                              this.isok = false
                              this.lists = []
                              this.onload()
                              this.isok = true
                            }
                          })
                        }.padding(20).margin(5).backgroundColor(
                          $r('sys.color.ohos_id_color_toolbar_sub_bg')
                        ).borderRadius(15)

                      }, (item: Code) => item.code+"-"+item.port+"-"+item.express)
                    }
                    .height('80%').width('100%')
                  }
                }.height('100%').width('100%')

              }
              .tabBar({
                text: "取件码",
              })
              TabContent() {
                if (this.lists.length == 0){
                  EmptyCard()
                }else {
                  Column(){
                    if (this.isreflash){
                      LoadingProgress().width(50).height(50)
                    }
                    Grid() {
                      ForEach(this.lists, (iii: Express) => {
                        GridItem() {
                          ExpressCard(
                            {
                              express: iii,
                              onClickOK: () =>{
                                this.isok = false
                                this.onload()
                                this.isok = true
                              }
                            }
                          ).onClick(e => {

                          })
                        }.padding(20).margin(5).backgroundColor(
                          $r('sys.color.ohos_id_color_toolbar_sub_bg')
                        ).borderRadius(15)
                      }, (item: Express) => item.express)
                    }
                    .height('100%')
                    .width('100%')
                  }.height('100%')
                  .width('100%').alignItems(HorizontalAlign.Center)


                }
              }
              .tabBar({
                text: "快递公司",
              })
              TabContent() {
                if (this.lists.length == 0){
                  EmptyCard()
                }else {
                  Column(){
                    if (this.isreflash){
                      LoadingProgress().width(50).height(50)
                    }
                    Grid() {
                      ForEach(this.lists, (item: Port) => {
                        GridItem() {
                          PortCard({
                            port: item ,
                            onClickOK: () =>{
                              this.isok = false
                              this.onload()
                              this.isok = true
                            }
                          })
                        }.padding(20).margin(5).backgroundColor(
                          $r('sys.color.ohos_id_color_toolbar_sub_bg')
                        ).borderRadius(15)
                      }, (item: Port) => item.port)
                    }
                    .height('100%')
                    .width('100%')
                  }.height('100%')
                  .width('100%').alignItems(HorizontalAlign.Center)

                }
              }
              .tabBar({
                text: "我的驿站",
              })


            }
            .onChange((index: number) => {
              this.currentIndex = index
              this.isok = false
              this.onload()
              this.isok = true
            })
            .scrollable(false)
            .barWidth('70%')
            .barBackgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
            .clip(
              true
            )

            Button('+')
              .width(80)
              .height(80)
              .fontColor(Color.White)
              .margin({
                right: 30,
                bottom: '20%'
              })
              .fontSize(30)
              .onClick(e => {
                if (this.currentIndex == 0) {
                  if (this.addCodeDialogController){
                    this.addCodeDialogController.open()
                  }
                } else if (this.currentIndex == 1) {
                  if (this.addExpressDialogController){
                    this.addExpressDialogController.open()
                  }
                } else if (this.currentIndex == 2) {
                  if (this.addPortDialogController){
                    this.addPortDialogController.open()
                  }
                }
              })
          }.width('100%').height('100%').align(Alignment.BottomEnd)

        }else{
          LoadingProgress()
        }
      }
      .height('100%')
      .width('100%')
    }.width('100%').height('110%').scrollable(ScrollDirection.Vertical)
    .scrollBarColor(Color.Gray) // 滚动条颜色
    .scrollBarWidth(5) // 滚动条宽度
    .edgeEffect(EdgeEffect.Spring) // 滚动到边沿后回弹
    .onScrollEdge((side)=>{

      this.isreflash = true
      console.log("dfdsf","sdfdsf触底"+side)

      let timeidf = setInterval(()=>{
        this.nextPage()
        this.isreflash = false
        clearInterval(timeidf)
      },1000)

    })

  }
}