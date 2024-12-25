import http from '@ohos.net.http';
import { dataPreferences } from '../entryability/EntryAbility';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

export class  GeneratedTypeLiteralInterface_1 {
  code: string[] = []
  yz: string = ""
  local: string = ""
  kd: string = ""
}

export class  LLMResponse {
  code: number = 0
  msg: string = ""
  data?: GeneratedTypeLiteralInterface_1
}

export class BaseEntity {
  code: number = 0
  msg: string = ""
}

export class ReqEntity {
  code: number = 0
  msg: string = ""
  data: string | UserInfo | Run | FunctionData | FunctionDetailData | HistListData | HisDetailData = ""
}
export class HisDetailData {
  id?: number
  prompts: string = ""
  context: string = ""
  cid?: string
  status?: number
  createTime?: string
}
export class FunctionData {
  id?: number
  name?: string
  img?: string
}
export class FunctionDetailData {
  id: number = 0
  name: string = ""
  img: string = ""
  prompt: string = ""
  fields:string[] = []
  fieldsShow:string[] = []
  createTime: string = ""
}


export class Run {
  content: string= ""
  notice: string = ""
}
@Observed
export class UserInfo {
  id: number=0
  passWord: string=""
  userCreateTime: string=""
  userDesp: string=""
  userImage: string=""
  userKey: string=""
  userLastTime: string=""
  userName: string=""
  userNickName: string=""
  userVip: number=0
  userVipLimited: string=""
  device: string|null=""
  status: number=0
}

export async function parseCodeBySMS(sms: string): Promise<LLMResponse | null> {
  let httpRequest = http.createHttp();
  try {
    let response = await httpRequest.request(
      "https://note.wxd2zrx.top/llm/code",
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({
          sms: sms
        })
      }
    )
    
    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as LLMResponse
      return result
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}

