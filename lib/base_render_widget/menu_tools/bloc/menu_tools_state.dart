part of 'menu_tools_bloc.dart';

abstract class MenuToolsState {
  Tools tools = Tools.point;
}

class MenuToolsInitial extends MenuToolsState {
 @override
  Tools get tools => Tools.point;
}
class MenuToolsSelectDrawPoint extends MenuToolsState {
  @override
  Tools get tools => Tools.point;
}
class MenuToolsSelectDrawLine extends MenuToolsState {
  @override
  Tools get tools => Tools.line;
}
class MenuToolsSelectDrawPentagon extends MenuToolsState {
  @override
  Tools get tools => Tools.pentagon;
}
class MenuToolsSelectDrawShap extends MenuToolsState {
  @override
  Tools get tools => Tools.shap;
}

enum Tools{
  point,line,pentagon,shap
}