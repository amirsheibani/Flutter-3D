import 'dart:typed_data';

import 'package:example_one/gl_object/canves_gl.dart';
import 'package:example_one/gl_object/object_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/openGL/opengl/OpenGLContextWeb.dart';
import 'package:vector_math/vector_math_64.dart' as mat4;
import 'dart:math' as math;
class PointDate{
  final double x;
  final double y;
  final double z;
  final Color color;

  PointDate(this.x, this.y, this.z, this.color);
}


class DrawObject{
  late OpenGLContextWeb gl;
  double pw;
  double ph;
  //WebGLProgram
  // dynamic _glProgram;
  // //WebGLBuffer
  // dynamic _vertexBuffer;
  // //WebGLBuffer
  // dynamic _colorBuffer;

  final CanvasGL canvasGL;


  DrawObject(this.canvasGL,this.pw,this.ph,{String? vertexCode,String? fragmentCode}){
    try{
      gl = canvasGL.flutterGlPlugin.gl;
      // gl.clearColor(0.8, 0.8, 0.8, 1.0);
      // gl.enable(gl.DEPTH_TEST);
      // gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
      // drawLine();
    }catch (e){
      print(e);
    }
  }

  drawPoint(PointDate pointDate,{Color color = Colors.white}){
    final List<double> _vertex = [];
    final List<double> _colorVertex = [];

    //WebGLShader
    dynamic vertexShader = _makeShader(gl,'''
                    attribute vec3 coordinates;
                    attribute vec3 colors;
                    varying vec4 vColor;
                    void main(void) {
                        gl_Position = vec4(coordinates, 1.0);
                        vColor = vec4(colors, 1.0);
                        gl_PointSize = 5.0;
                    }
                ''', gl.VERTEX_SHADER);
    //WebGLShader
    dynamic fragmentShader = _makeShader(gl,'''
                    precision mediump float;
                    varying vec4 vColor;
                    void main(void) {
                        gl_FragColor = vColor;
                    }
                ''', gl.FRAGMENT_SHADER);
    dynamic _glProgram = gl.createProgram();
    gl.attachShader(_glProgram, vertexShader);
    gl.attachShader(_glProgram, fragmentShader);
    gl.linkProgram(_glProgram);
    var _res = gl.getProgramParameter(_glProgram, gl.LINK_STATUS);
    if (_res == false || _res == 0) {
      throw Exception('Unable to initialize the shader program');
    }
    gl.useProgram(_glProgram);
    dynamic _vertexBuffer = gl.createBuffer();
    if (_vertexBuffer == null) {
      throw Exception('Failed to create the vertexBuffer object');
    }
    dynamic _colorBuffer = gl.createBuffer();
    if (_colorBuffer == null) {
      throw Exception('Failed to create the colorBuffer object');
    }

    double xd = ((pointDate.x - pw) - (canvasGL.flutterGlPlugin.width / 2)) / (canvasGL.flutterGlPlugin.width / 2);
    double yd = ((canvasGL.flutterGlPlugin.height / 2) - (pointDate.y - ph)) / (canvasGL.flutterGlPlugin.height / 2);
    _vertex.add(xd);
    _vertex.add(yd);
    _vertex.add(0.0);
    _colorVertex.add(pointDate.color.red/255);
    _colorVertex.add(pointDate.color.green/255);
    _colorVertex.add(pointDate.color.blue/255);
    _colorVertex.add(pointDate.color.alpha/255);

    var coordinates = gl.getAttribLocation(_glProgram, 'coordinates');
    if (coordinates < 0) {
      throw('Failed to get the storage location of coordinates');
    }
    var colors = gl.getAttribLocation(_glProgram,'colors');
    if (colors < 0) {
      throw('Failed to get the storage location of color');
    }

    var colorsVertices = Float32List.fromList(_colorVertex);
    var vertices = Float32List.fromList(_vertex);
    gl.bindBuffer(gl.ARRAY_BUFFER, _colorBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, colorsVertices.length,colorsVertices, gl.STATIC_DRAW);

    gl.vertexAttribPointer(colors, 3, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);
    gl.enableVertexAttribArray(colors);

    gl.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, vertices.length, vertices, gl.STATIC_DRAW);

