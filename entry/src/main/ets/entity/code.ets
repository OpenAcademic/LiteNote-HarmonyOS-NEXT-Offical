import { relationalStore } from "@kit.ArkData"
import { List } from "@kit.ArkTS"
import { systemDateTime } from "@kit.BasicServicesKit"
import { PublicUtils } from "../utils/pu"

export class CompareItem{
  public key : string| number
  public value: string | number
  constructor(key:string| number,value: string | number) {
    this.key = key
    this.value = value

  }
}

@Observed
export class Code {
  id : number
  code: string
  express: string
  port: string
  status:number = 0
  timestemp?:number = 0
  strDay?:string = ''


  constructor(id:number,code: string, express: string, 
  port: string,status:number,time?:number) {
    this.id = id
    this.code = code

    this.express = express
    this.port = port
    this.status = status
    this.timestemp = time

    this.strDay = PublicUtils.getDateTime(time as number,'yyyy-MM-dd')
  }

  static build_create_table_sql(store:relationalStore.RdbStore){
   let createTableSql = `CREATE TABLE IF NOT EXISTS code ( `;
  createTableSql += `id INTEGER PRIMARY KEY AUTOINCREMENT, `;
  createTableSql += `code TEXT, `;
  createTableSql += `express TEXT, `;
  createTableSql += `port TEXT, `;
  createTableSql += `status INTEGER NOT NULL DEFAULT 0, `;
  createTableSql += `chengben REAL NOT NULL DEFAULT 0, `;
  createTableSql += `timestemp TimeStamp NOT NULL DEFAULT CURRENT_TIMESTAMP, `;
  createTableSql += `strDay TEXT)`;
  return store.executeSync(createTableSql)
  }
  static update_by_id(store:relationalStore.RdbStore,name:string,orstatus:number) : boolean{
    let predicates = new relationalStore.RdbPredicates("code");
    predicates.equalTo("code", name);
    console.info(`Delete rows: ${name}`);
    const valueBucket3: relationalStore.ValuesBucket = {
      "status": orstatus==1?0:1
    }
    if(store != undefined) {
      try {
        let rows: number = store.updateSync(valueBucket3,predicates)
        console.info(`Delete rows: ${rows}`);
        return rows != 0

      } catch (err) {
        console.error(`Delete failed, code is ${err.code},message is ${err.message}`);
        return false
      }
    }
    return false

  }

  static update_by_code(store:relationalStore.RdbStore,orcode:string,code:Code) : boolean{
    console.log("uopdate",code.id.toString()+" "+code.code)
    let predicates = new relationalStore.RdbPredicates("code");
    predicates.equalTo("code", orcode);
    const valueBucket3: relationalStore.ValuesBucket = {
      "status": code.status,
      "express": code.express,
      "port": code.port,
      "code": code.code,
    }
    if(store != undefined) {
      try {
        let rows: number = store.updateSync(valueBucket3,predicates)
        console.info(`Delete rows: ${rows}`);
        return rows != 0

      } catch (err) {
        console.error(`Delete failed, code is ${err.code},message is ${err.message}`);
        return false
      }
    }
    return false

  }

  static delete_by_id(store:relationalStore.RdbStore,name:string) : boolean{
    let predicates = new relationalStore.RdbPredicates("code");
    predicates.equalTo("code", name);
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
  static load_yzs(store:relationalStore.RdbStore) : List<string> {
    // SELECT strDay as first, " +
    //             "COUNT(*) as second FROM item  GROUP BY  strDay
    let predicates = new relationalStore.RdbPredicates("code");
    predicates.groupBy(["port"])
    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id", "port"]);
    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);


    let strs:List<string> = new List();
    while (resultSet.goToNextRow()) {
      strs.add(resultSet.getString(resultSet.getColumnIndex("port")))
    }
    return strs
  }
  static load_graph(store:relationalStore.RdbStore) : List<string> {
    // SELECT strDay as first, " +
    //             "COUNT(*) as second FROM item  GROUP BY  strDay
    let predicates = new relationalStore.RdbPredicates("code");
    predicates.groupBy(["strDay"])
    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id", "strDay"]);
    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);


