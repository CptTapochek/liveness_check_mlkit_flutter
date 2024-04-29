import 'package:flutter/material.dart';

class AppColors {
  const AppColors();

  Color branding(int pallet) {
    Color color = const Color(0xFF000000);
    String hex = "000000";
    switch (pallet) {
      case 1: hex = "f5fcff"; break; case 2: hex = "e0f7ff"; break; case 3: hex = "cbf1ff"; break;
      case 4: hex = "b7ebff"; break; case 5: hex = "a3e6ff"; break; case 6: hex = "8fe0ff"; break;
      case 7: hex = "7bdbff"; break; case 8: hex = "65c0ea"; break; case 9: hex = "51d0ff"; break;
      case 10: hex = "3dcaff"; break; case 11: hex = "29c5ff"; break; case 12: hex = "17c0ff"; break;
      case 13: hex = "16baff"; break; case 14: hex = "13abea"; break; case 15: hex = "119cd6"; break;
      case 16: hex = "0e8dc2"; break; case 17: hex = "007AAB"; break; case 18: hex = "096f98"; break;
      case 19: hex = "066084"; break; case 20: hex = "055170"; break; case 21: hex = "03435c"; break;
      case 22: hex = "023548"; break; case 23: hex = "012432"; break; case 24: hex = "00161e"; break;
      default: hex = "16baff"; break;
    }
    color = Color(int.parse("0xFF$hex"));
    return color;
  }
  Color info(int pallet) {
    Color color = const Color(0xFF000000);
    String hex = "000000";
    switch (pallet) {
      case 1: hex = "f5fbfc"; break; case 2: hex = "e2f3f5"; break; case 3: hex = "cdebec"; break;
      case 4: hex = "bae3e7"; break; case 5: hex = "a6dbe0"; break; case 6: hex = "93d3d9"; break;
      case 7: hex = "80ccd2"; break; case 8: hex = "6ac3cb"; break; case 9: hex = "57bbc4"; break;
      case 10: hex = "44b4be"; break; case 11: hex = "31acb6"; break; case 12: hex = "1da4af"; break;
      case 13: hex = "129ca9"; break; case 14: hex = "108f9b"; break; case 15: hex = "0d838e"; break;
      case 16: hex = "0b7780"; break; case 17: hex = "096A73"; break; case 18: hex = "075d65"; break;
      case 19: hex = "055157"; break; case 20: hex = "04444a"; break; case 21: hex = "03383d"; break;
      case 22: hex = "032c2f"; break; case 23: hex = "021f21"; break; case 24: hex = "011214"; break;
      default: hex = "129ca9"; break;
    }
    color = Color(int.parse("0xFF$hex"));
    return color;
  }
  Color success(int pallet) {
    Color color = const Color(0xFF000000);
    String hex = "000000";
    switch (pallet) {
      case 1: hex = "f6fcfb"; break; case 2: hex = "e2f7f2"; break; case 3: hex = "cef1e8"; break;
      case 4: hex = "bbece0"; break; case 5: hex = "a8e7d7"; break; case 6: hex = "96e2cf"; break;
      case 7: hex = "83ddc5"; break; case 8: hex = "6ed7bd"; break; case 9: hex = "5bd2b4"; break;
      case 10: hex = "47cdab"; break; case 11: hex = "36c8a3"; break; case 12: hex = "23c29a"; break;
      case 13: hex = "1abd91"; break; case 14: hex = "17ad85"; break; case 15: hex = "149f79"; break;
      case 16: hex = "11906e"; break; case 17: hex = "0e8163"; break; case 18: hex = "0b7156"; break;
      case 19: hex = "08624b"; break; case 20: hex = "075340"; break; case 21: hex = "054434"; break;
      case 22: hex = "043529"; break; case 23: hex = "03251c"; break; case 24: hex = "021611"; break;
      default: hex = "1abd91"; break;
    }
    color = Color(int.parse("0xFF$hex"));
    return color;
  }
  Color warning(int pallet) {
    Color color = const Color(0xFF000000);
    String hex = "000000";
    switch (pallet) {
      case 1: hex = "fefaf8"; break; case 2: hex = "fcf0e9"; break; case 3: hex = "fae5d8"; break;
      case 4: hex = "f8dcca"; break; case 5: hex = "f6d2bb"; break; case 6: hex = "f4c8ac"; break;
      case 7: hex = "f2be9d"; break; case 8: hex = "f0b38d"; break; case 9: hex = "eeaa7e"; break;
      case 10: hex = "eca071"; break; case 11: hex = "ea9661"; break; case 12: hex = "e88c52"; break;
      case 13: hex = "e68343"; break; case 14: hex = "d47a41"; break; //case 15: hex = "c3723f"; break;
      case 15: hex = "A7602A"; break;
      case 16: hex = "b26b3e"; break; case 17: hex = "a1643c"; break; case 18: hex = "8e5c3a"; break;
      case 19: hex = "7d5439"; break; case 20: hex = "6c4c37"; break; case 21: hex = "5b4535"; break;
      case 22: hex = "4a3e34"; break; case 23: hex = "373632"; break; case 24: hex = "262e30"; break;
      default: hex = "e46e18"; break;
    }
    color = Color(int.parse("0xFF$hex"));
    return color;
  }
  Color danger(int pallet) {
    Color color = const Color(0xFF000000);
    String hex = "000000";
    switch (pallet) {
      case 1: hex = "fef7f8"; break; case 2: hex = "fbe9ea"; break; case 3: hex = "f8d7d9"; break;
      case 4: hex = "f6c9ca"; break; case 5: hex = "f4b9bd"; break; case 6: hex = "f2aaaf"; break;
      case 7: hex = "ed8b90"; break; case 8: hex = "ed8b90"; break; case 9: hex = "e97c82"; break;
      case 10: hex = "e86c74"; break; case 11: hex = "e55e65"; break; case 12: hex = "e34e57"; break;
      case 13: hex = "e13f49"; break; case 14: hex = "cf3c45"; break; case 15: hex = "be3a44"; break;
      case 16: hex = "ae3842"; break; case 17: hex = "9d3640"; break; case 18: hex = "8b333e"; break;
      case 19: hex = "7a323c"; break; case 20: hex = "692f38"; break; case 21: hex = "582d38"; break;
      case 22: hex = "482b35"; break; case 23: hex = "362833"; break; case 24: hex = "252631"; break;
      default: hex = "bf4040"; break;
    }
    color = Color(int.parse("0xFF$hex"));
    return color;
  }
  Color basic(int pallet) {
    Color color = const Color(0xFF000000);
    String hex = "000000";
    switch (pallet) {
      case 1: hex = "fafbfb"; break; case 2: hex = "f2f3f4"; break; case 3: hex = "e8eaeb"; break;
      case 4: hex = "e1e3e5"; break; case 5: hex = "d7dbdd"; break; case 6: hex = "CED3D5"; break;
      case 7: hex = "C6CBCE"; break; case 8: hex = "bdc3c6"; break; case 9: hex = "b4bbbe"; break;
      case 10: hex = "abb3b7"; break; case 11: hex = "a3abaf"; break; case 12: hex = "9aa4a8"; break;
      case 13: hex = "919ca0"; break; case 14: hex = "869196"; break; case 15: hex = "7c888d"; break;
      case 16: hex = "717e85"; break; case 17: hex = "67767d"; break; case 18: hex = "5b6b72"; break;
      case 19: hex = "516169"; break; case 20: hex = "465860"; break; case 21: hex = "3c4e57"; break;
      case 22: hex = "32454f"; break; case 23: hex = "263a44"; break; case 24: hex = "1b313b"; break;
      default: hex = "808080"; break;
    }
    color = Color(int.parse("0xFF$hex"));
    return color;
  }
}