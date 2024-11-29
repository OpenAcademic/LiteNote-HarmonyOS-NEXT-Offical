import { CircleShape, promptAction, router } from '@kit.ArkUI';
import { List } from '@kit.ArkTS';
import { Format } from '../entity/format';
import { dataPreferences, store } from '../entryability/EntryAbility';
import { relationalStore } from '@kit.ArkData';
import { Express } from '../entity/express';
import { Port } from '../entity/port';
import { Code } from '../entity/code';
import { parseCodeBySMS } from '../service/api';

//@Entry
//@Component
//struct AddCodePage {
@CustomDialog
export struct AddCodeDialog {
  controller?: CustomDialogController
  onClickOK?: () => void;
  @State isLoading: boolean = false

  @State message: string = '添加取件码';
  @State input : string = '';
  @State codes :  string[] = []

  private last_codes = new List<string>()

  @State code_input :string = ''
  @State express_input :string = ''
  @State port_input :string = ''
  @State port_local_input :string = ''

  @State express:string = ''
  @State port : string = ''
  @State port_local : string = ""
  @State formats : List<string> = new List()
  @State express_reg : string = ""
  @State port_reg : string = ""
  @State isjiexi : boolean = false
  @State isAIEnabled: boolean = false

  aboutToAppear(): void {
    if (dataPreferences) {
      this.isAIEnabled = dataPreferences.getSync('ai_enabled', false as boolean) as boolean
    }
    if(store != undefined) {
      let mStore = (store as relationalStore.RdbStore);
      this.formats = Format.load_all_formats(mStore)
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

      this.express_reg = dreg.concat(Express.load_all_expresses(mStore)).join("|")
      let ports = Port.load_all_ports(mStore).convertToArray()
      this.port_reg = ports.join("|")

    }

  }
  scroller: Scroller = new Scroller();
  dx : number = 0
  dy : number = 0

