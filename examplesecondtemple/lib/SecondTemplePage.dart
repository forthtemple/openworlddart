import 'dart:async';
import 'dart:convert';
import 'dart:developer';


import 'dart:ui';

import 'package:audioplayers/audioplayers.dart' as audioplayers;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openworld_gl/openworld_gl.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_user_guildance/flutter_user_guildance.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:openworld/three_dart/three3d/objects/index.dart';
import 'package:openworld/three_dart/three_dart.dart' as THREE;
import 'package:openworld/three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'package:openworld/objects/fire.dart';

import 'package:openworld/objects/flares.dart';
import 'package:openworld/objects/smoke.dart';
import 'package:openworld/shaders/water2.dart';
import 'package:openworld/objects/watersimple.dart';
import 'package:openworld/openworld.dart' as OPENWORLD;
import 'package:openworld/client.dart' as CLIENT;
import 'package:openworld/shaders/SkyShader.dart';
import 'dart:math' as math;

import 'package:openworld/three_dart_jsm/three_dart_jsm/controls/index.dart';
import 'package:openworld/three_dart_jsm/extra/dom_like_listenable.dart';
import 'package:http/http.dart';

String gamename = 'Second Temple';

class SecondTemplePage extends StatefulWidget {


  SecondTemplePage({Key? key})
      : super(key: key);

  @override
  createState() => _State();
}

class _State extends State<SecondTemplePage> {
  UserGuidanceController userGuidanceController = UserGuidanceController();

  late OpenworldGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  late Timer _timer;
  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;

  late THREE.Clock clock;

  double dpr = 1.0;

  bool verbose = false;
  bool disposed = false;

  late THREE.Object3D object;

  late THREE.Texture texture;

  late THREE.WebGLMultisampleRenderTarget renderTarget;

  dynamic? sourceTexture;

  bool loaded = false;

  late THREE.Object3D model;

  static GlobalKey<DomLikeListenableState> _globalKey =
  GlobalKey<DomLikeListenableState>();

  OPENWORLD.VirtualJoystick? _joystick;
  int pointerdowntick = -1;

  var prevlocalx = 0.0;
  var prevlocaly = 0.0;
  var prevlocalz = 0.0;

  late VolumetricFire _fire;

  List<CLIENT.Player> players = [];
  List<CLIENT.Player> players_removed = [];

  late Group _shofar;
  late THREE.Object3D _shofar2;
  late THREE.Object3D _guide;

  late THREE.SpotLight _lightshofar;
  late THREE.SpotLight _light;

  late Group _priest;
  late Group _horse;
  bool horseriding = false; // This is your own horse
  late audioplayers.AudioPlayer horseridingclop;
  bool horseridingcloploaded = false;
  var horsespeed = 20.0 / 4; //25.0/4;
  var defaultspeed = 8.0 / 4; //2m/s

  late Group _cow;

  var _cowtick = -1;

  bool _canfly = false;

  late THREE.Object3D roomB;
  late THREE.Object3D roomC;
  late THREE.Object3D roomOlives;
  late THREE.Object3D roomSouth;
  late THREE.Object3D roomWest;
  late THREE.Object3D roomNorth;

  var poll = 1000; // How often you poll the server
  var msgs = [];
  var whos = [];
  var max_message = 5; // How many messages you show
  var num_players = 0;
  var msglines = [];

  late CLIENT.Session _session;
  String prompttext = "";
  bool showdisconnect = false;

  var removed_horn = false;

  Group _hotload = Group();

  String roomname = "";

  int actoroffset = 38;

  bool mapshow = false;
  double mapx = -1;
  double mapy = -1;
  late String mapfile;
  late int mapwidth;
  late int mapheight;

  bool hasprayer = false;
  bool priestblessing = false;

  bool hidewidgets = false; // useful if want to do screenshots without controls etc showing
  bool showfps = false; // show frames per second
  int fps = -1;
  int framedelay = 40;

  double menuposx = -1;
  double menuposy = -1;
  late THREE.Object3D menuobj;
  List menuitems = [];
  double defaultcameraoffset = 0.15; //35;
  double horsecameraoffset = 0.15 + 0.2 * 0.5;

  double convscale = 0.0025 / 0.006;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = OpenworldGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    print("begin initialize");
    await three3dRender.initialize(options: _options);

    setState(() {});

