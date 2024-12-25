import { promptAction, router } from '@kit.ArkUI';
import cryptoFramework from "@ohos.security.cryptoFramework";
import { buffer, util } from '@kit.ArkTS';
import { login, regest } from '../service/api';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State repassword: string = '';
  @State agree : boolean = false
  @State loading : boolean = true

  @State status : number = 0 // 0表示登陆，1表示注册
  stringToUint8Array(str: string) {

    return new Uint8Array(buffer.from(str, 'utf-8').buffer);

  }
   async  digest(text: string): Promise<Uint8Array> {
    let md5 = cryptoFramework.createMd("MD5")
    await md5.update({ data: this.stringToUint8Array(text) })
    let result = await md5.digest()
    return result.data
  }
  uint8ArrayToHexStr(data: Uint8Array): string {

    let hexString = "";

    let i: number;

    for (i = 0; i < data.length; i++) {

      let char = ('00' + data[i].toString(16)).slice(-2);

      hexString += char;

    }

    return hexString;

  }

  build() {
    Stack() {
      Column() {
        // 顶部的欢迎文字
        Column() {
          RelativeContainer() {
            Text('您好！')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Red)
              .alignRules({
                top: { anchor: '__container__', align: VerticalAlign.Top },
                center: { anchor: '__container__', align: VerticalAlign.Center }
              })
              .width('100%');

            Text('欢迎使用红宝书！')
              .fontSize(22)
              .fontColor(Color.Black)
              .alignRules({
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                center: { anchor: '__container__', align: VerticalAlign.Center }
              })
              .width('100%')
              .margin({ top: 80 });
          }
          .height('30%')
          .width('100%')
          .padding({ left: 32, right: 32 })
          .backgroundColor(Color.White);

          // 用户名和密码输入框

          Column() {
            // 用户名输入框
            Column() {
              TextInput({ placeholder: '请输入用户名', text: this.username })
                .onChange((value: string) => {
                  this.username = value;
                })
                .fontSize(18)
                .fontColor(Color.Black)
                .width('100%')
                .height(50)
                .padding({ left: 10, right: 10 });
              Divider().height(1).color('#194487fe'); // 下划线
            }

            // 密码输入框
            Column() {
              TextInput({ placeholder: '请输入密码', text: this.password })
                .onChange((value: string) => {
                  this.password = value;
                })
                .fontSize(18)
                .fontColor(Color.Black)
                .width('100%')
                .height(50)
                .padding({ left: 10, right: 10 })
                .type(InputType.Password);
              Divider().height(1).color('#194487fe'); // 下划线
            }.margin({ top: 32 });
            if (this.status==1){
              Column() {
                TextInput({ placeholder: '请再次输入密码', text: this.repassword })
                  .onChange((value: string) => {
                    this.repassword = value;
                  })
                  .fontSize(18)
                  .fontColor(Color.Black)
                  .width('100%')
                  .height(50)
                  .padding({ left: 10, right: 10 })
                  .type(InputType.Password);
                Divider().height(1).color('#194487fe'); // 下划线
              }.margin({ top: 32 });

            }

          }
          .width('100%')
          .padding({ left: 32, right: 32 })
          .backgroundColor(Color.White);

          // 记住密码与忘记密码行
          Row() {
            Row() {
              // 根据用户是否选择记住密码，显示不同的图标
              Row(){
                Checkbox({

                }).select(this.agree).onClick(e=>{
                  this.agree = !this.agree;

                })


                Text('您是否同意并阅读《红宝书用户协议》并选择注册一个账号')
                  .fontSize(14)
                  .fontColor(Color.Red)
                  .margin({ left: 5.5 }).width('60%')
                  .onClick( () => {
                    // 也可以点击文字时切换记住密码的状态
                    router.pushUrl({
                      url:"pages/WebViewPage",
                      params:{
                        url:"yhxy.html",
                        local:true
                      }
                    })
                  });
              }
              if (this.status==0){
                Text('没有账号')
                  .fontSize(14)
                  .fontColor(Color.Gray)
                  .onClick(() => {
                    // 实现忘记密码功能，跳转或弹出窗口
                    this.status = 1
                  });
              }else{
                Text('已有账号')
                  .fontSize(14)
                  .fontColor(Color.Gray)
                  .onClick(() => {
                    // 实现忘记密码功能，跳转或弹出窗口
                    this.status = 0
                  });
              }

            }.width('100%')
            .justifyContent(FlexAlign.SpaceBetween)


          }.width('100%')
          .justifyContent(FlexAlign.SpaceBetween).margin({ top:10,bottom:10 })
          .padding({ left: 32, right: 32 })


          // 登录按钮
          Button(this.status===0?'登 录':'注 册')
            .width('70%')
            .height(50)
            .backgroundColor(Color.Red)
            .fontSize(18)
            .fontColor(Color.White)
            .onClick(async () => {
              // 处理登录逻辑，并且在用户选择记住密码时保存密码
              if (!this.agree){
                promptAction.showToast({
                  message: "您还没有同意用户协议",
                  duration: 1500
                })
                return
              }
                if (!this.username || !this.password){
                  promptAction.showToast({
                    message: "您输入的信息为空",
                    duration: 1500
                  })
                  return
                }
                if (this.status===1){
                  if (!this.repassword){
                    promptAction.showToast({
                      message: "您输入的信息为空",
                      duration: 1500
                    })
                    return
                  }
                  if (this.repassword!==this.password){
                    promptAction.showToast({
                      message: "您输入的两次密码不一致",
                      duration: 1500
                    })
                    return
                  }
                }
                const md5password = this.uint8ArrayToHexStr(await this.digest(this.password))
                if (this.status===0){
                  const res = await login(this.username,md5password)
                  if (res){
                    promptAction.showToast({
                      message: "登陆成功",
                      duration: 1500
                    })
                    router.back()
                  }else{
                    promptAction.showToast({
                      message: "登陆失败",
                      duration: 1500
                    })
                  }
                }else{
                  const res = await regest(this.username,md5password)
                  if (res){
                    promptAction.showToast({
                      message: "注册成功，去登陆",
                      duration: 1500
                    })
                    this.status=0
                  }else{
                    promptAction.showToast({
                      message: "注册失败",
                      duration: 1500
                    })
                  }
                }


            })
            .margin({ top:15,bottom:60,left: 32, right: 32 });

          // 底部图片


        }
        .height('100%')
        .width('100%')
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.Center);

        if (this.loading) {
          LoadingProgress().height(180).color('#cd0401');
        }
      }
    }
  }

}