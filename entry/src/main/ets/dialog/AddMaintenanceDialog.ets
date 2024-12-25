import { promptAction } from "@kit.ArkUI"
import { Maintenance } from "../entity/maintenance"
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

      })
      .width('100%')
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
            if (!this.selectedDate){
              promptAction.showToast({
                message:"你还没有选择噢",
                duration:1500
              })
              return
            }
            if (this.selected){
              this.selected(this.selectedDate)
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

@CustomDialog
export struct AddMaintenanceDialog {
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
  productId: number = 0

  constructor(productId: number) {
    super()
    this.productId = productId
  }
  
  @State content: string = ''
  @State price: number = 0
  
  build() {
    Column() {
      Text("添加维护记录")
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 15 })

      // 维护内容
      Row() {
        Text("内容").fontSize(20).fontWeight(FontWeight.Bold)
        TextArea({
          placeholder: "请输入维护内容"
        })
        .width('70%')
        .height(100)
        .onChange((value: string) => {
          this.content = value
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)

      // 维护费用
      Row() {
        Text("费用").fontSize(20).fontWeight(FontWeight.Bold)
        TextInput({
          placeholder: "请输入维护费用"
        })
        .width('70%')
        .padding(15)
        .onChange((value: string) => {
          try {
            this.price = Number.parseFloat(value)
          } catch (e) {
          }
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)

      // 维护时间
      Row() {
        Text("维护时间").fontSize(20).fontWeight(FontWeight.Bold)
        if (this.selectedDate) {
          Button(this.selectedDate.toLocaleDateString())
            .onClick(() => {
              this.dialogController.open()
            })
        } else {
          Button("选择")
            .onClick(() => {
              this.dialogController.open()
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
            if (!this.content || !this.price || !this.selectedDate) {
              promptAction.showToast({
                message: "请填写完整的维护信息",
                duration: 1500
              })
              return
            }
            
            if (store) {
              Maintenance.insert_maintenance(store,
                new Maintenance(0, this.productId, this.content, this.price, this.selectedDate.getTime()))
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