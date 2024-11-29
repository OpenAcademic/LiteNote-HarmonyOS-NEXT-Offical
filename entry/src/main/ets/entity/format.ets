import { relationalStore } from "@kit.ArkData"
import { List } from "@kit.ArkTS"
import { CompareItem } from "./code"

export class Format {
  id : number
  format_demo: string
  format_regex: string
  format_bac:string

  constructor(id:number,format_demo: string, format_regex: string,  format_bac: string) {
    this.id = id
    this.format_demo = format_demo
    this.format_regex = format_regex
    this.format_bac = format_bac
  }



  static build_create_table_sql(store:relationalStore.RdbStore){
    let createTableSql = `CREATE TABLE IF NOT EXISTS format ( `;
    createTableSql += `id INTEGER  AUTO_INCREMENT   , `;
    createTableSql += `format_demo TEXT  , `;
    createTableSql += `format_regex TEXT , `;
    createTableSql += `format_bac TEXT , `;
    createTableSql += `PRIMARY KEY(id))`;
    return store.executeSync(createTableSql)
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
  ) : List<Format>{
    let predicates = new relationalStore.RdbPredicates("format");
    for (let i = 0;i<options.length;i++){
      predicates.equalTo(options[i].key,options[i].value)
    }
    predicates.limitAs(pageSize)
    predicates.offsetAs((page-1)*pageSize)
    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id",  "format_demo", "format_regex", "format_bac"]);

    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);

		let expresses:List<Format> = new List();
    while (resultSet.goToNextRow()) {
      const id = resultSet.getLong(resultSet.getColumnIndex("id"));
      const format_demo = resultSet.getString(resultSet.getColumnIndex("format_demo"));
      const format_regex = resultSet.getString(resultSet.getColumnIndex("format_regex"));
      const format_bac = resultSet.getString(resultSet.getColumnIndex("format_bac"));
      expresses.add(
        new Format(id, format_demo, format_regex, format_bac)
      )
    }
    return expresses
	}

  static load_all_formats(store:relationalStore.RdbStore):List<string>{
    let predicates = new relationalStore.RdbPredicates("format");

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      [ "format_regex"]);

    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);

    let expresses:List<string> = new List();
    while (resultSet.goToNextRow()) {
      const format_regex = resultSet.getString(resultSet.getColumnIndex("format_regex"));
      expresses.add(
        format_regex
      )
    }
    return expresses
  }

  static insert_formats(
    store:relationalStore.RdbStore,
    format:Format
  ) : number {
    const valueBucket3: relationalStore.ValuesBucket = {
      "format_demo" : format.format_demo,
      "format_regex" : format.format_regex,
      "format_bac" : format.format_bac
    };
    let predicates = new relationalStore.RdbPredicates("format");
    predicates.equalTo("format_regex",format.format_regex)

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id",  "format_regex"]);
    if (resultSet.rowCount > 0){
      return -1
    }


    if(store != undefined) {
      try {
        let rowId : number = (store as relationalStore.RdbStore).insertSync("format", valueBucket3, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
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
}