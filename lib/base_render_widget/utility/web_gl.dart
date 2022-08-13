import 'dart:typed_data';

import 'package:example_one/base_render_widget/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'dart:math' as Math;
import 'package:vector_math/vector_math_64.dart' as mat4;

const bool debug = true;

void printLog(String msg){
  if(debug) {
    debugPrint(msg);
  }
}

class WebGL{
  var cubeRotationX = 0.0;
  var cubeRotationY = 0.0;
  var cubeRotationZ = 0.0;

  bool cubeRotationXDirection = true;
  bool cubeRotationYDirection = false;
  bool cubeRotationZDirection = false;


  var cubeTranslateX = 0.0;
  var cubeTranslateY = 0.0;
  var cubeTranslateZ = -100.0;

  late FlutterGlPlugin fgl;
  // static const vsSource = '''
  //   attribute vec4 aVertexPosition;
  //   attribute vec3 aVertexNormal;
  //   attribute vec2 aTextureCoord;
  //   uniform mat4 uNormalMatrix;
  //   uniform mat4 uModelViewMatrix;
  //   uniform mat4 uProjectionMatrix;
  //   varying highp vec2 vTextureCoord;
  //   varying highp vec3 vLighting;
  //   void main(void) {
  //     gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
  //     vTextureCoord = aTextureCoord;
  //     // Apply lighting effect
  //     highp vec3 ambientLight = vec3(0.3, 0.3, 0.3);
  //     highp vec3 directionalLightColor = vec3(1, 1, 1);
  //     highp vec3 directionalVector = normalize(vec3(0.85, 0.8, 0.75));
  //     highp vec4 transformedNormal = uNormalMatrix * vec4(aVertexNormal, 1.0);
  //     highp float directional = max(dot(transformedNormal.xyz, directionalVector), 0.0);
  //     vLighting = ambientLight + (directionalLightColor * directional);
  //   }
  // ''';
  static const vsSource = '''
    attribute vec3 aVertexPosition;
    attribute vec3 colors;
    varying vec4 vColor;
    uniform mat4 uModelViewMatrix;
    uniform mat4 uProjectionMatrix;
    void main(void) {
        gl_Position = uProjectionMatrix * uModelViewMatrix * vec4(aVertexPosition, 1.0);
        // gl_Position = vec4(aVertexPosition, 1.0);
        // vColor = vec4(colors, 1.0);
        vColor = vec4(1.0,1.0,1.0, 1.0);
        gl_PointSize = 1.0;
    }
  ''';

  // static const fsSource = '''
  //   varying highp vec2 vTextureCoord;
  //   varying highp vec3 vLighting;
  //   uniform sampler2D uSampler;
  //   void main(void) {
  //     highp vec4 texelColor = texture2D(uSampler, vTextureCoord);
  //     gl_FragColor = vec4(texelColor.rgb * vLighting, texelColor.a);
  //   }
  // ''';
  static const fsSource = '''
    precision mediump float;
    varying vec4 vColor;
    void main(void) {
        gl_FragColor = vColor;
    }
  ''';

  dynamic shaderProgram ;
  dynamic vertexPosition;
  dynamic vertexNormal;
  dynamic textureCoord;
  dynamic vertexColors;

  dynamic projectionUniformLocation;
  dynamic modelViewUniformLocation;
  dynamic normalUniformLocation;
  dynamic uSampler;

  Matrix4? projectionMatrix;
  Matrix4? modelViewMatrix;
  Matrix4? normalMatrix;

  dynamic positionBuffer;
  dynamic normalBuffer;
  dynamic textureCoordBuffer;
  dynamic indexBuffer;
  dynamic colorBuffer;

  List<double>? positions;
  List<double>? vertexNormals;
  List<double>? textureCoordinates;
  List<double>? indices;
  List<double>? colors;

  dynamic texture;

