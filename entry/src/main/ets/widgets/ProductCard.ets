import { relationalStore } from "@kit.ArkData"
import { Maintenance } from "../entity/maintenance"
import { Product } from "../entity/product"
import { store } from "../entryability/EntryAbility"
import { PublicUtils } from "../utils/pu"
import { AddMaintenanceDialog } from "../dialog/AddMaintenanceDialog"
import { EditProductDialog } from "../dialog/EditProductDialog"
import { TongyiDialog, TongyiDialogConfig } from "../dialog/started"
import { promptAction } from "@kit.ArkUI"

@Component
export struct ProductCard {
  @ObjectLink product: Product
  @State isExpanded: boolean = false
  onClickOK?: () => void;

  @State progress: number = 0
  @State total: number = 0
  @State yu: number = 0

  @State maintenances: Maintenance[] = []
  dialogController?: CustomDialogController | null = null
    editDialogController?: CustomDialogController | null = null
  deleteDialogController?: CustomDialogController | null = null

  aboutToAppear() {
    this.dialogController =  new CustomDialogController({
      builder: AddMaintenanceDialog({
        productId: this.product.id,
        onAdd: () => {
          // 刷新维护记录列表
          this.maintenances = []
          // 重新加载数据
          if (this.onClickOK)
          {
            this.onClickOK()
          }
        }
      })
    })
    this.editDialogController = new CustomDialogController({
      builder: EditProductDialog({
        product: this.product,
        onEdit: () => {
          // 刷新数据
          if (this.onClickOK)
          {
            this.onClickOK()
          }
        }
      })
    })
    let tongyi = ()=>{
      if (store){
        let res = Product.delete_by_id(store,this.product.id)
        if (res){
          promptAction.showToast({
            message: "删除成功",
            duration: 1500
          })
        }else{
          promptAction.showToast({
            message: "删除失败",
            duration: 1500
          })
        }
        if (this.onClickOK){
          this.onClickOK()

        }
      }

    }
    this.deleteDialogController = new CustomDialogController({
      builder: TongyiDialog({
        config: new TongyiDialogConfig(
          "您是否同意删除该产品",
          tongyi
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

    // 计算进度
    const totalDays = Math.floor(this.product.price / this.product.chengben)
    const usedDays = Math.floor((new Date().getTime() - this.product.purchaseTime) / (24 * 60 * 60 * 1000))
    this.total = totalDays
    this.yu = usedDays
    this.progress = Math.min(usedDays / totalDays * 100, 100)
    console.log("ProductCard this.product.price",this.product.price)
    console.log("ProductCard this.product.chengben",this.product.chengben)
    console.log("ProductCard",this.product.purchaseTime)

    // 加载维护记录
    if(store) {
      let predicates = new relationalStore.RdbPredicates("maintenance")
      predicates.equalTo("productId", this.product.id)
      predicates.orderByDesc("maintenanceTime")
      let resultSet = store.querySync(predicates)
      while(resultSet.goToNextRow()) {
        this.maintenances.push(new Maintenance(
          resultSet.getLong(resultSet.getColumnIndex("id")),
          resultSet.getLong(resultSet.getColumnIndex("productId")), 
          resultSet.getString(resultSet.getColumnIndex("content")),
          resultSet.getDouble(resultSet.getColumnIndex("price")),
          resultSet.getLong(resultSet.getColumnIndex("maintenanceTime"))
        ))
      }
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.product.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text(`￥${this.product.price}`)
            .fontSize(16)
            .fontColor('#666')
        }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Center)

        Row(){
          Column(){
            Text("总"+this.total.toFixed(0)+"天")
            Stack(){
              Progress({
                value: this.progress,
                total: 100,
                type: ProgressType.Ring
              }).width(60)
                .height(60)
              Text(this.progress.toFixed(2)).fontWeight(FontWeight.Bolder).fontSize(14).align(Alignment.Top)

            }.width(60)
            .height(60)

            Text("余"+this.yu.toFixed(0)+"天")

          }

          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(24)
            .height(24)
            .rotate({ z: 1, angle: this.isExpanded ? 180 : 0 })
            .onClick(() => {
              this.isExpanded = !this.isExpanded
            })
        }
      }    .justifyContent(FlexAlign.SpaceBetween)

      .width('100%')
      .padding(10)
      
      if(this.isExpanded) {
        Column(){
          Row(){
            Text("维护记录")
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Row(){
              Image($r('sys.media.ohos_ic_public_remove'))
                .width(24)
                .height(24)
                .rotate({ z: 1, angle: this.isExpanded ? 180 : 0 })
                .onClick(() => {
                  if (this.deleteDialogController) {
                    this.deleteDialogController.open()
                  }
                }).margin(5)
              Image($r('sys.media.ohos_ic_public_edit'))
                .width(24)
                .height(24)
                .rotate({ z: 1, angle: this.isExpanded ? 180 : 0 })
                .onClick(() => {
                if (this.editDialogController) {
                      this.editDialogController.open()
                    }
                }).margin(5)
              Image($r('sys.media.ohos_ic_public_add_norm_filled'))
                .width(24)
                .height(24)
                .rotate({ z: 1, angle: this.isExpanded ? 180 : 0 })
                .onClick(() => {
                  if (this.dialogController){
                    this.dialogController.open()
                  }
                }).margin(5)
            }
          }.width('100%').justifyContent(FlexAlign.SpaceBetween)
          List() {
            ForEach(this.maintenances, (item: Maintenance,index:number) => {
              ListItem() {
                Row() {
                  Column() {
                    Circle({ width: 10, height: 10 })
                      .fill(Color.Blue)
                    if(index < this.maintenances.length - 1) {
                      Divider()
                        .vertical(true)
                        .height(40)
                        .strokeWidth(2)
                        .color('#DDDDDD')
                    }
                  }
                  .width(20)
                  .alignItems(HorizontalAlign.Center)

                  Column() {
                    Text(item.content)
                      .fontSize(16)
                    Text(`维护费用: ￥${item.price}`)
                      .fontSize(14)
                      .fontColor('#666')
                    Text(PublicUtils.getDateTime(item.maintenanceTime, 'yyyy-MM-dd'))
                      .fontSize(12)
                      .fontColor('#999')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 10 })
                }
              }
            })
          }.width('100%')

          
        }.width('100%').padding(10)
      }
    }
    .width('100%')
    .padding(10)
    .backgroundColor($r('sys.color.ohos_id_color_toolbar_sub_bg'))
    .borderRadius(15)
  }
} 