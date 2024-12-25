import { it } from "@ohos/hypium"
import { FunctionData, getbanners, getFunctions } from "../service/api"
import { router } from "@kit.ArkUI"


@Component
export struct LLMHomePage {
  @State isreflash : boolean = false
  @State banners : string[] = []
  @State functions : FunctionData[] = []

  async aboutToAppear(){
    this.isreflash = true
    let ba = await getbanners()
    if (ba!==null){
      this.banners = ba
    }
    let ba2 = await getFunctions()
    if (ba2!==null){
      this.functions = ba2
    }
    this.isreflash = false
  }
  build() {
    Column() {
      if (this.isreflash) {
        LoadingProgress().width(50).height(50)
      }else{
        Scroll(){

          Column(){
            Swiper() {
              ForEach(this.banners, (item: string, index: number) => {
                Image(item).size({width:'100%',height:'100%'})
              })
            }.height(150).margin(20).borderRadius(20).autoPlay(true).interval(5000)
            .indicator(
              Indicator.dot()
                .left(0)
                .itemWidth(15)
                .itemHeight(15)
                .selectedItemWidth(30)
                .selectedItemHeight(15)
                .color(Color.Gray)
                .selectedColor(Color.Red)
            )

            Row(){
              Button(){
                Text("历史记录").margin(5).fontColor(Color.White)
              }.onClick(e=>{
                router.pushUrl({
                  url:"pages/HistoryPage",
                  params:{
                  }
                })
              }).padding(5)
            }.width("90%").justifyContent(FlexAlign.End).alignItems(VerticalAlign.Center)

            Grid() {
              ForEach(this.functions, (item: FunctionData,position:number) => {
                GridItem() {
                  Column(){
                    Image("https://oac.ac.cn/icons/"+item.img).width(50).height(50).borderRadius(9999)
                    Text(item.name).fontSize(10).margin({top:5})
                  }

                }.width(90).height(60).align(Alignment.Center).alignSelf(ItemAlign.Center).onClick(e=>{
                  console.log(item.id?.toString())
                  router.pushUrl({
                    url:"pages/LLMPage",
                    params:{
                      id:item.id,
                    }
                  })
                })
                .borderRadius(15).margin(5)
              }, (item: FunctionData) => item.id?.toString())
            }.padding(20).alignItems(GridItemAlignment.STRETCH)
            .width('100%').columnsGap(10)
            .rowsGap(10)
            .cellLength(0).flexGrow(1)
            .layoutDirection(GridDirection.Row)


            }.width('100%').height('100%').alignItems(
            this.isreflash?HorizontalAlign.Center:HorizontalAlign.Center
          ).justifyContent(
            this.isreflash?FlexAlign.Center:FlexAlign.Start
          )

          }.scrollable(ScrollDirection.Vertical).width('100%').height('100%') .scrollBarColor(Color.Gray) // 滚动条颜色
        .scrollBarWidth(5) // 滚动条宽度
        .edgeEffect(EdgeEffect.None) // 滚动到边沿后回弹

      }
    }.width('100%').height('100%').alignItems(
      this.isreflash?HorizontalAlign.Center:HorizontalAlign.Center
    ).justifyContent(
      this.isreflash?FlexAlign.Center:FlexAlign.Start
    )

  }


}