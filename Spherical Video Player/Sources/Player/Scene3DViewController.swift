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
    @IBOutlet private weak var scene3DView: Scene3DView!
    private var context: EAGLContext!

    deinit
    {
        if EAGLContext.currentContext() == self.context
        {
            EAGLContext.setCurrentContext(nil)
        }
    }

    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureContext()
        self.configureView()
    }

    // This is one of update variants used by GLKViewController.
    // See comment to GLKViewControllerDelegate.glkViewControllerUpdate for more info.
    func update()
    {
    }

    // MARK: - Configuration
    private func configureContext()
    {
        self.context = EAGLContext(API: EAGLRenderingAPI.OpenGLES3)
        EAGLContext.setCurrentContext(self.context)
    }

    private func configureView()
    {
        self.scene3DView.context = self.context

        let skybox = Skybox()
        self.scene3DView.addSceneObject(skybox)

        // Pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: "panGestureAction:")
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panGesture)
    }

    // MARK: - Event handlers
    func panGestureAction(sender: UIPanGestureRecognizer)
    {
        if (sender.state == .Changed)
        {
            let translation = sender.velocityInView(sender.view)
            let camera = self.scene3DView.camera
            let dh = Float(translation.x / self.view.frame.size.width) * camera.fovRadians
            let dv = Float(translation.y / self.view.frame.size.height) * camera.fovRadians
            let dt = Float(self.timeSinceLastUpdate)

            camera.yaw += dh * dt
            camera.pitch += dv * dt
        }
    }
}

