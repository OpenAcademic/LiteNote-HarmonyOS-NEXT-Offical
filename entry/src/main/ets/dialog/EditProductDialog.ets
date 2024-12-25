import { promptAction } from "@kit.ArkUI"
import { Product } from "../entity/product"
import { store } from "../entryability/EntryAbility"
import { SelectDateDialog } from "./AddProductDialog"

@CustomDialog
export struct EditProductDialog {
  @State selectedDate: Date | undefined = undefined
  dialogController: CustomDialogController = new CustomDialogController({
    builder: SelectDateDialog({
      selected: (value: Date) => {
        this.selectedDate = value
      }
    })
  })
  
  controller?: CustomDialogController
  onEdit?: () => void
  product: Product  = new Product(
    0,"",0,0,"",0
  )

  constructor(product: Product) {
    super()
    this.product = product
  }
  
  @State name: string = ''
  @State price: number = 0
  @State property: string = ''
  @State chengben: number = 0
  
  aboutToAppear() {
    this.name = this.product.name
    this.price = this.product.price
    this.property = this.product.property
    this.chengben = this.product.chengben
    this.selectedDate = new Date(this.product.purchaseTime)
  }
  
  build() {
    Column() {
      Text("编辑产品")
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 15 })

      // 产品名称
      Row() {
        Text("名称").fontSize(20).fontWeight(FontWeight.Bold)
        TextInput({
          placeholder: "请输入产品名称",
          text: this.name
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
      // 产品成本
      Row() {
        Text("价格").fontSize(20).fontWeight(FontWeight.Bold)
        TextInput({
          placeholder: "请输入产品价格",
          text: this.price.toString()
        })
          .width('70%')
          .padding(15)
          .onChange((value: string) => {
            try{
              this.price = Number.parseFloat(value)
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
          placeholder: "请输入产品成本",
          text: this.chengben.toString()
        })
        .width('70%')
        .padding(15)
        .onChange((value: string) => {
          try{
            this.chengben = Number.parseFloat(value)
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
          placeholder: "请输入产品属性描述",
          text: this.property
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

        Button("保存")
          .width('30%')
          .onClick(() => {
            if (!this.name || !this.chengben || !this.selectedDate) {
              promptAction.showToast({
                message: "请填写完整的产品信息",
                duration: 1500
              })
              return
            }
            
            if (store) {
              let success = Product.update_product(store, 
                new Product(this.product.id, this.name, this.price, 
                  this.selectedDate.getTime(), this.property, this.chengben))
              
              if (success) {
                promptAction.showToast({ message: "更新成功", duration: 1500 })
              } else {
                promptAction.showToast({ message: "更新失败", duration: 1500 })
              }
            }
            
            if (this.onEdit) {
              this.onEdit()
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