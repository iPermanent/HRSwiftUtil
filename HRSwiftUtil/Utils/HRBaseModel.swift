//
//  HRBaseModel.swift
//  HRSwiftUtil
//
//  Created by ZhangHeng on 16/4/25.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

import UIKit

class HRBaseModel: NSObject ,NSCoding{
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        var count:UInt32 = 0
        let ivars = class_copyPropertyList(self.classForCoder, &count)
        for cnt:UInt32 in 0...count-1{
            let ivr = ivars[Int(cnt)]
            let name = ivar_getName(ivr)
            let key:String = String(name)
            self.setValue(aDecoder.valueForKeyPath(key), forKey: key)
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        var count:UInt32 = 0
        let ivars = class_copyPropertyList(self.classForCoder, &count)
        for cnt:UInt32 in 0...count-1{
            let ivr = ivars[Int(cnt)]
            let name = ivar_getName(ivr)
            let key:String = String(name)
            aCoder.encodeObject(self.valueForKeyPath(key), forKey: key)
        }
    }
    
    required init(dictionary:Dictionary<String,AnyObject>){
        super.init()
        for(key, value) in dictionary{
            if value.isKindOfClass(NSArray.classForCoder()){
                //if array type, set recycle
                self.configArrayValue(value as! Array<AnyObject>, name: key )
            }else if value.isKindOfClass(NSDictionary.classForCoder()){
                //if dictionary set object
                self.configDictionaryValue(value as! Dictionary<String, AnyObject>, name: key)
            }else{
                //else will be number or string, set directly
                self.setValue(value, forKeyPath: key )
            }
        }
    }
    
    private func configDictionaryValue(object:Dictionary<String,AnyObject>,name:String){
        let classType = NSClassFromString(name) as? HRBaseModel.Type
        if classType != nil {
            let model = classType!.init(dictionary:object)
            self.setValue(model, forKeyPath: name)
        }else{
            print(NSStringFromClass(self.classForCoder) + "class with property" + name + "undeclare,object")
        }
    }
    
    private func configArrayValue(object:Array<AnyObject>,name:String){
        let classType = NSClassFromString(name) as? HRBaseModel.Type
        if classType != nil {
            var objs:[AnyObject] = []
            for index in 0...object.count{
                if object[index] is Dictionary<String, AnyObject>{
                    let model = classType!.init(dictionary:object[index] as! Dictionary<String, AnyObject>)
                    objs.append(model)
                }else{
                    objs.append(object[index])
                }
            }
            self.setValue(objs, forKeyPath: name)
        }else{
            print(NSStringFromClass(self.classForCoder) + "class with property" + name + "undeclare,array")
        }
    }
}
