import systemDateTime from '@ohos.systemDateTime'

/*公共方法类*/
export class PublicUtils {
  /**
   * 时间戳转时间
   * PublicUtils.getDateTime(systemDateTime.getTime(), 'yyyy-MM-dd HH:mm:ss')
   * @param time 时间戳(默认获取当前时间)
   * @param type 时间格式(默认'yyyy-MM-dd HH:mm')
   * @returns
   */
  static getDateTime(time: number | null, type: string | null): string {
    let date = new Date(systemDateTime.getTime())
    if (time) {
      date = new Date(time)
    }
    // 获取时间
    const year = date.getFullYear().toString()
    let month = (date.getMonth() + 1).toString()
    let day = date.getDate().toString()
    let hour = date.getHours().toString()
    let min = date.getMinutes().toString()
    let seconds = date.getSeconds().toString()
    // 补位
    month = month.length === 1 ? `0${month}` : month
    day = day.length === 1 ? `0${day}` : day
    hour = hour.length === 1 ? `0${hour}` : hour
    min = min.length === 1 ? `0${min}` : min
    seconds = seconds.length === 1 ? `0${seconds}` : seconds
    // 默认格式:年月日
    type = type ? type : 'yyyy-MM-dd'
    // 格式转换
    let timeStr = `${year}-${month}-${day}` // 默认 yyyy-mm-dd
    if (type === 'yyyy-MM-dd HH:mm:ss') {
      timeStr = `${year}-${month}-${day} ${hour}:${min}:${seconds}`
    } else if (type === 'yyyy-MM-dd HH:mm') {
      timeStr = `${year}-${month}-${day} ${hour}:${min}`
    } else if (type === 'yyyy-MM-dd') {
      timeStr = `${year}-${month}-${day}`
    } else if (type === 'yyyy-MM') {
      timeStr = `${year}-${month}`
    } else if (type === 'HH:mm:ss') {
      timeStr = `${hour}:${min}:${seconds}`
    } else if (type === 'HH:mm') {
      timeStr = `${hour}:${min}`
    } else {
      timeStr = `${year}-${month}-${day} ${hour}:${min}:${seconds}`

    }
    // callback
    return timeStr
  }
  static getDateTime2(time: number): string {
    let date = new Date(time)
    console.log(date.toJSON(),"")
    console.log("out cha",date.getTime()-time)

    // 获取时间
    const year = (date.getFullYear()).toString()
    let month = (date.getUTCMonth() + 1).toString()
    let day = (date.getUTCDate()).toString()

    // 补位
    month = month.length === 1 ? `0${month}` : month
    day = day.length === 1 ? `0${day}` : day

    // 格式转换
    let timeStr = `${year}-${month}-${day}` // 默认 yyyy-mm-dd

    // callback
    return timeStr
  }

}