    // TODO web wait dom ok!!!
    // Future.delayed(const Duration(milliseconds: 100), () async {
    Timer(Duration(milliseconds: 100), () async {
      print("begin prepare context");
      // try {
      await three3dRender.prepareContext();
      // } on Exception catch (exception) {
      //   print('never reached');
//
      //   ... // only executed if error is of type Exception
      //} catch (error) {
      //  ... // executed for errors of all types other than Exception
      //print('errr!');
      //}

      print("done prepare context");

      initScene();
    });
  }

  initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

    print("screen" + screenSize!.width.toString()+" dpr"+dpr.toString());
    initPlatformState();
  }


  @override
  void reassemble() {
    super.reassemble();
    print("hotload");
    hotload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //  title: Text('voor'), //widget.fileName),
      // ),
      body:
      DomLikeListenable(
        key: _globalKey,
        builder: (BuildContext context) {
          initSize(context);
          return _build(context);
        },
      ),
    );
  }

  Widget _build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    //print("width"+width.toString());
    return
      UserGuidance(
          controller: userGuidanceController,
          opacity: 0.5,
          tipBuilder: (context, data) {
            if (data != null) {
              return TipWidget(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250.0),
                    child: Text(
                        "${data.tag}", style: TextStyle(color: Colors.black))),
                data: data,
              );
            }

            return null;
          },

          child:
          Scaffold(
            // resizeToAvoidBottomInset: true,

              body: Container(
                child: Stack(
                  children: [
                    //  Text("hi"),
                    Container(
                        child: loaded ? Container(
                            width: width,
                            height: height,
                            color: Colors.black,
                            child: Builder(builder: (BuildContext context) {
                              if (kIsWeb) {
                                return three3dRender.isInitialized
                                    ? HtmlElementView(
                                    viewType: three3dRender.textureId!
                                        .toString())
                                    : Container();
                              } else {
                                return three3dRender.isInitialized
                                    ?
                                Texture(textureId: three3dRender.textureId!)

                                    : Container();
                              }
                            })) :
                        Stack(
                            children: [
                              Center(child: Image.asset(
                                "icons/ark2.jpg", fit: BoxFit.cover,)),
                              //house2.jpg"),


                              Center(child: Container(

                                child: Center(child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          Center(child: SizedBox(width: 400,
                                              child: Container(
                                                  padding: EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors
                                                              .transparent),
                                                      //color is transparent so that it does not blend with the actual color specified
                                                      borderRadius: const BorderRadius
                                                          .all(
                                                          const Radius.circular(
                                                              10.0)),
                                                      color: Colors
                                                          .black //.withOpacity(0.2) // Specifies the background color and the opacity
                                                  ),
                                                  child: Row(
                                                      children: [
                                                        Text(gamename
                                                            //Welcome to Second Temple.\n"

                                                            //  "Its 72AD before destruction of jeruaslem by the romans.\n"
                                                            //  "Can you find the ark before this great calamity?"
                                                            ,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight: FontWeight
                                                                    .bold)),
                                                        Text("  is",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .white)),
                                                        SizedBox(width: 25),
                                                        WidgetAnimator(
                                                          //    atRestEffect: WidgetRestingEffects.pulse(), //WidgetRestingEffects.swing(),
                                                            atRestEffect: WidgetRestingEffects
                                                                .size(),
                                                            //WidgetRestingEffects.swing(),
                                                            //  incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(),

                                                            child: Text(
                                                                "Loading"
                                                                ,
                                                                textAlign: TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                    fontSize: 20,
                                                                    color: Colors
                                                                        .yellow,
                                                                    fontWeight: FontWeight
                                                                        .bold)))
                                                      ])))),
                                          SizedBox(height: 15),

                                        ]
                                    )
                                )),
                              )

                              )
                            ])
                    ),
                    menuposx >= 0 ? Positioned(
                        top: menuposy,
                        left: menuposx,

                        child: Column(
                            children: [
                              for (var item in menuitems)
                                item.containsKey('text') &&
                                    item.containsKey('command') ? TextButton(
                                  child: Text(item['text']),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Colors.black.withOpacity(0.5)),
                                  ),
                                  onPressed: () {
                                    menuobj.extra['touchtrigger'].triggermenu(
                                        item['command']);
                                  },
                                ) : item.containsKey('text') ||
                                    item.containsKey('iconpath')
                                    ? // when just text
                                Row(children: [
                                  item.containsKey('text')
                                      ? Text(item['text'])
                                      : SizedBox.shrink(),
                                  item.containsKey('iconpath') ? Image.asset(
                                    item['iconpath'],
                                    width: 50,
                                  ) : SizedBox.shrink()
                                ])
                                    :
                                IconButton(
                                  tooltip: item['tooltip'] ?? '',
                                  iconSize: 20,
                                  icon: item['icon'],
                                  //const Icon(menuicon),//Icons.get_app),
                                  style: IconButton.styleFrom(
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(5),
                                    backgroundColor: Colors.green.withOpacity(
                                        0.4), // <-- Button color
                                    foregroundColor: Colors
                                        .white, // <-- Splash color
                                  ),
                                  onPressed: () {
                                    print('get it' +
                                        item.toString()); //['command']);
                                    if (item.containsKey('command')) {
                                      menuobj.extra['touchtrigger'].triggermenu(
                                          item['command']);
                                    } else {
                                      menuobj.extra['touchtrigger'].triggermenu(
                                          null);
                                    }
                                  },
                                ),


                            ]
                        )

                    ) : SizedBox.shrink(),
                    loaded && !hidewidgets && mapshow && mapx != -1
                        ? Stack(children: [
                      WidgetZoom(
                          heroAnimationTag: 'tag',
                          zoomWidget: Image.asset(
                              mapfile, //'assets/maps/map.jpg',
                              fit: BoxFit.scaleDown,
                              height:
                              1 * MediaQuery
                                  .of(context)
                                  .size
                                  .height)),
                      Positioned(
                        //1.4
                          left: mapx *
                              (1 *
                                  mapwidth *
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height) /
                              mapheight -
                              40,
                          top: mapy *
                              (1 * MediaQuery
                                  .of(context)
                                  .size
                                  .height) -
                              40,
                          child: Transform(
                            alignment: FractionalOffset.center,
                            transform: Matrix4.rotationZ(
                              THREE.MathUtils.degToRad(OPENWORLD.Camera.turn)
                                  .toDouble(),
                            ), child: Image.asset('assets/maps/marker.png',
                              height:
                              80),
                          ))
                    ])
                        : SizedBox.shrink(),

                    !hidewidgets ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /* hasloadedimage? Image.memory(
                      tryimage,
                     // width: 600.0,
                    //  height: 240.0,
                     // fit: BoxFit.cover,
                    ):SizedBox.shrink(),*/
                          Stack(children: [
                            Align(alignment: Alignment.bottomLeft,
                                child: Container(
                                    color: Colors.black.withOpacity(0.1),
                                    margin: EdgeInsets.only(top: 7),
                                    child: Padding(padding: EdgeInsets.only(
                                        top: 0, right: 5, bottom: 5, left: 7),
                                        child: Text(roomname)))),

                            // Place widget 1/3 middle of screen for swipe guidance
                            Column(
                                children: [
                                  SizedBox(height: MediaQuery
                                      .of(context)
                                      .size
                                      .height / 3),
                                  Row(mainAxisAlignment: MainAxisAlignment
                                      .start,
                                      children: [

                                        SizedBox(width: MediaQuery
                                            .of(context)
                                            .size
                                            .width / 3),
                                        UserGuildanceAnchor(
                                            step: 7,
                                            tag: (OPENWORLD.System.isDesktop()
                                                ? ("←  → Key to slide left & right\n"+
                                                "↑ Key forward  ↓ back  \n"):
                                            ("←Swipe screen left to turn left\n"+
                                                "Swipe right to turn right→ \n"))+
                                                "↑ Swipe up to look up \n"
                                                "↓ Swipe down to look down ",
                                            child: Container(width: 10,
                                                height: 10) //,color:Colors.black)
                                        )
                                      ])
                                ]),

                            showfps ? Text(" FPS:" + fps.toString(),
                                style: TextStyle(fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)) : SizedBox
                                .shrink(),
                            !OPENWORLD.System.isDesktop() && loaded
                                ? Container(
                              //   margin:EdgeInsets.only(top:30),
                                child: UserGuildanceAnchor(
                                    step: 1,
                                    tag: "Move up for going forward.\n"
                                        "Move  down to go backwards\n"
                                        "Move left/right to turn left/right",
                                    child: Joystick(
                                      base: JoystickBase(
                                        decoration: JoystickBaseDecoration(
                                          color: Colors.transparent,
                                          drawOuterCircle: false,
                                        ),
                                        arrowsDecoration: JoystickArrowsDecoration(
                                            color: Colors.blue,
                                            enableAnimation: false),
                                      ),
                                      listener: (details) {
                                        // print("oo"+details.x.toString()+" "+details.y.toString());
                                        if (this.loaded)
                                          this
                                              ._joystick
                                              ?.onStickChange(
                                              details.x, details.y);
                                      },

                                      onStickDragEnd: () {
                                        if (this.loaded) this._joystick
                                            ?.onStickUp();
                                        //this._joystick.onStickDown();
                                      },
                                    )))
                                : SizedBox.shrink(),

                          ]),

                          Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                loaded ? Container(
                                    width: 500,

                                    decoration: BoxDecoration(
                                      // border: Border.all(color: Colors.blueAccent)
                                    ),
                                    child: Row(
                                        children: [
                                          Spacer(),

                                          hasprayer
                                              ? IconButton(
                                            tooltip: "Say a prayer",
                                            icon: Image.asset(
                                                'assets/textures/torah.png',
                                                width: 40, height: 40),
                                            //     iconSize: 20,
                                            onPressed: () {
                                              prayer();
                                            },
                                          )
                                              : SizedBox.shrink(),
                                          priestblessing ? IconButton(
                                            tooltip: "Priest blessing",
                                            icon: Image.asset(
                                                'icons/blessing.png',

                                                width: 20, height: 20),
                                            //     iconSize: 20,
                                            onPressed: () {
                                              // userGuidanceController.show();
                                              Fluttertoast.showToast(
                                                  msg: "The priest has blessed you",
                                                  toastLength: Toast
                                                      .LENGTH_LONG);
                                            },
                                            style: IconButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(5),
                                              backgroundColor: Colors.black
                                                  .withOpacity(0.2),
                                              // <-- Button color
                                              foregroundColor: Colors
                                                  .white, // <-- Splash color
                                            ),
                                          ) : SizedBox.shrink(),
                                          (horseriding) &&
                                              !OPENWORLD.You.immobile
                                              ? IconButton(
                                            tooltip: horseriding
                                                ? "Dismount"
                                                : "Call horse",
                                            icon: Image.asset(
                                                'icons/horse.png',
                                                width: 40, height: 40),
                                            iconSize: 20,
                                            style: IconButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(0),
                                              backgroundColor: Colors.black
                                                  .withOpacity(0.2),
                                              // <-- Button color
                                              foregroundColor: Colors
                                                  .white, // <-- Splash color
                                            ),
                                            color: Colors.white,
                                            onPressed: () {
                                              dismount();
                                            },
                                          )
                                              : SizedBox.shrink(),

                                          UserGuildanceAnchor(
                                              step: 5,
                                              tag: "Guide to tell you about this place",
                                              child: IconButton(
                                                tooltip: "Call a guide",
                                                icon: Image.asset(
                                                    'icons/guide.png',

                                                    width: 20, height: 20),
                                                //     iconSize: 20,
                                                onPressed: () {
                                                  callGuide();
                                                },
                                                style: IconButton.styleFrom(
                                                  shape: CircleBorder(),
                                                  padding: EdgeInsets.all(5),
                                                  backgroundColor: Colors.black
                                                      .withOpacity(0.2),
                                                  // <-- Button color
                                                  foregroundColor: Colors
                                                      .white, // <-- Splash color
                                                ),
                                              )),
                                          loaded && !kIsWeb &&
                                              CLIENT.Connection.connect_state ==
                                                  CLIENT.Connection.CS_NONE
                                              ? UserGuildanceAnchor(
                                              step: 4,
                                              tag: "Play online",
                                              child: IconButton(
                                                tooltip: "Connect to a game",
                                                iconSize: 20,
                                                icon: const Icon(Icons.link),
                                                style: IconButton.styleFrom(
                                                  shape: CircleBorder(),
                                                  padding: EdgeInsets.all(5),
                                                  backgroundColor: Colors.green
                                                      .withOpacity(0.4),
                                                  // <-- Button color
                                                  foregroundColor: Colors
                                                      .white, // <-- Splash color
                                                ),
                                                onPressed: () {
                                                  getName();
                                                },
                                              )) : SizedBox.shrink(),

                                          UserGuildanceAnchor(
                                              step: 3,
                                              tag: "Display map of where you are",
                                              child: IconButton(
                                                tooltip: "Show a map",
                                                iconSize: 20,
                                                icon: const Icon(
                                                    Icons.place_rounded),
                                                style: IconButton.styleFrom(
                                                  shape: CircleBorder(),
                                                  padding: EdgeInsets.all(5),
                                                  backgroundColor: Colors.black
                                                      .withOpacity(0.2),
                                                  // <-- Button color

                                                  foregroundColor: Colors
                                                      .white, // <-- Splash color
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    mapshow = !mapshow;
                                                  });
                                                },
                                              )),
                                          loaded &&
                                              CLIENT.Connection.connect_state ==
                                                  CLIENT.Connection
                                                      .CS_CONNECTED &&
                                              showdisconnect ? Row(children: [
                                            SizedBox(height: 30,
                                                child: VerticalDivider(
                                                    thickness: 2,
                                                    width: 10,
                                                    color: Colors.black
                                                        .withOpacity(0.3))),
                                            IconButton(
                                              alignment: Alignment.center,
                                              tooltip: "Whos On",
                                              //  icon: Icon(FontAwesomeIcons.peopleGroup),//Icons.people),
                                              icon: Icon(Icons.people),
                                              iconSize: 20,
                                              style: IconButton.styleFrom(
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(0),
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.2),
                                                // <-- Button color
                                                foregroundColor: Colors
                                                    .white, // <-- Splash color
                                              ),
                                              color: Colors.white,
                                              onPressed: () {
                                                CLIENT.You.actions["who"] =
                                                true;
                                              },
                                            ),
                                            IconButton(
                                              // alignment: Alignment.topRight,
                                              tooltip: "Speak",
                                              icon: Icon(
                                                  FontAwesomeIcons.bullhorn),
                                              //Icons.people),
                                              iconSize: 20,
                                              style: IconButton.styleFrom(
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(0),
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.2),
                                                // <-- Button color
                                                foregroundColor: Colors
                                                    .white, // <-- Splash color
                                              ),
                                              color: Colors.white,
                                              onPressed: () {
                                                msg();
                                              },
                                            ),
                                            IconButton(
                                              // alignment: Alignment.topRight,
                                              tooltip: "Wave",
                                              icon: Icon(Icons.waving_hand),
                                              iconSize: 20,
                                              style: IconButton.styleFrom(
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(0),
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.2),
                                                // <-- Button color
                                                foregroundColor: Colors
                                                    .white, // <-- Splash color
                                              ),
                                              color: Colors.white,
                                              onPressed: () {
                                                CLIENT.You.action = "wave";
                                              },
                                            ),
                                            loaded &&
                                                CLIENT.Connection
                                                    .connect_state ==
                                                    CLIENT.Connection
                                                        .CS_CONNECTED &&
                                                showdisconnect ? IconButton(
                                              tooltip: "Disconnect",
                                              iconSize: 25,
                                              icon: const Icon(Icons.link_off),
                                              style: IconButton.styleFrom(
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(5),
                                                backgroundColor: Colors.red
                                                    .withOpacity(0.4),
                                                // <-- Button color
                                                foregroundColor: Colors
                                                    .white, // <-- Splash color
                                              ),
                                              onPressed: () {
                                                print("disconnect");
                                                disconnect();
                                              },
                                            ) : SizedBox.shrink(),
                                            SizedBox(height: 30,
                                                child: VerticalDivider(
                                                    thickness: 2,
                                                    width: 10,
                                                    color: Colors.black
                                                        .withOpacity(0.3))),
                                            //  SizedBox(width:15),
                                          ]) : SizedBox.shrink(),
                                          IconButton(
                                            iconSize: 20,
                                            tooltip: "Settings",
                                            icon: const Icon(Icons.settings),
                                            style: IconButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(0),
                                              backgroundColor: Colors.black
                                                  .withOpacity(0.2),
                                              // <-- Button color
                                              foregroundColor: Colors
                                                  .white, // <-- Splash color
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                // loaded=true;
                                                _globalKey.currentState?.pause =
                                                true;
                                              });
                                              await settings(context);
                                            },
                                          ),
                                          IconButton(
                                            iconSize: 20,
                                            tooltip: "Settings",
                                            icon: const Icon(Icons.help),
                                            style: IconButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(0),
                                              backgroundColor: Colors.black
                                                  .withOpacity(0.2),
                                              // <-- Button color
                                              foregroundColor: Colors
                                                  .white, // <-- Splash color
                                            ),
                                            onPressed: () {
                                              help(context);
                                            },
                                          ),
                                          IconButton(
                                            // alignment: Alignment.topRight,
                                            tooltip: "Exit game",
                                            icon: Icon(Icons.close),
                                            iconSize: 20,
                                            style: IconButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(0),
                                              backgroundColor: Colors.black
                                                  .withOpacity(0.2),
                                              // <-- Button color
                                              foregroundColor: Colors
                                                  .white, // <-- Splash color
                                            ),
                                            color: Colors.white,
                                            onPressed: () {
                                              close();
                                            },
                                          ),
                                        ])) : SizedBox.shrink(),

                                CLIENT.Connection.connect_state ==
                                    CLIENT.Connection.CS_CONNECTED &&
                                    CLIENT.You.name != ""
                                    ? Align(alignment: Alignment.topRight,
                                    child: Container(
                                        width: 300,
                                        color: Colors.black.withOpacity(0.3),
                                        padding: EdgeInsets.only(left: 7,
                                            right: 7,
                                            top: 5),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Row(children: [
                                                Text("You are: "),
                                                Text(CLIENT.You.name,
                                                    style: TextStyle(
                                                        color: OPENWORLD
                                                            .ColorLib
                                                            .colorFromText(
                                                            CLIENT.You.name)))
                                              ]),
                                              Text(
                                                  "People on:" +
                                                      num_players.toString()),
                                              whos.length > 0
                                                  ? Text("Players on:")
                                                  : SizedBox.shrink(),
                                              for (var name in whos)
                                                Text(name,
                                                    style: TextStyle(
                                                        color: OPENWORLD
                                                            .ColorLib
                                                            .colorFromText(
                                                            name)))

                                            ])))
                                    : SizedBox.shrink(),
                                prompttext != "" ? Text(prompttext,
                                    style: TextStyle(fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)) : SizedBox
                                    .shrink(),
                                _canfly && !horseriding && loaded
                                    ? WidgetAnimator(
                                  //    atRestEffect: WidgetRestingEffects.pulse(), //WidgetRestingEffects.swing(),
                                    atRestEffect: WidgetRestingEffects.pulse(),
                                    //duration:Duration(seconds:1)),
                                    child: Column(children: [
                                      IconButton(
                                        icon: Image.asset('icons/arrow.png'),
                                        iconSize: 50,
                                        onPressed: () {
                                          flyup();
                                        },
                                      ),
                                      IconButton(
                                        icon: Image.asset('icons/wings.png'),
                                        iconSize: 50,
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: Transform.scale(
                                            scaleY: -1,
                                            child: Image.asset(
                                                'icons/arrow.png')),
                                        iconSize: 50,
                                        onPressed: () {
                                          flydown();
                                        },
                                      ),
                                    ]))
                                    : SizedBox.shrink(),
                                msglines.length > 0 ? Container(
                                    color: Colors.black.withOpacity(0.3),
                                    width: 300,
                                    padding: EdgeInsets.only(
                                        left: 7, right: 7, top: 5),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          for (var item in msglines)
                                            Row(children: [
                                              Text(item['msg'],
                                                  style: TextStyle(
                                                      color: (item['usename'] !=
                                                          "")
                                                          ? OPENWORLD.ColorLib
                                                          .colorFromText(
                                                          item['usename'])
                                                          : Colors.white)
                                              )
                                            ]
                                            )

                                        ])

                                ) : SizedBox.shrink(),


                              ])
                        ]) : SizedBox.shrink()
                  ],
                ),
              )));
  }

  render() {
    int _t = DateTime
        .now()
        .millisecondsSinceEpoch;


    final _gl = three3dRender.gl;

    renderer!.render(scene, camera);

    int _t1 = DateTime
        .now()
        .millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    _gl.flush();

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }


    var delta = clock.getDelta();
    if (delta > 0.2) {
      print("delta too long" + delta.toString() + " " + camera.far.toString());
    }
    if (this._joystick != null) this._joystick?.update(delta);

    OPENWORLD.Space.update(delta);
    OPENWORLD.Light
        .update(); // must be before space update otherwise night only will override hide
    OPENWORLD.BaseObject.update(delta);
    OPENWORLD.Texture.update(delta);

    if (prevlocalx != camera.position.x || prevlocalz != camera.position.z) {

      /*if (OPENWORLD.You.drag<1)
          OPENWORLD.You.drag*=1.1;
        else if (OPENWORLD.You.drag>1)
          OPENWORLD.You.drag=1;*/

      // Wall detection - if hit wall put player back to where they were
      // calculate objects intersecting the picking ray
      var distintersect = OPENWORLD.Space.distanceWall(
          prevlocalx, prevlocaly, prevlocalz);

      if (distintersect >= 0) {
        var dostop = distintersect >= 0 && distintersect < 0.4;
        if (dostop) {
          print("wall intersect");
          camera.position.x = prevlocalx;
          camera.position.z = prevlocalz;
        } else {

        }
      } else if (disposed == -2) {
        // what is this for?
        prevlocalx = -1;
      }

      // Increase speed if riding a horse
      var usespeed;
      if (horseriding)
        usespeed = horsespeed;
      else
        usespeed = defaultspeed;
      OPENWORLD.You.speed = usespeed;

      // Show pool objects based upon current camera position
      var worldpos = OPENWORLD.You.getWorldPos();
      OPENWORLD.Config.showPoolsObjects(worldpos.x, worldpos.y);


      if (horseriding) {
        if (OPENWORLD.You.indoors()) {
          // Get off the horse because indoors
          print("exit horse");
          horseriding = false;
          horseridingclop.stop();
          var worldpos = OPENWORLD.You.getWorldPos();

          var newhorsepos = OPENWORLD.Math.vectorMoveFoward(
              worldpos.x, worldpos.y, OPENWORLD.You.getMoveDir(),
              -1.5); // Move it back so isn't half in the temple
          OPENWORLD.Space.worldToLocalSurfaceObj(
              _horse, newhorsepos.x, newhorsepos.y, 0);
          OPENWORLD.Camera.cameraoffset = defaultcameraoffset;
          // if (OPENWORLD.You.indoors()) {
          OPENWORLD.Sound.play(path: 'sounds/horse.mp3', volume: 0.5);
          OPENWORLD.BaseObject.reenableDistanceTrigger(_horse);
        } else {
          // Move the horse you are riding on
          OPENWORLD.Camera.cameraoffset = horsecameraoffset; // 0.15;
          OPENWORLD.Space.worldToLocalSurfaceObj(
              _horse, worldpos.x, worldpos.y, 0);
          OPENWORLD.Space.objTurnLerp(_horse, OPENWORLD.Camera.turn, 0.5);
        }
      } // else
      OPENWORLD.You.update(); // To get move dir
    }
  }

  initRenderer() {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = THREE.WebGLRenderer(_options);
    // print("dpr"+dpr.toString()); 1.0
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);

    renderer!.shadowMap.enabled = true;

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({"format": THREE.RGBAFormat});
      renderTarget = THREE.WebGLMultisampleRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);

      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  /// Called whenever you hotload
  /// Useful if want to add 3D objects on the fly and see the objects appear almost instantly
  hotload() async
  {
    _hotload.clear();

    // Display the flaming brands
    var fireWidth = 2;
    var fireHeight = 4;
    var fireDepth = 2;
    var sliceSpacing = 0.5;

    Group brand = Group();
    var brandm = await OPENWORLD.Model.createModel(
        'assets/models/brand/brand.glb');


    brandm.scale.set(0.01, 0.01, 0.01);
    THREE.MeshStandardMaterial mat =
    THREE.MeshStandardMaterial(); //brand.children[0].material;
    //  mat.shininess=100;
    // mat.specular=THREE.Color(0xff0000);
    mat.emissive = THREE.Color(
        0x806c00); //665600); //4d4100);//665600);//);//ab9000);//c2a300);//d4b200);//FFD700);//444400);//222211);//444422);//ffff66);//00ff00);
    mat.metalness = 1;
    mat.roughness = 0.5;
    mat.needsUpdate = true;
    brandm.children[0].material = mat;
    brand.add(brandm);

    var brandblue = Group();
    brandblue.add(brandm.clone());

    var brandfire = new VolumetricFire(
        fireWidth, fireHeight, fireDepth, sliceSpacing, camera);
    await brandfire.init();

    brandfire.mesh.scale.x = 0.04; //0.05;
    brandfire.mesh.scale.y = 0.04; //0.05;
    brandfire.mesh.scale.z = 0.04; //0.05;
    brandfire.mesh.position.y = 0.25; //33;

    brand.add(brandfire.mesh);

    OPENWORLD.Updateables.add(brandfire);

    var brandfireblue = new VolumetricFire(
        fireWidth, fireHeight, fireDepth, sliceSpacing, camera,
        color: THREE.Color(0x6666ff));
    await brandfireblue.init();

    brandfireblue.mesh.scale.x = 0.04; //0.05;
    brandfireblue.mesh.scale.y = 0.04; //0.05;
    brandfireblue.mesh.scale.z = 0.04; //0.05;
    brandfireblue.mesh.position.y = 0.25; //33;

    brandblue.add(brandfireblue.mesh);
    OPENWORLD.Updateables.add(brandfireblue);


    var lightdistance = 3;

    const brandposs = [

      [10.07, 4.13, 0.0, 5],
      [9.60, -2.12, 0.0, 4],
      [-2.64, 12.40, 0.0, 15],
      [1.24, -6.65, 0.0, 15],
      [2.02, -13.50, 0.0, 15],
      [10.02, 1.50, 0.0, 3],
      [12.63, 1.63, 0.0, 10],
      [15.17, 6.79, 0.0, 10], //14.97, 1.57,0.0,5],
      [13.60, 4.50, 0.0, 10], //17.33, 1.38,0.0,5],
      [16.56, 8.88, 0.0, 15], //19.73, 1.20,0.0,5],
      [19.37, 10.48, 0, 15], //22.17, 1.18,0.0,5]
      [24.96, 11.27, 0, 15],
      [30.61, 9.68, 0, 15],
      [34.00, 2.70, 0, 15],
      [6.45, -6.80, 0, 6],
      [5.63, -13.04, 0, 7],
      [5.30, -15.74, 0, 5],
      [3.53, -15.95, 0, 5],
      [-3.23, -3.20, 0, 5],
      [6.10, 15.56, 0, 5],
      [2.61, 14.69, 0, 5],
      [2.47, 12.43, 0, 5],
      [-0.59, 18.11, 0, 5],
      [-6.09, 18.19, 0, 5],
      //[-7.01, 17.44,0,10],//-7.56, 17.03,0,10],//-7.29, 17.18,0,10]
      // [-7.01, 17.29,0,10],
      [-7.1, 18.25, 0, 15],
      [-14.59, 17.04, 0, 10],
      [-11.47, 12.18, 0, 10],
      [-9.42, 4.57, 0, 10],
      [-6.63, -10.68, 0, 10],
      [-5.54, -2.18, 0, 10],
      [-13.32, -4.10, 0, 10],
      [-6.29, -13.21, 0, 10],
      [-5.36, -20.24, 0, 10],
      [-7.87, -9.17, 0, 10], // west wall market
      [3.50, -11.43, 0, 10], //2.70, -11.56,0,10]   // stoa market
      [1.44, -11.44, 0, 10]
    ];

    // var brandpos=OPENWORLD.Config.getPositionByName('brand');//_config['objectpositions'][0]['positions'];
    for (var brandpos in brandposs) {
      if (brandpos[0] < 9.7) {
        var brandii = brand.clone(true);
        // brandii = makeBrand(brandii, true);

        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            brandii,
            brandpos[0].toDouble(),
            brandpos[1].toDouble(),
            brandpos[2].toDouble(),
            brandpos[3]
                .toDouble()); //9.60, -2.12, 0.0, 4); //7.0, 2.0, 0.0,2); //3.7);
        _hotload.add(brandii);
        var brandlightii = makeBrandLight(true, false);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            brandlightii, brandpos[0].toDouble(),
            brandpos[1].toDouble(),
            brandpos[2].toDouble(), lightdistance); //7.0, 2.0, 0.0,2); //3.7);
        _hotload.add(brandlightii);
      } else {
        // those to the east lead to the ark
        var brandii = brandblue.clone(true);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            brandii,
            brandpos[0].toDouble(),
            brandpos[1].toDouble(),
            brandpos[2].toDouble(),
            brandpos[3]
                .toDouble()); //9.60, -2.12, 0.0, 4); //7.0, 2.0, 0.0,2); //3.7);
        _hotload.add(brandii);
        var brandlightii = makeBrandLight(true, true);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            brandlightii, brandpos[0].toDouble(),
            brandpos[1].toDouble(),
            brandpos[2].toDouble(), lightdistance); //7.0, 2.0, 0.0,2); //3.7);
        _hotload.add(brandlightii);
      }
    }

    // brands that shine even during the day
    var brandposnohide = [
      [4.80, -14.74, 0, 5] // pool
    ];
    for (var brandpos in brandposnohide) {
      var brandii = brand.clone(true);
      // brandii = makeBrand(brandii, false);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          brandii,
          brandpos[0].toDouble(),
          brandpos[1].toDouble(),
          brandpos[2].toDouble(),
          brandpos[3]
              .toDouble());
      _hotload.add(brandii);
      var brandlightii = makeBrandLight(false, false);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          brandlightii, brandpos[0].toDouble(),
          brandpos[1].toDouble(),
          brandpos[2].toDouble(), lightdistance);
      _hotload.add(brandlightii);
    }

    // All the grass
    const grassposs = [
      [13.61, 1.54, 0.0, 4],
      [14.41, 1.82, 0.0, 4],
      [16.67, 1.33, 0.0, 4],
      [14.60, 5.79, 0.0, 4],
      [14.20, 5.41, 0.0, 4],
      [12.82, 4.86, 0.0, 4],
      [13.79, 6.45, 0.0, 4],
      [15.68, 9.29, 0.0, 4],
      [15.08, 8.18, 0.0, 4],
      [13.24, 3.52, 0.0, 4],
      [13.49, 4.17, 0.0, 4],
      [14.66, 6.11, 0.0, 4],
      [14.15, 6.68, 0.0, 4],
      [12.75, 3.95, 0.0, 4],
      [15.02, 6.93, 0.0, 4],
      [15.35, 8.52, 0.0, 4],
      [17.31, 11.22, 0.0, 4],
      [18.46, 10.53, 0.0, 4],
      [22.04, 11.28, 0.0, 4],
      [29.58, 11.29, 0.0, 4],
      [0.05, -22.22, 0.0, 4],
      [4.34, -19.63, 0.0, 4],
      [3.96, 14.31, 0.0, 4],
      [1.90, 15.76, 0.0, 4],
      [2.60, 14.38, 0.0, 4],
      [1.92, 14.80, 0.0, 4],
      [1.75, 19.02, 0.0, 4],
      [9.22, 21.92, 0.0, 4],
      [4.15, 18.99, 0.0, 4],
      [5.36, 20.48, 0, 4],
      [2.05, 16.49, 0, 4],
      [-12.93, 17.04, 0, 4],
      [-14.85, 11.77, 0, 4],
      [-14.82, -1.44, 0, 4],
      [-11.18, 0.39, 0, 4],
      [-8.19, -4.26, 0, 4],
      [-13.15, -4.87, 0, 4],
      [-10.89, -8.31, 0, 4],
      [-12.73, -17.92, 0, 4],
      [-8.14, -20.54, 0, 4],
      [-6.70, -18.27, 0, 4],
      [-4.75, -18.80, 0, 4],
      [-12.09, -10.13, 0, 4],
      [-10.88, -12.01, 0, 4],
      [-12.84, -13.62, 0, 4],
      [-12.36, -15.77, 0, 4],
      [-9.81, -6.51, 0, 4],
      [-13.84, -16.18, 0, 4],
      [-8.11, -19.25, 0, 4],
      [-4.45, -20.57, 0, 4],
      [35.47, -2.77, 0, 4],
      [29.91, 0.28, 0, 4],
      [-4.82, -16.17, 0, 4],
      [7.12, 30.71, 0, 4],
      [60.90, 4.24, 0, 4],
      [60.40, 5.83, 0, 4],
      [58.55, 4.95, 0, 4],
      [59.10, 0.10, 0, 4],
      [60.45, 7.48, 0, 4],
      [61.13, 9.38, 0, 4],
      [60.32, 12.04, 0, 4],
      [58.71, 9.24, 0, 4],
      [62.58, 0.67, 0, 4],
      [61.29, -1.26, 0, 4],
      [61.37, 0.18, 0, 4],
      [60.09, 1.44, 0, 4],
      [58.80, 1.97, 0, 4],
      [60.09, -2.68, 0, 4],
      [59.29, 2.87, 0, 4],
      [60.39, 1.61, 0, 4],
      [59.54, -0.12, 0, 4],
      [58.10, 0.35, 0, 4]
    ];
    var grass = await OPENWORLD.Sprite.loadSprite(
        'assets/textures/grass.png', 0.1, 0.1);
    for (var tree in grassposs) {
      var cyprusii = await OPENWORLD.Sprite.cloneSprite(grass);
      OPENWORLD.Space.worldToLocalSurfaceObj(cyprusii, tree[0].toDouble(),
          tree[1].toDouble(), tree[2].toDouble());
      _hotload.add(cyprusii);
    }

    // Display olive trees
    var oliveposs = [
      [39.09, 13.24, 0.0],
      [32.36, 6.43, 0.0],
      [37.52, 3.11, 0.0],
      [43.53, 1.19, 0.0],
      [34.67, -9.64, 0.0],
      [17.40, 9.60, 0.0],
      [22.90, 11.18, 0.0],
      [34.01, 1.99, 0.0],
      [34.66, -2.18, 0.0],
      [36.01, -6.34, 0.0],
      [37.68, -8.60, 0.0],
      [22.92, 2.21, 0.0],
      [25.97, 4.55, 0.0],
      [31.67, 0.51, 0.0],
      [57.36, -2.35, 0.0],
      [57.60, 0.27, 0.0],
      [57.59, 3.76, 0.0],
      [57.50, 6.57, 0.0],
      [57.48, 8.70, 0.0],
      [12.42, 7.53, 0.0],
      [13.06, -1.70, 0.0],
      [13.09, 14.87, 0.0],
      [12.04, 19.31, 0.0],
      [10.94, 23.09, 0.0],
      [12.44, -11.53, 0.0],
      [5.22, 14.34, 0.0],
      [6.18, 14.57, 0.0],
      [-22, 24, 0],
      [-20, 18, 0],
      [-20, 9, 0],
      [-16, 3, 0],
      [-15, 0, 0],
      [-14, -11, 0],
      [-12, -14, 0],
      [-11, -19, 0],
      [-12, -24, 0],
      [-9, -31, 0,],
      [-5, -28, 0],
      [-5, -31, 0],
      [-6, -33, 0],
      [-13.01, 11.49, 0],
      [-10.90, 8.04, 0],
      [-8.71, 1.32, 0],
      [-7.97, -2.18, 0],
      [-13.28, 4.51, 0],
      [-14.99, -4.94, 0],
      [-13.15, -4.87, 0],
      [-10.34, -10.06, 0],
      [-11.11, -14.56, 0],
      [-9.58, -21.77, 0],
      [-7.92, -14.78, 0],
      [-7.80, -16.67, 0],
      [-5.45, -21.69, 0],
      [-7.33, -24.15, 0],
      [-5.55, -22.64, 0],
      [-11.66, -19.63, 0],
      [-5.09, -14.93, 0],
      [29.64, 12.29, 0],
      [30.72, 10.90, 0],
      [31.57, 9.23, 0],
      [33.33, 6.54, 0],
      [35.32, -0.20, 0],
      [34.54, -1.03, 0],
      [3.15, -20.34, 0],
      [-8.45, -4.08, 0], //west wall market
      [-8.45, 21.14, 0],
      [9.00, 21.26, 0],
      [1.13, 23.46, 0],
      [-3.20, 34.08, 0],
      [-0.66, 23.06, 0],
      [62.51, 6.55, 0],
      [63.05, 2.20, 0],
      [62.08, -2.62, 0],
      [60.35, 11.71, 0]
    ];
    var olive = await OPENWORLD.Sprite.loadSprite(
        'assets/models/temple/olive.png', 0.6, 0.6);
    for (var tree in oliveposs) {
      var cyprusii = await OPENWORLD.Sprite.cloneSprite(olive);
      OPENWORLD.Space.worldToLocalSurfaceObj(
          cyprusii, tree[0].toDouble(), tree[1].toDouble(), tree[2].toDouble());

      // Only show trees if are within the room you're in
      if (OPENWORLD.Room.pointInRoom(roomOlives, tree[0], tree[1]))
        OPENWORLD.Room.addRoomObject(roomOlives, cyprusii);
      else if (OPENWORLD.Room.pointInRoom(roomSouth, tree[0], tree[1]))
        OPENWORLD.Room.addRoomObject(roomSouth, cyprusii);
      else if (OPENWORLD.Room.pointInRoom(roomWest, tree[0], tree[1]))
        OPENWORLD.Room.addRoomObject(roomWest, cyprusii);
      else if (OPENWORLD.Room.pointInRoom(roomNorth, tree[0], tree[1]))
        OPENWORLD.Room.addRoomObject(roomNorth, cyprusii);
      _hotload.add(cyprusii);
    }

    // Show cyprus trees
    var cyprusposs = [
      [24.11, -2.65, 0.0],
      [22.60, -1.50, 0.0], //3.42);
      [15.07, 12.25, 0.0], //3.42);
      [13.26, 5.99, 0.0], //3.42);
      [15.96, 7.95, 0.0],
      [14.24, 14.4, 0.0],
      [19.88, 14.49, 0.0],
      [29.14, 12.33, 0.0],
      [32.35, 12.57, 0.0],
      [35.22, 12.92, 0.0],
      [45.28, 13.84, 0.0],
      [51.85, 13.59, 0.0],
      [21.36, 3.58, 0.0],
      [28.52, -7.06, 0.0],
      [39.01, -10.20, 0.0],
      [46.42, -10.78, 0.0],
      [31.92, -19.04, 0.0],
      [27.57, -18.21, 0.0],
      [20.55, -16.89, 0.0],
      [15.43, -16.60, 0.0],
      [36.34, -2.96, 0.0],
      [36.97, -2.63, 0.0],
      [37.38, -2.11, 0.0],
      [37.61, -1.77, 0.0],
      [38.10, -1.23, 0.0],
      [44.50, 6.35, 0.0],
      [45.46, 13.54, 0.0],
      [25.96, -3.62, 0.0],
      [21.84, -7.77, 0.0],
      [20.95, -0.76, 0.0],
      [17.84, -1.09, 0.0],
      [32.62, -9.41, 0.0],
      [40.52, -10.46, 0.0],
      [43.12, -10.85, 0.0], //
      [46.67, -10.88, 0.0], //
      [49.71, -10.92, 0.0], //
      [54.48, -10.86, 0.0], //
      [57.69, -10.82, 0.0], //
      [57.55, -10.93, 0.0], //
      [57.74, -8.44, 0.0], //
      [57.71, -5.60, 0.0], //
      [57.61, -0.69, 0.0],
      [57.49, 6.09, 0.0],
      [57.50, 13.29, 0.0],
      [20.76, 11.96, 0.0],
      [33.72, 4.16, 0.0],
      [34.42, 4.52, 0.0],
      [29.63, 11.04, 0.0],
      [30.64, 12.25, 0.0],
      [27.13, 11.24, 0.0],
      [21.03, 11.30, 0.0],
      [31.66, 7.59, 0.0],
      [34.29, 0.27, 0.0],
      [35.09, -5.07, 0.0],
      [35.63, -4.90, 0.0],
      [37.06, -7.84, 0.0],
      [-21.92, 21.94, 0.0],
      [-23.70, 16.09, 0.0],
      [-17, 4, 0.0],
      [-13, 1, 0.0],
      [-14, -9, 0.0],
      [-15, -14, 0.0],
      [-12, -23, 0.0],
      [-13, -35, 0.0],
      [-9, -36, 0.0],
      [-4, -33, 0.0],
      [-14.21, 14.68, 0.0],
      [-15.77, 6.87, 0],
      [-11.41, -2.90, 0],
      [-12.69, -21.01, 0],
      [-9.31, -24.39, 0],
      [-15.23, -29.19, 0],
      [22.38, 12.67, 0],
      [25.30, 14.05, 0],
      [35.48, 2.45, 0],
      [-7.76, 12.79, 0], //near antonia fortress
      [-13.17, 25.85, 0],
      [4.26, 37.33, 0],
      [-8.78, 33.22, 0],
      [56.19, 17.50, 0],
      [57.40, 25.29, 0],
      [56.70, -14.61, 0],
      [56.11, -17.12, 0],
      [62.51, 3.00, 0],
      [60.97, 5.97, 0],
      // [3.75, 3.85, 0],
      [64.43, -2.47, 0],
      [57.79, 1.74, 0],
      [60.40, -6.04, 0],
      [62.34, -4.22, 0],
      [63.73, 9.77, 0],
      [63.60, 13.01, 0],
      [58.00, 11.60, 0],
      [64.15, 7.30, 0],
      [61.59, 13.41, 0],
      [56.37, 10.79, 0],
      [60.94, 1.35, 0],
      [43.36, -18.07, 0],
      [43.23, -23.91, 0],
      [43.09, -35.60, 0]
    ];
    var cyprus = await OPENWORLD.Sprite.loadSprite(
        'assets/models/temple/cyprus.png', 0.4, 1.4);
    for (var tree in cyprusposs) {
      var cyprusii = await OPENWORLD.Sprite.cloneSprite(cyprus);
      OPENWORLD.Space.worldToLocalSurfaceObj(cyprusii, tree[0].toDouble(),
          tree[1].toDouble(), tree[2].toDouble()); //24.11, -2.65,0.0); //3.42);

      // Only show trees if are within the room you're in
      if (OPENWORLD.Room.pointInRoom(roomOlives, tree[0], tree[1]))
        OPENWORLD.Room.addRoomObject(roomOlives, cyprusii);
      else if (OPENWORLD.Room.pointInRoom(roomSouth, tree[0], tree[1]))
        OPENWORLD.Room.addRoomObject(roomSouth, cyprusii);
      else if (OPENWORLD.Room.pointInRoom(roomWest, tree[0], tree[1]))
        OPENWORLD.Room.addRoomObject(roomWest, cyprusii);
      else if (OPENWORLD.Room.pointInRoom(roomNorth, tree[0], tree[1]))
        OPENWORLD.Room.addRoomObject(roomNorth, cyprusii);

      _hotload.add(cyprusii);
    }

    // Show rocks
    var rock = await OPENWORLD.Model.createModel('assets/models/rock.glb');
    _hotload.add(rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        rock, 60.49, 1.21, 0.0, 7); // 3.2,2.5, 0.0);
    rock.scale.set(0.011, 0.011, 0.011);

    var rockposs = [
      [61.68, 1.94, 7],
      [62.61, 4.65, 7],
      [61.39, 10.91, 7],
      [62.52, 5.04, 7],
      [62.93, -1.32, 7],
      [64.48, 1.81, 7],
      [59.40, -3.63, 7],
      [58.81, -3.02, 7],
      [63.68, -1.64, 7],
    ];
    for (var tree in rockposs) {
      var cyprusii = rock.clone();
      var fct = 0.011 * 2 * OPENWORLD.Math.random() + 0.002;
      cyprusii.scale.set(fct, fct, fct);
      OPENWORLD.Space.objTurn(cyprusii, OPENWORLD.Math.random() * 360);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cyprusii,
          tree[0].toDouble(),
          tree[1].toDouble(),
          -0.2 * OPENWORLD.Math.random(),
          tree[2].toDouble()); //24.11, -2.65,0.0); //3.42);
      _hotload.add(cyprusii);
    }
  }

  // Display text on a model eg the minorah
  addMsgToObj(obj, msg, {scale: 0.3, z: 20}) {
    OPENWORLD.Mob.setText(obj, msg, textcolor: Colors.blue,
        scale: scale,
        z: z,
        backgroundopacity: 0); //, fontfamily: "Roboto");
  }

  help(BuildContext context) {
    showDialog(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.5),
                titlePadding: EdgeInsets.only(left: 25, right: 25),
                contentPadding: EdgeInsets.only(left: 25, right: 25),
                actionsPadding: EdgeInsets.only(left: 25, right: 25),
                title: const Text('Info', style: TextStyle(fontSize: 22)),
                content: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //crossAxisAlignment:CrossAxisAlignment.

                        children: [

                          // SizedBox(height:10),
                          Text(gamename, style: TextStyle(fontSize: 22)),
                          //fontWeight:FontWeight.bold,
                          Text("Find the ark and save Israel!",
                              style: TextStyle(fontSize: 15)),
                          SizedBox(height: 10),
                          GestureDetector(
                              onTap: () {
                                launchUrl(Uri.parse(
                                    "https://forthtemple.com/arkcover/"));
                              },
                              child:
                              Column(children: [Image.asset(
                                'icons/forthtemple.png',
                                //height: 240
                              ),
                                SizedBox(height: 25),
                                Text("Forth Temple Ltd",
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold)),
                                Text("All Rights Reserved",
                                    style: TextStyle(fontSize: 17.0)),
                              ])),
                          // Divider(color: Colors.black),
                          SizedBox(height: 55),


                        ])
                ),
                actions: <Widget>[

                  TextButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),

                ],
              );
            }
        );
      },
    );
  }


  settings(BuildContext context) {
    bool soundon = !OPENWORLD.Sound.mute;
    bool musicon = !OPENWORLD.Musics.mute;
    TextEditingController _textFieldController = TextEditingController();
    bool reset = false;
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.5),
                title: const Text('Settings'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Row(
                          children: [
                            Checkbox(

                              value: soundon,
                              onChanged: (value) {
                                setState(() {
                                  soundon = value!;
                                });
                              },
                            ),
                            Text('Sound On')]),
                      Row(
                          children: [
                            Checkbox(
                              // tristate: true,
                              value: musicon,
                              onChanged: (value) {
                                setState(() {
                                  musicon = value!;
                                });
                              },
                            ),
                            Text('Music On')]),
                      Row(
                          children: [
                            Checkbox(
                              value: reset,
                              onChanged: (value) {
                                setState(() {
                                  reset = value!;
                                });
                              },
                            ),
                            Text('Reset Game')]),
                      kIsWeb ? SizedBox(width: 300, child: TextField(
                        autofocus: true,
                        controller: _textFieldController,
                        decoration: InputDecoration(hintText: "Coords"),
                      )) : SizedBox.shrink()
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      OPENWORLD.Persistence.set("mute", !soundon);
                      OPENWORLD.Sound.setMute(!soundon); //mute=!soundon;
                      OPENWORLD.Persistence.set("musicmute", !musicon);
                      OPENWORLD.Musics.setMute(!musicon);
                      OPENWORLD.Room.mute(!soundon);
                      if (_textFieldController.text.contains(",")) {
                        var pos = _textFieldController.text.split(",");
                        OPENWORLD.Space.worldToLocalSurfaceObj(
                            camera, double.parse(pos[0]), double.parse(pos[1]),
                            OPENWORLD.Camera.cameraoffset);
                      }

                      Navigator.of(context).pop();
                      if (reset) {
                        OPENWORLD.Persistence.reset();
                        close();
                      }
                    },
                  ),

                ],
              );
            }
        );
      },
    );
  }

  // General prompt dialog
  promptDialog(title, body, initvalue) async {
    TextEditingController _textFieldController = TextEditingController();
    _textFieldController.text = initvalue;
    return showDialog(

      context: context,
      //  barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(left: 25, right: 25),
          contentPadding: EdgeInsets.only(left: 25, right: 25),
          actionsPadding: EdgeInsets.only(left: 25, right: 25),
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.black.withOpacity(0.5),

          title: Text(title, style: TextStyle(fontSize: 20)),
          //'Player Name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                //'To play '+gamename+' online enter your players name',
                Text(body, style: TextStyle(fontSize: 15)),
                TextField(
                  autofocus: true,
                  controller: _textFieldController,
                ),

              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(_textFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to chat in multiplayer
  chatDialog(title, body, initvalue) async {
    TextEditingController _textFieldController = TextEditingController();
    _textFieldController.text = initvalue;
    return showDialog(

      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.bottomRight,

          titlePadding: EdgeInsets.only(left: 25, right: 25),
          contentPadding: EdgeInsets.only(left: 25, right: 25),
          actionsPadding: EdgeInsets.only(left: 25, right: 25),
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.black.withOpacity(0.5),

          // title: Text(title, style:TextStyle(fontSize: 20)),//'Player Name'),
          content:
          SizedBox(width: 400, height: 100, child: Row(
            children: [
              //'To play '+gamename+' online enter your players name',
              // Text(body, style: TextStyle(fontSize: 15)),
              SizedBox(width: 300, child: TextField(
                autofocus: true,
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "Your message"),
              )),
              IconButton(
                // alignment: Alignment.topRight,
                icon: Icon(Icons.cancel),
                //Icons.people),
                iconSize: 20,
                style: IconButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(0),
                  backgroundColor: Colors.black.withOpacity(0.2),
                  // <-- Button color
                  foregroundColor: Colors.white, // <-- Splash color
                ),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                // alignment: Alignment.topRight,
                //    tooltip:"Speak",
                icon: Icon(Icons.send),
                //Icons.people),
                iconSize: 20,
                style: IconButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(0),
                  backgroundColor: Colors.black.withOpacity(0.2),
                  // <-- Button color
                  foregroundColor: Colors.white, // <-- Splash color
                ),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop(_textFieldController.text);
                },
              ),


            ],
          )),

        );
      },
    );
  }

  // Set default size of actor
  setActorSize(actor) {
    actor.scale.set(0.0025, 0.0025, 0.0025);
  }

  // Set actor chatter with default settings
  setActorChatter(actor, chatter) {
    OPENWORLD.Mob.setChatter(
        actor, chatter, start: false, z: 100, scale: 0.3, width: 400);

    OPENWORLD.BaseObject.setDistanceTrigger(actor, dist: 1.0);
    actor.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Space.faceObjectAlways(actor, camera);
        OPENWORLD.Mob.startChatter(actor);
      } else {
        OPENWORLD.Mob.pauseChatter(actor);
        OPENWORLD.Mob.clearText(actor);
        OPENWORLD.Space.faceObjectAlwaysRemove(actor);
        OPENWORLD.Space.objTurnLerp(actor, OPENWORLD.Mob.getOrigTurn(actor), 1);
      }
    });
  }

  /// Create [num] citizens at position [x],[y] being a random [dist] from that point. If [guard] then uses a different skin
  /// Can set citizen [chatter] which all citizens will get
  createCitizens(actorcopy, x, y, dist, num, {guards: false, chatter}) async {
    for (var i = 0; i < num; i++) {
      var citizen =
      await OPENWORLD.Actor.copyActor(actorcopy, randomduration: 0.1);
      var filename;
      if (!guards) {
        if (OPENWORLD.Math.random() < 0.5) {
          var which = OPENWORLD.Math.randInt(5);
          if (which == 0)
            filename = "bodyc.png";
          else
            filename = "bodyc" + (which + 1).toString() + ".png";
        } else {
          var which = OPENWORLD.Math.randInt(3);
          if (which == 0)
            filename = "bodycf.png";
          else
            filename = "bodycf" + (which + 1).toString() + ".png";
        }
        await OPENWORLD.Model.setTexture(
            citizen, "assets/actors/citizen/" + filename);
      } else {
        var which = OPENWORLD.Math.randInt(3);
        if (which == 0)
          filename = "bodys.png";
        else
          filename = "bodys" + (which + 1).toString() + ".png";
        await OPENWORLD.Model.setTexture(
            citizen, "assets/actors/soldier/" + filename);
      }

      if (chatter != null)
        OPENWORLD.Mob.setChatter(
            actorcopy, chatter,
            z: 100,
            width: 300);
      setActorSize(citizen);
      OPENWORLD.Space.worldToLocalSurfaceObj(
          citizen, x.toDouble(), y.toDouble(), 0.0); //3.42);
      citizen.visible = false;
      scene.add(citizen);
      OPENWORLD.BaseObject.setDistanceTrigger(citizen,
          dist: 4, ignoreifhidden: false);
      citizen.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
        if (event.action) {
          OPENWORLD.Mob.randomwalk(citizen, dist, 0.15, 0.1,
              action: "walk",
              actionduration: 0.5,
              stopaction: "idle",
              reset: true,
              surfaceonly: true
          );
          citizen.visible = true;
        } else {
          citizen.visible = false;
        }
      });
    }
  }

  // Call the guide and give information about the room the player is in
  callGuide() {
    _guide.visible = true;
    OPENWORLD.Space.faceObjectAlways(_guide, camera);
    var offset;
    if (horseriding)
      offset = 0.2;
    else
      offset = 0;
    OPENWORLD.Mob.placeBeforeCamera(_guide, 0.4, time: 2, offset: offset,
        action: "walk", stopaction: "idle");
    new Timer(new Duration(milliseconds: (2 * 1000).floor()), () async {
      var speech;
      if (OPENWORLD.You.room != null &&
          OPENWORLD.You.room!.extra.containsKey('guide'))
        speech = OPENWORLD.You.room!.extra['guide'];
      else
        speech = ["Sorry, I don't have much information on this place"];

      OPENWORLD.Mob.setSpeech(_guide, speech, randwait: 0, z: 100, width: 300);
    });
  }

  var inprayer = false;

  // Say the prayer given by gabriel
  // If the player is at the perpetual fire and says the prayer then the ark will appear
  prayer() async
  {
    print("prayer");
    if (inprayer) {
      print("in prayer");
      return;
    } else {
      inprayer = true;
      print("in prayer true");
    }
    print("prayer2");

    OPENWORLD.Sound.play(path: 'sounds/pray5.mp3', volume: 1);

    if (priestblessing) {
      var dist = OPENWORLD.Space.getDistanceBetweenObjs(_fire.mesh, camera);
      var angletofire = OPENWORLD.Space.getAngleBetweensObjs(
          camera, _fire.mesh);
      var anglecamera = OPENWORLD.Space.getObjTurn(camera);
      var anglediff = (OPENWORLD.Math.angleDifference(angletofire, anglecamera)
          .abs());
      print("desti" + dist.toString() + " " + anglediff.toString() + " " +
          angletofire.toString() + " " + anglecamera.toString());
      if (dist < 2 && anglediff.abs() < 90) {
        Future.delayed(const Duration(milliseconds: 4 * 1000), () async {
          print(" priest bless");

          OPENWORLD.You.immobile = true;
          OPENWORLD.You.immobileturn = true;
          OPENWORLD.BaseObject.disableDistanceTrigger(_priest);
          OPENWORLD.Mob.clearText(_priest);

          var arkx = 3.23,
              arky = 0.51; //3.20, arky=0.46;  // 2.4, 1.41


          var ark = await OPENWORLD.Model.createModel(
              'assets/models/ark/ark.glb');
          OPENWORLD.Space.worldToLocalSurfaceObj(ark, arkx, arky, 1.0);

          // OPENWORLD.Space.objTurn(ark,90);
          ark.scale.set(0.1, 0.1, 0.1);
          THREE.MeshStandardMaterial mat = ark.children[0].material;

          mat.emissive = THREE.Color(
              0x665600);
          mat.metalness = 1;
          mat.roughness = 0.5;

          mat.needsUpdate = true;
          scene.add(ark);

          OPENWORLD.Space.worldToLocalSurfaceObjLerp(ark, arkx, arky, 0.0, 6);
          OPENWORLD.Space.faceObjectLerp(camera, ark, 1, delay: 6);

          var angels = await OPENWORLD.Sprite.loadSprite(
              'assets/textures/angels.png', 1, 0.6, ambient: false);
          OPENWORLD.Space.worldToLocalSurfaceObj(
              angels, arkx, arky, 2); //3.42);
          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
              angels, arkx, arky, 0.55, 8); //3.42);
          scene.add(angels);
          // Create another set of angles that can see from afar
          var angelsii = await OPENWORLD.Sprite.cloneSprite(
              angels); //'assets/textures/angels.png',1,0.6, ambient:false);
          OPENWORLD.Space.worldToLocalSurfaceObj(
              angelsii, arkx, arky, 7); //3.42);
          angelsii.scale.x *= 4;
          angelsii.scale.y *= 4;

          scene.add(angelsii);


          Flares flares = Flares();
          Group flaresobj = await flares.createFlares(
              "assets/models/ark/lensflare2.jpg",
              "assets/models/ark/lensflare0.png");
          OPENWORLD.Space.worldToLocalSurfaceObj(flaresobj, arkx, arky, 2);
          flaresobj.scale.set(0.1, 0.1, 0.1);
          scene.add(flaresobj);
          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
              flaresobj, arkx, arky, 0.2, 8);

          var light = new THREE.SpotLight(0xffffff); //SpotLight(0xFFA500);//
          light.intensity = 0; //0.5;
          light.penumbra = 1;
          light.angle = 0.2; //0.4;

          OPENWORLD.Space.worldToLocalSurfaceObj(
              light, arkx - 0.5, arky - 0.5, 3); //7.0); //3.29, 2.2

          scene.add(light);
          OPENWORLD.Light.intensityLerp(light, 1, 6);
          light.target = ark;

          if (_shofar.parent != scene) {
            scene.add(_shofar);
          }
          OPENWORLD.Mob.clearText(_shofar);
          OPENWORLD.Space.worldToLocalSurfaceObj(
              _shofar, 3.26, 1.03 + 1, 0); //3.2, 2.1, 0,3);

          OPENWORLD.Mob.moveTo(_shofar, [[3.26, 1.03, 0, 0.3]], action: "walk",
              stopaction: "idle",
              facedir: false);
          if (_shofar2.parent != scene)
            scene.add(_shofar2);
          OPENWORLD.Space.worldToLocalSurfaceObj(
              _shofar2, 3.33, -0.80 - 1, 0); //3.2, 2.1, 0,3);
          OPENWORLD.Mob.moveTo(
              _shofar2, [[3.33, -0.80, 0, 0.3]], action: "walk",
              stopaction: "idle",
              facedir: false);

          new Timer(new Duration(milliseconds: (8 * 1000).floor()), () async {
            OPENWORLD.Sound.play(path: 'sounds/angels.mp3', volume: 1);


            print("ark add");
            scene.remove(_cow);
            OPENWORLD.Room.clearRandomSound(roomB); // stop cow mooing
            Future.delayed(const Duration(milliseconds: 4000), () async {
              OPENWORLD.Space.removeObjFromHide(
                  _priest); // So no longer hidden when walk from temple
              OPENWORLD.Space.worldToLocalSurfaceObj(_priest, 1.91, 1.26, 0.0);

              _priest.visible = true;

              OPENWORLD.Mob.moveTo(
                  _priest, [[2.69, 0.85, 0, 0.2]], action: "walk",
                  stopaction: "idle"); //2.26, 1.25
              await OPENWORLD.Actor.playAction(_priest,
                  name: "armsup",
                  clampWhenFinished: true,
                  stopallactions: true,
                  delay: 4,
                  loopmode: THREE.LoopOnce);

              OPENWORLD.Mob.setSpeech(
                  _priest, ["Hallelujah",], z: 100, width: 300, delay: 7);

              animateShofar();

              Future.delayed(const Duration(milliseconds: 22 * 1000), () async {
                // In case player has moved in the 10 seconds
                OPENWORLD.Mob.placeBeforeCamera(
                    _shofar, 0.4, time: 1.5, action: "walk",
                    stopaction: "idle",
                    offset: -0.15);
                OPENWORLD.Space.faceObjectAlways(_shofar, camera);
                OPENWORLD.Mob.placeBeforeCamera(
                    _shofar2, 0.4, time: 2, action: "walk",
                    stopaction: "idle",
                    offset: -0.4);
                OPENWORLD.Space.faceObjectAlways(_shofar2, camera);
                OPENWORLD.Mob.placeBeforeCamera(
                    _priest, 0.3, time: 1,
                    action: "walk",
                    stopaction: "armsup");
                OPENWORLD.Space.faceObjectAlways(_priest, camera);
                OPENWORLD.Mob.setSpeech(
                    _priest, [
                  "Thank you",
                  "Now that the ark has returned",
                  "our enemies will be defeated",
                  "Israel thanks you",
                  "God blesses those that love Israel",
                  "God blesses those that help Israel",
                  "in its hour of need"
                ],
                    z: 90,
                    scale: 0.35,
                    width: 250);
                OPENWORLD.You.setImmobile(false, delay: 20);
                OPENWORLD.You.setImmobileTurn(false, delay: 10);

                // Have all the npcs that are chatting, chat that the ark has been found
                for (var obj in OPENWORLD.Mob.chatterlist) {
                  OPENWORLD.Mob.setChatter(
                      obj, [
                    "Did you hear, the ark has been found!",
                    "Israel is saved, the ark is back at the temple",
                    "Hallelujah, someone found the ark!",
                    "Some hero found the ark. Anyone know who?",
                    "When I get a break I'll go to the temple and see the ark",
                    "Wish I could go to the temple and see the ark"
                  ],
                      z: 90,
                      scale: 0.3,
                      width: 300);
                  OPENWORLD.Space.faceObjectAlways(obj, camera);
                }

                roomB.extra['guide'] = [
                  'Hallelujah, the ark is back!',
                  'The Ark of the Covenant is our most sacred object',
                  'It is a wooden chest coated in pure gold, ',
                  'topped off by an elaborate golden lid known as the mercy seat.',
                  'The Ark contains the Tablets of the Law, by which God delivered',
                  'the Ten Commandments to Moses at Mount Sinai.',
                  'It also contained Aarons rod and a pot of manna.',
                  'The gold-plated acacia chests staves were lifted and carried',
                  'approximately 2,000 cubits (800m) in advance of the people while ',
                  'they marched.',
                  'God spoke with Moses "from between the two cherubim" on the Arks cover.'
                ];

                setState(() {
                  _canfly = true;
                  OPENWORLD.Persistence.set("canfly", _canfly);
                  //  inprayer=false;

                });
              });
            });
          });
        });
      } else {
        inprayer = false;
        print("in prayer false");
      }
    } else {
      inprayer = false;
      print("in prayer falseii");
    }
  }

  // Dismount the horse
  dismount({left}) {
    if (horseriding) {
      var worldpos = OPENWORLD.You
          .getWorldPos();
      var dismountpos;
      if (left == null || !left)
        dismountpos = OPENWORLD.Math.vectorMoveFoward(
            worldpos.x, worldpos.y, OPENWORLD.Camera.turn, 0.52);
      else {
        // For case of gabriel where want to dismount side saddle
        dismountpos = OPENWORLD.Math.vectorMoveFoward(
            worldpos.x, worldpos.y, OPENWORLD.Camera.turn, 0.1);
        dismountpos = OPENWORLD.Math.vectorMoveFoward(
            dismountpos.x, dismountpos.y, OPENWORLD.Camera.turn, 0.2);
      }
      OPENWORLD.Space
          .worldToLocalSurfaceObjLerp(
          camera,
          dismountpos.x, //worldpos.x,
          dismountpos.y, // worldpos.y + 0.52,
          defaultcameraoffset, 1,
          delay: 1);
      horseriding = false;
      OPENWORLD.You.speed = defaultspeed;
      horseridingclop.stop();
      Future.delayed(Duration(
          milliseconds: (1000)
              .round()), () async {
        OPENWORLD.Camera
            .cameraoffset =
            defaultcameraoffset;
        OPENWORLD.Sound.play(path: 'sounds/horse.mp3', volume: 0.5);
      });
    } else {
      //  callHorse();
    }
  }

  initPage() async {
    OPENWORLD.System.active = true;
    if (kIsWeb)
      OPENWORLD.Persistence.gamename =
      "secondtemple"; // So that if two games in web wont mix up cookies in browser
    OPENWORLD.Time.setTime(await OPENWORLD.Persistence.get("time",
        def: OPENWORLD.Math.random() *
            24)); //OPENWORLD.Math.random()*24);//);//12.0); //);
    OPENWORLD.Time.daylength = 1.0; // Takes an hour to do 24 hours

    OPENWORLD.Room.init();

    // Make player faster if on smartphone
    if (!kIsWeb) {
      defaultspeed *= 1.5; //8; //2m/s
    }
    OPENWORLD.You.speed = defaultspeed;

    // Set the client game url
    _session = CLIENT.Session(
        "https://forthtemple.com/secondtemple/serverdart/secondtemple.php");

    // skydome is 1000 so over 1000 isn't really necessary
    camera = THREE.PerspectiveCamera(60, width / height, 0.04, 4000);

    OPENWORLD.Camera.init(camera, defaultcameraoffset, width, height);

    // Set the default font to Nanum Myeongjo
    OPENWORLD.Texture.defaultfontfamily = 'NanumMyeongjo';

    camera.position.y = 999;

    // Set must wait 100ms when has triggered that touched an object
    OPENWORLD.BaseObject.touchtriggerwait = 0.1;

    clock = THREE.Clock();

    print("create scene");
    scene = THREE.Scene();
    scene.rotation.order = "YXZ";

    // Show hotloaded objects
    scene.add(_hotload);

    // Set the ambient light in the scene
    var ambience = new THREE.AmbientLight(0x666666);
    scene.add(ambience); //222222 ) );


    // Create the skymat that shows the sky at different times of the day eg sunset, noon, night
    print("create sky");
    var skyGeo = THREE.SphereGeometry(-1000, 32, 15);
    // uniforms['topColor']['value']= hemiLight.color.getHex();//.groundColor;
    var skyMat = new THREE.ShaderMaterial(SkyShader);

    var sky = THREE.Mesh(skyGeo, skyMat);

    scene.add(sky);

    skyMat.uniforms = {
      'turbidity': {'value': 10.0},
      'reileigh': {'value': 2.0},
      'mieCoefficient': {'value': 0.005},
      'mieDirectionalG': {'value': 0.8},
      'luminance': {'value': 1.0},
      'inclination': {'value': 0},
      //this._inclination}, // elevation / inclination
      'azimuth': {'value': 0},
      //this._azimuth}, //0.25, // Facing front,
      // 'sun': {'value':true},
      'opacity': {'value': 1.0},
      'sunPosition': {'value': THREE.Vector3(0, 100, 0)}
    };

    // Add Sun
    var sunSphere = THREE.Mesh(THREE.SphereGeometry(20000, 16, 8),
        THREE.MeshBasicMaterial({'color': THREE.Color.fromHex(0xffffff)}));
    sunSphere.position.y = -700000;
    sunSphere.visible = true;
    var sunlight = new THREE.SpotLight(0x888888); //ffffff);
    sunlight.intensity = 0.4;
    sunlight.penumbra = 1;
    sunSphere.add(sunlight);
    scene.add(sunSphere);

    // Specify the maps for the game
    // Each map has an map image with two points with a world position and corresponding pixel position on the map
    print("create maps");
    var maps = [
      OPENWORLD.MapItem('assets/maps/maplarge.jpg',
          worldx: -7.61,
          worldy: 17.73,
          imagex: 301,
          imagey: 338,
          worldx2: 11.05,
          worldy2: -12.99,
          imagex2: 371,
          imagey2: 450),
      OPENWORLD.MapItem('assets/maps/map.jpg',
          worldx: -2.36,
          worldy: 4.94,
          imagex: 13,
          imagey: 122,
          worldx2: 9.52,
          worldy2: -2.32,
          imagex2: 977,
          imagey2: 588)
    ];
    OPENWORLD.Maps.init(maps);

    // Initialise music with 4 tunes
    // Hatikvah has the highest chance of playing
    print("create music");
    var musics = [
      OPENWORLD.MusicItem('sounds/hatikvah.mp3', chance: 0.5),
      OPENWORLD.MusicItem('sounds/harp.mp3', chance: 0.1),
      OPENWORLD.MusicItem('sounds/harp2.mp3', chance: 0.1),
      OPENWORLD.MusicItem('sounds/harp3.mp3', chance: 0.1),
    ];
    OPENWORLD.Musics.init(musics);

    // Change sound mute based on settings
    OPENWORLD.Musics.setMute(
        await OPENWORLD.Persistence.get("musicmute", def: false));
    OPENWORLD.Sound.setMute(
        await OPENWORLD.Persistence.get("mute", def: false));

    // Initialize the time with the sunsphere, skymat and ambience so that can change these based upon the time of day giving a realistic sky
    print("init time");
    //  OPENWORLD.Time.init( null,null ,ambience);
    OPENWORLD.Time.init(sunSphere, skyMat, ambience);

    // Load the terrain that everything is place on top of
    print(
        "load terrain"); //+OPENWORLD.Space.getMesh().toString());//_mesh.toString());
    var manager = THREE.LoadingManager();
    var mtlLoader = THREE_JSM.MTLLoader(manager);
    mtlLoader.setPath('assets/models/temple/');
    print("loading terrain materials");
    var materials = await mtlLoader.loadAsync('temple.mtl');
    print("loaded terrain materials");
    await materials.preload();
    var loader = THREE_JSM.OBJLoader(null);
    loader.setMaterials(materials);
    Group mesh = await loader.loadAsync('assets/models/temple/temple.obj');

    // Create a detail texture applied to the terrain surface only
    print("load terrain detail");
    var textureii = await THREE.TextureLoader()
        .loadAsync('assets/models/temple/detailmap.png');
    textureii.wrapS = THREE.RepeatWrapping;
    textureii.wrapT = THREE.RepeatWrapping;
    textureii.needsUpdate = true;
    textureii.repeat.set(2, 2);
    var mat2 = new THREE.MeshBasicMaterial({
      'map': textureii,
      'transparent': true,
      //  'alphaTest': .5
    });

    scene.add(mesh);
    OPENWORLD.Space.init(mesh, scene);

    mesh.traverse((object) {
      if (object is Mesh && object.material is THREE.Material) {
        THREE.MeshPhongMaterial mat = object.material as THREE
            .MeshPhongMaterial; // as THREE.MeshPhongMaterial).alphaMap.toString()

        if (mat.alphaMap != null) mat.alphaMap = null;

        mat.shininess = 0;

        mat.emissive = THREE.Color(0x000000);

        // Only apply texture to surface and not walls, roof etc
        if (object.name.contains("surface"))
          object.material = [mat, mat2];
      }
    });

    // Create the cloud object that is a plane with a cloud texture
    print("create cloud");
    var geometry = new THREE.PlaneGeometry(2000, 2000);
    var texturei =
    await THREE.TextureLoader(null).loadAsync('assets/textures/clouds.png');
    texturei.wrapS = THREE.RepeatWrapping;
    texturei.wrapT = THREE.RepeatWrapping;
    texturei.needsUpdate = true;

    texturei.matrixAutoUpdate = true;
    texturei.repeat.set(50, 50);
    // var material = new THREE.MeshBasicMaterial( {'color': 0xffff00, 'side': THREE.FrontSide} );
    var material =
    THREE.MeshStandardMaterial({'map': texturei, 'transparent': true});

    var clouds = new THREE.Mesh(geometry, material);
    clouds.rotateX(THREE.MathUtils.degToRad(90));
    scene.add(clouds);

    OPENWORLD.Space.worldToLocalSurfaceObj(clouds, 7.7, 1.0, 15);

    // Initialize the weather including the cloud plane and the sounds used for wind and rain
    print("init weather");
    await OPENWORLD.Weather.init(
        clouds, 'sounds/wind.mp3', 'sounds/rain.mp3'); // rainSound);

    // Set the weather based upon what was last saved
    OPENWORLD.Weather.setCloud(
        await OPENWORLD.Persistence.get("cloud", def: 0.0)); //.0);
    OPENWORLD.Weather.setWind(
        await OPENWORLD.Persistence.get("wind", def: 0.0));
    OPENWORLD.Weather.setRain(
        await OPENWORLD.Persistence.get("rain", def: 0.0));
    OPENWORLD.Weather.setFog(await OPENWORLD.Persistence.get("fog", def: 0.0));
    OPENWORLD.Weather
        .setRandomWeather(); // Will randomly get rain, fog, wind and cloud
    // Remember if player can fly
    _canfly = await OPENWORLD.Persistence.get("canfly", def: _canfly);
    // Remember if player has received a blessing
    priestblessing =
    await OPENWORLD.Persistence.get("priestblessing", def: priestblessing);
    // Remember if player has received gabriels prayer
    hasprayer = await OPENWORLD.Persistence.get("hasprayer", def: hasprayer);

    // This is the start room in the court of women outside the second temple
    var roomBC = OPENWORLD.Room.createRoom(7.4, 1.26);
    roomBC.extra['name'] = "Court of Women";
    // Set information about the room for the guide
    roomBC.extra['guide'] = [
      "This is the Court of Women.",
      "Ritually pure women, children &",
      "prosletytes and men are",
      "allowed here.",
      "There is a lot of festivals",
      "with dancing and music",
      "that go on here " //as",
    ];
    scene.add(roomBC);

    // Set distance trigger for the room and change the room name when you enter the room ie 'Court of Women'
    OPENWORLD.Room.setDistanceTrigger(roomBC,
        minx: 5, maxx: 9.1, miny: -0.67, maxy: 2.8);
    roomBC.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        if (mounted)
          setState(() {
            print("in shofar");
            roomname = roomBC.extra['name'];
          });
      } else {
        if (roomname == roomBC.extra['name']) {
          if (mounted)
            setState(() {
              roomname = "";
            });
        }
      }
    });

    // ciziten.glb holds all the animations so load the actor without adding to the scene yet so can share animations with other actors
    Group seller =
    await OPENWORLD.Actor.createActor('assets/actors/citizen/citizen.glb',
        texture: "assets/actors/citizen/bodyc4.png",
        z: actoroffset);

    // Load shofar actor using the sellers animations
    _shofar = await OPENWORLD.Actor.createActor(
        'assets/actors/shofar/shofar.glb',
        z: actoroffset,
        shareanimations: seller,
        randomduration: 0.1);

    // Have the shofar wield a horn
    var horn = await OPENWORLD.Model.createModel(
        'assets/actors/shofar/horn.glb');

    OPENWORLD.Actor.wield(_shofar, horn, "Bip01_R_Hand");

    // Set the shofar to be the default size
    setActorSize(_shofar);

    // Set the position of the shofar
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        _shofar, 7.7, 1.8, 0, 3, lerpopacity: 1); //7.7, 2.0, 0, 3);  //3.42);
    scene.add(_shofar);
    // Set the direction the shofar is facing
    OPENWORLD.Space.objTurn(_shofar, 180); // south
    // When player goes near the shofar and the player has gabriels prayer then remind player to say the prayer at the perpetual flame
    OPENWORLD.BaseObject.setDistanceTrigger(_shofar, dist: 1.5);
    _shofar.extra['trigger'].addEventListener('trigger',
            (THREE.Event event) async {
          if (event.action) {
            if (hasprayer && !inprayer && !_canfly) {
              var speech = [
                "Say the prayer at the eternal flame"
              ];
              OPENWORLD.Mob.setSpeech(
                  _shofar,
                  speech,
                  z: 90,
                  //scale: 0.3,
                  width: 300);
            }
          }
        });


    // Define the joystick
    _joystick = OPENWORLD.VirtualJoystick();
    _joystick?.joysticksize = 200;

    var fpsControl = PointerLockControls(camera, _globalKey);

    fpsControl.domElement.addEventListener('keyup', (event) {
      _joystick?.keyboard.onKeyChange(event, 'keyup');
    }, false);
    fpsControl.domElement.addEventListener('keydown', (event) {
      _joystick?.keyboard.onKeyChange(event, 'keydown');
    }, false);
    fpsControl.domElement.addEventListener('pointerdown', (event) {
      pointerdowntick = OPENWORLD.System.currentMilliseconds();
      _joystick?.onTouchDown(event.clientX, event.clientY);
    }, false);
    fpsControl.domElement.addEventListener('pointerup', (event) {
      var numpoints;
      numpoints = 2;

      if (!OPENWORLD.BaseObject.touchup(
          pointerdowntick, event, scene, width, height, numpoints)) {
        //   OPENWORLD.BaseObject.setHighLights(scale:1.000005,opacity:0.5);//hidehighlights();
        OPENWORLD.BaseObject.deselectHighLights(); //hidehighlights();
        setState(() {
          menuposx = -1;
        });
      }
    }, false);
    fpsControl.domElement.addEventListener('pointerdown', (event) {
      _joystick?.onTouchDown(event.clientX, event.clientY);
    }, false);

    fpsControl.domElement.addEventListener('pointerup', (event) {
      _joystick?.onTouchUp();
    }, false);
    fpsControl.domElement.addEventListener('pointermove', (event) {
      // this should be in openworld!!
      if (!_joystick?.getStickPressed()) {
        _joystick?.onTouch(
            event.clientX, event.clientY, width, height, clock.getDelta());
      }
    }, false);

    // This room is within the second temple where the priest is and includes the minorah, showbread and altar of incense
    var roomA = OPENWORLD.Room.createRoom(
        0.67, 1.26, soundpath: "sounds/temple.mp3",
        volume: 0.4); //THREE.Object3D();
    OPENWORLD.Room.setIndoors(roomA, true);
    roomA.extra['name'] = 'Sanctuary';
    roomA.extra['guide'] = [
      "You are within the sanctuary",
      "of the Second Temple in 70AD.",
      "Only priests are allowed in",
      "here but since you are",
      "a special visitor they",
      "have made an exception.",
      "This temple was originally",
      "built in the 10th century BC",
      "by Solomon before being",
      "destroyed by the Babylonians",
      "in 587BC. It was rebuilt as",
      "close to what you see here",
      "starting 516BC onwards. Theres",
      "been a lot of expansion",
      "recently."
    ];
    scene.add(roomA);

    OPENWORLD.Room.setDistanceTrigger(roomA,
        miny: 0.74, maxy: 1.84, minx: 0.21, maxx: 1.88);

    roomA.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        if (mounted)
          setState(() {
            roomname = roomA.extra['name'];
          });
      } else {
        if (roomname == roomA.extra['name']) {
          if (mounted)
            setState(() {
              roomname = "";
            });
        }
      }
    });

    // Show make coming from altar
    var smoke = Smoke();
    var smokeGroup =
    await smoke.createSmoke('assets/textures/smoke/clouds64.png');

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smokeGroup, -0.42, 1.35, 0.21, 3);

    smokeGroup.scale.set(0.00007, 0.00007, 0.00007);
    OPENWORLD.Updateables.add(smoke);
    scene.add(smokeGroup);

    // Add the priest
    _priest = await OPENWORLD.Actor.createActor(
      'assets/actors/priest/priest.glb',
      shareanimations: seller,
      z: actoroffset,
    );

    setActorSize(_priest);
    OPENWORLD.Space.objTurn(_priest, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        _priest, -0.12, 1.3, 0, 3, lerpopacity: 1); //3.42);
    scene.add(_priest);

    // When go near priest say the blessing to the player
    OPENWORLD.BaseObject.setDistanceTrigger(_priest, dist: 1.0);
    var blessingsound = audioplayers.AudioPlayer();
    _priest.extra['trigger'].addEventListener('trigger',
            (THREE.Event event) async {
          if (event.action && !inprayer) {
            print("priest in");
            print("remove shofar");
            scene.remove(_shofar);
            scene.remove(_shofar2);
            scene.remove(_lightshofar);

            var duration = await OPENWORLD.Sound.play(
                sound: blessingsound, path: 'sounds/blessing.mp3', volume: 0.2);
            if (duration != null && duration > 0) {
              Future.delayed(
                  Duration(milliseconds: (duration * 1000).round()), () async {
                print("completed");
                OPENWORLD.Actor.playActionThen(
                    _priest, "armsdown", "idle"); //,   durationthen:2);

                print("priest blessing finished");
                print("priest hands up");

                OPENWORLD.Mob.clearText(_priest);

                var speech = [
                  "Israel has so many enemies",
                  "If only we had the ark again",
                  "If only someone could find it",
                  "Our enemies would be no more",
                  "There are rumours among the people on where it is",
                  "Maybe listen to what the people say"
                ];
                if (priestblessing) {
                  if (!hasprayer)
                    speech.insert(0, "Hello again friend");
                  else if (!_canfly)
                    speech.insert(0, "Say your prayer at the perpetual flame!");
                }
                OPENWORLD.Mob.setSpeech(
                    _priest,
                    speech,
                    z: 100,
                    // scale: 0.3,
                    width: 300, delay: 2);

                OPENWORLD.Persistence.set("priestblessing", true);
                setState(() {
                  priestblessing = true;
                });
              });
            }

            OPENWORLD.Actor.playActionThen(
                _priest, "armsup", "armsidle");
          } else {}
        });

    // Show the minorah
    var minorah = await OPENWORLD.Model.createModel(
        'assets/models/minorah.glb');
    scene.add(minorah);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        minorah, -0.33, 1.03, 0.0, 4); // 3.2,2.5, 0.0);
    minorah.scale.set(0.11, 0.11, 0.11);
    OPENWORLD.Space.objTurn(minorah, 0);
    // Add message above minorah telling player to click it for info
    addMsgToObj(minorah, "Click Minorah", scale: 0.01, z: 3.5);
    // Highlight the minorah to show that can click it
    OPENWORLD.BaseObject.setHighlight(minorah, scene, THREE.Color(0x0000ff),
        0.25); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(minorah, true, scale: 1.05, opacity: 0.15);
    OPENWORLD.BaseObject.setTouchTrigger(minorah);
    minorah.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      // Display information about the minorah when click it
      print("touched");
      OPENWORLD.BaseObject.highlight(minorah, true, scale: 1.05, opacity: 0.25);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The menorah is made of pure gold."});
        menuitems.add(
            {"text": "The design was revealed to Moses by God as follows:"});
        menuitems.add({"text": "'Make a lampstand of pure gold."});
        menuitems.add({
          "text": "Hammer out its base and shaft, and make its flowerlike cups,"
        });
        menuitems.add({"text": "buds and blossoms of one piece with them.'"});
        menuobj = minorah;
      });
    });

    // Display and show information about showbread when clicked
    var showbread = await OPENWORLD.Model.createModel(
        'assets/models/showbread.glb');
    scene.add(showbread);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        showbread, -0.38, 1.61, 0.0, 4); // 3.2,2.5, 0.0);
    showbread.scale.set(0.2, 0.2, 0.2);
    OPENWORLD.Space.objTurn(showbread, 0);
    addMsgToObj(showbread, "Click showbread", scale: 0.005, z: 1);
    OPENWORLD.BaseObject.setHighlight(showbread, scene, THREE.Color(0x0000ff),
        0.35); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(showbread, true, scale: 1.0, opacity: 0.2);
    OPENWORLD.BaseObject.setTouchTrigger(showbread);
    showbread.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      print("touched");
      OPENWORLD.BaseObject.highlight(
          showbread, true, scale: 1.05, opacity: 0.35);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The showbread are cakes of bread that"});
        menuitems.add({"text": "are always present as an offering to God."});
        menuitems.add({"text": "The 12 cakes are baked from fine flour,"});
        menuitems.add({"text": "arranged in two rows on a table"});
        menuitems.add({"text": "each cake was to contain"});
        menuitems.add({"text": "'two tenth parts of an ephah' of flour."});
        menuitems.add({"text": "The table is made of gold"});
        menuobj = showbread;
      });
    });

    // Show and display information when altar is clicked
    var altar = await OPENWORLD.Model.createModel('assets/models/altar.glb');
    scene.add(altar);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        altar, -0.38, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
    altar.scale.set(0.6, 0.6, 0.6);
    OPENWORLD.Space.objTurn(altar, 0);
    OPENWORLD.BaseObject.setHighlight(altar, scene, THREE.Color(0x0000ff),
        0.35); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(altar, true, scale: 1.0, opacity: 0.2);
    OPENWORLD.BaseObject.setTouchTrigger(altar);
    addMsgToObj(altar, "Click altar", scale: 0.002, z: 0.3);
    altar.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      print("touched");
      OPENWORLD.BaseObject.highlight(altar, true, scale: 1.05, opacity: 0.35);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The altar of incense is made of shittim wood"});
        menuitems.add({"text": "and is covered in pure gold. "});
        menuitems.add({"text": "As God said in Exodus:"});
        menuitems.add(
            {"text": "'Place it in front of the curtain that is over'"});
        menuitems.add(
            {"text": "the Ark of the Pact—in front of the cover that is"});
        menuitems.add({"text": "over the Pact—where I will meet with you.'"});
        menuobj = altar;
      });
    });


    // This room is between the santuary and the court of women and has the eternal flame
    roomB = OPENWORLD.Room.createRoom(3.2, 1.26, soundpath: "sounds/fire.mp3",
        volume: 0.2,
        randomsoundpath: "sounds/moo1.mp3",
        randomsoundgap: 60); //THREE.Object3D();
    roomB.extra['name'] = 'Court of the Priests';
    roomB.extra['guide'] = [
      "This the Court of the Priests.",
      "Here priests slaughter",
      "animals such as lamb or bull",
      "and then sacrifice them",
      "on the altar. Often the",
      "offerer will then cook",
      "and eat the offering",
      "giving part of it to",
      "the priests.",
      "Only priest are allowed here",
      "with ritually pure males only",
      "allowed a few metres east of",
      "here."
    ];
    scene.add(roomB);

    OPENWORLD.Room.setDistanceTrigger(roomB,
        minx: 1.88, maxx: 5, miny: -0.67, maxy: 2.8);
    roomB.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        if (mounted)
          setState(() {
            roomname = roomB.extra['name'];
          });
      } else {
        if (roomname == roomB.extra['name']) {
          if (mounted)
            setState(() {
              roomname = "";
            });
        }
      }
    });

    // Light up the temple with spotlight
    _light = new THREE.SpotLight(0xffffff);
    _light.intensity = 1;
    _light.penumbra = 1;
    OPENWORLD.Light.clock = clock;
    OPENWORLD.Light.addFlicker(_light);
    OPENWORLD.Light.addNightOnly(_light);

    OPENWORLD.Space.worldToLocalObj(_light, 2.5, 1.3, 7.4); //7.0);
    scene.add(_light);

    // Show the altar fire
    var fireWidth = 2;
    var fireHeight = 4;
    var fireDepth = 2;
    var sliceSpacing = 0.5;

    _fire = new VolumetricFire(
        fireWidth, fireHeight, fireDepth, sliceSpacing, camera);
    await _fire?.init();

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        _fire?.mesh, 3.29, 0.25, 0.3, 3); // 3.35, 0.51, 0.3,3); //3.7);
    _fire?.mesh.scale.x = 0.25;
    _fire?.mesh.scale.y = 0.25;
    _fire?.mesh.scale.z = 0.25;
    scene.add(_fire?.mesh);
    OPENWORLD.Updateables.add(_fire);

    print('added fire');

    // add the altar to the eternal flame and if click give information about it
    var altargreat = await OPENWORLD.Model.createModel(
        'assets/models/altargreat.glb');
    scene.add(altargreat);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        altargreat, 3.25, 0.3, 0.0, 7); // 3.2,2.5, 0.0);
    altargreat.scale.set(0.9, 0.9, 0.9);
    OPENWORLD.Space.objTurn(altargreat, 180);
    OPENWORLD.BaseObject.setHighlight(altargreat, scene, THREE.Color(0x0000ff),
        0.35); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(altargreat, true, scale: 1.05, opacity: 0.2);
    OPENWORLD.BaseObject.setTouchTrigger(altargreat);
    altargreat.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      print("touched");
      OPENWORLD.BaseObject.highlight(
          altargreat, true, scale: 1.02, opacity: 0.35);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The Brazen altar"});
        menuitems.add({"text": "is where burnt animal offerings were made."});
        menuitems.add({
          "text": "The sacrifices were made at atonements for sins of the people."
        });
        menuitems.add(
            {"text": "The fire of the alter is kept lit at all times."});
        menuobj = altargreat;
      });
    });

    OPENWORLD.BaseObject.setDistanceTrigger(altargreat, dist: 0.5);
    altargreat.extra['trigger'].addEventListener(
        'trigger', (THREE.Event event) async {
      if (event.action) {
        OPENWORLD.Sound.play(delay: OPENWORLD.Math.random() * 3,
            path: 'sounds/die.mp3',
            volume: 0.5);
      }
    });

    // Show cow and if near the cow then play moo sound
    _cow = await OPENWORLD.Actor.createActor('assets/actors/cow/cow.glb');
    _cow.scale = THREE.Vector3(0.005, 0.005, 0.005);
    OPENWORLD.Space.objTurn(_cow, 0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        _cow, 3.0, 2.4, 0.0, 3, lerpopacity: 1); //3.42);
    scene.add(_cow);
    OPENWORLD.BaseObject.setDistanceTrigger(_cow, dist: 1.0);
    _cow.extra['trigger'].addEventListener(
        'trigger', (THREE.Event event) async {
      if (event.action) {
        print("in cow");
        var moo = ((OPENWORLD.Math.random() * 3) + 1).floor().toString();
        OPENWORLD.Sound.play(delay: OPENWORLD.Math.random() * 10,
            path: 'sounds/moo' + moo + '.mp3',
            volume: 0.5);
        // var starttime=OPENWORLD.System.currentMilliseconds();
      }
    });

    // Show the laver and if clicked display information
    var laver = await OPENWORLD.Model.createModel('assets/models/laver.glb');
    scene.add(laver);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        laver, 2.53, -0.51, 0.0, 7); // 3.2,2.5, 0.0);
    laver.scale.set(0.11, 0.11, 0.11);
    addMsgToObj(laver, "Click Laver", scale: 0.013, z: 5.5);
    OPENWORLD.Space.objTurn(laver, 0);
    OPENWORLD.BaseObject.setHighlight(laver, scene, THREE.Color(0x0000ff),
        0.35); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(laver, true, scale: 1.02, opacity: 0.2);
    OPENWORLD.BaseObject.setTouchTrigger(laver);
    laver.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      print("touched");
      OPENWORLD.BaseObject.highlight(laver, true, scale: 1.02, opacity: 0.35);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The bronze laver is for "});
        menuitems.add({"text": "Aaron, his sons and their successors"});
        menuitems.add({"text": "as priests to wash their hands and "});
        menuitems.add({"text": "their feet before making a sacrifice"});
        menuobj = laver;
      });
    });

    // Room just outside the court of women
    roomC = OPENWORLD.Room.createRoom(9.78, 1.5,
        soundpath: "sounds/courtyard.mp3", volume: 0.05); //THREE.Object3D();
    //roomA.extra['name']='Sanctuary';
    roomC.extra['guide'] = [
      "To the west is the",
      "inner courts where only",
      "jews are permitted.",
      "Gentiles are only permitted",
      "in the Court of the Gentiles",
      "north and south of here.",
      "Theres many signs warning",
      "Gentiles not to enter here.",
      "If they disobey they",
      "are executed."
    ];
    scene.add(roomC);
    OPENWORLD.Room.setDistanceTrigger(roomC,
        minx: 9.5, maxx: 10.2, miny: -2.35, maxy: 4.61);
    print("guard");
    Group guard = await OPENWORLD.Actor.createActor(
        'assets/actors/soldier/solider.glb',
        texture: "assets/actors/soldier/bodys.png",
        z: actoroffset,
        randomduration: 0.1);
    // so that both guards aren't idle in sync
    OPENWORLD.Mob.setName(guard, "Peter");

    // Set random chatter for the guard that is guarding the entrance
    OPENWORLD.Mob.setChatter(
        guard,
        [
          "Keep moving, citizen, the temple gates must remain clear!",
          "Show respect as you enter—we guard the house of the Lord!",
          "Stay vigilant, no disturbances near the sacred grounds!",
          "Peace and order must be maintained at all times!",
          "Only those with temple business may pass; state your purpose!",
          "Watch yourself, friend, I’ve got my eyes on every corner.",
          "Move along, no loitering near the holy sanctuary!",
          "Remember, any misbehavior will be dealt with swiftly!",
          "Pilgrims, keep your offerings secure; the temple is crowded today.",
          //   "All traders, set up your stalls outside the temple walls!",
          "Go to the Mount of Olives to find what is holy",
        ],
        z: 100,
        width: 300);

    setActorSize(guard);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        guard, 9.8, 1.1, 0.0, 3); //3.42);

    scene.add(guard);
    OPENWORLD.Space.objTurn(guard, 90);

    // Display second guard
    var guard2 = await OPENWORLD.Actor.copyActor(guard, randomduration: 0.1);
    // (await OPENWORLD.Actor.getAction(guard2,name:"idle", randomduration:0.1)).reset().play();

    await OPENWORLD.Model.setTexture(
        guard2, "assets/actors/soldier/bodys2.png");
    setActorSize(guard2);
    OPENWORLD.Space.worldToLocalSurfaceObj(
        guard2, 9.6, 1.8, 0); // 9.8,1.1, 0.14,3); //3.42);
    Group sword = await OPENWORLD.Model.createModel('assets/models/sword.glb');
    sword.children[0].scale.set(0.15, 0.15, 0.15);
    OPENWORLD.Space.objRoll(sword.children[0], 90);
    OPENWORLD.Space.objTurn(sword.children[0], 20 + 180);
    OPENWORLD.Actor.wield(guard2, sword, "Bip01_L_Hand");
    scene.add(guard2);
    OPENWORLD.Space.objTurn(guard2, 90);
    // Have guard walk up and down over and over
    OPENWORLD.BaseObject.setDistanceTrigger(
        guard2, dist: 3, ignoreifhidden: false);
    guard2.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        guard2.visible = true;
        OPENWORLD.Mob.moveToLoop(
            guard2,
            [
              [9.8, 1.8, 0, 0.2],
              [9.8, 1.8 + 2.5, 0, 0.2]
            ],
            action: "walk",
            randomposition: true);
      } else {
        print("outsidemoveto");
        guard2.visible = false;
      }
    });

    OPENWORLD.Mob.setChatter(
        guard2,
        [
          "I walk up and down here all day",
          "Its boring walking up and down here all day",
        ],
        z: 100,
        width: 300);

    // If walk near stairway then will take you down the stair automatically and place you in the mount of olives room
    var downstairs = THREE.Object3D();
    OPENWORLD.Space.worldToLocalSurfaceObj(downstairs, 10.69, 3.60, 0.0);
    scene.add(downstairs);

    OPENWORLD.BaseObject.setDistanceTrigger(downstairs, dist: 0.5);
    downstairs.extra['trigger'].addEventListener('trigger',
            (THREE.Event event) {
          if (event.action &&
              !roomC.extra.containsKey("upstairs") &&
              !roomC.extra.containsKey(
                  "downstairs")) {
            roomC.extra['downstairs'] = true;
            // top of stairs

            OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                camera, 10.49, 3.60, 0, 1);
            OPENWORLD.Space.objTurnLerp(camera, 0.0, 0.5);
            new Timer(new Duration(milliseconds: 1000), () {
              // bottom of stairs
              OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                  camera, 10.87, 1.4, 0, 1);
              new Timer(new Duration(milliseconds: 1000), () {
                OPENWORLD.Space.objTurnLerp(camera, 90, 1);
                // outside
                OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                    camera, 12.62, 1.47, 0, 1);
                new Timer(new Duration(milliseconds: 1000), () {
                  print("removed upstairs downstairs");
                  roomC.extra.remove("upstairs");
                  roomC.extra.remove("downstairs");
                });
              });
            });
          }
        });

    // If in mount of olives room then will go up the stair back to roomc
    var upstairs = THREE.Object3D();
    OPENWORLD.Space.worldToLocalSurfaceObj(upstairs, 11.8, 1.4, 0.0);
    scene.add(upstairs);

    OPENWORLD.BaseObject.setDistanceTrigger(upstairs, dist: 0.5);

    upstairs.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action &&
          !roomC.extra.containsKey("upstairs") &&
          !roomC.extra.containsKey("downstairs")) {
        roomC.extra['upstairs'] = true;
        OPENWORLD.Space.worldToLocalSurfaceObjLerp(
            camera, 10.87, 1.47, OPENWORLD.Camera.cameraoffset, 0.5);
        OPENWORLD.Space.objTurnLerp(camera, 180.0, 0.5);
        new Timer(new Duration(milliseconds: 1000), () {
          // print("go down");
          // top of stairs
          // why do I need to make the offset 7 - otherwise falls through the surface
          OPENWORLD.Space.worldToLocalSurfaceObjLerp(camera, 10.49, 3.60, 7, 1);
          // _space.objTurnLerp(camera,90,0.5);

          new Timer(new Duration(milliseconds: 1000), () {
            OPENWORLD.Space.objTurnLerp(camera, 180, 1);
            // back to top outside
            OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                camera, 9.95, 3.83, 5, 1);
            new Timer(new Duration(milliseconds: 1000), () {
              //  _templestate=TS_NONE;
              OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                  camera, 9.95, 3.83, OPENWORLD.Camera.cameraoffset, 1);
              // _space.worldToLocalSurfaceObjLerp(camera,9.2, 3.83 ,_space.cameraoffset,1);
              roomC.extra.remove("upstairs");
              roomC.extra.remove("downstairs");
              print("removed upstairs downstairs");
            });
          });
        });
      }
    });

    // Royal stoa room with shops
    var roomSouthCourt = OPENWORLD.Room.createRoom(3.4, -5.4,
        soundpath: "sounds/courtyard.mp3", volume: 0.05); //THREE.Object3D();

    OPENWORLD.Room.setAutoIndoors(roomSouthCourt, true);
    roomSouthCourt.extra['guide'] = [
      "You are at the Royal Stoa.",
      "Here a lot of commercial",
      "activity occurs such as",
      "banking and theres also",
      "law courts. Herod",
      "built it wanting it to be",
      "the greatest stoa in the",
      "world."
    ];
    scene.add(roomSouthCourt);

    OPENWORLD.Room.setDistanceTrigger(roomSouthCourt,
        minx: -3.47, maxx: 10.1, miny: -12.4, maxy: -2.1);

    roomSouthCourt.extra['trigger'].addEventListener('trigger',
            (THREE.Event event) {
          if (event.action) {
            print("Royal Stoa");
            if (mounted)
              setState(() {
                roomname = "Royal Stoa";
              });
          } else {
            if (mounted)
              setState(() {
                roomname = "";
              });
          }
        });

    setActorSize(seller);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        seller, 3.4, -11.1, 0, 4, lerpopacity: 1); //3.42);
    scene.add(seller);
    // _space.objTurn(citizen4, 0);  // north

    OPENWORLD.Mob.setInitTurn(seller, 0);

    OPENWORLD.Mob.setName(seller, "Jeremiah");
    print("seller out");

    // Set random chatter for seller
    setActorChatter(seller, [
      "What is the strongest fish? A mussel :)",
      "What do you get when you cross a banker and a fish? A loan shark",
      "Fresh fish from the Sea of Galilee! Best catch of the day!",
      "Step right up! You won't find a better deal on mackerel anywhere!",
      "Perfect fish for your Sabbath meal, just caught this morning!",
      "Take a look at these scales, glistening like silver! Finest in Jerusalem!",
      "Don't wait, the best ones go fast! These fish are as fresh as the sunrise!",
      "Taste the bounty of the sea, perfect for tonight's feast!",
      "Bring home a fish that glows with health, straight from the nets!",
      "Treat your family to the richest flavor, only a few left!",
      "Sea bass, trout, and mullet! Fresh, delicious, and ready for your table!",
      "Come and see, the finest selection in the market, guaranteed fresh!",
      "Is it true? Mount of Olives is the key to find what was taken by the Philistines",
      "For some reason the flaming brands are green that lead to Mount of Olives",
    ]);

    var lender = await OPENWORLD.Actor.copyActor(seller, randomduration: 0.1);
    await OPENWORLD.Model.setTexture(
        lender, "assets/actors/citizen/bodyc5.png");

    setActorSize(lender);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        lender, 1.8, -11.1, 0.0, 4, lerpopacity: 1); //3.42);
    scene.add(lender);
    OPENWORLD.BaseObject.setDistanceTrigger(lender, dist: 1.0);
    OPENWORLD.Mob.setInitTurn(lender, 0);
    OPENWORLD.Mob.setName(lender, "Jeremy");

    setActorChatter(lender, [
      "Need funds for this week's offerings? I have the best rates in all of Jerusalem!",
      "Exchange your foreign coins here; fair and honest conversions!",
      "Temple tax due? Let's settle it quickly with a fair loan!",
      "Gold, silver, copper—I'll convert any currency to temple shekels!",
      "Short on tribute? Come, I can lend you what you need.",
      "A loan here ensures your pilgrimage is free of financial worry!",
      "A wise investment starts with trusted coins; let me assist you!",
      "Money for your market purchases, straight and honest trades right here!",
      "Secure a loan today, and repay with ease before the feast!",
      "No hidden fees, just straightforward lending to suit your needs!",
      "You might meet Gabriel at the Mount of Olives",
      "Why are the flaming brands green that lead to Mount of Olives",
    ]);

    // Create citizens that randomly wonder around the grand stoa
    createCitizens(seller, OPENWORLD.Room.getX(roomSouthCourt),
        OPENWORLD.Room.getY(roomSouthCourt), 1.5, 2);

    // The court of the gentiles  is north of the court of women
    var roomNorthCourt = OPENWORLD.Room.createRoom(3.84, 8.2,
        soundpath: "sounds/courtyard.mp3", volume: 0.05); //THREE.Object3D();

    roomNorthCourt.extra['guide'] = [
      "This is the Court of the Gentiles.",
      "All comers are allowed here",
      "including sellers.",
      "They sell souvenirs",
      "animals for sacrifice and food",
      "for the visitors. There are",
      "also money changers."
    ];
    OPENWORLD.Room.setAutoIndoors(roomNorthCourt, true);
    scene.add(roomNorthCourt);

    OPENWORLD.Room.setDistanceTrigger(roomNorthCourt,
        minx: -3.47, maxx: 10.1, miny: 4.61, maxy: 12.46);
    roomNorthCourt.extra['trigger'].addEventListener('trigger',
            (THREE.Event event) {
          if (event.action) {
            if (mounted)
              setState(() {
                roomname = "Court of Gentiles";
              });
          } else {
            if (mounted)
              setState(() {
                roomname = "";
              });
          }
        });

    createCitizens(seller, OPENWORLD.Room.getX(roomNorthCourt),
        OPENWORLD.Room.getY(roomNorthCourt), 1.5, 2);

    // This is outside the grand entrance where the baths are
    roomSouth = OPENWORLD.Room.createRoom(3.84, -16,
        soundpath: "sounds/courtyard.mp3", volume: 0.05); //THREE.Object3D();

    roomSouth.extra['guide'] = [
      "You are at the south wall.",
      "Here is the grand entrance to",
      "the temple for commoners.",
      "There are also baths for",
      "people to wash before",
      "entering the temple."
    ];
    OPENWORLD.Room.setAutoIndoors(roomSouth, true);
    scene.add(roomSouth);


    OPENWORLD.Room.setDistanceTrigger(roomSouth,
        maxy: -13.1, miny: -28, minx: -9.3, maxx: 10.1);

    roomSouth.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        setState(() {
          if (mounted)
            roomname = "South Wall";
        });
      } else {
        setState(() {
          if (mounted)
            roomname = "";
        });
      }
    });

    createCitizens(seller, 4.2, -13.5, 0.4, 2);

    // Create water for baths
    WaterSimple.initVertexData();
    var water = WaterSimple();
    var water1 = water.createWater();

    water1.scale.set(0.3, 1.0, 0.8);
    scene.add(water1);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        water1, 5.08, -14.89, 0.05, 3); //7.7, 1.0, 0.05);
    OPENWORLD.Updateables.add(water); // only need to do one

    var water2 = water1.clone(true);
    scene.add(water2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        water2, 4.49, -14.89, 0.05, 3); //7.7, 1.0, 0.05);

    var water3 = water1.clone(true);
    scene.add(water3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        water3, 3.91, -14.89, 0.05, 35); //7.7, 1.0, 0.05);


    // put bathers in baths
    var bather = await OPENWORLD.Actor.copyActor(seller,
        duration: 5, randomduration: 0.1, action: "layidle");
    await OPENWORLD.Model.setTexture(
        bather, "assets/actors/citizen/bodyc2.png");

    setActorSize(bather);
    OPENWORLD.Space.worldToLocalSurfaceObj(bather, 5.1, -14.6, 0.00); //3.42);
    scene.add(bather);
    OPENWORLD.Space.objTurn(bather, 180);
    OPENWORLD.Space.objPitch(bather, -15);

    var bather2 = await OPENWORLD.Actor.copyActor(seller,
        duration: 5, randomduration: 0.1, action: "sitidle");
    await OPENWORLD.Model.setTexture(
        bather2, "assets/actors/citizen/bodyc3.png");

    setActorSize(bather2);
    OPENWORLD.Space.worldToLocalSurfaceObj(bather2, 4.5, -14.8, -0.01); //3.42);
    scene.add(bather2);
    OPENWORLD.Space.objTurn(bather2, 180);
    OPENWORLD.Mob.setChatter(
        bather2,
        [
          "Its so nice in here. I could stay here all day",
          "If I eat beans I have a bubble bath ",
        ],
        z: 70,
        scale: 0.4,
        width: 300);

    // Put guards at south entrance
    var guard3 = await OPENWORLD.Actor.copyActor(guard, randomduration: 0.1);

    await OPENWORLD.Model.setTexture(
        guard3, "assets/actors/soldier/bodys3.png");
    setActorSize(guard3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        guard3, 2.16, -13.42, 0, 4); // 9.8,1.1, 0.14,3); //3.42);

    THREE.Object3D sword2 = sword.clone();

    OPENWORLD.Actor.wield(guard3, sword2, "Bip01_L_Hand");

    scene.add(guard3);
    OPENWORLD.Space.objTurn(guard3, 180);

    OPENWORLD.Mob.setName(guard3, "Simon");
    OPENWORLD.Mob.setChatter(
        guard3,
        [
          "Stay alert, any movement beyond the south wall must be reported!",
          "Eyes sharp, lads; we defend the holiest site in all of Judea!",
          "Report any suspicious activity immediately, no exceptions!",
          "Ensure the gates are secure, no unauthorized entry!",
          "Keep your weapons ready and your mind sharper!",
          "Remember, we are the first line of defense for the temple's sanctity.",
          "If you see anything unusual, raise the alarm without delay!",
          "Hold the line; the safety of Jerusalem depends on our vigilance!",
          "Any breach of this wall is a breach of the holy temple itself!",
          "Stay focused, no distractions; our duty here is sacred and paramount!",
          "I heard to find Israel's missing treasure go to the Mount of Olives",
          "The light to the Mount of Olives is different than the other light",
        ],
        z: 100,
        width: 300);

    var guard9 = await OPENWORLD.Actor.copyActor(guard, randomduration: 0.1);

    await OPENWORLD.Model.setTexture(
        guard9, "assets/actors/soldier/bodys3.png");
    setActorSize(guard9);
    OPENWORLD.Space.worldToLocalSurfaceObj(guard9, -5.77, -13.42, 0);
    guard9.visible = false;
    THREE.Object3D sword8 = sword.clone();
    OPENWORLD.Actor.wield(guard9, sword8, "Bip01_L_Hand");

    scene.add(guard9);
    OPENWORLD.Space.objTurn(guard9, 180);
    OPENWORLD.BaseObject.setDistanceTrigger(
        guard9, dist: 5, ignoreifhidden: false);
    guard9.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        guard9.visible = true;
        OPENWORLD.Mob.moveToLoop(
            guard9,
            [
              [-5.77, -13.42, 0, 0.2],
              [-6.04, -22.67, 0, 0.2]
            ],
            action: "walk",
            randomposition: true);
      } else {
        guard9.visible = false;
      }
    });

    // Put a person in house
    var person = await OPENWORLD.Model.createModel('assets/models/person.glb');
    scene.add(person);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        person, -8.27, -20.06, -0.03, 4); // 3.2,2.5, 0.0);
    person.scale.set(0.004, 0.004, 0.004);
    OPENWORLD.Space.objTurn(person, 140);

    // Put a dog in the house which randomly urinates
    Group dog = await OPENWORLD.Actor.createActor('assets/actors/dog.glb',);
    dog.scale.set(0.005 * convscale, 0.005 * convscale,
        0.005 * convscale); //25, 0.0025, 0.0025);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        dog, -8.14, -19.86, 0, 3, lerpopacity: 1.0);

    OPENWORLD.Space.objTurn(dog, 0);
    scene.add(dog);
    OPENWORLD.BaseObject.setDistanceTrigger(dog,
        dist: 2); //, ignoreifhidden: false);
    dog.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Sound.play(path: 'sounds/bark.mp3',
            volume: 0.1,
            delay: OPENWORLD.Math.random() * 5);
        var urinate = OPENWORLD.Math.random() * 30;
        OPENWORLD.Actor.playActionThen(
            dog, "urinate", "idle", delay: urinate);

        // Have person scold dog and then later start random chatter
        OPENWORLD.Mob.setSpeech(
            person,
            [
              "Dirty dog, dont wee in here!",
              "Go outside!"
            ],
            z: 80,
            //0.5
            scale: 0.3,
            width: 300,
            randwait: 0,
            delay: urinate + 3);

        OPENWORLD.Mob.setChatter(
            person,
            ["I like going to the baths",
              "I get lonely here sometimes",
              //  "Stupid dog, dont wee in here"
            ],
            z: 70,
            scale: 0.3,
            width: 300,
            delay: urinate + 20);
      } else {

      }
    });

    // This is the western wall with more sellers
    roomWest = OPENWORLD.Room.createRoom(-8.3, -7.08,
        soundpath: "sounds/courtyard.mp3", volume: 0.05); //THREE.Object3D();

    roomWest.extra['guide'] = [
      "We are at the western wall.",
      "The western wall hasnt been",
      "fully built yet. It has some",
      "immense stones, some weighing",
      "100 tonnes and measuring 1mx3m",
      "with some up to 12m.",
      "There are also some sellers",
      "around here."
    ];
    scene.add(roomWest);

    OPENWORLD.Room.setDistanceTrigger(roomWest,
        minx: -9.3, maxx: -5.6, maxy: -3.5, miny: -11);

    roomWest.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        if (mounted)
          setState(() {
            roomname = "Western Wall";
          });
      } else {
        if (mounted)
          setState(() {
            roomname = "";
          });
      }
    });

    var seller2 = await OPENWORLD.Actor.copyActor(seller, randomduration: 0.1);
    await OPENWORLD.Model.setTexture(
        seller2, "assets/actors/citizen/bodycf.png");

    setActorSize(seller2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        seller2, -7.23, -9.54, 0.0, 4, lerpopacity: 1); //3.42); //-7.22, -10.12
    scene.add(seller2);
    // OPENWORLD.Space.setDistanceTrigger(seller2, dist: 1.0);
    OPENWORLD.Mob.setInitTurn(seller2, 90);
    OPENWORLD.Mob.setName(seller2, "Golda");

    setActorChatter(seller2, [
      "Fine fish from the Sea of Galilee, freshly caught and delicious!",
      "Come, taste the freshness of today’s catch—your family will thank you!",
      "Best fish in all of Jerusalem, perfect for your Sabbath meal!",
      "Step right up, good sir! These fish are as fresh as this morning’s dawn!",
      "Straight from the nets to your table, finest quality in the market!",
      "Lovely mackerel and trout, perfect for a feast fit for a king!",
      "Bring the best of the sea home today, freshly scaled and ready!",
      "Be quick, dear friends; the choicest fish are going fast!",
      "Taste the blessing of the waters; these fish are the pride of Galilee!",
      "A fine meal deserves the finest fish—take a look at these beauties!",
      "At night you see that the light to the Mount of Olives quite green.",
    ]);

    var seller3 = await OPENWORLD.Actor.copyActor(seller, randomduration: 0.1);
    await OPENWORLD.Model.setTexture(
        seller3, "assets/actors/citizen/bodycf2.png");

    setActorSize(seller3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        seller3, -7.28, -9.01, 0.0, 4, lerpopacity: 1); //3.42);
    scene.add(seller3);
    // OPENWORLD.Space.setDistanceTrigger(seller2, dist: 1.0);
    OPENWORLD.Mob.setInitTurn(seller3, 90);
    OPENWORLD.Mob.setName(seller3, "Leah");

    setActorChatter(seller3, [
      "Do you like my melons?",
      "My melons are ripe and firm",
      "Fresh vegetables from the Jordan Valley, come and take your pick!",
      "Bright and crisp greens, perfect for your family's evening meal!",
      "Step right up! The finest carrots and herbs in all of Jerusalem!",
      "Just harvested this morning, taste the freshness of the land!",
      "Make your dishes vibrant with these colorful fruits of the earth!",
      "Add some flavor to your cooking with fresh onions and garlic!",
      "Vegetables straight from the soil, full of life and nutrients!",
      "Perfect for your Sabbath preparations, handpicked with care!",
      "Hurry, good people, the best produce won't last long!",
      "Nourish your loved ones with the bounty of these fresh vegetables!"
    ]);

    createCitizens(seller, OPENWORLD.Room.getX(roomWest),
        OPENWORLD.Room.getY(roomWest), 1.5, 2);

    var roomNorthWest = OPENWORLD.Room.createRoom(-15.8, 17.3,
        soundpath: "sounds/courtyard.mp3", volume: 0.05); //THREE.Object3D();

    scene.add(roomNorthWest);

    OPENWORLD.Room.setDistanceTrigger(roomNorthWest,
        minx: -25, maxx: -5.8, maxy: 23.5, miny: -2.4);


    createCitizens(seller, OPENWORLD.Room.getX(roomNorthWest),
        OPENWORLD.Room.getY(roomNorthWest), 3, 2);

    // Have cat wonder around house
    Group cat = await OPENWORLD.Actor.createActor('assets/actors/cat.glb',
        z: 0);
    cat.scale.set(0.01 * convscale, 0.01 * convscale, 0.01 * convscale);
    OPENWORLD.Space.objTurn(cat.children[0], 0);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cat, -15.04, 6.73, 0, 4, lerpopacity: 1.0);

    OPENWORLD.Space.objTurn(cat, 0);
    scene.add(cat);

    // Cat meows when you get near
    OPENWORLD.BaseObject.setDistanceTrigger(cat,
        dist: 3);
    cat.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Sound.play(path: 'sounds/meow.mp3',
            volume: 0.1,
            delay: OPENWORLD.Math.random() * 5);
        OPENWORLD.Mob.randomwalk(cat, 1, 0.15, 0.1,
          action: "walk",
          actionduration: 0.5,
          stopaction: "idle",
          reset: true,
        );
        //  citizen.visible = true;
      } else {
        //   citizen.visible = false;
      }
    });

    // Put person in second house
    var person2 = person
        .clone(); //await OPENWORLD.Model..createModel('assets/models/person.glb');
    scene.add(person2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        person2, -14.35, 7.26, 0.0, 4); // 3.2,2.5, 0.0);
    //person2.scale.set(0.004, 0.004, 0.004);
    OPENWORLD.Space.objTurn(person2, 100);
    OPENWORLD.Mob.setChatter(
        person2,
        ["Hello, welcome",
          "Have you seen my pussy? I can't find it",
          "How do like my place?"],
        z: 70,
        scale: 0.3,
        width: 300);


    // Antonios fortress with many soldiers
    var roomAntonio = OPENWORLD.Room.createRoom(-3.4, 17.3,
        soundpath: "sounds/courtyard.mp3", volume: 0.05); //THREE.Object3D();

    roomAntonio.extra['guide'] = [
      "This is Antonia fortress.",
      "Its a military baracks.",
      "At one point the Romans",
      "had a garrison here back",
      "when Herod and Rome were",
      "on more friendly terms.",
      "An attack by an army on",
      "Jerusalem would",
      "come from the north",
      "so we depend on this fortress",
      "for our defence."
    ];
    scene.add(roomAntonio);

    OPENWORLD.Room.setDistanceTrigger(roomAntonio,
        minx: -6.3, maxx: -0.45, maxy: 19.3, miny: 14.6);

    roomAntonio.extra['trigger'].addEventListener('trigger',
            (THREE.Event event) {
          if (event.action) {
            if (mounted)
              setState(() {
                roomname = "Antonia Fortress";
              });
          } else {
            if (mounted)
              setState(() {
                roomname = "";
              });
          }
        });

    var guard4 = await OPENWORLD.Actor.copyActor(guard, randomduration: 0.1);
    await OPENWORLD.Model.setTexture(guard4, "assets/actors/soldier/bodys.png");
    setActorSize(guard4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        guard4, -3.78, 14.95, 0, 4); // 9.8,1.1, 0.14,3); //3.42);

    THREE.Object3D sword3 = sword.clone();
    OPENWORLD.Actor.wield(guard4, sword3, "Bip01_L_Hand");

    scene.add(guard4);
    OPENWORLD.Space.objTurn(guard4, 0);

    OPENWORLD.Mob.setName(guard4, "Jacob");
    OPENWORLD.Mob.setChatter(
        guard4,
        [
          "Keep your posts steady and your eyes sharp; the fortress must be secure!",
          "Any sign of trouble and we sound the alarm immediately!",
          "Remember, we safeguard not just a fort, but the heart of our city.",
          "Report any unusual activity at once; we can take no chances!",
          "Maintain formation and stay vigilant; the safety of many depends on us.",
          "Look alive, soldiers! Our duty here is critical to Jerusalem's defense.",
          "Patrol the walls thoroughly; we must prevent any surprise attacks.",
          "Stay focused, comrades; there are eyes on us from every direction.",
          "Secure the gates and ensure all visitors are properly questioned.",
          "We stand as the last line of defense; failure is not an option!",
          "People say the Mount of Olives as the place to find what Israel lost",
        ],
        z: 100,
        width: 300);

    var guard5 = await OPENWORLD.Actor.copyActor(guard, randomduration: 0.1);
    await OPENWORLD.Model.setTexture(
        guard5, "assets/actors/soldier/bodys2.png");
    setActorSize(guard5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        guard5, -6.33, 17.84, 0, 4); // 9.8,1.1, 0.14,3); //3.42);

    THREE.Object3D sword4 = sword.clone();
    OPENWORLD.Actor.wield(guard5, sword4, "Bip01_L_Hand");

    scene.add(guard5);
    OPENWORLD.Space.objTurn(guard5, 180);

    OPENWORLD.Mob.setName(guard5, "Daniel");

    createCitizens(guard, OPENWORLD.Room.getX(roomAntonio),
        OPENWORLD.Room.getY(roomAntonio), 1, 2,
        guards: true);


    // room east of antonios fortress and has the pool of israel
    roomNorth = OPENWORLD.Room.createRoom(3.84, 16.7,
        soundpath: "sounds/courtyard.mp3", volume: 0.05); //THREE.Object3D();

    roomNorth.extra['guide'] = [
      "Here is the Pool of Israel",
      "which is use for cleaning",
      "sheep before sacrifice.",
      "To the north is the Pool of",
      "Bethesda which is where",
      "the sick and lame go to",
      "be healed."
    ];
    scene.add(roomNorth);

    OPENWORLD.Room.setDistanceTrigger(roomNorth,
        minx: 1.5, maxx: 10.1, maxy: 25, miny: 14.1);

    roomNorth.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        if (mounted) {
          setState(() {
            roomname = "Pool of Israel";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            roomname = "";
          });
        }
      }
    });

    // pool2
    var water4 = water1.clone(true);
    scene.add(water4);
    water4.scale.set(3.0, 1.0, 1.2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        water4, 8.1, 14.8, 0.7, 7); //7.7, 1.0, 0.05);

    // Pool of israel
    if (!kIsWeb) {
      // If smartphone use Water shader instead of WaterSimple
      final waterGeometryi = THREE.PlaneGeometry(20.0, 20.0);

      final Map<String, dynamic> params = {
        'color': THREE.Color(0.25, 0.3, 0.35),
        //0xffffff, //0000ff,  0.25,0.3,0.35
        'scale': 80,
        'flowX': 0.1,
        //1.0,
        'flowY': 0.1,
        //1.0
      };

      final wateri = Water(waterGeometryi, {
        'color': params['color'],
        'scale': params['scale'],
        'flowDirection': THREE.Vector2(params['flowX'], params['flowY']),
        'textureWidth': 256, //512,//1024,
        'textureHeight': 256, //512,//1024,
        'reflectivity': 0.0,
        'clipBias': 3.0
      });

      wateri.scale.set(1.6 / 20.0, 1.7 / 20, 1); // 1.7/20.0);
      OPENWORLD.Space.setTurnPitchRoll(wateri, -16, 0, 90);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          wateri, 5.7, 19.89, 0.1, 7); //7.7, 1.0, 0.05);
      scene.add(wateri);
    } else {
      var water5 = water1.clone(true);
      scene.add(water5);
      water5.scale.set(1.6, 1.0, 1.7);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          water5, 5.7, 19.89, 0.1, 7); //7.7, 1.0, 0.05);
      OPENWORLD.Space.objTurn(water5, -16);
    }

    // Add fountain to pool of israel with information if click it
    var fountain = await OPENWORLD.Model.createModel(
        'assets/models/fountain.glb');
    scene.add(fountain);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fountain, 5.8, 13.85, 0.0, 7); // 3.2,2.5, 0.0);
    fountain.scale.set(0.11, 0.11, 0.11);
    addMsgToObj(
        fountain, "ⓘ", scale: 0.011, z: 2.3); // \u00a9 \u24D8 \u1F6C8 \u02139
    OPENWORLD.Space.objTurn(fountain, 180);
    OPENWORLD.BaseObject.setHighlight(fountain, scene, THREE.Color(0x0000aa),
        0.35); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(fountain, true, scale: 1.02, opacity: 0.2);
    OPENWORLD.BaseObject.setTouchTrigger(fountain);
    fountain.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      print("touched");
      OPENWORLD.BaseObject.highlight(
          fountain, true, scale: 1.02, opacity: 0.35);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The pool of Israel or"});
        menuitems.add({"text": "Birket Israel is a water"});
        menuitems.add({"text": "reservoir. It  is also used"});
        menuitems.add({"text": "to protect the northern wall from attack"});
        menuobj = fountain;
      });
    });


    var guard6 = await OPENWORLD.Actor.copyActor(guard, randomduration: 0.1);

    await OPENWORLD.Model.setTexture(
        guard6, "assets/actors/soldier/bodys3.png");
    setActorSize(guard6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        guard6, 2.15, 16.02, 0, 4); // 9.8,1.1, 0.14,3); //3.42);

    THREE.Object3D sword5 = sword.clone();
    OPENWORLD.Actor.wield(guard6, sword5, "Bip01_L_Hand");

    scene.add(guard6);
    OPENWORLD.Space.objTurn(guard6, 90);

    OPENWORLD.Mob.setName(guard6, "Isiah");

    createCitizens(seller, 5.10, 17.79, 3, 2); //OPENWORLD.Room.getX(roomNorth),

    // Mount of olives. Has Gabriel at the top and a horse near the east entrance
    roomOlives = OPENWORLD.Room.createRoom(37, 1.26,
        soundpath: "sounds/forest.mp3", volume: 0.3); //THREE.Object3D();

    roomOlives.extra['guide'] = [
      "You are near the Mount of Olives.",
      "This is where jews are buried.",
      "There are 150,000 graves near here."
    ];
    scene.add(roomOlives);

    OPENWORLD.Room.setDistanceTrigger(roomOlives,
        maxy: 32, miny: -30, minx: 10.1, maxx: 80);

    var guard7 = await OPENWORLD.Actor.copyActor(
        guard, randomduration: 0.1, texture: "assets/actors/soldier/bodys.png");

    setActorSize(guard7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        guard7, 10.30, 22.17, 0, 4); // 9.8,1.1, 0.14,3); //3.42);

    THREE.Object3D sword6 = sword.clone();
    OPENWORLD.Actor.wield(guard7, sword6, "Bip01_L_Hand");

    scene.add(guard7);
    OPENWORLD.Space.objTurn(guard7, 90);

    OPENWORLD.Mob.setName(guard7, "Saul");
    OPENWORLD.Mob.setChatter(
        guard7,
        [
          "Keep watch over the pool; no one enters without clearance!",
          "Stay alert for any disturbances; this area must remain peaceful!",
          "Ensure only those with proper business near the waters approach.",
          "Hold your positions, the pool is a vital resource for our city!",
          "Watch for any suspicious activity around the perimeter!",
          "Maintain order; the sanctity of this place is in our hands.",
          "Only pilgrims and priests may pass; verify their identity!",
          "Keep the path clear for those coming to purify themselves!",
          "Eyes on the edges, we must prevent any unauthorized entry.",
          "Stay focused; the safety of the pool and its visitors depends on us!",
          "Where is the ark? People say the Mount of Olives might hold the secret",
        ],
        z: 100,
        width: 300);

    var guard8 = await OPENWORLD.Actor.copyActor(guard, randomduration: 0.1,
        texture: "assets/actors/soldier/bodys2.png");
    setActorSize(guard8);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        guard8, 12.54, 1.32, 0, 4); // 9.8,1.1, 0.14,3); //3.42);

    THREE.Object3D sword7 = sword.clone();
    OPENWORLD.Actor.wield(guard8, sword7, "Bip01_L_Hand");

    scene.add(guard8);
    OPENWORLD.Space.objTurn(guard8, 90);

    OPENWORLD.Mob.setName(guard8, "Yeshua");
    OPENWORLD.Space.faceObjectAlways(guard8, camera);

    // Horse that player can ride
    _horse = await OPENWORLD.Actor.createActor('assets/actors/horse.glb');
    OPENWORLD.Space.objTurn(_horse.children[0], 0);
    OPENWORLD.Space.objTurn(_horse, 0); //OPENWORLD.Math.random()*360);
    // 0.0025 vs 0.006
    _horse.scale.set(0.014 * convscale, 0.014 * convscale,
        0.014 * convscale); //25, 0.0025, 0.0025);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        _horse, 12.67, 5.22, 0, 6); // 9.8,1.1, 0.14,3); //3.42);
    scene.add(_horse);
    OPENWORLD.BaseObject.setDistanceTrigger(_horse, dist: 0.5);

    // When get close to horse ride it
    _horse.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      //print("horse trigger");
      if (event.action) {
        if (!horseridingcloploaded) {
          horseridingcloploaded = true;
          horseridingclop = OPENWORLD.Sound.getAudioPlayer();
        }
        OPENWORLD.Sound.play(
            sound: horseridingclop,
            path: "sounds/horseclop.mp3",
            volume: 0.5,
            loop: true,
            fadein: 2,
            delay: 2);
        setState(() {
          horseriding = true;
        });
        OPENWORLD.You.speed = horsespeed;

        OPENWORLD.Sound.play(path: 'sounds/horse.mp3', volume: 0.5);
      } else {

      }
    });

    // Show smoke near gabriel on mount of olives
    smoke = Smoke();
    smokeGroup = await smoke.createSmoke('assets/textures/smoke/clouds64.png');

    OPENWORLD.Space.worldToLocalSurfaceObjHide(smokeGroup, 59.20, 1.01, 0, 3);

    smokeGroup.scale.set(0.0004, 0.0004, 0.0004);
    OPENWORLD.Updateables.add(smoke);
    scene.add(smokeGroup);

    // Create gabriel sprite
    var gabriel = await OPENWORLD.Sprite.loadSprite(
        'assets/textures/gabriel.png', 0.5, 0.4,
        ambient: false);

    OPENWORLD.Space.worldToLocalSurfaceObj(gabriel, 59.20, 1.01, 5); //3.42);
    scene.add(gabriel);
    gabriel.visible = false;

    // Create flares for gabriel
    Flares flares = Flares();
    Group flaresobj = await flares.createFlares(
        "assets/models/ark/lensflare2.jpg", "assets/models/ark/lensflare0.png");
    OPENWORLD.Space.worldToLocalSurfaceObj(flaresobj, 59.70, 1.01, 5); // 0.8);
    flaresobj.scale.set(0.05, 0.05, 0.05);
    flaresobj.visible = false;
    scene.add(flaresobj);

    // Show light for gabirel
    var gabriellight = new THREE.PointLight(0xffffff);
    gabriellight.intensity = 0.5;
    gabriellight.penumbra = 1;
    OPENWORLD.Light.addFlicker(gabriellight);
    OPENWORLD.Light.addNightOnly(gabriellight);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        gabriellight, 59.20, 1.01, 0.5, 7);
    scene.add(gabriellight);

    // Create torah with prayer for gabriel
    var torah = await OPENWORLD.Sprite.loadSprite(
        'assets/textures/torah.png', 0.08, 0.08,
        ambient: false);

    OPENWORLD.Space.worldToLocalSurfaceObj(torah, 59.20, 1.01, 0.5); //3.42);
    scene.add(torah);
    torah.visible = false;

    // If get near gabriel who is hidden only appear if the player has got the blessing from the priest first
    OPENWORLD.BaseObject.setDistanceTrigger(
        gabriel, dist: 1.6, ignoreifhidden: false);
    gabriel.extra['trigger'].addEventListener('trigger',
            (THREE.Event event) async {
          if (event.action &&
              priestblessing) {
            // Show gabriel and flares
            gabriel.visible = true;
            flaresobj.visible = true;
            OPENWORLD.You.immobile = true;
            OPENWORLD.You.immobileturn = true;
            dismount(left: true);
            OPENWORLD.Space.faceObjectLerp(camera, gabriel, 1, delay: 1);
            OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                flaresobj, 59.70, 1.01, 0.8, 3); //3.42);
            print("gabriel visible");
            OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                gabriel, 59.20, 1.01, 0.5, 3); //3.42);

            // Put back shofars so can remind player to say prayer at the eternal flame
            if (_shofar.parent != scene)
              scene.add(_shofar);
            if (_shofar2.parent != scene)
              scene.add(_shofar2);
            // Give prayer to player
            new Timer(new Duration(milliseconds: (6 * 1000).floor()), () async {
              var time;
              if (!hasprayer) {
                time = await OPENWORLD.Mob.setSpeech(
                    gabriel,
                    [
                      "I see you are blessed and I see you are worthy",
                      "Say this prayer at the perpetual fire",
                      "in the Court of priests",
                      "and what Israel has lost will return",
                      "Take it now"
                    ],
                    z: -0.1,
                    //0.5
                    scale: 0.004,
                    width: 300,

                    randwait: 0,
                    delay: 8); //z:100, width:300);
                torah.visible = true; // show prayer
                OPENWORLD.Space.placeBeforeCamera(torah, 0.5, time: 2);
              } else {
                time = await OPENWORLD.Mob.setSpeech(
                    gabriel,
                    [
                      "Return to the Court of Priests and",
                      "say the prayer at the perpetual fire.",
                      "Then what Israel has lost will finally return"
                    ],
                    z: -0.1,
                    //0.5,
                    scale: 0.004,
                    width: 300,
                    randwait: 0,
                    delay: 8);
              }
              // Allow movement of player again after have listened to gabriel
              OPENWORLD.You.setImmobile(false, delay: time - 5);
              OPENWORLD.You.setImmobileTurn(false, delay: time - 20);
            });

            OPENWORLD.Sound.play(path: 'sounds/angels.mp3', volume: 1);
          } else {

          }
        });

    // If go near prayer then pick it up and put in inventory
    OPENWORLD.BaseObject.setDistanceTrigger(torah, dist: 0.2);
    torah.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        torah.visible = false;

        OPENWORLD.Sound.play(path: 'sounds/bag.mp3', volume: 1);

        OPENWORLD.Persistence.set("hasprayer", true);
        setState(() {
          hasprayer = true;
        });
      } else {

      }
    });

    createCitizens(seller, OPENWORLD.Room.getX(roomOlives),
        OPENWORLD.Room.getY(roomOlives), 10, 2, chatter: [
          "You're getting close!",
          "There is a wonderful view at the top",
          "I love walking to the top of the Mount of Olives",
          "Whats with the smoke at the top of the mountain?"]);


    // Show hotloaded objects - this function is called every time hotload
    hotload();

    // Load the configuration file with shop items
    await OPENWORLD.Config.loadconfig();

    await OPENWORLD.Config.createAllObjects(scene);
    await OPENWORLD.Config.createPoolObjects(scene);


    Future.delayed(const Duration(milliseconds: 5000), () {
   /*setState(() {
     width=width/2;
   });*/
      //three3dRender.
    });

    // Create the second shofar
    // Should really be in roomBC
    print("creating shofar2");
    _shofar2 = await OPENWORLD.Actor.copyActor(_shofar, randomduration: 0.1,
        texture: "assets/actors/shofar/shofar2.jpg");

    setActorSize(_shofar2);


    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        _shofar2, 7.7, 0.9, 0, 3, lerpopacity: 1); //3.42);
    OPENWORLD.Space.objTurn(_shofar2, 0.0);
    scene.add(_shofar2);

    _lightshofar = new THREE.SpotLight(0xffffff); //PointLight(0xffffff)
    _lightshofar.intensity = 1; // 0.6;
    _lightshofar.angle = 0.5;
    _lightshofar.penumbra = 0.5;
    _lightshofar.distance = 4;

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        _lightshofar, 7.7, 1.3, 2, 3); //3.42);

    var dummy = new THREE.Object3D();
    // dummy.position.set(7.7,3.42,-1.3);
    OPENWORLD.Space.worldToLocalSurfaceObj(dummy, 7.7, 1.3, 0); //3.42);
    scene.add(dummy);
    _lightshofar.target = dummy; //shofar;
    scene.add(_lightshofar);

    OPENWORLD.Light.addFlicker(_lightshofar);
    OPENWORLD.Light.addNightOnly(_lightshofar);

    // Add the shofars as the list of players that can be shown if you play a multiplayer game
    players.add(CLIENT.Player(_shofar)); //_mixershofar));
    players.add(CLIENT.Player(_shofar2)); //_mixershofar2));

    resetYou();

    // Create the guide
    _guide = await OPENWORLD.Actor.copyActor(seller,
        randomduration: 0.1, texture: "assets/actors/citizen/guide.png");
    setActorSize(_guide);
    scene.add(_guide);
    _guide.visible = false;


    // Set position from last time
    if (await OPENWORLD.Persistence.get("posx") != null) {
      // If position saved persistenly then put player to that position
      var x = await OPENWORLD.Persistence.get("posx");
      var y = await OPENWORLD.Persistence.get("posy");
      OPENWORLD.Space.worldToLocalSurfaceObj(
          camera, x!, y!, OPENWORLD.Camera.cameraoffset); //home temple
      var turn = await OPENWORLD.Persistence.get("turn", def: 0);

      OPENWORLD.Camera.setTurn(turn);
    } else {
      print("Using default position");
      OPENWORLD.Space.worldToLocalSurfaceObj(
          camera, 8.59, 1.31, OPENWORLD.Camera.cameraoffset); //home temple

      OPENWORLD.Camera.setTurn(-90); //Space.objTurn(camera,-90);

      if (!kIsWeb) // Persistence doesnt work on web
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          userGuidanceController.show();
        });

      //   lindos bunks camera.lookAt(_shofar.position);
      //    OPENWORLD.Space.worldToLocalSurfaceObj(camera,  -6.79, -9.53, OPENWORLD.Camera.cameraoffset); //westwall market
      // OPENWORLD.Space.worldToLocalSurfaceObj(camera,  -2.80, 16.26, OPENWORLD.Camera.cameraoffset); //antonia fortress

      //  OPENWORLD.Space.worldToLocalSurfaceObj(camera, 3.15, 1.05, OPENWORLD.Camera.cameraoffset);  //fire temple
      // OPENWORLD.Space.worldToLocalSurfaceObj(camera, 7.71, -10.59, 0.15); //fish table
      // OPENWORLD.Space.worldToLocalSurfaceObj(camera,4.76, -15.77,OPENWORLD.Camera.cameraoffset);//0.15);  pool
      // OPENWORLD.Space.worldToLocalSurfaceObj(camera,-7.14, -19.91,OPENWORLD.Camera.cameraoffset);//0.15);  house
      //  OPENWORLD.Space.worldToLocalSurfaceObj(camera,-12.69, 8.16,OPENWORLD.Camera.cameraoffset);//0.15);  house2
      //    OPENWORLD.Space.worldToLocalSurfaceObj(camera, 3.83, 15.86, 0.15); //pool israel
      //  OPENWORLD.Space.worldToLocalSurfaceObj(camera, 57.55, 4.91, 0.15); //mount olives
      //   OPENWORLD.Space.worldToLocalSurfaceObj(camera, 13.71, 3.65, 0.15); //mount olives entrance


    }
    var dist = OPENWORLD.Space.getDistanceBetweenObjs(camera, roomC);
    if (dist < 2) {
      // Only play shofar if start game near shofar - otherwise annoying if play it every time
      print("animating shofar");
      await animateShofar();
    }

    setState(() {
      loaded = true;
    });


    animate();

    _timer = new Timer.periodic(new Duration(milliseconds: poll), (_) {
      clientInterval(); // for the client connection
      heartbeat();
      //userGuidanceController.show(subIndex:1);
    });
  }

  resetYou() {
    CLIENT.You.action = "";
    CLIENT.You.msg = [];
    CLIENT.You.actions['who'] = false;
    // CLIENT.You.actions['disconnect'] = false;
  }

  // Create brand
  makeBrandLight(nightonly, blue) {
    var group = THREE.Group();
    var light;
    if (!blue)
      light = new THREE.PointLight(0xFFA500); //PointLight(0xffffff)
    else
      light = new THREE.PointLight(
          0x6cd5fb); //9ae4ff);//9999ff); //PointLight(0xffffff)

    light.intensity = 1.0; // 0.6;
    light.distance = 1.2;
    light.position.y = 0.33;

    OPENWORLD.Light.addFlicker(light);
    if (nightonly) OPENWORLD.Light.addNightOnly(light);
    group.add(light);
    return group;
  }

  // Animate the shofars on startup
  animateShofar() async
  {
    OPENWORLD.Actor.playActionThen(
        _shofar, "armsup", "hornidle");


    OPENWORLD.Actor.playActionThen(
        _shofar2, "armsup", "hornidle");

    Future.delayed(const Duration(milliseconds: 2000), () async {
      var time = await OPENWORLD.Sound.play(path: 'sounds/shofar.mp3');


      if (time != null && time > 0)
        Future.delayed(Duration(milliseconds: (time * 1000).round()), () async {
          print("done play");
          if (CLIENT.Connection.connect_state !=
              CLIENT.Connection
                  .CS_CONNECTED /*&&
            (_templestate == TS_SHOFAR || _templestate == TS_ARK*)*/
          ) {
            OPENWORLD.Actor.playActionThen(
                _shofar, "horndown", "idle");
            OPENWORLD.Actor.playActionThen(
                _shofar2, "horndown", "idle");
          }
        });
    });
  }

  // Called when you click the connect/disconnect button
  // if clicking connect then ask the users name
  // if clicking disconnect then signal disconnect
  getName() async {
    if (CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTED) {
      // CLIENT.You.actions['disconnect'] = true;
      disconnect();
      //connect_state=CS_NONE;
    } else {
      var names = [
        "Phannias",
        "Mattathias",
        "Joshua",
        "Ananus",
        "Joseph",
        "Ishmael",
        "Jonathan",
        "Ananias",
        "Josephus",
        "Elioneus",
        "Matthias",
        "Simon",
        "Theophilus",
        "Eleazar",
        "Joazer",
        "Ananelus",
        "Antigonus",
        "Simeon",
        "Jason",
        "Onias",
        "Johannan",
        "Joiada",
        "Eliashib",
        "Joiakim",
        "Ezra",
        "Joshua"
      ];

      setState(() {
        CLIENT.Connection.connect_state = CLIENT.Connection.CS_GET_NAME;
        // stop rendering while show dialog

        // Disable DomLikeListenable so can type
        _globalKey.currentState?.pause = true;
      });
      var value = names[(OPENWORLD.Math.random() * names.length).floor()];
      //  FocusScope.of(context).unfocus();
      var name = await promptDialog(
          'Player Name', 'To play online enter your players name', value);


      setState(() {
        // loaded=true;
        _globalKey.currentState?.pause = false;
      });
      if ((name == null || name == "") &&
          CLIENT.Connection.connect_state != CLIENT.Connection.CS_CONNECTED) {
        setState(() {
          CLIENT.Connection.connect_state = CLIENT.Connection.CS_NONE;
        });
      } else {
        if (CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTED) {
          msg();
        } else {
          setState(() {
            prompttext = "Connecting...";
            CLIENT.You.name = name!; //$("name").value;
          });


          msgs = [];
          whos = [];
          for (var i = 0; i < players.length; i++) {
            await OPENWORLD.Actor.playAction(players[i].actor,
                name: "idle",
                clampWhenFinished: true,
                stopallactions: true
            );
          }
          setState(() {
            CLIENT.Connection.connect_state = CLIENT.Connection.CS_CONNECTING;
          });
        }
      }
    }
  }


  // Change layout and stop polling server
  disconnect() async {
    // Tell the server you have disconnected
    if (CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTED) {
      //CLIENT.You.actions['disconnect'] = true;
      //await setInterval();
      lastconnection = -1;
      setState(() {
        showdisconnect = false;

        CLIENT.Connection.connect_state = CLIENT.Connection.CS_NONE;
        prompttext = "";
        msglines.clear();
        msgs.clear();
        whos.clear();
      });
      var servercommands = ["disconnect"];
      var position = {
        "position": jsonEncode({
          "name": CLIENT.You.name,
          // "x": -1,
          "commands": servercommands
          // "who": camera._who,
          // "disconnect": camera._disconnect
        })
      };

      resetYou();

      await _session.post(
        //  "https://forthtemple.com/secondtemple/serverdart/secondtemple.php",
          position);
      Fluttertoast.showToast(
          msg: "You disconnected from the game",
          toastLength: Toast.LENGTH_LONG);
    }
    // }
    // Navigator.pop(context);
  }

  // When click the close button
  // Silence sounds and hide inventory
  close() async {
    print("close");
    OPENWORLD.Weather.mute(
        true); // so that dont get wind or rain sound when close
    OPENWORLD.Musics.setMute(true); //stop();
    OPENWORLD.Sound.setMute(true);
    OPENWORLD.Room.mute(true);
    OPENWORLD.You.immobile = false;
    OPENWORLD.You.immobileturn = false;
    if (horseridingcloploaded)
      horseridingclop.stop();
    if (loaded) {
      _timer.cancel();
      await disconnect();
      setState(() {
        loaded = false;
        hasprayer = false;
        inprayer = false;
        priestblessing = false;
        removed_horn = false;
        OPENWORLD.System.active = false;
      });
    }

    Navigator.pop(context);
  }

  // Once has connected to server change layout
  has_connected() {
    setState(() {
      prompttext = "";
    });
  }

  msg() async {
    // disable DomLikeListenable so can type
    _globalKey.currentState?.pause = true;

    var msg = await chatDialog('Enter Message', '', '');

    // reenable DomLikeListenable so can use movement keyboard again
    _globalKey.currentState?.pause = false;

    if (msg != null && msg != "") {
      CLIENT.You.msg.add(msg);
    }
  }

  // Play wing flap sound if can fly
  wingflap() {
    OPENWORLD.Sound.play(
        path: 'sounds/flap' +
            ((OPENWORLD.Math.random() * 3).floor() + 1).toString() + '.mp3',
        volume: 0.1);
  }

  // If can fly fly upwards
  flyup() {
    if (OPENWORLD.Camera.cameraoffset < 3) {
      OPENWORLD.Camera.cameraoffset += 0.1;
      OPENWORLD.Space.objUpSurface(
          camera,
          OPENWORLD.Camera
              .cameraoffset); //camera.position.x+=0.01; //trick to show
    }
    wingflap();
  }

  // If can fly fly downards
  flydown() {
    if (OPENWORLD.Camera.cameraoffset > 0.15) {
      OPENWORLD.Camera.cameraoffset -= 0.1;
      OPENWORLD.Space.objUpSurface(
          camera,
          OPENWORLD.Camera
              .cameraoffset); //camera.position.x+=0.01; //trick to show
      wingflap();
    }
  }

  var frames = 0;
  var frames10 = 0;

  animate() async {
    // if app in background dont keep animating
    if (!kIsWeb && OPENWORLD.System.appstate != AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        animate();
      });
      return;
    }

    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }
    frames++;
    frames10++;
    var frameTime = clock.getDelta();


    //if (_space != null) {
    prevlocalx = camera.position.x;
    prevlocaly = camera.position.y;
    prevlocalz = camera.position.z;


    if (mapshow) {
      // Get the map to display and maps pixel coordinates based on the world coordinates and show the marker where the player is
      setState(() {
        var worldpos = OPENWORLD.You
            .getWorldPos(); //Space.localToWorldObj(camera);
        var map = OPENWORLD.Maps.getMapFromWorldcoords(worldpos.x, worldpos.y);
        if (map != null) {
          //  print("uu"+map.toString());
          mapx = map['imagepos'][0] / map['map'].width;
          mapy = map['imagepos'][1] / map['map'].height;
          mapfile = map['map'].filename;
          mapwidth = map['map'].width;
          mapheight = map['map'].height;
        } //else

      });
    }

    // Where all the openworld updates are performed - every frame
    OPENWORLD.Actor.update(frameTime);

    if (OPENWORLD.Math.random() < 0.1) {
      OPENWORLD.Mob.update();
    }
    //_smoke.update(frameTime);
    OPENWORLD.Updateables.update(frameTime, clock.elapsedTime);

    render();
    //if (_osound != null)
    OPENWORLD.Sound.update();

    if (OPENWORLD.Math.random() < 0.1)
      OPENWORLD.Musics.update(); // dont need to do it very often

    OPENWORLD.Time.update(
        frameTime);

    OPENWORLD.Weather.update(frameTime);

    OPENWORLD.Room.update(frameTime);

    if (horseriding && ismoving) {
      // Up and down when ride horse
      OPENWORLD.Camera.setPitch(
          0.35 * math.sin(clock.getElapsedTime() * 5 % (math.pi)));
    }

    Future.delayed(Duration(
        milliseconds: framedelay), () { // was 40 which is 1000/40 = 25 fps
      animate();
    });
  }


  var lastconnection = -1;
  var doneinterval = true;

  // called every second
  clientInterval() async
  {
    // So that if in background dont keep doing interval
    if (OPENWORLD.System.appstate != AppLifecycleState.resumed || !doneinterval)
      return;

    doneinterval = false;
    var pos = OPENWORLD.Space.localToWorldObj(camera);
    print("pos: " + pos.x.toStringAsFixed(2) + ", " + pos.y.toStringAsFixed(2) +
        ", t" + OPENWORLD.Camera.turn.toStringAsFixed(
        2)); //+" shofar"+_shofar.toString());


    if ((CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTED ||
        CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTING)) {
      //print("in interval");
      // var pos = OPENWORLD.Space.localToWorldObj(camera);

      var servercommands = [];
      if (CLIENT.You.actions['who'])
        servercommands.add("who");

      if (CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTING)
        servercommands.add("connecting");

      var position = {
        "position": jsonEncode({
          "name": CLIENT.You.name,
          "x": pos.x.toString(),
          "y": pos.y.toString(),
          "z": 0.toString(),
          "turn": OPENWORLD.Space.getObjTurn(camera).toString(),
          "action": CLIENT.You.action.toString(),
          "msg": CLIENT.You.msg,
          "commands": servercommands
          // "who": camera._who,
          // "disconnect": camera._disconnect
        })
      };

      // This is hwat clears msg
      resetYou();
      // If over 10 seconds that got a response from server then display disconnect icon
      if (CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTED &&
          lastconnection >
              0 /*&&
          OPENWORLD.System.currentMilliseconds() - lastconnection > 10000*/
      )
        setState(() {
          showdisconnect = true;
        });
      else
        setState(() {
          showdisconnect = false;
        });
      // commands who, connect, disconnect
      // Why do I need to do this when I call remove_horn?

      Response response = await _session.post(
        //  "https://forthtemple.com/secondtemple/serverdart/secondtemple.php",
          position);


      log("resp- " + response.body.toString());
      if (response.body == "") {
        return;
      }
      lastconnection = OPENWORLD.System.currentMilliseconds();

      if (CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTING) {
        // user has connected
        setState(() {
          CLIENT.Connection.connect_state = CLIENT.Connection.CS_CONNECTED;
          prompttext = "Connected";
        });
        Future.delayed(Duration(seconds: 1), () {
          has_connected();
        });

        if (!removed_horn) {
          // this is causing issue when clone _shofar
          //  await OPENWORLD.Actor.unwieldAll(_shofar);
          print("removed horn");

          removed_horn = true;
        }
        //
      }
      // try {
      var ret = jsonDecode(response.body);

      var data = ret["users"];

      if (ret.containsKey('who')) {
        //&&ret["who"]) {
        setState(() {
          whos = ret["who"];
        });
      }
      // Move to where the server says to if told to
      if (ret.containsKey("player_pos")) {
        OPENWORLD.Space.worldToLocalSurfaceObj(camera, ret["player_pos"][0],
            ret["player_pos"][1], OPENWORLD.Camera.cameraoffset);
      }
      if (ret.containsKey('num_players')) {
        num_players = ret["num_players"];
      }


      // Only show max_message message
      msgs.addAll(ret["msg"]);
      if (msgs.length > max_message) {
        msgs.splice(0, msgs.length - max_message - 1);
      }
      // if a player is no longer on the server remove them
      for (var i = players.length - 1; i >= 0; i--) {
        var gone = true;
        for (var j = 0; j < data.length; j++) {
          if (players[i].userid == data[j][0])
            gone = false;
        }

        if (gone) {
          //player_mixers[i]._gone) {
          scene.remove(players[i].actor); //mixer.getRoot());
          players_removed.add(players[i]);
          players.splice(i, 1);
        }
      }

      for (var i = 0; i < data.length; i++) {
        // go through each player from server
        CLIENT.Player? player;
        // find the player in your list of current players
        var found_player = false;
        for (var j = 0; j < players.length; j++) {
          if (players[j].userid == data[i][0] || players[j].userid == "") {
            player = players[j];
            if (players[j].userid == data[i][0])
              found_player = true;
          }
        }
        // if cant find the player either reuse a removed player or create a new one
        if (player == null) {
          if (players_removed.length > 0) {
            // reuse an old player if one around
            player = players_removed[0];

            players_removed.splice(0, 1);
          } else {
            //alert('clone');
            var _has_name;
            var player_model;
            if ((players.length) % 3 == 0) {
              print("shofariii" + _shofar.toString());

              player_model =
              await OPENWORLD.Actor.copyActor(_shofar); //.clone();

            } else if ((players.length) % 3 == 1) {
              print("shofarii" + _shofar.toString());
              player_model = await OPENWORLD.Actor.copyActor(_shofar,
                  texture: "assets/actors/shofar/shofar2.jpg"); //clone();

            } else {
              print("shofar" + _shofar.toString());
              player_model = await OPENWORLD.Actor.copyActor(_shofar,
                  texture: "assets/actors/shofar/shofar3.jpg"); //.clone();

            }
            player = CLIENT.Player(
                player_model); //THREE.AnimationMixer(player_model));
          }
          scene.add(player?.actor); //mixer.getRoot());
          players.add(player);
        }

        var changed_sprite = false;
        if (!found_player || player.name != data[i][1]) {
          // If reusing old player then remove old name
          for (var kk = player.actor.children.length - 1; kk >= 0; kk--)
            if (player.actor.children[kk] is THREE.Sprite)
              player.actor.remove(player.actor.children[kk]);

          OPENWORLD.Mob.setName(player.actor, data[i][1]);
          OPENWORLD.Mob.setText(player.actor, data[i][1], z: 100);
          changed_sprite = true;
        }

        var x = double.parse(data[i][2]);
        var y = double.parse(data[i][3]);
        var z = double.parse(data[i][4]);
        var playerpos = OPENWORLD.Space.localToWorldObj(player.actor);
        player.userid = data[i][0];
        player.name = data[i][1];
        if (!changed_sprite) {
          // if existing player has moved then lerp the player to the new location
          var stopdist = 0.01;
          var dist = OPENWORLD.Math.vectorDistance(
              new THREE.Vector3(x, y, 0.14), playerpos);

          if (dist > stopdist && !player.isWalking) {
            print('is walking');
            player.isWalking = true;
            //     (await OPENWORLD.Actor.getAction(player.actor, name:"idle")).stop();// index: 3)).stop();
            //(await OPENWORLD.Actor.getAction(player.actor, name:"walk")).reset();//index: 4)).reset();
            // player.clipAction( player.getRoot().geometry.animations[4] ).reset();

            //(await OPENWORLD.Actor.getAction(player.actor, name:"walk")).play();// index: 4)).play();
            await OPENWORLD.Actor.playAction(
                player.actor, name: "walk", duration: 1, stopallactions: true);

            // player.clipAction( player.getRoot().geometry.animations[4] ).play();
          } else if (dist < stopdist && player.isWalking) {
            print('is not walking');
            player.isWalking = false;
            await OPENWORLD.Actor.playAction(
                player.actor, name: "idle2", duration: 1, stopallactions: true);
/*
            (await OPENWORLD.Actor.getAction(player.actor, name:"walk")).stop();//index: 4)).stop();
            // player.clipAction( player.getRoot().geometry.animations[4] ).stop();
            (await OPENWORLD.Actor.getAction(player.actor, name:"idle")).reset();//index: 3)).reset();
            //player.clipAction( player.getRoot().geometry.animations[3] ).reset();
            (await OPENWORLD.Actor.getAction(player.actor, name:"idle")).play();//index: 3)).play();
            // player.clipAction( player.getRoot().geometry.animations[3] ).play();*/
          }
          //print("vooot");
          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
              player.actor, x, y, 0, poll / 1000);
        } else {
          // if player has entered the game then move them straight there
          await OPENWORLD.Actor.stopAnimations(player.actor);

          (await OPENWORLD.Actor.getAction(player.actor, name: "idle"))
              .play(); //index: 3)).play();
          OPENWORLD.Space.worldToLocalSurfaceObj(player.actor, x, y, 0);
        }

        var action = data[i][6];
        if (action == "wave") {
          print("wave");
          player.isWalking = false;
          //OPENWORLD.Actor.stopAnimations(player.actor);
          await OPENWORLD.Actor.playActionThen(player!.actor, "wave", "idle2");
        }
        var turn = double.parse(data[i][5]);
        OPENWORLD.Space.objTurn(player.actor, turn);
      }

      print("msgs" + msgs.toString());
      var msglinesi = [];
      for (var i = 0; i < msgs.length; i++) {
        if (int.parse(msgs[i][0].toString()) >= 0) {
          var usename = "";
          for (var j = 0; j < players.length; j++)
            if (players[j].userid == msgs[i][0])
              usename = players[j].name;
          if (usename == "")
            usename = CLIENT.You
                .name; // if cannot find on a player must be the user himself
          //var color=colorFromName(usename);
          msglinesi.add({'usename': usename, 'msg': msgs[i][1]});
          print("added msg for " + usename + " id" + msgs[i][0].toString());
          //  msglines=msglines+"<span style='color:"+color+"'>"+msgs[i][1]+"</span><br>";
        } else {
          msglinesi.add({
            'usename': '',
            'msg': msgs[i][1]
          });
        }
      }
      setState(() {
        msglines = msglinesi;
      });
    }
    doneinterval = true;
  }

  // anything in the game that needs to be done every second
  var prevposx = -99999.0;
  var prevposy = -99999.0;
  var heartbeattick = 0;
  var ismoving = false;

  heartbeat() async {
    // So that if in background dont keep ticking
    if (OPENWORLD.System.appstate != AppLifecycleState.resumed)
      return;

    // Save player state
    var worldpos = OPENWORLD.You.getWorldPos(); //Space.localToWorldObj(camera);
    if (worldpos.x != prevposx || worldpos.y != prevposy) {
      ismoving = true;

      OPENWORLD.Persistence.set("posx", worldpos.x);
      OPENWORLD.Persistence.set("posy", worldpos.y);
      prevposx = worldpos.x;
      prevposy = worldpos.y;
    } else
      ismoving = false;
    if (horseriding) {
      if (ismoving)
        horseridingclop.setVolume(0.5);
      else
        horseridingclop.setVolume(0.01); // so doesnt turn off
    }
    OPENWORLD.Persistence.set("turn", OPENWORLD.Camera.turn);

    // Save currrent time
    OPENWORLD.Persistence.set("time", OPENWORLD.Time.time);
    // Save weather
    OPENWORLD.Persistence.set("rain", OPENWORLD.Weather.rain);
    OPENWORLD.Persistence.set("wind", OPENWORLD.Weather.wind);
    OPENWORLD.Persistence.set("cloud", OPENWORLD.Weather.cloud);
    OPENWORLD.Persistence.set("fog", OPENWORLD.Weather.fog);

    if (showfps) {
      setState(() {
        fps = frames;
      });
    }
    // print("fps"+frames.toString());
    frames = 0;
    heartbeattick++;
    if (heartbeattick % 10 == 0) {
      if (showfps)
        print("fps av " + (frames10 / 10).toString());
      if (frames10 < 200 && framedelay > 0) {
        // framedelay--;
        //  print("frame delay"+framedelay.toString());
      }
      frames10 = 0;
    }
  }

  @override
  void dispose() {
    print(" dispose ............. ");
    disposed = true;

    three3dRender.dispose();

    super.dispose();
  }
}
