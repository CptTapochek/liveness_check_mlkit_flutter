import 'package:next_vision_flutter_app/src/constants/size.dart';
import 'package:next_vision_flutter_app/src/liveness_check/components/sets_of_challenges.dart';


class RotateLookPositionArc {
  int getArcHAngle(PositionType positionType) {
    switch(positionType) {
      case PositionType.up: return 33;
      case PositionType.down: return 11;
      case PositionType.left: return 0;
      case PositionType.right: return 0;
      case PositionType.topRight: return 18;
      case PositionType.topLeft: return 4;
      case PositionType.bottomRight: return 7;
      case PositionType.bottomLeft: return 15;
    }
  }

  int getArcVAngle(PositionType positionType) {
    switch(positionType) {
      case PositionType.up: return 1;
      case PositionType.down: return 1;
      case PositionType.left: return 1;
      case PositionType.right: return 0;
      case PositionType.topRight: return 0;
      case PositionType.topLeft: return 0;
      case PositionType.bottomRight: return 0;
      case PositionType.bottomLeft: return 0;
    }
  }

  Map getPosition(PositionType positionType) {
    switch(positionType) {
      case PositionType.up:
        return {
          "left": null,
          "right": null,
          "bottom": const AppSize().flex(370),
          "top": 0.0
        };
      case PositionType.down:
        return {
          "left": null,
          "right": null,
          "bottom": 0.0,
          "top": const AppSize().flex(130)
        };
      case PositionType.left:
        return {
          "left": 10.0,
          "right": null,
          "bottom": const AppSize().flex(120),
          "top": 0.0
        };
      case PositionType.right:
        return {
          "left": null,
          "right": 10.0,
          "bottom": const AppSize().flex(120),
          "top": 0.0
        };
      case PositionType.topRight:
        return {
          "left": null,
          "right": 55.0,
          "bottom": const AppSize().flex(310),
          "top": 0.0
        };
      case PositionType.topLeft:
        return {
          "left": 55.0,
          "right": null,
          "bottom": const AppSize().flex(310),
          "top": 0.0
        };
      case PositionType.bottomRight:
        return {
          "left": null,
          "right": 45.0,
          "bottom": 0.0,
          "top": const AppSize().flex(45)
        };
      case PositionType.bottomLeft:
        return {
          "left": 45.0,
          "right": null,
          "bottom": 0.0,
          "top": const AppSize().flex(45)
        };
    }
  }
}