  WebGL(this.fgl, {this.positions,this.vertexNormals,this.textureCoordinates,this.indices}){
    loadNeedDefault();
    initShaderProgram(vsSource, fsSource);
    printLog('getAttribLocation');
    if(shaderProgram != null){
      vertexPosition = fgl.gl.getAttribLocation(shaderProgram, 'aVertexPosition');
      // vertexNormal = fgl.gl.getAttribLocation(shaderProgram, 'aVertexNormal');
      // textureCoord = fgl.gl.getAttribLocation(shaderProgram, 'aTextureCoord');
      vertexColors = fgl.gl.getAttribLocation(shaderProgram,'colors');
      printLog('getAttribLocation vertex success');
      projectionUniformLocation = fgl.gl.getUniformLocation(shaderProgram, 'uProjectionMatrix');
      modelViewUniformLocation = fgl.gl.getUniformLocation(shaderProgram, 'uModelViewMatrix');
      // normalUniformLocation = fgl.gl.getUniformLocation(shaderProgram, 'uNormalMatrix');
      printLog('getAttribLocation Matrix success');
      // uSampler = fgl.gl.getUniformLocation(shaderProgram, 'uSampler');
    }else{
      throw Exception('shaderProgram failed');
    }
    printLog('getAttribLocation success');
    initBuffers();
    // loadTexture('assets/cubetexture.png');
    // render(DateTime.now());

  }

