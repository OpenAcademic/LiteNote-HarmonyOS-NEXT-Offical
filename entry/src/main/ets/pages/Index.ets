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
import { MoreSubActionsPage, ProductListPage } from './ProductListPage';
import { getUserInfo, UserInfo } from '../service/api';
import { LLMHomePage } from '../subpages/homepage';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  dialogController: CustomDialogController | null = null
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()
  @State model_select : number = 0
  @State is_updated_pa : boolean = false
  @State userinfo :UserInfo | null = null
  @State haveuserinfo : boolean = false

  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }
  async onPageShow() {
    if (dataPreferences) {
      this.model_select = dataPreferences.getSync('mode_select', 0 as number) as number
    }
    const p = await getUserInfo()
    if (p){
      this.userinfo=p
      this.haveuserinfo = true
    }else{
      this.haveuserinfo = false
    }
  }



  async aboutToAppear() {
    if (dataPreferences !== undefined) {
      let mdataPreferences = dataPreferences as  preferences.Preferences
      let res = mdataPreferences.getSync("first_open",true)
      console.info("my",res)
      if (res){
        this.dialogController = new CustomDialogController({
          builder: PrivacyDialog({
            is_updated:true
          }),
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
        if (this.dialogController != null) {
          this.dialogController.open()
        }
      }else{

        let mdataPreferences = dataPreferences as  preferences.Preferences

        let  is_skip_pa = mdataPreferences.getSync('is_skip_pa', false) as boolean
        if (!is_skip_pa){
          this.is_updated_pa = mdataPreferences.getSync('is_updated_pa', false) as boolean
          if (!this.is_updated_pa){
            this.dialogController = new CustomDialogController({
              builder: PrivacyDialog({
                is_updated:false
              }),
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
            if (this.dialogController != null) {
              this.dialogController.open()
            }
          }else{
            this.dialogController = null // 将dialogController置空
          }
        }

      }
    }


  }
  build() {
    RelativeContainer() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller, index: this.currentIndex }) {
        TabContent() {
          LLMHomePage()

        }
        .tabBar({
          text:"首页",
          icon:this.currentIndex === 0?$r('app.media.home_click'):$r('app.media.home')
        })
        TabContent() {
          MoreSubActionsPage()
        }
        .tabBar({
          text:"更多功能",
          icon:this.currentIndex === 1?$r('app.media.product_click'):$r('app.media.product_unclick')
        })
        TabContent() {
          OverLookPage()
        }
        .tabBar({
          text:"总览",
          icon:this.currentIndex === 2?$r('app.media.overlook_click'):$r('app.media.overlook')
        })


        TabContent() {
          MinePage({
            userinfo:this.userinfo === null ? undefined : this.userinfo,
            have_userinfo:this.haveuserinfo
          })
        }
        .tabBar({
          text:"我的",
          icon:this.currentIndex === 3?$r('app.media.mine_click'):$r('app.media.mine')
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


