//
//  Skybox.swift
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

class Skybox: NSObject, Renderable
{
    private var cubemap: GLKTextureInfo!
    private var skyboxEffect = GLKSkyboxEffect()

    override init()
    {
        super.init()
        self.configureCubemap()
    }

    private func configureCubemap()
    {
        let fileNames = [
            NSBundle.mainBundle().pathForResource("posx", ofType: "jpg")!,
            NSBundle.mainBundle().pathForResource("negx", ofType: "jpg")!,
            NSBundle.mainBundle().pathForResource("posy", ofType: "jpg")!,
            NSBundle.mainBundle().pathForResource("negy", ofType: "jpg")!,
            NSBundle.mainBundle().pathForResource("posz", ofType: "jpg")!,
            NSBundle.mainBundle().pathForResource("negz", ofType: "jpg")!
        ]

        let options = [GLKTextureLoaderOriginBottomLeft : false]
        self.cubemap = try? GLKTextureLoader.cubeMapWithContentsOfFiles(fileNames, options: options)
        self.skyboxEffect.textureCubeMap.name = self.cubemap.name;
    }

    func render(camera: Camera)
    {
        self.skyboxEffect.transform.projectionMatrix = camera.projection
        self.skyboxEffect.transform.modelviewMatrix = GLKMatrix4Scale(camera.view, 50.0, 50.0, 50.0)
        self.skyboxEffect.prepareToDraw()
        self.skyboxEffect.draw()
    }
}
