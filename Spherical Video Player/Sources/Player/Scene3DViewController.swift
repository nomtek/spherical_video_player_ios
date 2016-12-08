//
//  Scene3DViewController.swift
//  Spherical Video Player
//
//  Created by Pawel Leszkiewicz on 18.01.2016.
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


import GLKit

class Scene3DViewController: GLKViewController
{
    @IBOutlet fileprivate weak var scene3DView: Scene3DView!
    fileprivate var context: EAGLContext!
    fileprivate var skysphere: Skysphere!
    fileprivate var videoReader: VideoReader!

    deinit
    {
        if EAGLContext.current() == self.context
        {
            EAGLContext.setCurrent(nil)
        }
    }

    override var prefersStatusBarHidden : Bool
    {
        return true
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureContext()
        self.configureView()
        self.configureVideoReader()
    }

    // This is one of update variants used by GLKViewController.
    // See comment to GLKViewControllerDelegate.glkViewControllerUpdate for more info.
    func update()
    {
        self.videoReader?.currentFrame(
        {
            [weak self] (size, frameData) -> (Void) in
            self?.skysphere.updateTexture(size, imageData: frameData)
        })
    }

    // MARK: - Configuration
    fileprivate func configureContext()
    {
        self.context = EAGLContext(api: EAGLRenderingAPI.openGLES3)
        EAGLContext.setCurrent(self.context)
    }

    fileprivate func configureView()
    {
        self.scene3DView.context = self.context

        self.skysphere = Skysphere(radius: 60)
        self.scene3DView.addSceneObject(self.skysphere)

        // Pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Scene3DViewController.panGestureAction(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panGesture)
    }

    fileprivate func configureVideoReader()
    {
        if let url = Bundle.main.url(forResource: "videoplayback", withExtension: "mp4")
        {
            self.videoReader = VideoReader(url: url)
        }
    }

    // MARK: - Event handlers
    func panGestureAction(_ sender: UIPanGestureRecognizer)
    {
        if (sender.state == .changed)
        {
            let dt = CGFloat(self.timeSinceLastUpdate)
            let velocity = sender.velocity(in: sender.view)
            let translation = CGPoint(x: velocity.x * dt, y: velocity.y * dt)

            let camera = self.scene3DView.camera
            let scale = Float(UIScreen.main.scale)
            let dh = Float(translation.x / self.view.frame.size.width) * camera.fovRadians * scale
            let dv = Float(translation.y / self.view.frame.size.height) * camera.fovRadians * scale
            camera.yaw += dh
            camera.pitch += dv
        }
    }
}

