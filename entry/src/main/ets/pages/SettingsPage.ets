import { dataPreferences } from '../entryability/EntryAbility'
import { promptAction } from '@kit.ArkUI'

@Entry
export struct SettingsPage {
  @State isAIEnabled: boolean = false
  @State models_regs : string[] = []
  @State modes : SelectOption[] = []
  @State model_select : number = 0

  aboutToAppear() {
    // 读取设置
    if (dataPreferences) {
      this.isAIEnabled = dataPreferences.getSync('ai_enabled', false as boolean) as boolean
      this.model_select = dataPreferences.getSync('mode_select', 0 as number) as number
    }
    let dreg = [
      "取件码",
      "产品管理",
      // "车票收藏",
    ]
    dreg.forEach((value,index)=>{
      this.modes.push({value:value})
    })
  }

  build() {
    Column() {
      Text("设置")
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 20, bottom: 10 })

      Row() {
        Text("大模型解析")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        
        Toggle({ type: ToggleType.Switch, isOn: this.isAIEnabled })
          .onChange((isOn: boolean) => {
            this.isAIEnabled = isOn
            if (dataPreferences) {
              try {
                dataPreferences.putSync('ai_enabled', isOn)
                dataPreferences.flush()
                promptAction.showToast({
                  message: "设置已保存",
                  duration: 1500
                })
              } catch (err) {
                console.error(`Failed to save settings: ${err}`)
                promptAction.showToast({
                  message: "设置保存失败",
                  duration: 1500
                })
              }
            }
          })
      }
      .width('90%').backgroundColor(
        $r('sys.color.ohos_id_color_toolbar_sub_bg')
      ).borderRadius('2%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)
      .margin({ top: 20 })



    }
    .width('100%')
    .height('100%')
  }
} 