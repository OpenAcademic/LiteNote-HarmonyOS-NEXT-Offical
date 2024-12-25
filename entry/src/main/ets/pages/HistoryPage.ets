import { getHistories, HistListData } from '../service/api';
import { promptAction, router } from '@kit.ArkUI';
import { LLMHistoryCard } from '../widgets/llmcard';
import { EmptyCard } from '../widgets/ExpressCard';

@Entry
@Component
struct HistoryPage {
  @State message: string = '历史记录';
  @State isreflash : boolean = false

  @State page:number = 1
  @State histories : HistListData[]  = []

  async nextPage(){
    this.page= this.page+1
    let p = await getHistories(this.page)
    if (p!=null){
      if (p.length===0){
        promptAction.showToast({
          message:"已经是最后一页了",
          duration:1500
        })
        this.page = this.page-1
        return
      }else{
        this.histories = this.histories.concat(p)
      }

    }else{
      promptAction.showToast({
        message:"失败",
        duration:1500
      })
      router.back()
    }
  }

  async aboutToAppear(){
    let p = await getHistories(this.page)
    if (p!=null){
      console.log(p?.length.toString())

      this.histories = p
    }else{
      promptAction.showToast({
        message:"失败",
        duration:1500
      })
      router.back()
    }
  }

  build() {
    Scroll(){
    RelativeContainer() {

      Column() {
        Text(this.message)
          .id('HistoryPageHelloWorld')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
        if (this.isreflash) {
          LoadingProgress().width(50).height(50)
        }
        if (this.histories.length>0){
          Grid() {
            ForEach(this.histories, (item: HistListData) => {
              GridItem() {
                LLMHistoryCard({
                  history: item,
                  onClickOK: () =>{
                    this.aboutToAppear()
                  }
                })
              }.padding(20).margin(5).backgroundColor(
                item.status===1? "#FF9696":
                $r('sys.color.ohos_id_color_toolbar_sub_bg')
              ).borderRadius(15)

            }, (item: HistListData) => item.id+"-"+item.status+"-"+item.cid)
          }
          .height('100%').width('100%')
        }else{
          EmptyCard()
        }
      }.height('100%').width('100%')
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

      let timeidf = setInterval(async ()=>{
        await this.nextPage()
        this.isreflash = false
        clearInterval(timeidf)
      },1000)

    })
  }
}