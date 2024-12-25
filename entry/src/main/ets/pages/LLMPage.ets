import { promptAction, router } from '@kit.ArkUI';
import { createLLM, FunctionDetailData, getFunctionsDetail, getHistoriy, runLLM } from '../service/api';
import { getkeyStr } from '../service/kv';
import { LMICallBack, lvMarkdownIn } from '@luvi/lv-markdown-in'

@Entry
@Component
struct LLMPage {
  @State message: string = 'Hello World';
  @State ids: number = 0;
  @State function : FunctionDetailData | null = null
  @State prompts : string = ""
  @State inputs : string[] = []
  @State llm_ok : boolean = false
  @State llm_loading : boolean = false
  @State userkey : string  = ""
  @State res : string  = ""
  @State read : boolean = false

  async aboutToAppear(){
    if (router.getParams() !== undefined && router.getParams() !== null) {
      let record = router.getParams() as Record<string, string|number|boolean | boolean>;
      if (record !== undefined && record !== null) {
        let msg = record['id']
        let read = record['read'] as  boolean
        this.read = read
        console.log(record["read"] as string)
        if (read){
          let cid = record['cid'] as string
          const res2 = await getHistoriy(cid)
          if (res2){
            this.llm_ok=true
            this.llm_loading=false
            this.res=res2.context?.toString()
            this.prompts=res2.prompts
            this.userkey = ""
          }
        }else{
          this.ids = msg as number
          this.function = await getFunctionsDetail(this.ids)
          this.userkey =await getkeyStr("userKey")
          if (this.function){
            this.function.fields.forEach((value : string,index:number)=>{
              this.inputs.push("")
            })
            this.prompts = this.function.prompt
          }
        }



      }
    }
  }
  build() {
    Scroll(){
    RelativeContainer() {
      Column(){
        if (this.function || this.read){
          if (this.function){
            Text("AI生成"+this.function.name)
              .id('LLMPageHelloWorld')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
          }else{
            Text("AI生成")
              .id('LLMPageHelloWorld')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
          }
          Column(){
            Text("风险提示⚠️")
              .id('LLMPageHelloWorld')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
            Text("内容生成涉及风险内容，软件产生的文本不代表软件的立场。软件Ai模型由百度文心大模型提供。通过软件提示词生成的文章责任不归软件制作方负责，所有责任由使用者承担！")
              .id('LLMPageHelloWorld')
              .fontSize(15)
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
          }.backgroundColor(
            "#FF9696"
          ).width('90%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center).borderRadius(20).padding(10)
          if (this.llm_loading){
            Column(){
              if (!this.userkey){
                Text("您未登陆\n请不要退出")
                  .id('LLMPageHelloWorld')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .alignRules({
                    center: { anchor: '__container__', align: VerticalAlign.Center },
                    middle: { anchor: '__container__', align: HorizontalAlign.Center }
                  })

              }
              LoadingProgress().size({width:100,height:100})
            }.height('100%')
            .width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
          }else{
            if (this.llm_ok){
              if (this.userkey){
                Column(){
                  Text("您已登陆\n生成结果请到历史记录查看")
                    .id('LLMPageHelloWorld')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .alignRules({
                      center: { anchor: '__container__', align: VerticalAlign.Center },
                      middle: { anchor: '__container__', align: HorizontalAlign.Center }
                    })

                }.height('100%')
                .width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)

              }else{
                lvMarkdownIn({
                  text: this.prompts.toString(), // content为文本内容
                  loadMode: "text", // 默认text可省略
                  loadCallBack: { // loadCallBack回调可省略
                    success(r: LMICallBack) {
                      console.log("luvi-markdown-in > " + r.code, r.message)
                    },
                    fail(r: LMICallBack) {
                      console.error("luvi-markdown-in > " + r.code, r.message)
                    }
                  }
                }).width("90%")
                lvMarkdownIn({
                  text: this.res.toString(), // content为文本内容
                  loadMode: "text", // 默认text可省略

                  loadCallBack: { // loadCallBack回调可省略
                    success(r: LMICallBack) {
                      console.log("luvi-markdown-in > " + r.code, r.message)
                    },
                    fail(r: LMICallBack) {
                      console.error("luvi-markdown-in > " + r.code, r.message)
                    }
                  }
                }).width("90%")

              }
            }else{
              if (this.function){
              ForEach(this.function.fields, (item: string,index:number) => {
                Column() {
                  TextArea({ placeholder: '请输入'+this.function?.fieldsShow[index], text: this.inputs[index] })
                    .onChange((value: string) => {
                      this.inputs[index] = value;
                    })
                    .fontSize(18)
                    .fontColor(Color.Black)
                    .width('90%').borderRadius(20).padding(10)
                    .padding({ left: 10, right: 10 }).margin({top:10});
                  Divider().height(1).color('#194487fe'); // 下划线
                }
              })

              Button("生 成")
                .width('90%')
                .backgroundColor(Color.Red).borderRadius(20).padding(10).margin({top:10})
                .fontSize(18)
                .fontColor(Color.White)
                .onClick(async () => {
                  console.log(this.inputs.toString())
                  let isall = true
                  this.inputs.forEach((value:string,index:number)=>{
                    if (!value){
                      promptAction.showToast({
                        message: "您输入的信息为空",
                        duration: 1500
                      })
                      isall = false
                      return
                    }
                    this.prompts = this.prompts.replaceAll("{"+index+"}",value)
                  })
                  if (isall){
                    console.log(this.prompts.toString())
                    this.llm_loading = true
                    const cid = await createLLM()

                    if (!cid){
                      promptAction.showToast({
                        message:"失败",
                        duration:1500
                      })
                      return
                    }
                    const res2 = await runLLM(cid,this.prompts)
                    console.log(res2?.content,res2?.notice)

                    this.llm_loading = false
                    this.llm_ok = true
                    if (res2){
                      this.res = res2.content
                      promptAction.showToast({
                        message:res2.notice?"生成成功":res2.notice,
                        duration:1500
                      })
                    }else{
                      promptAction.showToast({
                        message:"失败",
                        duration:1500
                      })
                      return
                    }
                  }

                })
              }
            }
          }



        }else{
          Column(){
            LoadingProgress().size({width:100,height:100})
          }.height('100%')
          .width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
        }
      }.height('100%')
      .width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Start)

    }
    .height('100%')
    .width('100%')
    }.width('100%').height('110%').scrollable(ScrollDirection.Vertical)
    .scrollBarColor(Color.Gray) // 滚动条颜色
    .scrollBarWidth(5) // 滚动条宽度
    .edgeEffect(EdgeEffect.Spring) // 滚动到边沿后回弹
  }
}