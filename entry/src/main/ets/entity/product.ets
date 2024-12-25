import { relationalStore } from "@kit.ArkData"
import { List } from "@kit.ArkTS"

@Observed
export class Product {
  id: number
  name: string
  price: number 
  purchaseTime: number
  property: string
  chengben: number

  constructor(id: number, name: string, price: number,
   purchaseTime: number, property: string,chengben:number) {
    this.id = id
    this.name = name
    this.price = price
    this.purchaseTime = purchaseTime
    this.property = property
    this.chengben = chengben
  }

  static build_create_table_sql(store: relationalStore.RdbStore) {
    let createTableSql = `CREATE TABLE IF NOT EXISTS product ( `;
    createTableSql += `id INTEGER PRIMARY KEY AUTOINCREMENT, `;
    createTableSql += `name TEXT, `;
    createTableSql += `price REAL, `;
    createTableSql += `purchaseTime TimeStamp NOT NULL DEFAULT CURRENT_TIMESTAMP, `;
    createTableSql += `property TEXT, `;
    createTableSql += `chengben REAL NOT NULL DEFAULT 0)`;
    return store.executeSync(createTableSql)
  }

  static insert_product(store: relationalStore.RdbStore, product: Product): number {
    const valueBucket: relationalStore.ValuesBucket = {
      "name": product.name,
      "price": product.price,
      "purchaseTime": product.purchaseTime,
      "property": product.property,
      "chengben":product.chengben
    };

    if(store != undefined) {
      try {
        let rowId = store.insertSync("product", valueBucket, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
        return rowId
      } catch (error) {
        console.error(`Insert failed, code is ${error.code},message is ${error.message}`);
        return -1
      }
    }
    return -1
  }

  static update_price(store: relationalStore.RdbStore, id: number, price: number): boolean {
    if(store != undefined) {
      try {
        // 开启事务
        store.beginTransaction()
        
        // 更新产品价格
        let updateSql = `UPDATE product SET price = ${price} WHERE id = ${id}`
        store.executeSync(updateSql)
        
        // 提交事务
        store.commit()
        
        return true
      } catch (error) {
        // 发生错误时回滚
        store.rollBack()
        console.error(`Update price failed, code is ${error.code}, message is ${error.message}`)
        return false
      }
    }
    return false
  }

  static update_product(store: relationalStore.RdbStore, product: Product): boolean {
    if(store != undefined) {
      try {
        store.beginTransaction()
        
        const valueBucket: relationalStore.ValuesBucket = {
          "name": product.name,
          "price":product.price,
          "chengben": product.chengben,
          "purchaseTime": product.purchaseTime,
          "property": product.property
        } //测试产品
        
        let predicates = new relationalStore.RdbPredicates("product")
        predicates.equalTo("id", product.id)
        
        let rows = store.updateSync( valueBucket,predicates)
        
        store.commit()
        return rows > 0
      } catch (error) {
        store.rollBack()

        console.error(`Update product failed, code is ${error.code}, message is ${error.message}`)
        return false
      }
    }
    return false
  }
  static delete_by_id(store:relationalStore.RdbStore,id:number) : boolean{
    let predicates = new relationalStore.RdbPredicates("product");
    predicates.equalTo("id", id);
    console.info(`Delete rows: ${id}`);

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

} 