  // setupDefaultFBO() {
  //   final _gl = flutterGlPlugin.gl;
  //   int glWidth = (width * dpr).toInt();
  //   int glHeight = (height * dpr).toInt();
  //
  //   defaultFramebuffer = _gl.createFramebuffer();
  //   defaultFramebufferTexture = _gl.createTexture();
  //   _gl.activeTexture(_gl.TEXTURE0);
  //
  //   _gl.bindTexture(_gl.TEXTURE_2D, defaultFramebufferTexture);
  //   _gl.texImage2D(_gl.TEXTURE_2D, 0, _gl.RGBA, glWidth, glHeight, 0, _gl.RGBA,
  //       _gl.UNSIGNED_BYTE, null);
  //   _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.LINEAR);
  //   _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.LINEAR);
  //
  //   _gl.bindFramebuffer(_gl.FRAMEBUFFER, defaultFramebuffer);
  //   _gl.framebufferTexture2D(_gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0,
  //       _gl.TEXTURE_2D, defaultFramebufferTexture, 0);
  // }
  loadNeedDefault(){
    printLog('loadNeedDefault');
    positions ??= [];
    // Map<int,List<double>> c = {
    //   0: [39/255, 77/255, 82/255],
    //   1: [199/255, 162/255, 166/255],
    //   2: [129/255, 139/255, 112/255],
    //   3: [96/255, 78/255, 60/255],
    //   4: [140/255, 159/255, 183/255],
    //   5: [121/255, 104/255, 128/255],
    // };
    colors = [];
    // for (var face = 0; face < 6; face++) {
    //   // List<double>? faceColor = c[face];
    //   for (var vertex = 0; vertex < 6; vertex++) {
    //     colors!.add(faceColor![0]);
    //     colors!.add(faceColor[1]);
    //     colors!.add(faceColor[2]);
    //   }
    // }
    vertexNormals ??= [];
    textureCoordinates ??= [];

    indices ??=[];
  }
  initShaderProgram(vsSource, fsSource) {
    printLog('initShaderProgram');
    var vertexShader = loadShader(fgl.gl.VERTEX_SHADER, vsSource);
    var fragmentShader = loadShader(fgl.gl.FRAGMENT_SHADER, fsSource);
    shaderProgram = fgl.gl.createProgram();
    fgl.gl.attachShader(shaderProgram, vertexShader);
    fgl.gl.attachShader(shaderProgram, fragmentShader);
    fgl.gl.linkProgram(shaderProgram);
    if (!(fgl.gl.getProgramParameter(shaderProgram, fgl.gl.LINK_STATUS))) {
      printLog('Unable to initialize the shader program: ' + fgl.gl.getProgramInfoLog(shaderProgram));
      return null;
    }
    fgl.gl.useProgram(shaderProgram);
  }
  loadShader(type, source) {
    printLog('loadShader');
    var shader = fgl.gl.createShader(type);
    fgl.gl.shaderSource(shader, source);
    fgl.gl.compileShader(shader);
    if (!(fgl.gl.getShaderParameter(shader, fgl.gl.COMPILE_STATUS))) {
      printLog('An error occurred compiling the shaders: ' + fgl.gl.getShaderInfoLog(shader));
      fgl.gl.deleteShader(shader);
      return null;
    }
    return shader;
  }
  initBuffers() {
    printLog('initBuffers');
    var positionData = Float32List.fromList(positions!);
    positionBuffer = fgl.gl.createBuffer();
    fgl.gl.enableVertexAttribArray(vertexPosition);
    fgl.gl.bindBuffer(fgl.gl.ARRAY_BUFFER, positionBuffer);
    fgl.gl.bufferData(fgl.gl.ARRAY_BUFFER,positionData.length, positionData, fgl.gl.STATIC_DRAW);
    fgl.gl.vertexAttribPointer(vertexPosition, 3, fgl.gl.FLOAT, false, 0, 0);
    printLog('positionBuffer success');

    // var colorsVerticesData  = Float64List.fromList(colors!);
    // colorBuffer = fgl.gl.createBuffer();
    // fgl.gl.enableVertexAttribArray(vertexColors);
    // fgl.gl.bindBuffer(fgl.gl.ARRAY_BUFFER, colorBuffer);
    // fgl.gl.bufferData(fgl.gl.ARRAY_BUFFER,colorsVerticesData.length, colorsVerticesData, fgl.gl.STATIC_DRAW);
    // fgl.gl.vertexAttribPointer(vertexColors, 3, fgl.gl.FLOAT, false, Float64List.bytesPerElement * 3, 0);
    // printLog('colorBuffer success');

    // var vertexNormalsData = Float32Array(vertexNormals);
    // var normalBuffer = fgl.gl.createBuffer();
    // fgl.gl.bindBuffer(fgl.gl.ARRAY_BUFFER, normalBuffer);
    // fgl.gl.bufferData(fgl.gl.ARRAY_BUFFER, vertexNormalsData.length,vertexNormalsData, fgl.gl.STATIC_DRAW);
    //
    // var textureCoordinatesData = Float32Array(textureCoordinates);
    // var textureCoordBuffer = fgl.gl.createBuffer();
    // fgl.gl.bindBuffer(fgl.gl.ARRAY_BUFFER, textureCoordBuffer);
    // fgl.gl.bufferData(fgl.gl.ARRAY_BUFFER,textureCoordinatesData.length ,textureCoordinatesData, fgl.gl.STATIC_DRAW);
    //
    // var indicesData = Uint16Array(indices);
    // var indexBuffer = fgl.gl.createBuffer();
    // fgl.gl.bindBuffer(fgl.gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    // fgl.gl.bufferData(fgl.gl.ELEMENT_ARRAY_BUFFER, indicesData.length, indicesData, fgl.gl.STATIC_DRAW);
  }
  render() {
    printLog('render as ${DateTime.now()}');
    drawScene();
  }
  drawScene() {
    printLog('drawScene');
    fgl.gl.clearColor(0.0, 0.0, 0.0, 1.0);  // Clear to black, fully opaque
    fgl.gl.clearDepth(1.0);                 // Clear everything
    fgl.gl.enable(fgl.gl.DEPTH_TEST);           // Enable depth testing
    fgl.gl.depthFunc(fgl.gl.LEQUAL);            // Near things obscure far things

    fgl.gl.clear(fgl.gl.COLOR_BUFFER_BIT | fgl.gl.DEPTH_BUFFER_BIT);


    var fieldOfView = 45 * Math.pi / 180;   // in radians
    // var aspect = contextWeb.gl.canvas.clientWidth / gl.canvas.clientHeight;
    var aspect = 1.0;
    var zNear = 0.1;
    var zFar = 1000.0;
    projectionMatrix = mat4.Matrix4(
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    );
    projectionMatrix = mat4.makePerspectiveMatrix(fieldOfView, aspect, zNear, zFar);

    modelViewMatrix = mat4.Matrix4(
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    );
    modelViewMatrix!.translate(mat4.Vector3(cubeTranslateX, cubeTranslateY, cubeTranslateZ));

    // printLog('modelViewMatrix : ${modelViewMatrix!.storage}');
    // modelViewMatrix!.rotate(mat4.Vector3(
    //     cubeRotationXDirection ? 1 : 0,
    //     cubeRotationYDirection ? 1 : 0,
    //     cubeRotationZDirection ? 1 : 0
    // ), cubeRotation * Math.pi / 180);

    //TODO ??? why Z Y?
    modelViewMatrix!.rotate(mat4.Vector3(1 ,0, 0), cubeRotationX * Math.pi / 180);
    modelViewMatrix!.rotate(mat4.Vector3(0 ,0, 1), cubeRotationY * Math.pi / 180);
    modelViewMatrix!.rotate(mat4.Vector3(0 ,1, 0), cubeRotationZ * Math.pi / 180);

    // printLog('modelViewMatrix : ${modelViewMatrix!.storage}');


    // _calculateTranslate();
    // printLog('$cubeRotation');
    // _calculateRotate();
    // modelViewMatrix.rotate(mat4.Vector3(0, 1, 1), cubeRotation * Math.pi / 180);
    // modelViewMatrix.rotate(mat4.Vector3(1, 0, 0), cubeRotation);

    // var normalMatrix = mat4.Matrix4(
    //     1,0,0,0,
    //     0,1,0,0,
    //     0,0,1,0,
    //     0,0,0,1
    // );
    // normalMatrix = modelViewMatrix;
    // normalMatrix.invert();
    // normalMatrix.transpose();

    //todo ios
    fgl.gl.uniformMatrix4fv(projectionUniformLocation, false, projectionMatrix!.storage);
    fgl.gl.uniformMatrix4fv(modelViewUniformLocation, false, modelViewMatrix!.storage);


    // fgl.gl.uniformMatrix4fv(normalUniformLocation, false, normalMatrix.storage);

    // fgl.gl.activeTexture(fgl.gl.TEXTURE0);
    // fgl.gl.bindTexture(fgl.gl.TEXTURE_2D, texture);
    // fgl.gl.uniform1i(uSampler, 0);
    //
    int vertexCount = positions!.length ~/ 3;
    printLog('vertexCount : ${positions!.length / 3}');
    // fgl.gl.drawArrays(fgl.gl.TRIANGLES, 0, vertexCount);
    fgl.gl.drawArrays(fgl.gl.POINTS, 0, vertexCount);

  }

