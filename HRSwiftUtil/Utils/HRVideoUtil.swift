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

    internal typealias convertResult = (Bool,String,String) -> Void
    
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
            result(false,"input video file is not avaliable","no file output")
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
                result(true,"exported success",outputPath)
            }
        }
    }
    
    /**
     向视频中加入声音
     
     - parameter videoPath: 视频路径
     - parameter audioPath: 声音路径
     - parameter result:    完成回调
     */
    static func mixAudioToVideo(videoPath:String,audioPath:String,result:convertResult){
        let mixComposition:AVMutableComposition = AVMutableComposition.init()
        let audioInputUrl:NSURL! = NSURL.init(fileURLWithPath: audioPath)
        let videoInputUrl:NSURL! = NSURL.init(fileURLWithPath: videoPath)
        
        let docPath:String = NSHomeDirectory().stringByAppendingString("/Documents")
        let outPutFilePath:String! = docPath.stringByAppendingString("/mixed"+videoPath.componentsSeparatedByString("/").last!)
        let outPutFileUrl:NSURL = NSURL.init(fileURLWithPath: outPutFilePath)
        
        if (NSFileManager.defaultManager().fileExistsAtPath(videoPath) == false){
            result(false,"video not exist","")
            return
        }
        if (NSFileManager.defaultManager().fileExistsAtPath(audioPath) == false){
            result(false,"audio not exist","")
            return
        }
        if (NSFileManager.defaultManager().fileExistsAtPath(outPutFilePath) == true){
            do {
                try NSFileManager.defaultManager().removeItemAtPath(outPutFilePath)
            } catch {
                print(error)
            }
        }
        
        let audioAsset:AVURLAsset = AVURLAsset.init(URL: audioInputUrl)
        let audioTimeRange:CMTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        let b_compositionAudioTrack:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try b_compositionAudioTrack.insertTimeRange(audioTimeRange, ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: kCMTimeZero)
        } catch {
            print(error)
        }
        
        let videoAsset:AVURLAsset = AVURLAsset.init(URL: videoInputUrl)
        let videoTimeRange:CMTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let compositionVideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        if (videoAsset.tracksWithMediaType(AVMediaTypeVideo).count != 0){
            do {
                try compositionVideoTrack.insertTimeRange(videoTimeRange, ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: kCMTimeZero)
            } catch {
                print(error)
            }
        }
        
        let assetExport:AVAssetExportSession = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileTypeMPEG4
        assetExport.outputURL = outPutFileUrl
        
        assetExport.exportAsynchronouslyWithCompletionHandler {
            let status = assetExport.status
            switch status{
            case AVAssetExportSessionStatus.Failed:
                result(false,"","")
            case AVAssetExportSessionStatus.Exporting:
                print("exporting...")
            case AVAssetExportSessionStatus.Completed:
                result(true,"",outPutFilePath)
            default:
                result(false,"","")
            }
        }
    }
}
