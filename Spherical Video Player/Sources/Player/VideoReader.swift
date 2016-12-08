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
    fileprivate let singleFrameInterval: TimeInterval = 0.02

    fileprivate let videoURL: URL!
    fileprivate var videoOutput: AVPlayerItemVideoOutput!
    fileprivate var player: AVPlayer!
    fileprivate var playerItem: AVPlayerItem!
    fileprivate var videoOutputQueue: DispatchQueue!

    init(url: URL)
    {
        self.videoURL = url
        super.init()
        self.configureVideoPlayback()
    }

    fileprivate override init()
    {
        self.videoURL = nil
        super.init()
    }

    deinit
    {
        self.playerItem.remove(self.videoOutput)
    }

    fileprivate func configureVideoPlayback()
    {
        let asset = AVURLAsset(url: self.videoURL, options: nil)
        let kTracksKey = "tracks"
        let requestedKeys = [kTracksKey]
        asset.loadValuesAsynchronously(forKeys: requestedKeys) { () -> Void in

            DispatchQueue.main.async(execute: { () -> Void in

                for key in requestedKeys
                {
                    var error: NSError?
                    let status = asset.statusOfValue(forKey: key, error: &error)
                    if status == AVKeyValueStatus.failed
                    {
                        print("Failed to load \(key). Reason: \(error?.localizedDescription)")
                    }
                }

                var error: NSError?
                let status = asset.statusOfValue(forKey: kTracksKey, error: &error)
                guard status == .loaded else
                {
                    print("Failed to load \(kTracksKey). Reason: \(error?.localizedDescription)")
                    return
                }

                let pixelBufferAttributes = [
                    kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32),
//                    kCVPixelBufferWidthKey as String : NSNumber(unsignedInt: 1024),
//                    kCVPixelBufferHeightKey as String : NSNumber(unsignedInt: 512),
                ]
                self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)

                self.playerItem = AVPlayerItem(asset: asset)
                self.playerItem.add(self.videoOutput)
                NotificationCenter.default.addObserver(self, selector: #selector(VideoReader.playerItemDidPlayToEndTime(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)

                self.player = AVPlayer(playerItem: self.playerItem)
                self.player.play()
            })
        }
    }

    func currentFrame(_ frameHandler: ((_ size: CGSize, _ frameData: UnsafeMutableRawPointer) -> (Void))?)
    {
        guard self.playerItem?.status == .readyToPlay else
        {
            return
        }

        let currentTime = self.playerItem.currentTime()
        guard let pixelBuffer = self.videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) else
        {
            print("empty pixel buffer")
            return
        }

        print("currentTime: \(currentTime.seconds)")

        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        frameHandler?(CGSize(width: width, height: height), baseAddress!)

        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
    }

    // MARK: - Notifications
    func playerItemDidPlayToEndTime(_ notification: Notification)
    {
        self.player.seek(to: kCMTimeZero)
        self.player.play()
    }
}
