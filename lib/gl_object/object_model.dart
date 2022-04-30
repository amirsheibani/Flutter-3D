import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show ByteData, NetworkAssetBundle, rootBundle;

class ObjectModel{

  List<double> outVertices = [];
  List<double> outUVS = [];
  List<double> outNormals = [];

  List<int> vertexIndices = [];
  List<int> uvIndices = [];
  List<int> normalIndices = [];

  bool? isUseDDS;

  List<double> tempVertices = [];
  List<double> tempUVS = [];
  List<double> tempNormals = [];

  Map<String,List<double>> dataResult = {};


  Future<void>loadFileFromAsset(String path,{bool isUseDDS = false}) async {
    this.isUseDDS = isUseDDS;
    ByteData? _data = await rootBundle.load(path);
    tempVertices = [];
    tempUVS = [];
    tempNormals = [];
    await _objParsDate(_data);
    // processingData();
  }
  Future<void> loadFileFromNetwork(String path,{bool isUseDDS = false}) async {
    this.isUseDDS = isUseDDS;
    ByteData? _data = await NetworkAssetBundle(Uri.parse(path)).load("");
    await _objParsDate(_data);
    _objProcessingData();
  }
  
  Future _objParsDate(ByteData _data){
    final Completer completer = Completer();
    final ByteBuffer buffer = _data.buffer;
    Uint8List list = buffer.asUint8List(_data.offsetInBytes, _data.lengthInBytes);
    List<String> lines = String.fromCharCodes(list).split('\n');
    for(var line in lines){
      if(line.startsWith('v ')){
        _objLoadVertex(line);
      }else if(line.startsWith('vt')){
        _objLoadVertexTexture(line);
      }else if(line.startsWith('vn')){
        _objLoadVertexNormal(line);
      } else if(line.startsWith('f ')){
        _objLoadPolygon(line);
      }
    }
    completer.complete();
    return completer.future;
  }
  _objLoadVertex(String line){
    line = line.replaceFirst('v ', '');
    List<String> items = line.split(' ');
    for(var item in items){
      if(item.isNotEmpty){
        tempVertices.add(double.parse(item));
      }
    }
  }
  _objLoadVertexTexture(String line){
    line = line.replaceFirst('vt', '');
    List<String> items = line.split(' ');
    int index = 0;
    for(var item in items){
      if(item.isNotEmpty){
        if(isUseDDS! && index == 2){
          tempUVS.add(double.parse(item) * -1);
        }else{
          tempUVS.add(double.parse(item));
        }
      }
      index++;
    }
  }
  _objLoadVertexNormal(String line){
    line = line.replaceFirst('vn', '');
    List<String> items = line.split(' ');
    for(var item in items){
      if(item.isNotEmpty){
        tempNormals.add(double.parse(item));
      }
    }
  }
  _objLoadPolygon(String line){
    line = line.replaceFirst('f ', '');
    String vertex1, vertex2, vertex3;
    List<int> vertexIndex = [];
    List<int> uvIndex = [];
    List<int> normalIndex = [];
    List<String> items = line.split(' ');
    for(var item in items){
      if(item != 'f ' && item.isNotEmpty){
        List<String> parts = item.split('/');
        if(parts.length == 3){
          vertexIndex.add(int.tryParse(parts[0]) ?? 0);
          uvIndex.add(int.tryParse(parts[1])?? 0);
          normalIndex.add(int.tryParse(parts[2])?? 0);
        }
      }
    }

    vertexIndices.add(vertexIndex[0]);
    vertexIndices.add(vertexIndex[1]);
    vertexIndices.add(vertexIndex[2]);
    uvIndices.add(uvIndex[0]);
    uvIndices.add(uvIndex[1]);
    uvIndices.add(uvIndex[2]);
    normalIndices.add(normalIndex[0]);
    normalIndices.add(normalIndex[1]);
    normalIndices.add(normalIndex[2]);
  }
  _objProcessingData(){
    debugPrint('vertexIndices.length :${vertexIndices.length}');
    outVertices = [];
    outUVS = [];
    normalIndices = [];
    for( int i=0; i<vertexIndices.length; i++ ){
      if(vertexIndices.isNotEmpty){
        int vertexIndex = vertexIndices[i];
        outVertices.add(tempVertices[vertexIndex-1 < 0 ? 0 : vertexIndex-1]);
      }
      if(uvIndices.isNotEmpty){
        int uvIndex = uvIndices[i];
        outUVS.add(tempUVS[uvIndex-1 < 0 ? 0 : uvIndex-1]);
      }
      if(normalIndices.isNotEmpty){
        int normalIndex = normalIndices[i];
        outNormals.add(tempNormals[normalIndex-1 < 0 ? 0 : normalIndex-1]);
      }
    }
    debugPrint('outVertices.length :${outVertices.length}');
    debugPrint('outUVS.length :${outUVS.length}');
    debugPrint('outNormals.length :${outNormals.length}');
    // dataResult['vertices'] = outVertices;
    // dataResult['uvs'] = outUVS;
    // dataResult['normals'] = outNormals;
  }
}
class ObjectModelSTL{
  List<double> outVertices = [];
  List<double> outUVS = [];
  List<double> outNormals = [];
  List<String> layer = [];
  
  Future<void>loadFileFromAsset(String path,{bool isUseDDS = false}) async {
    ByteData? _data = await rootBundle.load(path);
    outVertices = [];
    outUVS = [];
    outNormals = [];
    await _stlParsDate(_data);
  }
  Future<void> loadFileFromNetwork(String path,{bool isUseDDS = false}) async {
    ByteData? _data = await NetworkAssetBundle(Uri.parse(path)).load("");
    outVertices = [];
    outUVS = [];
    outNormals = [];
    await _stlParsDate(_data);
  }
  
  Future _stlParsDate(ByteData _data){
    final Completer completer = Completer();
    final ByteBuffer buffer = _data.buffer;
    Uint8List list = buffer.asUint8List(_data.offsetInBytes, _data.lengthInBytes);
    List<String> lines = String.fromCharCodes(list).split('\n');

    if(_isASCII(lines.first)){
      for(var line in lines){
        List<String> lineElements = line.split(' ');
        for(int index = 0;index < lineElements.length;index++){
          if(index+1 < lineElements.length){
            if(lineElements[index] == 'facet' && lineElements[index+1] == 'normal'){
              outNormals.add(double.tryParse(lineElements[index+2]) ?? 0);
              outNormals.add(double.tryParse(lineElements[index+3]) ?? 0);
              outNormals.add(double.tryParse(lineElements[index+4]) ?? 0);
              break;
            }
            if(lineElements[index] == 'vertex'){
              outVertices.add((double.tryParse(lineElements[index+1]) ?? 0) * 0.01);
              outVertices.add((double.tryParse(lineElements[index+2]) ?? 0) * 0.01);
              outVertices.add((double.tryParse(lineElements[index+3]) ?? 0) * 0.01);
              break;
            }
          }
        }
      }
    }else{
      debugPrint('is not ASCII');
    }
    debugPrint('outVertices: ${outVertices.length}');
    debugPrint('outNormals: ${outNormals.length}');
    completer.complete();
    return completer.future;
  }
  bool _isASCII(String line){
    return line.startsWith('solid') && line.contains('ASCII');
  }
}