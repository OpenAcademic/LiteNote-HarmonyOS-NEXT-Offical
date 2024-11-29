import { dataPreferences, kvManager, kvStore, store } from '../entryability/EntryAbility';
import { distributedKVStore, preferences, relationalStore } from '@kit.ArkData';
import { Code, CompareItem } from '../entity/code';
import { List } from '@kit.ArkTS';
import { Express } from '../entity/express';
import { Port } from '../entity/port';
import { Format } from '../entity/format';
import { PrivacyDialog } from '../dialog/started';
import { HomePage } from '../subpages/home';
import { OverLookPage } from '../subpages/overlook';
import { MinePage } from '../subpages/mine';
import { ProductListPage } from './ProductListPage';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: PrivacyDialog(),
    openAnimation: {
      duration: 1200,
      curve: Curve.Friction,
      delay: 500,
      playMode: PlayMode.Alternate,
      onFinish: () => {
        console.info('play end')
      }
    },
    cancel:()=>{

    },
    closeAnimation:{
      duration: 1200,
      curve: Curve.Friction,
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
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }


  async aboutToAppear() {
    if (dataPreferences !== undefined) {
      let mdataPreferences = dataPreferences as  preferences.Preferences
      let res = mdataPreferences.getSync("first_open",true)
      console.info("my",res)
      if (res){

        if (this.dialogController != null) {
          this.dialogController.open()
        }
      }else{
        this.dialogController = null // 将dialogController置空

      }
    }


  }
  build() {
    RelativeContainer() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller, index: this.currentIndex }) {
        TabContent() {
          HomePage()
        }
        .tabBar({
          text:"首页",
          icon:this.currentIndex === 0?$r('app.media.home_click'):$r('app.media.home')
        })

        TabContent() {
          OverLookPage()
        }
        .tabBar({
          text:"总览",
          icon:this.currentIndex === 1?$r('app.media.overlook_click'):$r('app.media.overlook')
        })
        TabContent() {
          ProductListPage()
        }
        .tabBar({
          text:"产品管理",
          icon:this.currentIndex === 1?$r('app.media.product_click'):$r('app.media.product_unclick')
        })

        TabContent() {
          MinePage()
        }
        .tabBar({
          text:"我的",
          icon:this.currentIndex === 2?$r('app.media.mine_click'):$r('app.media.mine')
        })
      }
      .onChange((index: number) => {
        this.currentIndex = index
      }).scrollable(false)

    }
    .height('100%')
    .width('100%')
  }
}


