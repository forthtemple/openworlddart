import 'dart:convert';

import 'package:openworld/three_dart/three_dart.dart' as THREE;
import 'dart:math' as math;
import 'package:openworld/three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;
import 'package:http/http.dart' as http;

// Another player in the game
class Player
{
  late THREE.Object3D actor;//AnimationMixer mixer;//=THREE.AnimationMixer();
  String userid="";
  String name="";
  bool isWalking=false;

  Player(actor)
  {
    this.actor=actor;//mixer=mixer;
  }
}

class You
{
  static Map actions={};  //for server like who
  static String action=""; // eg wave
  static String name="";
  static List msg=[];    // what you said
}

class Session {
  late String url;

  Session(url)
  {
    this.url=url;
  }

  Map<String, String> headers = {};

  Future<http.Response> get() async {
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    updateCookie(response);
    return response;
    //return json.decode(response.body);
  }

  Future<http.Response> post( dynamic data) async {
    http.Response response = await http.post(Uri.parse(url), body: data, headers: headers);
    updateCookie(response);
   // return json.decode(response.body);
    return response;
  }

  // So remember sessions
  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
      (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}

// Connection states
class Connection
{
  static int CS_NONE = 0;
  static int CS_GET_NAME = 1;
  static int CS_CONNECTING = 2;
  static int CS_CONNECTED = 3;
  static int connect_state=0;
}