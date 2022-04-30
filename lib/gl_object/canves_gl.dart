import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_gl/flutter_gl.dart';

class CanvasGL {
  late FlutterGlPlugin _flutterGlPlugin;
  late final dynamic _sourceTexture;

  dynamic _defaultFramebuffer;
  dynamic _defaultFramebufferTexture;

  late Size _viewSize;
  late num _dpr;
  late Map<String, dynamic> _options;

  FlutterGlPlugin get flutterGlPlugin => _flutterGlPlugin;

  dynamic get sourceTexture => _sourceTexture;
  Size get viewSize => _viewSize;
  num get dpr => _dpr;

  CanvasGL(Size viewSize, num dpr) {
    _options = {
      "width": viewSize.width.toInt(),
      "height": viewSize.height.toInt(),
      "dpr": dpr,
      "antialias": true,
      "alpha": false
    };
    _viewSize = viewSize;
    _dpr = dpr;
    _flutterGlPlugin = FlutterGlPlugin(_viewSize.width.toInt(), _viewSize.height.toInt(), dpr: _dpr);

  }
  Future<void> init() async {
    await flutterGlPlugin.initialize(options: _options);
    print(" flutterGlPlugin: textureid: ${flutterGlPlugin.textureId} ");
    if (!kIsWeb) {
      await flutterGlPlugin.prepareContext();
      _setupDefaultFBO();
      _sourceTexture = _defaultFramebufferTexture;
    }
  }
  _setupDefaultFBO() {
    final _gl = flutterGlPlugin.gl;
    int glWidth = (_viewSize.width * _dpr).toInt();
    int glHeight = (_viewSize.height * _dpr).toInt();

    _defaultFramebuffer = _gl.createFramebuffer();
    _defaultFramebufferTexture = _gl.createTexture();
    _gl.activeTexture(_gl.TEXTURE0);

    _gl.bindTexture(_gl.TEXTURE_2D, _defaultFramebufferTexture);
    _gl.texImage2D(_gl.TEXTURE_2D, 0, _gl.RGBA, glWidth, glHeight, 0, _gl.RGBA, _gl.UNSIGNED_BYTE, null);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.LINEAR);

    _gl.bindFramebuffer(_gl.FRAMEBUFFER, _defaultFramebuffer);
    _gl.framebufferTexture2D(_gl.FRAMEBUFFER, _gl.COLOR_ATTACHMENT0, _gl.TEXTURE_2D, _defaultFramebufferTexture, 0);
  }
}
