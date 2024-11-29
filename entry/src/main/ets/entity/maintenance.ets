import { relationalStore } from "@kit.ArkData"
import { List } from "@kit.ArkTS"
@Observed
export class Maintenance {
  id: number
  productId: number
  content: string
  price: number
  maintenanceTime: number
  
  constructor(id: number, productId: number, content: string, price: number, maintenanceTime: number) {
    this.id = id
    this.productId = productId
    this.content = content
    this.price = price
    this.maintenanceTime = maintenanceTime
  }

  static build_create_table_sql(store: relationalStore.RdbStore) {
    let createTableSql = `CREATE TABLE IF NOT EXISTS maintenance ( `;
    createTableSql += `id INTEGER PRIMARY KEY AUTOINCREMENT, `;
    createTableSql += `productId INTEGER, `;
    createTableSql += `content TEXT, `;
    createTableSql += `price REAL, `;
    createTableSql += `maintenanceTime TimeStamp NOT NULL DEFAULT CURRENT_TIMESTAMP, `;
    createTableSql += `FOREIGN KEY(productId) REFERENCES product(id))`;
    return store.executeSync(createTableSql)
  }

  static insert_maintenance(store: relationalStore.RdbStore, maintenance: Maintenance): number {
    const valueBucket: relationalStore.ValuesBucket = {
      "productId": maintenance.productId,
      "content": maintenance.content,
      "price": maintenance.price,
      "maintenanceTime": maintenance.maintenanceTime
    };

    if(store != undefined) {
      try {
        // 开启事务
        store.beginTransaction()
        
        // 插入维护记录
        let rowId = store.insertSync("maintenance", valueBucket, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
        
        // 更新产品总成本
        let updateSql = `UPDATE product SET price = price + ${maintenance.price} WHERE id = ${maintenance.productId}`
        store.executeSync(updateSql)
        
        // 提交事务
        store.commit()
        
        return rowId
      } catch (error) {
        // 发生错误时回滚
        store.rollBack()
        console.error(`Insert failed, code is ${error.code},message is ${error.message}`);
        return -1
      }
    }
    return -1
  }
} 