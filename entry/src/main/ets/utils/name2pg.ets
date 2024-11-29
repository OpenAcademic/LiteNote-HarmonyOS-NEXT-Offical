import { when } from "@ohos/hypium";

export function name2png(name:string){
  if (name == "顺丰"){
    return $r('app.media.sf')
  }
  else if (name == "申通"){
    return $r('app.media.sto')
  }
  else if (name == "中通"){
    return $r('app.media.zto')
  }
  else if (name == "圆通"){
    return $r('app.media.yto')
  }
  else if (name == "韵达"){
    return $r('app.media.yd')
  }
  else if (name == "京东"){
    return $r('app.media.jd')
  }
  else if (name == "极兔"){
    return $r('app.media.yd')
  }
  else if (name == "邮政"){
    return $r('app.media.yz')
  }
  else if (name == "德邦"){
    return $r('app.media.db')
  }
  else if (name == "百世"){
    return $r('app.media.bs')
  }
  else if (name == "韵达"){
    return $r('app.media.yd')
  }
  else{
    return $r('app.media.def')
  }
}