  build() {
    Stack() {
      Scroll(this.scroller) {
        Column() {
          Text(this.message)
            .id('AddCodePageHelloWorld')
            .fontSize(35)
            .fontWeight(FontWeight.Bold)
            .margin({
              left: 30
            }).width('90%')
          TextArea({
            placeholder: "请输入您的取件码短信",
          })
            .maxLines(10)
            .width('85%')
            .height(150)
            .margin({
              left: 30,
              top: 30,
              right: 30
            })
            .onChange((value: string) => {
              this.input = value
              console.info(value);
            })
            .onFocus(() => {
              console.info('获取焦点');
            })
          Row({space:10}) {
            Button("取消").onClick(e => {
              this.controller?.close()
            }).backgroundColor(Color.Red)
            Button("解析").onClick(async e => {
              if (this.input == '') {
                promptAction.showToast({
                  message: "您输入的含有取件码的短信为空",
                  duration: 1500
                })
                return
              }
              // 匹配取件短信this.input中的取件码信息
              // 先过滤掉 电话号码 11位
              let filterInput = this.input.replace(/1\d{10}/g, "")
              if (filterInput == '') {
                promptAction.showToast({
                  message: "短信内容为空",
                  duration: 2000,
                });
                this.input = ''
                return
              }
              if (this.isAIEnabled){
                this.isLoading = true

                parseCodeBySMS(filterInput).then(res => {

                })
                try {
                  let res = await parseCodeBySMS(filterInput)
                  if (res && res.code === 200) {
                    this.last_codes = new List<string>()
                    if (res.data){
                      res.data.code.forEach(code => {
                        if (this.last_codes.getIndexOf(code) == -1) {
                          this.last_codes.add(code)
                        }
                      })

                      if (store) {
                        Port.delete_by_id(
                          store, this.port
                        )
                        Express.delete_by_id(
                          store, this.express
                        )
                      }
                      this.codes = this.last_codes.convertToArray()
                      this.express = res.data.kd
                      this.port = res.data.yz
                      this.port_local = res.data.local
                      if (store){

                        Port.insert_formats(
                          store,new Port(0,this.port, this.port_local,this.port)
                        )
                        Express.insert_express(
                          store,new Express(0,this.express, this.express,this.express)
                        )
                      }

                      this.isjiexi = true
                      return
                    }else{
                      promptAction.showToast({
                        message: "解析失败",
                        duration: 1500
                      }
                      )
                    }


                  }
                } catch (err) {
                  console.error(`AI parse failed: ${err}`)
                } finally {
                  this.isLoading = false
                }
              }
              this.last_codes = new List<string>()


              // 匹配取件码默认规则 12-34-1244 ， 0代表 1-9之间的数字
              for (let i: number = 0; i < this.formats.length; i++) {
                console.log(this.message, this.formats.get(i))
                let reg = new RegExp(this.formats.get(i).replace(/\?/g, "\\?"), "g")
                console.log(this.message, reg)

                let arrs = filterInput.matchAll(reg)
                for (const arr of arrs) {
                  if (this.last_codes.getIndexOf(arr[0]) == -1) {
                    this.last_codes.add(arr[0])
                  }
                }
              }
              let express_reg = new RegExp(this.express_reg, "g")
              let express_res = filterInput.match(express_reg)
              if (express_res) {
                this.express = express_res[0]
              }

              let port_regs = new RegExp(this.port_reg, "g")
              let port_res = filterInput.match(port_regs)
              if (port_res) {
                this.port = port_res[0]
              }


              this.codes = this.last_codes.convertToArray()

              if (this.codes.length == 0) {
                promptAction.showToast({
                  message: "未匹配到取件码，您可能需要手动输入",
                  duration: 2000,
                })
              } else {
                console.log(this.message, this.codes)
                console.log(this.message, typeof this.codes)
              }
              this.isjiexi = true


            })

          }.width('95%').justifyContent(FlexAlign.End).margin({
            top: 10,right:30
          })

          //34-23-4424,34-23-4424
          if (this.codes.length > 0) {
            Text('已经匹配到的取件码')
              .id('AddCodePageHelloWorld')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .width('90%')
              .margin({
                left: 30
              })
            Column() {
              ForEach(this.codes, (item: string, position: number) => {
                ListItem() {
                  Row() {
                    Text(item).fontSize(20).width('80%')
                    Button('x').backgroundColor(Color.Gray).width(40).height(40).onClick(e => {
                      this.codes.splice(position, 1);
                      this.last_codes.removeByIndex(position)
                    })
                  }
                  .width('100%')
                  .backgroundColor(
                    $r('sys.color.ohos_id_color_toolbar_sub_bg')
                  )
                  .padding(15)
                  .width('90%')
                  .margin({
                    left: 30
                  })
                  .borderRadius(15)

                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                }
                // 菜鸟驿站金日成广场站
                // 朝鲜平壤
              }, (item: string) => item)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)

            .padding({
              top: 20
            })
          }
          if (this.express !== "") {
            Text('已经匹配到的快递')
              .id('AddCodePageHelloWorld')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .width('90%')
              .margin({
                left: 30,
                top: 10
              })
            Row() {
              Text(this.express).fontSize(20).width('80%')
              Button('x').backgroundColor(Color.Gray).width(40).height(40).onClick(e => {
                this.express = ""
              })
            }
            .width('100%')
            .backgroundColor(
              $r('sys.color.ohos_id_color_toolbar_sub_bg')
            )
            .padding(15)
            .width('90%')
            .margin({
              left: 30
            })
            .borderRadius(15)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
          }
          if (this.port !== "") {
            Text('已经匹配到的快递')
              .id('AddCodePageHelloWorld')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .width('90%')
              .margin({
                left: 30,
                top: 10
              })
            Row() {
              Text(this.port).fontSize(20).width('80%')
              Button('x').backgroundColor(Color.Gray).width(40).height(40).onClick(e => {
                this.port = ""
              })
            }
            .width('100%')
            .backgroundColor(
              $r('sys.color.ohos_id_color_toolbar_sub_bg')
            )
            .padding(15)
            .width('90%')
            .margin({
              left: 30
            })
            .borderRadius(15)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
          }
          if (this.isjiexi) {
            Text('没有你想要的取件码？')
              .id('AddCodePageHelloWorld')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .width('90%')
              .margin({
                left: 30,
                top: 15
              })
            Text('点击添加后，我们将自动为您添加匹配格式，以供你您下一次使用。')
              .id('AddCodePageHelloWorld')
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontStyle(FontStyle.Italic)
              .width('90%')
              .margin({
                left: 30
              })
            // 菜鸟驿站朝鲜金日成广场站， 顺丰
              // 朝鲜平壤特别市金日成广场朝鲜劳动党总部楼下
            TextInput({
              placeholder: "请输入短信中的取件码"
            }).width('85%').margin({
              left: 30, top: 10
            }).padding(15).onChange((value: string) => {
              this.code_input = value
              console.info(value);
            })
            // this.last_codes
            Row() {
              Button("添加")
            }.width('95%').justifyContent(FlexAlign.End).margin({
              top: 10
            })
            .onClick(e => {
              if (this.code_input == '') {
                promptAction.showToast({
                  message: "您输入的取件码为空",
                  duration: 1500
                })
                return
              }
              let reg = ''
              // 逐个字符匹配，是数字添加[0-9],是字母添加[a-z,A-Z]
              for (let index = 0; index < this.code_input.length; index++) {
                const element = this.code_input[index];
                let numReg = new RegExp(/[0-9]/)
                let laterReg = new RegExp(/[a-z,A-Z]/)
                if (numReg.test(element)) {
                  reg += '[0-9]'
                } else if (laterReg.test(element)) {
                  reg += '[a-z,A-Z]'
                } else{
                  reg+=element
                }
              }
              console.log(this.message, reg)

              this.last_codes.add(this.code_input)
              this.codes = this.last_codes.convertToArray()
              console.log(this.message, store)

              if (store!= undefined) {
                let id = Format.insert_formats(
                  store, new Format(0, this.code_input, reg, '')
                )
                if (id === -1) {
                  return
                }
                console.log(this.message, id)

              }

            })

            if (!this.express){
              Text('没有你想要的快递？')
                .id('AddCodePageHelloWorld')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .width('90%')
                .margin({
                  left: 30,
                  top: 15
                })
              Text('点击添加后，我们将自动为您添加匹配格式，以供你您下一次使用。')
                .id('AddCodePageHelloWorld')
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .fontStyle(FontStyle.Italic)
                .width('90%')
                .margin({
                  left: 30
                })
              TextInput({
                placeholder: "请输入短信中的快递（不包含‘快递’）"
              }).width('85%').margin({
                left: 30, top: 10
              }).padding(15).onChange((value: string) => {
                this.express_input = value
                console.info(value);
              })
              // this.last_codes
              Row() {
                Button("添加")
              }.width('95%').justifyContent(FlexAlign.End).margin({
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
                  console.log(this.message, id)
                  this.express = this.express_input
                }

              })
            }
            if (!this.port){
              Text('没有你想要的快递驿站？')
                .id('AddCodePageHelloWorld')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .width('90%')
                .margin({
                  left: 30,
                  top: 15
                })
              Text('点击添加后，我们将自动为您添加匹配格式，以供你您下一次使用。')
                .id('AddCodePageHelloWorld')
                .fontSize(10)
                .fontWeight(FontWeight.Regular)
                .fontStyle(FontStyle.Italic)
                .width('90%')
                .margin({
                  left: 30
                })
              TextInput({
                placeholder: "请输入短信中的快递驿站名"
              }).width('85%').margin({
                left: 30, top: 10
              }).padding(15).onChange((value: string) => {
                this.port_input = value
                console.info(value);
              })
              TextInput({
                placeholder: "请输入短信中的快递驿站地址"
              }).width('85%').margin({
                left: 30, top: 10
              }).padding(15).onChange((value: string) => {
                this.port_local_input = value
                console.info(value);
              })
              // this.last_codes
              Row() {
                Button("添加")
              }.width('95%').justifyContent(FlexAlign.End).margin({
                top: 10
              })
              .onClick(e => {
                if (this.port_input == '') {
                  promptAction.showToast({
                    message: "您输入的快递驿站为空",
                    duration: 1500
                  })
                  return
                }
                if (this.port_local_input == '') {
                  promptAction.showToast({
                    message: "您输入的快递驿站地址为空",
                    duration: 1500
                  })
                  return
                }
                let reg = ''
                console.log(this.message,  this.port_input)
                console.log(this.message, store != undefined)

                if (store!= undefined) {
                  let id = Port.insert_formats(
                    store, new Port(0, this.port_input, this.port_local_input, this.port_input)
                  )

                  console.log(this.message, id)
                  this.port = this.port_input
                  this.port_local_input = this.port_local_input
                  this.port_input = ''
                  this.port_local_input = ''

                }


              })
            }

          }
          if (this.isjiexi){
            Button('添加').width(
              '90%'
            ).margin('5%').onClick(e=>{
              if (this.codes.length == 0){
                promptAction.showToast({
                  message: "没有取件码",
                  duration: 1500
                })
                return
              }
              if (!this.express){
                promptAction.showToast({
                  message: "没有快递信息",
                  duration: 1500
                })
                return
              }
              //
              if (!this.port){
                promptAction.showToast({
                  message: "没有驿站信息",
                  duration: 1500
                })
                return
              }
              let succeedNum = 0
              if (store) {
                for (let i = 0; i < this.codes.length; i++) {
                  let res = Code.insert_code(
                    store, new Code(0, this.codes[i], this.express, this.port, 0)
                  )
                  if (res != -1){
                    succeedNum+=1
                  }
                }
              }
              promptAction.showToast({
                message: "添加成功",
                duration: 1500
              })
              //router.back()
              if(this.onClickOK){
                this.onClickOK()

              }
              this.controller?.close()

            })
          }



        }.backgroundColor(
          Color.White
        )
        .width('95%').padding({
          top:'10%',bottom:'10%'
        }).alignItems(HorizontalAlign.Center).margin('2.5%').justifyContent(FlexAlign.Start).borderRadius(20)
      }.padding({
        bottom:'20%',
      }).scrollable(ScrollDirection.Vertical)
      .scrollBarColor(Color.Gray) // 滚动条颜色
      .scrollBarWidth(5) // 滚动条宽度
      .edgeEffect(EdgeEffect.None) // 滚动到边沿后回弹

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
          Text('正在解析...')
            .fontSize(16)
            .margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .justifyContent(FlexAlign.Center)
      }
    }
  }
}