  loadTexture(url) {
    printLog('loadTexture');
    texture = fgl.gl.createTexture();
    fgl.gl.activeTexture(fgl.gl.TEXTURE0);
    fgl.gl.bindTexture(fgl.gl.TEXTURE_2D, texture);

    var level = 0;
    var internalFormat = fgl.gl.RGBA;
    var width = 1;
    var height = 1;
    var border = 0;
    var srcFormat = fgl.gl.RGBA;
    var srcType = fgl.gl.UNSIGNED_BYTE;
    var pixel = Uint8Array.from([0, 0, 255, 255]);  // opaque blue

    fgl.gl.texImage2D(fgl.gl.TEXTURE_2D, level, internalFormat, width, height, border, srcFormat, srcType, pixel);


    Image image = Image(image: AssetImage(url));
    printLog('${url}');
    printLog('${image}');

    // fgl.gl.bindTexture(fgl.gl.TEXTURE_2D, texture);
    // fgl.gl.texImage2D(fgl.gl.TEXTURE_2D, level, internalFormat, width, height, border,srcFormat, srcType, image);

    // WebGL1 has different requirements for power of 2 images
    // vs non power of 2 images so check if the image is a
    // power of 2 in both dimensions.
    // if (isPowerOf2(image.width) && isPowerOf2(image.height)) {
    //   // Yes, it's a power of 2. Generate mips.
    //   fgl.gl.generateMipmap(fgl.gl.TEXTURE_2D);
    // } else {
    //   // No, it's not a power of 2. Turn of mips and set
    //   // wrapping to clamp to edge
    //   fgl.gl.texParameteri(fgl.gl.TEXTURE_2D, fgl.gl.TEXTURE_WRAP_S, fgl.gl.CLAMP_TO_EDGE);
    //   fgl.gl.texParameteri(fgl.gl.TEXTURE_2D, fgl.gl.TEXTURE_WRAP_T, fgl.gl.CLAMP_TO_EDGE);
    //   fgl.gl.texParameteri(fgl.gl.TEXTURE_2D, fgl.gl.TEXTURE_MIN_FILTER, fgl.gl.LINEAR);
    // }
    fgl.gl.texParameteri(fgl.gl.TEXTURE_2D, fgl.gl.TEXTURE_WRAP_S, fgl.gl.CLAMP_TO_EDGE);
    fgl.gl.texParameteri(fgl.gl.TEXTURE_2D, fgl.gl.TEXTURE_WRAP_T, fgl.gl.CLAMP_TO_EDGE);
    fgl.gl.texParameteri(fgl.gl.TEXTURE_2D, fgl.gl.TEXTURE_MIN_FILTER, fgl.gl.LINEAR);
  }
  dynamic isPowerOf2(value) {
    printLog('isPowerOf2');
    return (value & (value - 1)) == 0;
  }

