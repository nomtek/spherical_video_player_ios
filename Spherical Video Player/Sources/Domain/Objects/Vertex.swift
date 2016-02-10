//
//  Vertex.swift
//  Spherical Video Player
//
//  Created by Pawel Leszkiewicz on 19.01.2016.
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

typealias VertexPositionComponent = (GLfloat, GLfloat, GLfloat)
typealias VertexTextureCoordinateComponent = (GLfloat, GLfloat)

struct TextureVertex
{
    var position: VertexPositionComponent = (0, 0, 0)
    var texture: VertexTextureCoordinateComponent = (0, 0)
}
