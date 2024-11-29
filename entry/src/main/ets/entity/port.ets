import { relationalStore } from "@kit.ArkData"
import { List } from "@kit.ArkTS"
import { CompareItem } from "./code"

@Observed
export class Port {
  id : number
  port: string
  port_local: string
  regex:string = ""

  constructor(id:number,port: string, port_local: string,  regex: string) {
    this.id = id
    this.port = port
    this.port_local = port_local
    this.regex = regex
  }



  static build_create_table_sql(store:relationalStore.RdbStore){
    let createTableSql = `CREATE TABLE IF NOT EXISTS port ( `;
    createTableSql += `id INTEGER   AUTO_INCREMENT  , `;
    createTableSql += `port TEXT  , `;
    createTableSql += `port_local TEXT , `;
    createTableSql += `regex TEXT , `;
    createTableSql += `PRIMARY KEY(id))`;
    return store.executeSync(createTableSql)
  }
  static load_all_by_name(store:relationalStore.RdbStore,port:string):string{
    let predicates = new relationalStore.RdbPredicates("port");
    predicates.equalTo("port",port)
    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      [ "port_local"]);

    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);

    while (resultSet.goToNextRow()) {
      const port_local = resultSet.getString(resultSet.getColumnIndex("port_local"));
      return port_local
    }
    return ""
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
  ) : List<Port>{
    let predicates = new relationalStore.RdbPredicates("port");
    for (let i = 0;i<options.length;i++){
      predicates.equalTo(options[i].key,options[i].value)
    }
    predicates.limitAs(pageSize)
    predicates.offsetAs((page-1)*pageSize)
    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id",  "port", "port_local", "regex"]);

    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);

		let expresses:List<Port> = new List();
    while (resultSet.goToNextRow()) {
      const id = resultSet.getLong(resultSet.getColumnIndex("id"));
      const express = resultSet.getString(resultSet.getColumnIndex("port"));
      const express_local = resultSet.getString(resultSet.getColumnIndex("port_local"));
      const regex = resultSet.getString(resultSet.getColumnIndex("regex"));
      expresses.add(
        new Port(id, express, express_local, regex)
      )
    }
    return expresses
	}



  static delete_by_id(store:relationalStore.RdbStore,id:string) : boolean{
    let predicates = new relationalStore.RdbPredicates("port");
    predicates.equalTo("port", id);
    console.info(`Delete rows: ${predicates}`);

    if(store != undefined) {
      try {
        let rows: Number = store.deleteSync(predicates)
        console.info(`Delete rows: ${rows}`);
        return rows != 0

      } catch (err) {
        console.error(`Delete failed, code is ${err.code},message is ${err.message}`);
        return false
      }
    }
    return false

  }

  static load_all_ports(store:relationalStore.RdbStore):List<string>{
    let predicates = new relationalStore.RdbPredicates("port");

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      [ "port"]);

    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);

    let expresses:List<string> = new List();
    while (resultSet.goToNextRow()) {
      const port = resultSet.getString(resultSet.getColumnIndex("port"));
      expresses.add(
        port
      )
    }
    return expresses
  }

  static insert_formats(
    store:relationalStore.RdbStore,
    port:Port
  ) : number {
    const valueBucket3: relationalStore.ValuesBucket = {
      "port" : port.port,
      "port_local" : port.port_local,
      "regex" : port.regex
    };
    let predicates = new relationalStore.RdbPredicates("port");
    predicates.equalTo("port",port.port)

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id",  "port"]);
    console.log("insert",resultSet.rowCount);

    if (resultSet.rowCount > 0){
      return -1
    }


    if(store != undefined) {
      try {
        let rowId : number = (store as relationalStore.RdbStore).insertSync("port", valueBucket3, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
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