    let strs:List<string> = new List();
    while (resultSet.goToNextRow()) {
      strs.add(resultSet.getString(resultSet.getColumnIndex("strDay")))
    }
    return strs
  }

  static load_graph_by_str(store:relationalStore.RdbStore,str:string) : CompareItem[] {
    // SELECT strDay as first, " +
    //             "COUNT(*) as second FROM item  GROUP BY  strDay
    let predicates = new relationalStore.RdbPredicates("code");
    predicates.equalTo("strDay",str)
    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id", "code"]);
    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);


    let strs:List<CompareItem> = new List();
    while (resultSet.goToNextRow()) {
      strs.add(new CompareItem(resultSet.getLong(resultSet.getColumnIndex("id")),resultSet.getString(resultSet.getColumnIndex("code"))))
    }
    return strs.convertToArray()
  }

  static load_alls(store:relationalStore.RdbStore) : number[]{
    // SELECT strDay as first, " +
    //             "COUNT(*) as second FROM item  GROUP BY  strDay
    let predicates = new relationalStore.RdbPredicates("code");
    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id", "code"]);
    let all = resultSet.rowCount

    let predicates2 = new relationalStore.RdbPredicates("code");
    predicates2.equalTo("status",0)
    let resultSet2: relationalStore.ResultSet = store.querySync(predicates2,
      ["id", "code"]);
    let unqujian =  resultSet2.rowCount

    let predicates3 = new relationalStore.RdbPredicates("code");
    predicates3.equalTo("status",1)
    let resultSet3: relationalStore.ResultSet = store.querySync(predicates3,
      ["id", "code"]);
    let qujian =  resultSet3.rowCount


    return [all,unqujian,qujian]
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
  ) : List<Code>{
    let predicates = new relationalStore.RdbPredicates("code");
    for (let i = 0;i<options.length;i++){
      predicates.equalTo(options[i].key,options[i].value)
    }

    predicates.limitAs(pageSize)
    predicates.offsetAs((page-1)*pageSize)
    predicates.orderByDesc("timestemp")

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id", "code", "express", "port", "status","timestemp"]);


    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);
    console.info("dd",resultSet.rowIndex);
    console.info("dd",resultSet.rowCount);

		let codes:List<Code> = new List();

    while (resultSet.goToNextRow()) {
      const id = resultSet.getLong(resultSet.getColumnIndex("id"));
      const code = resultSet.getString(resultSet.getColumnIndex("code"));
      const express = resultSet.getString(resultSet.getColumnIndex("express"));
      const port = resultSet.getString(resultSet.getColumnIndex("port"));
      const status = resultSet.getLong(resultSet.getColumnIndex("status"));

      const timestemp  = resultSet.getLong(resultSet.getColumnIndex("timestemp"));
      let cop : Code = new Code(id, code, express, port, status,timestemp)
      codes.add(
        cop
      )
      console.info("ResultSet",cop);
      console.info("ResultSet",id+code+express, port, status);

    }

    return codes
	}

  static load_by_resultSet_for_card(store:relationalStore.RdbStore) : List<Code>{
    let predicates = new relationalStore.RdbPredicates("code");
    predicates.equalTo("status",0)

    predicates.limitAs(4)
    predicates.offsetAs(0)
    predicates.orderByDesc("timestemp")

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id", "code", "express", "port", "status","timestemp"]);


    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);
    console.info("dd",resultSet.rowIndex);
    console.info("dd",resultSet.rowCount);

    let codes:List<Code> = new List();

    while (resultSet.goToNextRow()) {
      const id = resultSet.getLong(resultSet.getColumnIndex("id"));
      const code = resultSet.getString(resultSet.getColumnIndex("code"));
      const express = resultSet.getString(resultSet.getColumnIndex("express"));
      const port = resultSet.getString(resultSet.getColumnIndex("port"));
      const status = resultSet.getLong(resultSet.getColumnIndex("status"));
      const timestemp  = resultSet.getLong(resultSet.getColumnIndex("timestemp"));
      let cop : Code = new Code(id, code, express, port, status,timestemp)
      codes.add(
        cop
      )
      console.info("ResultSet",cop);
      console.info("ResultSet",id+code+express, port, status);

    }

    return codes
  }
  static load_by_resultSet_yz(
    store:relationalStore.RdbStore,
    page:number,
    pageSize:number,
    port:string,
    status:number | null
  ) : List<Code>{
    let predicates = new relationalStore.RdbPredicates("code");
    console.info("dd",port);

    predicates.equalTo("port",port)
    if (status){
      predicates.equalTo("status",status)
      console.info("dd",status);

    }

    predicates.limitAs(pageSize)
    predicates.offsetAs((page-1)*pageSize)
    predicates.orderByDesc("timestemp")

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id", "code", "express", "port", "status","timestemp"]);


    console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.rowCount}`);
    console.info("dd",resultSet.rowIndex);
    console.info("dd",resultSet.rowCount);

    let codes:List<Code> = new List();

    while (resultSet.goToNextRow()) {
      const id = resultSet.getLong(resultSet.getColumnIndex("id"));
      const code = resultSet.getString(resultSet.getColumnIndex("code"));
      const express = resultSet.getString(resultSet.getColumnIndex("express"));
      const port = resultSet.getString(resultSet.getColumnIndex("port"));
      const status = resultSet.getLong(resultSet.getColumnIndex("status"));
      const timestemp  = resultSet.getLong(resultSet.getColumnIndex("timestemp"));
      let cop : Code = new Code(id, code, express, port, status,timestemp)
      codes.add(
        cop
      )
      console.info("ResultSet",cop);
      console.info("ResultSet",id+code+express, port, status);

    }

    return codes
  }



  static insert_code(
    store:relationalStore.RdbStore,
    code:Code
  ) : number {
    /*
      this.code = code
    this.express = express
    this.port = port
    this.status = status
     */
    let ctime = systemDateTime.getTime()
    const valueBucket3: relationalStore.ValuesBucket = {
      "code" : code.code,
      "express" : code.express,
      "port" : code.port,
      "status":0,
      "timestemp" :  ctime,
      "strDay": PublicUtils.getDateTime(ctime as number,'yyyy-MM-dd')
    };
    let predicates = new relationalStore.RdbPredicates("code");
    predicates.equalTo("code",code.code)
    predicates.equalTo("express",code.express)
    predicates.equalTo("port",code.port)

    let resultSet: relationalStore.ResultSet = store.querySync(predicates,
      ["id",  "code"]);
    console.log("insert",resultSet.rowCount);
    if (resultSet.rowCount > 0){
      return -1
    }


    if(store != undefined) {
      try {
        let rowId : number = (store as relationalStore.RdbStore).insertSync("code", valueBucket3, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
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