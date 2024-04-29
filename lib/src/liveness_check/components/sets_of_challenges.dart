import 'dart:io';


/// Liveness check challenges
List setOfLeftRightChallenges = <Map>[
  {
    "label": "Look left",
    "maxEulerPosY": Platform.isAndroid ? 30 : -30,
    "minEulerPosY": 0,
    "maxEulerPosX": 15,
    "minEulerPosX": -15,
    "targetPosition": PositionType.left
  },
  {
    "label": "Look right",
    "maxEulerPosY": Platform.isAndroid ? -30 : 30,
    "minEulerPosY": 0,
    "maxEulerPosX": 15,
    "minEulerPosX": -15,
    "targetPosition": PositionType.right
  },
];

List setOfUpDownChallenges = <Map>[
  {
    "label": "Look up",
    "maxEulerPosY": 10,
    "minEulerPosY": -10,
    "maxEulerPosX": 30,
    "minEulerPosX": 0,
    "targetPosition": PositionType.up
  },
  {
    "label": "Look down",
    "maxEulerPosY": 10,
    "minEulerPosY": -10,
    "maxEulerPosX": -15,
    "minEulerPosX": 0,
    "targetPosition": PositionType.down
  },
];

List setOfCornersChallenges = <Map>[
  {
    "label": "Turn your head a bit",
    "maxEulerPosY": Platform.isAndroid ? -18 : 18,
    "minEulerPosY": 0,
    "maxEulerPosX": 15,
    "minEulerPosX": 0,
    "targetPosition": PositionType.topRight
  },
  {
    "label": "Turn your head a bit",
    "maxEulerPosY": Platform.isAndroid ? 18 : -18,
    "minEulerPosY": 0,
    "maxEulerPosX": 15,
    "minEulerPosX": 0,
    "targetPosition": PositionType.topLeft
  },
  {
    "label": "Turn your head a bit",
    "maxEulerPosY": Platform.isAndroid ? -16 : 16,
    "minEulerPosY": 0,
    "maxEulerPosX": -6,
    "minEulerPosX": 0,
    "targetPosition": PositionType.bottomRight
  },
  {
    "label": "Turn your head a bit",
    "maxEulerPosY": Platform.isAndroid ? 16 : -16,
    "minEulerPosY": 0,
    "maxEulerPosX": -6,
    "minEulerPosX": 0,
    "targetPosition": PositionType.bottomLeft
  },
];

enum PositionType {
  up,
  down,
  left,
  right,
  topRight,
  topLeft,
  bottomRight,
  bottomLeft
}