//
//  HRDevice.swift
//  HRSwiftUtil
//
//  Created by ZhangHeng on 16/5/10.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

import UIKit
import Foundation

enum HRDeviceType {
    case iPhone
    case iPhone3G
    case iphone3GS
    case iPhone4
    case iPhone4S
    case iPhone5
    case iPhone5C
    case iPhone5S
    case iPhone6
    case iPhone6Plus
    case iPhone6S
    case iPhone6SPlus
    case iPhoneSE
    case iPad
    case iPad2
    case iPad3
    case iPadMini
    case iPadMini2
    case iPadMini3
    case iPad4
    case iPadAir
    case iPadAir2
    case iPadPro
    case iPod
    case simulator
}

class HRDevice: NSObject {
    static func getDeviceType()->HRDeviceType{
        let name:String = HRDevice.getDeviceModel()
        print(name)
        
        switch name {
        case "iPhone1,1":
            return HRDeviceType.iPhone
        case "iPhone2,1":
            return HRDeviceType.iPhone3G
        case "iPhone2,1":
            return HRDeviceType.iphone3GS
        case "iPhone3,1","iPhone3,2","iPhone3,3":
            return HRDeviceType.iPhone4
        case "iPhone4,1":
            return HRDeviceType.iPhone4S
        case "iPhone5,1","iPhone5,2":
            return HRDeviceType.iPhone5
        case "iPhone5,3","iPhone5,4":
            return HRDeviceType.iPhone5C
        case "iPhone6,1","iPhone6,2":
            return HRDeviceType.iPhone5S
        case "iPhone7,2":
            return HRDeviceType.iPhone6
        case "iPhone7,1":
            return HRDeviceType.iPhone6Plus
        case "iPhone8,1":
            return HRDeviceType.iPhone6S
        case "iPhone8,2":
            return HRDeviceType.iPhone6SPlus
        case "iPhone8,4":
            return HRDeviceType.iPhoneSE
        case "iPad1,1":
            return HRDeviceType.iPad
        case "iPad2,1","iPad2,2","iPad2,3":
            return HRDeviceType.iPad2
        case "iPad3,1","iPad3,2","iPad3,3":
            return HRDeviceType.iPad3
        case "iPad3,4","iPad3,5","iPad3,6":
            return HRDeviceType.iPad4
        case "iPad2,5","iPad2,6","iPad2,7":
            return HRDeviceType.iPadMini
        case "iPad4,4","iPad4,5","iPad4,6":
            return HRDeviceType.iPadMini2
        case "iPad4,7","iPad4,8","iPad4,9":
            return HRDeviceType.iPadMini3
        case "iPad4,1","iPad4,2","iPad4,3":
            return HRDeviceType.iPadAir
        case "iPad5,1","iPad5,2","iPad5,3":
            return HRDeviceType.iPadAir2
        case "iPad6,1","iPad6,2","iPad6,3":
            return HRDeviceType.iPadPro
        case "x86_64":
            return HRDeviceType.simulator
        default:
            return HRDeviceType.iPod
        }
    }
    
    static func getDeviceModel()->String{
        var systemInfo = [UInt8](count: sizeof(utsname), repeatedValue: 0)
        let model = systemInfo.withUnsafeMutableBufferPointer { (inout body: UnsafeMutableBufferPointer<UInt8>) -> String? in
            if uname(UnsafeMutablePointer(body.baseAddress)) != 0 {
                return nil
            }
            return String.fromCString(UnsafePointer(body.baseAddress.advancedBy(Int(_SYS_NAMELEN * 4))))
        }
        
        return model!
    }
}