  moveToRight(){
    // rotateToRight();
    cubeTranslateX +=5;
    drawScene();
  }
  moveToLeft(){
    // rotateToLeft();
    cubeTranslateX -=5;
    drawScene();
  }
  moveToTop(){
    cubeTranslateY +=2;
    drawScene();
  }
  moveToBottom(){
    cubeTranslateY -=2;
    drawScene();
  }

  zoomIn(){
    if(cubeTranslateZ < 0){
      cubeTranslateZ +=5;
      drawScene();
    }
  }
  zoomOut(){
    cubeTranslateZ -=5;
    drawScene();
  }

  rotateToRight(AxisStatus axisStatus,{int? step}) {
    if (axisStatus == AxisStatus.X) {
      if (cubeRotationX < 360) {
        cubeRotationX += step ?? 10;
      } else {
        cubeRotationX = 0;
        cubeRotationX += step ?? 10;
      }
    } else if (axisStatus == AxisStatus.Y) {
      if (cubeRotationY < 360) {
        cubeRotationY += step ?? 10;
      } else {
        cubeRotationY = 0;
        cubeRotationY += step ?? 10;
      }
    } else {
      if (cubeRotationZ < 360) {
        cubeRotationZ += step ?? 10;
      } else {
        cubeRotationZ = 0;
        cubeRotationZ += step ?? 10;
      }
    }
    drawScene();
  }
  rotateToLeft(AxisStatus axisStatus,{int? step}){
    if (axisStatus == AxisStatus.X) {
      if(cubeRotationX >= 0){
        cubeRotationX -= step ?? 10;
      }else{
        cubeRotationX = 360;
        cubeRotationX -= step ?? 10;
      }
    } else if (axisStatus == AxisStatus.Y) {
      if(cubeRotationY >= 0){
        cubeRotationY -= step ?? 10;
      }else{
        cubeRotationY = 360;
        cubeRotationY -= step ?? 10;
      }
    } else {
      if(cubeRotationZ >= 0){
        cubeRotationZ -= step ?? 10;
      }else{
        cubeRotationZ = 360;
        cubeRotationZ -= step ?? 10;
      }
    }
    drawScene();
  }

  autoRotate(AxisStatus axisStatus){
    rotateToRight(axisStatus,step: 2);
  }


}
