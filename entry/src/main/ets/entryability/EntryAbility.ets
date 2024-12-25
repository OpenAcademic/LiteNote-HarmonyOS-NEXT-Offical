import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';
import { relationalStore } from '@kit.ArkData';
import { Code } from '../entity/code';
import { Express } from '../entity/express';
import { Port } from '../entity/port';
import { Format } from '../entity/format';
import { Product } from '../entity/product';
import { Maintenance } from '../entity/maintenance';

import AbilityStage from '@ohos.app.ability.AbilityStage';
import { preInit, InternalPlugin, setLogEnabled, init, onEventObject } from '@umeng/analytics';


export let store: relationalStore.RdbStore | undefined = undefined;
export let dataPreferences: preferences.Preferences | null = null;
export let kvManager: distributedKVStore.KVManager | undefined = undefined;
export let kvStore: distributedKVStore.SingleKVStore | null = null;
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void
  {
    preInit({
      context: this.context.getApplicationContext(),
      plugins: [new InternalPlugin()]
    });
    let context = this.context
    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: 'cn.tw.sar.note'
    };
    try {
      // 创建KVManager实例
      kvManager = distributedKVStore.createKVManager(kvManagerConfig);
      console.info('Succeeded in creating KVManager.');
      try {
        const options: distributedKVStore.Options = {
          createIfMissing: true,
          encrypt: false,
          backup: false,
          autoSync: false,
          kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
          securityLevel: distributedKVStore.SecurityLevel.S2,
        };
        kvManager.getKVStore('note', options, (err: BusinessError, store: distributedKVStore.SingleKVStore) => {
          if (err) {
            console.error(`Failed to get KVStore.code is ${err.code},message is ${err.message}`);
            return;
          }
          console.info("Succeeded in getting KVStore");
          kvStore = store;
        });
      } catch (e) {
        let error = e as BusinessError;
        console.error(`An unexpected error occurred.code is ${error.code},message is ${error.message}`);
      }
      // 继续创建获取数据库
    } catch (e) {
      let error = e as BusinessError;
      console.error(`Failed to create KVManager. Code:${error.code},message:${error.message}`);
    }

    let options: preferences.Options = { name: 'litenote' };
    dataPreferences = preferences.getPreferencesSync(this.context,
      options);

    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: "litenote.db",
      securityLevel: relationalStore.SecurityLevel.S1
    };

   relationalStore.getRdbStore(this.context, STORE_CONFIG, (err: BusinessError, rdbStore: relationalStore.RdbStore) => {
      store = rdbStore;
      // 设置数据库版本
      if(store != undefined) {
        (store as relationalStore.RdbStore).version = 3;
        // 获取数据库版本
        console.info(`RdbStore version is ${store.version}`);
        // 获取数据库是否重建
        console.info(`RdbStore rebuilt is ${store.rebuilt}`);
        if(store != undefined) {
          let mStore = (store as relationalStore.RdbStore);

          Code.build_create_table_sql(mStore);
          Express.build_create_table_sql(mStore);
          Port.build_create_table_sql(mStore);
          Format.build_create_table_sql(mStore);
          //Code.load_graph(mStore)
          Product.build_create_table_sql(mStore);
          Maintenance.build_create_table_sql(mStore);

        }
      }
      if (err) {
        console.error(`Get RdbStore failed, code is ${err.code},message is ${err.message}`);
        return;
      }
      console.info('Get RdbStore successfully.');
    })


    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
