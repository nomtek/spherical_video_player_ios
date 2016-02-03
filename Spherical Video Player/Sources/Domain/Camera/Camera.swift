//
//  Camera.swift
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

class Camera: NSObject
{
    private var projectionMatrix = GLKMatrix4()
    private var viewMatrix = GLKMatrix4()

    // MARK: - Projection matrix properties
    var fovRadians: Float = GLKMathDegreesToRadians(65.0)
    {
        didSet { self.updateProjectionMatrix() }
    }

    var aspect: Float = (320.0 / 480.0)
    {
        didSet { self.updateProjectionMatrix() }
    }

    var nearZ: Float = 0.1
    {
        didSet { self.updateProjectionMatrix() }
    }

    var farZ: Float = 100.0
    {
        didSet { self.updateProjectionMatrix() }
    }

    // MARK: - Matrix getters
    var projection: GLKMatrix4
    {
        get { return self.projectionMatrix }
    }

    var view: GLKMatrix4
    {
        get { return self.viewMatrix }
    }

    // MARK: - Init
    init(fovRadians: Float = GLKMathDegreesToRadians(65.0), aspect: Float = (320.0 / 480.0), nearZ: Float = 0.1, farZ: Float = 100)
    {
        super.init()
        self.fovRadians = fovRadians
        self.aspect = aspect
        self.nearZ = nearZ
        self.farZ = farZ
        self.updateProjectionMatrix()
        self.updateViewMatrix()
    }

    // MARK: - Updaters
    private func updateProjectionMatrix()
    {
        self.projectionMatrix = GLKMatrix4MakePerspective(self.fovRadians, self.aspect, self.nearZ, self.farZ)
    }

    private func updateViewMatrix()
    {
        // Look in the direction of z+ axis
        self.viewMatrix = GLKMatrix4MakeLookAt(0, 0, 0, 0, 0, 1, 0, 1, 0)
    }
}
