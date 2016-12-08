//
//  Scene3DView.swift
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

class Scene3DView: GLKView
{
    fileprivate var sceneObjects = [NSObject]()

    // MARK: - Properties
    var camera = Camera()
    {
        didSet { self.setNeedsDisplay() }
    }

    // MARK: - Public interface
    func addSceneObject(_ object: NSObject)
    {
        if !self.sceneObjects.contains(object)
        {
            self.sceneObjects.append(object)
        }
    }

    func removeSceneObject(_ object: NSObject)
    {
        if let index = self.sceneObjects.index(of: object)
        {
            self.sceneObjects.remove(at: index)
        }
    }

    // MARK: - Overriden interface
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.camera.aspect = fabsf(Float(self.bounds.size.width / self.bounds.size.height))
    }

    override func display()
    {
        super.display()
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        let objects = self.sceneObjects
        for object in objects
        {
            if let renderable = object as? Renderable
            {
                renderable.render(self.camera)
            }
        }
    }
}
