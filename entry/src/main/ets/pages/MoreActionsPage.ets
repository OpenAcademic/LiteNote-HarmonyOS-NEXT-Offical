import { router } from '@kit.ArkUI';
import { HomePage } from '../subpages/home';
import { ProductListPage } from './ProductListPage';

class IDOBJ{
  id:number

  constructor(id:number) {
    this.id = id
  }
}
@Entry
@Component
struct MoreActionsPage {
  @State message: string = 'Hello World';
  @State model_select : number = 0

  aboutToAppear(): void {
    let q = router.getParams() as IDOBJ
    console.log("dfsf",q.id)
    this.model_select  = q.id
    if (router.getParams()){

    }
  }
  onPageShow(): void {
  }
  build() {
    RelativeContainer() {
      if (this.model_select==0){
        HomePage()
      }else if (this.model_select == 1){
        ProductListPage()
      } else{
        HomePage()

      }
    }
    .height('100%')
    .width('100%')
  }
}