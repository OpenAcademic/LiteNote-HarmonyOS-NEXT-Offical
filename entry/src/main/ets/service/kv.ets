import { dataPreferences } from "../entryability/EntryAbility";
import { preferences } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";


export async function removekey(key:string): Promise<boolean>{
  return new Promise<boolean>((resolve,reject)=>{
    if (dataPreferences !== undefined) {
      let mdataPreferences = dataPreferences as preferences.Preferences

      mdataPreferences.deleteSync(key)
      mdataPreferences.flush((err: BusinessError) => {
        if (err) {
          console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
          resolve(false)

        }
        console.info('Succeeded in flushing.');
        resolve(true)


      })
    }
  })

}

export async function getkeyStr(key:string): Promise<string>{
  return new Promise<string>((resolve,reject)=>{
    if (dataPreferences !== undefined) {
      let mdataPreferences = dataPreferences as preferences.Preferences


      resolve(mdataPreferences.getSync(key,"") as string)

    }
  })

}