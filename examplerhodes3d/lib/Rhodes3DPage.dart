
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';


import 'dart:ui';

import 'package:audioplayers/audioplayers.dart' as audioplayers;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openworld_gl/flutter_gl.dart';
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
//import 'openworld/objects/watersimple.dart';

import 'package:openworld/objects/watersimple.dart';
//import 'openworld/shaders/outline.dart';
import 'package:openworld/shaders/water2.dart';
import 'package:openworld/openworld.dart' as OPENWORLD;
import 'package:openworld/client.dart' as CLIENT;
import 'package:openworld/shaders/SkyShader.dart';

import 'package:openworld/three_dart_jsm/three_dart_jsm/controls/index.dart';
import 'package:openworld/three_dart_jsm/extra/dom_like_listenable.dart';
import 'package:http/http.dart';
import 'dart:math' as math;

String gamename='Lindos 1522';


class Rhodes3DPage extends StatefulWidget {

  Rhodes3DPage({Key? key}) //, required this.fileName})
      : super(key: key);

  @override
  createState() => _StateRhodes3D();
}

bool roomdefaultsoundloaded=false;
late audioplayers.AudioPlayer roomdefaultsound11;
late audioplayers.AudioPlayer roomdefaultsound12;
late audioplayers.AudioPlayer roomdefaultsound21;
late audioplayers.AudioPlayer roomdefaultsound22;

class _StateRhodes3D extends State<Rhodes3DPage> /*with TickerProviderStateMixin */ {
  UserGuidanceController userGuidanceController = UserGuidanceController();

  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;
  bool black = false;

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

  var mudwidth=700;
  var mudheight=650;

 // late VolumetricFire _fire;

  List<CLIENT.Player> players = [];
  List<CLIENT.Player> players_removed = [];

  bool _canfly = false;


  var poll = 1000; // How often you poll the server
  var msgs = [];
  var whos = [];
  var max_message = 5; // How many messages you show
  var num_players = 0;
  var msglines = [];

  late CLIENT.Session _session;
  String prompttext = "";
  bool showdisconnect = false;

  late THREE.Object3D boat2;
  bool boatriding = false;
  bool horseriding=false;   // This is your own horse
  late audioplayers.AudioPlayer horseridingclop;
  bool horseridingcloploaded=false;
  bool donequest=false;
  bool canhit=true;


  bool horse2riding=false;  // This is the horse with fixed routes
  late THREE.Object3D armourer;
  late THREE.Object3D postulant;
  late THREE.Object3D knight22;
  late THREE.Object3D me;
  late THREE.Object3D guard2;
  late THREE.Object3D roomQuartersdoorway;
  late THREE.Object3D jobknight;
  late THREE.Object3D roomNewsroom;
  late THREE.Object3D journalist2;
  late THREE.Object3D journalist2board;
  late Group trixie;

  // State of quest
  var journalist2newsroomseen=false;
  var journalist2beachseen=false;
  var journalist2inwait=false;
  late THREE.Object3D bandit;
  var loadedbandit=false;
  late THREE.Group amon;
  late THREE.Group horse;
  late THREE.Object3D horse2;
  bool whistle=false;

  late PopupMenuButton bottlebutton;

  Group _hotload = Group();

  String roomname = "";

  int actoroffset = 38;

  bool mapshow = false;
  double mapx = -1;
  double mapy = -1;
  late String mapfile;
  late int mapwidth;
  late int mapheight;
  THREE.Color seacolor = THREE.Color(0x064273);
  bool hidewidgets = false; // useful if want to do screenshots without controls etc showing
  bool showfps = false; // show frames per second
  int fps = -1;
  int framedelay = 40;
  double defaultcameraoffset = 0.35;   // Default player height about ground
  double horsecameraoffset= 0.35+0.2;  // How high off ground if ride horse
  // Menu variables
  double menuposx = -1;
  double menuposy = -1;
  late THREE.Object3D menuobj;
  List menuitems = [];

  // The players inventory
  List<Widget> inventorydisplay = [];
  List<Widget> inventory = [];
  List inventorynames = [];
  List inventoryvalues = [];
  List inventoryobjectids=[];

  // List of npcs can attack or attack you
  List npcs = [];
  late THREE.Object3D corpse;

  double health = 1.0;  // Your health
  double gold = 100;    // How much gold you have
  double bank = 0;      // How much gold in the bank
  String defaultweaponicon='icons/fist.png';  // Icon when wielding nothing
  String weaponicon =  ''; // Icon of what you are wielding
  bool nod=false;
  bool resurrect=false;  // show ressurect
  bool restart=false;    // show restart game

  var defaultspeed=8.0; //2m/s
  var horsespeed=25.0;
  var defaultdrag=0.5;
  var inventoryiconwidth=60.0;  // defautl width of icon for inventory

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    print("width" + width.toString() + " height" +
        height.toString()); // 896.0 height414.0

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height":height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: _options);

    setState(() {});

    // TODO web wait dom ok!!!
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

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

    initPlatformState();
  }


  @override
  void reassemble() {
    super.reassemble();
    print("hotload");
    hotload();  // If hotload then call hotload to display object in hotload straight away
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return Scaffold(

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

    return
      UserGuidance(
          controller: userGuidanceController,
          opacity: 0.5,
          tipBuilder: (context, data) {
            print("guidance controller data"+data.toString());
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
                              if (black)
                                return Container();
                              else if (kIsWeb) {
                                return three3dRender.isInitialized
                                    ? HtmlElementView(
                                    viewType: three3dRender.textureId!
                                        .toString())
                                    : Container();
                              } else {
                                return three3dRender.isInitialized
                                    ? Texture(
                                    textureId: three3dRender.textureId!)
                                    : Container();
                              }
                            })) :
                       Stack( // Load screen
                            children: [
                              Center(child: Image.asset(
                                "icons/rhodes3d2.jpg", fit: BoxFit.fitWidth, width:1600)),

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
                                                          .black.withOpacity(0.5) // Specifies the background color and the opacity
                                                  ),
                                                  child: Row(
                                                      children: [
                                                        Text(gamename,
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

                                                            child: Text(
                                                                "Loading"
                                                                ,
                                                                textAlign: TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                    fontSize: 20,
                                                                    color: Colors
                                                                        .blue,
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

                    // Display menu at position menuposx, menuposy
                    menuposx >= 0 ? Positioned(
                        top: menuposy,
                        left: menuposx,

                        child: Column(
                            children: [
                              // Show all the menu items
                              for (var item in menuitems)
                                item.containsKey('text') &&
                                    item.containsKey('command') ? TextButton(
                                  child: Text(item['text']),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Colors.black.withOpacity(0.5)),
                                  ),
                                  onPressed: () {
                                    // Trigger menu to do something when click menu that has no options
                                    menuobj.extra['touchtrigger'].triggermenu(
                                        item['command']);
                                  },
                                ) : item.containsKey('text')||item.containsKey('iconpath') ? // when just text
                                Row( children:[
                                  item.containsKey('text')?Text(item['text']):SizedBox.shrink(),
                                    item.containsKey('iconpath')?Image.asset(
                                      item['iconpath'],
                                      width: 50,
                                    ):SizedBox.shrink()
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
                                    print('get it'+item.toString());//['command']);
                                    // Trigger menu from list of items in menu eg get, wield, read, drop
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
                    loaded&&health>0.0?Positioned(  // Show health
                        child: Padding(padding: EdgeInsets.only(left: 230+inventoryiconwidth), child: Row(
                        children: inventorydisplay
                    ))):SizedBox.shrink(),
                    loaded && !hidewidgets && mapshow && mapx != -1
                        ? Stack(children: [  // Show map
                      WidgetZoom(
                          heroAnimationTag: 'tag',
                          zoomWidget: Image.asset(
                              mapfile,
                              fit: mapwidth>mapheight?BoxFit.fitWidth:BoxFit.fitHeight,//scaleDown,
                              height:
                              1 * MediaQuery
                                  .of(context)
                                  .size
                                  .height)),

                      // Display the marker on the map
                      Positioned(

                          left: mapx *
                              (1 *
                                  mapwidth *
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height) /
                              mapheight -
                              25,
                          top: mapy *
                              (1 * MediaQuery
                                  .of(context)
                                  .size
                                  .height) -
                              25,
                          child: Transform(
                            alignment: FractionalOffset.center,
                            transform: Matrix4.rotationZ(
                              THREE.MathUtils.degToRad(OPENWORLD.Camera.turn)  // Rotate the marker based on camera turn
                                  .toDouble(), //3.1415926535897932 / 4,
                            ), child: Image.asset('assets/maps/marker.png',
                              height:
                              50),
                          ))
                    ])
                        : SizedBox.shrink(),

                    !hidewidgets ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Stack(children: [
                            // Obsolete room name
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
                                            step: 4,
                                            tag: "←Swipe screen left to turn left\n"
                                                "Swipe right to turn right→ \n"
                                                "↑ Swipe up to look up \n"
                                                "↓ Swipe down to look down ",
                                            child: Container(width: 10,
                                                height: 10) //,color:Colors.black)
                                        )
                                      ])
                                ]),


                            Row(

                            children:[
                              !kIsWeb?SizedBox(width:200):SizedBox.shrink(),

                            // Show the weapon icon and if click the icon strike the npc
                            weaponicon!=''&&!mapshow? IconButton(
                              tooltip: weaponicon==null||weaponicon==""||weaponicon==defaultweaponicon?"Punch":"Slash",
                              icon: Image.asset(
                                   weaponicon,
                                  fit: BoxFit.fitHeight,
                                  height: inventoryiconwidth,
                                 ),
                              //     iconSize: 20,
                              onPressed: () {
                                if (!canhit)
                                  return;
                                // Show yourself slashing
                                OPENWORLD.Actor.playActionThen(
                                    me, "slash", "idle", duration: 1,
                                    durationthen: 2);

                                // If wielding something slash sound otherwise punch sound
                                if (OPENWORLD.You.wield == null ||
                                    OPENWORLD.You.wield == "")
                                  OPENWORLD.Sound.play(
                                      path: 'sounds/punch.mp3', volume: 1);
                                else //if (OPENWORLD.You.wield=="sword")
                                  OPENWORLD.Sound.play(
                                      path: 'sounds/slash.mp3', volume: 1);

                                // Get the damage you deal given what you are wielding
                                var damage = getYouDamage();

                                // Get the closest npc in range
                                var mindist = 999.0;
                                var minnpc = null;
                                for (var npc in npcs) {
                                  if (!actorIsDead(npc)) {
                                    var dist = OPENWORLD.Space.getDistanceBetweenObjs(camera, npc); //, object2) OPENWORLD.Math.vectorDistance(
                                    var angletofire = OPENWORLD.Space.getAngleBetweensObjs(camera, npc);

                                    var anglecamera = OPENWORLD.Camera.turn;

                                    var anglediff = (OPENWORLD.Math.angleDifference(angletofire, anglecamera).abs());
                                    if (dist < 2) {
                                      var pos1 = OPENWORLD.Space.localToWorldObj(camera);
                                      var pos2 = OPENWORLD.Space.localToWorldObj(npc);
                                      print(
                                          "dist hit" + dist.toStringAsFixed(2) + " " + anglediff.abs().toStringAsFixed(2) + " angle direct" + angletofire.toStringAsFixed(2) +
                                              " " + OPENWORLD.Math.standardAngle(anglecamera).toStringAsFixed(2) + " " +
                                              pos1.x.toStringAsFixed(2) + " " + pos1.y.toStringAsFixed(2) + " " + pos2.x.toStringAsFixed(2) + " " + pos2.y.toStringAsFixed(2) + " " +
                                              OPENWORLD.Mob.getName(npc));
                                    }

                                    if (((dist < 0.7 && anglediff.abs() < 15) ||
                                        (dist < 0.5 && anglediff.abs() < 30))) {
                                      if (dist < mindist) {
                                        if (dist < 2)
                                          print("use as hit" + dist.toString());
                                        mindist = dist;
                                        minnpc = npc;
                                      }
                                    }
                                  }
                                }
                                // If npc found then hit
                                if (mindist != 999.0) {

                                  print("hit" + " name:" + OPENWORLD.Mob.getName(minnpc));
                                  actorStruck(minnpc); // Animation to strike the npc
                                  OPENWORLD.Sound.play(
                                      path: 'sounds/struck.mp3', volume: 1);  // Struck sound when hit npc
                                  if (OPENWORLD.BaseObject.hasCustomTrigger(minnpc, "strucktrigger")) {
                                    // If npc has customer struck trigger then call it
                                    print("actor struck custom strucktrigger" + OPENWORLD.Mob.getName(minnpc));

                                    minnpc.extra['customtrigger'].trigger('strucktrigger', 5);
                                    //    OPENWORLD.BaseObject.clearTimers(npc);
                                  } else {
                                    // If no custom struck trigger use default
                                    print(
                                        "actor hit" + damage.toString() + " " +
                                            getActorHealth(minnpc).toString());
                                    // Set new health of actor when hit based on the damage you dealt
                                    setActorHealth(minnpc,
                                        getActorHealth(minnpc) - damage);
                                    // Have actor face you
                                    OPENWORLD.Space.faceObjectLerp(
                                        minnpc, camera, 1);
                                    if (getActorHealth(minnpc) <=
                                        0) {
                                      // If actors health is less than or equal to zero then is dead
                                      print("actor now is dead");
                                      // Show actor death animation
                                      actorDie(
                                          minnpc); // This is where sets to dead
                                      // remove any distance triggers the npc has
                                      OPENWORLD.BaseObject
                                          .disableDistanceTrigger(minnpc);
                                      // clear any text the npc is showing
                                      OPENWORLD.Mob.clearText(minnpc);
                                      // Clear all timers that npc has such as moving and lerping
                                      OPENWORLD.BaseObject.clearTimers(minnpc);
                                    }
                                  }
                                }
                              }
                            ):SizedBox.shrink()]),

                            showfps&&fps>0 ? Text(" FPS:" + fps.toString(),
                                style: TextStyle(fontSize: 15,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)) : SizedBox
                                .shrink(),
                            !kIsWeb && loaded
                                ? Container(
                              //   margin:EdgeInsets.only(top:30),
                                child: UserGuildanceAnchor(
                                    step: 1,
                                    tag: "Move up for going forward.\n"
                                        "Move  down to go backwards\n"
                                        "Move left/right to turn left/right",
                                    child: Joystick(
                                      base: JoystickBase(  // Show the joystick
                                        decoration: JoystickBaseDecoration(
                                          color: Colors.transparent,
                                          drawOuterCircle: false,
                                        ),
                                        arrowsDecoration: JoystickArrowsDecoration(
                                            color: Colors.blue,
                                            enableAnimation: false),
                                      ),
                                      listener: (details) {
                                        if (this.loaded)    //when move joystick send to openworld joystick controller
                                          this
                                              ._joystick
                                              ?.onStickChange(
                                              details.x, details.y);
                                      },

                                      onStickDragEnd: () {
                                        if (this.loaded) this._joystick
                                            ?.onStickUp();
                                      },
                                    )))
                                : SizedBox.shrink(),

                          ]),
                          // Expanded(child: SizedBox.shrink()),

                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                loaded ? Container(
                                    width: 400,

                                    decoration: BoxDecoration(
                                      // border: Border.all(color: Colors.blueAccent)
                                    ),
                                    child: Row(
                                        children: [
                                          Spacer(),
                                          nod?WidgetAnimator(
                                            //    atRestEffect: WidgetRestingEffects.pulse(), //WidgetRestingEffects.swing(),
                                              atRestEffect: WidgetRestingEffects.pulse(),

                                              // Used for jobknight where need to nod to say you want to do a job for the knight
                                              child:Column(
                                                  children:[
                                                    Text("Nod"),
                                                    IconButton(
                                                tooltip: "Click for Yes",
                                                icon: Icon(Icons.thumb_up_alt_outlined),
                                                iconSize: 25,
                                                style: IconButton.styleFrom(
                                                  shape: CircleBorder(),
                                                  padding: EdgeInsets.all(0),
                                                  backgroundColor: Colors.black
                                                      .withOpacity(0.2),
                                                  // <-- Button color
                                                  foregroundColor: Colors
                                                      .green, // <-- Splash color
                                                ),
                                                color: Colors.white,
                                                onPressed: () {
                                                  print("doorwya nod");

                                                  // Nod your head
                                                  var worldpos=OPENWORLD.You.getWorldPos();
                                                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(camera, worldpos.x,worldpos.y+0.01, OPENWORLD.Camera.cameraoffset-0.01, 0.15);
                                                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(camera, worldpos.x,worldpos.y+0.0, OPENWORLD.Camera.cameraoffset, 0.15, delay:0.15);
                                                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(camera, worldpos.x,worldpos.y+0.01, OPENWORLD.Camera.cameraoffset-0.01, 0.15, delay:0.3);
                                                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(camera, worldpos.x,worldpos.y+0.0, OPENWORLD.Camera.cameraoffset, 0.15, delay:0.45);

                                                  // Call trigger telling jobknight that player has nodded
                                                  if (jobknight.extra.containsKey('customtrigger')) {
                                                    print("trigger nod");
                                                    jobknight
                                                        .extra['customtrigger']
                                                        .trigger(
                                                        'nodtrigger', true);
                                                  }
                                                },
                                              )])):SizedBox.shrink(),
                                          SizedBox(width:50,
                                              child:LinearProgressIndicator(  // Show health
                                                backgroundColor: Colors.red,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                                value: health,//controller.value,
                                                minHeight:10,
                                                semanticsLabel: 'Linear progress indicator',
                                              )),

                                          Column( // Show gold
                                            children:[
                                              Text(gold.round().toString()),
                                          Image.asset(
                                              'icons/coins.png',
                                              width: 30, height: 30),
                                          ]),
                                          (horseriding||donequest)&&health>0&&!OPENWORLD.You.immobile?IconButton(  // Show horse dismount or mount icon
                                            // alignment: Alignment.topRight,
                                            tooltip: horseriding?"Dismount":"Call horse",
                                            icon: Image.asset(
                                                'icons/horse.png',
                                                width: 40, height: 40),
                                            iconSize: 20,
                                            style: IconButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(0),
                                              backgroundColor: Colors.black
                                                  .withOpacity(0.2),

                                              foregroundColor: Colors
                                                  .white, // <-- Splash color
                                            ),
                                            color: Colors.white,
                                            onPressed: () {
                                              if (horseriding) {
                                                // If already riding then dismount
                                                var worldpos = OPENWORLD.You
                                                    .getWorldPos();
                                                var dismountpos=OPENWORLD.Math.vectorMoveFoward(worldpos.x, worldpos.y,OPENWORLD.Camera.turn, 0.52);
                                                OPENWORLD.Space
                                                    .worldToLocalSurfaceObjLerp(
                                                    camera,
                                                    dismountpos.x,//worldpos.x,
                                                    dismountpos.y,// worldpos.y + 0.52,
                                                    defaultcameraoffset, 1,
                                                    delay: 1);
                                                horseriding = false;
                                                OPENWORLD.You.speed=defaultspeed;
                                                horseridingclop.stop();
                                                Future.delayed(Duration(
                                                    milliseconds: (1000)
                                                        .round()), () async {
                                                  OPENWORLD.Camera
                                                      .cameraoffset =
                                                      defaultcameraoffset;
                                                  OPENWORLD.Sound.play( path: 'sounds/horse.mp3', volume: 0.5);

                                                });
                                              } else {
                                                // If not riding horse then call it
                                                callHorse();
                                              }
                                            },
                                          ):SizedBox.shrink(),

                                          whistle?IconButton(
                                            alignment: Alignment.center, // Call amon the guide
                                            tooltip: "Amon the guide",
                                            //  icon: Icon(FontAwesomeIcons.peopleGroup),//Icons.people),
                                            icon: Image.asset(
                                                'assets/textures/whistle.png',
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
                                              print("call guide");

                                              callGuide();

                                            },
                                          ):SizedBox.shrink(),

                                          resurrect?WidgetAnimator(  // If dead and need to resurrect show ressurect icon
                                              atRestEffect: WidgetRestingEffects
                                                  .size(),
                                              child: IconButton(
                                                tooltip: "Resurrection",
                                                icon: Icon(FontAwesomeIcons.cross),
                                                //     iconSize: 20,
                                                onPressed: () async {

                                                  // When resurrect in church restore health and show flares
                                                  var dist = OPENWORLD.Math.vectorDistance(THREE.Vector3(374.846, 272.103, 0.14),OPENWORLD.You.getWorldPos());
                                                  print("dist" +dist.toString());
                                                  if (dist < 1) {
                                                    Flares flares = Flares();
                                                    Group flaresobj = await flares.createFlares(
                                                        "assets/textures/flares/lensflare2.jpg",
                                                        "assets/textures/flares/lensflare0.png");
                                                    OPENWORLD.Space.worldToLocalSurfaceObj(flaresobj, 374.846,272.103, 5);
                                                    flaresobj.scale.set(0.1, 0.1, 0.1);
                                                    scene.add(flaresobj);
                                                    OPENWORLD.Space.worldToLocalSurfaceObjLerp(flaresobj, 374.846,272.103, 0.2, 8);
                                                    Fluttertoast.showToast(
                                                        msg: "You pray to the almighty...",
                                                        toastLength: Toast
                                                            .LENGTH_LONG);
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 5 *
                                                                1000), () async {
                                                      OPENWORLD.Sound.play(path: "sounds/god.mp3", volume: 1);
                                                      Fluttertoast.showToast(
                                                          msg: "You feel your life force return to you...",
                                                          toastLength: Toast
                                                              .LENGTH_LONG);
                                                      OPENWORLD.You.immobile = false;
                                                      setState(() {
                                                        weaponicon=defaultweaponicon;
                                                        resurrect=false;
                                                      });


                                                      setHealth(1);
                                                      Future.delayed(
                                                          const Duration(
                                                              milliseconds: 10 *
                                                                  1000), () async {
                                                        flaresobj.visible = false;
                                                      });
                                                    });
                                                  }

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
                                              )):SizedBox(),
                                          restart?WidgetAnimator( // If need to restart ie when put in prison

                                                atRestEffect: WidgetRestingEffects
                                                    .size(),

                                               child: IconButton(
                                                tooltip: "Restart",
                                                icon: Icon(Icons.restart_alt),
                                                onPressed: ()  {

                                                  OPENWORLD.Persistence.reset();
                                                  close(pop:false);
                                                  setHealth(1);
                                                  initPage();

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
                                              )):SizedBox(),
                                          loaded &&
                                              !kIsWeb&&CLIENT.Connection.connect_state ==
                                                  CLIENT.Connection.CS_NONE
                                              ? UserGuildanceAnchor(  // Multiplayer
                                              step: 3,
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
                                              step: 2,
                                              tag: "Display map of where you are",
                                              child: IconButton(
                                                tooltip: "Show a map",
                                                iconSize: 20,
                                                icon: const Icon(  // Show the map
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
                                              showdisconnect ? Row(children: [  // if connected show multiplayer controls
                                            SizedBox(height: 30,
                                                child: VerticalDivider(
                                                    thickness: 2,
                                                    width: 10,
                                                    color: Colors.black
                                                        .withOpacity(0.3))),
                                            IconButton(
                                              alignment: Alignment.center, // if multiplayer find out whos on
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
                                              tooltip: "Speak",  // if multiplayer say something
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
                                            IconButton(  // If multiplayer wave your hand
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
                                                showdisconnect ? IconButton(  // disconnect from multiplayer game
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
                                          IconButton( // show settings
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
                                              setState(() {
                                                // loaded=true;
                                                //   _globalKey.currentState?.pause = false;
                                              });
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
                                          IconButton(  //close game
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
                                              // show multiplayer chat
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
                                _canfly
                                    ? Column(children: [
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
                                        child: Image.asset('icons/arrow.png')),
                                    iconSize: 50,
                                    onPressed: () {
                                      flydown();
                                    },
                                  ),
                                ])
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

  var lastclosewalltick=-1;

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

    // All openworld updates
    OPENWORLD.Space.update(delta);
    OPENWORLD.Light.update();  // must be before space update otherwise night only will override hide
    OPENWORLD.BaseObject.update(delta);
    OPENWORLD.Texture.update(delta);

    if (prevlocalx != camera.position.x || prevlocalz != camera.position.z) {

      // Wall detection - if hit wall put player back to where they were
      // calculate objects intersecting the picking ray
      var distintersect =
      OPENWORLD.Space.distanceWall(prevlocalx, prevlocaly, prevlocalz);

      if (distintersect >= 0) {

        if (distintersect<1)
          lastclosewalltick=OPENWORLD.System.currentMilliseconds();

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
      // If riding horse speed up
      var usespeed;
      if (horseriding)
        usespeed=horsespeed;
      else
        usespeed=defaultspeed;
      if (OPENWORLD.System.currentMilliseconds()-lastclosewalltick<2000) {

        OPENWORLD.You.speed = usespeed / 2;
      }  else {
        OPENWORLD.You.speed = usespeed;
      }
      var worldpos = OPENWORLD.You.getWorldPos();
      OPENWORLD.Config.showPoolsObjects(worldpos.x, worldpos.y);



      if (boatriding) {
        if (camera.position.y >= 0.2) {
          // Get off the boat because now on land
          print("exit boat");
          boatriding = false;
          print("move forward" + OPENWORLD.You.getMoveDir().toString());
          boat2.position.y = 0.1;

          OPENWORLD.Camera.cameraoffset = defaultcameraoffset;
          OPENWORLD.Space.objMoveAngleSurface(
              camera, OPENWORLD.You.getMoveDir(), 2,
              OPENWORLD.Camera.cameraoffset);

          OPENWORLD.BaseObject.reenableDistanceTrigger(boat2);
        } else {
          // move boat forward along with camera while sailing
          OPENWORLD.Camera.cameraoffset = 0.15;
          OPENWORLD.Space.worldToLocalSurfaceObj(
              boat2, worldpos.x, worldpos.y, 0);
          OPENWORLD.Space.objTurnLerp(boat2, OPENWORLD.Camera.turn, 0.5);
          OPENWORLD.Space.objForward(boat2, 0.15);
          if (camera.position.y < 0.2) {
            camera.position.y = 0.2 + 0.15;
            boat2.position.y = 0.2;
          }
        }
      }

      if (horseriding) {
        if (camera.position.y <= 0.2||OPENWORLD.You.indoors()) {
          // Get off the horse because in sea
          print("exit horse");
          horseriding = false;
          horseridingclop.stop();

          OPENWORLD.Camera.cameraoffset = defaultcameraoffset;

          OPENWORLD.Sound.play( path: 'sounds/horse.mp3', volume: 0.5);

          if (horse.parent==scene) {
            scene.remove(horse);
            horse.visible=false;
          }
          OPENWORLD.BaseObject.reenableDistanceTrigger(horse);
        } else {
          // Move horse along with camera and set camera higher
          OPENWORLD.Camera.cameraoffset = horsecameraoffset;// 0.15;
          OPENWORLD.Space.worldToLocalSurfaceObj(
              horse, worldpos.x, worldpos.y, 0);
          OPENWORLD.Space.objTurnLerp(horse, OPENWORLD.Camera.turn, 0.5);

        }
      }
      OPENWORLD.You.update();

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
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);

    renderer!.shadowMap.enabled = true;

    // renderer!.outputEncoding = THREE.sRGBEncoding;

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
  hotload() async {
    print("hotload");

    _hotload.clear();

    // Display grass
    var grassorig = await OPENWORLD.Sprite.loadSprite(
        "assets/textures/grass2.png", 0.4, 0.25, ambient: true);//, z:1);

    var grasss=[[467.15, 354.60],
      [468.82, 354.61],
    [469.51, 354.27],
    [471.02, 353.66],
    [472.90, 352.59],
    [474.63, 351.95],
      [303.14, 428.20],
      [305.48, 427.56],
      [303.77, 429.11],
      [306.09, 428.45],
      [304.36, 427.90],
      [304.93, 433.70],[308.96, 427.71], [300.79, 427.31]  // bandit
    ];

    for (var pos in grasss) {
      var grass=OPENWORLD.Sprite.cloneSprite(grassorig);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          grass,pos[0], pos[1], 0.0,8);
      scene.add(grass);
    }

    // Display trees
    var cypresstreeorig = await OPENWORLD.Model.createModel(
        'assets/models/tree2.glb');
    OPENWORLD.Texture.setEmissive(cypresstreeorig,THREE.Color(0x222222));
    cypresstreeorig.scale.set(0.015,0.015,0.015);
    //cypresstreeorig.scale.set(0.15,0.15,0.15);
    var trees=[
    [470.51, 349.06],
    [474.98, 351.08],
     //  [363.45, 314.27],
      [356.20, 325.89],
      [348.76, 338.22],
      [342.44, 348.70],
      [335.82, 364.70],
      [337.05, 381.76],
      [328.23, 397.76],
      [329.74, 418.88],
      [305.82, 429.14],
      [303.98, 428.44],
      [303.41, 429.67],
      [201.77, 117.85],
      [195.34, 120.55],
      [194.85, 114.84],
      [193.79, 109.77],
      [199.32, 111.09],
      [123.096,512.404] // wilddog
    ];
    for (var pos in trees) {
      var cypresstree=cypresstreeorig.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cypresstree,pos[0], pos[1], 0.0,25);
      scene.add(cypresstree);
    }

    // Display rock
    var rockorig = await OPENWORLD.Model.createModel(
        'assets/models/rock.glb');
    rockorig.scale.set(0.007,0.007,0.007);
    var rocks=[
      [471.86, 353.02],
      [474.31, 351.48],
      [469.45, 349.86],
      [466.10, 354.48 ],
      [303.60, 428.44],
      [305.25, 428.55],
      [303.99, 429.92]
    ];
    for (var pos in rocks) {
      var cypresstree=rockorig.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cypresstree,pos[0], pos[1], 0.0,8);
      OPENWORLD.Space.objTurn(cypresstree,OPENWORLD.Math.random()*360);
      scene.add(cypresstree);
    }


  }

  // Help dialog
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
                          Text("Help the Knights Hospitaller stave off the coming invasion",
                              style: TextStyle(fontSize: 15)),
                          SizedBox(height: 10),
                          GestureDetector(
                              onTap: () {
                                launchUrl(Uri.parse(
                                    "https://forthtemple.com/rhodes3d/"));

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

  // Setting dialog
  settings(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();
    bool soundon = !OPENWORLD.Sound.mute;
    bool musicon = !OPENWORLD.Musics.mute;
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
                              // tristate: true,
                              value: soundon,
                              onChanged: (value) {
                                setState(() {
                                  soundon = value!;
                                  // print("changed checkbox"+value.toString()+" "+music.toString());
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
                                  // print("changed checkbox"+value.toString()+" "+music.toString());
                                });
                              },
                            ),
                            Text('Music On')]),
                      Row(
                          children: [
                            Checkbox(
                              // tristate: true,
                              value: reset,
                              onChanged: (value) {
                                setState(() {
                                  reset = value!;
                                  // print("changed checkbox"+value.toString()+" "+music.toString());
                                });
                              },
                            ),
                            Text('Reset Game')]),
                      //  Text('Would you like to approve of this message?'),
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

  // Generic prompt dialog
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
                  //    decoration: InputDecoration(hintText: "Text Field in Dialog"),
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

  // Multiplayer chat dialog
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
                //    tooltip:"Speak",
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

  // Set the default size of an actor and share animations with armourer
  setDefaultActor(actor) {
    actor.scale.set(0.006, 0.006, 0.006); //25, 0.0025, 0.0025);
    if (actor != armourer)
      OPENWORLD.Actor.shareAnimations(actor, armourer);
  }

  // Is the actor dead
  actorIsDead(actor)
  {
    return actor.extra.containsKey('dead')&&actor.extra['dead'];
  }

  // Set the actor to be dead and play death animation and call custom death trigger if available
  // If get corpse then when dies will create a corpse you can take
  actorDie(actor) async //, {diesoundpath}) async
  {
    if (!actor.extra.containsKey('dead')) {
      // if (OPENWORLD.Actor.hasAnimation(actor, "die")) {  // eg rat might not have dead animation
      actor.extra['dead'] = true;

      OPENWORLD.BaseObject.clearAll(actor);

      print("play die dead");
      Future.delayed(const Duration(milliseconds: 200), () async {
        await OPENWORLD.Actor.playActionThen(
            actor, "die", "dead", duration: 1, durationthen: 2);
        //  }
        if (actor.extra.containsKey('deathsoundpath'))
          OPENWORLD.Sound.play(
              path: actor.extra['deathsoundpath'], volume: 1, delay: 0.5);
      });


      if (OPENWORLD.BaseObject.hasCustomTrigger(actor, "deadtrigger")) {
        print("Has dead trigger");
        actor.extra['customtrigger'].trigger('deadtrigger',null);
      } else {
        print("has no dead trigger");
      }
      if (actor.extra.containsKey('getcorpse') && actor.extra['getcorpse']) {
        Future.delayed(const Duration(milliseconds: 3 * 1000), () async {
          var button;
          setGetObject(actor, scalenotselected: 1.05, scaleselected: 1.05);
          actor.extra['touchtrigger'].addEventListener(
              'triggermenu', (THREE.Event event) {
                print("triggermenu corpse");
            // pick up corpse
            //scene.add(helmet);
            button = PopupMenuButton(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  "icons/corpse.png",
                  width: 50,
                ),
              ),
              onSelected: (value) async {
                if (value == "drop") {
                  var corpseclone = corpse.clone();
                  scene.add(corpseclone);
                  OPENWORLD.Space.placeBeforeCamera(corpseclone, 1);

                  for (var i = 0; i < inventory.length; i++) {
                    if (inventory[i] == button) {
                      removeInventory(inventorynames[i]);
                    }
                  }
                  //OPENWORLD.Space.readdObjFromHide(bottle);
                }
              },
              itemBuilder: (BuildContext context) =>
              <PopupMenuEntry>[
                PopupMenuItem(
                  value: "drop",
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.download),
                      ),
                      const Text(
                        'Drop',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),

              ],
            );

            removeObject(actor);
            OPENWORLD.Sound.play( path: 'sounds/bag.mp3', volume: 0.2);

            OPENWORLD.BaseObject.highlight(actor, false);
            addInventory('corpse_' + actor.extra['corpsename'], button, 0);
          });
        });
      }
    }

  }

  // Health of [actor]
  getActorHealth(actor)
  {
    if (actor.extra.containsKey("health"))
      return actor.extra['health'];
    else
      return 1.0;
  }

  // Set the actors health
  setActorHealth(actor,h)
  {
    if (h<0) {
      h = 0;
     // actor.extra['dead']=true;
    } else if (h>1)
      h=1;
    actor.extra['health']=h;

  }

  // Set the actor to attacks you
  actorAttack(actor, {attackaction:"punch"})
  {
    if (actorIsDead(actor)) {
      print("actor is already dead");
      return;
    } else if (actorIsAttacking(actor)) {
      print("actor already attacking");
      return;
    }
    print("attack");
    // Have actor walk in front of you
    OPENWORLD.Space.faceObjectAlways(actor, camera);
    OPENWORLD.Mob.placeBeforeCamera(
        actor, 0.4, speed: 0.2, action: "walk", stopaction: "idle");

    var t = Timer.periodic(Duration(seconds: 5), (timer) {

      // 2D because is on hill so may not be 0.4 otherwise
      var dist = OPENWORLD.Space.getDistanceBetweenObjs2D(camera, actor);
      if (actorIsDead(actor)) {
        // If dead stop looping
         timer.cancel();
      } else if (dist > 0.5) {
        // Actor is too far away to walk before camera
        print("dist actor" + dist.toString());
        OPENWORLD.Mob.placeBeforeCamera(actor, 0.4, speed: 0.2,
            //    delay: 3,
            action: "walk",
            stopaction: "idle");
      } else if (!isDead()) {
        // Have actor strike you with an attack action animation
        print("actor attack");
        OPENWORLD.Actor.playActionThen(
            actor, attackaction, "idle", duration: 1,
            durationthen: 2); //, delay:5);
        // Shift camera to show you are struck
        youStruck();

        // Subtract the damage from your health
        setHealth(health - getActorDamage(actor));
        if (isDead()) { //health<=0) {
          // If you die go to the endo
          Fluttertoast.showToast(
              msg: "Your life force drifts away from you...",
              toastLength: Toast.LENGTH_LONG);
          youDie();
          endo(delay: 10);
          timer.cancel();
        }
      }

      // }

    });
    OPENWORLD.BaseObject.addTimer(actor, t);
    actor.extra['attacktimer']=t;
  }

  // Is the attacking you
  actorIsAttacking(actor)
  {
    return actor.extra.containsKey('attacktimer')&&OPENWORLD.BaseObject.getTimers(actor).contains(actor.extra['attacktimer']);
  }

  // Call the horse to you
  callHorse()
  {
    if (underSea()) {
      Fluttertoast.showToast(
          msg: "Unfortunately you cannot call your horse while underwater",
          toastLength: Toast.LENGTH_LONG);

    } else if (boatriding) {
      Fluttertoast.showToast(
          msg: "Unfortunately you cannot call your horse while sailing a boat",
          toastLength: Toast.LENGTH_LONG);

    } else if (OPENWORLD.You.indoors()) {
      Fluttertoast.showToast(
          msg: "Unfortunately you cannot call your horse while indoors",
          toastLength: Toast.LENGTH_LONG);
    } else {
      if (horse.parent != scene)
        scene.add(horse);
      // When call horse have it appear in front of camera
      horse.visible=true;

      OPENWORLD.Mob.placeBeforeCamera(
          horse, 3, offset: 2, time: 1, action: "walk", stopaction: "idle");
      OPENWORLD.Mob.placeBeforeCamera(
          horse, 1.3, time: 2, action: "walk", stopaction: "idle", delay: 1.1);
      Future.delayed(Duration(milliseconds: (3000).round()), () {
        OPENWORLD.BaseObject.setDistanceTrigger(horse, dist: 0.5);
        // Ride horse when you get within 0.5 of it
        horse.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
          //print("horse trigger");
          if (event.action) {
            if (!horseridingcloploaded) {
              horseridingcloploaded=true;
              horseridingclop = OPENWORLD.Sound.getAudioPlayer();
            }
            OPENWORLD.Sound.play(
                sound: horseridingclop,
                path: "sounds/horseclop.mp3",
                volume: 0.5,
                loop: true,
                fadein: 2,
                delay: 2);
            horseriding = true;
            OPENWORLD.You.speed=horsespeed;  // Increase your speed

            // Neigh when you get on the horse
            OPENWORLD.Sound.play( path: 'sounds/horse.mp3', volume: 0.5);

            // If the jobknight is near by then have the jobknight say have fun
            var dist=OPENWORLD.Space.getDistanceBetweenObjs(jobknight, camera);
            if (dist<5) {
              // When ride off says 'have fun' instead of sticking on 'take this stead'
              OPENWORLD.Mob.setSpeech(jobknight, [
                "Have fun"], z: 80,
                  width: 300,
                  scale: 0.4,
                  randwait: 0,
                  minwait: 5);
            }
            print("horse move forward" + OPENWORLD.You.getMoveDir().toString());


          } else {

          }
        });
      });
    }
  }

  // Has completed quest of finding spy
  foundTraitor()
  {
    if (!donequest) {
      print("found traitor");
      Future.delayed(Duration(milliseconds: (15 * 1000).round()), () async {
        setState(() {
          donequest = true;
        });
        OPENWORLD.Persistence.set("donequest", donequest);
        // Immobilize player so can reward him
        OPENWORLD.You.immobile = true;
        OPENWORLD.You.immobileturn = true;
        canhit=false;

        // Call a horse as a prize to the player
        callHorse();

        // Have amon, trixie and jobknight appear before you to cheer you
        OPENWORLD.BaseObject.clearAll(amon);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            amon, 305.03, 422.32, 0, 8);
        OPENWORLD.Space.objTurn(amon, 0); //n
        // scene.add(amon);
        OPENWORLD.Mob.placeBeforeCamera(
            amon, 0.8, speed: 0.15,
            offset: 0.3,
            action: "walk",
            stopaction: "idle2");
        OPENWORLD.Space.faceObjectAlways(amon, camera, delay: 9);
        OPENWORLD.Actor.playAction(amon, name: "clap",
            duration: 1,
            randomduration: 0.1,
            delay: 12,
            loopmode: THREE.LoopOnce);
        OPENWORLD.Actor.playAction(
            amon, name: "idle2", stopallactions: true, delay: 16);


        OPENWORLD.BaseObject.clearAll(trixie);
        OPENWORLD.BaseObject.disableDistanceTrigger(trixie);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            trixie, 304.83, 422.32, 0, 8);
        OPENWORLD.Space.objTurn(trixie, 0); //n
        // scene.add(amon);
        OPENWORLD.Mob.placeBeforeCamera(
            trixie, 0.8, speed: 0.15,
            offset: 0.6,
            action: "walk",
            stopaction: "idle");
        OPENWORLD.Space.faceObjectAlways(trixie, camera, delay: 9);
        OPENWORLD.Mob.setSpeech(trixie, [
          "You're my hero",
          //  "I'm yours",
          "I'll do anything you want",
          "I love you"], z: 80,
            width: 300,
            scale: 0.4,
            randwait: 0,
            minwait: 5,
            delay: 12 + 5 * 5);
        OPENWORLD.Actor.playAction(trixie, name: "clap",
            duration: 1,
            randomduration: 0.2,
            loopmode: THREE.LoopOnce,
            delay: 12.2);


        OPENWORLD.BaseObject.clearAll(jobknight);
        OPENWORLD.BaseObject.disableDistanceTrigger(jobknight);

        OPENWORLD.Space.faceObjectLerp(jobknight, camera, 1, delay: 1);

        OPENWORLD.Mob.placeBeforeCamera(
            jobknight, 2, offset: 2,
            time: 1,
            action: "walk",
            stopaction: "idle");

        OPENWORLD.Mob.placeBeforeCamera(
            jobknight, 0.6, time: 2,
            action: "walk",
            offset: -0.1,
            stopaction: "idle2",
            delay: 10);
        OPENWORLD.Space.faceObjectLerp(jobknight, camera, 1, delay: 13);
        OPENWORLD.Actor.playAction(jobknight, name: "clap",
            duration: 1,
            randomduration: 0.2,
            loopmode: THREE.LoopOnce,
            delay: 12.2);
        OPENWORLD.Actor.playAction(
            jobknight, name: "idle2", stopallactions: true, delay: 16);
        OPENWORLD.Sound.play(path: 'sounds/clap.mp3', volume: 1, delay: 12);

        OPENWORLD.Mob.setSpeech(jobknight, [
          "You've found the spy!",
          "You've done so much to save Lindos",
          "Now Sulamein is going to have a much tougher time",
          "As the knight prefect I make you an honoury knight",
          "And what knight doesnt have a horse",
          "Take this stead"], z: 80,
            width: 300,
            scale: 0.4,
            randwait: 0,
            minwait: 5,
            delay: 12);

        OPENWORLD.Space.faceObjectLerp(
            jobknight, horse, 1, delay: 12 + 5 * 5 + 1);
        OPENWORLD.Actor.playAction(
            jobknight, name: "point", delay: 12 + 5 * 5 + 1);
        OPENWORLD.Actor.playAction(jobknight, name: "idle2",
            stopallactions: true,
            delay: 12 + 5 * 5 + 1 + 1);
        OPENWORLD.Space.faceObjectAlways(
            jobknight, camera, delay: 12 + 5 * 5 + 3 + 1);
        OPENWORLD.Sound.play(
            path: 'sounds/cheer.mp3', volume: 1, delay: 12 + 5 * 5 + 3 + 1);

        // Now that have cheered player, let him move again
        OPENWORLD.You.setImmobile(false, delay: 12 + 5 * 5 + 3 + 1);
        OPENWORLD.You.setImmobileTurn(false, delay: 12 + 5 * 5 + 3 + 1);

        Future.delayed(Duration(seconds: (12 + 5 * 5 + 3 + 1).round()), () async {
          canhit=true;
        });

      });
    }
  }

  // Set the value of an object eg a broom
  setValue(THREE.Object3D obj, name, value) {
    obj.extra['value'] = value;
    obj.extra['namevalue'] = name;
  }

  // Get the value of an object
  getValue(THREE.Object3D obj) {
    return obj.extra['value'] ?? 0;
  }

  getNameValue(obj) {
    return obj.extra['namevalue'] ?? "";
  }

  // Give the price given its markup
  getBuyPrice(amt, markup) {
    return amt * markup;
  }

  // Give the sell price given its markdown
  getSellPrice(amt, markdown) {
    return amt * markdown;
  }

  // Show formatted money
  displayMoney(value) {
    return value.toStringAsFixed(2);
  }

  // Add an npc that can be killed
  // If getcorpse true then can loot a corpse
  // If deathsoundpath set then will play that sound when the npc dies
  addnpc(actor, name, getcorpse, {deathsoundpath}) //, attackwhenhit)
  {
    npcs.add(actor);
    actor.extra['getcorpse'] = getcorpse;
    actor.extra['corpsename'] = name;
    if (name!="")
      OPENWORLD.Mob.setName(actor,name);
    if (deathsoundpath!=null)
      actor.extra['deathsoundpath']=deathsoundpath;
  }

  // Add a human npc
  // If you cant kill the npc you either go to prison or die and go to endo
  addcitizennpc(actor, name, cankill)
  {
    addnpc(actor,name,false, deathsoundpath: "sounds/die.mp3");
    OPENWORLD.BaseObject.setCustomTrigger(actor);//, dist: 1.5);
    // postie.extra['strucktrigger']=StruckTrigger();
    print("add citizennpc"+name);
    actor.extra['customtrigger'].addEventListener('strucktrigger', (THREE.Event event) {
      // This is you striking actor
      print("citizen struck trigger"+name);
      if (!cankill) {
        print("struck" + event.action.toString());
        OPENWORLD.Space.faceObjectLerp(actor, camera, 1);
        OPENWORLD.Actor.playActionThen(
            actor, "punch", "idle", duration: 1, durationthen: 2);
        youDie();
        if (OPENWORLD.Math.random() < 0.5) {
          setHealth(0.5);
          toPrison(4);
        } else {
          setHealth(0);
          endo();
        }
      } else {
        print("journalist struck trigger in");
        var damage = getYouDamage();
        setActorHealth(actor, getActorHealth(actor) - damage);

        if (getActorHealth(actor) <= 0) {
          print(name+"actor dead");
          OPENWORLD.BaseObject.clearAll(actor);
          actorDie(actor); //,diesoundpath:"sounds/die.mp3");
          OPENWORLD.BaseObject.disableDistanceTrigger(actor);

        } else
           actorAttack(actor);

      }
    });
  }

  // Same as citizen except you can never kill them
  addknightnpc(actor, name)
  {
    addcitizennpc(actor,name, false);
  }

  // How much damage do you deal to npc depending on what you wield
  getYouDamage()
  {
    if (OPENWORLD.You.wield=="sword"||OPENWORLD.You.wield=="battleaxe") {
      print("damage 1");
      return 1.0;
    } else {
      print("damage 0.34");
      return 0.34;
    }
  }

  // Return the damage you receive when hit by npc
  // If where armour then less damage
  // Actor actually ignored
  getActorDamage(actor)
  {
     var damage=0.2;
     if (inventory.contains("hauberk"))
       damage*=0.7;
     if (inventory.contains("helmet"))
       damage*=0.7;
     return damage;
  }

  // Shop keeper speech if you dont have enough money to buy the item
  actorCannotBuy(actor)
  {
    OPENWORLD.Mob.setSpeech(
        actor, ["You dont have enough money for that"],
        z: 80, width: 300, scale: 0.4);
  }

  // Record quaterion of sword so can wield it and put it back to the way it was when unwield
  copyQuaternion(sword, oldsword)
  {
    sword.extra['defaultquaternion'] = oldsword.extra['defaultquaternion'];
    sword.extra['defaultchildquaternion'] = oldsword.extra['defaultchildquaternion'];
    sword.extra['defaultchildscale'] =  oldsword.extra['defaultchildscale'];
    sword.extra['defaultscale'] = oldsword.extra['defaultscale'];
  }

  // Change the weapson quaterion so can wield it
  // Record the quaterion so can change it back to the way it was if unwield it
  setWeaponWield(sword, wield, name) {
    if (!sword.extra.containsKey('defaultquaternion')) {
      print("record quat"+name+" "+sword.scale.x.toString()+" child"+sword.children[0].scale.x.toString());
      // Record the unwielded rotations and scale so can redo them when drop the sword
      sword.extra['defaultquaternion'] = sword.quaternion.clone();
      sword.extra['defaultchildquaternion'] =
          sword.children[0].quaternion.clone();
      sword.extra['defaultchildscale'] = sword.children[0].scale.clone();
      sword.extra['defaultscale'] = sword.scale.clone();
    }
    if (wield) {
      OPENWORLD.You.wield=name;
      if (name == 'sword') {
        sword.scale.set(1.0, 1.0, 1.0);
        OPENWORLD.Space.objTurn(sword, 0);
        OPENWORLD.Space.objPitch(sword, 0);
        OPENWORLD.Space.objRoll(sword, 0);
        sword.position.x = 0.0;
        sword.position.y = 0.0;
        sword.position.z = 0.0;
        sword.children[0].scale.set(0.15, 0.15, 0.15);
        OPENWORLD.Space.objRoll(sword.children[0], 90.0);
        OPENWORLD.Space.objTurn(sword.children[0], 20 + 180.0);
      } else if (name == 'torch') {
        sword.scale.set(1.0, 1.0, 1.0);

        sword.position.x = 20.0;
        sword.position.y = 0.0;
        sword.position.z = 0.0;
      } else if (name == 'battleaxe' || name == 'flute' || name == 'dagger') {
        sword.scale.set(1.0, 1.0, 1.0);
        OPENWORLD.Space.objTurn(sword, 0);
        OPENWORLD.Space.objPitch(sword, 0);
        OPENWORLD.Space.objRoll(sword, 0);
        sword.position.x = 15.0; //50;
        sword.position.y = 0.0;
        sword.position.z = 0.0;
        // OPENWORLD.Space.objRoll(sword.children[0], 90.0);
      }
    } else {
      OPENWORLD.You.wield="";
      print("unwield"+name+" "+sword.extra['defaultscale'].x.toString()+" child"+sword.extra['defaultchildscale'].x.toString());
      sword.setRotationFromQuaternion(
          sword.extra['defaultquaternion'].clone()); //=sword.quaternion.clone();
      sword.children[0].setRotationFromQuaternion(
          sword.extra['defaultchildquaternion'].clone()); //=sword.quaternion.clone();
      sword.children[0].scale = sword.extra['defaultchildscale'].clone();
      sword.scale = sword.extra['defaultscale'].clone();

    }
  }

  // This just shows the get icon on the object
  // Set the obj so that it can be selected on the ground and touched
  // When touched show a get menu item so can take it
  setGetObject(obj, {scalenotselected: 1.025, scaleselected: 1.05, on: true, takelabel: "Take", color}) {

    if (color==null)
      color=THREE.Color(0x0000ff);
    OPENWORLD.BaseObject.setHighlight(obj, scene, color, 1.0, deselectopacity: 0.5); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(
        obj, on, scale: scalenotselected, opacity: 0.5);

    OPENWORLD.BaseObject.setTouchTrigger(obj);
    obj.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      //  print("touched");
      if (OPENWORLD.Actor.getWielding(me)==obj) { //&&.containsKey('wieldling')&&obj.extra['wielding']==obj) {
        // so if click on what you are wielding doesn't show get menu
        print("already wielding it");
        return;
      } else {
        print("not wielding it");
      }
      OPENWORLD.BaseObject.highlight(
          obj, true, scale: scaleselected, opacity: 1);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"icon": Icon(Icons.get_app), "tooltip": takelabel});
        // menuicon=Icon(Icons.get_app);
        // menutooltip="Take";
        menuobj = obj;
      });
    });
  }

  // Remove the [obj] from the scene including its select highlight item
  removeObject(obj)
  {
    print("removeing obj");
    scene.remove(obj);
    if (obj.extra.containsKey('select'))
      scene.remove(obj.extra['select']);
  }

  // When you click on the get button it puts in your inventory and removes it from the scene
  // triggermenu is done when you click get
  setPickupObject(obj, name, button, {objectid}) async {
    obj.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {

      print("triggermenu remove "+name);
      OPENWORLD.Sound.play( path: 'sounds/bag.mp3', volume: 0.2);
      OPENWORLD.BaseObject.highlight(obj, false);
      removeObject(obj); // Remove it from the scene
      addInventory(name, button, getValue(obj), objectid:objectid);  // show it in your inventory
    });

    // So is persistent and keep the object in your inventory
    if (objectid!=null) {
      print("setpickupobject "+objectid);
      // Can only have one
      if (await OPENWORLD.Persistence.get(objectid)!=null &&!inventoryobjectids.contains(objectid) ) {
         print("trigger objectid"+objectid);

         obj.extra['touchtrigger'].triggermenu(null);//dummyevent);
      } else {
        print("trigger objectid not found "+objectid);
      }
    }
  }

  // Standard give animation for an actor
  giveAnimation(actor, {delay}) {

    if (delay!=null) {
      Future.delayed(Duration(milliseconds: (delay*1000).round()), () async {
         giveAnimation(actor);
      });
    } else {
      OPENWORLD.Space.faceObjectLerp(actor, camera, 0.5);
      OPENWORLD.Actor.playActionThen(actor, "hand", "idle2", duration: 1);
      OPENWORLD.Actor.playActionThen(
          actor, "hand", "idle2", backwards: true, duration: 0.2, delay: 1.3);
    }
  }

  // Drop an item in your inventory and add it back to the scene
  dropItem(name, obj)
  {
    if (OPENWORLD.Actor.getWielding(me)==obj)
      OPENWORLD.Actor.clearWielding(me);
    scene.add(obj);
    OPENWORLD.Space.placeBeforeCamera(obj, 0.65);
    OPENWORLD.BaseObject.highlight(obj, true); // turn highlight back on
    OPENWORLD.BaseObject.deselectHighLight(obj); // put it back to deselected state
    if (obj.extra.containsKey('select')) {
      var sel=obj.extra['select'];
      if (sel.parent!=scene)
        scene.add(sel);
    }
    removeInventory(name);
    OPENWORLD.Space.readdObjFromHide(obj);
  }

  //  Create a menu button that allows you to drop an object
  dropButton(name, obj, {icon}) {
    if (icon==null)
      icon="icons/arrow.png";
    return Container(height:inventoryiconwidth,
        child:Padding(padding:EdgeInsets.only(top:10),
    child:PopupMenuButton(
      color: Colors.black.withOpacity(0.2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
          icon,
          //width: inventoryiconwidth,
          fit: BoxFit.fitHeight,
          height: inventoryiconwidth,
        ),
      ),
      onSelected: (value) async {
        if (value == "drop") {
           dropItem(name,obj);
        }
      },
      itemBuilder: (BuildContext context) =>
      <PopupMenuEntry>[

        PopupMenuItem(
          value: "drop",
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.download),
              ),
              const Text(
                'Drop',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    )));
  }

  // Create a button for the menu that lets you drop and wield an item
  // Can show an icon for the item
  dropWieldButton(name, obj, {icon, iconwield}) {
    if (icon==null)
      icon="icons/arrow.png";

    return Container(height:inventoryiconwidth,
        child:Padding(padding:EdgeInsets.only(top:10),
    child:PopupMenuButton(
      color: Colors.black.withOpacity(0.2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
          icon,
        //  width: inventoryiconwidth,
          fit: BoxFit.fitHeight,
          height: inventoryiconwidth,
        ),
      ),
      onSelected: (value) {
        if (value == "wield") {
          print("wield " + name);
          obj.visible = true;
          OPENWORLD.Space.removeObjFromHide(obj);
          setWeaponWield(obj, true, name);

          OPENWORLD.Actor.wield(me, obj, "Bip01_R_Hand");
          setState(() {
            if (iconwield!=null)
              weaponicon=iconwield;
            else
              weaponicon=icon;
          });
        } else if (value == "drop") {
          setWeaponWield(obj, false, name);

          dropItem(name,obj);
          setState(() {
            weaponicon="icons/fist.png";
          });

        }
      },
      itemBuilder: (BuildContext context) =>
      <PopupMenuEntry>[
        PopupMenuItem(
          value: "wield",
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.front_hand),
              ),
              const Text(
                'Wield',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "drop",
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.download),
              ),
              const Text(
                'Drop',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    )));
  }

  // Menu button to drop and read an item in your inventory
  dropReadButton(name, obj, lines, {label:"Read", extracustomlabel, extracustomfunc, icon})
  {
    if (icon==null)
       icon="icons/arrow.png";
    return Container(height:inventoryiconwidth,
    child:Padding(padding:EdgeInsets.only(top:10),
    child:PopupMenuButton(
     // constraints:  BoxConstraints.expand( width: inventoryiconwidth),
      color: Colors.black.withOpacity(0.2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
         // color: Colors.black.withOpacity(0.2),
          icon,//"icons/arrow.png",
          fit: BoxFit.fitHeight,
          height: inventoryiconwidth,
        ),
      ),
      onSelected: (value) {
        if (value == "read") {

          setState(() {
            menuposx=width/3;
            menuposy=height/3;
            menuitems.clear();
            for (var line in lines)
               menuitems.add({"text":line});//"There is a note in the bottle. It reads:"});

          });
        } else  if (value == "drop") {

          setWeaponWield(obj, false,name);

          dropItem(name,obj);

        } else if (extracustomlabel!=null&& value==extracustomlabel) {
          extracustomfunc();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          value: "read",
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.front_hand),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "drop",
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.download),
              ),
              const Text(
                'Drop',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        if (extracustomlabel!=null)
          PopupMenuItem(
          value: extracustomlabel,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.download),
              ),
              Text(
                extracustomlabel,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        )
      ],
    )));
  }

  // Set your health and save it persistently
  setHealth(h)
  {
    setState(() {
      if (h<0)
        health=0;
      else if (h>1)
        health=1.0;
      else
        health=h.toDouble();//=1;
    });
    OPENWORLD.Persistence.set("health", health);
  }

  // Set your gold and save it persistenly
  setGold(g, {delay})
  {
    if (delay!=null) {
      Future.delayed( Duration(milliseconds: (delay*1000).round()), () async {
        setGold(g);
      });
    } else {
      setState(() {
        if (g is String)
          gold=double.parse(g);
        else
          gold = g.toDouble();
      });
    }
    OPENWORLD.Persistence.set("gold", g);
  }

  // Set your amount in the bank and save it persistently
  setBank(b)
  {
    setState(() {
      bank = b.toDouble();
    });
    OPENWORLD.Persistence.set("bank", bank);
  }

  // When click on the item on the ground eat it and get a health increase
  // Eg soup kitchen when click on the soup bowl you set it straight away
  setEatObject(obj,increase, minamt, {sound:true})
  {
    obj.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      print("triggermenu eat"+health.toString()+" "+increase.toString());
      setHealth(health*increase+minamt);
      print("triggermenu eat done"+health.toString());
      OPENWORLD.BaseObject.highlight(obj, false);
     // scene.remove(obj);
      removeObject(obj);
      Fluttertoast.showToast(
          msg: "Yummy",
          toastLength: Toast.LENGTH_LONG);
      if (sound) {
        OPENWORLD.Sound.play( path: 'sounds/eat.mp3', volume: 0.2);
        OPENWORLD.Sound.play( path: 'sounds/burp2.wav', volume: 0.2, delay:5);
      }
    });
  }

  // Animation and sound when you die
  // Show blackness
  youDie()
  {
    OPENWORLD.Sound.play( path: 'sounds/die.mp3', volume: 1.0);
    var pos=OPENWORLD.You.getWorldPos();
    OPENWORLD.Space.objForward(camera, -0.05, delay:0.6);
    OPENWORLD.Space.objForward(camera, 0.05,delay:0.7);
    OPENWORLD.Space.worldToLocalSurfaceObjLerp(camera, pos.x,pos.y+0.01,0.1,1, delay:1);//x, y, z)
    OPENWORLD.You.immobile=true;
    OPENWORLD.Actor.unwield(me,"Bip01_R_Hand");
    OPENWORLD.You.wield="";
    setState(() {
      weaponicon="";
    });
    Future.delayed(const Duration(milliseconds: 2000), () async {
      setState(() {
        black = true;

      });
    });
    Future.delayed(const Duration(milliseconds: 3000), () async {
      setState(() {
        black = false;
      });
    });

  }

  // Haul player off to prison
  toPrison(delay)
  {
    print("to prison");
    OPENWORLD.Space.worldToLocalSurfaceObj(guard2, 364.02, 276.71, 0, delay: delay);
    OPENWORLD.Space.worldToLocalSurfaceObj(
        camera, 364.02, 276.71, 0.1, delay: delay);
    //  Drag the player to the prison with guard in front
    OPENWORLD.Mob.moveTo(guard2, [
      [364.38, 280.60, 0, 0.52],
      [366.07, 285.23, 0, 0.52],
      [368.27, 284.86, 0, 0.52],
      [367.37, 282.14, 0, 0.52],
      [367.96, 281.92, 0, 0.52],
      [ 367.44, 279.55, 0, 0.52]
    ], action: "walk", stopaction: "idle", delay: delay);
    OPENWORLD.Mob.moveTo(camera, [
      [364.38, 280.60, 0.1, 0.52],
      [366.07, 285.23, 0.1, 0.52],
      [368.27, 284.86, 0.1, 0.52],
      [367.37, 282.14, 0.1, 0.52],
      [367.96, 281.92, 0.1, 0.52],
      [ 367.44, 279.55, 0.1, 0.52]
    ], delay: delay+0.5);

    OPENWORLD.Mob.setSpeech(
        guard2, ["Why do you hit innocent people?", "Whats wrong with you?"],
        z: 80, width: 300, scale: 0.4, delay: delay+16);
    OPENWORLD.Space.worldToLocalSurfaceObjLerp(
        camera, 368.88, 279.96, OPENWORLD.Camera.cameraoffset, 5, delay: delay+36);
    OPENWORLD.Space.faceObjectLerp(guard2,camera,1, delay:delay+38);
    // Show restart button so can start game again
    Future.delayed(Duration(seconds: (delay+39).round()), ()  {
      setState(() {
        restart=true;
      });
    });

  }

  // Send the player to the endoplasm so they can resurrect in the church
  endo({delay})
  {
    print("to endo");
    if (delay!=null) {
      Future.delayed(Duration(milliseconds: (delay*1000).round()), () async {
        endo();
      });

    } else {
      // Move player out of their body into the sky
      var pos = OPENWORLD.You.getWorldPos();
      // go up into the sky
      OPENWORLD.Space.worldToLocalSurfaceObjLerp(
          camera, pos.x, pos.y + 0.01, 40, 10, delay: 10); //x, y, z)
      // go to endo
      OPENWORLD.Space.worldToLocalSurfaceObjLerp(
          camera, 374.846, 272.103, OPENWORLD.Camera.cameraoffset, 5,
          delay: 30); //x, y, z)
      OPENWORLD.Space.objTurnLerp(camera, 0, 1, delay: 35);
      // Show resurrect button
      Future.delayed(Duration(milliseconds: 35000), () async {
        setState(() {
          resurrect=true;
        });
      });

    }
  }

  // Player struck so jolt the camera
  youStruck()
  {
    OPENWORLD.Space.objForward(camera, -0.05, delay:0.6);
    OPENWORLD.Space.objForward(camera, 0.05,delay:0.7);
  }

  // Strike actor and jolt the actor
  actorStruck(obj)
  {
    var angle=OPENWORLD.Camera.turn;
    print("actor struck"+angle.toString()+" "+OPENWORLD.Mob.getName(obj));
    OPENWORLD.Space.objMoveAngleSurfaceLerp(obj, angle, 0.15,0.0,0.1);
    OPENWORLD.Space.objMoveAngleSurfaceLerp(obj, angle, -0.15,0.0,0.1,delay:0.1);
  }

  // Are you dead?
  isDead()
  {
    return health<=0;
  }

  // Add a message to an object such as read me to a book
  addMsgToObj(obj,msg, {scale:0.3, z:20})
  {
    OPENWORLD.Mob.setText(obj,msg,textcolor:Colors.blue,scale:scale,z:z, backgroundopacity:0);
  }

  // Show buttons for inventory and show how many of those items if more than one
  displayInventory()
  {
    setState(() {
      inventorydisplay.clear();//add(widget);
      for (var i=0; i<inventory.length; i++) {
        var found=false;
        for (var j=0; j<i; j++)
          if (inventorynames[j]==inventorynames[i])
            found=true;
        if (!found) {
          // is first so count number
          var cnt=1;
          for (var j=i+1; j<inventory.length; j++)
            if (inventorynames[j]==inventorynames[i])
              cnt++;
          inventorydisplay.add(inventory[i]);
          if (cnt>1)
            inventorydisplay.add(Text(cnt.toString()));
        }
      }
    });
  }

  // Add an item to your inventory including the button menu, name of the inventory item
  addInventory(name, Widget widget, value, {objectid=""})
  {
    inventory.add(widget);
    inventorynames.add(name);
    inventoryvalues.add(value);
    inventoryobjectids.add(objectid);
    displayInventory();
    if (objectid!=null&&objectid!="") {
      print("addinventory objectid"+objectid);
      OPENWORLD.Persistence.set(objectid, true);
    }
  }

  // remove an item from your inventory
  removeInventory(name)
  {
    var found=false;
    for (var i=inventory.length-1; i>=0; i--) {
      if (!found && inventorynames[i]==name) {
        inventory.removeAt(i);
        inventorynames.removeAt(i);
        inventoryvalues.removeAt(i);
        if (inventoryobjectids[i]!=null&& inventoryobjectids[i]!="") {
          print("removeInventory objectid"+inventoryobjectids[i]);
          OPENWORLD.Persistence.remove(inventoryobjectids[i]);
        }
        inventoryobjectids.removeAt(i);
        found=true;
      }
    }
    if (found) {
      // Redisplay inventory once removed
      displayInventory();
    }

  }

  // Are you on the terrain and not in acropolis or lindos
  isTerrain()
  {
    var worldpos=OPENWORLD.You.getWorldPos();
    return (worldpos.y>311||worldpos.x<357||worldpos.x>425|| worldpos.y<195);
  }

  // are you in the acropolis?
  isAcropolis()
  {
    var worldpos=OPENWORLD.You.getWorldPos();
    return (worldpos.x>404&&worldpos.x<457&&worldpos.y<288&& worldpos.y>253);
  }

  // Are you in lindos?
  isLindos()
  {
    var worldpos=OPENWORLD.You.getWorldPos();
    return (worldpos.x>357&&worldpos.x<404&& worldpos.y<311&&worldpos.y>195);
  }

  // Call the guide and get information on where you are from the room you are in
  callGuide() {
    if (boatriding) {
      Fluttertoast.showToast(
          msg: "Amon the guide isn't able to walk on water",
          toastLength: Toast.LENGTH_LONG);
    } else if (underSea()) {
      Fluttertoast.showToast(
          msg: "Amon can't find you when your underwater",
          toastLength: Toast.LENGTH_LONG);
    } else {
      OPENWORLD.Sound.play( path: 'sounds/whistle.mp3', volume: 1);
      var dist = OPENWORLD.Space.getDistanceBetweenObjs(camera, amon);
      if (dist > 1) {
        amon.visible = true;
        OPENWORLD.BaseObject.clearTimers(amon);
        OPENWORLD.Mob.clearText(amon);
        OPENWORLD.BaseObject.disableDistanceTrigger(amon);
        OPENWORLD.Space.faceObjectAlways(amon, camera);
        OPENWORLD.Mob.placeBeforeCamera(amon, 2, time: 1,
            action: "walk", offset: 2, stopaction: "idle");
        // do twice so amon doesn't just pop in front of you if was a long way away
        var offset;
        var dist;
        if (horseriding) {
          offset = 0.2; // show amon off center if you are on a horse
          dist=0.8;
        } else {
          offset = 0;
          dist=0.5;
        }

        OPENWORLD.Mob.placeBeforeCamera(amon, dist, time: 2, offset:offset,
            action: "walk", stopaction: "idle", delay: 1.3);
        // Amon bows
        OPENWORLD.Actor.playActionThen(
            amon, "bow", "idle2", duration: 0.5, delay: 4);

        new Timer(new Duration(milliseconds: (2 * 1000).floor()), () async {
          OPENWORLD.BaseObject.reenableDistanceTrigger(amon);
          // Get speech for the room you are in
          // If you are not in a room or in a room without a speech generate general speech based on about where you are
          var speech;
          if (OPENWORLD.You.room != null &&
              OPENWORLD.You.room!.extra.containsKey('guide')) {
            speech = OPENWORLD.You.room!.extra['guide'];

          } else if (isLindos()) {
            speech = [
              "We're in the town of Lindos",
              "It has traditionally",
              "been a fishing village.",
              "It was founded by the Dorians around 3000BC.",
              "Lindos is famous for its temple of Athena Lindia",
              "which you can see high up in the east.",
              "Why not explore it?",
            ];
          } else if (isAcropolis()) {
            speech = [
              "We're at the Acropolis. ",
              "Its been a natural fortress used by",
              "the Greeks, Romans & now the Knights.",
              "Around 300BC the temple Athena Lindia",
              "complex was built.",
              "Its dedicated to the goddess Athena.",
              "Additions to the Acropolis have been made",
              "by the Romans & quite recently the",
              "Knights Hospitaller, setting up their",
              "head quarters in the church of St John.",
            ];
          } else if (isTerrain()) {
            speech = [
              "We are outside of the town of Lindos",
              "We are on the island of Rhodes.",
              "and are 40km south of the ",
              "town of Rhodes",
              "During summer it can get",
              "really hot out here",
            ];
          } else
            speech = ["Sorry, I don't have much information on this place"];

          OPENWORLD.Mob.setSpeech(amon, speech, z: 80,
              width: 300,
              scale: 0.4,
              randwait: 0,
              minwait: 5,
              delay: 3);
        });
      } else {
        print("amon dist is"+dist.toString());
      }
    }
  }

  // Are you underwater?
  underSea() {
     return camera.position.y<0;//-22.5;
  }

  initPage() async {

    var starttick=OPENWORLD.System.currentMilliseconds();
    OPENWORLD.System.active = true;
    // Set the time of day - random if first time
    OPENWORLD.Time.setTime(await OPENWORLD.Persistence.get("time", def:OPENWORLD.Math.random()*24));//OPENWORLD.Math.random()*24);//);//12.0); //);
    OPENWORLD.Time.daylength=1.0;  // Takes an hour to do 24 hours
    restart=false;

    OPENWORLD.Space.wallintersectoffsetz=0.01;   // make so wall needs to be a little bit lower before defined as wall - needed in acropolis quarters window

    if (kIsWeb)
      OPENWORLD.Persistence.gamename="rhodes3d";  // So that if two games in web wont mix up cookies in browser
    // Set player health, gold and bank balance and restore from persistent if set
    setHealth(await OPENWORLD.Persistence.get("health", def:health));
    setGold(await OPENWORLD.Persistence.get("gold", def:gold));
    setBank(await OPENWORLD.Persistence.get("bank", def:bank));
    // Get state of player doing the quest of finding the spy
    journalist2newsroomseen=await OPENWORLD.Persistence.get("journalist2newsroomseen", def:journalist2newsroomseen);
    journalist2beachseen=await OPENWORLD.Persistence.get("journalist2beachseen", def:journalist2beachseen);
    journalist2inwait=await OPENWORLD.Persistence.get("journalist2inwait", def:false);
    donequest=await OPENWORLD.Persistence.get("donequest", def:donequest);

    // Has the player got a whistle to call amon?
    whistle=await OPENWORLD.Persistence.get("whistle", def:whistle);

    OPENWORLD.Room.init();
    //if (!kIsWeb) {
      defaultspeed*= 1.5; //8; //2m/s
    //}
    OPENWORLD.You.speed = defaultspeed; //8; //2m/s
    OPENWORLD.You.drag = defaultdrag; //0.5;

    // Set the url for playing multiplayer
    _session = CLIENT.Session("https://forthtemple.com/secondtemple/serverdart/rhodes3d.php");

    // skydome is 1000 so over 1000 isn't really necessary
    camera = THREE.PerspectiveCamera(60, width / height, 0.04, 4000);

    OPENWORLD.Camera.init(camera, defaultcameraoffset,width,height);  // 0.45 for threejs version but 0.35 delphi version

    // Set default font to Nanum Myeongjo
    OPENWORLD.Texture.defaultfontfamily= 'NanumMyeongjo';

    // Set must wait 100ms when has triggered that touched an object
    OPENWORLD.BaseObject.touchtriggerwait=0.1;
    camera.position.y = 999;

    clock = THREE.Clock();

    print("create scene");
    scene = THREE.Scene();
    scene.rotation.order = "YXZ";

    scene.add(_hotload);

    // Set the ambient light in the scene
    var ambience = new THREE.AmbientLight(0x666666);
    scene.add(ambience); //222222 ) );

    print("create sky");
    var skyGeo = THREE.SphereGeometry(-1000, 32, 15);

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
    var sunlight = new THREE.SpotLight(0x888888);//ffffff);
    sunlight.intensity = 0.4;
    sunlight.penumbra = 1;
    sunSphere.add(sunlight);

    scene.add(sunSphere);

    // Specify the maps for the game
    // Each map has an map image with two points with a world position and corresponding pixel position on the map
    print("create maps");
    var maps = [
      OPENWORLD.MapItem('assets/maps/world.jpg',//maplarge.jpg',
          worldx: 0,//-7.61,
          worldy: 0,//17.73,
          imagex: 0,
          imagey: 650,
          worldx2: 700,
          worldy2: 650,
          imagex2: 700,
          imagey2: 0),


      OPENWORLD.MapItem('assets/maps/lindos.jpg',//map.jpg',
          worldx: 368.14,
          worldy: 213.80,
          imagex: 119, //173, //58,
          imagey: 387,//462,//461,
          worldx2: 418.20,
          worldy2: 309.60,
          imagex2: 247,//398,// 280,
          imagey2: 151),//39),//27)
      OPENWORLD.MapItem('assets/maps/acropolis.jpg',//map.jpg',
          worldx: 426.72,
          worldy: 285.64,
          imagex: 76,//(178/2).round(),
          imagey: 6, //(80/2).round(),
          worldx2: 439.58,
          worldy2: 263.76,
          imagex2: 171,//(467/2).round(),
          imagey2: 173)//(559/2).round()),
    ];
    OPENWORLD.Maps.init(maps);

    // Initialise music with 2 tunes
    // Both have equal chance of playing
    print("create music");
    var musics = [
      OPENWORLD.MusicItem('sounds/asteriarose.mp3', chance: 0.5),
      OPENWORLD.MusicItem('sounds/asteriarose2.mp3', chance: 0.5),
    ];
    OPENWORLD.Musics.init(musics);

    // Change sound mute based on settings
    OPENWORLD.Musics.setMute(await OPENWORLD.Persistence.get("musicmute", def:false));
    OPENWORLD.Sound.setMute(await OPENWORLD.Persistence.get("mute",def:false));

    // Initialize the time with the sunsphere, skymat and ambience so that can change these based upon the time of day giving a realistic sky
    print("init time");
    OPENWORLD.Time.init(sunSphere, skyMat, ambience);

    // Load the terrain that everything is place on top of
    print("load terrain");
    var manager = THREE.LoadingManager();
    var mtlLoader = THREE_JSM.MTLLoader(manager);
    mtlLoader.setPath('assets/models/rhodes/');
    print("loading terrain materials");
    var materials = await mtlLoader.loadAsync('rhodes.mtl');
    print("loaded terrain materials");
    await materials.preload();
    var loader = THREE_JSM.OBJLoader(null);
    loader.setMaterials(materials);
    Group mesh = await loader.loadAsync('assets/models/rhodes/rhodes.obj');

    // Create a detail texture applied to the terrain surface only
    print("load terrain detail");
    var textureaerial = await THREE.TextureLoader()
        .loadAsync('assets/models/rhodes/detailaerial.png');
    textureaerial.wrapS = THREE.RepeatWrapping;
    textureaerial.wrapT = THREE.RepeatWrapping;
    textureaerial.needsUpdate = true;
    textureaerial.repeat.set(64, 64);

    var mataerial = new THREE.MeshBasicMaterial({
      'map': textureaerial,
      'transparent': true,
      //  'alphaTest': .5
    }); // Fudge to remove unnecessary alphamap that causes wood to be transparent
    mataerial.opacity=0.5;

    // Create a detail texture applied to the acropolis surface only
    var textureacropolis=await THREE.TextureLoader()
        .loadAsync('assets/models/rhodes/detailmap.png');//textureaerial.clone();
    textureacropolis.wrapS = THREE.RepeatWrapping;
    textureacropolis.wrapT = THREE.RepeatWrapping;
    textureacropolis.repeat.set(1,1);
    textureacropolis.needsUpdate = true;
    var matacropolis = new THREE.MeshBasicMaterial({
      'map': textureacropolis,
      'transparent': true,
      //  'alphaTest': .5
    }); // Fudge to remove unnecessary alphamap that causes wood to be transparent
    matacropolis.opacity=0.4;

    // Create a detail texture applied to the beach only
    var textureiii = await THREE.TextureLoader()
        .loadAsync('assets/models/rhodes/detailbeach.png');
    textureiii.wrapS = THREE.RepeatWrapping;
    textureiii.wrapT = THREE.RepeatWrapping;
    textureiii.needsUpdate = true;
    textureiii.repeat.set(64, 64);
    var matbeach = new THREE.MeshBasicMaterial({
      'map': textureiii,
      'transparent': true,
      //  'alphaTest': .5
    }); // Fudge to remove unnecessary alphamap that causes wood to be transparent

    scene.add(mesh);

    OPENWORLD.Space.init(  mesh, scene);

    mesh.traverse((object) {
      if (object is Mesh && object.material is THREE.Material) {

        THREE.MeshPhongMaterial mat = object.material as THREE
            .MeshPhongMaterial; // as THREE.MeshPhongMaterial).alphaMap.toString()
        if (mat.alphaMap != null) mat.alphaMap = null;
        mat.shininess = 0;
        mat.emissive = THREE.Color(0x000000);

        if (object.name.contains("acropolis"))
          object.material = [mat, matacropolis];  // Set the detail to acropolis detail
        else if (object.name.contains("beach")) {
          object.material = [mat, matbeach];   // Set the detail to beach material
          print("found beach"+object.name.toString());
        } else if (object.name.contains("surface")&&!object.name.contains("lindos")) {
          object.material = [mat, mataerial];  // Set the detail to terrain material
          print("found surface"+object.name.toString());
        }
      }
    });

    // Get a sea floor the extends further out than the mesh so looks like the sea goes out much further
    var geometryseafloor = new THREE.PlaneGeometry(2000, 2000);
    var materialseafloor = THREE.MeshStandardMaterial();
    materialseafloor.color.setHex( 0x8e816e );
    var seafloor = new THREE.Mesh(geometryseafloor, materialseafloor);
    seafloor.rotateX(THREE.MathUtils.degToRad(-90));
    scene.add(seafloor);
    OPENWORLD.Space.worldToLocalSurfaceObj(seafloor, 7.7, 1.0, -6);

    // Create the cloud object that is a plane with a cloud texture
    print("create cloud");
    var geometry = new THREE.PlaneGeometry(2000, 2000);
    var texturei =
        await THREE.TextureLoader(null).loadAsync('assets/textures/clouds.png');
    texturei.wrapS = THREE.RepeatWrapping;
    texturei.wrapT = THREE.RepeatWrapping;
    texturei.needsUpdate = true;

    texturei.matrixAutoUpdate = true;
    texturei.repeat.set(25,25);//50, 50);
    var material =
        THREE.MeshStandardMaterial({'map': texturei, 'transparent': true});

    var clouds = new THREE.Mesh(geometry, material);
    clouds.rotateX(THREE.MathUtils.degToRad(90));
    scene.add(clouds);

    OPENWORLD.Space.worldToLocalSurfaceObj(clouds, 7.7, 1.0, 25);

    // Initialize the weather including the cloud plane and the sounds used for wind and rain
    print("init weather");
    await OPENWORLD.Weather.init(
        clouds, 'sounds/wind.mp3', 'sounds/rain.mp3'); // rainSound);

    OPENWORLD.Weather.fogindoors=false;  // so no fog in sea

    // Set the weather based upon what was last saved
    OPENWORLD.Weather.setCloud(await OPENWORLD.Persistence.get("cloud", def:0.0));//.0);
    OPENWORLD.Weather.setWind(await OPENWORLD.Persistence.get("wind", def:0.0));
    OPENWORLD.Weather.setRain(await OPENWORLD.Persistence.get("rain", def:0.0));
    OPENWORLD.Weather.setFog(await OPENWORLD.Persistence.get("fog", def:0.0));
    OPENWORLD.Weather.setRandomWeather();  // Will randomly get rain, fog, wind and cloud

    // Create the joystick
    _joystick = OPENWORLD.VirtualJoystick();
    _joystick?.joysticksize=200;

    var fpsControl = PointerLockControls(camera, _globalKey);

    fpsControl.domElement.addEventListener('keyup', (event) {
      _joystick?.keyboard.onKeyChange(event, 'keyup');

    }, false);
    fpsControl.domElement.addEventListener('keydown', (event) {
      _joystick?.keyboard.onKeyChange(event, 'keydown');
    }, false);

    fpsControl.domElement.addEventListener('pointerdown', (event) {

      pointerdowntick=OPENWORLD.System.currentMilliseconds();

      _joystick?.onTouchDown(event.clientX, event.clientY);

    }, false);
    //  if (!kIsWeb) {
    fpsControl.domElement.addEventListener('pointerup', (event) {
      var numpoints;
      if (lastframes<10&&!(event.clientX<_joystick?.joysticksize&&event.clientY<_joystick?.joysticksize))
        numpoints=40;
      else
        numpoints=1;
      print("numpoints"+numpoints.toString()+" fps"+lastframes.toString());
      if (!OPENWORLD.BaseObject.touchup(pointerdowntick, event, scene, width, height, numpoints)) {
        OPENWORLD.BaseObject.deselectHighLights();//hidehighlights();
        setState(() {
          menuposx=-1;
        });
      }

      _joystick?.onTouchUp();
      //print("mmm");

      pointerdowntick=-1;
    }, false);
    fpsControl.domElement.addEventListener('pointermove', (event) {
      // this should be in openworld!!
      if (!_joystick?.getStickPressed()) {

        _joystick?.onTouch(
            event.clientX, event.clientY, width, height, clock.getDelta());

      }
    }, false);

    if (!kIsWeb) {
      // If smartphone then create sea using water shader
      final waterGeometry = THREE.PlaneGeometry(20, 20);

      final Map<String, dynamic> params = {
        'color': THREE.Color(0.25,0.3,0.35),//0xffffff, //0000ff,  0.25,0.3,0.35
        'scale': 80,
        'flowX': 0.1, //1.0,
        'flowY': 0.1, //1.0
      };

      final water = Water(waterGeometry, {
        'color': params['color'],
        'scale': params['scale'],
        'flowDirection': THREE.Vector2(params['flowX'], params['flowY']),
        'textureWidth': 256, //512,//1024,
        'textureHeight': 256, //512,//1024,
        'reflectivity': 0.0,
        'clipBias':3.0
      });

      water.scale.set(200, 200, 200);
      // water.position.y = 1;
      water.rotation.x = math.pi * -0.5;

      scene.add(water);
    } else {
      // If web use simple water
      // For some reason doens't work for web
      WaterSimple.initVertexData();
      var water = WaterSimple();
      var water1 = water.createWater();
      water1.scale.set(3000.0, 1.0, 3000.0);
      scene.add(water1);

      OPENWORLD.Updateables.add(water); // only need to do one
    }

    // Is this sea so when looking up dont see sky?
    // This might be redundant
    geometry = new THREE.PlaneGeometry(1,1);
    material = THREE.MeshStandardMaterial();
    material.transparent=true;
    material.color=seacolor;//THREE.Color(0x064273);//1da2d8);
    material.opacity=0.5;
    var sea = new THREE.Mesh(geometry, material);
    sea.rotateX(THREE.MathUtils.degToRad(90));
    sea.scale.set(1000,1000,1000);
    scene.add(sea);
    sea.position.y -= 22.5;

    hotload();

    print("load config");
    // Load all objects from config file including pool objects
    await OPENWORLD.Config.loadconfig();

    await OPENWORLD.Config.createAllObjects(scene);
    await OPENWORLD.Config.createPoolObjects(scene);

    // Create default room that extends over the whole terrain  which you go in if you exit say a shop
    // Have its own sound system - though better if could modify the openworld room so that reuse that instead of redoing it
    var roomDefault = OPENWORLD.Room.createRoom(mudwidth/2, mudheight/2);//, beforeenter:defaultBeforeEnter); //THREE.Object3D();
    OPENWORLD.Room.setDistanceTrigger( roomDefault , dist:mudwidth/2);

    // Allow fading of room sound in default eg beach to underwater
    var is1=true;
    roomdefaultsound11 = audioplayers.AudioPlayer();
    roomdefaultsound12 = audioplayers.AudioPlayer();
    roomdefaultsound21 = audioplayers.AudioPlayer();
    roomdefaultsound22 = audioplayers.AudioPlayer();
    roomdefaultsoundloaded=true;

    // use underSea function to determine if in indoor so that wont rain while you're under water
    OPENWORLD.Room.setIndoorsFunc(roomDefault,underSea);
    // When resume game trigger this room
    roomDefault.extra['triggeronresume']=true;

    // Get the current audio player for this room
    // Have two sets so can fade between the two
    getAudioPlayer()
    {
       if (is1)
         return [roomdefaultsound11,roomdefaultsound12];
       else
         return [roomdefaultsound21,roomdefaultsound22];
    }

    roomDefault.extra['trigger'].addEventListener('trigger', (THREE.Event event) {

      if (event.action) {
       print("in default--");

       OPENWORLD.BaseObject.clearTimers(roomDefault);
       var currentpath="";

       // 500ms so that when go under water isn't delay in hearing underwater sound
       var t=Timer.periodic(Duration(milliseconds: 500), (timer) async {
         // While in default loop and change sound depending if underwater, on beach, in lindos in acropolis
         if (OPENWORLD.You.room != roomDefault||OPENWORLD.System.appstate != AppLifecycleState.resumed||!loaded) {
           //sound.stop();
           //sound2.stop();
           var sounds=getAudioPlayer();
           if (sounds[0].state==audioplayers.PlayerState.playing)
             OPENWORLD.Sound.fadeOut(sounds[0], 2);
           else { // bug ios
             sounds[0].stop();
             print("default stop a0");
           }
           if (sounds[1].state==audioplayers.PlayerState.playing)
             OPENWORLD.Sound.fadeOut(sounds[1], 2);
           else { // bug ios
             sounds[1].stop();
             print("default stop a1");
           }
           timer.cancel();
           print("stop default timer");
         } else {


             var worldpos = OPENWORLD.You.getWorldPos();
             var path;
             var volume=0.05;
             if (underSea()) {
               path = "sounds/underwater.mp3";
               volume=1;
             } else if (camera.position.y < 1.0)
               path = "sounds/surf.mp3";
             else {
               if (worldpos.x > 427 && worldpos.x < 518  && worldpos.y < 354 &&worldpos.y>288) {  //445
              //   print("in cannon ");
                 // if in cannon area play it
                 if (OPENWORLD.Math.random()<1/30.0) { // every 30 seconds play cannon

                   var dist=OPENWORLD.Math.vectorDistance(THREE.Vector3(467.69, 351.81,0), worldpos);
                   if (dist>5) {
                     // dont play cannon if near the cannons
                     // make louder as get closer
                     var volume = 1 - dist / 40;
                     if (volume < 0.1) {
                       volume = 0.1;
                     }
                     print("volume cannon" + volume.toString() + " " +
                         dist.toString());
                     OPENWORLD.Sound.play(
                         path: 'sounds/cannon.mp3', volume: volume);
                   }
                 }
               }

               // At night have lindos sound like a field with crickets chirping
               if (OPENWORLD.Time.isNight(OPENWORLD.Time.time))
                 path = "sounds/field.mp3";
               else if (isAcropolis())
                 path = "sounds/acropolis.mp3";
               else if (isLindos())
                 path = "sounds/courtyard.mp3";
               else {
                 path = "sounds/field.mp3";

               }
             }

             if (path != currentpath) {
               print("defaultroom path change " + path + " " + currentpath);
               var sounds=getAudioPlayer();
               if (sounds[0].state==audioplayers.PlayerState.playing)
                 OPENWORLD.Sound.fadeOut(sounds[0], 2);
               else { //bug ios
                 sounds[0].stop();
                 print("default stop 0");

               }
               if (sounds[1].state==audioplayers.PlayerState.playing)
                  OPENWORLD.Sound.fadeOut(sounds[1], 2);
               else { //bug ios
                 print("default stop 1");
                 sounds[1].stop();
               }

               is1=!is1;
               sounds=getAudioPlayer();

               var duration = await OPENWORLD.Sound.play(
                   sound: sounds[0],
                   path: path,
                   volume: volume,
                   loop: true,
                 //  fadein: 1
               );

               OPENWORLD.Sound.play(sound: sounds[1],
                   path: path,
                   volume:volume,
                   loop: true,
                   seek: duration / 2.0,
                  // fadein: 1
               );
               currentpath = path;
             }
          // }

         }


       });

       OPENWORLD.BaseObject.addTimer(roomDefault,t);
      } else {
       print("out default");
      }
    });

    // Enable distance trigger only when you're in room default since roomdefault overlaps all other rooms
    OPENWORLD.BaseObject.disableDistanceTrigger(roomDefault);

    // The introduction room on the beach with a horse to ride and amon explaining
    var roomIntro= OPENWORLD.Room.createRoom(380,339,//-74,-57,
        soundpath: "sounds/surf.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();

    // Set the room size to be 6
    OPENWORLD.Room.setDistanceTrigger(roomIntro,
        minx: OPENWORLD.Room.getX(roomIntro)-6, maxx: OPENWORLD.Room.getX(roomIntro)+6,miny: OPENWORLD.Room.getY(roomIntro)-6, maxy:OPENWORLD.Room.getY(roomIntro)+6);

    // Show the welcome lindos sign
    var lindossign=THREE.Group();
    var brandm= await OPENWORLD.Model.createModel('assets/models/sign.glb');
    brandm.scale.set(0.015, 0.015, 0.015);
    lindossign.add(brandm);
    var plane =   await OPENWORLD.Plane.makeTextPlane("Welcome to Lindos", Colors.white,backgroundopacity: 0);//scale:0.01);//THREE.Color(0xff0000));
    lindossign.add( plane );
    plane.position.y+=0.3;
    plane.position.x=-0.05;
    plane.scale.set(0.35,0.35,0.35);//.x=0.1;
    lindossign.add(plane);
    scene.add(lindossign);

    // Create the armourer but dont add him to the scene because has all the animations that wish to share with all other actors
    armourer = await OPENWORLD.Actor.createActor('assets/actors/armourer.glb',
        action:"idle2",
        z: actoroffset);

    // Load amon the guide and use the armourers animations
    amon = await OPENWORLD.Actor.createActor('assets/actors/citizen3.glb',
        shareanimations: armourer,
        z: actoroffset);

    // Set the default size of amon
    setDefaultActor(amon);
    // Place actor on scene and hide amon if 10 meters away
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amon,  380.12, 338.99 ,0,10);//380.3,338.7,0,10);
    scene.add(amon);
    // Have amon always face you
    OPENWORLD.Space.faceObjectAlways(amon, camera);

    // Set that if attack amon then you cannot kill him but instead will either die or go to prison
    addcitizennpc(amon,"amon",false);

    // If 1.5 meters from amon then give speech about quest if at the beach
    OPENWORLD.BaseObject.setDistanceTrigger(amon, dist: 1.5);
    amon.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        var dist=OPENWORLD.Space.getDistanceBetweenObjs(camera, roomIntro);
        if (dist<4) {
          // Only do speech if at the beach
          var timeamon = await OPENWORLD.Mob.setSpeech(amon, [
            "Hi friend",
            "Welcome to Lindos",
            "Its 1522 and we're really worried about getting invaded",
            "We know Suleiman and his huge army are coming",
            "We know he has spies in Lindos",
            "giving details of our defences",
            "We really need help uncovering the spies",
            "Do you feel up to the challenge?",
            "If so take the horse up to the acropolis",
            "The knight prefect will give you more info",
            ], z: 80,
              width: 300,
              scale: 0.4,
              randwait: 0,
              minwait: 5);

          // Horse randomly farts
          var delay = timeamon + OPENWORLD.Math.random() * 20 + 10;
          if (OPENWORLD.Math.random() < 0.5)
            OPENWORLD.Sound.play(
                path: 'sounds/fart.wav', volume: 0.5, obj: amon, delay: delay);
          else
            OPENWORLD.Sound.play(
                path: 'sounds/fart2.mp3', volume: 0.5, obj: amon, delay: delay);

          // Amon apologizes for flatulence
          OPENWORLD.Mob.setSpeech(amon, [
            "That wasn't me, that was the horse",
            "He must have eaten Beeforeno",
            "Can be explosive"], z: 80,
              width: 300,
              scale: 0.4,
              randwait: 0,
              minwait: 5,
              delay: delay + 1);
        }
      } else {
        OPENWORLD.BaseObject.clearAll(amon);

      }
    });

    // Put crabs near intro room that can kill
    Group craborig = await OPENWORLD.Actor.createActor('assets/actors/crab.glb',
        z: 0.1//actoroffset
         );
    craborig.scale.set(0.01, 0.01, 0.01);
    var crabs=[];

    var crabposx=383.39;
    var crabposy=335.86;
    // Create three and place randomly
    for (var i=0; i<3; i++) {
      var crab= await OPENWORLD.Actor.copyActor(craborig);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crab, crabposx + 4*(OPENWORLD.Math.random()-0.5),
          crabposy + 4*(OPENWORLD.Math.random()-0.5), 0, 4);
      OPENWORLD.Space.objTurn(crab.children[0], 0);
      scene.add(crab);
      addnpc(crab, "crab", true);  // Can kill the crab and take the corpse
      crabs.add(crab);
    }

    // When enter intro room start crabs moving
     roomIntro.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        print("in room intro");
        for (var crab in crabs)
          OPENWORLD.Mob.randomwalk(crab, 0.1, 0.05, 0.1,
            action: "walk",
            actionduration: 0.5,
            stopaction: "idle",
            reset: true
          );

      } else {
        print("out room intro");
      }
    });

    // Create dog so can share animations with cat and wilddog but dont add to scene
    Group dog =
    await OPENWORLD.Actor.createActor('assets/actors/dog.glb',
      //  texture: "assets/actors/citizen/bodycf3.png", z: 50);
      //   texture: "assets/actors/citizen/bodyc4.png",
    );
    dog.scale.set(0.005,0.005,0.005);//25, 0.0025, 0.0025);

    // Create the horse you can ride if you complete the quest - dont add it to the scene
    horse = await OPENWORLD.Actor.createActor('assets/actors/horse.glb');
    OPENWORLD.Space.objTurn(horse.children[0],0);
    OPENWORLD.Space.objTurn(horse,0);//OPENWORLD.Math.random()*360);
    horse.scale.set(0.014,0.014,0.014);//25, 0.0025, 0.0025);

    // Create the horse you can ride to lindos and acropolis only
    horse2= await OPENWORLD.Actor.copyActor(horse);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        horse2, 380.37, 338.09 ,0,10);// 380.23, 337.80 380.57, 337.58, 0, 4);
    scene.add(horse2);

    // Create the saddle which you can click and show a menu that lets you choose where to ride to
    var saddle=await OPENWORLD.Model.createModel('assets/models/saddle.glb');
    saddle.scale.set(0.65,0.65,0.65);
    saddle.position.set(0.0,22.0,0.0);
    OPENWORLD.Space.objTurn(saddle,-90);
    horse2.add(saddle);

    OPENWORLD.BaseObject.setDistanceTrigger(horse2, dist: 4);
    horse2.extra['trigger'].addEventListener('trigger', (THREE.Event event) {

        if (event.action) {
          // If the horse is near amon then show text above saddle telling player to click the saddle to ride it
          // Dont show these lines all the time as would be annoying
          var dist=OPENWORLD.Space.getDistanceBetweenObjs(horse2, amon);
          if (dist<4) {
            var inc = 0;
            var saddlelines = [
              'Click blue outline',
              'to get menu options',
              'Click saddle to ride'
            ];
            // Every 5 seconds show next line in message on top of saddle
            var t = Timer.periodic(Duration(seconds: 5), (timer) async {
              if (inc < saddlelines.length) {
                if (saddle.extra.containsKey('saddlemsg')) {
                  saddle.remove(saddle.extra['saddlemsg']);
                  saddle.extra.remove('saddlemsg');
                }
                var saddlemsg = THREE.Group();
                var saddlesprite = await OPENWORLD.Sprite.makeTextSprite(
                    saddlelines[inc], fontSize: 20,
                    Colors.blue,
                    bold: true,
                    backgroundopacity: 0,
                    width: 300); //,scale:0.01);//THREE.Color(0xff0000));
                saddlemsg.add(saddlesprite);
                saddle.add(saddlemsg);
                saddle.extra['saddlemsg'] = saddlemsg;
                saddlemsg.position.y = 25.0;
                saddlemsg.scale.set(0.25, 0.25, 1.0);
                inc++;
              } else
                OPENWORLD.BaseObject.clearTimers(saddle);
            });
            OPENWORLD.BaseObject.addTimer(saddle, t);
          }
        } else {
          //  OPENWORLD.BaseObject.clearAll(dog);
          OPENWORLD.BaseObject.clearTimers(saddle);

        }

    });
    OPENWORLD.Space.worldToLocalSurfaceObjHide(lindossign, 380.3,338.7,0,10); //3.7);

    // Set highlight on saddle so know that can click it
    OPENWORLD.BaseObject.setHighlight(saddle, horse2, THREE.Color(0x0000ff), 0.5);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(saddle, true, opacity:0.5, scale:1.02);
    OPENWORLD.BaseObject.setTouchTrigger(saddle);

    // Handle user clicking the saddle and show menu that can ride to lindos or to acropolis
    var horsestate="beach";
    saddle.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      //  print("touched");
      OPENWORLD.BaseObject.highlight( saddle, true, scale:1.06, opacity:0.6);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"iconpath":"icons/horse.png"});
        if (horsestate=='beach'||horsestate=='acropolis')
          menuitems.add({"text":"Ride to Lindos", "command":"ridelindos"});
        if (horsestate=='beach'||horsestate=='lindos')
          menuitems.add({"text":"Ride to Acropolis", "command":"rideacropolis"});
        if (horsestate=='acropolis'||horsestate=='lindos')
          menuitems.add({"text":"Ride to Beach", "command":"ridebeach"});
        menuobj=saddle;//lindossign;
      });
    });

    // Handle user click on the menu item to either ride to acropolis or ride to lindos
    saddle.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) async {
      if (donequest) {
        // If you already have a horse dont ride this one
        Fluttertoast.showToast(
            msg: "You are now a knight and have your own horse!",
            toastLength: Toast.LENGTH_LONG);
      } else {
        print(
            "triggermenu horsestate" + horsestate + " ride to" + event.action);
        // Turn off hightlight on saddle while riding
        OPENWORLD.BaseObject.highlight(
            saddle, false, opacity: 0.5, scale: 1.02);

        // You cant get off horse while riding
        OPENWORLD.You.immobile = true;
        // Place camera higher now that on horse
        OPENWORLD.Camera.cameraoffset = horsecameraoffset; //defaultcameraoffset+0.2;
        // Put the player on the horse
        var horsepos = OPENWORLD.Space.localToWorldObj(horse2);
        OPENWORLD.Space.worldToLocalSurfaceObjLerp(
            camera, horsepos.x, horsepos.y, OPENWORLD.Camera.cameraoffset,
            1); //380.37, 338.09,
        OPENWORLD.Space.objTurnLerp(camera, 0, 1);  // why does it face you north when you ride the horse
        Future.delayed(Duration(milliseconds: (5000).round()), () async {
          horse2riding = true;
        });

        // From beach to lindos shared - list of points horse passes through to the to the central lindos point
        var beachpos = [
          [380.37, 338.09],
          [391.76, 301.30],
          [390.64, 298.23],
          [390.85, 293.60],
          [387.39, 285.56],
          [385.54, 279.69], // shared
        ];

        // From lindos to lindos shared point
        var lindospos = [

          [377.51, 276.92],
          [381.57, 276.89],
          [384.65, 280.22],
          [385.54, 279.69]]; // shared

        // from acropolis to lindos shared point
        var acropolispos = [
          [428.81, 275.02],
          [428.69, 274.72],
          [431.67, 271.77],
          [427.96, 266.86],
          [425.16, 265.89],
          [422.89, 273.72],
          [425.89, 280.32],
          [430.76, 280.00],
          [436.99, 279.88],
          [437.73, 281.11],
          [432.92, 282.86],
          [426.44, 285.81],
          [419.72, 284.10],
          [410.77, 277.24],
          [406.57, 273.75],
          [404.87, 270.40],
          [391.17, 275.65],
          [385.54, 279.69]]; // shared

        // Given where you are and where you need to go construct a list of point horse must go through to get you to either lindos, acropolis or back to beach
        var fromlist;
        var tolist;

        if (event.action == 'ridelindos') {
          if (horsestate == 'beach') {
            fromlist = beachpos;
          } else if (horsestate == 'acropolis')
            fromlist = acropolispos;
          tolist = lindospos;

          horsestate = "lindos";
        } else if (event.action == 'rideacropolis') {
          if (horsestate == 'beach') {
            fromlist = beachpos;
          } else if (horsestate == 'lindos')
            fromlist = lindospos;
          tolist = acropolispos;
          horsestate = "acropolis";

        } else if (event.action == 'ridebeach') {
          if (horsestate == 'acropolis') {
            fromlist = acropolispos;
          } else if (horsestate == 'lindos')
            fromlist = lindospos;
          tolist = beachpos;
          horsestate = "beach";
        }

        List<List> poshorse = [];
        List<List> poscamera = [];

        print('vvv' + fromlist.toString() + " " + tolist.toString());
        var speed = 3;
        for (var pos in fromlist) {
          poshorse.add([pos[0], pos[1], 0, speed]);
          poscamera.add([pos[0], pos[1], OPENWORLD.Camera.cameraoffset, speed]);
        }

        for (var i = tolist.length - 1; i >= 0; i--) {
          var pos = tolist[i];
          poshorse.add([pos[0], pos[1], 0, speed]);
          poscamera.add([pos[0], pos[1], OPENWORLD.Camera.cameraoffset, speed]);
        }

        // Remove the saddle message thats on top of the saddle
        if (saddle.extra.containsKey('saddlemsg')) {
          OPENWORLD.BaseObject.clearTimers(saddle);
          saddle.remove(saddle.extra['saddlemsg']);
          saddle.extra.remove('saddlemsg');
        }
        // Start playin the clop sound
        audioplayers.AudioPlayer horseclop = OPENWORLD.Sound.getAudioPlayer();
        OPENWORLD.Sound.play(
            sound: horseclop,
            path: "sounds/horseclop.mp3",
            volume: 1,
            loop: true,
            fadein: 2,
            delay: 4);

        // Work out how long will take to get to the destination
        var totaltime = await OPENWORLD.Mob.moveTo(
            horse2, poshorse, action: "walk",
            stopaction: "idle",
            delay: 4,
            surfaceonly: true);
        print("totaltime" + totaltime.toString() + "poshorse" +
            poshorse.toString());
        // Move the camera through the points until get to the destination
        OPENWORLD.Mob.moveTo(camera, poscamera, delay: 4, surfaceonly: true);
        // OPENWORLD.You.setImmobile(false, delay:totaltime);
        // Dismount
        Future.delayed(
            Duration(milliseconds: (totaltime * 1000).round()), () async {
              // now that have reached destination have player get off horse and reanble mobility
          OPENWORLD.You.immobile = false;
          horseclop.stop();
          //var lastpos=poss[poss.length-1];
          var lastpos = tolist[0]; //tolist.length-1];
          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
              camera, lastpos[0], lastpos[1] + 0.2, defaultcameraoffset, 1,
              delay: 1);
          horse2riding = false;
          Future.delayed(Duration(milliseconds: (1000).round()), () async {
            OPENWORLD.Sound.play(path: 'sounds/horse.mp3', volume: 0.5);
            OPENWORLD.Camera.cameraoffset = defaultcameraoffset;
            OPENWORLD.BaseObject.highlight(
                saddle, true, opacity: 0.5, scale: 1.02);
          });
        });
      }

    });

    // Add fish to the sea near the intro
    Group fishorig = await OPENWORLD.Actor.createActor('assets/actors/fish.glb',
        z: 0.1//actoroffset
    );
    fishorig.scale.set(0.01, 0.01, 0.01);
    for (var i=0; i<4; i++) {
      var fish= await OPENWORLD.Actor.copyActor(fishorig);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          fish, 390.33+ 4*(OPENWORLD.Math.random()-0.5),
          346.57  + 10*(OPENWORLD.Math.random()-0.5), 0.1, 4);
      OPENWORLD.Space.objTurn(fish.children[0], 0);
      //  OPENWORLD.Space.objTurn(crab  ,90);  //e
      scene.add(fish);
      OPENWORLD.BaseObject.setDistanceTrigger(fish, dist: 4);
      fish.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
        if (event.action) {
          // Have fish swim around when you are near them
          OPENWORLD.Mob.randomwalk(fish, 0.5, 0.2, 0.9,
              actionduration: 0.5,
              reset: true,
              z:0.1
          );
        } else {
        }
      });
    }

    // create a corpse that can be dropped if you loot a corpse
    corpse= await OPENWORLD.Model.createModel('assets/models/corpse.glb');
    corpse.scale.set(0.005, 0.005, 0.005);


    // Room in lindos for the armourer
    var roomArmourer = OPENWORLD.Room.createRoom(384.260,264.900,
        soundpath: "sounds/shop.mp3", volume: 0.05, exitroom: roomDefault);
    // Set speech about the armourers
    roomArmourer.extra['guide'] = [
      "This place specializes in armour.",
      "You can buy armour here",
      "and get good prices when you sell"
    ];
    // Set that the room is indoors and should check if their is a roof
    OPENWORLD.Room.setAutoIndoors(roomArmourer, true);

    scene.add(roomArmourer);

    // Add the armourer to the scene which was created earlier since it has all the animations
    OPENWORLD.Room.setDistanceTrigger(roomArmourer, dist:0.5);

    setDefaultActor(armourer);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        armourer,OPENWORLD.Room.getX(roomArmourer)+0.7, OPENWORLD.Room.getY(roomArmourer)-0.5, 0, 4);
    OPENWORLD.Space.objTurn(armourer,270+45);  //nw
    scene.add(armourer);
    // If try to kill armourer you either die or go to prison
    addcitizennpc(armourer,"armourer",false);//,false);

    // For the job by the jobknight and player has the card then remind about the order
    OPENWORLD.BaseObject.setDistanceTrigger(armourer, dist: 1);
    armourer.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action&&inventorynames.contains("card")) {
        OPENWORLD.Mob.setSpeech(armourer, ["Do you have an order for me?","I'm expecting one from Gerard at the acropolis"], z: 80, width: 300,  scale:0.4);
      } else {
      }
    });

    // Show the armour cabinet with armour in it
    var armourshop = await OPENWORLD.Plane.loadPlane(
        "assets/textures/armourer.png", 0.6, 0.32, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        armourshop,385.15,264, 0.47, 4);
    OPENWORLD.Space.objTurn(armourshop,210);
    scene.add(armourshop);
    // Add text telling player can click the cabinet
    addMsgToObj(armourshop, "Click for armour", scale:0.0017, z:0.22);

    // Highlight the cabinet to show can click
    OPENWORLD.BaseObject.setHighlight(armourshop, scene, THREE.Color(0x0000ff), 1.0, scale:1.02);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(armourshop, true,scale:1.01, opacity:0.7);
    OPENWORLD.BaseObject.setTouchTrigger(armourshop);
    var markup=1.2;
    var markdown=0.8;
    var helmetprice=80;
    var hauberkprice=80;

    // If click cabinet show the items for sale and your item that the armourer will buy
    armourshop.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      //  print("touched");
      OPENWORLD.BaseObject.highlight( armourshop, true, scale:1.02, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Buy"});
        menuitems.add({"text":"Helmet: "+displayMoney(getBuyPrice(helmetprice,markup)), "command":"helmet"});
        menuitems.add({"text":"Hauberk: "+displayMoney(getBuyPrice(hauberkprice,markup)), "command":"hauberk"});
        menuitems.add({"text":"Sell"});
        if (inventorynames.contains("helmet"))
          menuitems.add({"text":"Helmet: "+displayMoney(getSellPrice(helmetprice,markdown)), "command":"helmetsell"});
        if (inventorynames.contains("hauberk"))
          menuitems.add({"text":"Hauberk: "+displayMoney(getSellPrice(hauberkprice,markdown)), "command":"hauberksell"});
        menuobj=armourshop;
      });
    });

    // Create the items the armourer sells including the menu buttons so can wear it, drop it etc
    var helmet= await OPENWORLD.Model.createModel('assets/models/helmet.glb');
    setValue(helmet,"helmet",helmetprice);
    helmet.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        helmet,OPENWORLD.Room.getX(roomArmourer),OPENWORLD.Room.getY(roomArmourer),0.0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    setGetObject(helmet);// {scalenotselected:1.025, scaleselected:1.05})
    OPENWORLD.BaseObject.highlight(helmet,false);

    var helmetbutton=dropButton("helmet", helmet, icon:"icons/helmet.png");

    // When on ground and pick up the helmet
    setPickupObject(helmet, "helmet", helmetbutton,objectid:"helmet");

    var hauberk= await OPENWORLD.Model.createModel('assets/models/hauberk.glb');
    setValue(hauberk,"hauberk",hauberkprice);
    hauberk.scale.set(0.009, 0.009, 0.009);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hauberk,OPENWORLD.Room.getX(roomArmourer)+0.5,OPENWORLD.Room.getY(roomArmourer),0.0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    setGetObject(hauberk);// {scalenotselected:1.025, scaleselected:1.05})
    OPENWORLD.BaseObject.highlight(hauberk,false);

    var hauberkbutton=  dropButton(hauberk, "hauberk",icon:"icons/hauberk.png");

    // When on ground and pick up the helmet
    setPickupObject(hauberk, "hauberk", hauberkbutton, objectid:"hauberk");

    // This is when you click on the get item in the menu
    armourshop.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
       print("triggermenu armourshop "+event.action.toString());
       if (inventorynames.contains(event.action)) {
         OPENWORLD.Mob.setSpeech(armourer, ["You already have one of those"], z: 80, width: 300, scale: 0.4);
       } else {
         // Buy and sell the items from the shop
         var didgive = true;
         if (event.action == 'helmet') {
           if (gold - getBuyPrice(helmetprice, markup) < 0) {
             actorCannotBuy(armourer);
             didgive=false;
           } else {
             addInventory(
                 "helmet", helmetbutton, helmetprice, objectid: "helmet");
             setGold(gold - getBuyPrice(helmetprice, markup));
           }
         } else if (event.action == 'helmetsell') {
           removeInventory("helmet");
           setGold(gold + getSellPrice(helmetprice, markdown));
         } else if (event.action == 'hauberk') {
           if (gold - getBuyPrice(hauberkprice, markup) < 0) {
             actorCannotBuy(armourer);
             didgive=false;
           } else {
             addInventory(
                 "hauberk", hauberkbutton, hauberkprice, objectid: "hauberk");
             setGold(gold - getBuyPrice(hauberkprice, markup));
           }
         } else if (event.action == 'hauberksell') {
           removeInventory("hauberk");
           setGold(gold + getSellPrice(hauberkprice, markdown));
         }
         if (didgive)
           giveAnimation(armourer);

       }
    });

    // Baccarat room in Lindos - doesnt do anything
    var roomBaccarat = OPENWORLD.Room.createRoom(364.010,246.390,
        soundpath: "sounds/shop.mp3",  randomsoundpath:"sounds/dice.mp3", randomsoundgap:30, volume: 0.05); //THREE.Object3D();
    roomBaccarat.extra['guide'] = [
      "This is a gaming room",
      "and is only available to",
      "Lindos residents",
    ];
    OPENWORLD.Room.setAutoIndoors(roomBaccarat, true);

    scene.add(roomBaccarat);

    OPENWORLD.Room.setDistanceTrigger(roomBaccarat, dist:0.5);

    // Show dealers and players plyaing cards
    var dealer= await OPENWORLD.Actor.copyActor(amon, texture: "assets/actors/citizen3h4.jpg",action:"carddeal");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        dealer,364.07,245.88, 0, 4);
    OPENWORLD.Space.objTurn(dealer,0);  //n
    scene.add(dealer);
    addcitizennpc(dealer,"dealer",false);


    var playingcards = await OPENWORLD.Plane.loadPlane(
        "assets/textures/playingcards.png", 0.08, 0.13, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        playingcards,364.09,246.19,0.27, 4);
    OPENWORLD.Space.setTurnPitchRoll(playingcards,0,90,0);
    scene.add(playingcards);
    OPENWORLD.BaseObject.setHighlight(playingcards, scene, THREE.Color(0x0000ff), 1.0);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(playingcards, true,scale:1.05, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(playingcards);
    // If click the playing cards indicate not playable
    playingcards.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(playingcards, true, scale:1.05, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Blackjack currently for Lindos citizens only."});
        menuobj=playingcards;
      });
    });

    Group citizen6 = await OPENWORLD.Actor.createActor('assets/actors/citizen6.glb',
        shareanimations: armourer,
        action:"idle2",
        z: actoroffset);
    //
    setDefaultActor(citizen6);
    addcitizennpc(citizen6,"citizen6",true);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizen6,364.05, 246.62, 0, 4);// 364.93, 248.11
    OPENWORLD.Space.objTurn(citizen6,180);
    scene.add(citizen6);
    var board= await OPENWORLD.Model.createModel('assets/models/board.glb');
  //  "sx": 0.45 ,"sz": 0.8
    board.scale.set(0.015*0.45, 0.015, 0.015* 0.8);
    OPENWORLD.Space.objTurn(board,190);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board, 365.10,249.35,0.2,4);
    scene.add(board);
    OPENWORLD.BaseObject.setHighlight(board, scene, THREE.Color(0x0000ff), 1.0);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(board, true,scale:1.02, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(board);
    // Indicate that the jackpot isn't working
    board.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(board, true, scale:1.05, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Jackpot currently out of operation."});
        menuobj=board;
      });
    });


    // Bank room in Lindos where can deposit money
    // In future should add interest and ability to take out loans
    var roomBank = OPENWORLD.Room.createRoom(375.400,254.800,
        soundpath: "sounds/shop.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomBank.extra['guide'] = [
      "Place your money here",
      "for safe keeping",
    ];
    OPENWORLD.Room.setAutoIndoors(roomBank, true);

    scene.add(roomBank);

    OPENWORLD.Room.setDistanceTrigger(roomBank, dist:0.5);
    Group bankmanager =
    await OPENWORLD.Actor.createActor('assets/actors/bankmanager.glb',
        shareanimations: armourer,
        action:"idle2",
        z: actoroffset);
    setDefaultActor( bankmanager);

    // Set bank manager chatter - can be three different sets of chat chosen at random
    OPENWORLD.BaseObject.setDistanceTrigger(bankmanager, dist: 1);
    bankmanager.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        var chatters=[
          ["How can I help you?",],
           [  "Im not as boring as people think",
              "I can be the life of the party",
              "I put a lamp shade on my head",
              "everyone laughs"],
          ["This bank is impregnable",
           "Nobody can get past these bars",
           "I have my wits about me"]
        ];
        var chatter=chatters[OPENWORLD.Math.randInt(chatters.length)];
        OPENWORLD.Mob.setSpeech(bankmanager, chatter, z: 80, width: 300,  scale:0.4, randwait:0, minwait:5, delay:10);
      } else {
      }
    });

    // Cannot kill the bankmanager
    addcitizennpc(bankmanager,"bankmanager",false);

    // Show money on bank  bench
    var money= await OPENWORLD.Model.createModel('assets/models/money.glb');
    money.scale.set(0.004, 0.004,0.004);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        money, 375.77, 254.11,0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    //moneyg.add(money);
    scene.add(money);
    OPENWORLD.BaseObject.setHighlight(money, scene, THREE.Color(0x0000ff), 1.0);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(money, true,scale:1.05, opacity:0.7);
    OPENWORLD.BaseObject.setTouchTrigger(money);

    addMsgToObj(money, "Click for banking");
    // When click money show banking options
    money.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(money, true, scale:1.05, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Balance \$"+bank.toString()});
        if (gold>0)
          menuitems.add({"text":"Deposit", "command":"deposit"});
        if (bank>0)
          menuitems.add({"text":"Withdraw", "command":"withdraw"});
        menuobj=money;
      });
    });

    // When choose banking option can enter amount want to deposit or withdraw
    money.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) async {
      print("triggermenu money"+event.action.toString());
      if (event.action=='deposit') {
        setState(() {
          // Disable DomLikeListenable so can type
          _globalKey.currentState?.pause = true;

        });
        var depositstr=await promptDialog('Deposit','Enter amount to deposit out of your total of \$'+gold.toString(),gold.toString());
        setState(() {
          // Disable DomLikeListenable so can type
          _globalKey.currentState?.pause = false;

        });
        if (int.tryParse(depositstr) != null) {
           var deposit=int.parse(depositstr);
           if (deposit>gold)
             OPENWORLD.Mob.setSpeech(bankmanager, ["\$"+depositstr+" is more than you have"], z: 80, width: 300,  scale:0.4);

           else  if (deposit>0){
             giveAnimation(bankmanager);
             setState(() {
               //  gold-=deposit;
               setGold(gold-deposit);
               setBank(bank+deposit);
             //    bank+=deposit;
             });
             OPENWORLD.Mob.setSpeech(bankmanager, ["\$"+depositstr+" has been deposited into your bank account"], z: 80, width: 300,  scale:0.4);


           }
        }

      } else  if (event.action=='withdraw') {
        setState(() {
          // Disable DomLikeListenable so can type
          _globalKey.currentState?.pause = true;

        });
        var widthdrawstr=await promptDialog('Withdraw','Enter amount to withdraw out of your total of \$'+bank.toString(),bank.toString());
        setState(() {
          // Disable DomLikeListenable so can type
          _globalKey.currentState?.pause = false;

        });
        if (int.tryParse(widthdrawstr) != null) {
          var withdraw=int.parse(widthdrawstr);
          if (withdraw>gold)
            OPENWORLD.Mob.setSpeech(bankmanager, ["\$"+widthdrawstr+" is more than you have deposited"], z: 80, width: 300,  scale:0.4);

          else  if (withdraw>0){
            giveAnimation(bankmanager);
            setState(() {
              setGold(gold+withdraw);
              setBank(bank-withdraw);
            });
            OPENWORLD.Mob.setSpeech(bankmanager, ["\$"+widthdrawstr+" has been withdrawn from your bank account"], z: 80, width: 300,  scale:0.4);
          }
        }

      }
    });

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bankmanager,OPENWORLD.Room.getX(roomBank)+0.3, OPENWORLD.Room.getY(roomBank)-1, 0, 4);
    OPENWORLD.Space.objTurn(bankmanager,0);  //n
    scene.add(bankmanager);

    // road in lindos with the beggar who will attack you
    var roomBeggar = OPENWORLD.Room.createRoom(373.936,267.67,
        soundpath: "sounds/courtyard.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    scene.add(roomBeggar);

    OPENWORLD.Room.setDistanceTrigger(roomBeggar, dist:0.5);

    // Beggar sits on the ground
    var beggar = await OPENWORLD.Actor.createActor('assets/actors/citizen4.glb',
        shareanimations: armourer,
        action:"sitidle",
        z: actoroffset);

    OPENWORLD.Mob.setName(beggar,"beggar");  // This is why the beggar text is blue
    setDefaultActor(beggar);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        beggar,OPENWORLD.Room.getX(roomBeggar)-0.45, OPENWORLD.Room.getY(roomBeggar), -0.04, 4);
    OPENWORLD.Space.objTurn(beggar,90);  //e
    scene.add(beggar);

    var chatter=["I just need a little money to buy to some food. Can you spare a few coins?",
      "I lost my money somewhere. Can I have a little just to tide me over for a while?",
      " ... in heavan all the interesting people are missing!",

      "Don't discourage someone who continually makes progress, no matter how slow",

      "Wise men talk because they have something to say unlike fools who talk because they have to say something",

      "People aren't against injustice because they hate injustice, they just dont want it to happen to them",
      "Give me some money."];
    OPENWORLD.Mob.setChatter(beggar, chatter,   z: 80, width: 300, scale:0.4);

    // Can kill the beggar
    addnpc(beggar, "begger", false, deathsoundpath: "sounds/die.mp3");

    OPENWORLD.BaseObject.setDistanceTrigger(beggar, dist: 2);

    // If get close to beggar will try to kill you
    beggar.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {

        OPENWORLD.Actor.playActionThen(beggar, "sit", "sitidle",   durationthen:2);
        OPENWORLD.Space.faceObjectLerp(beggar, camera,1);
        OPENWORLD.Actor.playActionThen(beggar, "sit", "idle", duration:2, backwards:true, durationthen:2);
        OPENWORLD.Mob.placeBeforeCamera(beggar, 0.4, time:1,delay:3, action:"walk", stopaction:"idle");
        OPENWORLD.Mob.setSpeech(beggar, ["Give me some money","Give me money!"], z: 80, width: 300, delay:5, scale:0.4);

        var t=Timer.periodic(Duration(seconds: 5), (timer) {
          OPENWORLD.Actor.playActionThen(beggar, "punch", "idle", duration:1, durationthen:2);//, delay:5);
          youStruck();
          setHealth(health-getActorDamage(beggar));
          if (isDead()) {//health<=0) {
            Fluttertoast.showToast(
                msg: "Your life force drifts away...",
                toastLength: Toast.LENGTH_LONG);
            youDie();

          }

          var dist=OPENWORLD.Space.getDistanceBetweenObjs(camera, beggar);
          if (dist>2||isDead()) {//health<=0) {
            timer.cancel();
            if (isDead()) {//health<=0) {
              OPENWORLD.BaseObject.clearTimers(beggar);
              OPENWORLD.Actor.playActionThen(beggar, "sit", "sitidle",   durationthen:2, delay:5);
              OPENWORLD.Mob.setSpeech(beggar, ["Some people dont listen"], z: 80, width: 300, delay:5, scale:0.4);
              endo();

            }
          } else {
            if (dist>0.5)
               OPENWORLD.Mob.placeBeforeCamera(beggar, 0.4, time:1,delay:3, action:"walk", stopaction:"idle");
          }
        });
        OPENWORLD.BaseObject.addTimer(beggar,t);

      } else {
        print("trigger out beggar");
        OPENWORLD.BaseObject.clearTimers(beggar);
        // When move away from beggar goes back to sitting on the ground
        OPENWORLD.Actor.playActionThen(beggar, "sit", "sitidle",   durationthen:2);
      }
    });

    // Will drop pants for money sign
    var beggarsign = await OPENWORLD.Plane.loadPlane(
        "assets/textures/beggarsign.jpg", 0.15, 0.15, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        beggarsign,373.47, 267.29, 0.07, 4);//373.65, 267.26
    OPENWORLD.Space.objTurn(beggarsign,102+180+90);
    scene.add(beggarsign);

    // Blackjack room in Lindos that does nothing
    var roomBlackjack = OPENWORLD.Room.createRoom(364.310,247.710,
        soundpath: "sounds/shop.mp3", randomsoundpath:"sounds/dice.mp3", randomsoundgap:30, volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomBlackjack.extra['guide'] = [
      "Gaming room is currently",
      "only available to Lindos",
      "residence"
    ];
    OPENWORLD.Room.setAutoIndoors(roomBlackjack, true);

    scene.add(roomBlackjack);

    // Show dealer and player playing cards
    OPENWORLD.Room.setDistanceTrigger(roomBlackjack, dist:0.5);
    var dealer2= await OPENWORLD.Actor.copyActor(amon, texture: "assets/actors/citizen3h4.jpg",action:"carddeal");

    setDefaultActor(dealer2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        dealer2,364.18,248.16, 0, 4);
    OPENWORLD.Space.objTurn(dealer2,90);  //e
    scene.add(dealer2);

    addcitizennpc(dealer2,"dealer2",false);

    OPENWORLD.BaseObject.setDistanceTrigger(dealer2, dist: 1);
    dealer2.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        chatter=[
          "Are you going to make a bet",
          "or just stand there?"];
        OPENWORLD.Mob.setSpeech(dealer2, chatter, z: 80, width: 300,  scale:0.4, randwait:0, minwait:5, delay:OPENWORLD.Math.random()*30);
      } else {
      }
    });
    var citizen62= await OPENWORLD.Actor.copyActor(citizen6, texture: "assets/actors/citizen62.jpg",action:"idle2");
    setDefaultActor(citizen62);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizen62,364.84, 248.10, 0, 4);// 364.93, 248.11
    OPENWORLD.Space.objTurn(citizen62,270);
    scene.add(citizen62);
    addcitizennpc(citizen62,"citizen62",true);

    // Bottle shop in lindos where player can buy drinks to boost health
    var roomBottleshop = OPENWORLD.Room.createRoom(375.640,267.140,
        soundpath: "sounds/shop.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomBottleshop.extra['guide'] = [
      "You can buy drinks from ",
      "here and take them with you.",
      "These drinks can give you a",
      "boost when your under the weather"
    ];
    OPENWORLD.Room.setAutoIndoors(roomBottleshop, true);
    scene.add(roomBottleshop);

    OPENWORLD.Room.setDistanceTrigger(roomBottleshop, dist:0.5);

    Group bottleshopowner =
    await OPENWORLD.Actor.createActor('assets/actors/citizen7.glb',
        action:"idle2",
        shareanimations: armourer,
        z: actoroffset);

    setDefaultActor(bottleshopowner);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bottleshopowner,OPENWORLD.Room.getX(roomBottleshop)+0.8, OPENWORLD.Room.getY(roomBottleshop), 0, 4);
    OPENWORLD.Space.objTurn(bottleshopowner,270);  //w
    scene.add(bottleshopowner);
    addcitizennpc(bottleshopowner,"bottleshopowner",false);
    // When enter room bottleshop owner will randomly burp
    roomBottleshop.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        var delay=OPENWORLD.Math.random()*20;
        OPENWORLD.Sound.play( path: 'sounds/burp.wav', volume: 0.1, delay:delay);
        OPENWORLD.Sound.play( path: 'sounds/burp2.wav', volume: 0.1, delay:delay+5);
        chatter=["Pardon me"];
        OPENWORLD.Mob.setSpeech(bottleshopowner, chatter, z: 80, width: 300,  scale:0.4, randwait:0, minwait:5, delay:delay);

        chatter=["I can see two of you.",
          "Sometimes I have to try out my wares",
          "Watch out for the beggar. He's a nasty piece of work"];
        OPENWORLD.Mob.setChatter(bottleshopowner, chatter,  z: 80, width: 300, scale:0.4, delay:delay+5);

        // bottleshop owner will walk into the wall
        OPENWORLD.Mob.moveTo(bottleshopowner, [ [ 376.49, 266.72,0,0.5]] , action:"walk", stopaction:"idle", delay:delay+16);
        OPENWORLD.Mob.moveTo(bottleshopowner, [  [OPENWORLD.Room.getX(roomBottleshop)+0.8, OPENWORLD.Room.getY(roomBottleshop)]] , action:"walk", stopaction:"idle", delay:delay+24);

        OPENWORLD.Space.faceObjectAlways(bottleshopowner,camera,delay:delay+20);

      }
    });

    // If click bottles in cabint will show menu allowing you to buy drinks
    var bottleshop = await OPENWORLD.Plane.loadPlane(
        "assets/textures/bottleshop.png", 0.5, 0.32, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bottleshop,378,267.6, 0.37, 4);
    OPENWORLD.Space.objTurn(bottleshop,195);
    scene.add(bottleshop);
    addMsgToObj(bottleshop, "Click for drinks", scale:0.0017, z:0.27);

    OPENWORLD.BaseObject.setHighlight(bottleshop, scene, THREE.Color(0x0000ff), 1.0, scale:1.025);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(bottleshop, true,scale:1.01, opacity:0.7);
    OPENWORLD.BaseObject.setTouchTrigger(bottleshop);
    var rieslingprice=15;
    var beerprice=10;
    var wineprice=10;
    bottleshop.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      //  print("touched");
      OPENWORLD.BaseObject.highlight( bottleshop, true, scale:1.02, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"White Riesling: "+displayMoney(rieslingprice), "command":"riesling"});
        menuitems.add({"text":"Porter Beer: "+displayMoney(beerprice), "command":"beer"});
        menuitems.add({"text":"Gattinara Wine: "+displayMoney(wineprice),"command":"wine"});
        menuobj=bottleshop;
      });
    });

    var bottle= await OPENWORLD.Model.createModel('assets/models/bottle.glb');
    bottle.scale.set(0.04, 0.04, 0.04);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bottle,OPENWORLD.Room.getX(roomBottleshop),OPENWORLD.Room.getY(roomBottleshop),0.0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    setGetObject(bottle);// {scalenotselected:1.025, scaleselected:1.05})
    OPENWORLD.BaseObject.highlight(bottle,false);
    bottlebutton=PopupMenuButton(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
          "icons/bottle.png",
          width: 50,
        ),
      ),
      onSelected: (value) async {
        if (value == "drop") {
          scene.add(bottle);

          OPENWORLD.Space.placeBeforeCamera(bottle, 1);
          OPENWORLD.BaseObject.highlight(bottle, true);  // turn highlight back on
          OPENWORLD.BaseObject.deselectHighLight(bottle);  // put it back to deselected state

          for (var i=0; i<inventory.length; i++) {
            if (inventory[i] == bottlebutton) {
              removeInventory(inventorynames[i]);
            }
          }
          OPENWORLD.Space.readdObjFromHide(bottle);
        } else if (value=='drink') {
          for (var i=0; i<inventory.length; i++) {
            if (inventory[i]==bottlebutton) {
              OPENWORLD.Sound.play( path: 'sounds/burp.wav', volume: 0.2);
              var fct=1.0;
              if (inventorynames[i]=='riesling')
                fct=1.5;
              else
                fct=1.25;
              setHealth(health*fct);

              removeInventory(inventorynames[i]);
              Fluttertoast.showToast(
                  msg: "You feel a little tipsy",
                  toastLength: Toast.LENGTH_LONG);
            }
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[

        PopupMenuItem(
          value: "drop",
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.download),
              ),
              const Text(
                'Drop',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "drink",
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.wine_bar),
              ),
              const Text(
                'Drink',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );

    // When on ground and pick up the bottle
    setPickupObject(bottle, "bottle", bottlebutton, objectid:"bottledrink");

    // This is where you click on the menu
    bottleshop.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) async {
      print("triggermenu bottleshop"+event.action);
      if (inventoryobjectids.contains("bottledrink")) {
        OPENWORLD.Mob.setSpeech(bottleshopowner, ["Sorry, we can only sell you one at a time"], z: 80, width: 300, scale: 0.4);
      } else {
        var hasgiven = true;
        if (event.action == 'riesling') {
          if (gold - 15 < 0) {
            actorCannotBuy(bottleshopowner);
            hasgiven = false;
          } else {
            setGold(gold - 15);
            addInventory(
                "riesling", bottlebutton, rieslingprice,
                objectid: "bottledrink");
          }
        } else if (event.action == 'wine') {
          if (gold - 10 < 0) {
            actorCannotBuy(bottleshopowner);
            hasgiven = false;
          } else {
            setGold(gold - 10);
            addInventory(
                "wine", bottlebutton, wineprice, objectid: "bottledrink");
          }
        } else if (event.action == 'beer') {
          if (gold - 10 < 0) {
            actorCannotBuy(bottleshopowner);
            hasgiven = false;
          } else {
            setGold(gold - 10);
            addInventory(
                "beer", bottlebutton, beerprice, objectid: "bottledrink");
          }
        }
        if (hasgiven)
          giveAnimation(bottleshopowner);
      }

    });
    // Bottle shop owner holds a bottle of drink
    var bottle3=bottle.clone();
    bottle3.scale.set(5.0,5.0,5.0);
    bottle3.position.set(0.0,0.0,0.0);
    OPENWORLD.Actor.wield(bottleshopowner,bottle3,"Bip01_R_Finger11");

    // Brewery in Lindos for brewing beer. Doesnt actually do anything
    var roomBrewery = OPENWORLD.Room.createRoom(373.351,241.526,
        soundpath: "sounds/shop.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomBrewery.extra['guide'] = [
      "Many of the hotels",
      "and restaurants",
      "of Lindos",
      "get their drinks from here"
    ];
    OPENWORLD.Room.setAutoIndoors(roomBrewery, true);

    scene.add(roomBrewery);

    OPENWORLD.Room.setDistanceTrigger(roomBrewery, dist:0.5);

    Group citizen =
    await OPENWORLD.Actor.createActor('assets/actors/citizen.glb',
        shareanimations: armourer,
        action:"idle2",
        z: actoroffset);

    setDefaultActor(citizen);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizen,374.39, 242.26,0,4);//OPENWORLD.Room.getX(roomBrewery)-0.5, OPENWORLD.Room.getY(roomBrewery), 0, 4);
    OPENWORLD.Space.objTurn(citizen,180);  //s
    scene.add(citizen);
    addcitizennpc(citizen,"citizen",false);  // Cannot kill owner

    OPENWORLD.BaseObject.setDistanceTrigger(citizen, dist: 1);
    citizen.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Space.faceObjectAlways(citizen, camera,delay:5);

        var chatters=[
          ["We only sell to bottleshops"],

          [  "It plays on my mind",
            "This brewery is responsible",
            "for half the drunks in Lindos",
            "Maybe I should become a monk",
            "But I like the ladies too much",
            ],
          ["Before the knights hospitiller",
          "this brewery was a fish shop",
          "Its funny the knights drink like fish",]
        ];
        var chatter=chatters[OPENWORLD.Math.randInt(chatters.length)];
        OPENWORLD.Mob.setSpeech(citizen, chatter, z: 80, width: 300,  scale:0.4, randwait:0, minwait:5, delay:10);
      } else {
        OPENWORLD.Space.faceObjectAlwaysRemove(citizen);
      }
    });

    // Indicate that the brewery doesnt actually sell anything
    var barrel= await OPENWORLD.Model.createModel('assets/models/barrel.glb');
    barrel.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObj(barrel,373.6,243,0);
    scene.add(barrel);
    OPENWORLD.BaseObject.setHighlight(barrel, scene, THREE.Color(0x0000ff), 1.0);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(barrel, true,scale:1.025, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(barrel);

    barrel.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(barrel, true, scale:1.05, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"This is where most Lindos's alcohol is brewed"});
        menuobj=barrel;
      });
    });

    // Butcher where can sell corpses and make money
    // There is a blow fly that randomly makes a sound
    var roomButcher = OPENWORLD.Room.createRoom(389.520,245.900,
        soundpath:"sounds/shop.mp3",
        randomsoundpath: "sounds/fly.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomButcher.extra['guide'] = [
      "The butcher will",
      "buy any sort of meat",
      "not questions asked.",
    ];
    OPENWORLD.Room.setAutoIndoors(roomButcher, true);

    scene.add(roomButcher);

    OPENWORLD.Room.setDistanceTrigger(roomButcher, minx:389, maxx:391.2, miny:244.25, maxy:248.1);// dist:0.5);

    Group butcher =
    await OPENWORLD.Actor.createActor('assets/actors/butcher.glb',
        shareanimations: armourer,
        action:"idle2",
        z: actoroffset);

    setDefaultActor(butcher);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        butcher,OPENWORLD.Room.getX(roomButcher)+1, OPENWORLD.Room.getY(roomButcher), 0, 4);
    OPENWORLD.Space.objTurn(butcher,270);  //w
    scene.add(butcher);
    addcitizennpc(butcher,"butcher",false);

    OPENWORLD.BaseObject.setDistanceTrigger(butcher, dist: 1.0);
    butcher.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      print("butcher dist" + event.action.toString());
      if (event.action) {
        chatter=["Pleased to meet you & meat to please you",
          "My brother in a knight. His name is Sir Loin"];
        OPENWORLD.Mob.setChatter(butcher, chatter,  z: 80, width: 300, scale:0.4);

      }
    });


    // Rat moves around the butchers - can kill it and sell the corpse
    // Perhaps should have cat and rat like in mud?
    Group rat = await OPENWORLD.Actor.createActor('assets/actors/rat.glb',
        z:0);
    rat.scale.set(0.01,0.01,0.01);
    var ratposs=[[389.76, 245.18],
      [390.08, 247.31],
      [389.45, 246.78]];
    var ratpos=ratposs[OPENWORLD.Math.randInt(ratposs.length)];
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        rat,ratpos[0],ratpos[1], 0, 4);
    setActorHealth(rat,0.3);// rat should be easy to kil
    OPENWORLD.Space.objTurn(rat,OPENWORLD.Math.random()*360);
    scene.add(rat);
    OPENWORLD.BaseObject.setDistanceTrigger(rat, dist: 4);
    rat.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Mob.randomwalk(rat, 0.2, 0.15, 0.1,
            action: "walk", actionduration: 0.5,
            stopaction: "idle",
            reset: true
        );
      }
    });
    // Can kill rat and get the corpse
    addnpc(rat, "rat", true, deathsoundpath: "sounds/rat.mp3");

    // Show meat in butchers
    var meat3=await OPENWORLD.Model.createModel('assets/models/meat.glb');
    meat3.scale.set(0.04, 0.04, 0.04);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        meat3,390.07, 245.45,0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    OPENWORLD.Space.objTurn(meat3,0);
    scene.add(meat3);

    var meat4=meat3.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        meat4,389.90, 245.94,0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    OPENWORLD.Space.objTurn(meat4,0);
    scene.add(meat4);

    var meat5=meat3.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        meat5,389.79, 246.30,0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    OPENWORLD.Space.objTurn(meat5,0);
    scene.add(meat5);

    // Meat menu to sell corpses - will get different amounts for different corpses
    var meat=await OPENWORLD.Model.createModel('assets/models/meat3.glb');
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        meat,390.04,246.33,0,4);//389.91, 245.83,0, 4);
    meat.scale.set(0.2, 0.2, 0.2);
    OPENWORLD.Space.objPitch(meat,-90);
    scene.add(meat);
    addMsgToObj(meat, "Click to sell meat\n", scale:0.007, z:1.5);
    OPENWORLD.BaseObject.setHighlight(meat, scene, THREE.Color(0x0000ff), 0.2, scale:1.08);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(meat, true,scale:1.08, opacity:0.2);
    OPENWORLD.BaseObject.setTouchTrigger(meat);

    meat.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      OPENWORLD.BaseObject.highlight( meat, true, scale:1.2, opacity:0.2);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=20;//clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Sell"});
        menuitems.add({"text":"Agrios skylos (wild dog): 100", "command":"wilddog"});
        menuitems.add({"text":"Crab: 15", "command":"crab"});
        menuitems.add({"text":"Sheep: 15", "command":"sheep"});
        menuitems.add({"text":"Skylos (dog): 10", "command":"dog"});
        menuitems.add({"text":"Gatos (cat): 10", "command":"cat"});
        menuitems.add({"text":"Nyfitsa (rat): 5", "command":"rat"});
        menuobj=meat;
      });
    });

    // This is where you click on the menu
    meat.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) async {
      print("triggermenu meat"+event.action);

      var give=false;
      if (event.action=='wilddog') {
        if (inventorynames.contains("corpse_wilddog")) {
          setGold(gold+100);

          removeInventory("corpse_wilddog");
          OPENWORLD.Mob.setSpeech(butcher,['Thank you for wild dog meat.','The farmers of Lindos will be pleased'],  z: 80, width: 300, scale: 0.4);
          give=true;
        } else {
          OPENWORLD.Mob.setSpeech(butcher,['You dont have any wild dog meat to sell'], z: 80, width: 300, scale: 0.4);
        }
      } else  if (event.action=='crab') {
        if (inventorynames.contains("corpse_crab")) {
          setGold(gold + 15);

          removeInventory("corpse_crab");
          give=true;

        }else {
          OPENWORLD.Mob.setSpeech(butcher,['You dont have any crab to sell'], z: 80, width: 300, scale: 0.4);

        }

      } else  if (event.action=='sheep') {
        if (inventorynames.contains("corpse_sheep")) {
          setGold(gold + 15);

          removeInventory("corpse_sheep");
          give=true;

        }else {
          OPENWORLD.Mob.setSpeech(butcher,['You dont have any lamb to sell'], z: 80, width: 300, scale: 0.4);
        }

      } else  if (event.action=='dog') {
        if (inventorynames.contains("corpse_dog")) {
          setGold(gold+10);

          removeInventory("corpse_dog");
          OPENWORLD.Mob.setSpeech(butcher,['Thank you.','Hope this isnt Rufus'], z: 80, width: 300, scale: 0.4);
          give=true;

        } else {
          OPENWORLD.Mob.setSpeech(butcher,['You dont have any dog meat to sell'], z: 80, width: 300, scale: 0.4);

        }
      } else  if (event.action=='cat') {
        if (inventorynames.contains("corpse_cat")) {

          setGold(gold+10);
          removeInventory("corpse_cat");
          OPENWORLD.Mob.setSpeech(butcher,['Thank you. '], z: 80, width: 300, scale: 0.4);
          give=true;

        } else {
          OPENWORLD.Mob.setSpeech(butcher,['You dont have any cat meat to sell'], z: 80, width: 300, scale: 0.4);
        }
      } else  if (event.action=='rat') {
        if (inventorynames.contains("corpse_rat")) {

          setGold(gold+5);
          removeInventory("corpse_rat");
          OPENWORLD.Mob.setSpeech(butcher,['Thank you for cleaning up the vermin in Lindos'], z: 80, width: 300, scale: 0.4);
          give=true;

        } else {
          OPENWORLD.Mob.setSpeech(butcher,['You dont have any rat meat to sell'], z: 80, width: 300, scale: 0.4);

        }
      }
      if (give)
        giveAnimation(butcher);
    });

    // Have a citizen in the butchers looking at the rat making comments about the rat
    var citizen4= await OPENWORLD.Actor.copyActor(beggar, texture: "assets/actors/citizen42.jpg",);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizen4,389.76, 245.47, 0, 4);  //389.55,245.42
    OPENWORLD.Space.objTurn(citizen4,90);  //e
    scene.add(citizen4);
    OPENWORLD.BaseObject.setCustomTrigger(citizen4);

    OPENWORLD.Space.faceObjectAlways(citizen4, rat);
    OPENWORLD.BaseObject.setDistanceTrigger(citizen4, dist: 1.0);
    citizen4.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      print("citizen4 dist" + event.action.toString());
      if (event.action) {
        chatter=["Did you see that, a big rat?",
          "Are you going to get rid of the rats?",
        "My word, a big rat!",
        "When are you going to get rid of the rats?"];
        OPENWORLD.Mob.setChatter(citizen4, chatter,  z: 80, width: 300, scale:0.4);

      }
    });

    // This is the prison courtyard with two prisoners and a guard
    var roomCourtyard = OPENWORLD.Room.createRoom(365.82, 279.45,//366.617,279.593,
        soundpath: "sounds/courtyard.mp3", volume: 0.01,exitroom: roomDefault); //THREE.Object3D();

    OPENWORLD.Room.setAutoIndoors(roomCourtyard, true);
    roomCourtyard.extra['guide'] = [
      "Sometimes they let",
      "prisoners out for",
      "exercise.",
      "They get a really long workout"
    ];
    scene.add(roomCourtyard);

    OPENWORLD.Room.setDistanceTrigger(roomCourtyard, dist:1.0);
    // have sound of prisoners doing starjumps in the courtyard
    var soundstarjump; //=OPENWORLD.Sound.getAudioPlayer();
    roomCourtyard.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        soundstarjump=OPENWORLD.Sound.getAudioPlayer();
        print("in courtyard");
         OPENWORLD.Sound.play(
            sound: soundstarjump,
            path: "sounds/starjump.mp3",
            volume: 0.1,
            loop: true,
            fadein: 2);
      } else {
        print("out courtyard");
        if (soundstarjump!=null)
          OPENWORLD.Sound.fadeOut(soundstarjump,1);
      }
    });

    // Prisoner doing star jumps
    Group citizen2 =
    await OPENWORLD.Actor.createActor('assets/actors/citizen2.glb',
        shareanimations: armourer,
        action:"starjump",
        z: actoroffset);
    setDefaultActor(citizen2);
    var prisoner =
    await OPENWORLD.Actor.copyActor(citizen2,//'assets/actors/citizen2.glb',
      texture: "assets/actors/citizen22.jpg",
      //   z: actoroffset
      action:"starjump"
    );
    setDefaultActor(prisoner);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        prisoner,366.617-0.2, 279.593-0.1, 0, 4,lerpopacity: 1);
    OPENWORLD.Space.objTurn(prisoner,180);  //n
    scene.add(prisoner);
    addcitizennpc(prisoner,"prisoner",true);  // You can kill the prisoner

    OPENWORLD.BaseObject.setDistanceTrigger(prisoner, dist: 2.0);
    prisoner.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        chatter = ["Can I have a rest soon? I've been doing this for hours.",
          "Please have mercy. When can I have a breather?",
          "Can I do some pushups soon?"];
        OPENWORLD.Mob.setChatter(
            prisoner, chatter, z: 80, width: 300, scale: 0.4);
      }
    });

    // Create the second prisoner doing star jumps
    var prisoner2 =
    await OPENWORLD.Actor.copyActor(citizen2,
        texture: "assets/actors/citizen23.jpg",
        action:"starjump"
    );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        prisoner2,366.617-0.4,279.593-0.1, 0, 4,lerpopacity: 1);
    OPENWORLD.Space.objTurn(prisoner2,180);  //n
    scene.add(prisoner2);
    addcitizennpc(prisoner2,"prisoner2",true);

    // Guard watching the prisoners
    Group guard = await OPENWORLD.Actor.createActor('assets/actors/knight.glb',
        shareanimations: armourer,
        action:"idle2",
        z: actoroffset);
    setDefaultActor(guard);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        guard,365.81, 278.74,0,4);
    OPENWORLD.Space.objTurn(guard,360-45+90);  //nw
    scene.add(guard);

    OPENWORLD.BaseObject.setDistanceTrigger(guard, dist: 2.0);
    guard.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        chatter = ["Lift those legs & one & two & three &",
          "Keep it going",
          "Remember no pain no gain",
          "& stretch and one & two & ..",
          "Nearly there, keep it up"];
        OPENWORLD.Mob.setChatter(guard, chatter, z: 80, width: 300, scale: 0.4);
      }
    });
    addknightnpc(guard,"guard");  // cannot kill guard

    // Endoplasm room where regenerate if you die
    var roomEndo= OPENWORLD.Room.createRoom(374.846,272.103,
        soundpath: "sounds/church.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();

    OPENWORLD.Room.setAutoIndoors(roomEndo, true);
    roomEndo.extra['guide'] = [
      "If you die sometimes",
      "your spirit comes here",
      "and if you prey you",
      "are resurrected"
    ];
    scene.add(roomEndo);

    OPENWORLD.Room.setDistanceTrigger(roomEndo, dist:0.5);

    // Have a citizen praying the church
    Group citizen5 =
    await OPENWORLD.Actor.createActor('assets/actors/citizen5.glb',action:"pray",
        shareanimations: armourer,
        z: actoroffset);

    setDefaultActor(citizen5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizen5,OPENWORLD.Room.getX(roomEndo)+0.3, OPENWORLD.Room.getY(roomEndo)+0.3, 0, 4);
    OPENWORLD.Space.objTurn(citizen5,0);  //n
    scene.add(citizen5);
    addcitizennpc(citizen5,"citizen5",true); // Can kill the citizen

    OPENWORLD.BaseObject.setDistanceTrigger(citizen5, dist: 2.0);
    citizen5.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        chatter = ["An eye for an eye makes everyone blind",
          "Please God, save us from Sulamein",
          "Please God, rid us of spies and traitors"];
        OPENWORLD.Mob.setChatter(
            citizen5, chatter, z: 80, width: 300, scale: 0.4);
      }
    });

    // Add light at the top of the church lighting up lindos
    var churchlight= new THREE.PointLight(0xFFA500); //PointLight(0xffffff)
    churchlight.intensity = 1.0; // 0.6;
    churchlight.distance = 20;

    OPENWORLD.Light.addFlicker(churchlight);
    OPENWORLD.Light.addNightOnly(churchlight);
    scene.add(churchlight);
    OPENWORLD.Space.worldToLocalSurfaceObj(churchlight,374.65, 272.26,5);

    // Room for general store in Lindos where can buy and sell general items
    var roomGeneralstore= OPENWORLD.Room.createRoom(380.480,258.710,
        soundpath: "sounds/shop.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();
    roomGeneralstore.extra['guide'] = [
      "This general store",
      "buy and sells",
      "general items",
    ];
    OPENWORLD.Room.setAutoIndoors(roomGeneralstore, true);

    scene.add(roomGeneralstore);

    OPENWORLD.Room.setDistanceTrigger(roomGeneralstore, dist:0.5);

    Group storeman =
    await OPENWORLD.Actor.createActor('assets/actors/storeman.glb',
        z: actoroffset);

    setDefaultActor(storeman);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        storeman,OPENWORLD.Room.getX(roomGeneralstore)-0.9, OPENWORLD.Room.getY(roomGeneralstore), 0, 4);
    OPENWORLD.Space.objTurn(storeman,90);  //
    scene.add(storeman);
    addcitizennpc(storeman,"storeman",false);

    // If click on newspapers show general store buy/sell options
    var newspapers= await OPENWORLD.Model.createModel('assets/models/newspapers.glb');
    newspapers.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(newspapers,380.34,259.14,0,4);
    scene.add(newspapers);
    addMsgToObj(newspapers, "Click for store");//, scale:0.15, z:15);

    markup=1.2;
    markdown=0.8;
    var torchprice=5;
    var bucketprice=20;
    var broomprice=20;

    OPENWORLD.BaseObject.setHighlight(newspapers, scene, THREE.Color(0x0000ff), 1.0);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(newspapers, true,scale:1.05, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(newspapers);
    newspapers.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight( newspapers, true, scale:1.1, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Buy"});
        menuitems.add({"text":"Torch: "+displayMoney(getBuyPrice(torchprice, markup)), "command":"torch"});
        menuitems.add({"text":"Bucket: "+displayMoney(getBuyPrice(bucketprice, markup)), "command":"bucket"});
        menuitems.add({"text":"Broom: "+displayMoney(getBuyPrice(broomprice, markup)), "command":"broom"});
        menuitems.add({"text":"Sell"});
        if (inventorynames.contains("torch"))
          menuitems.add({"text":"Torch "+displayMoney(getSellPrice(torchprice, markdown)), "command":"torchsell"});
        if (inventorynames.contains("bucket"))
          menuitems.add({"text":"Bucket "+displayMoney(getSellPrice(bucketprice, markdown)), "command":"bucketsell"});
        if (inventorynames.contains("broom"))
          menuitems.add({"text":"Broom "+displayMoney(getSellPrice(broomprice, markdown)), "command":"broomsell"});
      //  menuitems.add({"text":"Kindling "+displayMoney(getSellPrice(kindlingprice, markdown)), "command":"kindling"});
        menuobj=newspapers;
      });
    });
    // Create general store items that can buy and sell
    var bucket= await OPENWORLD.Model.createModel('assets/models/bucket.glb');
    setValue(bucket, "bucket",bucketprice);
    bucket.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(bucket,OPENWORLD.Room.getX(roomGeneralstore), OPENWORLD.Room.getY(roomGeneralstore),0.0,4);
    setGetObject(bucket,on:false);// {scalenotselected:1.025, scaleselected:1.05})
    var bucketbutton=dropButton("bucket",bucket,icon:"icons/bucket.png");
    setPickupObject(bucket, "bucket", bucketbutton,objectid:"bucket");

    var broom= await OPENWORLD.Model.createModel('assets/models/broom.glb');
    setValue(broom,"broom", broomprice);
    broom.scale.set(0.01, 0.01, 0.01);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(broom,OPENWORLD.Room.getX(roomGeneralstore), OPENWORLD.Room.getY(roomGeneralstore),0.0,4);
    setGetObject(broom,on:false);// {scalenotselected:1.025, scaleselected:1.05})
    var broombutton=dropButton("broom",broom, icon:"icons/broom.png");
    setPickupObject(broom, "broom", broombutton,objectid:"broom");

    // Create flaming torch that you can wield and shines at night
    var fireWidth = 2;
    var fireHeight = 4;
    var fireDepth = 2;
    var sliceSpacing = 0.5;
    var torch= await OPENWORLD.Model.createModel('assets/models/torch.glb');
    setValue(torch,"torch", torchprice);
    torch.scale.set(0.007, 0.007, 0.007);
    var brandfire = new VolumetricFire(
        fireWidth, fireHeight, fireDepth, sliceSpacing, camera);
    await brandfire.init();
    // _space.worldToLocalSurfaceObj(fire?.mesh, 7.0, 2.0, 0.33); //3.7);
    brandfire.mesh.scale.x = 5; //0.05;
    brandfire.mesh.scale.y = 5; //0.05;
    brandfire.mesh.scale.z = 5; //0.05;
    brandfire.mesh.position.x = 18;//0.25; //33;
    brandfire.mesh.position.z = 8;//0.25; //33;
    OPENWORLD.Space.objPitch(brandfire.mesh, -90);
    //scene.add(fire?.mesh);
    torch.add(brandfire.mesh);

    OPENWORLD.Updateables.add(brandfire);
    var light= new THREE.PointLight(0xFFA500); //PointLight(0xffffff)

    light.intensity = 1.0; // 0.6;
    light.distance = 1.2;
    light.position.y = 0.33;
    OPENWORLD.Light.clock=clock;
    OPENWORLD.Light.addFlicker(light);
    OPENWORLD.Light.addNightOnly(light);
    torch.add(light);

    // Need to set a position even if not adding to seen so when drop it can readd to hiddenobjects
    OPENWORLD.Space.worldToLocalSurfaceObjHide(torch,OPENWORLD.Room.getX(roomGeneralstore), OPENWORLD.Room.getY(roomGeneralstore),0.0,4);

    setGetObject(torch, on:false);// {scalenotselected:1.025, scaleselected:1.05})

    var torchbutton=dropWieldButton("torch", torch, icon:"icons/torch.png");

    setPickupObject(torch, "torch", torchbutton,objectid:"torch");


    // This is where you click on the menu
    newspapers.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) async {
      print("triggermenu newspaper"+event.action);

      if (inventorynames.contains(event.action)) {
        OPENWORLD.Mob.setSpeech(storeman, ["You already have one of those"], z: 80, width: 300, scale: 0.4);
      } else {
        var didgive=true;
        if (event.action == 'torch') {
          if (gold - getBuyPrice(torchprice, markup) < 0) {
            actorCannotBuy(storeman);
            didgive = false;
          } else {
            setGold(gold - getBuyPrice(torchprice, markup));
            addInventory("torch", torchbutton, torchprice, objectid: "torch");
          }
        } else if (event.action == 'bucket') {
          if (gold - getBuyPrice(bucketprice, markup) < 0) {
            actorCannotBuy(storeman);
            didgive = false;
          } else {
            setGold(gold - getBuyPrice(bucketprice, markup));
            addInventory(
                "bucket", bucketbutton, bucketprice, objectid: "bucket");
          }
        } else if (event.action == 'broom') {
          if (gold - getBuyPrice(broomprice, markup) < 0) {
            actorCannotBuy(storeman);
            didgive = false;
          } else {
            setGold(gold - getBuyPrice(broomprice, markup));
            addInventory("broom", broombutton, broomprice, objectid: "broom");
          }
        } else if (event.action == 'torchsell') {
          removeInventory("torch");
          setGold(gold + getSellPrice(torchprice, markdown));

        } else if (event.action == 'bucketsell') {
          removeInventory("bucket");
          setGold(gold + getSellPrice(bucketprice, markdown));

        } else if (event.action == 'broomsell') {
          removeInventory("broom");
          setGold(gold + getSellPrice(broomprice, markdown));

        }
        if (didgive)
          giveAnimation(storeman);
      }


    });

    // This the Lindos home room for knigths in lindos - has bunks
    var roomHomeroom= OPENWORLD.Room.createRoom(383.968,251.565,
        soundpath: "sounds/home.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();
    roomHomeroom.extra['guide'] = [
      "Sometimes Knights Hospitaller",
      "stay here",
      "This place can get messy"
    ];
    OPENWORLD.Room.setAutoIndoors(roomHomeroom, true);
    scene.add(roomHomeroom);

    OPENWORLD.Room.setDistanceTrigger(roomHomeroom, dist:1.5);

    // Put knights flag and coat of arms on wall
    var coatarms = await OPENWORLD.Plane.loadPlane(
        "assets/textures/coatarms.png", 0.18, 0.2, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(coatarms,385.27, 248.1,0.6,5);
    OPENWORLD.Space.objTurn(coatarms,90+180);
    scene.add(coatarms);

   var banner=await OPENWORLD.Model.createModel('assets/models/banner.glb');
    banner.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        banner,386.1, 248.2,0.6,5);
    OPENWORLD.Space.setTurnPitchRoll(banner, 90,90,0);//turn, pitch, roll)Space.objPitch(banner,90);
    scene.add(banner);

    // Knight is looking at a picture of a lady
    var knight15 =await OPENWORLD.Actor.copyActor( guard,
        texture: "assets/actors/knight15.jpg",
        action:"sittablewrite"
    );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        knight15,383.5,251.81, 0, 4);
    OPENWORLD.Space.objTurn(knight15,180);  //sw
    scene.add(knight15);

    // Have knigth wield picture of lady
    var ladycard = await OPENWORLD.Plane.loadPlane(
        "assets/textures/lady.jpg", 120*0.05,120*0.15, ambient: false);
    OPENWORLD.Space.objPitch(ladycard.children[0],90);
    ladycard.children[0].position.set(0.0,0.0,-10.0);
    OPENWORLD.Actor.wield(knight15, ladycard, "Bip01_L_Finger11");
    OPENWORLD.BaseObject.setDistanceTrigger(knight15, dist: 1.3);
    // When knight sees you gets up and walks away and then sits back down when you leave
    var sitting=true;
    knight15.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      print("knight15 dist"+event.action.toString());
      if (event.action) {
        if (sitting) {
          sitting=false;
          OPENWORLD.BaseObject.clearAll(knight15);
          OPENWORLD.Actor.playActionThen(
              knight15, "sittable", "idle2", backwards: true,
              delay: 5-3);
          OPENWORLD.Mob.moveTo(knight15, [ [ 383.76, 252.02]] , action:"walk", stopaction:"idle", delay:7-3);
          OPENWORLD.Space.faceObjectAlways(knight15, camera, delay: 9-3);
        }

      } else {
        if (!sitting) {
          sitting=true;
          OPENWORLD.BaseObject.clearAll(knight15);
          OPENWORLD.Space.faceObjectAlwaysRemove(knight15);
          OPENWORLD.Mob.moveTo(knight15, [ [ 383.5,251.81]] , action:"walk", stopaction:"idle");
          OPENWORLD.Space.objTurnLerp(knight15,180, 1,delay:4);  //sw

          OPENWORLD.Actor.playActionThen(
              knight15, "sittable", "sittableidle",
              delay: 5);

        }
      }

    });

    // This is house of the old lady who has an apple pie you can eat and a bucket you can take
    var roomHome= OPENWORLD.Room.createRoom(396.510,240.980,
        soundpath: "sounds/home.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();

    OPENWORLD.Room.setAutoIndoors(roomHome, true);
    scene.add(roomHome);

    OPENWORLD.Room.setDistanceTrigger(roomHome, dist:1.5);

    Group oldlady =
    await OPENWORLD.Actor.createActor('assets/actors/citizenf2.glb',
        z: actoroffset);
    setDefaultActor(oldlady);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        oldlady,397.66,241.29, 0, 4);
    OPENWORLD.Space.faceObjectAlways(oldlady, camera);
    scene.add(oldlady);
    addnpc(oldlady,"oldlady",false);
    OPENWORLD.BaseObject.setDistanceTrigger(oldlady, dist: 1.5);
    oldlady.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Mob.setSpeech(oldlady, ["I can't see very well.","Is someone there?","Try some of my pie"], z: 80, randwait:10, width: 300,  scale:0.4);
      } else {
        OPENWORLD.Actor.playActionThen(oldlady, "wave", "idle", backwards:true, duration:1, durationthen:2);

        OPENWORLD.Mob.setSpeech(oldlady, ["Nice meeting you.","Come back again won't you"], z: 80, width: 300,  scale:0.4);
      }

    });
    var applepie= await OPENWORLD.Model.createModel('assets/models/applepie.glb');
    applepie.scale.set(0.003, 0.003, 0.003);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(applepie,OPENWORLD.Room.getX(roomHome)+0.4, OPENWORLD.Room.getY(roomHome),0.2,4);
    scene.add(applepie);
    addMsgToObj(applepie, "Click eat");
    setGetObject(applepie, takelabel:"Eat");// {scalenotselected:1.025, scaleselected:1.05})
    //setEatObject(applepie,2);
    applepie.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      print("triggermenu applepie");
      setHealth(health*2+0.2);
      OPENWORLD.BaseObject.highlight(applepie, false);

      removeObject(applepie);
      OPENWORLD.Sound.play( path: "sounds/eat.mp3", volume: 0.2);
      OPENWORLD.Sound.play( path: "sounds/burp.wav", volume: 0.2, delay:3);
      OPENWORLD.Mob.setSpeech(oldlady, ["Did you like it?","How did it taste?"], z: 80, width: 300, delay:5, scale:0.4);
    });

    // Add bucket you can take
    var bucket2= bucket.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(bucket2,OPENWORLD.Room.getX(roomHome)+0.6, OPENWORLD.Room.getY(roomHome)+0.4,0.0,4);
    scene.add(bucket2);
    setGetObject(bucket2);// {scalenotselected:1.025, scaleselected:1.05})
    var bucketbutton2=dropButton("bucket",bucket2,icon:"icons/bucket.png");
    setPickupObject(bucket2, "bucket", bucketbutton2,objectid:"bucket");

    // Candle sitting on table
    var homelight= new THREE.PointLight(0xFFA500); //PointLight(0xffffff)
    homelight.intensity = 1.0; // 0.6;
    homelight.distance = 1.2;

    OPENWORLD.Light.addFlicker(homelight);
    OPENWORLD.Light.addNightOnly(homelight);
    scene.add(homelight);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(homelight,397.32, 240.97 ,0.2,4);//431.22, 276.84,2);
    var candle = await OPENWORLD.Sprite.loadSprite('assets/textures/candle.png', 0.015, 0.08,ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        candle,397.32, 240.97,0.2,4);//377.04, 280.52,0.05,4);//376.68, 281.48, 0.25, 4);
    scene.add(candle);

    // This is the home in Lindos with the doormat and key - has broom you can take
    var roomHome2= OPENWORLD.Room.createRoom(399.820,233.650,
        soundpath: "sounds/home.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();

    OPENWORLD.Room.setAutoIndoors(roomHome2, true);

    scene.add(roomHome2);

    OPENWORLD.Room.setDistanceTrigger(roomHome2, dist:0.5);
    Group leanne =
    await OPENWORLD.Actor.createActor('assets/actors/citizenf.glb',
        z: actoroffset);

    setDefaultActor(leanne);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        leanne,400.10,234.13, 0, 4);
   // OPENWORLD.Space.objTurn(leanne,270);  //w
    OPENWORLD.Space.faceObjectAlways(leanne, camera);
    scene.add(leanne);
    addcitizennpc(leanne,"leanne",true);

    OPENWORLD.BaseObject.setDistanceTrigger(leanne, dist: 1.5);
    leanne.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Mob.setSpeech(leanne, ["Hi gorgeous","Wanna have some fun?"], z: 80, width: 300,  scale:0.4);
      } else {
        OPENWORLD.Actor.playActionThen(leanne, "wave", "idle", backwards:true, duration:1, durationthen:2);

        OPENWORLD.Mob.setSpeech(leanne, ["Going somewhere?","Dont you like me anymore?"], z: 80, width: 300,  scale:0.4);
      }

    });

    var broom2= broom.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(broom2,400.35,234.00,0.0,4);
    setValue(broom2,"broom", broomprice);
    scene.add(broom2);
    setGetObject(broom2);// {scalenotselected:1.025, scaleselected:1.05})
    var broombutton2=dropButton("broom",broom2, icon:"icons/broom.png");
    setPickupObject(broom2, "broom", broombutton2, objectid:"broom");

    // This is the room in Lindos with Jeremy and Sandra having dinner
    var roomHome3= OPENWORLD.Room.createRoom(396.610,302.110,
        soundpath: "sounds/home.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();
    OPENWORLD.Room.setAutoIndoors(roomHome3, true);
    scene.add(roomHome3);

    var jeremy = await OPENWORLD.Actor.copyActor(citizen62,    action:"sittableidle");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        jeremy ,OPENWORLD.Room.getX(roomHome3)-0.05, OPENWORLD.Room.getY(roomHome3)-0.5, -0.05, 4);
    OPENWORLD.Space.objTurn(jeremy ,90);  //e

    scene.add(jeremy );
    addcitizennpc(jeremy,"jeremy",true);

    var sarah = await OPENWORLD.Actor.copyActor(leanne,
      action:"sittableidle",
      texture: "assets/actors/sarah.jpg",
      //   z: actoroffset
    );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sarah ,OPENWORLD.Room.getX(roomHome3)+0.75, OPENWORLD.Room.getY(roomHome3)-0.5, -0.05, 4);
    OPENWORLD.Space.objTurn(sarah ,270);  //w
    scene.add(sarah );
    addcitizennpc(sarah,"sarah",true);

    // Have banter between Jeremy and Sandra when you enter the room
    OPENWORLD.Room.setDistanceTrigger(roomHome3, dist:0.5);
    roomHome3.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        print("in home3");
        OPENWORLD.Mob.setSpeech(jeremy, [
          "That loaf looks delicious",
          "Can I try some?",
          "Ok, then can I try a slice?"
        ], randwait:0, minwait:4, z: 80, width: 300,  scale:0.4, delay:3);
        OPENWORLD.Mob.setSpeech(sarah, [
          "Thanks. Just out of the oven",
          "Lets just stare at it",
          "Ok, after we've stared at it for a while",
          "",
          "I hope they catch that spy. They say he's friends with that bandit in the north"
        ], randwait:0, minwait:4, z: 80, width: 300,  scale:0.4, delay:3+2);

      } else {
        print("out room3");

          OPENWORLD.BaseObject.clearAll(jeremy);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              jeremy, OPENWORLD.Room.getX(roomHome3) - 0.05,
              OPENWORLD.Room.getY(roomHome3) - 0.5, -0.05, 4);
          OPENWORLD.Space.objTurn(jeremy, 90); //e
          OPENWORLD.Actor.playAction(
              jeremy, name: "sittableidle", duration: 1, stopallactions: true);

      }
    });


    jeremyKickout(msg)
    {
      OPENWORLD.You.immobile=true;

      OPENWORLD.Space.faceObjectLerp(camera,jeremy,1);

      OPENWORLD.Actor.playActionThen(jeremy, "jump", "idle2", backwards:true, duration:1);
      OPENWORLD.Mob.moveTo(jeremy, [[ 396.50, 301.92]] , action:"walk", stopaction:"idle", delay:1.5);
      OPENWORLD.Mob.placeBeforeCamera(jeremy, 0.4,action:"walk",stopaction:"idle2",time:1, delay:2 );
      OPENWORLD.Actor.playActionThen(jeremy, "push", "idle2", backwards:true, duration:0.5, delay:3);
      OPENWORLD.Mob.setSpeech(jeremy, msg, randwait:0, minwait:4, z: 80, width: 300,  scale:0.4);
      OPENWORLD.Mob.moveTo(camera, [[396.37, 302.45,OPENWORLD.Camera.cameraoffset,0.6],[396.09, 303.26,OPENWORLD.Camera.cameraoffset,0.6]] , delay:4, surfaceonly:true);
      OPENWORLD.You.setImmobile(false,delay:6);
      OPENWORLD.Mob.moveTo(jeremy, [[ 396.50, 301.92]] , action:"walk", stopaction:"idle", delay:6);
      OPENWORLD.Space.faceObjectAlways(jeremy, camera,delay:7);;
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          jeremy ,OPENWORLD.Room.getX(roomHome3)-0.05, OPENWORLD.Room.getY(roomHome3)-0.5, -0.05, 4);
      OPENWORLD.Space.objTurn(jeremy ,90);  //e
    }
    var naughty=false;

    // If you try to take the bread jeremy kicks you out of his house
    // If you come in a second time he'll attack you
    var bread= await OPENWORLD.Model.createModel('assets/models/bread.glb');
    bread.scale.set(0.003, 0.003, 0.003);
    OPENWORLD.Space.worldToLocalSurfaceObj(bread,OPENWORLD.Room.getX(roomHome3)+0.3, OPENWORLD.Room.getY(roomHome3)-0.5,0.15);
    scene.add(bread);
    setGetObject(bread,scaleselected: 1.1, scalenotselected: 1.1);
    bread.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      print("trigger remove bread");
      if (naughty) {
        OPENWORLD.Mob.setSpeech(jeremy, ["I told you not to come back!","Now I'm going to thump you."], randwait:0, minwait:4, z: 80, width: 300,  scale:0.4, delay:3);
        actorAttack(jeremy);
      } else {
        jeremyKickout([
          "Hey! Why are you stealing our bread?",
          "Get out! If you come back in I'll thump you."
        ]);
        naughty = true;
      }
    });

    // Show candle on table
    var home3light= new THREE.PointLight(0xFFA500); //PointLight(0xffffff)
    home3light.intensity = 1.0; // 0.6;
    home3light.distance = 1.2;
    //churchlight.position.y = 0.33;
    OPENWORLD.Light.addFlicker(home3light);
    OPENWORLD.Light.addNightOnly(home3light);
    scene.add(home3light);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(home3light,397.15, 301.60 ,0.15,4);//431.22, 276.84,2);
    var candle3 = await OPENWORLD.Sprite.cloneSprite(candle);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        candle3,397.15, 301.60,0.15,4);//377.04, 280.52,0.05,4);//376.68, 281.48, 0.25, 4);
    scene.add(candle3);

    // If you go past the bed Jeremy kicks you out
    var woodbed= await OPENWORLD.Model.createModel('assets/models/bed.glb', texture:"assets/textures/wood.jpg",);
    woodbed.scale.set(0.0017, 0.0017, 0.0017);
    OPENWORLD.Space.worldToLocalSurfaceObj(woodbed,398,302.1,0);
    OPENWORLD.Space.objTurn(woodbed ,-103);
    scene.add(woodbed);
    OPENWORLD.BaseObject.setDistanceTrigger(woodbed, dist: 0.5);
    woodbed.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
       // print("woodbed in");
        jeremyKickout(["Hey. Where do you think you're going?"]);

      } else {
      //  print("woodbed out");
      }
    });


    // Trading post room where you can buy and sell anything of value but at a higher markup
    var roomTradingpost= OPENWORLD.Room.createRoom(384.037,286.318,
        soundpath: "sounds/shop.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomTradingpost.extra['guide'] = [
      "This general store",
      "will buy and sell",
      "anything of value.",
      "The markup is quite",
      "steep though!"
    ];
    OPENWORLD.Room.setAutoIndoors(roomTradingpost, true);

    scene.add(roomTradingpost);
    OPENWORLD.Room.setDistanceTrigger(roomTradingpost,minx:381.9, maxx:386.1, miny:283.5, maxy:287.5);// dist:0.5);
    // minx: -3.47, maxx: 10.1, miny: -12.4, maxy: -2.1);

    var storeman2 =
    await OPENWORLD.Actor.copyActor(storeman,

    );

    //setDefaultActor(leanne);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        storeman2 ,384.69,284.81, 0, 4);
    OPENWORLD.Space.objTurn(storeman2 ,270+45);  //nw

    scene.add(storeman2 );
    addcitizennpc(storeman2,"storeman2",false);

    OPENWORLD.BaseObject.setDistanceTrigger(storeman2, dist: 1.5);
    storeman2.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        print("storeman in");
        chatter = ["We buy & sell anything of value",
          "This parrot isnt dead. Its resting",
          "Ill sell this Norwegian Blue for a song",
          "The Norwegian Blue parrot is stunned I tell you",
        ];
        OPENWORLD.Mob.setChatter(
            storeman2, chatter, z: 80, width: 300, scale: 0.4);
      }
    });
    // If click on clothes on bench can buy and sell your items
    // Only lists items if they have been bought and sold
    var clothes= await OPENWORLD.Model.createModel('assets/models/clothes.glb');
    clothes.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObj(clothes,384.14, 285.03,0.24);
    scene.add(clothes);
    addMsgToObj(clothes, "Click to trade");

    OPENWORLD.BaseObject.setHighlight(clothes, scene, THREE.Color(0x0000ff),  1.0,scale:1.15);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(clothes, true,scale:1.15, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(clothes);
    markup=1.3;
    markdown=0.7;

    var buyitems=[];

    clothes.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      //  print("touched");
      OPENWORLD.BaseObject.highlight( clothes, true, scale:1.1, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        if (buyitems.length==0&&inventoryvalues.length==0)
          menuitems.add({"text":"There is currently nothing to buy or sell"});
        else { // Means you buy
          if ( buyitems.length>0) {
            menuitems.add({"text": "Buy"}); // Means you buy
            for (var item in buyitems) {
              // buyitems.add([inventorynames[i],inventoryvalues[i], inventory]);
              menuitems.add({
                "text": item[0] + ": " +
                    displayMoney(getBuyPrice(item[1], markup)),
                "command": item[0]
              });
            }
          }

          if (inventoryvalues.length>0) {
            menuitems.add({"text": "Sell"}); // Means you sell
            for (var i = 0; i < inventoryvalues.length; i++) {
              if (inventoryvalues[i] > 0) {
                menuitems.add({
                  "text": inventorynames[i] + ": " +
                      displayMoney(getSellPrice(inventoryvalues[i], markdown)),
                  "command": inventorynames[i] + "sell"
                });
              }
            }
          }
        }

        menuobj=clothes;
      });
    });

    // This is where you click on the menu
    clothes.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) async {
      print("triggermenu board"+event.action);

      var hasgiven=false;
      // If click on buy an item
      for (var item in buyitems) {
        if (event.action==item[0]) {

          if (gold-getBuyPrice(item[1], markup)>=0) {
            setGold(gold - getBuyPrice(item[1], markup));

            addInventory(item[0], item[2], item[1]);
            buyitems.remove(item);
            hasgiven=true;
            break;
          }
        }
      }
      // If click on sell an item
      for (var i=0; i<inventorynames.length; i++) {
        if (event.action==inventorynames[i]+"sell") {
          setGold(gold+getSellPrice(inventoryvalues[i], markdown));

          buyitems.add([inventorynames[i],inventoryvalues[i], inventory[i]]);
          removeInventory(inventorynames[i]);
          hasgiven=true;
          break;
        }
      }
      if (hasgiven)
        giveAnimation(storeman2);
      else
        OPENWORLD.Mob.setSpeech(storeman2, ["You dont have enough for that"], randwait:0, minwait:4, z: 80, width: 300,  scale:0.4);

    });

    // Put a norwegian blue on the trading post bench
    var deadparrot = await OPENWORLD.Sprite.loadSprite(
        'assets/textures/deadparrot.png', 0.09, 0.16,
        ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        deadparrot,384.65, 285.39,0.23,4);//377.04, 280.52,0.05,4);//376.68, 281.48, 0.25, 4);
    scene.add(deadparrot);

    // The lindos newsroom where the start of the quest takes place
    // Once you visit the journalist will then head off to the beach to spy on the cannon
    roomNewsroom= OPENWORLD.Room.createRoom(378.260,281.060,
        soundpath: "sounds/writing.mp3", volume: 0.1, exitroom: roomDefault); //THREE.Object3D();
    OPENWORLD.Room.setAutoIndoors(roomNewsroom, true);
    roomNewsroom.extra['guide'] = [
      "This is where",
      "news of Lindos",
      "is published.",
      "Simon is always around",
      "getting information about",
      "everything and everyone"
    ];
    scene.add(roomNewsroom);

    // Put sign on building
    plane =   await OPENWORLD.Plane.makeTextPlane("Lindos News", Colors.black, backgroundopacity: 0);//scale:0.01);//THREE.Color(0xff0000));
    var newsroomsign=THREE.Group();
    newsroomsign.add( plane );
  //  plane.position.y+=0.3;
   // plane.position.x=-0.05;
    plane.scale.set(0.5,0.5,0.5);//.x=0.1;
    newsroomsign.add(plane);
    OPENWORLD.Space.objTurn(newsroomsign,270-180-90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(newsroomsign, 379.23, 280.95,1.3,4);
    scene.add(newsroomsign);

    // Show hint that Simon is the traitor with info on cannon etc
    var newsroommessage = await OPENWORLD.Plane.loadPlane(
        "assets/textures/newsroommessage.jpg", 0.15,0.15, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObj(
        newsroommessage,378.89,281.27,0.2);//377.04, 280.52,0.05,4);//376.68, 281.48, 0.25, 4);
    OPENWORLD.Space.setTurnPitchRoll(newsroommessage, 45, 90, 0);
    scene.add(newsroommessage);
    newsroommessage.visible=false;



    var lastentrytick=-1;
    OPENWORLD.Room.setDistanceTrigger(roomNewsroom, dist:1.0);

    roomNewsroom.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      print("journalist2beachseen"+journalist2beachseen.toString()+"journalist2newsroomseen"+journalist2newsroomseen.toString());
      if (event.action) {
        // Dont always show the news room hint message
        newsroommessage.visible=OPENWORLD.Math.random()<0.15;
        print("in newsroom"+(OPENWORLD.System.currentMilliseconds()-lastentrytick).toString()+" indoors"+OPENWORLD.You.indoors().toString());
        lastentrytick=OPENWORLD.System.currentMilliseconds();
      } else {
        print("out newsroom"+OPENWORLD.You.indoors().toString());
      }
    });
    var quill = await OPENWORLD.Sprite.loadSprite(
        'assets/textures/quill.png', 0.02, 0.1,
        ambient: false);
    quill.scale.set(140.0,140.0,140.0);
    ///   quill.children[0].position.set(0.0,0.015,-0.035);
    quill.children[0].position.set(0.0,0.0,0.03);

    var journalist =
    await OPENWORLD.Actor.copyActor( citizen5,
        texture: "assets/actors/citizen52.jpg",
        action:"sittablewrite",
       duration:1.5,
       randomduration: 0.2
      //   z: actoroffset
    );
    //setDefaltActor(leanne);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        journalist ,378.33,280.66,-0.022, 4);
    OPENWORLD.Space.objTurn(journalist, 0);  //n
    scene.add(journalist );
    addcitizennpc(journalist,"journalist",false);

    // Banter between the two journalists
    OPENWORLD.BaseObject.setDistanceTrigger(journalist, dist: 1);
    journalist.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        if ( !journalist2beachseen&&!journalist2newsroomseen) {
          chatter = ["Your always at Pallas Beach arent you",
            "Simon, you love writing about the cannon dont you",
            ".. just sign it with your initials S. D.",
            "Youre not off to again are you, where do you go?"
          ];
          OPENWORLD.Mob.setChatter(
              journalist, chatter, z: 80, width: 300, scale: 0.4);

        } else {
          OPENWORLD.BaseObject.clearAll(journalist);
          chatter = ["Where does Simon go?",
            "We've got a deadline",
            "Hes always at Pallum beach",
            "Looking at the birds I suspect"
          ];
          OPENWORLD.Mob.setSpeech(journalist, chatter, randwait:0, minwait:4, z: 80, width: 300,  scale:0.4, delay:2);

        }

      }
    });
    // This is the traitor who gives secrets to the bandit
    journalist2 = await OPENWORLD.Actor.copyActor( citizen5,
        texture: "assets/actors/citizen53.jpg",
        action:"sittablewrite",
                randomduration: 0.2,
    );
    OPENWORLD.Mob.setName(journalist2,"journalist2");

    // Journalist holds a quill and board to write stuff down on
    OPENWORLD.Actor.wield(journalist, quill, "Bip01_R_Finger11");//Bip01_R_Hand");

    journalist2board=board.clone();//await OPENWORLD.Model.createModel('assets/models/board.glb');
    journalist2board.scale.set(0.3,0.3,0.3);
    journalist2board.position.set(0.0,0.0,0.0);
    OPENWORLD.Actor.wield(journalist2,journalist2board, "Bip01_L_Finger11");
    journalist2board.visible=false;

    // Hint that traitor wears a red hat
    var hat =await OPENWORLD.Model.createModel('assets/models/hat.glb');
    hat.scale.set(0.3,0.3,0.3);
    hat.position.set(5.5,0.0,0.0);
    OPENWORLD.Space.setTurnPitchRoll(hat, 0, -90,0);
    OPENWORLD.Actor.wield(journalist2,hat, "Bip01_Head");

    // Send the jouranlist to the beach to spy on the cannon
    journalist2atbeach()
    {
      print("journalist to beach func");
      journalist2board.visible = true;
      //469.02, 347.40
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          journalist2, 468.37, 349.54, 0, 6);
      OPENWORLD.Actor.playAction(
          journalist2, name: "idle2");
      OPENWORLD.BaseObject.setDistanceTrigger(journalist2, dist: 6);
      journalist2.extra['trigger'].addEventListener(
          'trigger', (THREE.Event event) {
        if (event.action) {
          chatter=["I better head back to the newsroom",
            "Interesting.."
          ];
          OPENWORLD.Mob.setChatter(journalist2, chatter,  z: 80, width: 300, scale:0.4);

          OPENWORLD.Mob.resetrandomwalk(journalist2);
          OPENWORLD.Mob.randomwalk(journalist2, 1.5, 0.2, 0.1,
              action: "walk",
              // actionduration: 0.5,
              stopaction: "idle",
              reset: true
          );
        }
      });

    }

    // Send the jouranlist to the bandit to give away the secrets
    journalist2tobandit()
    {
      print("journalist to bandit");
      if (loadedbandit) {
        print("journalist to bandit has loaded");
        journalist2board.visible = true;
        //469.02, 347.40
        var banditpos = OPENWORLD.Space.localToWorldObj(bandit);

        OPENWORLD.Mob.clearText(journalist2);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            journalist2, banditpos.x, banditpos.y + 1, 0,
            6); //305.32, 428.21, 0, 6);

        OPENWORLD.BaseObject.setDistanceTrigger(journalist2, dist: 8);
        OPENWORLD.Actor.playAction(
            journalist2, name: "idle2"); //, loopmode:THREE.LoopRepeat );
        journalist2.extra['trigger'].addEventListener(
            'trigger', (THREE.Event event) {
          if (event.action) {
            OPENWORLD.Mob.resetrandomwalk(journalist2);
            OPENWORLD.Mob.randomwalk(journalist2, 1.5, 0.2, 0.1,
                action: "walk",
                // actionduration: 0.5,
                stopaction: "idle",
                reset: true
            );
          }
        });
      } else {
        print("bandit try again");
        Future.delayed(const Duration(milliseconds: 1 * 1000), () {
          journalist2tobandit();
        });
      }
    }

    // Jouranlist sits back down
    journalist2Sit() {
      OPENWORLD.Space.worldToLocalSurfaceObj(
          journalist2, 378.16, 281.39, -0.022, delay: 1);
      OPENWORLD.Space.objTurnLerp(journalist2, 180, 1, delay: 1);
      OPENWORLD.Actor.playActionThen(
          journalist2, "sittable", "sittablewrite", duration: 0.5, delay: 1);
    }

    // So if restart game dont have to redo the entire quest - save persistent
    // journalist2 will be put in correct place
    if (!journalist2newsroomseen &&! journalist2beachseen) {
      print("put jounalist2 in newsroom");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          journalist2, 378.16, 281.39, -0.022, 4); //378.13,281.45, 0, 4);
      OPENWORLD.BaseObject.setDistanceTrigger(journalist2, dist: 1.0);
    } else if (journalist2newsroomseen &&! journalist2beachseen) {
      print("put jounalist2 at beach");
      journalist2atbeach();
      OPENWORLD.BaseObject.setDistanceTrigger(journalist2, dist: 3.0);
    } else if (journalist2beachseen) {
      print("put jounalist2 at bandit");
      // Delayed because bandit not created yet
      Future.delayed(const Duration(milliseconds: 1 * 1000), () {
        journalist2tobandit();
      });
      OPENWORLD.BaseObject.setDistanceTrigger(journalist2, dist: 3.0);
    } else {
      print("put jounalist2 no where");
    }

    // Can kill jouranlist2 traitor but has custom strike
    addnpc(journalist2,"Simon",false,deathsoundpath: "sounds/die.mp3");

    OPENWORLD.Space.objTurn(journalist2, 180);  //s
    scene.add(journalist2 );


    var quill2=await OPENWORLD.Sprite.cloneSprite(quill);
    quill2.scale.set(140.0,140.0,140.0);
    ///   quill.children[0].position.set(0.0,0.015,-0.035);
    quill2.children[0].position.set(0.0,0.0,0.03);

    OPENWORLD.Actor.wield(journalist2, quill2, "Bip01_R_Finger11");//Bip01_R_Hand");

    journalist2.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        print("in journalist2");
        if (!journalist2newsroomseen) {
          if (!journalist2inwait) {
            chatter=["Sure",
              "Okay",
              "What about it?"
            ];
            OPENWORLD.Mob.setChatter(journalist2, chatter,  z: 80, width: 300, scale:0.4);

            print("seen journalist2 in newsroom");
            // Means first time in newsroom
            // In one minute linger around beach
            journalist2inwait = true;
            OPENWORLD.Persistence.set("journalist2inwait",journalist2inwait);

            // Once you have seen the journalist traitor wait till you go away for 1 minute and then will send jouranlist to the beach to look at the cannon
            goBeachLoop() {
              print("go beach");
              Future.delayed(const Duration(milliseconds: 60 * 1000), () {
                var dist = OPENWORLD.Space.getDistanceBetweenObjs(
                    camera, journalist2);
                if (dist > 2) {
                  print("now to beach");

                  // Now at beach then trigger is further away
                  OPENWORLD.BaseObject.setDistanceTrigger(journalist2, dist: 5.0);
                  journalist2inwait = false;
                  OPENWORLD.Persistence.set(
                      "journalist2inwait", journalist2inwait);
                  journalist2newsroomseen = true;
                  OPENWORLD.Persistence.set(
                      "journalist2newsroomseen", journalist2newsroomseen);
                  OPENWORLD.BaseObject.clearTimers(journalist2);
                  OPENWORLD.Mob.clearText(journalist2);
                  OPENWORLD.Mob.pauseChatter(journalist2);


                  journalist2atbeach();

                } else {
                  print("go beach try again");
                  goBeachLoop();
                }
              });
            }
            goBeachLoop();
          }

        } else if (! journalist2beachseen) {
          if (!journalist2inwait) {
            // Journalist is at the beach and you have seen the journalist hanging around there then again wait till player goes away for 60 seconds and then goes to bandit to give info
            // Means first time seen journalist at beach
            // so send to bandit
            print("seen journalist2 at beach");
            journalist2inwait = true;
            var t=Timer.periodic(Duration(seconds: 60), (timer) async {
              var dist = OPENWORLD.Space.getDistanceBetweenObjs(
                  camera, journalist2);
              print("check away from beach"+dist.toString());
              if (dist>10) {
                timer.cancel();
                print("now to bandit");
                journalist2inwait = false;
                // Now at beach then trigger is further away
                OPENWORLD.BaseObject.setDistanceTrigger(journalist2, dist: 5.0);

                journalist2beachseen = true;
                OPENWORLD.Persistence.set(
                    "journalist2beachseen", journalist2beachseen);
                OPENWORLD.BaseObject.clearTimers(journalist2);

                OPENWORLD.Mob.clearText(journalist2);
                OPENWORLD.Mob.pauseChatter(journalist2);

                journalist2tobandit();

              }
            });
          }
        } else if (journalist2beachseen) {
          print("journalist2 do nothing");
        }
      }
    });

    // Custom strike of journalist traitor. Only allow killing when is at the bandits giving away secrets
    OPENWORLD.BaseObject.setCustomTrigger(journalist2);//, dist: 1.5);
    journalist2.extra['customtrigger'].addEventListener('strucktrigger', (THREE.Event event) {
      print("journalist struck trigger");
      if (!actorIsDead(journalist2)) {
        var dist=OPENWORLD.Space.getDistanceBetweenObjs(journalist2, bandit);
        if (dist<10) {
          //if (!actorIsAttacking(journalist2))
          actorAttack(journalist2);
          print("journalist struck trigger in");
          var damage = getYouDamage();
          setActorHealth(journalist2, getActorHealth(journalist2) - damage);
          //  OPENWORLD.Space.faceObjectLerp(npc,camera,1);
          if (getActorHealth(journalist2) <= 0) {
            print("jouranlist dead");
            OPENWORLD.BaseObject.clearAll(journalist2);
            actorDie(journalist2); //,diesoundpath:"sounds/die.mp3");
            OPENWORLD.BaseObject.disableDistanceTrigger(journalist2);
            if (actorIsDead(bandit))
              foundTraitor();
          }
        } else {
          OPENWORLD.Mob.setSpeech(journalist2, ["Stop hitting me!", "I have a dead line", "Go away!"], randwait:0, minwait:4, z: 80, width: 300,  scale:0.4, delay:2);
          if (!journalist2newsroomseen)
             OPENWORLD.Mob.moveTo(camera, [[ 379.80, 280.87, OPENWORLD.Camera.cameraoffset,1.0]], delay:1);
          else {

            OPENWORLD.Space.faceObjectLerp( journalist2, camera, 0.5);
            OPENWORLD.Actor.playActionThen(journalist2, "push", "idle2", backwards:true, duration:0.5);
            OPENWORLD.Space.objForwardLerp(camera, -1.0,1, z:OPENWORLD.Camera.cameraoffset, delay:0.5);
          }

        }
      }
    });

    // Newspaper where you can read the latest news about lindos
    var newspaper=await OPENWORLD.Model.createModel('assets/models/newspapers.glb');
    newspaper.scale.set(0.005*1.2, 0.0005, 0.005);
    OPENWORLD.Space.objTurn(newspaper,45);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        newspaper,378.44,281.04,0.2,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    scene.add(newspaper);
    var newspapersprite =   await OPENWORLD.Sprite.makeTextSprite("Click to read", fontSize:20, Colors.blue, bold:true, backgroundopacity: 0, width:300);//,scale:0.01);//THREE.Color(0xff0000));
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        newspapersprite,378.44,281.04,0.25,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    newspapersprite.scale.set(0.1,0.03,1.0);
    scene.add(newspapersprite);

    OPENWORLD.BaseObject.setHighlight(newspaper, scene, THREE.Color(0x0000ff), 1.0, scale:1.1);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(newspaper, true,scale:1.1, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(newspaper);
    newspaper.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(newspaper, true, scale:1.1, opacity:1);
      var clickevent=event.action;
      setState(() {

        menuposx=width/3;//clickevent.clientX;
        menuposy=40;//clickevent.clientY-40;

        menuitems.clear();
        menuitems.add({"text":"LINDOS NEWS"});
        menuitems.add({"text":"In news from the Ottaman empire Suleiman is said to be amassing "});
        menuitems.add({"text":"a force to invade.  It is said he is gathering as much intelligence"});
        menuitems.add({"text":"about Rhodes from spies as possible. The Knight Commander has asked"});
        menuitems.add({"text":"residents to keep an ear and eye out for such spies and traitors."});

        menuobj=newspaper;
      });
    });


    // Backroom of newsroom where if you try to go in while the journalist traitor is around will kick you out because has notes about treachery
    var roomNewsroomBack= OPENWORLD.Room.createRoom( 376.17, 281.29,
        soundpath: "sounds/home.mp3", volume: 0.05); //THREE.Object3D();
    OPENWORLD.Room.setAutoIndoors(roomNewsroomBack, true);
    scene.add(roomNewsroomBack);
    OPENWORLD.Room.setDistanceTrigger(roomNewsroomBack, dist:1.3);

    roomNewsroomBack.extra['trigger'].addEventListener('trigger', (THREE.Event event) {

      if (event.action) {
        print("in newsroomback");

        if (!(OPENWORLD.You.immobile||journalist2newsroomseen)) {
          OPENWORLD.You.immobile = true;
          //  OPENWORLD.Actor.unwieldAll(journalist2);//Bip01_R_Hand");
          OPENWORLD.Space.faceObjectLerp(camera, journalist2, 1);
          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
              camera, 377.67, 281.64, OPENWORLD.Camera.cameraoffset, 1);
          OPENWORLD.Actor.playActionThen(
              journalist2, "sittable", "idle2", backwards: true, duration: 0.5);
          OPENWORLD.Space.faceObjectLerp(journalist2, camera, 1, delay: 1);
          OPENWORLD.Mob.placeBeforeCamera(journalist2, 0.4, action: "walk",
              stopaction: "idle2",
              time: 1,
              delay: 1);
          OPENWORLD.Mob.setSpeech(journalist2,
              ["Hey, where are you going", "Youre not allowed in there"],
              randwait: 0,
              minwait: 4,
              z: 80,
              width: 300,
              scale: 0.4,
              delay: 2);
          Future.delayed(const Duration(milliseconds: 12000), () {
            print("journalist2 sit down");

            OPENWORLD.Mob.clearText(journalist2);
            OPENWORLD.You.immobile = false;

            OPENWORLD.Mob.moveTo(
                journalist2, [ [378.16, 281.39, -0.022, 0.5]], action: "walk",
                stopaction: "idle");
            journalist2Sit();


          });
          // print("newsroomin");
        }
      } else {
        print("newsroomout");

      }
    });

    // Message with info on cannon etc in the backroom
    var newsroommessage2 = newsroommessage.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        newsroommessage2,375.33, 280.57,0.03,4);//377.04, 280.52,0.05,4);//376.68, 281.48, 0.25, 4);
    OPENWORLD.Space.setTurnPitchRoll(newsroommessage2, 45, 90, 0);
    scene.add(newsroommessage2);

    // Post office room to the east of lindos
    // Just one message from grandmaster - cannot actually send mail
    var roomPostoffice= OPENWORLD.Room.createRoom(365.770,273.560,
        soundpath: "sounds/shop.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomPostoffice.extra['guide'] = [
      "The post office",
      "is where Lindos residents",
      "post and get mail",
    ];
    OPENWORLD.Room.setAutoIndoors(roomPostoffice, true);

    scene.add(roomPostoffice);

    OPENWORLD.Room.setDistanceTrigger(roomPostoffice, dist:0.5);
    Group postie =
    await OPENWORLD.Actor.createActor('assets/actors/shopkeeper.glb',//citizen6.glb',
        shareanimations: armourer,
        action:"idle2",
        z: actoroffset);

    setDefaultActor(postie);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        postie,OPENWORLD.Room.getX(roomPostoffice)+0.9, OPENWORLD.Room.getY(roomPostoffice)-0.2, 0, 4);
    OPENWORLD.Space.objTurn(postie,270);  //w
    scene.add(postie);
    addcitizennpc(postie,"postie",false);
    chatter=["I know this bench is a bit high.",
      "But the builders went a bit over board.",
     "And now Im stuck with it",
    "Anyway what can I do for you?"];
    OPENWORLD.Mob.setSpeech(postie, chatter,  z: 80, width: 300, scale:0.4);

    // Click bag to show message from grandmaster
    var bag=await OPENWORLD.Model.createModel('assets/models/bag.glb');
    bag.scale.set(0.015, 0.015, 0.015);
    OPENWORLD.Space.objTurn(bag,20);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(bag,366.19,272.90,-0.02,4);
    scene.add(bag);
    addMsgToObj(bag, "Click to check mail", scale:0.1, z:11);

    OPENWORLD.BaseObject.setHighlight(bag, scene, THREE.Color(0x0000ff), 1.0, scale:1.08);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(bag, true,scale:1.08, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(bag);
    bag.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(bag, true, scale:1.1, opacity:1);
      var clickevent=event.action;
      giveAnimation(postie);
      setState(() {
        menuposx=width/3;//clickevent.clientX;
        menuposy=40;//clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"You have a message."});
        menuitems.add({"text":"It reads:"});
        menuitems.add({"text":"Hello friend."});
        menuitems.add({"text":"We are most pleased with your arrival at Lindos."});
        menuitems.add({"text":"We are hopeful that you can find the spies and traitors"});
        menuitems.add({"text":"who are helping our enemies invade."});
        menuitems.add({"text":" "});
        menuitems.add({"text":"Yours Philippe Villiers de L'Isle-Adam"});
        menuitems.add({"text":"Grandmaster of Knights Hospitalier"});

        menuobj=bag;
      });
    });


    // Real estate office in Lindos but actually cant buy property yet
    var roomRealEstate = OPENWORLD.Room.createRoom(407.110,308,
        soundpath: "sounds/shop.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomRealEstate.extra['guide'] = [
      "Here Lindos residents",
      "buy and sell",
      'property'
    ];
    OPENWORLD.Room.setAutoIndoors(roomRealEstate, true);

    scene.add(roomRealEstate);

    OPENWORLD.Room.setDistanceTrigger(roomRealEstate, dist:1.0);

    Group realestatelady =
    await OPENWORLD.Actor.createActor('assets/actors/citizenf4.glb',
        z: actoroffset);

    setDefaultActor(realestatelady);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        realestatelady,407.01,308.59, 0, 4);
    OPENWORLD.Space.objTurn(realestatelady,180);
    scene.add(realestatelady);
    addcitizennpc(realestatelady,"realestatelady",false);

    OPENWORLD.BaseObject.setDistanceTrigger(realestatelady, dist: 1);
    realestatelady.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        print("real estate lady in");
        chatter = [
          "Our Main St cottage is a renovators dream",
          "Krane Ln cottage is airy & lets you feel the elements",
          "Want something cosy & low maintainence? Check out our Philips St cabin"
        ];
        OPENWORLD.Mob.setChatter(realestatelady, chatter, z: 80,
            randwait: 15,
            width: 300,
            scale: 0.4);
      } else {
        print("real estate lady out");
      }
    });

    // If click on real estate guide cannot buy anything
    var guide=await OPENWORLD.Model.createModel('assets/models/guide.glb');
    guide.scale.set(0.015,0.015,0.015);
    OPENWORLD.Space.objTurn(guide,75);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(guide, 406.71, 308.19,0.23,4);
    scene.add(guide);
    OPENWORLD.BaseObject.setHighlight(guide, scene, THREE.Color(0x0000ff), 1.0, scale:1.03);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(guide, true,scale:1.03, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(guide);
    guide.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(guide, true, scale:1.1, opacity:1);
      var clickevent=event.action;

      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Real Estate For Sale"});
        menuitems.add({"text":"Lindos Gaming House: 1000", "command":"buy"});
        menuitems.add({"text":"Tasty Restaurant: 1000", "command":"buy"});

        menuobj=guide;
      });
    });

    // This is where you click on the menu
    guide.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) async {
      print("triggermenu board"+event.action);
      OPENWORLD.Mob.setSpeech(realestatelady, ["Sorry, purchase of property only for Lindos citizens"], z: 80, width: 300,  scale:0.4);

    });

    // Show pictures at back of real estate office
    var realestatesign = await OPENWORLD.Plane.loadPlane(
    "assets/textures/realestate.jpg", 0.25, 0.25, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        realestatesign, 406.96, 309.63,0.47, 4);
    OPENWORLD.Space.objTurn(realestatesign,80);
    scene.add(realestatesign);

    var realestatesign4 = await OPENWORLD.Plane.loadPlane(
        "assets/textures/realestate4.jpg", 0.25, 0.2, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        realestatesign4, 406.56, 309.63,0.47, 4);
    OPENWORLD.Space.objTurn(realestatesign4,80);
    scene.add(realestatesign4);

    var realestatesign5 = await OPENWORLD.Plane.loadPlane(
        "assets/textures/realestate5.jpg", 0.25, 0.15, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        realestatesign5, 406.16, 309.53,0.47, 4);
    OPENWORLD.Space.objTurn(realestatesign5,80);
    scene.add(realestatesign5);

    var clocki = await OPENWORLD.Plane.loadPlane(
        "assets/textures/clock.png", 0.1, 0.4, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clocki,405.74, 309.23 ,0.5,4);//407.8,307.76 ,0.5, 4);
    OPENWORLD.Space.objTurn(clocki,85);
    scene.add(clocki);

    // This is the road in lindos with the dog
    var roomRoad = OPENWORLD.Room.createRoom(372.200,269.800,
        soundpath: "sounds/courtyard.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    scene.add(roomRoad);

    OPENWORLD.Room.setDistanceTrigger(roomRoad, dist:0.5);

    // If you get near the dog it will either bark, urinate or sit down
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        dog,371.99, 270.54, 0, 4,lerpopacity: 1);
    OPENWORLD.Space.objTurn(dog.children[0],0);
    OPENWORLD.Space.objTurn(dog,OPENWORLD.Math.random()*360);
    scene.add(dog);
    addnpc(dog, "dog", true,deathsoundpath: "sounds/yelp.mp3");

    OPENWORLD.BaseObject.setDistanceTrigger(dog, dist: 1.5);
    dog.extra['trigger'].addEventListener('trigger', (THREE.Event event) {

      if (event.action&&!actorIsDead(dog)) {
        OPENWORLD.Sound.play( path: 'sounds/bark.mp3', volume: 0.1, delay:OPENWORLD.Math.random()*5);
        OPENWORLD.Space.faceObjectLerp(dog, camera, 0.3);
        var rnd=OPENWORLD.Math.random();
        if (rnd<0.3) {
          var urinate = OPENWORLD.Math.random() * 30;
          OPENWORLD.Actor.playActionThen(
              dog, "urinate", "idle", delay: urinate);
        } else if (rnd<0.66) {
          var urinate = OPENWORLD.Math.random() * 30;
          OPENWORLD.Actor.playActionThen(dog, "sit", "sitidle", duration: 0.5,
              durationthen: 2,
              delay: urinate);
        } else {
          OPENWORLD.Mob.randomwalk(dog, 0.5, 0.15, 0.1,
              action: "walk",
              actionduration: 0.7,
              stopaction: "idle",
              reset: true
          );
        }
      } else {
        OPENWORLD.BaseObject.clearAll(dog);
        OPENWORLD.Actor.playActionThen(dog, "sit", "idle",  backwards:true, duration:0.5, durationthen:2, delay:1);
      }
    });

    // This is the room with the kid
    var roomChild = OPENWORLD.Room.createRoom(365.660,231.750,
        soundpath: "sounds/courtyard.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();

    scene.add(roomChild);
    OPENWORLD.Room.setDistanceTrigger(roomChild, dist:0.5);

    var child=await OPENWORLD.Actor.createActor('assets/actors/child.glb',
        z: actoroffset);
    setDefaultActor(child);
    child.scale.set(0.006*3/5, 0.006*3/5, 0.006*3/5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(child,365.33,232.03,0,4,lerpopacity: 1);
    scene.add(child);
    OPENWORLD.BaseObject.setDistanceTrigger(child, dist: 0.8);
    var jumpsound;
    // If you go near the child he will either star doing star jump, jump in the air or fart
    child.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        print("child in");
        OPENWORLD.BaseObject.clearAll(child);
        OPENWORLD.Space.faceObjectAlways(child, camera, delay:5);

        jumpsound=OPENWORLD.Sound.getAudioPlayer();
        var t=Timer.periodic(Duration(seconds: 15), (timer) async {
            var rnd=OPENWORLD.Math.random();
            if (rnd<0.3) {
              var starjumptime =  OPENWORLD.Math.random() * 10;
              OPENWORLD.Actor.playAction(
                  child, name: "starjump", duration: 0.7, delay: starjumptime);
              OPENWORLD.Sound.play( sound:jumpsound, path: "sounds/starjump.mp3", loop:true, volume: 0.2,delay:starjumptime, obj:child);
              OPENWORLD.Mob.setSpeech(child, ["I can do star jumps!", "I jump so high"], z: 80,
                  width: 300,
                  scale: 0.4);
            } else if (rnd<0.6) {
              var jumptime=OPENWORLD.Math.random()*10;
              OPENWORLD.Actor.playAction(child,    name: "jump", duration:1, stopallactions: true,  delay:jumptime);

              OPENWORLD.Sound.play( sound:jumpsound,path: "sounds/starjump.mp3", loop:true, volume: 0.2,delay:jumptime, obj:child);
              OPENWORLD.Mob.setSpeech(child, ["I can jump!", "Im clever"], z: 80, width: 300,  scale:0.4);

            } else {
              jumpsound.stop();
              OPENWORLD.Actor.playAction(child,    name: "idle2", duration:1, stopallactions: true);
              OPENWORLD.Mob.clearText(child);
              var fartime=OPENWORLD.Math.random()*10;
              if (OPENWORLD.Math.random() <0.5)
                OPENWORLD.Sound.play( path: "sounds/fart.wav", volume: 0.2,delay:fartime);
              else
                OPENWORLD.Sound.play( path: "sounds/fart2.mp3", volume: 0.2,delay:fartime);
              OPENWORLD.Sound.play( path: "sounds/laugh.wav", volume: 0.1,delay:fartime+2);

              OPENWORLD.Mob.setSpeech(child, ["I farted!"], z: 80, width: 300,  scale:0.4, delay:fartime);

            }


        });
        OPENWORLD.BaseObject.addTimer(child,t);
      } else {
        print("child out");
        jumpsound.stop();
        OPENWORLD.Space.faceObjectAlwaysRemove(child);
        OPENWORLD.BaseObject.clearTimers(child);
      }
    });


    addnpc(child, "child", false, deathsoundpath: "sounds/groan.mp3");

    OPENWORLD.BaseObject.setCustomTrigger(child);//, dist: 1.5);
    child.extra['customtrigger'].addEventListener('strucktrigger', (THREE.Event event) async {
      print("child dead");
      OPENWORLD.BaseObject.clearAll(child);
      actorDie(child); //,diesoundpath:"sounds/groan.mp3");
      OPENWORLD.BaseObject.disableDistanceTrigger(child);

      var lolly= await OPENWORLD.Model.createModel('assets/models/lolly.glb');
      lolly.scale.set(0.0015, 0.0015, 0.0015);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          lolly,365.33+0.1,232.03,0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
      scene.add(lolly);
      setGetObject(lolly,scalenotselected:1.1, scaleselected:1.2, takelabel:"Eat");
      setEatObject(lolly,3,0.2);
    });

    // This is the prison entrance of lindos but not the actual prison where the prisoners are chained up
    var roomPrisonentrance = OPENWORLD.Room.createRoom(368.479,281.857,
    soundpath: "sounds/home.mp3",  randomsoundpath:"sounds/groan.mp3", randomsoundgap:30, volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomPrisonentrance.extra['guide'] = [
      "This where the",
      "bad people go.",
      "Not many people",
      "tend to leave this place"
    ];
    OPENWORLD.Room.setAutoIndoors( roomPrisonentrance , true);

    scene.add( roomPrisonentrance );

    OPENWORLD.Room.setDistanceTrigger( roomPrisonentrance , dist:0.5);
    // minx: -3.47, maxx: 10.1, miny: -12.4, maxy: -2.1);

    guard2 =await OPENWORLD.Actor.copyActor( guard,
        texture: "assets/actors/knight15.jpg",
        action:"idle2"
      //   z: actoroffset
    );
    setDefaultActor(guard2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        guard2,368.47,282.42, 0, 4);
    OPENWORLD.Space.objTurn(guard2,180+45);  //sw
    scene.add(guard2);

    OPENWORLD.BaseObject.setCustomTrigger(guard2);
    guard2.extra['customtrigger'].addEventListener('strucktrigger', (THREE.Event event) {
      print("struck"+event.action.toString());
      OPENWORLD.Actor.playActionThen(guard2, "slash", "idle", duration:1, durationthen:2);
      youDie();

      OPENWORLD.Mob.moveTo(guard2, [[ 367.44, 279.55,0,0.52]] , action:"walk", stopaction:"idle", delay:4.5);
      OPENWORLD.Space.faceObjectLerp(guard2, camera, 1,delay:16);
      OPENWORLD.Mob.setSpeech(guard2, ["Why did you hit me?","Are you mad?","Strange people around."], z: 80, width: 300,  scale:0.4, delay:20);
      OPENWORLD.Space.worldToLocalSurfaceObjLerp(camera, 367.44, 279.55,OPENWORLD.Camera.cameraoffset,5, delay:4);
      OPENWORLD.Space.worldToLocalSurfaceObjLerp(camera, 368.88, 279.96,OPENWORLD.Camera.cameraoffset,5, delay:9);


    });

    // This is for the guard
    var sword= await OPENWORLD.Model.createModel('assets/models/sword.glb');
    sword.scale.set(0.002, 0.002, 0.002);

    OPENWORLD.Space.objTurn(sword,90);
    OPENWORLD.Space.objPitch(sword.children[0],90);
    OPENWORLD.Space.objTurn(sword.children[0],90);
    setWeaponWield(sword, false, "sword");
    scene.add(sword);

    setWeaponWield(sword, true, "sword");

    OPENWORLD.Actor.wield(guard2, sword, "Bip01_R_Hand");
    addnpc(guard2, "guard", false);

    // This is the room with the prisoners chained up groaning
    var roomPrisoninside = OPENWORLD.Room.createRoom(368.980,280.330,
        soundpath: "sounds/courtyard.mp3",randomsoundpath:"sounds/groan.mp3", randomsoundgap:30, volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomPrisoninside.extra['guide'] = [
      "These poor prisoners",
      "are chained in manacles",
      "which is fair given",
      "what they done"
    ];
    OPENWORLD.Room.setAutoIndoors( roomPrisoninside , true);

    scene.add( roomPrisoninside );
    OPENWORLD.Room.setDistanceTrigger( roomPrisoninside , dist:0.5);

    // Prisoners with shackled animation
    var prisoner24 =await OPENWORLD.Actor.copyActor( citizen2,
      texture: "assets/actors/citizen24.jpg",
      action:"shackled"
      //   z: actoroffset
    );

    setDefaultActor(prisoner24);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        prisoner24,OPENWORLD.Room.getX(roomPrisoninside)+0.88, OPENWORLD.Room.getY(roomPrisoninside)+0.075, 0, 4);
    OPENWORLD.Space.objTurn(prisoner24,270);  //w
    scene.add(prisoner24);

    OPENWORLD.BaseObject.setDistanceTrigger(prisoner24, dist: 2.0);
    prisoner24.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        chatter = ["What Id give to get spat at in the face",
          "I sometimes hang awake at night dreaming of being spat at in the face",
          "Ooh manacles",
          "You dont get anywhere unless you do a fair days work for a fair days pay",
          "When Im hanging up here at night the guard does unspeakable things to me",
          "Im innocent, I did not kiss the mayors wife"];
        OPENWORLD.Mob.setChatter(
            prisoner24, chatter, z: 80, randwait: 10, width: 300, scale: 0.4);
      }
    });


    var prisoner25 =await OPENWORLD.Actor.copyActor( citizen2,
        texture: "assets/actors/citizen25.jpg",
        action:"shackled"
      //   z: actoroffset
    );
    setDefaultActor(prisoner25);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        prisoner25,OPENWORLD.Room.getX(roomPrisoninside)+0.63, OPENWORLD.Room.getY(roomPrisoninside)-0.35, 0, 4);
    OPENWORLD.Space.objTurn(prisoner25,270);  //w
    scene.add(prisoner25);


    // Restaurant room in center of Lindos - Sheperds baah
    var roomRestaurant = OPENWORLD.Room.createRoom(381.65, 254.19,//381.140,255.750,
    soundpath: "sounds/crowd.mp3", volume: 0.05, exitroom:roomDefault); //THREE.Object3D();
    roomRestaurant.extra['guide'] = [
      "The Shepherds Baah",
      "is where you can",
      "buy food. You always",
      "feel better after a good meal"
    ];
    OPENWORLD.Room.setAutoIndoors( roomRestaurant , true);

    scene.add( roomRestaurant );

    OPENWORLD.Room.setDistanceTrigger( roomRestaurant , dist:1.4);

    // Restaurant sheep sign outside
    var restaurantsign = await OPENWORLD.Plane.loadPlane(
        "assets/textures/sheperdsbaah.jpg", 0.3, 0.47, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        restaurantsign,381.97, 256.41 ,1.2, 4);
    OPENWORLD.Space.objTurn(restaurantsign,180+90-20);
    scene.add(restaurantsign);

    // Sheep sign inside
    var restaurantsign2= restaurantsign.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        restaurantsign2,382.05, 253.30 ,0.7, 4);
    OPENWORLD.Space.objTurn(restaurantsign2,180+90);
    restaurantsign2.scale.set(0.5,0.5,0.5);
    scene.add(restaurantsign2);

    // Knight standing in the restaurant
    Group knight2 =
    await OPENWORLD.Actor.createActor('assets/actors/knight2.glb',
        z: actoroffset);
     setDefaultActor(knight2 );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        knight2 ,381.140+0, 255.750-0.5, 0, 4);
    OPENWORLD.Space.objTurn(knight2 ,0);  //n
    scene.add( knight2 );
    addknightnpc(knight2,"knight2");

    // Citizen sitting in chair gets up when you get close to wench
    var citizenii =await OPENWORLD.Actor.copyActor(  amon, action:"sittableidle"/*, shareanimations: true*/);
    //  setDefaultActor(prisoner24);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizenii,381.140+0.3, 255.750-0.7, 0.05, 4);
    OPENWORLD.Space.objTurn( citizenii,180);  //s
    scene.add(citizenii);
    addcitizennpc(citizenii,"citizenii",true);

    var hasgotup2=false;
    var citizen42=  await OPENWORLD.Actor.copyActor(citizen4,action:"sittableidle");

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizen42,381.16, 254.63,0,4);
    OPENWORLD.Space.objTurn(citizen42,90);  //e
    scene.add(citizen42);
    addcitizennpc(citizen42,"citizen42",true);
    OPENWORLD.BaseObject.setDistanceTrigger(citizen42, dist: 0.5);
    citizen42.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        if (hasgotup2)
          OPENWORLD.Mob.setChatter(citizen42,["I'm just contemplating the meaning of life","I like to stand and look at the wall"],  z: 80, width: 300, scale:0.4);

      }
    });

    // Wench who serves the food
    var wench2 =await OPENWORLD.Actor.copyActor( oldlady,);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        wench2,381.140+0.4, 255.750+0, 0, 4);
    OPENWORLD.Space.objTurn( wench2,270);  //w
    scene.add( wench2);
    addcitizennpc(wench2,"wench2",false);

    OPENWORLD.BaseObject.setDistanceTrigger(wench2, dist: 0.5);
    wench2.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        print("old lady in");
        chatter = ["My legs are grey.",
            "What can I get you?",
            "My ears are gnarled.",
            "We have delicious Anthropinos stew",
            "My eyes are old and bent."];
        OPENWORLD.Mob.setChatter(
              wench2, chatter, z: 80, randwait: 10, width: 300, scale: 0.4);

        // Wench walks towards table when you enter
        if (!hasgotup2) {
          hasgotup2=true;
          OPENWORLD.Mob.moveTo(
              wench2, [[ 382.20, 254.78, 0], [381.88, 254.38, 0]],
              action: "walk", stopaction: "idle");
          OPENWORLD.Space.faceObjectAlways(wench2, camera, delay: 9);

          OPENWORLD.BaseObject.disableDistanceTrigger(wench2);

          OPENWORLD.Actor.playActionThen(
              citizen42, "sittable", "idle", backwards: true,
              duration: 1,
              durationthen: 2,
              delay: 5);
          OPENWORLD.Mob.moveTo(
              citizen42, [[381.23, 253.22], [ 381.58, 252.53]], action: "walk",
              stopaction: "idle",
              delay: 7);
        }

      } else {
        print("old lady out");
      }
    });

    // When click on restaurant board show menu so can buy food
    var board2=board.clone();
    board2.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.objTurn(board2,90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board2,381.88, 254.76,0.2,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    scene.add(board2);
    addMsgToObj(board2, "Click for menu",z:30);//, scale:0.15, z:15);

    OPENWORLD.BaseObject.setHighlight(board2, scene, THREE.Color(0x0000ff), 1.0);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(board2, true,scale:1.02, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(board2);
    board2.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      /*  "anthropinos stew" 20
    "skylos stew" 10
    "kabouros stew" 10
    "nyfitsa stew" 10 */
      OPENWORLD.BaseObject.highlight(board2, true, scale:1.05, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Anthropinos: 20", "command":"anthropinos"});
        menuitems.add({"text":"Skylos stew: 10", "command":"skylos"});
        menuitems.add({"text":"Kabouros stew: 10", "command":"kabouros"});
        //menuicon=Icon(Icons.notes);
        //menutooltip="Read menu";
        menuobj=board2;
      });
    });
    // Show either soup bowl or cheese depending on what you buy
    Group food=Group();
    var soupbowl= await OPENWORLD.Model.createModel('assets/models/soupbowl.glb');
    food.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObj(
        food,381.42,254.60,0.21);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    food.add(soupbowl);
    scene.add(food);
    OPENWORLD.BaseObject.setHighlight(soupbowl, food, THREE.Color(0x0000ff), 1.0, deselectopacity: 0.5);//, scalex:1.4, scaley:1, scalez:1.4);

    var cheese= await OPENWORLD.Model.createModel('assets/models/cheese.glb');
    food.add(cheese);
    OPENWORLD.BaseObject.setHighlight(cheese, food, THREE.Color(0x0000ff), 1.0, deselectopacity: 0.5);//, scalex:1.4, scaley:1, scalez:1.4);

    addMsgToObj(soupbowl, "Click to eat", scale:0.15, z:15);
    addMsgToObj(cheese, "Click to eat", scale:0.15, z:15);

    // When click on the food when seated show eat menu
    OPENWORLD.BaseObject.setTouchTrigger(food);
    // This is when you click on the food on your plate
    food.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      if (!cheese.visible&&!soupbowl.visible) {
        return;
      }
      var clickevent=event.action;
      if (food.extra['chosen']=='anthropinos')// event.action==
         OPENWORLD.BaseObject.highlight(cheese, true, scale:1.05, opacity:1);
      else
         OPENWORLD.BaseObject.highlight(soupbowl, true, scale:1.05, opacity:1);
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"icon":Icon(Icons.get_app), "tooltip":"Eat"});
        // menuicon=Icon(Icons.get_app);
        // menutooltip="Take";
        menuobj=food;
      });
    });
    // This is when you click on the get item in the menu - eat it and increase your health
    food.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {

        OPENWORLD.Sound.play( path: "sounds/eat.mp3", volume: 0.2);
        OPENWORLD.Sound.play( path: "sounds/burp.wav", volume: 0.2, delay:4);

        if (food.extra['chosen']=='anthropinos') {

          setHealth(health*1.5+0.3);

          OPENWORLD.BaseObject.highlight(cheese, false);
          cheese.visible=false;
        } else {
          setHealth(health*1.25+0.2);

          OPENWORLD.BaseObject.highlight(soupbowl, false);
          soupbowl.visible=false;
        }
        OPENWORLD.Mob.setSpeech(wench2, ["How was it?"], randwait: 0,
            minwait: 5,
            z: 80,
            width: 300,
            scale: 0.4, delay:6);

      OPENWORLD.You.immobile=false;

    });
    soupbowl.visible=false;
    cheese.visible=false;

    // This is where you click on the menu
    // When you buy the food you pay for its and walk to the chair and sit down and immobile until you eat it
    board2.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      print("triggermenu board"+event.action);

      var enough;
      food.extra['chosen']=event.action;
      if (event.action=='anthropinos') {
        if (gold-20>0) {
          cheese.visible = true;
          OPENWORLD.BaseObject.highlight(
              cheese, true, scale: 1.02, opacity: 0.5);
          OPENWORLD.BaseObject.highlight(soupbowl, false);
          setGold(gold - 20);
          enough=true;
        } else
          enough=false;
      }  else {
        if (gold-10>0) {
          soupbowl.visible = true;
          OPENWORLD.BaseObject.highlight(
              soupbowl, true, scale: 1.02, opacity: 0.5);
          OPENWORLD.BaseObject.highlight(cheese, false);
          setGold(gold - 10);
          enough=true;
        }else
          enough=false;
      }

      if (!enough) {
        OPENWORLD.Mob.setSpeech(wench2, ["You don't have enough money for that"], randwait: 0,
            minwait: 5, z: 80, width: 300, scale: 0.4);

      } else {
        OPENWORLD.Mob.setSpeech(wench2, ["There you go"], randwait: 0,
            minwait: 5,
            z: 80,
            width: 300,
            scale: 0.4);
        OPENWORLD.Mob.moveTo(camera, [
          [ 381.46, 255.22, OPENWORLD.Camera.cameraoffset],
          [381.16, 254.63, OPENWORLD.Camera.cameraoffset]
        ]);
        giveAnimation(wench2);

        // You sit in the chiar
        OPENWORLD.Space.objTurnLerp(camera, 90, 1, delay: 7);
        OPENWORLD.Space.worldToLocalSurfaceObj(
            camera, 381.16, 254.63, 0.3, delay: 9); //x, y, z)
        OPENWORLD.You.immobile = true;
      }

    });

    // This is the restaurant in Lindos that is closer to the sea
    // Sells the same food as sheperds baah
    var roomSmellybottle = OPENWORLD.Room.createRoom(392.830,300.000,
        soundpath: "sounds/crowd.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomSmellybottle.extra['guide'] = [
      "The Smelly Bottle",
      "is a popular restaurant",
      "where you can buy fine food.",
      "When you aren't feelling well",
      "a fine meal does the trick"
    ];
    OPENWORLD.Room.setAutoIndoors( roomSmellybottle , true);
    scene.add( roomSmellybottle );

    OPENWORLD.Room.setDistanceTrigger( roomSmellybottle , minx:392.6, maxx:396, miny:299.1, maxy:300.4);// dist:0.5);

    var wench2ii =await OPENWORLD.Actor.copyActor( realestatelady,
      texture: "assets/actors/citizenf42.jpg",
      action:"idle2"

    );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        wench2ii,393.35, 300.00, 0, 4);
    OPENWORLD.Space.objTurn( wench2ii,270);  //w
    scene.add( wench2ii);
    addcitizennpc(wench2ii,"wench2ii",false);
    OPENWORLD.Space.faceObjectAlways(wench2ii, camera);

    roomSmellybottle.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        chatter=["Are you looking at my cleavage?",
          "Dont ask why this place is called the smelly bottle",
          "What can I get you?"];
        OPENWORLD.Mob.setChatter(wench2ii, chatter,  z: 80, width: 300, scale:0.4);

      } else {
        OPENWORLD.Mob.setSpeech(wench2ii, ["Nice meeting you"], randwait: 0,
            minwait: 5, z: 80, width: 300, scale: 0.4);
      }
    });

    var board3=board.clone();//await OPENWORLD.Model.createModel('assets/models/board.glb');
    board3.scale.set(0.3,0.3,0.3);
    board3.position.set(0.0,0.0,0.0);
    OPENWORLD.Actor.wield(wench2ii,board3, "Bip01_R_Hand");

    OPENWORLD.BaseObject.setHighlight(board3, board3, THREE.Color(0x0000ff), 1.0, scale:3);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(board3, true,scale:3, opacity:0.8);
    OPENWORLD.BaseObject.setTouchTrigger(board3);
    board3.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(board3, true, scale:3, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Anthropinos: 20", "command":"anthropinos"});
        menuitems.add({"text":"Skylos stew: 10", "command":"skylos"});
        menuitems.add({"text":"Kabouros stew: 10", "command":"kabouros"});
        menuobj=board3;
      });
    });

    Group food2=Group();

    var soupbowl3= soupbowl.clone();
    food2.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObj(
        food2,393.81, 299.61 ,0.21);
    food2.add(soupbowl3);
    scene.add(food2);
    OPENWORLD.BaseObject.setHighlight(soupbowl3, food2, THREE.Color(0x0000ff), 1.0, deselectopacity: 0.5);//, scalex:1.4, scaley:1, scalez:1.4);

    var cheese2= cheese.clone();

    food2.add(cheese2);
    OPENWORLD.BaseObject.setHighlight(cheese2, food2, THREE.Color(0x0000ff), 1.0, deselectopacity: 0.5);//, scalex:1.4, scaley:1, scalez:1.4);

    addMsgToObj(soupbowl3, "Click to eat", scale:0.15, z:15);
    addMsgToObj(cheese2, "Click to eat", scale:0.15, z:15);

    OPENWORLD.BaseObject.setTouchTrigger(food2);
    // This is when you click on the food on your plate
    food2.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      //  print("touched trigger "+event.action);
      if (!cheese2.visible&&!soupbowl3.visible) {
        return;
      }
      var clickevent=event.action;
      if (food2.extra['chosen']=='anthropinos')// event.action==
        OPENWORLD.BaseObject.highlight(cheese2, true, scale:1.05, opacity:1);
      else
        OPENWORLD.BaseObject.highlight(soupbowl3, true, scale:1.05, opacity:1);
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"icon":Icon(Icons.get_app), "tooltip":"Eat"});
        // menuicon=Icon(Icons.get_app);
        // menutooltip="Take";
        menuobj=food2;
      });
    });
    // This is when you click on the get item in the menu
    food2.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      // print("triggermenu "+event.action);
      //  sword.visible=false;
      setState(() {
        OPENWORLD.Sound.play( path: "sounds/eat.mp3", volume: 0.2);
        OPENWORLD.Sound.play( path: "sounds/burp2.wav", volume: 0.2, delay:3);

        if (food2.extra['chosen']=='anthropinos') {
          //setGold(gold-20);//gold -= 20;
          setHealth(health*1.5+0.3);
//          health*=1.5;
          OPENWORLD.BaseObject.highlight(cheese2, false);
          cheese2.visible=false;

        } else {

          setHealth(health*1.25+0.2);
          OPENWORLD.BaseObject.highlight(soupbowl3, false);
          soupbowl3.visible=false;
        }
        OPENWORLD.Mob.setSpeech(wench2ii, ["Hope you liked it"], randwait: 0,
            minwait: 5,
            z: 80,
            width: 300,
            scale: 0.4, delay:6);

      });
      OPENWORLD.You.immobile=false;

    });
    soupbowl3.visible=false;
    cheese2.visible=false;

    // This is where you click on the menu
    board3.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      print("triggermenu board"+event.action);
      food2.extra['chosen']=event.action;
      var enough;
      if (event.action=='anthropinos') {
        if (gold-20>=0) {
          cheese2.visible = true;
          OPENWORLD.BaseObject.highlight(
              cheese2, true, scale: 1.02, opacity: 0.5);
          OPENWORLD.BaseObject.highlight(soupbowl3, false);
          setGold(gold - 20); //gold -= 20;
          enough=true;
        } else
          enough=false;

      }  else {
        if (gold-10>=0) {
          soupbowl3.visible = true;
          OPENWORLD.BaseObject.highlight(
              soupbowl3, true, scale: 1.02, opacity: 0.5);
          OPENWORLD.BaseObject.highlight(cheese2, false);
          setGold(gold - 10); //gold -= 20;
          enough=true;
        } else
          enough=false;


      }
      if (!enough) {
        OPENWORLD.Mob.setSpeech(wench2ii, ["You don't have enough money for that"], randwait: 0,
            minwait: 5, z: 80, width: 300, scale: 0.4);

      } else {
        OPENWORLD.Mob.setSpeech(wench2ii, ["There you go"], randwait: 0,
            minwait: 5, z: 80, width: 300, scale: 0.4);

        giveAnimation(wench2ii);

        OPENWORLD.Mob.moveTo(camera, [[ 393.39, 299.71, OPENWORLD.Camera.cameraoffset],[394, 299.38,OPENWORLD.Camera.cameraoffset]]);
        OPENWORLD.Space.objTurnLerp(camera,313,1,delay:7);
        OPENWORLD.Space.worldToLocalSurfaceObj(camera, 394, 299.38,0.3, delay:9);//x, y, z)
        OPENWORLD.You.immobile=true;

      }
    });

    citizenii =await OPENWORLD.Actor.copyActor(  citizen,
        action:"sittable"
    );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizenii,393.93, 299.85,- 0.05, 4);
    OPENWORLD.Space.objTurn( citizenii,270);  //s
    scene.add(citizenii);
    addcitizennpc(citizenii,"citizenii",true);

    var citizen2ii= await OPENWORLD.Actor.copyActor(citizen2,action:"sittable");
    setDefaultActor(citizen2ii);

    // Same as sheperds baah when you get close walks away from chair
    var hasgotup=false;
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizen2ii,394, 299.38, -0.05, 4);
    //OPENWORLD.Space.worldToLocalSurfaceObjHide(
   // citizen2,OPENWORLD.Room.getX(roomSmellybottle)+1-0.4, OPENWORLD.Room.getY(roomSmellybottle)+1-0.1, -0.55, 4);
    OPENWORLD.Space.objTurn(citizen2ii,270+45);  //nw
    scene.add(citizen2ii);
    OPENWORLD.BaseObject.setDistanceTrigger(citizen2ii, dist: 0.5);
    citizen2ii.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        if (hasgotup) {
          OPENWORLD.Mob.setChatter(
              citizen2ii, ["I like to stand out here & look at the sea","I can stand and look at the sea all day"], z: 80, width: 300, scale: 0.4);
        }
      }
    });

    addcitizennpc(citizen2ii,"citizen22ii",true);

    // When get close to wench citizen walks outside so you can have a seat
    OPENWORLD.BaseObject.setDistanceTrigger(wench2ii, dist: 0.8);
    wench2ii.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        print("smelly bottle wench in");

        if (!hasgotup) {
          hasgotup=true;
          OPENWORLD.Actor.playActionThen(
              citizen2ii, "sittable", "idle", backwards: true,
              duration: 1,
              durationthen: 2);
           var time= await OPENWORLD.Mob.moveTo(citizen2ii, [
            [393.01, 299.74],
            [392.84, 300.11],
            [391.68, 300.52],
            [391.50, 302.41]
          ], action: "walk", surfaceonly: true, stopaction: "idle", delay: 5);

        }

      } else {
        print("smelly bottle wench out");

      }
    });

    // This is the smithy of lindos - all you can do is sell kindling to him and also this where you send the order from the job knight
    var roomSmithy = OPENWORLD.Room.createRoom(381.064,239.750,
        soundpath: "sounds/fire.mp3", randomsoundpath:"sounds/smithyhammer.mp3", randomsoundgap:60,  volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomSmithy.extra['guide'] = [
      "The smithy is where",
      "armourers and weaponers",
      "buy and repair their",
      "weapons and armour.",
      "The smithy always complains about",
      "never having enough wood."
    ];
    OPENWORLD.Room.setAutoIndoors( roomSmithy, true);
    scene.add( roomSmithy );

    OPENWORLD.Room.setDistanceTrigger( roomSmithy , dist:0.5);

    // Fire in kiln
    brandfire = new VolumetricFire(
        fireWidth, fireHeight, fireDepth, sliceSpacing, camera);
    await brandfire.init();
    OPENWORLD.Updateables.add(brandfire);

    brandfire.mesh.scale.x = 0.04; //0.05;
    brandfire.mesh.scale.y = 0.04; //0.05;
    brandfire.mesh.scale.z = 0.04; //0.05;
    brandfire.mesh.position.y = 0.05; //33;
    scene.add(brandfire.mesh);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        brandfire.mesh ,380.40, 239.63,0.25,4);//380.32, 239.63, 0.2, 4);


    Group smithy =
    await OPENWORLD.Actor.createActor('assets/actors/smithy.glb',
        shareanimations: armourer,
        action:"idle2",
        z: actoroffset);
    setDefaultActor(smithy );

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smithy ,381.13, 239.46, 0, 4);
    OPENWORLD.Space.objTurn(smithy ,0);  //n
    scene.add( smithy );
    addcitizennpc(smithy,"smithy",false);


    roomSmithy.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        chatter=["Have you got wood? These furnaces use so much wood.",
          "I pay good money for kindling.",
          "Theres some good kindling south west from about 5 miles away.",
          "I sometimes get so hot in here I strip off. Was so embarrased when the mayor came in",
          "I do a lot of orders for the knights. They're always breaking something."];
        OPENWORLD.Mob.setChatter(smithy, chatter,  z: 80, width: 300, scale:0.4);
      }
    });

    // If click on hammer can sell your kindling
    var kindlingprice=20;  // was 5 but given the effort isn't worth it
    var hammer=await OPENWORLD.Model.createModel('assets/models/hammer.glb');
    hammer.scale.set(0.2,0.2,0.2);
    //hammer.children[0].position.set(0,0,0);
    OPENWORLD.Actor.wield(smithy,hammer, "Bip01_L_Finger11");//Bip01_R_Hand");
    addMsgToObj(hammer, "Click to sell",scale:0.6);
    OPENWORLD.BaseObject.setHighlight(hammer, hammer, THREE.Color(0x0000ff), 1.0, scale:5.2);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(hammer, true,scale:5.2, opacity:0.8);
    OPENWORLD.BaseObject.setTouchTrigger(hammer);
    hammer.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(hammer, true, scale:5.2, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Sell"});
        menuitems.add({"text":"Kindling: "+displayMoney(kindlingprice), "command":"kindling"});

        menuobj=hammer;
      });
    });

    hammer.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) async {
      print("triggermenu board"+event.action);

      if (event.action=='kindling') {
        if (inventorynames.contains("kindling")) {
          giveAnimation(smithy);
          setState(() {
            gold += kindlingprice;
          });
          removeInventory("kindling");
          OPENWORLD.Mob.setSpeech(smithy, [
            'Thanks. We need to keep these kilns running.',
          ], z: 100, width: 300);
        } else {
          Fluttertoast.showToast(
              msg: "You dont have any kindling to sell",
              toastLength: Toast.LENGTH_LONG);
        }
      }
    });
    // Show bundles of kindling in the smithys
    var  kindling = await OPENWORLD.Sprite.loadSprite(
        "assets/textures/kindling.png", 0.3, 0.2, ambient: false);//, z:1);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        kindling,382.57, 238.52, 0,4);
    scene.add(kindling);
    var kindling2=OPENWORLD.Sprite.cloneSprite(kindling);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        kindling2,380.14, 239.97, 0.0,4);
    scene.add(kindling2);
    var kindling3=OPENWORLD.Sprite.cloneSprite(kindling);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        kindling3,382.02, 240.51, 0.0,4);
    scene.add(kindling3);


    // This is the second post office in the center of lindos and is the same as the one further east
    // Just one message from the grandmaster about the spy
    var roomPostoffice2= OPENWORLD.Room.createRoom(383.850,257.930,
        soundpath: "sounds/shop.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();
    roomPostoffice2.extra['guide'] = [
      "This is where the people of",
      "Lindos send and recieve",
      "mail"
    ];
    OPENWORLD.Room.setAutoIndoors( roomPostoffice2, true);
    scene.add( roomPostoffice2);

    OPENWORLD.Room.setDistanceTrigger( roomPostoffice2 , minx:383.6, maxx:386.4, miny:256.3, maxy:257.95);//dist:0.5);
    // minx: -3.47, maxx: 10.1, miny: -12.4, maxy: -2.1);

    var postie2 =await OPENWORLD.Actor.copyActor( realestatelady,
        texture: "assets/actors/citizenf43.jpg",
        action:"idle2"
      //   z: actoroffset
    );

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        postie2,OPENWORLD.Room.getX(roomPostoffice2)+0.9, OPENWORLD.Room.getY(roomPostoffice2)-0.2, 0, 4);
    OPENWORLD.Space.objTurn(postie2,270);  //w
    scene.add(postie2);
    addcitizennpc(postie2,"postie2",false);

    roomPostoffice2.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        chatter = [
          "Sorting mail can get boring",
          "At least its better than working at the Smelly Bottle",
          "I was always getting my bottom pinched",
          "My sister took over my job there",
          "and her bottom is always red"
        ];
        OPENWORLD.Mob.setSpeech(postie2, chatter, randwait: 0,
            minwait: 5,
            z: 80,
            width: 300,
            scale: 0.4,
            delay: 5);
      }
    });

    var bag2=bag.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bag2,384.37, 257.32, 0, 4);
    scene.add(bag2);
    addMsgToObj(bag2, "Click to check mail", scale:0.1, z:11);

    OPENWORLD.BaseObject.setHighlight(bag2, scene, THREE.Color(0x0000ff), 1.0, scale:1.08);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(bag2, true,scale:1.08, opacity:0.5);
    OPENWORLD.BaseObject.setTouchTrigger(bag2);
    bag2.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {

      OPENWORLD.BaseObject.highlight(bag2, true, scale:1.1, opacity:1);
      var clickevent=event.action;
      giveAnimation(postie2);
      setState(() {

        menuposx=width/3;//clickevent.clientX;
        menuposy=40;//clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"You have a message."});
        menuitems.add({"text":"It reads:"});
        menuitems.add({"text":"Hello esteemed friend."});
        menuitems.add({"text":"We are glad youve come to help us out."});
        menuitems.add({"text":"We need all the help we can get."});
        menuitems.add({"text":"Keep your eyes and ears open for traitors"});
        menuitems.add({"text":"and spies."});
        menuitems.add({"text":" "});
        menuitems.add({"text":"Yours Philippe Villiers de L'Isle-Adam"});
        menuitems.add({"text":"Grandmaster of Knights Hospitalier"});
        //menuicon=Icon(Icons.notes);
        //menutooltip="Read menu";
        menuobj=bag2;
      });
    });

    // This is the soup kitchen with a bowl of soup that you can eat and will increase your health - its free
    var roomSoupkitchen = OPENWORLD.Room.createRoom(386.730,243.160,
        soundpath: "sounds/shop.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomSoupkitchen.extra['guide'] = [
      "When you arent feeling well",
      "a free bowl of soup will",
      "do the trick.",
      "Many homeless come here"
    ];
    OPENWORLD.Room.setAutoIndoors( roomSoupkitchen, true);
    scene.add( roomSoupkitchen );

    OPENWORLD.Room.setDistanceTrigger( roomSoupkitchen , dist:1.0);

    Group souplady =
    await OPENWORLD.Actor.createActor('assets/actors/citizenf3.glb',
        z: actoroffset);
    setDefaultActor(souplady );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        souplady ,387.77,243.3,0,4);
    OPENWORLD.Space.objTurn(souplady ,270);  //w
    scene.add( souplady );
    addcitizennpc(souplady,"souplady",false);

    // Homeless man sits there
    var homeless= await OPENWORLD.Actor.copyActor(citizen,  texture: "assets/actors/citizen13.jpg", action:"sittable");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        homeless,387.15, 242.51, 0, 4);

    OPENWORLD.Space.objTurn(homeless,0);  //w
    scene.add(homeless);
    addcitizennpc(homeless,"homeless",true);

    var soupbowl2= soupbowl.clone();//await OPENWORLD.Model.createModel('assets/models/soupbowl.glb');
    soupbowl2.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soupbowl2,386.61,242.78,0.2,4);
    scene.add(soupbowl2);

    addMsgToObj(soupbowl2, "Click to eat");

    roomSoupkitchen.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        var minwait=5;
        chatter = [
          "We get a lot of transients here",
          "But you dont look like one",
          "They are smelly",
          " ",
          " ",
          "Haha"
        ];
        OPENWORLD.Mob.setSpeech(souplady, chatter, randwait: 0,
            minwait: minwait,
            z: 80,
            width: 300,
            scale: 0.4,
            delay: 5);
        OPENWORLD.Actor.playActionThen(homeless, "sittable", "idle2",  backwards:true,  delay: 5+2*minwait+2);
        OPENWORLD.Space.faceObjectLerp(homeless, souplady, 0.5, delay: 5+2*minwait+4);
        chatter = [
          "Hey, I dont smell",
          "I changed my underwear last week",
        ];
        OPENWORLD.Mob.setSpeech(homeless, chatter, randwait: 0,
            minwait: minwait,
            z: 80,
            width: 300,
            scale: 0.4,
            delay: 5+2*minwait+4);

        OPENWORLD.Space.faceObjectLerp(homeless,camera, 0.5, delay: 5+2*minwait+4+minwait*2);
        chatter=[
          "If you are poor we give out free soup.",
          //  "Courtney says: Just give me a voucher and I'll give you a bowl of soup.\n",
          "We serve Fasolatha, a hearty navy bean soup with a tomato base.",
          "Another favourite is Kotosoupa, a chicken soup with creamy lemon sauce."];
        OPENWORLD.Mob.setChatter(souplady, chatter,  z: 80, width: 300, scale:0.4, delay:5+2*minwait+4*minwait*4);
      } else {
        OPENWORLD.BaseObject.clearAll(homeless);
        OPENWORLD.BaseObject.clearAll(souplady);
        OPENWORLD.Space.objTurnLerp(homeless,0,1);
        OPENWORLD.Actor.playActionThen(homeless, "sittable", "sittableidle" );

      }
    });

    setGetObject(soupbowl2,takelabel:"Eat");
    setEatObject(soupbowl2,3,0.2);  // If eat soup then increase health by a factor of 3


    // This is the Lindos weaponer where can buy/sell either a sword or battleaxe
    var roomWeaponer = OPENWORLD.Room.createRoom(383.710,270.590,
        soundpath: "sounds/shop.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomWeaponer.extra['guide'] = [
      "You can buy fine",
      "weapons here &",
      "sell them for a",
      "good price"
    ];
    OPENWORLD.Room.setAutoIndoors( roomWeaponer, true);
    scene.add( roomWeaponer );

    Group weaponer =
    await OPENWORLD.Actor.createActor('assets/actors/weaponer.glb',
        z: actoroffset);
    setDefaultActor(weaponer );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        weaponer ,OPENWORLD.Room.getX(roomWeaponer)+0, OPENWORLD.Room.getY(roomWeaponer)+0.9, 0, 4);
    OPENWORLD.Space.objTurn(weaponer  ,180);  //s
    scene.add( weaponer  );
    addcitizennpc(weaponer,"weaponer",false);

    var weaponshop = await OPENWORLD.Plane.loadPlane(
        "assets/textures/weaponer.png", 0.6, 0.32, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        weaponshop,383.45,272.40,0.47, 4);
    OPENWORLD.Space.objTurn(weaponshop,105);
    scene.add(weaponshop);
    addMsgToObj(weaponshop, "Click for weapons", scale:0.0017, z:0.22);

    OPENWORLD.BaseObject.setHighlight(weaponshop, scene, THREE.Color(0x0000ff), 1.0, scale:1.02);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(weaponshop, true,scale:1.01, opacity:0.7);
    OPENWORLD.BaseObject.setTouchTrigger(weaponshop);
    markup=1.2;
    markdown=0.8;
    var swordprice=100;
    var battleaxeprice=100;
    weaponshop.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      //  print("touched");
      OPENWORLD.BaseObject.highlight( weaponshop, true, scale:1.02, opacity:1);
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"Buy"});
        menuitems.add({"text":"Sword: "+displayMoney(getBuyPrice(swordprice,markup)), "command":"sword"});
        menuitems.add({"text":"Battleaxe: "+displayMoney(getBuyPrice(battleaxeprice,markup)), "command":"battleaxe"});
        menuitems.add({"text":"Sell"});
        if (inventorynames.contains("sword"))
          menuitems.add({"text":"Sword: "+displayMoney(getSellPrice(swordprice,markdown)), "command":"swordsell"});
        if (inventorynames.contains("battleaxe"))
          menuitems.add({"text":"Battleaxe: "+displayMoney(getSellPrice(battleaxeprice,markdown)), "command":"battleaxesell"});
        menuobj=weaponshop;
      });
    });

    // This sword you can try out without owning it
    // If click on it can wield while in the weaponer then have to give it back
    var sword3= sword.clone();
    print("sword3"+sword3.scale.x.toString()+" "+sword3.children[0].scale.x.toString());
    copyQuaternion(sword3, sword);
    setWeaponWield(sword3, false, "sword");
    setValue(sword3,"sword",swordprice);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sword3,OPENWORLD.Room.getX(roomWeaponer),OPENWORLD.Room.getY(roomWeaponer),0.2,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    scene.add(sword3);
    // When on ground pick it up - get icon
    setGetObject(sword3,scaleselected: 1.1, scalenotselected: 1.1);// {scalenotselected:1.025, scaleselected:1.05})
    OPENWORLD.BaseObject.highlight(sword3,false);
    OPENWORLD.Room.setDistanceTrigger( roomWeaponer , dist:0.5);

    var haswielded=false;
    roomWeaponer.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        sword3.visible=!inventorynames.contains("sword");
        OPENWORLD.BaseObject.highlight(sword3,true);

        chatter=[
          "Want to try this sword?",
          "Tempered steel handle with double grip",
          "Can cut off two heads with one blow",
          "I've seen it",
          "Only 100 gold coins!",
          "Try to lift it",
          "Its huge"
        ];
        OPENWORLD.Mob.setSpeech(weaponer, chatter,  randwait:0, minwait:5, z: 80, width: 300, scale:0.4, delay:5);

      } else {
        if (haswielded) {
          // When you leave the weaponer the sword is taken off you if wielding it
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              sword3,383.42, 271.20 ,0.0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
          OPENWORLD.Actor.unwield(me,"Bip01_R_Hand");
          scene.add(sword3);
          setWeaponWield(sword3, false, "sword");
          haswielded=false;
          chatter=[
            "Hey you cant take it with you.",
            "Ill take that back"
          ];
          OPENWORLD.Mob.setSpeech(weaponer, chatter,  randwait:0, minwait:5, z: 80, width: 300, scale:0.4);

          removeInventory("sword");
          setState(() {
            weaponicon=defaultweaponicon;
          });
        }

      }
    });
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sword3,383.42, 271.20 ,0.0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);

    // If click on sword can wield it
    var swordbutton=dropWieldButton("sword",sword3, icon:"icons/sword.png", iconwield:"icons/sword2.png");
    sword3.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      print("trigger remove sword3");
      OPENWORLD.Sound.play( path: 'sounds/bag.mp3', volume: 0.2);
      OPENWORLD.BaseObject.highlight(sword3, false);
      scene.remove(sword3);
     // removeObject(obj);
      sword3.visible = true;
      OPENWORLD.Space.removeObjFromHide(sword3);
      setWeaponWield(sword3, true, "sword");
      OPENWORLD.Actor.wield(me, sword3, "Bip01_R_Hand");
      haswielded=true;
      addInventory("sword", swordbutton, getValue(sword3), objectid:"sword");
    });

    // The battleaxe you can buy
    var battleaxe=await OPENWORLD.Model.createModel('assets/models/battleaxe.glb');
    battleaxe.scale.set(0.01, 0.01, 0.01);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        battleaxe,OPENWORLD.Room.getX(roomWeaponer),OPENWORLD.Room.getY(roomWeaponer),0.0,4);
    setValue(battleaxe,"battleaxe",battleaxeprice);
    setGetObject(battleaxe);// {scalenotselected:1.025, scaleselected:1.05})
    OPENWORLD.BaseObject.highlight(battleaxe,false);
    var battleaxebutton=dropWieldButton("battleaxe",battleaxe, icon:"icons/battleaxe.png");
    // When on ground and pick up the helmet
    setPickupObject(battleaxe, "battleaxe", battleaxebutton,objectid:"battleaxe");


    // This is when you click on the get item in the menu
    // Buy and sell weapons
    weaponshop.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      print("triggermenu weaponshop "+event.action.toString());
      if (inventorynames.contains(event.action)) {
        OPENWORLD.Mob.setSpeech(weaponer, ["You already have one of those"], z: 80, width: 300, scale: 0.4);
      } else {
        var hasgiven = true;
        if (event.action == 'sword') {
          if (gold - getBuyPrice(swordprice, markup) < 0) {
            actorCannotBuy(weaponer);
            hasgiven = false;
          } else {
            addInventory("sword", swordbutton, swordprice, objectid: "sword");
            setGold(gold - getBuyPrice(swordprice, markup));
          }
        } else if (event.action == 'swordsell') {
          removeInventory("sword");
          setGold(gold + getSellPrice(swordprice, markdown));
        } else if (event.action == 'battleaxe') {
          if (gold - getBuyPrice(battleaxeprice, markup) < 0) {
            actorCannotBuy(weaponer);
            hasgiven = false;
          } else {
            addInventory("battleaxe", battleaxebutton, battleaxeprice,
                objectid: "battleaxe");
            setGold(gold - getBuyPrice(battleaxeprice, markup));
          }
        } else if (event.action == 'battleaxesell') {
          removeInventory("battleaxe");
          setGold(gold + getSellPrice(battleaxeprice, markdown));
        }
        if (hasgiven)
          giveAnimation(weaponer);
      }
    });

    // Trixie in room - only thing you can do is take the opium and sell it
    var roomTrixiehouse = OPENWORLD.Room.createRoom(394.900,296.430,
        soundpath: "sounds/home.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();

    OPENWORLD.Room.setAutoIndoors( roomTrixiehouse, true);
    scene.add( roomTrixiehouse );

    OPENWORLD.Room.setDistanceTrigger( roomTrixiehouse , minx:393.8, maxx:395.1, miny:295.2, maxy:296.9);//dist:0.5);

    // Trixie lying on bed with sexy pose
    trixie= await OPENWORLD.Actor.createActor('assets/actors/trixie.glb',
        shareanimations: armourer,
        action:"sexypose",
        duration:4,
        z: actoroffset);
    setDefaultActor(trixie);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        trixie ,OPENWORLD.Room.getX(roomTrixiehouse)-0.1, OPENWORLD.Room.getY(roomTrixiehouse)-0.6, 0.165, 2);
    OPENWORLD.Space.objTurn(trixie  ,0);  //n
    scene.add( trixie  );
    addcitizennpc(trixie,"trixie",true);
    OPENWORLD.BaseObject.setDistanceTrigger(trixie, dist: 2);
    trixie.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        chatter = ["You want me?",
          "My god, you are so good looking.",
          "I get lonely sometimes",
          "Lets party",
          "I don't know what to do with myself",
          "Im Trixie",
          "I'm not dirty."];
        OPENWORLD.Mob.setChatter(trixie, chatter, z: 80, width: 300, scale: 0.4);
      }
    }
    );

    // Opium on the bedstand
    var opium= await OPENWORLD.Model.createModel('assets/models/opium.glb');
    setValue(opium, "opium",50);
    opium.scale.set(0.002, 0.002, 0.002);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(opium,394.04, 295.84,0.25,4);
    scene.add(opium);
    setGetObject(opium, scalenotselected :1.1, scaleselected: 1.15);//,on:false);// {scalenotselected:1.025, scaleselected:1.05})
    var opiumbutton=dropButton("opium",opium, icon:"icons/opium.png");
    setPickupObject(opium, "opium", opiumbutton);

    // Candle in trixieehouse
    var trixielight= new THREE.PointLight(0xFFA500); //PointLight(0xffffff)
    trixielight.intensity = 1.0; // 0.6;
    trixielight.distance = 1.2;
    OPENWORLD.Light.addFlicker(trixielight);
    OPENWORLD.Light.addNightOnly(trixielight);
    scene.add(trixielight);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(trixielight,394.10, 295.83 ,0.25,4);//431.22, 276.84,2);
    var candle2 = await OPENWORLD.Sprite.cloneSprite(candle);//.loadSprite('assets/textures/candle.png', 0.015, 0.08,ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
    candle2,394.10, 295.83,0.25,4);//377.04, 280.52,0.05,4);//376.68, 281.48, 0.25, 4);
    scene.add(candle2);

    // This is the wondering citizen that starts close to the trixie house
    // Walks up and down lindos  in a loop
    var storemanii = await OPENWORLD.Actor.copyActor(storeman);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        storemanii ,393.03, 297.87, 0, 10);
    OPENWORLD.Space.objTurn(storemanii ,45);  //nw

    scene.add(storemanii );

    addcitizennpc(storemanii,"storemanii",true);

    OPENWORLD.BaseObject.setDistanceTrigger(storemanii, dist: 10, ignoreifhidden: false);
    storemanii.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        storemanii.visible = true;
        print("storeman start moveto again");
        OPENWORLD.Mob.moveToLoop(
            storemanii,
            [
              [387.26, 285.76, 0, 0.2],
              [386.05, 281.09, 0, 0.2],
              [381.72, 276.86, 0, 0.2],
              [378.29, 276.46, 0, 0.2],
              [379.32, 271.84, 0, 0.2],
              [383.69, 268.31, 0, 0.2],
              [382.22, 263.48, 0, 0.2],
              [383.65, 253.85, 0, 0.2],
             [ 385.76, 252.93, 0, 0.2],
              [388.13, 245.92, 0, 0.2],
             [ 389.64, 238.58, 0, 0.2],
            ],
            action: "walk",
            randomposition: true);
      } else {
        print("storeman outsidemoveto");
        // OPENWORLD.Space.worldToLocalSurfaceObj(guard2, 9.8,1.8, 0.14);
        //  print("guard guard hide");
        storemanii.visible = false;
      }
    });



    // This is the second wondering citizen wondering through lindos
    var smithyii = await OPENWORLD.Actor.copyActor(storeman,);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smithyii , 389.64, 238.58, 0, 4);
    OPENWORLD.Space.objTurn(smithyii ,45);  //nw

    scene.add(smithyii);
    addcitizennpc(smithyii,"smithyii",true);
    OPENWORLD.BaseObject.setDistanceTrigger(smithyii, dist: 10, ignoreifhidden: false);
    smithyii.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        //  print("guard visible");
        smithyii.visible = true;
        print("smithyii start moveto again");

        OPENWORLD.Mob.moveToLoop(
            smithyii,
            [
              [388.13, 245.92, 0, 0.2],
              [ 385.76, 252.93, 0, 0.2],
              [383.65, 253.85, 0, 0.2],
              [382.22, 263.48, 0, 0.2],
              [383.69, 268.31, 0, 0.2],
              [379.32, 271.84, 0, 0.2],
              [378.29, 276.46, 0, 0.2],
              [381.72, 276.86, 0, 0.2],
              [386.05, 281.09, 0, 0.2],
              [387.26, 285.76, 0, 0.2],
              [ 372.68,331.52,0,0.2]
            ],
            action: "walk",
            randomposition: true);
      } else {
        print("smithyii outsidemoveto");

        smithyii.visible = false;
      }
    });


    // This is the trixie who is in the street
    var roomTrixie = OPENWORLD.Room.createRoom(391.787,253.682,
        soundpath: "sounds/home.mp3",randomsoundpath: "sounds/trixie.mp3", randomsoundgap:50, volume: 0.2, exitroom: roomDefault); //THREE.Object3D();

    scene.add(roomTrixie );

    OPENWORLD.Room.setDistanceTrigger( roomTrixie , dist:1.5);

    var trixie3= await OPENWORLD.Actor.copyActor(trixie,  texture: "assets/actors/trixie3.jpg", action:"idle2");
    setDefaultActor(trixie3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        trixie3,392.69, 253.70,0,4);
    OPENWORLD.Space.faceObjectAlways(trixie3, camera);
    scene.add(trixie3);
    addcitizennpc(trixie3,"trixie3",true);


    OPENWORLD.BaseObject.setDistanceTrigger(trixie3, dist: 4);
    trixie3.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        chatter=["Hello there!",
          "Are you looking for some fun?",
          "Can I do anything for you?",
          "Nice weather, isn't it?",
          "What tickles your fancy?"
        ];

        OPENWORLD.Mob.setChatter( trixie3, chatter,  z: 80, width: 300, scale:0.4);
        OPENWORLD.Mob.randomwalk(trixie3, 0.5, 0.15, 0.1,
            action: "walk",
            actionduration: 0.7,
            stopaction: "idle2",
            reset: true
        );
      }
    });

    // This is the area near the stairs going up into the acropolis with the flute resident where you can take the flute
    var roomBareground = OPENWORLD.Room.createRoom(438.840,280.250,
        soundpath: "sounds/acropolis.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();

    roomBareground.extra['guide'] = [
      "This is the walkway",
      "up to the grand stoa",
      "where the Knights Hospitaller",
      "are based"
    ];

    scene.add(roomBareground  );

    OPENWORLD.Room.setDistanceTrigger( roomBareground  , dist:2);
    var fluteresident= await OPENWORLD.Actor.copyActor(citizen,  texture: "assets/actors/citizen12.jpg", action:"sittable");
    setDefaultActor(fluteresident);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fluteresident,439.33,280.35, 0, 4,lerpopacity: 1);
    OPENWORLD.Space.objTurn(fluteresident,0);  //w
    scene.add(fluteresident);
    addcitizennpc(fluteresident,"fluteresident",true);

    // Flute resident tells jokes and laughs at his own jokes
    OPENWORLD.BaseObject.setDistanceTrigger(fluteresident, dist: 1.5);
    fluteresident.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Mob.clearText(fluteresident);
        print("flute resident in");
        var wait = 8;
        chatter = [
          "Want to play my flute?",
          "Take it if you want",
          "I love jokes",
          "Want to hear one?",
          "You know Trixie, the lady of the night?",
          "She says to me 'This is your lucky night.",
          "I've got a game for you.",
          "I'll do anything you want for twenty florens.'",
          "So I say 'Hey, why not?'. So I pull out twenty florens and",
          "give it to trixie.",
          "Then I say to her slowly ",
          " 'Paint...my...house'"];
        OPENWORLD.Sound.play(path: "sounds/laugh.wav",
            volume: 0.2,
            delay: wait * chatter.length,obj:fluteresident);


        chatter += ["You think thats funny",
          "Hears another one",
          "I was having a meal at the smelly bottle restaurant and this",
          "lady is waiting at the door to be seated by the waitress.",
          "When the waitress arrives the waitress looks at the baby & says:",
          "'Ugh thats the ugliest baby ive ever seen.'",
          "The woman sits down at her table fuming and tells a stranger ",
          "sitting nearby that the waitress had just insulted her.",
          "The stranger says 'You just go right back to the waitress and",
          "tell her off. Go ahead - Ill hold your monkey for you.'"];
        OPENWORLD.Sound.play(path: "sounds/laugh2.wav",
            volume: 0.2,
            delay: wait * chatter.length,obj:fluteresident);
        OPENWORLD.Mob.setSpeech(fluteresident, chatter,  randwait:0, minwait:wait, z: 80, width: 300, scale:0.4);

      } else {
        OPENWORLD.BaseObject.clearAll(fluteresident);
        OPENWORLD.Mob.setSpeech(fluteresident, ['Great talking to you'],   z: 80, width: 300, scale:0.4);
      }
    });


    // Can take the flute next to the flute resident - can play the flute as well
    var fluteprice=50;
    var flute=await OPENWORLD.Model.createModel('assets/models/flute.glb');
    flute.scale.set(0.01, 0.01, 0.01);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
    flute,439.6,280.350,0.18,4);
    OPENWORLD.Space.objTurn(flute,315-90);
    scene.add(flute);
    setValue(flute,"flute",fluteprice);
    setGetObject(flute, scalenotselected: 1.1, scaleselected: 1.1);// {scalenotselected:1.025, scaleselected:1.05})

    var flutebutton=PopupMenuButton(
        color: Colors.black.withOpacity(0.2),
        child: ClipRRect(
    borderRadius: BorderRadius.circular(100),
    child: Image.asset(
    "icons/flute.png",
    //  width: inventoryiconwidth,
    fit: BoxFit.fitHeight,
    height: inventoryiconwidth,
    ),
    ),
      onSelected: (value) {
        if (value == "play") {
          //print("wield "+name);
          flute.visible=true;
          OPENWORLD.Space.removeObjFromHide(flute);
          setWeaponWield(flute, true, 'flute');

          OPENWORLD.Actor.wield(me, flute, "Bip01_R_Hand");
          if (!underSea())
            OPENWORLD.Sound.play( path: "sounds/flute.mp3", volume: 0.2);
          OPENWORLD.Actor.unwield(me,"Bip01_R_Hand", delay:7);
          setState(() {
            weaponicon=    "icons/flute.png";
          });
        } else  if (value == "drop") {
          setWeaponWield(flute, false,'flute');
          dropItem("flute", flute);
          setState(() {
            weaponicon=   defaultweaponicon;

          });

        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          value: "play",
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.front_hand),
              ),
              const Text(
                'Play',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "drop",
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.download),
              ),
              const Text(
                'Drop',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
    // When on ground and pick up the helmet
    setPickupObject(flute, "flute", flutebutton, objectid: "flute");


    // This is in the acropolis with the three knights including the postulant and training knight
    var roomGrandstoaii= OPENWORLD.Room.createRoom(431.060,273.420,
        soundpath: "sounds/acropolis.mp3", volume: 0.05,  randomsoundpath:"sounds/meow.mp3", randomsoundgap:30, exitroom: roomDefault); //THREE.Object3D();

    roomGrandstoaii.extra['guide'] = [
      "You are at the acropolis",
      "& this stoa was part",
      "of the temple of Athena Lindia",
      "which was completed around 300 BC.",
      "And this stoa was completed in the first century BC",
      "by the Greeks. It originally had a roof",
      "as part of a covered walkway",
      "& originally had 42 columns."
    ];

    scene.add(roomGrandstoaii );
    OPENWORLD.Room.setDistanceTrigger( roomGrandstoaii  , dist:1.5);

    // teacher knight
    knight22= await OPENWORLD.Actor.copyActor(knight2, texture: "assets/actors/knight22.jpg");
    setDefaultActor(knight22);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        knight22,430.8,274.1, 0, 4,lerpopacity: 1.0);

    OPENWORLD.Space.objTurn(knight22,180);
    scene.add(knight22);
    addknightnpc(knight22,"knight22");

    // This is the knights sword
    var sword4=sword.clone();
    sword4.extra=sword.extra;
    setWeaponWield(sword4, true, "sword");
    OPENWORLD.Actor.wield(knight22, sword4, "Bip01_R_Finger11");

    // If walk near the teacher knight will try to give you a lesson
    OPENWORLD.BaseObject.setDistanceTrigger(knight22, dist: 0.7);
    knight22.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        print("teacher in");

        OPENWORLD.Space.faceObjectAlways(knight22, camera);

        var wait=5;
        OPENWORLD.Actor.playActionThen(knight22, "bow", "idle",  duration:1, durationthen:2);
        chatter=["I'll give you a lesson if you like.",
          "Once your opponent is past your point, it is too difficult",
          "to clear your weapon and bring the point to bear again."];
        OPENWORLD.Actor.playActionThen(knight22, "wave", "idle",  duration:1, durationthen:2, delay:chatter.length*wait);

        chatter+=[
          "The long blades drag in the hand and even though they are",
          "made lightweight they exert a leverage that make them slow",
          "to respond to the hand."];
        OPENWORLD.Actor.playActionThen(knight22, "point", "idle",  duration:1, durationthen:2, delay:chatter.length*wait);

        chatter+=[
          "Also I dislike the dismissal of the cutting blow and",
          "subsequent reliance on thrusting only.",
          "A thrust is rarely a killing or incapacitating blow, ",
          "especially from a rapier, and so a wounded opponent is"
              "still a threat; possibly a greater threat.",
          "I disregard the view that the thrust is a faster blow by",
          "pointing because delivering a thrust or cut a swordsman's",
          "hand moves the same distance.",
          "The thrust may be turned aside with little effort whereas",
          "a blow must be warded with manly strength."];
        OPENWORLD.Actor.playActionThen(knight22, "nod", "idle",  duration:1, durationthen:2, delay:chatter.length*wait);

        chatter+=[  "I am critical of attitudes to duelling being taught in",
          "England by Foreign Masters. A major criticism is that they",
          "teach a man to seek duels readily for any real or",
          "imagined offence.",
          "This is what I mean."];


        OPENWORLD.Actor.playActionThen(knight22, "slash", "idle",  duration:1, durationthen:2, delay:chatter.length*wait);

        chatter+=["",
          "",
          "Phew. I'll sit down for a moment.",
        ];

        OPENWORLD.Actor.playActionThen(knight22, "sit", "sitidle",  duration:1, durationthen:2, delay:chatter.length*wait);

        OPENWORLD.Mob.setSpeech(knight22, chatter,  randwait:0, minwait:wait, z: 80, width: 300, scale:0.4);
      } else {
        print("teacher out");
        OPENWORLD.Space.faceObjectAlwaysRemove(knight22);
        OPENWORLD.Mob.setSpeech(knight22, ["Is my lesson boring you?", ],    z: 80, width: 300, scale:0.4);

      }
    });

    // Postulant sits their
    postulant= await OPENWORLD.Actor.copyActor(guard, texture: "assets/actors/knight13.jpg", action:"sitidle");
    setDefaultActor(postulant);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        postulant,431.42,273.7, 0, 4,lerpopacity: 1.0);

    OPENWORLD.Space.objTurn(postulant,270);
    scene.add(postulant);
    addknightnpc(postulant,"postulant");

    // knight3 used in quartersdoorway - the jobknight!
    Group knight3 =
    await OPENWORLD.Actor.createActor('assets/actors/knight3.glb',
        shareanimations: armourer,
        action:"sittableidle",
        z: actoroffset);
    setDefaultActor(knight3);

    // The other postlant sitting down
    var postulant2= await OPENWORLD.Actor.copyActor(knight3, texture: "assets/actors/knight32.jpg", action:"sitidle");
    setDefaultActor(postulant2);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        postulant2,431.4,274.1, 0, 4,lerpopacity: 1.0);

    OPENWORLD.Space.objTurn(postulant2,270);
    scene.add(postulant2);
    addknightnpc(postulant2,"postulant2");

    // Cat the can kill - just wonder around
    Group cat = await OPENWORLD.Actor.createActor('assets/actors/cat.glb',
        z:0);
    cat.scale.set(0.01,0.01,0.01);
    OPENWORLD.Space.objTurn(cat.children[0],0);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cat,OPENWORLD.Room.getX(roomGrandstoaii)+0, OPENWORLD.Room.getY(roomGrandstoaii)-0, 0, 4,lerpopacity: 1.0);

    OPENWORLD.Space.objTurn(cat,0);
    scene.add(cat);
    addnpc(cat, "cat", true,deathsoundpath: "sounds/catfight.mp3");
    OPENWORLD.BaseObject.setCustomTrigger(cat); //, dist: 1.5);
    cat.extra['customtrigger'].addEventListener(
        'deadtrigger', (THREE.Event event) {
          // Postulant is happy when you kill the cat
      OPENWORLD.Mob.setSpeech(postulant2, [ "Good job", "I never liked that cat!"], randwait:0, minwait:5, z: 80, width: 300,  scale:0.4);
      OPENWORLD.Sound.play( path: 'sounds/clap.mp3', volume: 1, delay:3);
      // Stop cat meowing once its dead
      OPENWORLD.Room.clearRandomSound(roomGrandstoaii);

    }
    );
    // Have cat wonder around stoa
    OPENWORLD.BaseObject.setDistanceTrigger(cat, dist: 4);
    cat.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        print("cat in");
        OPENWORLD.Mob.randomwalk(cat, 0.5, 0.15, 0.1,
            action: "walk",
            actionduration: 0.7,
            stopaction: "idle",
            reset: true
        );
      } else {
        print("cat out");
      }
    });

    // Have torch that a player can pick up and keep - shines at night
    var torch2= torch.clone();
    setValue(torch2,"torch", torchprice);
    var brandfire2 = new VolumetricFire(
        fireWidth, fireHeight, fireDepth, sliceSpacing, camera);
    await brandfire2.init();
    // _space.worldToLocalSurfaceObj(fire?.mesh, 7.0, 2.0, 0.33); //3.7);
    brandfire2.mesh.scale.x = 5; //0.05;
    brandfire2.mesh.scale.y = 5; //0.05;
    brandfire2.mesh.scale.z = 5; //0.05;
    brandfire2.mesh.position.x = 18;//0.25; //33;
    brandfire2.mesh.position.z = 8;//0.25; //33;
    OPENWORLD.Space.objPitch(brandfire2.mesh, -90);
    //scene.add(fire?.mesh);
    torch2.add(brandfire2.mesh);
;
    OPENWORLD.Updateables.add(brandfire2);
    var light2= new THREE.PointLight(0xFFA500); //PointLight(0xffffff)

    light2.intensity = 1.0; // 0.6;
    light2.distance = 1.2;
    light2.position.y = 0.33;
    OPENWORLD.Light.clock=clock;
    OPENWORLD.Light.addFlicker(light2);
    OPENWORLD.Light.addNightOnly(light2);
    torch2.add(light2);
    scene.add(torch2);

    // Need to set a position even if not adding to seen so when drop it can readd to hiddenobjects
    OPENWORLD.Space.worldToLocalSurfaceObjHide(torch2,432.60, 272.96,0.0,4);
    setGetObject(torch2, scalenotselected:1.2, scaleselected:1.3);

    var torchbutton2=dropWieldButton("torch", torch2, icon:"icons/torch.png");
    setPickupObject(torch2, "torch", torchbutton2,objectid:"torch");


    // This is the room of the jobknight
    roomQuartersdoorway= OPENWORLD.Room.createRoom(430.080,278.290,
        soundpath: "sounds/home.mp3", volume: 0.05); //THREE.Object3D();

    roomQuartersdoorway.extra['guide']=[
      "This is the Church of Saint John &"
      "was build in the 12th century AD.",
      "It has become the ",
      "Knights Hospitaller headquarters."
    ];

    OPENWORLD.Room.setAutoIndoors( roomQuartersdoorway, true);
    scene.add(roomQuartersdoorway );

    // Light in quarters
    var acropolislight= new THREE.PointLight(0xFFA500); //PointLight(0xffffff)
    acropolislight.intensity = 1.0; // 0.6;
    acropolislight.distance = 20;
    OPENWORLD.Light.addFlicker(acropolislight);
    OPENWORLD.Light.addNightOnly(acropolislight);
    scene.add(acropolislight);
    OPENWORLD.Space.worldToLocalSurfaceObj(acropolislight,429.43, 268.65 ,0.5);//431.22, 276.84,2);

    var brand=THREE.Group();
    var brandi= await OPENWORLD.Model.createModel('assets/models/flamingbrand.glb');

    brandi.scale.set(0.012, 0.012, 0.012);
    brand.add(brandi);
    scene.add(brand);

    brandfire = new VolumetricFire(
        fireWidth, fireHeight, fireDepth, sliceSpacing, camera);
    await brandfire.init();
    OPENWORLD.Updateables.add(brandfire);

    brandfire.mesh.scale.x = 0.04; //0.05;
    brandfire.mesh.scale.y = 0.04; //0.05;
    brandfire.mesh.scale.z = 0.04; //0.05;
    brandfire.mesh.position.y = 0.4; //33;
    brand.add(brandfire.mesh);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(brand,429.43, 268.65 ,0,6);//431.22, 276.84,2);


    OPENWORLD.Room.setDistanceTrigger( roomQuartersdoorway  , dist:0.5);
    // minx: -3.47, maxx: 10.1, miny: -12.4, maxy: -2.1);
    var donejob=await OPENWORLD.Persistence.get("donejob",def:false);//false;

    roomQuartersdoorway.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        // Show nod if haven't started job yet so can nod and start the job
        if (whistle&&!inventorynames.contains("card")&&!inventorynames.contains("receipt")&&!donejob) {
          Future.delayed(const Duration(milliseconds: 20000), () {
            setState(() {
              var dist=OPENWORLD.Space.getDistanceBetweenObjs(camera, jobknight);
              if (dist<2) {
                // If have left room dont show nod
                nod = true;
                print("nod true");
              }
            });
          });
        }  else if (!whistle)
          print("no whistle");
      } else {
        setState(() {
          print("nod false");
          nod =false;
        });
      }
    });

    var coatarms2 = coatarms.clone();//await OPENWORLD.Plane.loadPlane(
    OPENWORLD.Space.worldToLocalSurfaceObjHide(coatarms2,430.02, 280.40,0.8,4);
    OPENWORLD.Space.objTurn(coatarms2,100);
    scene.add(coatarms2);

    var banner2=banner.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        banner2,432.2, 276.80,0.7,4);
    OPENWORLD.Space.setTurnPitchRoll(banner2, 40,90,0);
    scene.add(banner2);

    // This is the order of the jobknight to give to the smithy for pants and greaves
    var card= await OPENWORLD.Model.createModel('assets/models/card.glb');
    card.scale.set(0.007, 0.007, 0.007);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(card,OPENWORLD.Room.getX(roomQuartersdoorway), OPENWORLD.Room.getY(roomQuartersdoorway),0.0,4);
    setGetObject(card,on:false);// {scalenotselected:1.025, scaleselected:1.05})

    givefunc()
    {
      if (OPENWORLD.You.room==roomArmourer) {
        print("give armourer");
        OPENWORLD.Actor.playActionThen(me,"hand","idle");

        if (inventorynames.contains("card")) {
          OPENWORLD.Space.faceObjectLerp(camera, armourer, 1);
          OPENWORLD.Actor.playActionThen(armourer, "hand", "idle2", duration:1, durationthen:2, delay:1.5);
          OPENWORLD.Mob.setSpeech(armourer, ["Thanks for the order.","I'll send to Gerard as soon as its ready", "Here is the receipt", "You should return it to him","at the acropolis"], randwait:0, minwait:5, z: 80, width: 300,  scale:0.4);
          OPENWORLD.Actor.playActionThen(armourer, "hand", "idle2", duration:1, durationthen:2, delay:15);
          removeInventory('card');
          var cardtext=['RECEIPT from the armourers for',
            'Leather pants',
            'Leather greaves.'];
          var cardbutton=dropReadButton("receipt", card,cardtext, icon:"icons/card2.png");
          setPickupObject(card, "receipt", cardbutton,objectid:"receipt");
          addInventory("receipt", cardbutton, 0);
        } else {
        }

      } else
        Fluttertoast.showToast(
            msg: "The armourer isn't here",
            toastLength: Toast.LENGTH_LONG);
    }
    var cardtext=['ORDER for the armourers',
      'Leather pants',
      'Leather greaves.',
      '',
      'Yours sincerely',
      'Gerard'];

    var cardbutton=dropReadButton("card", card,cardtext,extracustomlabel: "Give receipt",extracustomfunc: givefunc, icon:"icons/card.png");
    setPickupObject(card, "card", cardbutton, objectid: "card");

    jobknight=knight3;
    var jobknightx=430.53;//OPENWORLD.Room.getX(roomQuartersdoorway)+0.4;
    var jobknighty=278.81;//OPENWORLD.Room.getY(roomQuartersdoorway)+0.5;
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        jobknight,jobknightx, jobknighty, 0, 6,lerpopacity: 1.0);
    OPENWORLD.Space.objTurn(jobknight,180+45);  //sw
    scene.add(jobknight);
    addknightnpc(jobknight,"jobknight");

    var intakinghauberk=false;
    OPENWORLD.BaseObject.setDistanceTrigger(jobknight, dist: 0.9);
    jobknight.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      // if giving the player the initial greeting then dont offer jobs
      if (jobknight.extra.containsKey('ingreeting')&&jobknight.extra['ingreeting'])
        return;
      // If player trying to take hauberk dont offet job
      if (intakinghauberk)
        return;
      // If haven't got the whistle yet for amon then dont offer job
      if (!whistle)
        return;

      if (event.action) {
        print("jobknight in");
        var wait = 5;
        if (donejob) {
          // Player has completed the job
          OPENWORLD.Mob.setSpeech(jobknight, ['If we have any more jobs','come up Ill','let you know'], randwait: 0,
              minwait: wait,
              z: 80,
              width: 300,
              scale: 0.4);
        } else if (inventorynames.contains("receipt")) {
           // Player has got the receipt from the armourer so give the reward
            OPENWORLD.Mob.setSpeech(jobknight, ['Good job.',"I'll take that receipt off you", "from the armourer","Heres something for your trouble.", "Heres 100 gold","Ill let you know if theres more jobs going"], randwait: 0,
                minwait: wait,
                z: 80,
                width: 300,
                scale: 0.4);

            Future.delayed(const Duration(milliseconds: 20000), () {
              removeInventory("receipt");
            });
            giveAnimation(jobknight, delay: 10);
            giveAnimation(jobknight, delay: 20);
            setGold(gold+100, delay:20);
            donejob=true;
            OPENWORLD.Persistence.set("donejob",donejob);
          } else if (inventorynames.contains("card")) {
            // Player still has the order but still hasn't given to armourer
            OPENWORLD.Mob.setSpeech(jobknight, ['Hey, when are you going','to give the order','to the armourer?'], randwait: 0,
                minwait: wait,
                z: 80,
                width: 300,
                scale: 0.4);
          } else {
            // Offer the player the job
            chatter = ["Want to help us out?",
              "I have an order for some armour to be made at the",
              "armourers. If you could deliver the order to the",
              "armourer that'd be a great help. He'll give you",
              "a receipt and you can bring back to me and I'll",
              "be most grateful. You'll be doing a great",
              "service to Lindos.",
              "If you are interested 'nod' and I'll give you",
              "the order."];
            OPENWORLD.Mob.setSpeech(jobknight, chatter, randwait: 0,
                minwait: wait,
                z: 80,
                width: 300,
                scale: 0.4);

            if (!jobknight.extra.containsKey('nodtrigger')) {
              // When player nods give the player the order
              OPENWORLD.BaseObject.setCustomTrigger(jobknight); //, dist: 1.5);
              jobknight.extra['nodtrigger']=true;
              jobknight.extra['customtrigger'].addEventListener(
                  'nodtrigger', (THREE.Event event) {
                print("have nodded");
                OPENWORLD.Actor.playActionThen(
                    jobknight, "sittable", "idle2", backwards: true,
                    duration: 1,
                    durationthen: 2);
                giveAnimation(jobknight, delay: 3);
                addInventory("card", cardbutton, 0);
                setState(() {
                  nod=false;
                });
              }
              );
            }
          }

      } else {
        print("jobnkight out");
      }
    });

    // Hide dagger under bunk in quarters
    var daggerprice=50;
    var dagger=await OPENWORLD.Model.createModel('assets/models/knife.glb');
    dagger.scale.set(0.01, 0.01, 0.01);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        dagger,431.16, 275.86,0.0,4);
    scene.add(dagger);
    setValue(dagger,"dagger",daggerprice);
    setGetObject(dagger, scalenotselected:1.1, scaleselected:1.1);

    var daggerbutton=dropWieldButton("dagger",dagger,icon:"icons/dagger.png");
    // When on ground and pick up the dagger
    setPickupObject(dagger, "dagger", daggerbutton, objectid:"dagger");

    // Put book on bedside table
    var bookprice=50;
    var book=await OPENWORLD.Model.createModel('assets/models/book.glb');
    book.scale.set(0.004, 0.004, 0.004);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
    book,430.30,275.35,0.25,4);
    scene.add(book);
    setValue(book,"book",bookprice);
    setGetObject(book, scalenotselected:1.1, scaleselected:1.1);
    // OPENWORLD.BaseObject.highlight(dagger,false);
    var revelationstext=[
      "REVELATIONS",
      "And I stood upon the sand of the sea,",
      "and saw a beast rise up out of the sea,",
      "having seven heads and ten horns,",
      "and upon his horns ten crowns,",
      "and upon his heads the name of blasphemy.",
    ];
    var bookbutton=dropReadButton("book",book,revelationstext,icon:"icons/book.png");
    // When on ground and pick up the helmet
    setPickupObject(book, "book", bookbutton, objectid:"book");

    // Put rosary on chair
    var rosaryprice=0;
    var rosary = await OPENWORLD.Plane.loadPlane(
    "assets/textures/rosary.png", 0.11, 0.11, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(rosary,430.60,276.0,0.125,4);
    OPENWORLD.Space.setTurnPitchRoll(rosary, 0,90,0);
   // OPENWORLD.Space.objPitch(rosary,90);
    scene.add(rosary);
    setValue(rosary,"rosary",rosaryprice);
    setGetObject(rosary, scalenotselected:1.1, scaleselected:1.1, color:THREE.Color(0x000088));
    // OPENWORLD.BaseObject.highlight(dagger,false);
    var rosarytext=[
    "Our Father, Who art in heaven, Hallowed be Thy Name.",
    "Thy Kingdom come. Thy Will be done, on earth as it is in Heaven.",
    "Give us this day our daily bread.",
    "And forgive us our trespasses,",
    "as we forgive those who trespass against us.",
    "And lead us not into temptation, but deliver us from evil. Amen.",
    ];
    var rosarybutton=dropReadButton("rosary",rosary,rosarytext, icon:"assets/textures/rosary.png");
    // When on ground and pick up the helmet
    setPickupObject(rosary, "rosary", rosarybutton, objectid:"rosary");

    // Put hauberk next to jobknight
    var hauberk2=hauberk.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(hauberk2, 430.60,279.2,0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);

    OPENWORLD.Space.objTurn(hauberk2,-90+15);
    scene.add(hauberk2);
    OPENWORLD.BaseObject.setHighlight(hauberk2, scene, THREE.Color(0x0000ff), 1.0,  deselectopacity: 0.5);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(hauberk2, true, opacity:0.5);
    setGetObject(hauberk2,takelabel:"Take");

    // Job knight stops you from taking the hauberk
    hauberk2.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      print("triggermenu huaberk");
      intakinghauberk=true;
      OPENWORLD.Mob.pauseSpeech(jobknight);
      OPENWORLD.Mob.moveTo(jobknight,[[429.74, 278.78],[429.78, 278.37]] , action:"walk", stopaction:"idle");

      OPENWORLD.Mob.placeBeforeCamera(jobknight, 0.4, time:1, action:"walk", stopaction:"idle", delay:4);
      OPENWORLD.Mob.setSpeech(jobknight, ["Hey, thats not yours!"], z: 80, width: 300,  scale:0.4, delay:4);
      OPENWORLD.Space.faceObjectLerp(jobknight,hauberk2,0.3,delay:5+2);
      OPENWORLD.Space.faceObjectLerp(jobknight,camera,0.3,delay:8+2);
      Future.delayed(const Duration(milliseconds: 10000), () {
        intakinghauberk=false;
      });

    });

     // Why is there two hauberks?
    var hauberk3=hauberk.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(hauberk3, 428.54,280.53,0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);

    OPENWORLD.Space.objTurn(hauberk3,-90+15);
    scene.add(hauberk3);
    OPENWORLD.BaseObject.setHighlight(hauberk3, scene, THREE.Color(0x0000ff), 1.0,  deselectopacity: 0.5);//, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(hauberk3, true, opacity:0.5);
    setGetObject(hauberk3,takelabel:"Take");
    hauberk3.extra['touchtrigger'].addEventListener('triggermenu', (THREE.Event event) {
      print("triggermenu huaberk2");
      OPENWORLD.Mob.placeBeforeCamera(jobknight, 0.4, time:1, action:"walk", stopaction:"idle");
      OPENWORLD.Mob.setSpeech(jobknight, ["What the hell", "You can't take that"], z: 80, width: 300,  scale:0.4);
      OPENWORLD.Space.faceObjectLerp(jobknight,hauberk3,0.3,delay:5);
      OPENWORLD.Space.faceObjectLerp(jobknight,camera,0.3,delay:8);
    });

    // Picture of lady under bed
    var lady2=ladycard.clone();
    lady2.scale.set(0.008,0.008,0.008);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        lady2,429.02, 279.45,0.05,4);
    OPENWORLD.Space.objRoll(lady2,90);
    scene.add(lady2);

    // Put funny trixie message on wall
    var trixiesign =   await OPENWORLD.Plane.makeTextPlane("Trixie was here", fontSize:20, Colors.black, backgroundopacity: 0, width:300);//scale:0.01);//THREE.Color(0xff0000));
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        trixiesign,428.84, 279.15  , 0.4, 4);
    trixiesign.scale.set(0.1,0.1,0.1);
    OPENWORLD.Space.objTurn(trixiesign, -90);
    scene.add(trixiesign);

    // Grand stoa in acropolis outside of the quarters where you are dropped off by the horse
    var roomGrandstoa= OPENWORLD.Room.createRoom(428.580,275.840,
        soundpath: "sounds/acropolis.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();

    roomGrandstoa.extra['guide'] = roomGrandstoaii.extra['guide'] ;
    scene.add(roomGrandstoa  );

    // Jobknight comes out and greets you if you dont have a whistle to call Amon yet
    OPENWORLD.Room.setDistanceTrigger( roomGrandstoa  , dist:1.5);
    roomGrandstoa.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {

      if (event.action) {
        print("enter grand stoa room");
        if (whistle)
          return;
        jobknight.extra['ingreeting']=true;
        OPENWORLD.BaseObject.clearAll(jobknight);
        OPENWORLD.Actor.playActionThen(jobknight, "sittable", "idle2", backwards:true,  durationthen:2);
        var time= await OPENWORLD.Mob.moveTo(jobknight,[[431.01, 278.35,0,0.5],[429.47, 277.50,0,0.5]] , action:"walk", stopaction:"idle",delay:2);
        print("time jobknight"+time.toString());
        OPENWORLD.Mob.placeBeforeCamera(jobknight, 0.6, speed:0.2, action:"walk", stopaction:"idle", delay:time+0.2);
        OPENWORLD.Space.faceObjectAlways(jobknight, camera, delay:time+2);
        var chatter=[
          'Welcome, so good to see you.',
          'As Amon probably told you we need all the help we can get',
          'Theres a spy whos giving our enemies information',
          'about our military strength',
          'If you could go and keep your ears and eyes open',
          "And discover the traitor it'd really help us out.",
          'The spy must be someone who likes to watch our ',
          'military operations',
          'Please find the spy and catch him',
          'in the act of passing on the information'

        ];

        // Once finished speech give player a whistle
        var jobknighttime= await OPENWORLD.Mob.setSpeech(jobknight, chatter, randwait: 0,
            minwait: 5,
            z: 80,
            width: 300,
            scale: 0.4,delay:time+3);
        Timer t = Timer(Duration(milliseconds: ((jobknighttime )* 1000).round()), ()  {
          if (!whistle) {
            setState(()  {
              OPENWORLD.Actor.playActionThen(jobknight, "hand", "idle2");
              whistle=true;
              OPENWORLD.Persistence.set("whistle", whistle);
              OPENWORLD.Mob.setSpeech(jobknight,["Here's a whistle", "If you ever need help","Amon the guide will come & help you"], randwait: 0,
                  minwait: 5,
                  z: 80,
                  width: 300,
                  scale: 0.4);

            });
            OPENWORLD.Actor.playActionThen(jobknight, "wave", "idle2", delay:15);


            // Now walk jobknight back to seat now that given whistle
            Future.delayed(const Duration(milliseconds: 20000), ()
            async {
              OPENWORLD.BaseObject.clearAll(jobknight);
              // Sit the jobknight back down at his desk
              jobknight.extra['ingreeting'] = false;
              OPENWORLD.BaseObject.clearTimers(jobknight);
              OPENWORLD.Mob.clearText(jobknight);
              // var dist=OPENWORLD.Space.getDistanceBetweenObjs(jobknight,hauberk3);
              var jobknightpos = OPENWORLD.Space.localToWorldObj(jobknight);
              //  OPENWORLD.Room.getX(roomQuartersdoorway)+0.4, OPENWORLD.Room.getY(roomQuartersdoorway)+0.5
              var dist = OPENWORLD.Math.vectorDistance(
                  THREE.Vector3(jobknightpos.x, jobknightpos.y, 0),
                  THREE.Vector3(jobknightx, jobknighty, 0));
              print("jobknight dist moved" + dist.toString());
              var time;
              if (dist < 0.5) { // if haven't moved very far yet, then dont walk through desk
                print("jobknigth walk back");
                time = await OPENWORLD.Mob.moveTo(jobknight, [
                  [431.01, 278.35, 0, 0.5],
                  [jobknightx, jobknighty, 0, 0.5]
                ], action: "walk", stopaction: "idle", delay: 2);
              } else {
                print("jobknigth walk back around desk");
                time = await OPENWORLD.Mob.moveTo(jobknight, [
                  [429.47, 277.50, 0, 0.5],
                  [431.01, 278.35, 0, 0.5],
                  [jobknightx, jobknighty, 0, 0.5]
                ], action: "walk", stopaction: "idle", delay: 2);
              }
              OPENWORLD.Actor.playActionThen(
                  jobknight, "sittable", "sittableidle", durationthen: 2,
                  delay: time + 2);
              OPENWORLD.Space.objTurnLerp(
                  jobknight, 180 + 45, 1, delay: time + 2); //sw
            });
          }
        });
        OPENWORLD.BaseObject.addTimer(jobknight,t);  // so can clear it
      } else {
        // When leave the room have jobknigth sit back down
        var jobknightpos=OPENWORLD.Space.localToWorldObj(jobknight);
        var dist=OPENWORLD.Math.vectorDistance(THREE.Vector3(jobknightpos.x,jobknightpos.y,0),THREE.Vector3(jobknightx,jobknighty,0));
        if (dist>0.2) {

          print("out grand stoa room");
          OPENWORLD.BaseObject.clearAll(jobknight);
          // Sit the jobknight back down at his desk
          jobknight.extra['ingreeting'] = false;
          OPENWORLD.BaseObject.clearTimers(jobknight);
          OPENWORLD.Mob.clearText(jobknight);

          print("jobknight dist moved" + dist.toString());
          var time;
          if (dist <
              0.5) // if haven't moved very far yet, then dont walk through desk
            time = await OPENWORLD.Mob.moveTo(jobknight,
                [ [431.01, 278.35, 0, 0.5], [jobknightx, jobknighty, 0, 0.5]],
                action: "walk", stopaction: "idle", delay: 2);
          else
            time = await OPENWORLD.Mob.moveTo(jobknight, [
              [429.47, 277.50, 0, 0.5],
              [431.01, 278.35, 0, 0.5],
              [jobknightx, jobknighty, 0, 0.5]
            ], action: "walk", stopaction: "idle", delay: 2);
          OPENWORLD.Actor.playActionThen(
              jobknight, "sittable", "sittableidle", durationthen: 2,
              delay: time + 2);
          OPENWORLD.Space.objTurnLerp(
              jobknight, 180 + 45, 1, delay: time + 2); //sw
        }


      }
    });

    // Put a bottle on ground with hint that dagger is under the bunk in the quarters
    var bottleprice=5;
    var bottle2=bottle.clone();
    bottle2.scale.set(0.05, 0.05, 0.05);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bottle2,430.59,276.81,0,4,lerpopacity: 1.0);
    scene.add(bottle2);
    setValue(bottle2,"bottle",bottleprice);
    setGetObject(bottle2, scalenotselected: 1.1, scaleselected: 1.1);// {scalenotselected:1.025, scaleselected:1.05})

    var bottlebutton2=dropReadButton("bottle", bottle2, ["There is a note in the bottle. It reads:","'Note to self. Dagger is under the bunk'"],label:"Examine", icon:"icons/bottle.png");
    setPickupObject(bottle2, "bottle", bottlebutton2);


    // Give information about the propylaea if in this room
    var roomPropylaea= OPENWORLD.Room.createRoom( 431.09, 267.41,
    soundpath: "sounds/acropolis.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();
    roomPropylaea.extra['guide'] =  [
      "The Propylaea is a monumental stair case",
      "leading to the stoa below.",
      "It is part of the acropolis sanctury",
      "which was part of the temple of Athena Lindia",
    "that was finished around 300 BC.",
    "The Propylaea was built around that time too."
    ];
    scene.add(roomPropylaea );

    OPENWORLD.Room.setDistanceTrigger( roomPropylaea  , dist:4);

    // give information about the roman stoa if in this room
    var roomRomanstoa= OPENWORLD.Room.createRoom(  427.39, 261.71,
        soundpath: "sounds/acropolis.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();
    roomRomanstoa.extra['guide'] =  [
      "This is the Stoa of Psithyros & was built",
      "during the Roman period around 200 AD",
      "and is dedicated to the",
      "guiding spirit Psithyros."
    ];
    scene.add(roomRomanstoa );
    OPENWORLD.Room.setDistanceTrigger( roomRomanstoa  , dist:4);

    // This is where the quest is concluded where if you have spotted the journalist in the newsroom and at the beach then the journalist
    // will give information to the bandit about troops. When giving information kill the bandit and journalist and you've completed the quest and
    // you get a fanfare and a horse to ride around on
    var roomBandit= OPENWORLD.Room.createRoom(304.564,429.025,
        soundpath: "sounds/field.mp3", volume: 0.2, exitroom: roomDefault); //THREE.Object3D();

    roomBandit.extra['guide'] = [
      "Id stay away from here.",
      "There is something dodgy",
      "about this place",
    ];

    scene.add(roomBandit );

    OPENWORLD.Room.setDistanceTrigger( roomBandit  , dist:8);

    bandit= await OPENWORLD.Actor.copyActor(beggar,  texture: "assets/actors/citizen43.jpg", action:"idle2");//, texture: "assets/actors/knight32.jpg", action:"sitidle");

    OPENWORLD.Mob.setName(bandit,"bandit");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bandit,OPENWORLD.Room.getX(roomBandit), OPENWORLD.Room.getY(roomBandit), 0, 8);

    OPENWORLD.Space.objTurn(bandit,270);
    scene.add(bandit);

    loadedbandit=true;
    addnpc(bandit, "bandit", false, deathsoundpath:"sounds/die.mp3");

    var rockpos=[[305.35, 432.52],[ 307.93, 427.45],[301.63, 427.94]];
    var hidepos=[[304.93, 433.70],[308.96, 427.71], [300.79, 427.31]];
    var rockorig= await OPENWORLD.Model.createModel('assets/models/rock.glb');
    rockorig.scale.set(0.04, 0.04, 0.04);
    for (var pos in rockpos) {
      var rock=rockorig.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          rock, pos[0], pos[1], -0.2,
          10); //409.66, 328.47,0,4);
      scene.add(rock);
    }
    OPENWORLD.BaseObject.setDistanceTrigger(bandit, dist: 3);

    // Bandit runs away if jouranlist isn't coming to give info
    var hasfollowed=false;
    bandit.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        //duration:20,
        if (!journalist2beachseen) {
           // run away & hide
          runaway() {
            var worldpos = OPENWORLD.You.getWorldPos();
            worldpos.z = 0.0;
            var maxdist = -1.0;
            var maxind = -1;
            for (var i = 0; i < hidepos.length; i++) {
              var dist = OPENWORLD.Math.vectorDistance(
                  worldpos, THREE.Vector3(hidepos[i][0], hidepos[i][1], 0.0));
              if (dist > maxdist) {
                maxdist = dist;
                maxind = i;
              }
            }
            OPENWORLD.Space.faceObjectLerp(bandit, camera, 1);
            OPENWORLD.Mob.moveTo(
                bandit, [[hidepos[maxind][0], hidepos[maxind][1], 0, 0.5]],
                action: "walk",
                stopaction: "sitidle",
                delay: 1,
                surfaceonly: true);
            if (!hasfollowed) {
              OPENWORLD.Mob.setSpeech(
                  bandit, ["Simon?", " "], z: 80,
                  randwait: 0,
                  width: 300,
                  scale: 0.4);
              hasfollowed = true;
            } else {
              OPENWORLD.Mob.setSpeech(
                  bandit, ["Stop following me", " "], z: 80,
                  randwait: 0,
                  width: 300,
                  scale: 0.4);
            }
          }
          runaway();
          var t=Timer.periodic(Duration(seconds: 15), (timer) async {
            print("bandit timer");
            var dist=OPENWORLD.Space.getDistanceBetweenObjs(camera,bandit);
            if (dist<2)
              runaway();
          });
          OPENWORLD.BaseObject.addTimer(bandit,t);

        } else {
          // If journalist coming then attack player
          OPENWORLD.Mob.setSpeech(
              bandit, ["Stand and deliver", "Yadi Yadi", "Hoff"], z: 80,
              width: 300,
              delay: 5,
              scale: 0.4);
          actorAttack(bandit);
        }

      } else {
        print("trigger out bandit");
        OPENWORLD.BaseObject.clearTimers(bandit);


      }
    });

    // You can only kill the bandit when journalist is there otherwise tries to get away from you
    OPENWORLD.BaseObject.setCustomTrigger(bandit);//, dist: 1.5);
    bandit.extra['customtrigger'].addEventListener('strucktrigger', (THREE.Event event) {
      var dist=OPENWORLD.Space.getDistanceBetweenObjs(bandit,journalist2);
      if (dist<7) {
        var damage = getYouDamage();
        setActorHealth(bandit, getActorHealth(bandit) - damage);
        print("bandit hit"+getActorHealth(bandit).toString());
        //  OPENWORLD.Space.faceObjectLerp(npc,camera,1);
        if (getActorHealth(bandit) <= 0) {
          actorDie(bandit); //,diesoundpath:"sounds/die.mp3");
          OPENWORLD.BaseObject.disableDistanceTrigger(bandit);
          OPENWORLD.Mob.clearText(bandit);
          OPENWORLD.BaseObject.clearTimers(bandit);

          Future.delayed(const Duration(milliseconds: 5000), () {
            //
            actorAttack(journalist2);
          });
        }
      } else {
        print("bandit - journalist too far away"+dist.toString());
      }

    });


    // This is the sword that is on the ground and is near the bandit
    var  sword2= sword.clone();//await OPENWORLD.Model.createModel('assets/models/sword.glb');
    copyQuaternion(sword2, sword);

    setWeaponWield(sword2, false,"sword");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sword2,322.93, 390.61,0,10);//318.56, 391.90,0,10);//431.96,273.68,0.0,4);//409.66, 328.47,0,4);//408.75,327.88,0.1, 4);
    OPENWORLD.Space.objTurn(sword2,90);
    OPENWORLD.Space.objPitch(sword2.children[0],90);
    OPENWORLD.Space.objTurn(sword2.children[0],90);
    scene.add(sword2);
    setGetObject(sword2,  scaleselected: 1.1, scalenotselected: 1.1);

    // Put a parrot near sword so is more visible from a distance
    var deadparrot3 = await OPENWORLD.Sprite.cloneSprite(deadparrot);
    deadparrot3.scale.set(2.0,2.0,2.0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        deadparrot3,322.93+0.3, 390.61,0,10);//377.04, 280.52,0.05,4);//376.68, 281.48, 0.25, 4);
    scene.add(deadparrot3);

    var objectid="sword";
    var sword2button=dropWieldButton("sword",sword2, icon:"icons/sword.png");
    setPickupObject(sword2, "sword", sword2button,objectid:objectid);

    // Room that has the boat thats on the sea
    var roomBeach= OPENWORLD.Room.createRoom(407.021,324.839,
        soundpath: "sounds/surf.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();

    roomBeach.extra['guide'] = [
      "Here is a boat",
      "for people of Lindos",
      "to sail around as they please.",
      "Maybe you could use it"
    ];

    scene.add(roomBeach );

    OPENWORLD.Room.setDistanceTrigger( roomBeach  , dist:0.5);

    // Have dr have encourage player to try out the boat
    var drhector= await OPENWORLD.Actor.copyActor( citizen2);
    setDefaultActor(drhector);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
    drhector,409.07, 327.49, 0, 4);
    OPENWORLD.Space.faceObjectAlways(drhector, camera);
    scene.add(drhector);
    addcitizennpc(drhector,"drhector",true);

    OPENWORLD.BaseObject.setDistanceTrigger(drhector, dist: 3);
    // OPENWORLD.Space.objTurn(boat2 ,180);
    drhector.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Mob.setSpeech(
            drhector, ["Why not take her for a spin?"], z: 80,
            minwait: 5,
            randwait: 0,
            width: 300,
            scale: 0.4);
        OPENWORLD.Mob.setChatter(drhector, [
          "I once went round the Horn",
          "I like to tell salty tales",
          "I bought this Norwegian Blue parrot from the trading store",
          "My parrot isn't dead, its just stunned",
          "My bird hasn't moved since I bought it",
          "That journalist is always taking notes around here"
        ],  z: 80, width: 300, scale:0.4, delay:10);
      }
    });

    // put parrot on dr hectors shoulder
    var deadparrot2 = await OPENWORLD.Sprite.loadSprite(
        'assets/textures/parrot.png', 0.15, 0.09,
        ambient: false);// await OPENWORLD.Sprite.cloneSprite(deadparrot);

    deadparrot2.scale.set(100.0,100.0,100.0);
    deadparrot2.children[0].position.set(0.0,0.0,0.03);

    OPENWORLD.Actor.wield(drhector, deadparrot2 , "Bip01_L_Arm");//Bip01_R_Hand");

    // Load boat
    boat2= await OPENWORLD.Model.createModel('assets/models/boat2.glb');
    boat2.extra['name']='boat';
    boat2.scale.set(0.03, 0.03, 0.03);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        boat2 ,408.18, 328.47, 0, 20);
    boat2.children[0].extra['name']='boat2';

    scene.add(boat2);

    OPENWORLD.BaseObject.setDistanceTrigger(boat2, dist: 0.5);

    // If get near boat then sail it
    boat2.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        // When boatriding true then in animate() moves the boat along with the player and puts player above sea level
        boatriding=true;

        print("boat move forward"+OPENWORLD.You.getMoveDir().toString());

        // Move player forward into sea
        OPENWORLD.Space.objMoveAngleSurface(camera,OPENWORLD.You.getMoveDir(),2,0);//OPENWORLD.Camera.cameraoffset);

        OPENWORLD.BaseObject.disableDistanceTrigger(boat2);

      } else {

      }
    });

    // room with people digging and preparing for defence. This was originally a second job to give them a fixed shovel
    var roomDigging= OPENWORLD.Room.createRoom(673.399,546.944,
        soundpath: "sounds/surf.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomDigging.extra['guide'] = [
      "Due to the coming",
      "invasion from Sulamein",
      "extra fortifications are being",
      "built"
    ];

    scene.add(roomDigging );

    OPENWORLD.Room.setDistanceTrigger( roomDigging  , dist:4.0);

    Group shoveler =
    await OPENWORLD.Actor.createActor('assets/actors/shoveler.glb',
        shareanimations: armourer,
        action:"shovel",
        z: actoroffset);
    setDefaultActor(shoveler );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        shoveler ,672.72,543.83, 0, 4);
    OPENWORLD.Space.objTurn(shoveler  ,90);  //e
    scene.add( shoveler );
    addcitizennpc(shoveler,"shoveler",true);


    var shoveler2= await OPENWORLD.Actor.copyActor(shoveler, texture: "assets/actors/shoveler2.jpg", action:"shovel", randomduration: 0.1);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        shoveler2,670.67,543.69,0,4);
    OPENWORLD.Space.objTurn(shoveler2,90);
    scene.add(shoveler2);
    addcitizennpc(shoveler2,"shoveler2",true);
    OPENWORLD.BaseObject.setDistanceTrigger(shoveler2, dist: 4);
    shoveler2.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Mob.setChatter(shoveler2, [
          "What's keeping the Knight Prefect?",
          "He should be sending someone over with new handle.",
          "This pile never gets smaller",
          "Ive been digging all day",
          "Theres a bandit east of here. Be careful of him"
        ], z: 100, width: 400);
      }
    });

    var citizeniii= await OPENWORLD.Actor.copyActor(citizen, action:"idle2");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizeniii,671.17,545.19, 0, 4);
    OPENWORLD.Space.objTurn(citizeniii,0);
    scene.add(citizeniii);
    addcitizennpc(citizeniii,"citizeniii",true);

    OPENWORLD.Space.faceObjectAlways(citizeniii, camera);
    OPENWORLD.BaseObject.setDistanceTrigger(citizeniii, dist: 4);
    citizeniii.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        OPENWORLD.Mob.setChatter(citizeniii, [
          "You know when you dig have your knees 45°",
          "Hold the shovel handle with two hands",
          "Put your back into it",
          "These holes arent going to dig themselves",
          "Weve got to build up our defences against Sulamein"], z: 100,
            width: 400);
      }
    });

    // If attack any citizen then each one will join in to kill you
    // All join in if any killed
    cleobusAttack(who)
    {
      var done=false;  // only attack one at a time
      if (who!=shoveler&&!actorIsDead(shoveler)) {
        actorAttack(shoveler);
        OPENWORLD.Mob.setSpeech(shoveler, [
          "Murderer!","You killed my friend"], z: 80, width: 300,  scale:0.4, randwait:0, minwait:5);
        done=true;
      }
      if (!done&&who!=shoveler2&&!actorIsDead(shoveler2)) {
        actorAttack(shoveler2);
        OPENWORLD.Mob.setSpeech(shoveler2, [
          "You'll pay now"], z: 80, width: 300,  scale:0.4, randwait:0, minwait:5);

        done=true;
      }
      if (!done&&who!=citizeniii&&!actorIsDead(citizeniii)) {
        actorAttack(citizeniii);
        OPENWORLD.Mob.setSpeech(citizeniii, [
          "How dare you"], z: 80, width: 300,  scale:0.4, randwait:0, minwait:5);

      }
    }

    shoveler.extra['customtrigger'].addEventListener(
        'deadtrigger', (THREE.Event event) {
       cleobusAttack(shoveler);
    }
    );
    shoveler2.extra['customtrigger'].addEventListener(
        'deadtrigger', (THREE.Event event) {
      cleobusAttack(shoveler2);
    }
    );
    citizeniii.extra['customtrigger'].addEventListener(
        'deadtrigger', (THREE.Event event) {
      cleobusAttack(citizeniii);
    }
    );

    // Show cannons that are used for defence
    var cannonorig= await OPENWORLD.Model.createModel('assets/models/cannon.glb');
    cannonorig.scale.set(0.005, 0.005, 0.005);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cannonorig,668.80, 542.78,0,8);
    scene.add(cannonorig);

    var cannon4= cannonorig.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cannon4,674.80, 545.43,0,8);
    scene.add(cannon4);


    // This used to be a room that had an armourer, weapon and general store all in one but now just has a knight jumping
    var roomFieldTent= OPENWORLD.Room.createRoom(373.500,334.056,
        soundpath: "sounds/fire.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomFieldTent.extra['guide'] = [
      "Here is a basic field",
      "tent for Knights Hospitaller",
      "in case of a battle",
    ];

    scene.add(roomFieldTent);

    OPENWORLD.Room.setDistanceTrigger( roomFieldTent  , dist:0.5);

    var postulant3= await OPENWORLD.Actor.copyActor(postulant,  action:"sitidle");

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        postulant3,371.57, 331.48, 0, 4);  //371.67, 331.39,

    OPENWORLD.Space.objTurn(postulant3,50);
    scene.add(postulant3);
    addknightnpc(postulant3,"postulant3");
    OPENWORLD.BaseObject.setDistanceTrigger(postulant3, dist: 1);
    var hasjumpedtick=-1;
    var issitting=true;
    // Show startled knight jump up when you get near
    postulant3.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
          if (OPENWORLD.System.currentMilliseconds()-hasjumpedtick<60*1000)
            return;

          OPENWORLD.Actor.playActionThen(
              postulant3, "jump", "idle", duration: 1);
          if (OPENWORLD.System.currentMilliseconds()-hasjumpedtick>5*60*1000)
            chatter=[
            "Oh no",
            "I thought you were our commander",
            "checking up on me",
            "I wasnt sleeping.",
            "I was just resting my eyes"
          ];
          else
            chatter=[
              "Youve got to stop doing that.",
              "Sneaking up on me.",
              "If the knight commander",
              "thinks Im sleeping he'll",
              "put me in the stockade"
            ];
          OPENWORLD.Mob.setSpeech(
              postulant3, chatter, z: 80,
              minwait: 5,
              randwait: 0,
              width: 300,
              scale: 0.4);
          OPENWORLD.Sound.play(path: "sounds/jump.mp3", volume: 0.2);
         // hasjumped=true;
          hasjumpedtick=OPENWORLD.System.currentMilliseconds();
          issitting=false;
      } else {
        if (!issitting) {
          issitting = true;
          OPENWORLD.Actor.playActionThen(
              postulant3, "sit", "sitidle", durationthen: 2, delay: 4);
        }
      }
    });


    // This is the room with kindling that you can take to the smithy for money
    var roomKindling= OPENWORLD.Room.createRoom(197.269,114.397,
        soundpath: "sounds/field.mp3", volume: 0.05, exitroom: roomDefault);

    roomKindling.extra['guide'] = [
      "Ahh kindling.",
      "I know the smithy",
      "is always begging for kindling.",
    ];
    scene.add(roomKindling);
    OPENWORLD.Room.setDistanceTrigger( roomKindling  , dist:4);

    // Create three bundles of kindling you can take
    var kindlingorig= await OPENWORLD.Model.createModel('assets/models/kindling.glb');
    kindlingorig.scale.set(0.04, 0.04, 0.04);
    OPENWORLD.Space.objPitch(kindlingorig,-15);

    for (var i=0; i<3; i++) {
      var kindling=kindlingorig.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          kindling, OPENWORLD.Room.getX(roomKindling)+4*(OPENWORLD.Math.random()-0.5),
          OPENWORLD.Room.getY(roomKindling)+4*(OPENWORLD.Math.random()-0.5), -0.0, 15); //3.42);
      scene.add(kindling);
      setGetObject(kindling,);
      kindling.extra['touchtrigger'].addEventListener(
          'triggermenu', (THREE.Event event) {
        print("triggermenu kindling");
        OPENWORLD.BaseObject.highlight(kindling, false);
        scene.remove(kindling);

        // When you take the kindling play a shot gun sound in the distance that damages players health slightly
        var delay=12*OPENWORLD.Math.random()+4;
        OPENWORLD.Sound.play( path: 'sounds/shotgun.mp3', volume: 1, delay:delay);
        OPENWORLD.Sound.play( path: 'sounds/hey.mp3', volume: 0.8, delay:delay+5);

        Future.delayed(Duration(milliseconds: delay.round()), () {
          setHealth(health*0.9);
        });
        var button=dropButton("kindling",kindling, icon:"assets/textures/kindling.png");

        addInventory("kindling", button, kindlingprice);
      });
    }


    //  Sheep between lindos and the acropolis
    var roomSheep= OPENWORLD.Room.createRoom(414.479,260.357,
        soundpath: "sounds/field.mp3", volume: 0.05, randomsoundpath:"sounds/bah.mp3", randomsoundgap:50, exitroom: roomDefault); //THREE.Object3D();

    scene.add(roomSheep );

    var sheperd =await OPENWORLD.Actor.copyActor(  prisoner25, action:"idle2");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheperd,OPENWORLD.Room.getX(roomSheep)+0.3, OPENWORLD.Room.getY(roomSheep)-0.7, 0.05, 4);
    scene.add(sheperd);
    sheperd.visible=false;

    // If stand still for too long near sheep the sheperd arrives and tells you off
    // If you continue to stand there the sheperd will attack you
    OPENWORLD.Room.setDistanceTrigger( roomSheep  , dist:8);
    roomSheep.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        print("in sheep");

        var lastpos=OPENWORLD.You.getWorldPos();

        var t=Timer.periodic(Duration(seconds: 10), (timer) async {
          var worldpos=OPENWORLD.You.getWorldPos();
          if (worldpos.x==lastpos.x&&worldpos.y==lastpos.y) {
            print("lingerd");

            OPENWORLD.BaseObject.clearTimers(roomSheep);
            OPENWORLD.Space.placeBeforeCamera(sheperd, 5,offset:5);
            sheperd.visible=true;
            OPENWORLD.Mob.placeBeforeCamera(
                sheperd, 0.6, time:6, action: "walk", stopaction: "idle2", offset:0.2);
            OPENWORLD.Mob.setSpeech(sheperd, [
              "Hey, I know what you're up to",
            "They're my sheep",
            "Leave them alone"], z: 80, width: 300,  scale:0.4, randwait:0, minwait:5, delay:7);
            Future.delayed(Duration(milliseconds: (20*1000).round()), () {
              if (worldpos.x==lastpos.x&&worldpos.y==lastpos.y) {
                OPENWORLD.Mob.setSpeech(sheperd, [
                  "You must be deaf"], z: 80, width: 300,  scale:0.4, randwait:0, minwait:5, delay:7);
                addnpc(sheperd,"sheperd",false);
                actorAttack(sheperd);
              }
            });
          } else {
            print("not lingerd");
            lastpos=worldpos;

          }


        });
        OPENWORLD.BaseObject.addTimer(roomSheep,t);
      } else {
        print("out sheep");
         OPENWORLD.BaseObject.clearTimers(roomSheep);
        sheperd.visible=false;
      }
    });

    // Create three sheep that wonder around
    Group sheeporig =
    await OPENWORLD.Actor.createActor('assets/actors/sheep.glb', shareanimations: dog
    );
    sheeporig.scale.set(0.005,0.005,0.005);
    for (var i=0; i<3; i++) {
      var sheep = await OPENWORLD.Actor.copyActor(sheeporig);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep,
          OPENWORLD.Room.getX(roomSheep) + 5 * (OPENWORLD.Math.random() - 0.5),
          OPENWORLD.Room.getY(roomSheep) + 5 * (OPENWORLD.Math.random() - 0.5),
          0, 5);
      OPENWORLD.Space.objTurn(sheep.children[0], 0);
      //  OPENWORLD.Space.objTurn(crab  ,90);  //e
      scene.add(sheep);
      addnpc(sheep, "sheep", true, deathsoundpath: "sounds/bah.mp3");
      OPENWORLD.BaseObject.setDistanceTrigger(sheep, dist: 5);
      sheep.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
        if (event.action) {
          OPENWORLD.Mob.randomwalk(sheep, 5, 0.05, 0.3,
              action: "walk",
              actionduration: 1,
              stopaction: "idle",
              reset: true
          );
        }
      });
    }

    // This is the sheep between the beach and lindos
    var roomSheep3= OPENWORLD.Room.createRoom(393.97, 316.09,
        soundpath: "sounds/field.mp3", volume: 0.05, randomsoundpath:"sounds/bah.mp3", randomsoundgap:50, exitroom: roomDefault); //THREE.Object3D();

    scene.add(roomSheep3 );
    OPENWORLD.Room.setDistanceTrigger( roomSheep3  , dist:8);

    // Create three sheep but there is no sheperd
    for (var i=0; i<3; i++) {
      var sheep = await OPENWORLD.Actor.copyActor(sheeporig);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep,
          OPENWORLD.Room.getX(roomSheep3) + 5 * (OPENWORLD.Math.random() - 0.5),
          OPENWORLD.Room.getY(roomSheep3) + 5 * (OPENWORLD.Math.random() - 0.5),
          0, 5);
      OPENWORLD.Space.objTurn(sheep.children[0], 0);

      scene.add(sheep);
      addnpc(sheep, "sheep", true,deathsoundpath: "sounds/bah.mp3");
      OPENWORLD.BaseObject.setDistanceTrigger(sheep, dist: 5);
      sheep.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
        if (event.action) {
          OPENWORLD.Mob.randomwalk(sheep, 5, 0.05, 0.3,
              action: "walk",
              actionduration: 1,
              stopaction: "idle",
              reset: true
          );
        }
      });
    }

    // This is the room for the wild dog in the wilderness
    var roomWildDog= OPENWORLD.Room.createRoom(123.096,512.404,
        soundpath: "sounds/field.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    scene.add(roomWildDog);
    Group wilddog = await OPENWORLD.Actor.createActor('assets/actors/wilddog.glb',
      shareanimations: dog,
      duration:3
    );
    wilddog.scale.set(0.005,0.005,0.005);
    OPENWORLD.Space.objTurn(wilddog.children[0],0);

    // If you get too near the wild dog it will attack you
    var wildpos=[OPENWORLD.Room.getX(roomWildDog)+5*(OPENWORLD.Math.random()-0.5), OPENWORLD.Room.getY(roomWildDog)+5*(OPENWORLD.Math.random()-0.5)];
    var wilddir=0.0;
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        wilddog,wildpos[0],wildpos[1] , 0,8);
    OPENWORLD.Space.objTurn(wilddog,wilddir);
    scene.add(wilddog);
    addnpc(wilddog, "wilddog", true,deathsoundpath: "sounds/yelp.mp3");
    OPENWORLD.BaseObject.setDistanceTrigger(wilddog, dist: 1);
    // OPENWORLD.Space.objTurn(boat2 ,180);
    wilddog.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        Future.delayed(Duration(milliseconds: (OPENWORLD.Math.random()*5000).round()), () {
          actorAttack(wilddog,attackaction: "attack");
        });

      }
    });

    // If at a distance from the dog then will urinate or eat the meat
    OPENWORLD.Room.setDistanceTrigger( roomWildDog  , dist:10);
    roomWildDog.extra['trigger'].addEventListener('trigger', (THREE.Event event) async {
      if (event.action) {
        var t=Timer.periodic(Duration(seconds: 15), (timer) {
          if (OPENWORLD.Math.random()<0.2)
            OPENWORLD.Actor.playActionThen(wilddog, "urinate", "idle", delay:OPENWORLD.Math.random()*15);
          else
            OPENWORLD.Actor.playActionThen(wilddog, "eat", "idle", delay:OPENWORLD.Math.random()*15);

        });
        OPENWORLD.BaseObject.addTimer(wilddog,t);
      } else {
        OPENWORLD.BaseObject.clearTimers(wilddog);

      }
    });

    // Put meat in front of wild dog
    var meatpos=OPENWORLD.Math.vectorMoveFoward(wildpos[0], wildpos[1],wilddir,0.18);
    var meat2= meat3.clone();

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        meat2,meatpos.x,meatpos.y,0,6);
    scene.add(meat2);

    // This is the cannon near the beach where the journalist comes and takes notes
    // Here a knight is firing off a cannon into the sea for practice
    var roomCannon= OPENWORLD.Room.createRoom(467.69, 351.81,
        soundpath: "sounds/field.mp3", volume: 0.05, exitroom: roomDefault); //THREE.Object3D();
    roomCannon.extra['guide'] = [
      "Here is a battery",
      "that keeps Lindos safe.",
      "It is the front line of",
      "defense for Lindos",
      "Sulamein would love to know",
      "more about this place"
    ];

    scene.add(roomCannon);

    OPENWORLD.Room.setDistanceTrigger( roomCannon , dist:0.5);

    var cannon= cannonorig.clone();//await OPENWORLD.Model.createModel('assets/models/cannon.glb');
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cannon,467.77, 355.13,0,8);
    OPENWORLD.Space.objTurn(cannon,0);
    scene.add(cannon);

    var cannonballs= await OPENWORLD.Model.createModel('assets/models/cannonballs.glb');
    cannonballs.scale.set(0.01, 0.01, 0.01);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cannonballs,469.84, 353.82,0,6);
    OPENWORLD.Space.objTurn(cannonballs,0);
    scene.add(cannonballs);
    var cannonballs2= cannonballs.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(cannonballs2, 473.92, 351.86,0,8);
    scene.add(cannonballs2);
    var cannonballs3= cannonballs.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(cannonballs3, 468.32, 354.91,0,8);
    scene.add(cannonballs3);

    var cannon2= cannon.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cannon2,470.60, 354.04,0,8);
    scene.add(cannon2);

    // This is the flash from the cannon when fired
    var fired = await OPENWORLD.Plane.loadPlane(
        "assets/models/cannonfired.png", 100*0.6, 100*0.32, ambient: false, doublesided:true);//, z:1);

    OPENWORLD.Space.objTurn(fired.children[0],90);
    fired.children[0].position.y=35.0;
    fired.children[0].position.z=75.0;
    cannon2.add(fired);
    fired.visible=false;

    // This is the splash you see in the sea when the cannon is fired
    var splash = await OPENWORLD.Sprite.loadSprite(
        "assets/models/cannonsplash.png", 0.6, 1.2, ambient: false);//, z:1);
    OPENWORLD.Space.worldToLocalSurfaceObj(
         splash,476.31, 371.05, 0.47);
    splash.position.y=0.0;
    scene.add(splash);
    splash.visible=false;



    var knight23= await OPENWORLD.Actor.copyActor(knight2, texture: "assets/actors/knight22.jpg");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        knight23,470.51, 353.81,0,6);
    scene.add(knight23);
    addknightnpc(knight23,"knight23");

    var splashpos=[472.31, 368.0];
    OPENWORLD.BaseObject.setDistanceTrigger(knight23, dist: 4);
    // When get near the knight he fires the cannon periodically
    knight23.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
        chatter=[
          "Boom goes the dynamite",
          "That journalist is always around making notes",
          "Ive been firing at the buoy all day & always miss",
          "Its the cannon, not me thats missing",
          "Must be faulty cannon balls is why I miss all day"];
        OPENWORLD.Mob.setSpeech(knight23, chatter, z: 80, width: 300,  scale:0.4, randwait:10, minwait:5, delay:OPENWORLD.Math.random()*30);

        var t=Timer.periodic(Duration(seconds: 5), (timer) {
          print("cannon off");
          OPENWORLD.Actor.playActionThen(knight23, "hand", "idle", duration:0.5, durationthen:2);//, delay:5);
          OPENWORLD.Sound.play( path: 'sounds/cannon.mp3', volume: 1, delay:0.8);
          OPENWORLD.Space.objForwardLerp(cannon2, 0.1, 0.2, delay:0.7);
          OPENWORLD.BaseObject.setVisible(fired,true,delay:0.8);
          OPENWORLD.Space.objForwardLerp(cannon2, -0.1,0.3, delay:0.9);
          OPENWORLD.BaseObject.setVisible(fired,false,delay:0.9);
          OPENWORLD.Texture.flipx(splash, OPENWORLD.Math.random()>0.5);
          OPENWORLD.Space.worldToLocalSurfaceObj(
              splash,splashpos[0]+4*(OPENWORLD.Math.random()-0.5), splashpos[1]+4*(OPENWORLD.Math.random()-0.5), 0);
          splash.position.y=-OPENWORLD.Math.random()*0.2;
          splash.scale.set(OPENWORLD.Math.random()*0.2+0.8,OPENWORLD.Math.random()*0.2+0.8,1.0);
          OPENWORLD.BaseObject.setVisible(splash,true,delay:1.3);
          OPENWORLD.BaseObject.setVisible(splash,false,delay:1.7);
        });
        OPENWORLD.BaseObject.addTimer(knight23,t);

      } else {
        print("trigger out knight");
        OPENWORLD.BaseObject.clearTimers(knight23);

      }
    });

    // Put buoy in sea where the knight is trying to hit in the distance
    var buoy = await OPENWORLD.Sprite.loadSprite(
        'assets/textures/buoy.png', 0.2, 0.2,
        ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObj(
        buoy,splashpos[0], splashpos[1],0);
    buoy.position.y=0.0; // sea level
    scene.add(buoy);

    var cannon3= cannon.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cannon3,473.87, 352.38,0,8);
    scene.add(cannon3);


    // This is the man walking along north and south between the bandit and lindos
    // Originally was going to be a sheperd with sheep but is just a man walking
    // He gives hint to player that the band is north
    var roomSheep2= OPENWORLD.Room.createRoom(363.45, 314.27,
        soundpath: "sounds/field.mp3", volume: 0.05,  exitroom: roomDefault); //THREE.Object3D();
    scene.add(roomSheep2 );
    OPENWORLD.Room.setDistanceTrigger( roomSheep2  , dist:8);

    var sheperd2 =await OPENWORLD.Actor.copyActor(  prisoner25, action:"idle2");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheperd2,OPENWORLD.Room.getX(roomSheep2), OPENWORLD.Room.getY(roomSheep2), 0.0, 20);
    scene.add(sheperd2);
    OPENWORLD.Texture.setEmissive(sheperd2, THREE.Color(0x222222));  // Make sheperd stand out more

    addcitizennpc(sheperd2,"sheperd2",true);  // can be killed
    OPENWORLD.BaseObject.setDistanceTrigger(sheperd2, dist: 20, ignoreifhidden: false);
    sheperd2.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {

        sheperd2.visible = true;
        print("sheperd2 start moveto again");
        OPENWORLD.Mob.moveToLoop(
            sheperd2,
            [  [363.45, 314.27, 0, 0.2],
            [356.20, 325.89, 0, 0.2],
            [348.76, 338.22, 0, 0.2],
            [342.44, 348.70, 0, 0.2],
            [335.82, 364.70, 0, 0.2],

            ],
            action: "walk",
            randomposition: true,
            surfaceonly:true);
        // Randomly turn to you and warn about the bandit
        var t=Timer.periodic(Duration(seconds: 5), (timer) {
           if (OPENWORLD.Math.random()<0.1) {
             // get turn and put it back
             var turn=OPENWORLD.Space.getObjTurn(sheperd2);
             OPENWORLD.Space.faceObjectLerp(sheperd2,bandit,1);
             OPENWORLD.Space.faceObjectLerp(sheperd2,camera,5,delay:2);
             OPENWORLD.Actor.playActionThen(
                 sheperd2, "point", "walk");

             // Warn the player about the bandit
            OPENWORLD.Mob.setSpeech(sheperd2, [
               "Dont go that way.",
               "Theres a dangerous bandit.",
               "I sometimes see him up there with",
               "someone with a red hat.",
               ], z: 80, width: 300,  scale:0.4, randwait:0, minwait:5);
             OPENWORLD.Space.objTurnLerp(sheperd2, turn, 1, delay:10);

             // face bandi
           }
        });
        OPENWORLD.BaseObject.addTimer(sheperd2,t);
      } else {
        print("shepered outsidemoveto");

        OPENWORLD.BaseObject.clearTimers(sheperd2);
        OPENWORLD.Mob.clearText(sheperd2);

        sheperd2.visible = false;
      }

    });


    resetYou();

    // Set position from last time
    var firstime;
    if (await OPENWORLD.Persistence.get("posx") != null) {
      firstime=false;
      var x = await OPENWORLD.Persistence.get(
          "posx");
      var y = await OPENWORLD.Persistence.get(
          "posy");
      OPENWORLD.Space.worldToLocalSurfaceObj(
          camera, x!, y!, OPENWORLD.Camera.cameraoffset); //home temple
      var turn=await OPENWORLD.Persistence.get("turn",def:0);
     //   print("pers turn"+turn.toString());
      OPENWORLD.Camera.setTurn(turn);
    } else {
      // If first time put player at intro
      print("Using default position");
      firstime=true;
     //OPENWORLD.Space.worldToLocalSurfaceObj(
     //    camera,  380,339,OPENWORLD.Camera.cameraoffset);  // beach -74,-57
    //  OPENWORLD.Space.worldToLocalSurfaceObj(
    //      camera,  390.33, 346.57,OPENWORLD.Camera.cameraoffset);  // sea

   // OPENWORLD.Space.worldToLocalSurfaceObj(
   //   camera,  384.58, 253.71,OPENWORLD.Camera.cameraoffset);  // lindos bunks - homeroom
  // OPENWORLD.Space.worldToLocalSurfaceObj(
  //      camera,  426.316,276.889,OPENWORLD.Camera.cameraoffset);  // acropolis start
   //     OPENWORLD.Space.worldToLocalSurfaceObj(
   //     camera,  365.38,273.52,OPENWORLD.Camera.cameraoffset);  // postoffice
  //  OPENWORLD.Space.worldToLocalSurfaceObj(
   //     camera,  381.79, 255.60,OPENWORLD.Camera.cameraoffset);  // restaurant  sheperds baah 381.42,254.60
   //   OPENWORLD.Space.worldToLocalSurfaceObj(
   //     camera,  397.16,240.99,OPENWORLD.Camera.cameraoffset);  // home
   // OPENWORLD.Space.worldToLocalSurfaceObj(
   //    camera,  380.66, 258.67,OPENWORLD.Camera.cameraoffset);  // general store  379.45,259.5
  // OPENWORLD.Space.worldToLocalSurfaceObj(
   //      camera,  400.4,233.56,OPENWORLD.Camera.cameraoffset);  // home2
    //OPENWORLD.Space.worldToLocalSurfaceObj(
    //      camera,  376.15,254.45,OPENWORLD.Camera.cameraoffset);  // bank
    //  OPENWORLD.Space.worldToLocalSurfaceObj(
     //    camera, 373.47, 240.89,OPENWORLD.Camera.cameraoffset);  // brewery   373.2,244.9
  //  OPENWORLD.Space.worldToLocalSurfaceObj(
   //     camera, 384.17, 264.90,OPENWORLD.Camera.cameraoffset);  // armourer   385.15,264
     // OPENWORLD.Space.worldToLocalSurfaceObj(
    ///     camera, 383.55, 270.44,OPENWORLD.Camera.cameraoffset);  // weaponer   383.45,272.40
   //   OPENWORLD.Space.worldToLocalSurfaceObj(
    //     camera,  375.72, 267.24,OPENWORLD.Camera.cameraoffset);  // bottleshop   378,267.6
  // OPENWORLD.Space.worldToLocalSurfaceObj(
   //      camera,   380.98, 240.42, OPENWORLD.Camera.cameraoffset);  // smithy 381.69,238.65,
    //OPENWORLD.Space.worldToLocalSurfaceObj(
    //  camera,   392.65,300.15,OPENWORLD.Camera.cameraoffset);  // smelly bottle

    // OPENWORLD.Space.worldToLocalSurfaceObj(
     //     camera,  396.95,301.58,OPENWORLD.Camera.cameraoffset);  // home3
     //  OPENWORLD.Space.worldToLocalSurfaceObj(
     //      camera,  383.5,251.81,OPENWORLD.Camera.cameraoffset);  // homeroom
      //   OPENWORLD.Space.worldToLocalSurfaceObj(
      //     camera,  384.28,256.67,OPENWORLD.Camera.cameraoffset);  // postoffice2
     // OPENWORLD.Space.worldToLocalSurfaceObj(
     //    camera,  387.87,243.84,OPENWORLD.Camera.cameraoffset);  // soupkitchen
     //OPENWORLD.Space.worldToLocalSurfaceObj(
     //    camera,  368.36,281.15,OPENWORLD.Camera.cameraoffset);  //prison
    //  OPENWORLD.Space.worldToLocalSurfaceObj(
     //    camera,  670.97,542.97,OPENWORLD.Camera.cameraoffset);  //cleobulus digging
     // OPENWORLD.Space.worldToLocalSurfaceObj(
     //   camera,  364.09,246.19,OPENWORLD.Camera.cameraoffset);  //baccarat
    //OPENWORLD.Space.worldToLocalSurfaceObj(
     //   camera,  377.86, 280.53 ,OPENWORLD.Camera.cameraoffset);  //newsroom   377.16,281.58,
    //  OPENWORLD.Space.worldToLocalSurfaceObj(
    //      camera,  376.17, 281.29 ,OPENWORLD.Camera.cameraoffset);  //newsroomback
      //  OPENWORLD.Space.worldToLocalSurfaceObj(
      //   camera, 406.86, 307.80,OPENWORLD.Camera.cameraoffset);  //real estate   406.56,308.23
  //   OPENWORLD.Space.worldToLocalSurfaceObj(
   //     camera, 372.200,269.800,OPENWORLD.Camera.cameraoffset);  //road dog
       //  OPENWORLD.Space.worldToLocalSurfaceObj(
       //    camera,  376.76, 268.76,OPENWORLD.Camera.cameraoffset);  //beggar    373.936,267.67
     // OPENWORLD.Space.worldToLocalSurfaceObj(
     //     camera,  389.55,245.42,OPENWORLD.Camera.cameraoffset);  //butcher
     // OPENWORLD.Space.worldToLocalSurfaceObj(
     //    camera, 366.617,279.593,OPENWORLD.Camera.cameraoffset);  //courtyard
    //  OPENWORLD.Space.worldToLocalSurfaceObj(
      //   camera, 374.846,272.103,OPENWORLD.Camera.cameraoffset);  //endo church
   //    OPENWORLD.Space.worldToLocalSurfaceObj(
    //       camera, 384.037,286.318,OPENWORLD.Camera.cameraoffset);  //tradingpost
  //  OPENWORLD.Space.worldToLocalSurfaceObj(
  //        camera, 394.900,296.430,OPENWORLD.Camera.cameraoffset);  //trixiehouse
    //  OPENWORLD.Space.worldToLocalSurfaceObj(
     //     camera, 391.787,253.682,OPENWORLD.Camera.cameraoffset);  //trixie
       // OPENWORLD.Space.worldToLocalSurfaceObj(
       //    camera, 438.840,280.250,OPENWORLD.Camera.cameraoffset);  //bareground flute
     //   OPENWORLD.Space.worldToLocalSurfaceObj(
     //      camera, 428.580,275.840,OPENWORLD.Camera.cameraoffset);  //grandstoa
        //OPENWORLD.Space.worldToLocalSurfaceObj(
       //     camera, 430.080,278.290,OPENWORLD.Camera.cameraoffset);  //quartersdoorway
  //  OPENWORLD.Space.worldToLocalSurfaceObj(
   //   camera, 304.19, 427.22,OPENWORLD.Camera.cameraoffset);  //bandit  304.564,429.02
     // OPENWORLD.Space.worldToLocalSurfaceObj(
     //     camera, 407.021,324.83,OPENWORLD.Camera.cameraoffset);  //boat
     // OPENWORLD.Space.worldToLocalSurfaceObj(
     //      camera, 197.269,114.397,OPENWORLD.Camera.cameraoffset);  //kindling
       //  OPENWORLD.Space.worldToLocalSurfaceObj(
      //       camera, 123.096,512.404,OPENWORLD.Camera.cameraoffset);  //wilddog
    OPENWORLD.Space.worldToLocalSurfaceObj(
             camera, 379.08, 338.82 ,OPENWORLD.Camera.cameraoffset);  //intro  380,339
     //    OPENWORLD.Space.worldToLocalSurfaceObj(
      //      camera,414.479,260.357,OPENWORLD.Camera.cameraoffset);  //sheep
       //   OPENWORLD.Space.worldToLocalSurfaceObj(
       //     camera,393.97, 316.09,OPENWORLD.Camera.cameraoffset);  //sheep2

    // OPENWORLD.Space.worldToLocalSurfaceObj(
    //         camera,467.69, 351.81,OPENWORLD.Camera.cameraoffset);  //cannon
       //  OPENWORLD.Space.worldToLocalSurfaceObj(
       //        camera,365.660,231.750,OPENWORLD.Camera.cameraoffset);  //child
      //  OPENWORLD.Space.worldToLocalSurfaceObj(
      //        camera,373.500,334.056,OPENWORLD.Camera.cameraoffset);  //tent

      OPENWORLD.Camera.setTurn( 100);//107.61);//-90);//Space.objTurn(camera,-90);


    }
    // Create an actor for yourself so when you slash or punch you can see your arm move
    print("set me");
    me= await OPENWORLD.Actor.createActor('assets/actors/citizenf5.glb');
    setDefaultActor(me);
    scene.add(camera);
    camera.add(me);
    //scene.add(me);
    OPENWORLD.Space.objTurn(me,0);
    me.position.set(0,-0.17,0.02);


    setState(() {
      weaponicon = defaultweaponicon;//'icons/fist.png';
      loaded = true;
    });

    // Show guidance if first time
    if (firstime&&!kIsWeb)  // Persistence doesnt work on web
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        userGuidanceController.show();
      });

    print("time to load"+((OPENWORLD.System.currentMilliseconds()-starttick)/1000.0).toString());

    Future.delayed(const Duration(milliseconds: 1000), () {
      // So when startup dont end up in two rooms - check if already in a room on startup and if not turn on distance trigger to can get into roomdefault
      if (OPENWORLD.You.room==null) {
        OPENWORLD.BaseObject.reenableDistanceTrigger(roomDefault);

      }
    });


    animate();

    _timer = new Timer.periodic(new Duration(milliseconds: poll), (_) {
      clientInterval(); // for the client connection
      heartbeat();
      //userGuidanceController.show(subIndex:1);
    });

    // scene.overrideMaterial = new THREE.MeshBasicMaterial();
  }

  resetYou() {
    CLIENT.You.action = "";
    CLIENT.You.msg = [];
    CLIENT.You.actions['who'] = false;
    // CLIENT.You.actions['disconnect'] = false;
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
      var name=await promptDialog('Player Name','To play online enter your players name',value);


      setState(() {
        // loaded=true;
        _globalKey.currentState?.pause = false;
      });
      if ((name==null|| name == "" ) &&
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
            await OPENWORLD.Actor.stopAnimations(players[i].actor);
            (await OPENWORLD.Actor.getAction(players[i].actor,name:"idle"))// index: 3))
                .setDuration(3)
                .play();
            // player_mixers[i].clipAction( player_mixers[i].getRoot().geometry.animations[3] ).setDuration(3).play();
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
      OPENWORLD.Mob.colorfromname=false;

    }

  }

  // When click the close button
  // Silence sounds and hide inventory
  close({pop:true}) async {

    print("close");
    OPENWORLD.Weather.mute(true); // so that dont get wind or rain sound when close
    OPENWORLD.Musics.setMute(true);//stop();
    OPENWORLD.Sound.setMute(true);
    OPENWORLD.Room.mute(true);
    roomdefaultsound11.stop();
    roomdefaultsound12.stop();
    roomdefaultsound21.stop();
    roomdefaultsound22.stop();
    if (horseridingcloploaded)
      horseridingclop.stop();
    OPENWORLD.You.immobile=false;
    OPENWORLD.You.immobileturn=false;
    canhit=true;
    OPENWORLD.Config.poolObjects.clear();
    if (loaded) {
      _timer.cancel();
      await disconnect();
      setState(() {
        loaded = false;
        OPENWORLD.System.active = false;
      });
    }

    if (pop)
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

    var msg=await chatDialog('Enter Message','','');

    // reenable DomLikeListenable so can use movement keyboard again
    _globalKey.currentState?.pause = false;

    if (msg!=null&&msg != "") {
      CLIENT.You.msg.add(msg);
    }

  }

  // This is obsolete but might be used later
  wingflap() {
    OPENWORLD.Sound.play(
        path: 'sounds/flap' + ((OPENWORLD.Math.random() * 3).floor() + 1).toString() + '.mp3', volume: 0.1);

  }

  // This is obsolete but might be used later
  flyup() {
    if (OPENWORLD.Camera.cameraoffset < 3) {
      OPENWORLD.Camera.cameraoffset += 0.1;
      OPENWORLD.Space.objUpSurface(
          camera,
          OPENWORLD.Camera.cameraoffset); //camera.position.x+=0.01; //trick to show
    }
    wingflap();
  }

  // This is obsolete but might be used later
  flydown() {
    if (OPENWORLD.Camera.cameraoffset > 0.15) {
      OPENWORLD.Camera.cameraoffset -= 0.1;
      OPENWORLD.Space.objUpSurface(
          camera,
          OPENWORLD.Camera.cameraoffset); //camera.position.x+=0.01; //trick to show
      wingflap();
    }
  }

  var frames=0;
  var lastframes=0;
  var frames10=0;

  animate() async {
    // if app in background dont keep animating
    if (!kIsWeb&&OPENWORLD.System.appstate != AppLifecycleState.resumed) {
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

    prevlocalx = camera.position.x;
    prevlocaly = camera.position.y;
    prevlocalz = camera.position.z;



    if (mapshow) {
      // Get the map to display and maps pixel coordinates based on the world coordinates and show the marker where the player is
      setState(() {
        var worldpos = OPENWORLD.You.getWorldPos();//Space.localToWorldObj(camera);
        var map = OPENWORLD.Maps.getMapFromWorldcoords(worldpos.x, worldpos.y);
        if (map != null) {

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

    OPENWORLD.Sound.update();

    if (OPENWORLD.Math.random() < 0.1)
      OPENWORLD.Musics.update(); // dont need to do it very often

    OPENWORLD.Time.update(frameTime);

    OPENWORLD.Weather.update(frameTime);


    OPENWORLD.Room.update(frameTime);

    if (boatriding) {
      // Rock the boat
       OPENWORLD.Space.objPitch(boat2, 0.5*math.sin( clock.getElapsedTime () % math.pi ));
       OPENWORLD.Space.objRoll(boat2, 0.4*math.sin( clock.getElapsedTime () % math.pi ));
    }

    if ((horseriding||horse2riding)&&ismoving) {
      // Up and down when ride horse
      //OPENWORLD.Camera.setPitch( 0.35*math.sin( clock.getElapsedTime ()*3 % (math.pi) ));
      OPENWORLD.Camera.setPitch( 0.35*math.sin( clock.getElapsedTime ()*5 % (math.pi) ));
    }

    Future.delayed( Duration(milliseconds: framedelay), () {  // was 40 which is 1000/40 = 25 fps
      animate();
    });
  }


  var lastconnection = -1;
  var doneinterval = true;

  // called every second
  clientInterval() async
  {
    //if (_space!=null) {
    // So that if in background dont keep doing interval
    if (OPENWORLD.System.appstate != AppLifecycleState.resumed || !doneinterval)
      return;

    doneinterval=false;
    var pos = OPENWORLD.Space.localToWorldObj(camera);

    print("pos: " + pos.x.toStringAsFixed(2) + ", " + pos.y.toStringAsFixed(2)+"  turn:"+OPENWORLD.Math.standardAngle(OPENWORLD.Camera.turn).toStringAsFixed(2)+"  movedir:"+OPENWORLD.Math.standardAngle(OPENWORLD.You.getMoveDir()).toStringAsFixed(2)+" "+
        ((OPENWORLD.Weather.wind>0)?"w"+OPENWORLD.Weather.wind.toStringAsFixed(2):"")+" "+
      ((OPENWORLD.Weather.cloud>0)?"c"+OPENWORLD.Weather.cloud.toStringAsFixed(2):"")+" "+
        ((OPENWORLD.Weather.fog>0)?"f"+OPENWORLD.Weather.fog.toStringAsFixed(2):"")+" "+
        ((OPENWORLD.Weather.rain>0)?"r"+OPENWORLD.Weather.rain.toStringAsFixed(2):"")+" "+
        "t"+OPENWORLD.Time.time.toStringAsFixed(2)+" "+
        "v"+OPENWORLD.You.speed.toStringAsFixed(2)+" "+
        "pitch"+OPENWORLD.Camera.pitch.toStringAsFixed(2)+" "

    );
    if ((CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTED ||
        CLIENT.Connection.connect_state == CLIENT.Connection.CS_CONNECTING)) {
      //print("in interval");

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
      print("position"+position.toString());

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
          OPENWORLD.Mob.colorfromname=true;
        });
        Future.delayed(Duration(seconds: 1), () {
          has_connected();
        });

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
        print("player found "+player.toString());
        // if cant find the player either reuse a removed player or create a new one
        if (player == null) {
          if (players_removed.length > 0) {
            // reuse an old player if one around
            player = players_removed[0];

            players_removed.splice(0, 1);
          } else {

            var _has_name;
            var player_model;
            if ((players.length) % 3 == 0) {

              print("copied armourer");//+_shofar.toString());

              player_model = await OPENWORLD.Actor.copyActor(armourer);//_shofar); //.clone();
              //shofar.add(player_mixers[0]._has_name);
            } else if ((players.length) % 3 == 1) {

              print("copied amon");//+_shofar.toString());
              player_model = await OPENWORLD.Actor.copyActor(amon);

            } else {
              print("copied guard2");//shofar"+_shofar.toString());
              player_model = await OPENWORLD.Actor.copyActor(guard2);//_shofar,texture:"assets/actors/shofar/shofar3.jpg"); //.clone();

            }
            player = CLIENT.Player(player_model);//THREE.AnimationMixer(player_model));
            player?.actor.visible=true;
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

          OPENWORLD.Mob.setName(player.actor,data[i][1]);
          OPENWORLD.Mob.setText(player.actor, data[i][1], z:100);
          changed_sprite = true;
        }

        var x = double.parse(data[i][2]);
        var y = double.parse(data[i][3]);
        var z = double.parse(data[i][4]);
        var playerpos = OPENWORLD.Space.localToWorldObj(player.actor);
        player.userid = data[i][0];
        player.name = data[i][1];
        if (!changed_sprite) {
          print("not changed sprite");
          // if existing player has moved then lerp the player to the new location
          var stopdist = 0.01;
          var dist = OPENWORLD.Math.vectorDistance(
              new THREE.Vector3(x, y, 0.14), playerpos);
          //print("uuu"+dist.toString()+" oo"+player.isWalking.toString());
          if (dist > stopdist && !player.isWalking) {
            print('is walking');
            player.isWalking = true;
            await OPENWORLD.Actor.playAction(
               player.actor, name: "walk", duration: 1, stopallactions: true);

          } else if (dist < stopdist && player.isWalking) {
            print('is not walking');
            player.isWalking = false;
            await OPENWORLD.Actor.playAction(
                player.actor, name: "idle2", duration: 1, stopallactions: true);

          }

          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
              player.actor, x, y, 0, poll / 1000);
        } else {
          // if player has entered the game then move them straight there

          await OPENWORLD.Actor.playAction(
              player.actor, name: "idle2", duration: 1, stopallactions: true);
          OPENWORLD.Space.worldToLocalSurfaceObj(player.actor, x, y, 0);
        }

        var action = data[i][6];
        if (action == "wave") {
          print("wave");
          player.isWalking = false;
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

          msglinesi.add({'usename': usename, 'msg': msgs[i][1]});
          print("added msg for "+usename+" id"+msgs[i][0].toString());
          //  msglines=msglines+"<span style='color:"+color+"'>"+msgs[i][1]+"</span><br>";
        } else {
         // print("no usename in msg");
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
    doneinterval=true;
  }

  // anything in the game that needs to be done every second
  var prevposx = -99999.0;
  var prevposy = -99999.0;
  var prevposz = -99999.0;

  var heartbeattick=0;

  var ismoving=false;

  heartbeat() async {
    // So that if in background dont keep ticking
    if (OPENWORLD.System.appstate != AppLifecycleState.resumed) {
    //  print("heartbeat stop");
      return;
    }

    if (underSea()) {
      // Show blue fog if underwater
      (scene.fog as THREE.Fog)?.near=0.1;
      (scene.fog as THREE.Fog)?.far=8;
      OPENWORLD.Weather.setSkyOpacity(0.0);
      scene.background=seacolor;//THREE.Color(0x064273);
      scene.fog?.color=seacolor; //THREE.Color(0x064273);
    } else
      OPENWORLD.Weather.changeFog(OPENWORLD.Weather.fog);

    // Save player state
    var worldpos = OPENWORLD.You.getWorldPos();//Space.localToWorldObj(camera);
    if (worldpos.x != prevposx || worldpos.y != prevposy) {
      ismoving=true;
      OPENWORLD.Persistence.set("posx", worldpos.x);
      OPENWORLD.Persistence.set("posy", worldpos.y);

      // If on acropolis and jump off then you die
      if (isAcropolis() && prevposz!=-99999.0&&camera.position.y - prevposz <-2.5&&!isDead()) {
        print("fell to death");
        setHealth(0);
        youDie();
        endo(delay: 10);
        Fluttertoast.showToast(
            msg: "You fall to your death",
            toastLength: Toast.LENGTH_LONG);
      }
      // If close to edge of game then slow down so can't go off edge
      var diff=5;
      var drag=-1.0;
      if (worldpos.x<diff)
        drag=defaultdrag*(1-((diff-worldpos.x)/diff));
      else if (worldpos.x>(mudwidth-2)-diff) {
       // print("drag x");
        drag = defaultdrag * ((mudwidth - 2)- worldpos.x) / diff;
      } else  if (worldpos.y<diff)
        drag=defaultdrag*(1-((diff-worldpos.y)/diff));
      else if (worldpos.y>mudheight-diff) {
        drag=defaultdrag*(mudheight-worldpos.y)/diff;
      }

      if (drag!=-1.0) {
        OPENWORLD.You.drag=drag;
      } else
        OPENWORLD.You.drag=defaultdrag;


      prevposx = worldpos.x;
      prevposy = worldpos.y;
      prevposz = camera.position.y;  // is absolute z

    } else
      ismoving=false;

    if (horseriding) {
      if (ismoving)
        horseridingclop.setVolume(0.5);
      else
        horseridingclop.setVolume(0.01); // so doesnt turn off
    }
    // Save current time
    OPENWORLD.Persistence.set("turn", OPENWORLD.Camera.turn);

    // Save current weather
    OPENWORLD.Persistence.set("time", OPENWORLD.Time.time);
    OPENWORLD.Persistence.set("rain",OPENWORLD.Weather.rain);
    OPENWORLD.Persistence.set("wind",OPENWORLD.Weather.wind);
    OPENWORLD.Persistence.set("cloud",OPENWORLD.Weather.cloud);
    OPENWORLD.Persistence.set("fog",OPENWORLD.Weather.fog);
    if (showfps) {
      setState(() {
        fps=frames;
      });
    }
   // print("fps"+frames.toString());
    lastframes=frames;
    frames=0;
    heartbeattick++;
    if (heartbeattick % 10==0)  {
      if (showfps)
        print("fps av "+(frames10/10).toString());
      if (frames10<200&&framedelay>0) {
       // framedelay--;
      //  print("frame delay"+framedelay.toString());
      }
      frames10=0;
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
