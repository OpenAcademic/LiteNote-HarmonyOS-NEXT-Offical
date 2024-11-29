import { relationalStore } from '@kit.ArkData'
import { AddProductDialog } from '../dialog/AddProductDialog'
import { Product } from '../entity/product'
import { store } from '../entryability/EntryAbility'
import { ProductCard } from '../widgets/ProductCard'

@Component
export struct ProductListPage {
  @State products: Product[] = []

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddProductDialog({
      onAdd: () => {
        this.loadProducts()
      }
    })
  })

  aboutToAppear() {
    this.loadProducts()
  }

  loadProducts() {
    if(store) {
      let predicates = new relationalStore.RdbPredicates("product")
      predicates.orderByDesc("purchaseTime")
      let resultSet = store.querySync(predicates, ["id", "name", "price", "purchaseTime",
        "property","chengben"])
      
      this.products = []
      while(resultSet.goToNextRow()) {
        this.products.push(new Product(
          resultSet.getLong(resultSet.getColumnIndex("id")),
          resultSet.getString(resultSet.getColumnIndex("name")),
          resultSet.getDouble(resultSet.getColumnIndex("price")),
          resultSet.getLong(resultSet.getColumnIndex("purchaseTime")),
          resultSet.getString(resultSet.getColumnIndex("property")),
          resultSet.getDouble(resultSet.getColumnIndex("chengben")),
        ))
      }
    }
  }

  build() {
    Stack() {
      Column() {
        Text("产品成本管理")
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 20, bottom: 10 })
          
        List({
          space:20
        }) {
          ForEach(this.products, (item: Product) => {
            ListItem() {
              ProductCard({
                product: item,
                onClickOK: ()=>{
                  this.loadProducts()
                }
              })
            }
          })
        }
        .width('100%')
        .margin(20)
        .padding(20)
      }
      .width('100%')
      .height('100%')

      Button({ type: ButtonType.Circle }) {
        Image($r('sys.media.ohos_ic_public_add'))
          .width(24)
          .height(24)
      }
      .width(50)
      .height(50)
      .position({ x: '80%', y: '85%' })
      .backgroundColor('#007DFF')
      .onClick(() => {
        this.dialogController.open()
      })
    }
    .width('100%')
    .height('100%')
  }
}

