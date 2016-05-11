//
//  HRVideoUtil.swift
//  HRSwiftUtil
//
//  Created by ZhangHeng on 16/5/11.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

import UIKit
import AVFoundation

enum cutVideoType {
    case top
    case middle
    case bottom
    case other
}

class HRVideoUtil: NSObject {

    internal typealias convertResult = (Bool,String) -> Void
    
    /**
     将视频截取为正方形
     
     - parameter videoPath:  输入视频路径
     - parameter outputPath: 输出路径
     - parameter cutType:    截取类型
     - parameter result:     截取转化以后的结果回调
     */
    static func cutVideoToSquareRect(videoPath:String,outputPath:String,cutType:cutVideoType,result:convertResult){
        let asset:AVAsset? = AVAsset.init(URL: NSURL.init(fileURLWithPath: videoPath))
        if asset == nil{
            print("read video with path" + videoPath + "failed")
            result(false,"input video file is not avaliable")
            return
        }
        
        let clipVideoTrack:AVAssetTrack? = asset?.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        let videoCompostion:AVMutableVideoComposition! = AVMutableVideoComposition.init()
        videoCompostion.frameDuration = CMTimeMake(1, 30)
        videoCompostion.renderSize = CGSizeMake((clipVideoTrack?.naturalSize.height)!, (clipVideoTrack?.naturalSize.height)!)
        
        let instruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction.init()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        let transformer:AVMutableVideoCompositionLayerInstruction? = AVMutableVideoCompositionLayerInstruction.init(assetTrack: clipVideoTrack!)
        
        var t1:CGAffineTransform!
        switch cutType {
        case .top:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack!.naturalSize.height, 0 )
        case .middle:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack!.naturalSize.height, -(clipVideoTrack!.naturalSize.width - clipVideoTrack!.naturalSize.height)/2)
        case .bottom:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack!.naturalSize.height, (clipVideoTrack!.naturalSize.width - clipVideoTrack!.naturalSize.height)/2)
        default:
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack!.naturalSize.height, -(clipVideoTrack!.naturalSize.width - clipVideoTrack!.naturalSize.height)/2)
        }
        
        let t2:CGAffineTransform = CGAffineTransformRotate(t1,CGFloat(M_PI_2))
        
        let finalTransform = t2
        transformer?.setTransform(finalTransform, atTime: kCMTimeZero)
        instruction.layerInstructions = [transformer!]
        videoCompostion.instructions = [instruction]
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(NSURL.init(fileURLWithPath: outputPath))
        } catch {
            print(error)
        }
        
        let exporter:AVAssetExportSession! = AVAssetExportSession.init(asset: asset!, presetName: AVAssetExportPresetHighestQuality)
        exporter.videoComposition = videoCompostion
        exporter.outputURL = NSURL.init(fileURLWithPath: outputPath)
        exporter.outputFileType = AVFileTypeMPEG4
        
        exporter.exportAsynchronouslyWithCompletionHandler { 
            dispatch_async(dispatch_get_main_queue()){
                print("exported success")
                result(true,"exported success")
            }
        }
    }
}