export async function getUserInfo() : Promise<UserInfo | null> {
  let httpRequest = http.createHttp();
  let userKey: string = ""
  if (dataPreferences !== undefined) {
    let mdataPreferences = dataPreferences as preferences.Preferences
    userKey = mdataPreferences.getSync("userKey", "") as string
    if (!userKey){
      return null
    }
  }
  try {
    let response = await httpRequest.request(
      "https://tjut.oac.ac.cn/user/getUserInfo",
      {
        method: http.RequestMethod.POST,
        header: {
          'userKey': userKey
        },
        extraData: {

        }
      }
    )

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity
      return result.data as UserInfo
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}

export async function regest(username:string,password:string)  : Promise<boolean | null> {
  let httpRequest = http.createHttp();

  try {
    let param = "username="+username+"&password="+password
    console.log(param)
    let response = await httpRequest.request(
      "https://tjut.oac.ac.cn/user/regest",
      {
        method: http.RequestMethod.POST,
        header: {
          "Content-Type": "application/x-www-form-urlencoded"


        },
        expectDataType: http.HttpDataType.STRING,
        extraData:param
      }
    )
    console.info("vdf",response.responseCode)
    console.info("vdf",response.result.toString())

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity

      if (result.code===200){
        return true
      }else{
        return false
      }
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}
export async function login(username:string,password:string)  : Promise<boolean | null> {
  let httpRequest = http.createHttp();

  try {
    let response = await httpRequest.request(
      "https://tjut.oac.ac.cn/user/login",
      {
        method: http.RequestMethod.POST,
        header: {
          "Content-Type": "application/x-www-form-urlencoded"

        },
        expectDataType: http.HttpDataType.STRING,
        extraData: "username="+username+"&password="+password
      }
    )

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity
      if (dataPreferences !== undefined) {
        let mdataPreferences = dataPreferences as preferences.Preferences
        if (!result){
          return null
        }
        let data = (result ).data
        mdataPreferences.putSync("userKey", data as string)
        mdataPreferences.flush((err: BusinessError) => {
          if (err) {
            console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
            return;
          }
          console.info('Succeeded in flushing.');
        })
        return true
      }
      return true
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}

export async function getbanners()  : Promise<string[] | null> {
  // https://oac.ac.cn/banner.json
  let httpRequest = http.createHttp();

  try {
    let response = await httpRequest.request(
      "https://oac.ac.cn/banner.json",
      {
        method: http.RequestMethod.GET,
        header: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        expectDataType: http.HttpDataType.STRING,
        // extraData: "username="+username+"&password="+password
      }
    )

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as string[]
      return result
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}

export async function getFunctions() : Promise<FunctionData[] | null> {
  let httpRequest = http.createHttp();
  try {
    let response = await httpRequest.request(
      "https://tjut.oac.ac.cn/functions/get_all",
      {
        method: http.RequestMethod.POST,
        header: {
        },
        extraData: {

        }
      }
    )

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity
      if (result.code===200){
        return result.data as FunctionData[]
      }
      return null
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}
export async function getFunctionsDetail(id:number) : Promise<FunctionDetailData | null> {
  let httpRequest = http.createHttp();
  try {
    let response = await httpRequest.request(
      "https://tjut.oac.ac.cn/functions/get_id",
      {
        method: http.RequestMethod.POST,
        header: {
          "Content-Type": "application/x-www-form-urlencoded"

        },
        extraData: "id="+id
      }
    )

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity
      if (result.code===200){
        return result.data as FunctionDetailData
      }
      return null
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}


export async function createLLM() : Promise<string | null> {
  let httpRequest = http.createHttp();
  let userKey: string | null = null
  if (dataPreferences !== undefined) {
    let mdataPreferences = dataPreferences as preferences.Preferences
    userKey = mdataPreferences.getSync("userKey", "") as string
    if (!userKey){
      userKey = null
    }
  }
  try {
    let response =  userKey? await httpRequest.request(
      "https://tjut.oac.ac.cn/llm/create",
      {
        method: http.RequestMethod.POST,
        header: {
          'userKey': userKey
        },
        extraData: {

        }
      }
    ) : await httpRequest.request(
      "https://tjut.oac.ac.cn/llm/create",
      {
        method: http.RequestMethod.POST,

        extraData: {

        }
      }
    )

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity
      if (result.code===200){
        return result.data as string
      }else{
        return null
      }
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}
export async function runLLM(
  cid:string,prompts:string
) : Promise<Run | null> {
  let httpRequest = http.createHttp();
  let userKey: string | null = null
  if (dataPreferences !== undefined) {
    let mdataPreferences = dataPreferences as preferences.Preferences
    userKey = mdataPreferences.getSync("userKey", "") as string
    if (!userKey){
      userKey = null
    }
  }
  try {
    let response =  userKey? await httpRequest.request(
      "https://tjut.oac.ac.cn/llm/run",
      {
        method: http.RequestMethod.POST,
        header: {
          'userKey': userKey,
          "Content-Type": "application/x-www-form-urlencoded"

        },
        extraData: "prompts="+prompts+"&conversationId="+cid
      }
    ) : await httpRequest.request(
      "https://tjut.oac.ac.cn/llm/run",
      {
        method: http.RequestMethod.POST,
        header:{
          "Content-Type": "application/x-www-form-urlencoded"

        },

        extraData: "prompts="+prompts+"&conversationId="+cid
      }
    )
    console.info("vdf",response.result.toString())
    console.info("vdf",response.responseCode.toString())

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity
      if (result.code===200){
        return result.data as Run
      }else{
        return null
      }
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}
@Observed
export class HistListData {
  id: string = ""
  prompts: string  = ""
  createTime: string = ""
  status: number = 0
  cid: string =""
}
export async function getHistories(page:number) : Promise<HistListData[] | null> {
  let httpRequest = http.createHttp();
  let userKey: string = ""
  if (dataPreferences !== undefined) {
    let mdataPreferences = dataPreferences as preferences.Preferences
    userKey = mdataPreferences.getSync("userKey", "") as string
    if (!userKey){
      return null
    }
  }
  try {
    let response = await httpRequest.request(
      "https://tjut.oac.ac.cn/history/gets",
      {
        method: http.RequestMethod.POST,
        header: {
          'userKey': userKey,
          "Content-Type": "application/x-www-form-urlencoded"

        },
        extraData: "pageNum="+page
      }
    )

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity
      if (result.code===200){
        return result.data as HistListData[]

      }else{
        return null
      }
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}

export async function getHistoriy(cir:string) : Promise<HisDetailData | null> {
  let httpRequest = http.createHttp();
  let userKey: string = ""
  if (dataPreferences !== undefined) {
    let mdataPreferences = dataPreferences as preferences.Preferences
    userKey = mdataPreferences.getSync("userKey", "") as string
    if (!userKey){
      return null
    }
  }
  try {
    let response = await httpRequest.request(
      "https://tjut.oac.ac.cn/history/get_id",
      {
        method: http.RequestMethod.POST,
        header: {
          'userKey': userKey,
          "Content-Type": "application/x-www-form-urlencoded"

        },
        extraData: "id="+cir
      }
    )

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity
      if (result.code===200){
        return result.data as HisDetailData
      }else{
        return null
      }
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}

// delete_id
export async function delHistoriy(cir:string) : Promise<boolean | null> {
  let httpRequest = http.createHttp();
  let userKey: string = ""
  if (dataPreferences !== undefined) {
    let mdataPreferences = dataPreferences as preferences.Preferences
    userKey = mdataPreferences.getSync("userKey", "") as string
    if (!userKey){
      return null
    }
  }
  try {
    let response = await httpRequest.request(
      "https://tjut.oac.ac.cn/history/delete_id",
      {
        method: http.RequestMethod.POST,
        header: {
          'userKey': userKey,
          "Content-Type": "application/x-www-form-urlencoded"

        },
        extraData: "cid="+cir
      }
    )

    if (response.responseCode === 200) {
      console.info("vdf",response.result.toString())
      let result = JSON.parse(response.result.toString()) as ReqEntity
      if (result.code===200){
        return true

      }else{
        return null
      }
    }
    return null
  } catch (err) {
    console.error(`Failed to parse code: ${err}`)
    return null
  } finally {
    httpRequest.destroy()
  }
}