    gl.vertexAttribPointer(coordinates, 3, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);
    gl.enableVertexAttribArray(coordinates);

    gl.drawArrays(gl.POINTS, 0, 1);
  }

  drawLine(List<Offset> points,{Color color = Colors.redAccent,bool closePath = false}){
    if(points.length == 1){
      PointDate pointDate = PointDate(points.first.dx,points.first.dy,0.0,color);
      drawPoint(pointDate);
      return;
    }
    //WebGLShader
    dynamic vertexShader = _makeShader(gl,'''
                    attribute vec3 coordinates;
                    attribute vec3 colors;
                    varying vec4 vColor;
                    void main(void) {
                        gl_Position = vec4(coordinates, 1.0);
                        vColor = vec4(colors, 1.0);
                        gl_PointSize = 5.0;
                    }
                ''', gl.VERTEX_SHADER);
    //WebGLShader
    dynamic fragmentShader = _makeShader(gl,'''
                    precision mediump float;
                    varying vec4 vColor;
                    void main(void) {
                        gl_FragColor = vColor;
                    }
                ''', gl.FRAGMENT_SHADER);
    dynamic _glProgram = gl.createProgram();
    gl.attachShader(_glProgram, vertexShader);
    gl.attachShader(_glProgram, fragmentShader);
    gl.linkProgram(_glProgram);
    var _res = gl.getProgramParameter(_glProgram, gl.LINK_STATUS);
    if (_res == false || _res == 0) {
      throw Exception('Unable to initialize the shader program');
    }
    gl.useProgram(_glProgram);
    dynamic _vertexBuffer = gl.createBuffer();
    if (_vertexBuffer == null) {
      throw Exception('Failed to create the vertexBuffer object');
    }
    dynamic _colorBuffer = gl.createBuffer();
    if (_colorBuffer == null) {
      throw Exception('Failed to create the colorBuffer object');
    }
    List<double> _vertex = [];
    List<double> _colorVertex = [];
    for(Offset item in points){
      double xd = ((item.dx - pw) - (canvasGL.flutterGlPlugin.width / 2)) / (canvasGL.flutterGlPlugin.width / 2);
      double yd = ((canvasGL.flutterGlPlugin.height / 2) - (item.dy - ph)) / (canvasGL.flutterGlPlugin.height / 2);
      _vertex.add(xd);
      _vertex.add(yd);
      _vertex.add(0.0);
      _colorVertex.add(color.red / 255);
      _colorVertex.add(color.green / 255);
      _colorVertex.add(color.blue / 255);
    }
    var coordinates = gl.getAttribLocation(_glProgram, 'coordinates');
    if (coordinates < 0) {
      throw('Failed to get the storage location of coordinates');
    }
    var colors = gl.getAttribLocation(_glProgram,'colors');
    if (colors < 0) {
      throw('Failed to get the storage location of color');
    }

    var colorsVertices = Float32List.fromList(_colorVertex);
    gl.bindBuffer(gl.ARRAY_BUFFER, _colorBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, colorsVertices.length, colorsVertices, gl.STATIC_DRAW);
    gl.vertexAttribPointer(colors, 3, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);
    gl.enableVertexAttribArray(colors);

    var vertices = Float32List.fromList(_vertex);

    gl.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, vertices.length, vertices, gl.STATIC_DRAW);
    gl.vertexAttribPointer(coordinates, 3, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);
    gl.enableVertexAttribArray(coordinates);

    if(closePath){
      gl.drawArrays(gl.LINE_LOOP, 0, _vertex.length/3);
    }else{
      gl.drawArrays(gl.LINE_STRIP, 0, _vertex.length/3);
    }

  }

  drawShape({double degreeX = 0,double degreeY = 0,double degreeZ = 0}){
    //WebGLShader
    dynamic vertexShader = _makeShader(gl,'''
                    attribute vec3 coordinates;
                    attribute vec3 colors;
                    varying vec4 vColor;
                    uniform mat4 matrix;
                    void main(void) {
                        gl_Position = matrix * vec4(coordinates, 1.0);
                        vColor = vec4(colors, 1.0);
                    }
                ''', gl.VERTEX_SHADER);
    //WebGLShader
    dynamic fragmentShader = _makeShader(gl,'''
                    precision mediump float;
                    varying vec4 vColor;
                    void main(void) {
                        gl_FragColor = vColor;
                    }
                ''', gl.FRAGMENT_SHADER);
    dynamic _glProgram = gl.createProgram();
    gl.attachShader(_glProgram, vertexShader);
    gl.attachShader(_glProgram, fragmentShader);
    gl.linkProgram(_glProgram);
    var _res = gl.getProgramParameter(_glProgram, gl.LINK_STATUS);
    if (_res == false || _res == 0) {
      throw Exception('Unable to initialize the shader program');
    }
    gl.useProgram(_glProgram);
    gl.enable(gl.DEPTH_TEST);
    dynamic _vertexBuffer = gl.createBuffer();
    if (_vertexBuffer == null) {
      throw Exception('Failed to create the vertexBuffer object');
    }
    dynamic _colorBuffer = gl.createBuffer();
    if (_colorBuffer == null) {
      throw Exception('Failed to create the colorBuffer object');
    }
    // List<double> _vertex = [
    //   0.0,0.5,0.0,
    //   0.5,-0.5,0.0,
    //   -0.5,-0.5,0.0
    // ];
    // List<double> _colorVertex = [
    //   1,0,0,
    //   0,1,0,
    //   0,0,1
    // ];

    List<double> _vertexCube = [
      // Front
      0.5, 0.5, 0.5,
      0.5, -.5, 0.5,
      -.5, 0.5, 0.5,
      -.5, 0.5, 0.5,
      0.5, -.5, 0.5,
      -.5, -.5, 0.5,

      // Left
      -.5, 0.5, 0.5,
      -.5, -.5, 0.5,
      -.5, 0.5, -.5,
      -.5, 0.5, -.5,
      -.5, -.5, 0.5,
      -.5, -.5, -.5,

      // Back
      -.5, 0.5, -.5,
      -.5, -.5, -.5,
      0.5, 0.5, -.5,
      0.5, 0.5, -.5,
      -.5, -.5, -.5,
      0.5, -.5, -.5,

      // Right
      0.5, 0.5, -.5,
      0.5, -.5, -.5,
      0.5, 0.5, 0.5,
      0.5, 0.5, 0.5,
      0.5, -.5, 0.5,
      0.5, -.5, -.5,

      // Top
      0.5, 0.5, 0.5,
      0.5, 0.5, -.5,
      -.5, 0.5, 0.5,
      -.5, 0.5, 0.5,
      0.5, 0.5, -.5,
      -.5, 0.5, -.5,

      // Bottom
      0.5, -.5, 0.5,
      0.5, -.5, -.5,
      -.5, -.5, 0.5,
      -.5, -.5, 0.5,
      0.5, -.5, -.5,
      -.5, -.5, -.5,
    ];

    List<double> _colorVertex = [];
    for (var face = 0; face < 6; face++) {
      var faceColor = randomColor(face);
      for (var vertex = 0; vertex < 6; vertex++) {
        _colorVertex.add(faceColor[0]);
        _colorVertex.add(faceColor[1]);
        _colorVertex.add(faceColor[2]);
      }
    }

    var coordinates = gl.getAttribLocation(_glProgram, 'coordinates');
    if (coordinates < 0) {
      throw('Failed to get the storage location of coordinates');
    }
    // var vertices = Float32List.fromList(_vertex);
    // gl.enableVertexAttribArray(coordinates);
    // gl.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    // gl.bufferData(gl.ARRAY_BUFFER, vertices.length, vertices, gl.STATIC_DRAW);
    // gl.vertexAttribPointer(coordinates, 3, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);

    var colors = gl.getAttribLocation(_glProgram,'colors');
    if (colors < 0) {
      throw('Failed to get the storage location of color');
    }
    var colorsVertices = Float32List.fromList(_colorVertex);
    gl.enableVertexAttribArray(colors);
    gl.bindBuffer(gl.ARRAY_BUFFER, _colorBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, colorsVertices.length, colorsVertices, gl.STATIC_DRAW);
    gl.vertexAttribPointer(colors, 3, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);

    var uniformLocation = gl.getUniformLocation(_glProgram, 'matrix');
    mat4.Matrix4 matrix4 = mat4.Matrix4(
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    );
    // matrix4.translate(mat4.Vector3(.0,.5,.0));
    // matrix4.scale(0.25,0.25,0.0);
    matrix4.rotateZ(degreeZ);
    matrix4.rotateY(degreeY);
    matrix4.rotateX(degreeX);
    gl.uniformMatrix4fv(uniformLocation, false, matrix4.storage);
    //
    // gl.drawArrays(gl.TRIANGLES, 0, _vertex.length/3);

    var verticesCube = Float32List.fromList(_vertexCube);
    gl.enableVertexAttribArray(coordinates);
    gl.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, verticesCube.length, verticesCube, gl.STATIC_DRAW);
    gl.vertexAttribPointer(coordinates, 3, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);

    // matrix4.translate(mat4.Vector3(.0,.0,.0));
    // matrix4.rotateZ(0);
    // gl.uniformMatrix4fv(uniformLocation, false, matrix4.storage);

    gl.drawArrays(gl.TRIANGLES, 0, _vertexCube.length/3);


  }

  // drawObject(ObjectModel objectModel,{double degreeX = 0,double degreeY = 0,double degreeZ = 0}){
  //
  //   //WebGLShader
  //   dynamic vertexShader = _makeShader(gl,'''
  //                   attribute vec3 aVertexPosition;
  //                   attribute vec3 aVertexNormal;
  //                   attribute vec2 aTextureCoord;
  //
  //                   uniform mat4 uNormalMatrix;
  //                   uniform mat4 uModelViewMatrix;
  //                   uniform mat4 uProjectionMatrix;
  //
  //                   varying highp vec2 vTextureCoord;
  //                   varying highp vec3 vLighting;
  //
  //                   void main(void) {
  //                       gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
  //                       vTextureCoord = aTextureCoord;
  //
  //                       highp vec3 ambientLight = vec3(0.3, 0.3, 0.3);
  //                       highp vec3 directionalLightColor = vec3(1, 1, 1);
  //                       highp vec3 directionalVector = normalize(vec3(0.85, 0.8, 0.75));
  //
  //                       highp vec4 transformedNormal = uNormalMatrix * vec4(aVertexNormal, 1.0);
  //
  //                       highp float directional = max(dot(transformedNormal.xyz, directionalVector), 0.0);
  //                       vLighting = ambientLight + (directionalLightColor * directional);
  //
  //                   }
  //               ''', gl.VERTEX_SHADER);
  //   //WebGLShader
  //   dynamic fragmentShader = _makeShader(gl,'''
  //                   varying highp vec2 vTextureCoord;
  //                   varying highp vec3 vLighting;
  //
  //                   uniform sampler2D uSampler;
  //
  //                   void main(void) {
  //                       highp vec4 texelColor = texture2D(uSampler, vTextureCoord);
  //                       gl_FragColor = vec4(texelColor.rgb * vLighting, texelColor.a);
  //                   }
  //               ''', gl.FRAGMENT_SHADER);
  //   dynamic shaderProgram = gl.createProgram();
  //   gl.attachShader(shaderProgram, vertexShader);
  //   gl.attachShader(shaderProgram, fragmentShader);
  //   gl.linkProgram(shaderProgram);
  //   var _res = gl.getProgramParameter(shaderProgram, gl.LINK_STATUS);
  //   if (_res == false || _res == 0) {
  //     throw Exception('Unable to initialize the shader program');
  //   }
  //   gl.useProgram(shaderProgram);
  //   gl.enable(gl.DEPTH_TEST);
  //
  //   var vertexPosition = gl.getAttribLocation(shaderProgram, 'aVertexPosition');
  //   if (vertexPosition < 0) {
  //     throw('Failed to get the storage location of coordinates');
  //   }
  //   var vertexNormal = gl.getAttribLocation(shaderProgram, 'aVertexNormal');
  //   if (vertexNormal < 0) {
  //     throw('Failed to get the storage location of coordinates');
  //   }
  //   var textureCoord = gl.getAttribLocation(shaderProgram, 'aTextureCoord');
  //   if (textureCoord < 0) {
  //     throw('Failed to get the storage location of coordinates');
  //   }
  //
  //
  //   var projectionMatrix = gl.getUniformLocation(shaderProgram, 'uProjectionMatrix');
  //   var modelViewMatrix = gl.getUniformLocation(shaderProgram, 'uModelViewMatrix');
  //   var normalMatrix = gl.getUniformLocation(shaderProgram, 'uNormalMatrix');
  //   var uSampler = gl.getUniformLocation(shaderProgram, 'uSampler');
  //
  //   List<double> vertices = objectModel.outVertices;
  //   List<double> normals = objectModel.outNormals;
  //   List<double> uvs = objectModel.outUVS;
  //
  //   dynamic _vertexBuffer = gl.createBuffer();
  //   if (_vertexBuffer == null) {
  //     throw Exception('Failed to create the vertexBuffer object');
  //   }
  //   var _vertices = Float32List.fromList(vertices);
  //   gl.enableVertexAttribArray(vertexPosition);
  //   gl.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
  //   gl.bufferData(gl.ARRAY_BUFFER, _vertices.length, _vertices, gl.STATIC_DRAW);
  //
  //   dynamic _normalBuffer = gl.createBuffer();
  //   if (_normalBuffer == null) {
  //     throw Exception('Failed to create the vertexBuffer object');
  //   }
  //   var _normalVertices = Float32List.fromList(normals);
  //   gl.enableVertexAttribArray(vertexNormal);
  //   gl.bindBuffer(gl.ARRAY_BUFFER, _normalBuffer);
  //   gl.bufferData(gl.ARRAY_BUFFER, _normalVertices.length, _normalVertices, gl.STATIC_DRAW);
  //
  //   dynamic _textureCoordBuffer = gl.createBuffer();
  //   if (_textureCoordBuffer == null) {
  //     throw Exception('Failed to create the vertexBuffer object');
  //   }
  //   var _textureCoordVertices = Float32List.fromList(uvs);
  //   gl.enableVertexAttribArray(textureCoord);
  //   gl.bindBuffer(gl.ARRAY_BUFFER, _textureCoordBuffer);
  //   gl.bufferData(gl.ARRAY_BUFFER, _textureCoordVertices.length, _textureCoordVertices, gl.STATIC_DRAW);
  //
  //   dynamic _indexBuffer = gl.createBuffer();
  //   if (_indexBuffer == null) {
  //     throw Exception('Failed to create the vertexBuffer object');
  //   }
  //   var _textureCoordVertices = Float32List.fromList(uvs);
  //   gl.enableVertexAttribArray(textureCoord);
  //   gl.bindBuffer(gl.ARRAY_BUFFER, _textureCoordBuffer);
  //   gl.bufferData(gl.ARRAY_BUFFER, _textureCoordVertices.length, _textureCoordVertices, gl.STATIC_DRAW);
  //
  //
  //   var uniformLocation = gl.getUniformLocation(_glProgram, 'matrix');
  //   mat4.Matrix4 normalMatrix = mat4.Matrix4(
  //       1,0,0,0,
  //       0,1,0,0,
  //       0,0,1,0,
  //       0,0,0,1
  //   );
  //   normalMatrix.rotateZ(degreeZ);
  //   normalMatrix.rotateY(degreeY);
  //   normalMatrix.rotateX(degreeX);
  //   gl.uniformMatrix4fv(uniformLocation, false, normalMatrix.storage);
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //   dynamic _uvBuffer = gl.createBuffer();
  //   if (_uvBuffer == null) {
  //     throw Exception('Failed to create the vertexBuffer object');
  //   }
  //   var uv = gl.getAttribLocation(_glProgram, 'UV');
  //   if (coordinates < 0) {
  //     throw('Failed to get the storage location of coordinates');
  //   }
  //   var _uvVertices = Float32List.fromList(uvs);
  //   gl.enableVertexAttribArray(uv);
  //   gl.bindBuffer(gl.ARRAY_BUFFER, _uvBuffer);
  //   gl.bufferData(gl.ARRAY_BUFFER, _uvVertices.length, _uvVertices, gl.STATIC_DRAW);
  //   gl.vertexAttribPointer(uv, 2, gl.FLOAT, false, Float32List.bytesPerElement * 2, 0);
  //
  //
  //   List<double> colorVertex = [];
  //   for (var element in vertices) {
  //     colorVertex.add(255/255);
  //     colorVertex.add(255/255);
  //     colorVertex.add(255/255);
  //   }
  //   dynamic _colorBuffer = gl.createBuffer();
  //   if (_colorBuffer == null) {
  //     throw Exception('Failed to create the colorBuffer object');
  //   }
  //   var colors = gl.getAttribLocation(_glProgram,'colors');
  //   if (colors < 0) {
  //     throw('Failed to get the storage location of color');
  //   }
  //   var _colorsVertices = Float32List.fromList(colorVertex);
  //   gl.enableVertexAttribArray(colors);
  //   gl.bindBuffer(gl.ARRAY_BUFFER, _colorBuffer);
  //   gl.bufferData(gl.ARRAY_BUFFER, _colorsVertices.length, _colorsVertices, gl.STATIC_DRAW);
  //   gl.vertexAttribPointer(colors, 3, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);
  //
  //
  //
  //
  //
  //   // var vertices = Float32List.fromList(_vertex);
  //   // gl.enableVertexAttribArray(coordinates);
  //   // gl.bindBuffer(gl.ARRAY_BUFFER, _vertexBuffer);
  //   // gl.bufferData(gl.ARRAY_BUFFER, vertices.length, vertices, gl.STATIC_DRAW);
  //   // gl.vertexAttribPointer(coordinates, 3, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);
  //
  //
  //
  //
  //
  //   // matrix4.translate(mat4.Vector3(.0,.5,.0));
  //   // matrix4.scale(0.25,0.25,0.0);
  //
  //   //
  //   // gl.drawArrays(gl.TRIANGLES, 0, _vertex.length/3);
  //
  //
  //
  //   // matrix4.translate(mat4.Vector3(.0,.0,.0));
  //   // matrix4.rotateZ(0);
  //   // gl.uniformMatrix4fv(uniformLocation, false, matrix4.storage);
  //
  //   gl.drawArrays(gl.TRIANGLES, 0, 24459 * 2);
  //
  //
  // }

  Map<int,List<double>> c = {
    0: [39/255, 77/255, 82/255],
    1: [199/255, 162/255, 166/255],
    2: [129/255, 139/255, 112/255],
    3: [96/255, 78/255, 60/255],
    4: [140/255, 159/255, 183/255],
    5: [121/255, 104/255, 128/255],

  };
  List<double> randomColor(int face) {
    // var rng = math.Random();
    // return [rng.nextInt(255)/255, rng.nextInt(255)/255, rng.nextInt(255)/255];
    return c[face]!;
  }
  _makeShader(gl, src, type) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, src);
    gl.compileShader(shader);
    var _res = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (_res == 0 || _res == false) {
      print("Error compiling shader: ${gl.getShaderInfoLog(shader)}");
      return;
    }
    return shader;
  }
}