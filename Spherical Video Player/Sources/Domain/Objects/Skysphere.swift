//
//  Skysphere.swift
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
import CoreGraphics
import QuartzCore

class Skysphere: NSObject, Renderable
{
    fileprivate let radius: Float
    fileprivate let rows: Int
    fileprivate let columns: Int

    init(radius: Float, rows: Int = 20, columns: Int = 20)
    {
        self.radius = radius
        self.rows = max(2, rows)
        self.columns = max(3, columns)
        super.init()

        self.prepareEffect()
        self.load()
    }

    deinit
    {
        self.unload()
    }

    fileprivate let effect = GLKBaseEffect()
    fileprivate var vertices = [TextureVertex]()
    fileprivate var indices = [UInt32]()
    fileprivate var vertexArray: GLuint = 0
    fileprivate var vertexBuffer: GLuint = 0
    fileprivate var indexBuffer: GLuint = 0
    fileprivate var texture: GLuint = 0

    fileprivate func prepareEffect()
    {
        self.effect.colorMaterialEnabled = GLboolean(GL_TRUE)
        self.effect.useConstantColor = GLboolean(GL_FALSE)
    }

    fileprivate func load()
    {
        self.unload()

        // Generate vertices and indices
        self.generateVertices()
        self.generateIndicesForTriangleStrip()
        
        // Create OpenGL's buffers
        glGenVertexArraysOES(1, &self.vertexArray)
        glBindVertexArrayOES(self.vertexArray)

        glGenBuffers(1, &self.vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<TextureVertex>.size * self.vertices.count, self.vertices, GLenum(GL_STATIC_DRAW))

        glGenBuffers(1, &self.indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<UInt32>.size * self.indices.count, self.indices, GLenum(GL_STATIC_DRAW))


        // Describe vertex format to OpenGL
        let sizeOfVertex = GLsizei(MemoryLayout<TextureVertex>.size)
        let texOffset = 3 * MemoryLayout<GLfloat>.size
        let texPtr = UnsafeRawPointer(bitPattern: texOffset)

        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), GLint(3), GLenum(GL_FLOAT), GLboolean(GL_FALSE), sizeOfVertex, nil)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), GLint(2), GLenum(GL_FLOAT), GLboolean(GL_FALSE), sizeOfVertex, texPtr)

        glBindVertexArrayOES(0)
    }

    fileprivate func unload()
    {
        self.vertices.removeAll()
        self.indices.removeAll()

        glDeleteBuffers(1, &self.vertexBuffer)
        glDeleteBuffers(1, &self.indexBuffer)
        glDeleteVertexArraysOES(1, &self.vertexArray)
        glDeleteTextures(1, &self.texture)
    }

    fileprivate func generateVertices()
    {
        let deltaAlpha = Float(2.0 * M_PI) / Float(self.columns)
        let deltaBeta = Float(M_PI) / Float(self.rows)
        for row in 0...self.rows
        {
            let beta = Float(row) * deltaBeta
            let y = self.radius * cosf(beta)
            let tv = Float(row) / Float(self.rows)
            for col in 0...self.columns
            {
                let alpha = Float(col) * deltaAlpha
                let x = self.radius * sinf(beta) * cosf(alpha)
                let z = self.radius * sinf(beta) * sinf(alpha)

                let position = GLKVector3(v: (x, y, z))
                let tu = Float(col) / Float(self.columns)

                let vertex = TextureVertex(position: position.v, texture: (tu, tv))
                self.vertices.append(vertex)
            }
        }
    }

    fileprivate func generateIndicesForTriangleStrip()
    {
        for row in 1...self.rows
        {
            let topRow = row - 1
            let topIndex = (self.columns + 1) * topRow
            let bottomIndex = topIndex + (self.columns + 1)
            for col in 0...self.columns
            {
                self.indices.append(UInt32(topIndex + col))
                self.indices.append(UInt32(bottomIndex + col))
            }

            self.indices.append(UInt32(topIndex))
            self.indices.append(UInt32(bottomIndex))
        }
    }

    // MARK: - Texture
    func loadTexture(_ image: UIImage?)
    {
        guard let cgImage = image?.cgImage else
        {
            return
        }

        let width = cgImage.width
        let height = cgImage.height
        let ptrCapacity = Int(width * height * 4)
        let ptr = UnsafeMutablePointer<GLubyte>.allocate(capacity: ptrCapacity)
        let imageData = ptr

        let imageColorSpace = cgImage.colorSpace!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let gc = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: imageColorSpace, bitmapInfo: bitmapInfo.rawValue)
        {
            gc.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

            self.updateTexture(CGSize(width: width, height: height), imageData: imageData)
        }
        ptr.deinitialize()
        ptr.deallocate(capacity: ptrCapacity)
    }

    func updateTexture(_ size: CGSize, imageData: UnsafeMutableRawPointer)
    {
        if self.texture == 0
        {
            glGenTextures(1, &self.texture)
            glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)

            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_REPEAT))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_REPEAT))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
        }

        glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(size.width), GLsizei(size.height), 0, GLenum(GL_BGRA), GLenum(GL_UNSIGNED_BYTE), imageData)
    }

    // MARK: - Renderable
    func render(_ camera: Camera)
    {
        guard self.texture != 0 else
        {
            return
        }

        glBindVertexArrayOES(self.vertexArray)

        self.effect.transform.projectionMatrix = camera.projection
        self.effect.transform.modelviewMatrix = camera.view
        self.effect.texture2d0.enabled = GLboolean(GL_TRUE)
        self.effect.texture2d0.name = self.texture
        self.effect.prepareToDraw()

        glDrawElements(GLenum(GL_TRIANGLE_STRIP), GLsizei(self.indices.count - 2), GLenum(GL_UNSIGNED_INT), nil)

        glBindVertexArrayOES(0)
    }
}
