import { promptAction } from "@kit.ArkUI"
import { Product } from "../entity/product"
import { store } from "../entryability/EntryAbility"
@CustomDialog
export struct SelectDateDialog {
  selected?: (value: Date) => void

  constructor(t:(value: Date) => void) {
    super()
    this.selected = t
  }
  @State selectedDate: Date | undefined = undefined
  controller?: CustomDialogController
  build() {
    Column() {
      Text("选择日期")
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2100-1-1'),
        selected: this.selectedDate
      })
      .onDateChange((value: Date) => {
        this.selectedDate = value
        console.info('select current date is: ' + value.toString())
        if (this.selected){
          this.selected(value)
        }
        this.controller?.close()
        })
        .width('100%')
        
    }
    .padding(20)
    .margin(20)
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}

@CustomDialog
export struct AddProductDialog {
  @State selectedDate: Date | undefined = undefined
  dialogController: CustomDialogController = new CustomDialogController({
    builder: SelectDateDialog({
      selected: (value: Date) => {
        this.selectedDate = value
      }
    })
  })
  controller?: CustomDialogController
  onAdd?: () => void

  @State name: string = ''
  @State price: number = 0
  @State time:number = 0
  @State property: string = ''
  @State chengben: number = 0

  build() {
    Column() {
      Text("添加产品")
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 15 })

      // 产品名称
      Row() {
        Text("名称").fontSize(20).fontWeight(FontWeight.Bold)
        TextInput({
          placeholder: "请输入产品名称"
        })
        .width('70%')
        .padding(15)
        .onChange((value: string) => {
          this.name = value
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)

      // 产品价格
      Row() {
        Text("价格").fontSize(20).fontWeight(FontWeight.Bold)
        TextInput({
          placeholder: "请输入产品价格",
        })
        .width('70%')
        .padding(15)
        .onChange((value: string) => {
          try{
            this.price =Number.parseFloat(value)
          } catch (e) {
          }
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)

      // 产品成本
      Row() {
        Text("成本").fontSize(20).fontWeight(FontWeight.Bold)
        TextInput({
          placeholder: "请输入产品成本"
        })
        .width('70%')
        .padding(15)
        .onChange((value: string) => {
          try{
            this.chengben =Number.parseFloat(value)
          } catch (e) {
          }
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)

      // 产品属性
      Row() {
        Text("属性").fontSize(20).fontWeight(FontWeight.Bold)
        TextArea({
          placeholder: "请输入产品属性描述"
        })
        .width('70%')
        .height(100)
        .onChange((value: string) => {
          this.property = value
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)

      // 产品购买时间
      Row() {
        Text("购买时间").fontSize(20).fontWeight(FontWeight.Bold)
        if (this.selectedDate) {
            Button(this.selectedDate.toLocaleDateString())
            .onClick(() => {
                this.dialogController.open()
            })
        } else {
            Button("选择")
                    .onClick(() => {
                    this.dialogController?.open()
                    })
        }
        


        
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)

      // 按钮组
      Row() {
        Button("取消")
          .width('30%')
          .onClick(() => {
            this.controller?.close()
          })
          .backgroundColor(Color.Red)

        Button("添加")
          .width('30%')
          .onClick(() => {
            if (!this.name || !this.price || !this.chengben || !this.selectedDate) {
              promptAction.showToast({
                message: "请填写完整的产品信息",
                duration: 1500
              })
              return
            }
            if (store){
              Product.insert_product(store,
                new Product(0,this.name,this.price,this.selectedDate?.getTime()?this.selectedDate.getTime():0,this.property,this.chengben))

            }
            if (this.onAdd) {
              this.onAdd()
            }
            this.controller?.close()
          })
          .backgroundColor(Color.Green)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)
    }
    .padding(20)
    .margin(20)
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
} 