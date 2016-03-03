//
//  VideoReader.swift
//  Spherical Video Player
//
//  Created by Pawel Leszkiewicz on 20.01.2016.
//  Copyright © 2016 Nomtek. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.


import AVFoundation

class VideoReader: NSObject
{
    private let singleFrameInterval: NSTimeInterval = 0.02

    private let videoURL: NSURL!
    private var videoOutput: AVPlayerItemVideoOutput!
    private var player: AVPlayer!
    private var playerItem: AVPlayerItem!
    private var videoOutputQueue: dispatch_queue_t!

    init(url: NSURL)
    {
        self.videoURL = url
        super.init()
        self.configureVideoPlayback()
    }

    private override init()
    {
        self.videoURL = nil
        super.init()
    }

    deinit
    {
        self.playerItem.removeOutput(self.videoOutput)
    }

    private func configureVideoPlayback()
    {
        let asset = AVURLAsset(URL: self.videoURL, options: nil)
        let kTracksKey = "tracks"
        let requestedKeys = [kTracksKey]
        asset.loadValuesAsynchronouslyForKeys(requestedKeys) { () -> Void in

            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                for key in requestedKeys
                {
                    var error: NSError?
                    let status = asset.statusOfValueForKey(key, error: &error)
                    if status == AVKeyValueStatus.Failed
                    {
                        print("Failed to load \(key). Reason: \(error?.localizedDescription)")
                    }
                }

                var error: NSError?
                let status = asset.statusOfValueForKey(kTracksKey, error: &error)
                guard status == .Loaded else
                {
                    print("Failed to load \(kTracksKey). Reason: \(error?.localizedDescription)")
                    return
                }

                let pixelBufferAttributes = [
                    kCVPixelBufferPixelFormatTypeKey as String : NSNumber(unsignedInt: kCVPixelFormatType_32BGRA),
//                    kCVPixelBufferWidthKey as String : NSNumber(unsignedInt: 1024),
//                    kCVPixelBufferHeightKey as String : NSNumber(unsignedInt: 512),
                ]
                self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)

                self.playerItem = AVPlayerItem(asset: asset)
                self.playerItem.addOutput(self.videoOutput)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)

                self.player = AVPlayer(playerItem: self.playerItem)
                self.player.play()
            })
        }
    }

    func currentFrame(frameHandler: ((size: CGSize, frameData: UnsafeMutablePointer<Void>) -> (Void))?)
    {
        guard self.playerItem?.status == .ReadyToPlay else
        {
            return
        }

        let currentTime = self.playerItem.currentTime()
        guard let pixelBuffer = self.videoOutput.copyPixelBufferForItemTime(currentTime, itemTimeForDisplay: nil) else
        {
            print("empty pixel buffer")
            return
        }

        print("currentTime: \(currentTime.seconds)")

        CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly)

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        frameHandler?(size: CGSize(width: width, height: height), frameData: baseAddress)

        CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly)
    }

    // MARK: - Notifications
    func playerItemDidPlayToEndTime(notification: NSNotification)
    {
        self.player.seekToTime(kCMTimeZero)
        self.player.play()
    }
}
