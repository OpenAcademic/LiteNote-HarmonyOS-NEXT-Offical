import { relationalStore } from "@kit.ArkData"
import { List } from "@kit.ArkTS"
import { CompareItem } from "./code"
/**
 * 菜鸟驿站首尔龙山店
 * 菜鸟驿站平壤龙城店
 * 大韩民国首尔特别市龙山总统府
 * 朝鲜民主主义人民共和国平壤特别市龙城官邸
 * 忠诚
 *
 * 菜鸟驿站首尔龙山店
 * 忠诚
 * 34-4455
 *
 * 菜鸟驿站黄埔军校店
 * 亲爱精诚
 * 34-33456
 *
 * 菜鸟驿站平壤龙城店
 * 主体
 * 34-3333
 */
@Observed
export class Express {
  id : number
  express: string
  express_local: string
  regex:string = ""

  constructor(id:number,express: string, express_local: string,  regex: string) {
    this.id = id
    this.express = express
    this.express_local = express_local
    this.regex = regex
  }

  static delete_by_id(store:relationalStore.RdbStore,name:string) : boolean{
    let predicates = new relationalStore.RdbPredicates("express");
    predicates.equalTo("express", name);
    console.info(`Delete rows: ${name}`);

    if(store != undefined) {
      try {
        let rows: number = store.deleteSync(predicates)
        console.info(`Delete rows: ${rows}`);
        return rows != 0

      } catch (err) {
        console.error(`Delete failed, code is ${err.code},message is ${err.message}`);
        return false
      }
    }
    return false

  }


  static build_create_table_sql(store:relationalStore.RdbStore){
    let createTableSql = `CREATE TABLE IF NOT EXISTS express ( `;
    createTableSql += `id INTEGER AUTO_INCREMENT   , `;
    createTableSql += `express TEXT  , `;
    createTableSql += `express_local TEXT , `;
    createTableSql += `regex TEXT , `;
    createTableSql += `PRIMARY KEY(id))`;
    return store.executeSync(createTableSql)
  }

  static insert_express(
    store:relationalStore.RdbStore,
    express:Express
  ) : number {
    const valueBucket3: relationalStore.ValuesBucket = {
      "express" : express.express,
      "express_local" : express.express_local,
      "regex" : express.regex
    };
    let predicates = new relationalStore.RdbPredicates("format");
    predicates.equalTo("express",express.regex)

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id",  "regex"]);
    if (resultSet.rowCount > 0){
      return -1
    }


    if(store != undefined) {
      try {
        let rowId : number = (store as relationalStore.RdbStore).insertSync("express",
          valueBucket3, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
        console.info(`Insert is successful, rowId = ${rowId}`);
        return rowId
      } catch (error) {
        console.error(`Insert is failed, code is ${error.code},message is ${error.message}`);
        return -1
      }
    }else{
      return -1
    }

  }

  static load_all_expresses(store:relationalStore.RdbStore):string[]{
    let predicates = new relationalStore.RdbPredicates("express");

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      [ "regex"]);

    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);

    let expresses:List<string> = new List();
    while (resultSet.goToNextRow()) {
      const format_regex = resultSet.getString(resultSet.getColumnIndex("regex"));
      expresses.add(
        format_regex
      )
    }
    return expresses.convertToArray()
  }


  /**
   * Specifies remote devices which connect to local device when syncing distributed database.
   * When query database, this function should not be called.
   *
   * @param { Array<string> } devices - Indicates specified remote devices.
   * @returns { RdbPredicates } - The {@link RdbPredicates} self.
   * @throws { BusinessError } 401 - Parameter error. Possible causes: 1. Mandatory parameters are left unspecified;
   * <br>2. Incorrect parameter types.
   * @syscap SystemCapability.DistributedDataManager.RelationalStore.Core
   * @since 9
   */
  static load_by_resultSet(store:relationalStore.RdbStore,
            options:List<CompareItem>,
            page:number,
            pageSize:number,
  ) : List<Express>{
    let predicates = new relationalStore.RdbPredicates("express");
    for (let i = 0;i<options.length;i++){
      predicates.equalTo(options[i].key,options[i].value)
    }
    predicates.limitAs(pageSize)
    predicates.offsetAs((page-1)*pageSize)
    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id",  "express", "express_local", "regex"]);

    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);

		let expresses:List<Express> = new List();
    while (resultSet.goToNextRow()) {
      const id = resultSet.getLong(resultSet.getColumnIndex("id"));
      const express = resultSet.getString(resultSet.getColumnIndex("express"));
      const express_local = resultSet.getString(resultSet.getColumnIndex("express_local"));
      const regex = resultSet.getString(resultSet.getColumnIndex("regex"));
      expresses.add(
        new Express(id, express, express_local, regex)
      )
    }
    return expresses
	}
}