import http from '@ohos.net.http';

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