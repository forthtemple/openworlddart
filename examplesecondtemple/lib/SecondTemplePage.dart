import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

//import 'dart:math';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:openworld/asset_pack.dart';


import 'package:custom_mouse_cursor/custom_mouse_cursor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_user_guildance/flutter_user_guildance.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:openworld/objects/fire.dart';
import 'package:openworld/objects/flares.dart';
import 'package:openworld/objects/vegetation.dart';
//import 'package:openworld/objects/distant_vegetation.dart';
import 'package:openworld/objects/smoke.dart';
import 'package:openworld/objects/tree.dart';
import 'package:openworld/objects/watersimple.dart';
import 'package:openworld/shaders/SkyShader.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as THREE;
import 'package:window_manager/window_manager.dart';
import 'gamestart.dart';
import 'glob.dart';
import 'main.dart' show restartApplication;
//export 'package:three_js_core/three_js_core.dart';
//export 'package:three_viewer/three_viewer.dart';

import 'package:openworld/openworld.dart' as OPENWORLD;
import 'package:openworld/client.dart' as CLIENT;
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:three_js_helpers/axes_helper.dart';
import 'package:three_js_helpers/camera_helper.dart';
import 'package:three_js_helpers/spot_light_helper.dart';
//import 'package:three_js_modifers/buffergeometry_utils.dart' as THREE_JS;
//import 'package:three_js_objects/water/water2.dart';
//import 'package:three_js_objects/water/reflector.dart';
//import 'package:three_js_objects/water/refractor.dart';
//import 'package:openworld/shaders/water2.dart';
//import 'package:openworld/objects/watersimple.dart';
import 'package:openworld/objects/water3.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:widget_zoom/widget_zoom.dart';
//import 'package:openworld/shaders/SkyShader.dart';
import 'package:three_js_objects/sky/sky.dart';

import 'package:openworld/InstancedBillboards.dart';
import 'package:openworld/InstancedModel.dart';
import 'package:package_info_plus/package_info_plus.dart';


part 'hotload.dart';
//part 'hotload_sprites.dart';
part 'hotload_hearth.dart';
part 'hotload_womensgate.dart';
part 'hotload_secondtemple.dart';
part 'hotload_bethphage.dart';
part 'hotload_lowercity.dart';
part 'hotload_pilgrimsroad.dart';
part 'hotload_siloam.dart';
part 'hotload_outer.dart';



String gamename = 'Second Temple';

const kC = [0x51, 0x1b, 0x17, 0x92, 0x47, 0xea, 0x68, 0x29, 0xc1, 0xda, 0x1b, 0xa7, 0xe8, 0x13, 0x34, 0xe1, 0x07, 0xa5, 0x1c, 0x1c, 0x14, 0xc4, 0x89, 0x73, 0x11, 0x52, 0xc2, 0x6a, 0x83, 0xd0, 0x22, 0xf5];


class SecondTemplePage extends StatefulWidget {
  final gamestart;
  final progress;
  const SecondTemplePage({super.key, this.gamestart, this.progress});

  @override
  createState() => SecondTemplePageState();
}

class SecondTemplePageState extends State<SecondTemplePage> {
  UserGuidanceController userGuidanceController = UserGuidanceController();

  List<int> data = List.filled(60, 0, growable: true);
  late Timer timer;
  late THREE.ThreeJS threeJs;
  late final GlobalKey _repaintBoundaryKey;
  Uint8List? _capturedImage;
  bool _showOverlay = false;
  bool _isBlending = false;
  double _blendOpacity = 1.0;
  DateTime? _blendStartTime;
  static const Duration _blendDuration = Duration(milliseconds: 1000);

  late THREE.Clock clock;
  late Timer _timer;
//  var loaded = false;
  int progress=0;
  double progressmax=210.0;
  String progressmsg="";
  // Every loading message reached so far, newest first, so they accumulate
  // on the loading screen instead of each one replacing the last.
  List<String> progressmsgs=[];
  String progressimg=OPENWORLD.Math.random()<0.5?'icons/secondtemple.jpg':'icons/secondtemple2.jpg';

  int pointerdowntick = -1;

  OPENWORLD.VirtualJoystick? _joystick;

  var prevlocalx = 0.0;
  var prevlocaly = 0.0;
  var prevlocalz = 0.0;

  late VolumetricFire _fire;

  List<CLIENT.Player> players = [];
  List<CLIENT.Player> players_removed = [];

  late THREE.Object3D _horse;
  bool horseriding = false; // This is your own horse
  bool canhorseride = false; // Near a horse to ride
  var horsespeed = 3.0/20;//4.0 / 20; //20.0 / 20;//16;//4; //25.0/4;
 //  var defaultspeed = 8.0 / 20;// 16;//4; //2m/s
  var indoorspeed = 1.5 / 20; // 16;//4; //2m/s
  var defaultspeed =  3.0 / 20; // 16;//4; //2m/s

  late THREE.Group _cow;

  late THREE.Object3D roomTerrain;
  late THREE.Object3D roomSanctuary;
  late THREE.Object3D roomCourtIsrael;
  late THREE.Object3D roomCourtWomen;
  late THREE.Object3D roomSouthCourt;
  late THREE.Object3D roomNorthCourt;
  late THREE.Object3D roomStoa;
  late THREE.Object3D roomSouth;   // Huldah gates
  late THREE.Object3D roomWest;
  late THREE.Object3D roomHearth;
  late THREE.Object3D roomHewnstone;
  late THREE.Object3D roomBethphage;
  late THREE.Object3D roomMiphkad; // red heifer
  late THREE.Object3D roomShop;  // shop in lower city
  late THREE.Object3D roomLowercity;  // home in lower city
  late THREE.Object3D roomSiloam;
  late THREE.Object3D roomPilgrimsroad;
  late THREE.Object3D roomBethesda;
  late THREE.Object3D roomStablebethesda;
  late THREE.Object3D roomStableSiloam;
 // late THREE.Object3D roomNorth;

  var poll = 1000; // How often you poll the server
  var msgs = [];
  var whos = [];
  var max_message = 5; // How many messages you show
  var num_players = 0;
  var msglines = [];

  late CLIENT.Session _session;
  String prompttext = "";
  bool showdisconnect = false;

  THREE.Group _hotload = THREE.Group();

  String roomname = "";

  int actoroffset = 38;
  double actorscale= 0.0025*0.5;

  bool mapshow = false;
  double mapx = -1;
  double mapy = -1;
  late String mapfile;
  late int mapwidth;
  late int mapheight;
  final mapmarkersize=40.0;

  bool hidewidgets = false; // useful if want to do screenshots without controls etc showing
  bool showfps = false; // show frames per second
  int fps = -1;
  int framedelay = 40;

  double menuposx = -1;
  double menuposy = -1;
  late THREE.Object3D menuobj;
  List menuitems = [];

  double horsecameraoffset = 0.15 * 0.5 + 0.03 * 0.5;

  double convscale = 0.5 * 0.0025 / 0.006;

  MouseCursor? assetCursor;
  bool donemousecursor = false;

  bool saveweather=false;
  late THREE.Object3D? creek=null;

  var defaultdrag = 1.0;

  List<OPENWORLD.Doorway> doorways=[];

  // This is the gate of the women path
  var citizenpath =
  [[-26.05, 119.82],
    [-25.47, 117.29],
    [-25.01, 114.94],
    [-24.23, 111.21],
    [-23.70, 108.74],
    [-22.92, 105.10],
    [-22.38, 102.64],
    [-21.82, 99.91],
    [-21.07, 96.52],
    [-20.46, 93.63],
    [-19.77, 90.25],
    [-19.05, 87.20],
    [-18.45, 84.19],
    [-17.82, 81.47],
    [-17.20, 78.77],
    [-16.39, 75.31],
    [-15.75, 72.16],
    [-15.10, 69.33],
    [-14.46, 66.17], //-14.11, 65.9],
    [-13.93, 63.53],
    [-13.8, 63.22],
    [-13.59, 62.54],
    [-13.59, 62.41],
    //  [-13.59, 62.39],
    [-13.55, 62.09],
//    [-13.72, 61.49],
    [-14.00, 61.41],
    [-14.30, 60.10],
    [-14.60, 58.98],
    [-16.58, 56.86], //-15.16, 57.46],
    [-18.27, 55.17], //-18.24, 55.15],
    [-18.60, 52.55],
    [-18.79, 50.44],
    [-19.20, 47.89], //-16.29, 54.60],
    // [-17.98, 51.30],
    // [-19.38, 48.33],
    [-20.69, 45.87],
    [-23.95, 44.11], //22.52, 42.34],
    [-23.9,39.15],
    [-28.68-0.1,35.04],
//    [-28.68-0.15,34.8],//35.04],
    [-24.6+0.2, 30.1],
    [-20.6,25.53],
   /* [-24.94,30.8],
    [-21.5,26.29],
    [-19.18,23.1],
    [-16.96,20.26],*/
    [-15.07,18.81],
    [-11.40,12.42],
    [-8.92,8.3],
    [-6.03,3.49],
  /*  [-15.09,17.15],
    [-13.53,14.0],
    [-11.5, 12.74],//12.27,11.96],
    [-9.5,9.15],//10.49,8.77],
    [-7.71, 6.55],//9.5,6.98],
    [-5.94,3.3],//8.6,3.3],*/
    [-5.79,-0.87],//-7.76,-0.37],
    [-6.03,-4.34],//-6.85,-4.04],
    [-6.2,-7.59],
    [-5.97,-10.9]

  ]; //0.065]];

  var friendpath = [
    [-25.51 + 0.1, 117.12],
    [-25.00, 115.09], // this is where they turn around and say nearly there
    [-24.24, 111.34], // where people sitting that say shalom
    [-21.66, 99.99], // flare with friend2
    [-21.41, 98.06], // kids playing
    [-20.12 + 0.8, 92.13 - 4], // psalm// speedup
    //    [-20.22, 93.13],  // speedup
    [-14.84, 67.53],
    [-14.17, 64.75], // birds   7
    [-13.76 - 0.05, 63.41 + 0.3], // gate in 8
    [-13.78, 63.13], // gate out 9
    [-12.31, 58.72], // psalm2 10
    [-9.92+0.2, 55.31 + 0.2], // 11
//    [-9.92 - 0.1, 55.31 + 0.2], // 11
    //[-9.92, 55.24],//-11.12, 55.38],
    [-10.09-0.15, 51.65 + 0.2], //12 -10.14, 51.55],
    [-6.91+0.05, 48.13], //13 -7.96, 46.86]
    [-5.86-0.05, 39.61],  //14
   // [-11.0,40.79],
  //  [-15.4,40.48]

    [-0.81+0.08,32.53], //15
    [2.45+0.1,23.1],  //16
    [3.55+0.15,21.8] , // 17 stables
    [5.78+0.1,18.93],//18
    [5.98,17.53],//19
    [6.35,16.83],  // 20 pool of bethesda
    //[5.98,17.53],
   // [5.78+0.1,18.93],
  ];


  // womensgate path to fishgate
  var friendpathfishgate = [
   // [6.35,16.83],  //  pool of bethesda
   // [5.98,17.53],
    [5.78,18.93],  //0
//    [5.78+0.1,18.93],  //0
    [3.55,21.8] , //  1stables
    [2.45,23.1],  //2
    [-0.81-0.07-0.02,32.53-0.05], //3
    [-5.86-0.07, 39.61-0.15], //4
    [-11.09,40.87-0.2],  //5
    [-15.2,40.66-0.2],  //6
    [-19.67,38.2-0.2],  //7
    [-28.44+0.15,35.18],  //8
    [-28.5+0.5,34.59-0.2], //9
//    [-28.63,34.99+0.07],
   // [-25.1,30.69] //fishgate
  ];

  // womensgate path to robinsons arch
  var friendpathrobinsons = [
     [-24.6+0.2, 30.1],//25.1,30.69], //fishgate
    [-20.6,25.53],  //1
    [-15.07,18.81],//2
    [-11.40,12.42],//3
    [-8.92,8.3],//4
    [-6.03,3.49],//5
    [-5.68,2.05], // 6 start of western wall
    [-6.14,-2.82], // wilsons arch
    [-6.03,-11.2],// 8
    [-6.0,-14.03+0.6]  // bottom of robinsons arch  - seperate moveto() to get them up the stairs
    ];

  // womensgate path to temple
  var friendpathtemple=[
    [-4.96,-11.69],  //0
    [-3.47, -12.52],  // 1 dove seller
    [ -3.01-0.1, -11.84], //2
    [ 2.8, -11.84],//2.5-0.1, -11.84],//3   // still in stoa
    [3.01-0.3, -8.79+1],// 5.23-0.4,-5.94],//4  middle of court of gentiles
    [7.27+0.045,-2.95],  //5 soreg
    [7.27+0.045,-1.39+0.1],  // inside court of women
    [ 6.62, -0.64-0.02],  // so avoid lamp -court of women
    [5.65,0.4]
  ];
  // late THREE.Object3D  soldierpath;
  List citizengroups = [];
  var citizenhidedist = 4.0;

  late THREE.Group soldier2;
  late var soldier22;
  late var soldier23;
  late var soldier24;

  late THREE.Group cart;
  late THREE.Group figs;

  late var womensgategroup=[];
  late THREE.Group donkey3group;
  late THREE.Group? friendbethphagegroup=null;
  late THREE.Group citizengroup;

  late var friendhearth;  // Your friend in the chamber of the hearth
  var friendhearthanglediff =120;

  // This looks like its that path you've done that goes to the east of the the temple mount - so can have a cart
  // This goes all the past bethphage to the eastern wall then as far south as can go
  var citizenpathsouth = [

    [53.62, -4.42],  // furthest way along the road through bethphage
    [56.22, -1.39],
    [57.29, 0.77],
    [58.29, 3.04],
    [ 58.83, 4.65],
    [59.42, 7.81],
    [ 59.85, 10.47],
    [ 56.83, 13.28],  // at your bethphage house
    [ 53.24, 12.76], // 53.26, 13.88],
    [ 50.03, 12.20], //50.61, 14.38],   9
    [47.94, 12.81], //47.05, 14.88],
    [43.10, 15.30], // 43.20, 15.38],
    [ 41.45, 14.67], //41.18, 14.91],
    [ 38.48, 13.77], //38.52, 13.35],//38.29, 14.15],
    [35.34, 12.45], // 35.01, 12.27] ,// [ 35.49, 13.39],
    [ 32.33, 12.21], //32.87, 12.58],
    [ 29.14, 11.60], // 29.82, 11.86],
    [ 26.69, 11.02],//26.36, 11.07], // 27.20, 11.90], //17
    [ 23.45, 10.03],//23.43, 9.91],//23.96, 11.62],  //18
    [ 20.93, 7.86],//22.32, 6.85],//20.85, 11.57],  //19
    //[ 20.91, 9.89],
//    [ 21.21, 6.70],
    [ 17.17, 4.34],//21.46, 3.73],//21.50, 3.20],  //20
    [ 17.61, 1.68],//21.83, 0.08],
    [ 18.11, -0.76],//21.52, -3.13],
    [ 18.11, -3.94],
    [ 18.19, -6.22],//21.07, -6.16],
    [  18.21, -8.68],//20.73, -9.07],
    [ 17.27, -11.14],//20.52, -12.01],  //26  around goats?
    [ 16.09, -14.25],//19.88, -15.96],
    [  15.43, -16.18],//14.67, -17.17],// 18.19, -18.08],
    [ 13.2,-20.29],//12.99, -20.29],//15.27, -21.43],
    [ 11.10, -24.09],//12.79, -24.15],   //30
    [ 8.02, -27.20],// 9.54, -27.37],
    [ 3.94, -30.87],//6.51, -30.49],
    [ 2.92, -33.30],//4.33, -33.36],
    [ 1.87, -36.13],// 2.30, -36.31],
    [0.57, -39.46],//0.72, -39.10],    //35
    [-0.44, -42.23],//-1.51, -42.86],
    [  -1.70, -45.25],//-2.91, -45.95],
    [ -3.37, -48.18],//-4.44, -48.97],  // 38
    [ -5.23, -51.07],//-6.29, -52.51],
    [ -7.67, -55.20],                    //40
    [ -10.91, -58.22],
    [ -12.68, -59.85],
    [ -14.24, -61.19],

  ];

  // For bethphage path of your friend
  List<List<double>> citizenpathsouthfriend=[];   // Same as citizenpathsouth but offset to the right so you dont walk through oncoming people

  var bathingactions = [
    "washhip",
    "idle",
    "squat",
    "squat",
    "idlebum",
    "washhead",
    "idlenose",
    "washhead",
    "idlebum"
  ];

  late var dad;  // lowercity game
  late var donkeypackbuckets;

  // This is the one that goes all the way south to the temple mount and is obtained from the terrain model rather than hard coded
  List<List> citizenessenpath =[];

  var groupessener = [];

  // The one from beztheda pool to court of women that is sort of redudant
  var citizenwomenpath = [
   /* [3.01, 20.19],  - this part isn't valid because pilgrims didn't come through here
    [2.14, 17.27,],
    [ 2.00, 14.13],
    [ 2.03, 12.53],
    [1.99, 9.28], //4.31, 9.74],
    [2.06,7.79],
    [2.06,7.66],*/
    [2.09, 5.28], //6.72, 7.13],
    [ 2.43, 4.94], //7.19, 4.40],
    [7.37, 4.26], //7.08, 3.50],
    [7.22, 2.89], //4.90, 1.49]
    [7.12, 1.86],  // exit north gate court of women
    [6.2, 0.92],  // west up the nicanor steps
    [5.70, 0.92]  // gate of nicanor
  ];

  var groupwomen = [];

  late THREE.Group manger;
  late THREE.Group hay;
  late var instancedHays;
  late var instancedHaysHearth;

  late THREE.Group seller;

//  late Smoke smoke;


  //late THREE.Object3D? me=null;
  late THREE.Group sheeporig;
  late THREE.Group citizen2;
  late var citizen22;
  late var citizen23;
  late var citizen42;
  late var citizen43;

  late var citizen3;
  late var citizen32;
  late var citizen33;
  late var citizen34;
  late var citizen35;
  late var citizen36;
  late THREE.Group wilddog;
  late var cat;
  late THREE.Group child1;
  late var child12;
  late THREE.Group childgirl;
  late var childgirl2;
  late THREE.Group citizen4;
  late THREE.Group citizenoldwoman;
  late THREE.Group citizenf2;
  late THREE.Object3D citizenf22;
  late THREE.Object3D citizenf23oldlady;
  late THREE.Group citizenf3;
  late var citizenf32;
  late var citizenf33;
  late var citizenf34;
  late var citizenoldman;
  late var citizenoldman2;
  late var citizenoldman22;
  late var chicken;
  late var donkeyorig;
  late var donkeypack;
  late var goat;
  late var woodbundle;
  late var instancedWoodbundle;

  late var bedding;
  late var instancedBeddings;
  late var pillow;
  late var instancedPillows;
  late var robes;
//  late var rock;
//  late var fence;
  late var fence2;
  late var sack;
  late var basket;
  late var instancedBasket;
  late var basketwicker;
  late var instancedBasketWicker;
  late var basketwickerfigs;
  late var basketwickerolives;
  late var basketwickerolivesblack;
  late var basketwickerdeepapples;
  late var basketwickerdeeppears;
  late var tannur;
  late var oven;
  late var tablelimestone;
  late var pitchfork;
  late var fence3;
  late var pot;
  late var chisel;
  late var hammer;
  late var saw;
  late var board;
  late var shovel;
  late var plate;
  late var amphora;
  late var cup;
  late var instancedCup;

  late var breadunleaven;
  late var breadleavened;
  late var bread;
  late var clothesline;
  late var table;
  late var firepit;
  late var cistern;
  late var ladder;
  late var loom;
  late var loomweight;
//  late var vegetabletable;
  late var doorhouse2;
  late var mortar;
  late var packdonkeybuckets;
  late var mati;
  late var clotheshanging;
  late var lamp;
  late var matrolled;
  late var instancedMatrolled;
  late var jug;
  late var millstone;
  late var hoe;
  late var cratelentils;
  late var crateclothes;
  late var shopawning;
  late var instancedShopawnings;
  late var bowl;
  late var boxlimestone;
  late var shofar;
  late var flute;
  late var lyrewield;
  late var birdcageorig;
  late var birdcagedoves;
  late var birdcagepigeon;
  late var pigeon;
  late var pigeon3;
  late var dove;
//  late var olivetreesprite;
   var olivetree=null;
  late var priest3;
  late var priest32;
  late var priest33;
  late var priest34;
  late var priest35;
  late var priest36;
  late var priest37;
  late var priest38;
  late var priest3clothed;
  late var priest32clothed;
  late var priest33clothed;
  late var priest34clothed;
  late var priest35clothed;
  late var priest36clothed;
  late var priest37clothed;
  late var priest38clothed;
  late var column;
  var instancedModels=[];
  late var instancedColumns;
  late var instancedColumnsSiloam;
  late var instancedColumnsBethesda;
  late var shewbread;
  late var altargreat;
  late var clothespile;
  late var spear;
  late var seagull;
  late var ring;
  late var instancedRings;
  late var grapevine;
  late var curtain;
  late var chain;
  late var pillar;
  late var instancedPillars;
  late var sheephead;
  late var sheepleg;
  late var meatfrontleg;
  late var  meatchunk;
  late var rib;
  late var intestines;
  late var  shank;
  late var vesselbazichtamid;
  late var vesselbowl;
  late var vesseltray;
  late var vesselpitcher;
  late var vessellist;
  late var doorwood;
  late var doornicanor;
  late var instancedGrass;
  late var instancedOlive;
  late var instancedFigtree;
  late var instancedCyprus;

  late var actorlist;
  late var malelist;
  late var womanlist;
  late var girllist;
  late var childlist;
  late var childrenlist;
  late var manlist;
  late var adultlist;
  late var soldierlist;
  late var walkerlist;

  late THREE.Material? menorahflamemat = null;
  late THREE.Object3D? menorah = null;
  late var lampbronze;
  late var laver;
  late var saltpile;
  late var turban;
  late var turbanwield;
  late var firepan;
  late var trumpet;
  late var donationchest;
  late var instancedDonationchest;
  late var money;
  late var scales;
  late var tablelow;
  late var instancedTablelow;
  late var moneychest;
  late var instancedMoneychest;
  late var parchment;
  late var instancedParchment;
  late var parchmentroll;
  late var instancedParchmentroll;
  late var penreed;
  late var rope;
  late var stool;
  late var instancedStool;
  late var tabletri;
  late var torch;
  late var knifewield;
  late var herbshyssop;
  late var herbsmint;
  late var onions;

  late THREE.Texture? normalcherubum;
  late THREE.Texture? normaltile;
  late THREE.Texture? normaltile2;
  late THREE.Material? bronzemat;
  late THREE.Material? bronzematclean;
  late THREE.Material? silvermaterial;
  late THREE.Material? goldmaterial;
  late THREE.Material? goldmaterialnormal;
  late THREE.Material? goldmaterialpalm;
  late THREE.Texture? normalsalt;

  var waterlist=[];
  late var firealtarblood;
  late var firealtarbloodse;

  List rabbitexts=[];
  List rabbicourtwomen=[];
  List travelsongs=[];
  Map chatsgeneral= {};


  GameStart gamestart = GameStart.roam;//hearth;////bethphage;//////;//womensgate;//;////;/lowercity;
  var progresspersistence=true;

  //57.0,13.0

  static int _liveInstances=0;  // Think this was used to test if two instances running when exit a game

  @override
  void initState() {

    _repaintBoundaryKey = GlobalKey();
    if (widget.gamestart!=null)
      gamestart=widget.gamestart;
    // This is use by roam only
    if (widget.progress!=null) {
      progresspersistence=false;
      gamestart=GameStart.roam;
      gamestartpos[gamestart]=gamestartpos[gamestart][widget.progress];
      if (widget.progress=='tamid')
        Glob.roamtamid=true;
      else if (widget.progress=='ketoret') {
        print("roam ketoret true");
        Glob.roamketoret = true;
      }else if (widget.progress=='sukkot') {
        print("roam sukkot true");
        Glob.roamsukkot = true;
      }
    }

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        data.removeAt(0);
        data.add(threeJs.clock.fps);
        if (kIsWeb||Platform.isIOS||Platform.isAndroid)
          print('fps' + threeJs.clock.fps.toString());
        else
          print('fps' + threeJs.clock.fps.toString()+' call'+threeJs.renderer!.info.render["calls"].toString());
         //   print('calls: ${threeJs.renderer!.info.render["calls"]}  fps: ${threeJs.clock.fps}');
      });
    });
    setup();
    _liveInstances++;
    print("SecondTemplePage instances alive: $_liveInstances");
    super.initState();
  }


  setup() async {

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        assetCursor = await CustomMouseCursor.asset("icons/rosette.png", hotX: 18, hotY: 0);
      } catch (e) {
        print("Custom cursor not available: $e");
      }
    }

    setState(() {
      donemousecursor = true;
    });

    threeJs = THREE.ThreeJS(

      settings: THREE.Settings(
        enableShadowMap: true,
        /*  shadowMapType: THREE.PCFSoftShadowMap,
          toneMapping: THREE.ACESFilmicToneMapping,
          toneMappingExposure: 1*/
      ),
      onSetupComplete: () {
        //  threeJs.renderer?.shadowMap.enabled=true;
        //THREE.Settings(enableShadowMap: true,shadowMapType: THREE.PCFSoftShadowMap);//.PCFSoftShadowMap);//
        //threeJs.renderer?.enableShadowMap: true,
        //shadowMapType: three.PCFSoftShadowMap,
        //  threeJs.renderer?.sortObjects=true;
        // threeJs.renderer?.se
        // threeJs.renderer?.setTransparentSort(sortByDepth);//(a,b)=>a.z-b.z);
      },
   /*   postProcessor: ([dt]) {
        _frameStartUs = _fsw.elapsedMicroseconds;
        threeJs.scene.updateMatrixWorld();
        _matrixUs += _fsw.elapsedMicroseconds - _frameStartUs;   // add: int _matrixUs = 0;
        threeJs.scene.matrixWorldAutoUpdate = false;              // so render() doesn't repeat it
        threeJs.renderer!.clear();
        threeJs.renderer!.setViewport(0, 0, threeJs.width, threeJs.height);
        threeJs.renderer!.render(threeJs.scene, threeJs.camera);
        threeJs.scene.matrixWorldAutoUpdate = true;
        _drawEndUs = _fsw.elapsedMicroseconds;
      },*/
      /*
      postProcessor: ([dt]) {
        _frameStartUs = _fsw.elapsedMicroseconds;
        threeJs.renderer!.clear();
        threeJs.renderer!.setViewport(0, 0, threeJs.width, threeJs.height);
        threeJs.renderer!.render(threeJs.scene, threeJs.camera);
        _drawEndUs = _fsw.elapsedMicroseconds;
      },*/
     /* customRenderer: (scene, camera, texture, dt) async {
        // 1. Submit GL render commands — GPU starts working immediately
        threeJs.angle?.activateTexture(texture);
        threeJs.renderer!.clear();
        threeJs.renderer!.setViewport(0, 0, threeJs.width, threeJs.height);
        threeJs.renderer!.render(scene, camera);

        // 2. While GPU is executing those commands, run your CPU game logic
        // This is the work that was previously happening AFTER the GPU finished
        animate(dt ?? 0);

        // 3. Now present — GPU has had the full duration of step 2 to work
        await threeJs.angle?.updateTexture(texture, null);
      },*/
      setup: initPage,
    );

   // threeJs.renderer!.shadowMap.enabled = false;
   /* threeJs.customRenderer=(scene, camera, texture, dt) async {
      // 1. Submit GL render commands — GPU starts working immediately
      threeJs.angle?.activateTexture(texture);
      threeJs.renderer!.clear();
      threeJs.renderer!.setViewport(0, 0, threeJs.width, threeJs.height);
      threeJs.renderer!.render(scene, camera);

      // 2. While GPU is executing those commands, run your CPU game logic
      // This is the work that was previously happening AFTER the GPU finished
      animate(dt ?? 0);

      // 3. Now present — GPU has had the full duration of step 2 to work
      await threeJs.angle?.updateTexture(texture, null);
    }*/
  }


  @override
  void dispose() {
    timer.cancel();
    threeJs.dispose();
    THREE.loading.clear();
    //controls.dispose();
    _liveInstances--;
    print("SecondTemplePage instances alive: $_liveInstances");

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    print("hotload reassemble");
    horseriding = false;
    hotload(false);

  }


  @override
  Widget build(BuildContext context) {
      /* return KeyboardListener(
        focusNode: _focusNode,
        autofocus: true, // Automatically grab keyboard focus on load
        onKeyEvent: _handleKeyEvent,
           child:*/
    return UserGuidance(
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
            body: Stack(
              children: [

                donemousecursor ? MouseRegion(
                  cursor: assetCursor ?? MouseCursor.defer,//assetCursor,
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: threeJs.build(),
                  ),

                ) : SizedBox.shrink(),
                // _showOverlay && _capturedImage != null?Text("voot"):Text("nnnn"),
                _showOverlay && _capturedImage != null ?
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: _blendOpacity,
                      child: Image.memory(
                        _capturedImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ) : SizedBox.shrink(),
                !OPENWORLD.System.loaded ?
                /*CursorTesterSelectorRegion(
              assetCursor,*/Stack(
                    children: [
                    //  Center(child: Image.asset(
                    //    "icons/ark2.jpg", fit: BoxFit.cover,)),
                      //house2.jpg"),


                      Center(child:
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          child:
                      Container(
                        key: ValueKey<String>(progressimg),
                        decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(progressimg),
                          fit: BoxFit.cover, // Scales the image to fill the container
                        )),
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
                                          child:Column(
                                              children:[
                                              SizedBox(width:300,child:
                                          LinearProgressIndicator(
                                            value: progress/progressmax,
                                            backgroundColor: Colors.grey,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),//Colors.blue),
                                            minHeight: 10, // Thickness of the bar
                                          )),
                                             // ])
                                              ])))),

                                  if (progressmsg!='')
                                    Center(child: SizedBox(width: 400,
                                      child: Container(
                                          margin: EdgeInsets.only(top:30),
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
                                          child:Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children:[
                                                // Newest message first, earlier ones
                                                // below it (slightly dimmed).
                                                if (progressmsgs.isEmpty)
                                                  Text(progressmsg),
                                                for (var i=0; i<progressmsgs.length; i++) ...[
                                                  if (i>0) SizedBox(height: 12),
                                                  Opacity(
                                                      opacity: i==0?1.0:0.65,
                                                      child: Text(progressmsgs[i])),
                                                ]

                                              ])))),
                                  SizedBox(height: 15),

                                ]
                            )
                        )),
                      ))

                      )
                    ]) : Stack(
                    children: [
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
                                        menuobj.extra['touchtrigger']
                                            .triggermenu(
                                            item['command']);
                                      } else {
                                        menuobj.extra['touchtrigger']
                                            .triggermenu(
                                            null);
                                      }
                                    },
                                  ),


                              ]
                          )

                      ) : SizedBox.shrink(),
                      OPENWORLD.System.loaded && !hidewidgets && mapshow && mapx != -1
                          ? Stack(children: [
                        WidgetZoom(
                            heroAnimationTag: 'tag',
                            zoomWidget: Image.asset(
                                mapfile,
                                fit: BoxFit.fitHeight,//scaleDown,
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
                                mapheight - mapmarkersize/2,//40,   // the minus 40 is necessary because you have set the height of the marker as 80
                            top: mapy *
                                (1 * MediaQuery
                                    .of(context)
                                    .size
                                    .height) - mapmarkersize/2,// 40

                            child: Transform(
                              alignment: FractionalOffset.center,
                              transform: Matrix4.rotationZ(
                                THREE.MathUtils.degToRad(OPENWORLD.Camera.turn)
                                    .toDouble(),
                              ), child: Image.asset('assets/maps/marker.png',
                                height:mapmarkersize),//40),
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
                      Expanded(child:
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
                                                  ? ("←  → Key to slide left & right\n" +
                                                  "↑ Key forward  ↓ back  \n") :
                                              ("←Swipe screen left to turn left\n" +
                                                  "Swipe right to turn right→ \n")) +
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
                              !OPENWORLD.System.isDesktop() && OPENWORLD.System.loaded
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
                                         //   innerCircleColor: Colors.red,
                                            drawOuterCircle: false,
                                          ),
                                          arrowsDecoration: JoystickArrowsDecoration(
                                              color: Colors.yellow,//blue,
                                              enableAnimation: false),

                                        ),
                                        stick: Image.asset(
                                          'icons/progressold2.gif',//info.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                       /* stick: JoystickStick(
                                          decoration: JoystickStickDecoration(
                                              color: Colors.yellow,
                                              shadowColor: Colors.white.withOpacity(0.5)
                                          ),
                                        ),*/
                                        listener: (details) {
                                          // print("oo"+details.x.toString()+" "+details.y.toString());
                                          if (OPENWORLD.System.loaded)
                                            this
                                                ._joystick
                                                ?.onStickChange(
                                                details.x, details.y);
                                        },

                                        onStickDragEnd: () {
                                          if (OPENWORLD.System.loaded) this._joystick
                                              ?.onStickUp();
                                          //this._joystick.onStickDown();
                                        },
                                      )))
                                  : SizedBox.shrink(),

                            ])),

                            Column(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              // mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                            OPENWORLD.System.loaded ? Container(
                                      width: 400,

                                      decoration: BoxDecoration(
                                        // border: Border.all(color: Colors.blueAccent)
                                      ),
                                      child: Row(
                                          children: [
                                            Spacer(),

                                            (horseriding||canhorseride) &&
                                                !OPENWORLD.You.immobile
                                                ? IconButton(
                                              tooltip: horseriding
                                                  ? "Dismount your donkey"
                                                  : "Ride donkey",
                                              icon: Image.asset(
                                                  'icons/donkey.png',//mount.png',//eydismount.png',//horse.png',
                                                  width: 50,height:50),//48, height: 48),
                                              iconSize: 30,
                                             /* style: IconButton.styleFrom(
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(0),
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.2),
                                                // <-- Button color
                                                foregroundColor: Colors
                                                    .white, // <-- Splash color
                                              ),*/
                                              color: Colors.white,
                                              onPressed: () {
                                                if (horseriding)
                                                 dismount();
                                                else if (canhorseride)
                                                  mount();
                                              },
                                            )
                                                : SizedBox.shrink(),

                                          /*  loaded && !kIsWeb &&
                                                CLIENT.Connection
                                                    .connect_state ==
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
                                                    backgroundColor: Colors
                                                        .green
                                                        .withOpacity(0.4),
                                                    // <-- Button color
                                                    foregroundColor: Colors
                                                        .white, // <-- Splash color
                                                  ),
                                                  onPressed: () {
                                                    getName();
                                                  },
                                                )) : SizedBox.shrink(),
                                               */
                                      UserGuildanceAnchor(
                                          step: 3,
                                          tag: "Display map of where you are",
                                            child:Tooltip(
                                                message: 'Map of where you are', // The visual text hint that pops up
                                          child:GestureDetector(
                                            onTap: () {
                                              setState(() { mapshow = !mapshow; });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: mapshow ? Colors.white.withOpacity(0.35/3) : Colors.transparent,
                                                boxShadow: mapshow
                                                    ? [BoxShadow(color: Colors.white.withOpacity(0.6/3), blurRadius: 10, spreadRadius: 1)]
                                                    : [],
                                              ),
                                              child: Image.asset('icons/location.png', width: 48, height: 48),
                                            ),
                                          ),
                                          )),

                                            OPENWORLD.System.loaded &&
                                                CLIENT.Connection
                                                    .connect_state ==
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
                                                icon: FaIcon(
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
                                              OPENWORLD.System.loaded &&
                                                  CLIENT.Connection
                                                      .connect_state ==
                                                      CLIENT.Connection
                                                          .CS_CONNECTED &&
                                                  showdisconnect ? IconButton(
                                                tooltip: "Disconnect",
                                                iconSize: 25,
                                                icon: const Icon(
                                                    Icons.link_off),
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
                                            Tooltip(
                                                message: 'Settings', // The visual text hint that pops up
                                                child:GestureDetector(
                                                  onTap: () {
                                                    settings(context);
                                                  },

                                                  child: Image.asset(
                                                    'icons/settings.png',
                                                    width: 35,
                                                    height: 35,
                                                  ),
                                                )
                                            ),

                                            SizedBox(width:5),
                                            Tooltip(
                                                message: 'Information', // The visual text hint that pops up
                                                child:GestureDetector(
                                                  onTap: () {
                                                    help(context);
                                                  },

                                                  child: Image.asset(
                                                    'icons/info.png',
                                                    width: 35,
                                                    height: 35,
                                                  ),
                                                )
                                            ),

                                            SizedBox(width:5),
                                            Tooltip(
                                                message: 'Exit Game', // The visual text hint that pops up
                                                child:GestureDetector(
                                                  onTap: () {
                                                    close();
                                                  },

                                                  child: Image.asset(
                                                    'icons/close.png',
                                                    width: 28,
                                                    height: 28,
                                                  ),
                                                )
                                            ),
                                            SizedBox(width:5),

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


                    ]
                )
                //   Statistics(data: data)
              ],

            ))

    );
  }


  var priestlist = [];

  // Set whether can collide with an actor
  setcancollide(object,cancollide)
  {
    object.extra['cancollide']=cancollide;
  }

  // Set the shoe groupname so can take an actors shows on and off
  setShoesGroup(object,group)
  {
    object.extra['shoesgroup']=group;

  }

  getShoesGroup(object)
  {
    if (object.extra.containsKey('robes')) {
      return "NIL!";  // priests dont wear shoes
    } else if (object.extra.containsKey('shoesgroup'))
      return object.extra['shoesgroup'];
    else
      return "citizen_2";
  }

  // Given a path list, create a path next to it by an offset amount either left or right
  getpathoffset(path, left,offset) {
    var diff = left ? -90 : 90;
    List<List> offsetpath = [];
    for (var i = 0; i < path.length; i++) {
      var pos = path[i];

      var angle;
      if (i == 0) {
        var nextpos = path[i + 1];
        angle = OPENWORLD.Math.getAngleBetweenPoints(
          THREE.Vector2(pos[0], pos[1]),
          THREE.Vector2(nextpos[0], nextpos[1]),
        );
      } else {
        var prevpos = path[i - 1];
        angle = OPENWORLD.Math.getAngleBetweenPoints(
            THREE.Vector2(prevpos[0], prevpos[1]),
            THREE.Vector2(pos[0], pos[1]));
      }
      var newpos = OPENWORLD.Math.vectorMoveForward(
          pos[0], pos[1], angle + diff, offset);
      var list=[newpos.x, newpos.y];
      for (var j=2; j<pos.length; j++)
        list.add(pos[j].toDouble());  // eg if a moveto position like [9.33,2.11,0.0,0.7] itll add all of it
      offsetpath.add(list);
    }
    return offsetpath;
  }


  // bethphage path for your friend
  generatePathSouthFriend() {
    // Get the offset citizenpath
    var left = false;
    var offset = 0.07;

    var  offsetpathu = getpathoffset(citizenpathsouth, left, offset);


    var found = false;
    List<List<double>> offsetpath = [];
    for (var pos in offsetpathu) {
      if (pos[0] < 53.85 && pos[1] > 7) {
        found = true;
      }
      if (found&&pos[1] > -48)//6)//43)
        offsetpath.add(pos);
    }
   // offsetpath.add([-2.10, -45.07]);
  //  offsetpath.add([-3.41, -47.24]);
    offsetpath.add([ -2.46-0.1, -46.5]);
    offsetpath.add([ -4.4,-49.01]);//55, -49.01]);
    return offsetpath;
  }

  // Allow an actor to go through a large text at random
  // [text] is a list of texts eg chapters in the torah and a new one is picked each loop and the [actor] says it
  loopspeech(actor,text,{scale=0.3})
  {
    var verse=OPENWORLD.Math.randPick(text);//rabbitexts);
    var verselines=OPENWORLD.Mob.chopText(verse['text']);
    var positionjson = OPENWORLD.Config.getPositionForObject(actor);
    OPENWORLD.Mob.setSpeech(actor,
        verselines, z:90,
        width: 300,
        clearwhendone: true,
        minwait: 5,
        scale: scale,//0.3,
        randwait: 0,
        callbackonfinish: (actor)
        {
            // In case have switched to new config for the actor in the mean time
            var positionjsonnext = OPENWORLD.Config.getPositionForObject(actor);
            if (actor.visible&&positionjsonnext==positionjson)//&&OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, actor)<)
              loopspeech(actor,text,scale:0.4);
        }
      //   delay:9
    );
  }

  // Generic function to have an actor look pack at the camera
  lookback(actor) {
    if (!actor.extra.containsKey('inlookback')) {
      actor.extra['inlookback']=true;
      var currentturn = OPENWORLD.Space.getObjTurn(actor);
      OPENWORLD.Actor.playAction(
          actor, action: "walkstraightlookright", //clampWhenFinished: true,
          //   stopallactions: true,
          delay: 1.0);
      OPENWORLD.Space.objTurnLerp(
          actor, currentturn + 90, 1, delay: 1.0); //-90, 1, delay: 1.0);
      Future.delayed(
          Duration(
              milliseconds: 5000), () async {
        OPENWORLD.Actor.playAction(
            actor, action: "walk");
        //   clampWhenFinished: true,
        //  stopallactions: true,
        // delay: 5.0);
        OPENWORLD.Space.objTurnLerp(
            actor, currentturn, 1);//, delay: 5.0);
        actor.extra.remove('inlookback');

      });
    }

  }


  // Add a flame to a torch
  addflametotorch(usetorch, castshadow) async {
    var brandfire = new VolumetricFire(
        Glob.fireWidth, Glob.fireHeight, Glob.fireDepth,
        Glob.sliceSpacing,
        threeJs.camera);
    await brandfire.init();
    // _space.worldToLocalSurfaceObj(fire?.mesh, 7.0, 2.0, 0.33); //3.7);
    // brandfire.mesh.scale.x = 5; //0.05;
    //  brandfire.mesh.scale.y = 5; //0.05;
    // brandfire.mesh.scale.z = 5; //0.05;
    brandfire.mesh.position.y = 2; //18;//0.25; //33;
    brandfire.mesh.position.z = 5; //8;//0.25; //33;
    OPENWORLD.Space.objPitch(brandfire.mesh, 20); //-90);
    //scene.add(fire?.mesh);
    usetorch.add(brandfire.mesh);

    OPENWORLD.Updateables.add(brandfire);
    var light = new THREE.PointLight(0xFFA500); //PointLight(0xffffff)

    light.intensity = 0.1; // 0.6;
    light.distance = 0.8;
    light.position.y = 2; //0.33;
    light.position.z = 5; //0.33;
    if (castshadow) {
      light.shadow?.mapSize.width = 64;
      light.shadow?.mapSize.height = 64;;
      light.shadow?.camera?.near = 0.01;
      light.shadow?.camera?.far = 0.5;
      light.castShadow = true;
    }
    OPENWORLD.Light.clock = clock;
    OPENWORLD.Light.addFlicker(light);
    OPENWORLD.Light.addNightOnly(light);
    usetorch.add(light);
  }


  // Increment the progress bar
  addProgress({int inc=1})
  {
    setState(() {
      print("progress"+progress.toString());
      progress+=inc;
      if (gamestartpos[gamestart].containsKey('progressmsg')&&gamestartpos[gamestart]['progressmsg'].length>0) {
         var perc=progress/progressmax;
         final reachedmsgs=<String>[];
         for (var prog in gamestartpos[gamestart]['progressmsg']) {

         //  print('perc'+perc.toString()+" "+prog['progress'].toString()+" "+((progress+1)/progressmax).toString());
           if (perc>=(prog['progress']/100.0)&&(prog['progress']/100.0)<(progress+1)/progressmax) {
             if (prog.containsKey('msg')) {
               progressmsg = prog['msg'];
               // newest message goes on top
               if (!reachedmsgs.contains(prog['msg']))
                 reachedmsgs.insert(0, prog['msg']);
             }
             if (prog.containsKey('img'))
                progressimg=prog['img'];

           }

         }
         progressmsgs=reachedmsgs;
       // {'progress':20,'msg':'yo what up'},
     // {'progress':40,'msg':'heloo up'},

      }

     /* if (progress==30)
        progressmsg='hello, you are on your way';
      else if (progress==60)
        progressmsg='do you think';*/

    });
  }

  // Display text on a model eg the minorah
  /*addMsgToObj(obj, msg, {scale = 0.3, z = 20}) {
    OPENWORLD.Mob.setText(obj, msg, textcolor: Colors.blue,
        scale: scale,
        z: z,
        backgroundopacity: 0); //, fontfamily: "Roboto");
  }*/

  // function gradually eats a piece of unleaven bread over time
  var ineatbread=false;
  eatbread(breadunleaven2,delay,{bitetime=2})
  {
    if (!ineatbread) {
      ineatbread=true;
      print("eat bread");
      var breadportions = [
        'top',
        'bottom',
        'left',
        'right',
        'centerouter',
        'center'
      ];
      for (var i = 0; i < breadportions.length; i++) {
        OPENWORLD.BaseObject.setVisible(breadunleaven2, false,
            groupname: breadportions[i], delay: delay + i * bitetime);
        OPENWORLD.Sound.play(
            path: 'sounds/eat.mp3', volume: 0.3, delay: delay + i * bitetime);
      }
      Future.delayed(Duration(milliseconds: (breadportions.length*bitetime+delay).round()), () async {
        ineatbread=false;
      });

    }
  }

  // Play the splash sound at random
  playSplash({volume=1,delay})
  {
    OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick( ['sounds/splash.mp3','sounds/splash2.mp3','sounds/splash3.mp3']), volume:volume,delay:delay);

  }

  // Return the correct game state depending on the progress
  getusedict()  {
   // print('dict for'+gamestart.toString());
    Map dict=gamestartpos[gamestart];
   // var key=gamestart.toString();
   // print("dict for "+gamestart.toString()+" "+dict.toString());
    if (gamestart!=GameStart.roam&& dict.containsKey('progress')&&dict['progress'].length>0) {
      // So can test without looking up persistence
      print("found progress");
      return dict[dict['progress'][dict['progress'].length - 1]];
    } else {
      /*var currentstate = await OPENWORLD.Persistence.get(key);
      if (currentstate != null && currentstate.length > 0)
        return dict[currentstate[currentstate.length - 1]];
      else*/
      print("found no progress");
      return dict;
    }

  }

  // Save the gamestate persistently so if close the game can restart where left off
  saveGameState(state) async
  {
    // If have test progress dont save the persistence
    var key = gamestart.toString();
    if (progresspersistence) {
      //if (!(gamestartpos[gamestart].containsKey('progress')&&gamestartpos[gamestart]['progress'].length>0)) {
      print("save game " + key + " state " + state);
      var  currentval = await OPENWORLD.Persistence.get(key);
      List<String> current;
      if (currentval == null) {
        current=[];
        await  OPENWORLD.Persistence.set(key, current);
        current = await OPENWORLD.Persistence.get(key);
      } else
        current= currentval.cast<String>();;
      if (!current.contains(state)) {
        print("have save "+state);
        current.add(state);
        await OPENWORLD.Persistence.set(key, current);
      } else
        print("state already exists "+state);
    } else
      print("didnt save game "+key+" state "+state);

  }

  // General call that will allow a function to be called but only once the system is loaded
  // Might only want a donkey to start walking once the game is loaded
  callwhenloaded(Function func)
  {
    var extra=3;
    var cnt=0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (cnt==extra) {
        func();
        timer.cancel();

      } else if (OPENWORLD.System.loaded) {
        cnt+=1;
      }
    });

  }

  // General function that allows a callback to be called only when a conditional function is true
  // Will call the conditional function every second until it is true and then call the callback
  List callwhentrues=[];
  callwhentrue(Function booleanfunction, Function callback,{delay}) {
    if (delay!=null) {
          Future.delayed( Duration(milliseconds: (delay * 1000).round()), () async {
            callwhentrue(booleanfunction,callback);
          });
    } else
    callwhentrues.add([booleanfunction,callback]);

  }

  // General function to allow to neightbours to chat to eachother using chatsgeneral.json list of general chats
  createNeightboursChatting(neighbourx,neighboury,facing, neighbour2x, neighbour2y, gender) async
  {
    var neighbourorig1;
    var neighbourorig2;
    if (gender=='women') {
      neighbourorig1=OPENWORLD.Math.randPick(womanlist);
      neighbourorig2=OPENWORLD.Math.randPick(womanlist,exclude:[neighbourorig1]);
    } else {
      neighbourorig1=OPENWORLD.Math.randPick(manlist);
      neighbourorig2=OPENWORLD.Math.randPick(manlist,exclude:[neighbourorig1]);

    }
    var neighbour = await OPENWORLD.Actor.copyActor(
        neighbourorig1, action: "idle3"); //"shovel");
    // _hotload.add(citizen2iii);
    _hotload.add(neighbour);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        neighbour, neighbourx,neighboury, 0, 2);
    OPENWORLD.Space.objTurn(neighbour, facing);

    var neighbour2 = await OPENWORLD.Actor.copyActor(
        neighbourorig2, action: "idle3"); //"shovel");
    // _hotload.add(citizen2iii);
    _hotload.add(neighbour2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        neighbour2, neighbour2x,neighbour2y, 0, 2);
    OPENWORLD.Space.objTurn(neighbour2, facing-180);

    var inchat=false;
    OPENWORLD.BaseObject.setDistanceTrigger(neighbour,
        dist: 0.4, event: (action) {
          if (action) {
            if (!inchat) {

              inchat = true;
              var chat = OPENWORLD.Math.randPick(chatsgeneral?[gender]);
              var citizenmeetchatterarr = createChat(chat);
              var citizenmeetchatter = citizenmeetchatterarr[0];
              var citizenmeet2chatter = citizenmeetchatterarr[1];
              //  print("found friend" + citizenmeetchatter.toString() + " " +
              //     citizenmeet2chatter.toString());
              var minwait = 4;
              var delay = OPENWORLD.Math.random() * 10;
              OPENWORLD.Mob.setSpeech(
                  neighbour,
                  citizenmeetchatter,
                  z: 110,
                  //0.5
                    scale: 0.4,
                  width: 300,
                  minwait: minwait,
                  clearwhendone: true,
                  randwait: 0,
                  delay: delay);
              OPENWORLD.Mob.setSpeech(
                  neighbour2,
                  citizenmeet2chatter,
                  z: 90,
                  //80,
                  minwait: minwait,
                  clearwhendone: true,
                  //0.5
                    scale: 0.4,
                  width: 300,
                  randwait: 0,
                  delay: delay + 2,
                  callbackonfinish: (actor) {
                    inchat=false;
                  }
              );
            }
          } else {

          }
        });

  }

  // Create a herb seller on a map at position x,y turned herbturn degrees
  createHerbSeller(x,y,herbturn) async {
   // var herbturn = pos[2];
    var mati3 = mati.clone();
    _hotload.add(mati3);
    //hotloadAdd(firsthotload, false, mati3);
    // _hotload.add(mat10);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mati3, x,y, 0.001, 2, normalize2world: true);
    OPENWORLD.Space.objTurn(mati3, herbturn); // 90 + 18);


    var herbseller = await OPENWORLD.Actor.copyActor(
        OPENWORLD.Math.randPick(adultlist), action: "squatwork",
        randomduration: 0.1,
        startat: OPENWORLD.Math.random());
    herbseller.position.x = 0.0;
    herbseller.position.y = 0.0;
    herbseller.position.z = -0.03;
    mati3.add(herbseller);
    // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
    // OPENWORLD.Space.worldToLocalSurfaceObjHide(
    //     herbseller,pos[0],pos[1], 0, 3);
    // _hotload.add(herbseller);
    // OPENWORLD.Space.objTurn(herbseller, herbturn);//-90);

    var herbshyssop4 = herbshyssop.clone();
    mati3.add(herbshyssop4);
    herbshyssop4.position.x = 0.0; // -0.02;
    herbshyssop4.position.y = 0.002;
    herbshyssop4.position.z = 0.02; // forward back -0.04;
    OPENWORLD.Space.objTurn(herbshyssop4, 90);
    // hotloadAdd(firsthotload, false, herbshyssop4);
    // OPENWORLD.Space.worldToLocalSurfaceObjHide(
    //     herbshyssop4, pos[0] - 0.02, pos[1] - 0.04, 0.002, 2);

    var herbshyssop2 = herbshyssop.clone();
    mati3.add(herbshyssop2);
    herbshyssop2.position.x = 0.02; // -0.04;
    herbshyssop2.position.y = 0.002;
    herbshyssop2.position.z = 0.02; // -0.04;
    OPENWORLD.Space.objTurn(herbshyssop2, 90);
    /*
        hotloadAdd(firsthotload, false, herbshyssop2);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            herbshyssop2, pos[0] - 0.02, pos[1] - 0.04 - 0.02, 0.002, 2);
        */

    var herbshyssop3 = herbshyssop.clone();
    mati3.add(herbshyssop3);
    herbshyssop3.position.x = 0.03; // -0.04;
    herbshyssop3.position.y = 0.002;
    herbshyssop3.position.z = 0.02; // -0.04;
    OPENWORLD.Space.objTurn(herbshyssop3, 90);
    /*
        hotloadAdd(firsthotload, false, herbshyssop3);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            herbshyssop3, pos[0] - 0.025, pos[1], 0.002, 2);
        OPENWORLD.Space.setTurnPitchRoll(herbshyssop3, 0, 90, 0);
        */

    var herbsmint4 = herbsmint.clone();
    mati3.add(herbsmint4);
    herbsmint4.position.x = 0.03; // -0.04;
    herbsmint4.position.y = 0.002;
    herbsmint4.position.z = 0.02; // -0.04;
    OPENWORLD.Space.objTurn(herbsmint4, 90);
    /*
        hotloadAdd(firsthotload, false, herbsmint4);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            herbsmint4, pos[0] + 0.02, pos[1] + 0.04, 0.002, 2);
        */

    var herbsmint2 = herbsmint.clone();
    mati3.add(herbsmint2);
    herbsmint2.position.x = 0.04; // -0.04;
    herbsmint2.position.y = 0.002;
    herbsmint2.position.z = 0.02; // -0.04;
    OPENWORLD.Space.objTurn(herbsmint2, 90);
    /*
        hotloadAdd(firsthotload, false, herbsmint2);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            herbsmint2, pos[0] + 0.02, pos[1] + 0.02, 0.002, 2);
        */

    var herbsmint3 = herbsmint.clone();
    mati3.add(herbsmint3);
    herbsmint3.position.x = 0.06; // -0.04;
    herbsmint3.position.y = 0.002;
    herbsmint3.position.z = 0.02; // -0.04;
    OPENWORLD.Space.objTurn(herbsmint3, 90);
    /*
        hotloadAdd(firsthotload, false, herbsmint3);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            herbsmint3, pos[0] + 0.02, pos[1] + 0.01, 0.002, 2);
        // OPENWORLD.Space.objTurn(herbsmint, 18);
        */

    var onions3 = onions.clone();
    mati3.add(onions3);
    onions3.position.x = -0.02; // -0.04;
    onions3.position.y = 0.002;
    onions3.position.z = 0.02; // -0.04;
    OPENWORLD.Space.objTurn(onions3, 90);
    /*
        hotloadAdd(firsthotload, false, onions3);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            onions3, pos[0] + 0.02, pos[1] + 0.04 + 0.02, 0.002, 2);
        */

    var onions2 = onions.clone();
    mati3.add(onions2);
    onions2.position.x = -0.03; // -0.04;
    onions2.position.y = 0.002;
    onions2.position.z = 0.02; // -0.04;
    OPENWORLD.Space.objTurn(onions2, 90);
    /*
        hotloadAdd(firsthotload, false, onions2);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            onions2, pos[0] + 0.02, pos[1] + 0.04 + 0.01, 0.002, 2);
        */
    // OPENWORLD.Space.objTurn(onions, 18);

    var lamp3ii = lamp.clone();
    mati3.add(lamp3ii);
    lamp3ii.position.x = 0.03;
    lamp3ii.position.y = 0.002;
    lamp3ii.position.z = 0.0;
    lamp3ii.rotation.x = 0.0;
    lamp3ii.rotation.y = 0.00;
    lamp3ii.rotation.z = 0.0;
    // OPENWORLD.Space.objTurn(lamp3ii, 90);
    // lamp3ii.scale.setValues(1.0, 1.0, 1.0);
    /*
        hotloadAdd(firsthotload, false, lamp3ii);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            lamp3ii, pos[0] - 0.05, pos[1] - 0.04, 0, 2);
        OPENWORLD.Space.objTurn(lamp3ii, herbturn);
        */

    var lamp3iii = lamp.clone();
    mati3.add(lamp3iii);
    lamp3iii.position.x = 0.05;
    lamp3iii.position.y = 0.002;
    lamp3iii.position.z = 0.0;
    lamp3iii.rotation.x = 0.0;
    lamp3iii.rotation.y = 0.00;
    lamp3iii.rotation.z = 0.0;
    /*
        hotloadAdd(firsthotload, false, lamp3iii);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            lamp3iii, pos[0] - 0.04, pos[1] - 0.01, 0, 2);
        OPENWORLD.Space.objTurn(lamp3iii, herbturn - 4);
        */

  }


  // Create a dove seller at x,y turned at herburn degreees
  createDoveSeller(x,y,herbturn) async {
  //  var herbturn = pos[2];
    var mati3 = mati.clone();
    _hotload.add(mati3);//hotloadAdd(firsthotload, false, mati3);
    // _hotload.add(mat10);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mati3, x,y, 0.001, 2, normalize2world: true);
    OPENWORLD.Space.objTurn(mati3, herbturn); // 90 + 18);


    var birdseller2 = await OPENWORLD.Actor.copyActor(
        OPENWORLD.Math.randPick(adultlist), action: "squatwork",
        randomduration: 0.1,
        startat: OPENWORLD.Math.random());
    birdseller2.position.x = 0.0;
    birdseller2.position.y = 0.0;
    birdseller2.position.z = -0.03;
    mati3.add(birdseller2);
    // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
    // OPENWORLD.Space.worldToLocalSurfaceObjHide(
    //     herbseller,pos[0],pos[1], 0, 3);
    // _hotload.add(herbseller);
    // OPENWORLD.Space.objTurn(herbseller, herbturn);//-90);
    mati3.add(birdcagepigeon.clone());
    mati3.add(birdcagedoves.clone());
    OPENWORLD.BaseObject.setDistanceTrigger(
        mati3, dist: 0.2, event: (action) {
      if (action ) {
        OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/pigeon.mp3','sounds/pigeon2.mp3']), volume: 0.5, delay:OPENWORLD.Math.random()*10);
      }
    });

  }

  /// Converts local (right, forward) offset to world offset.
  /// Angle 0 = North, positive clockwise (compass bearing).
 /* List<num> _localToWorld(num relx, num rely, num angleDeg) {
    final double rad = angleDeg * math.pi / 180.0;
    final double c = math.cos(rad);
    final double s = math.sin(rad);
    // right = (c, -s), forward = (s, c)
    final double ox = relx * c + rely * s;
    final double oy = -relx * s + rely * c;
    return [ox, oy];
  }

  /// Bearing from point A to point B.
  /// 0 = North, 90 = East, 180 = South, 270/-90 = West.
  double _bearing(num x1, num y1, num x2, num y2) {
    final double dx = (x2 - x1).toDouble();
    final double dy = (y2 - y1).toDouble();
    // atan2(east, north)
    double deg = math.atan2(dx, dy) * 180.0 / math.pi;
    if (deg < 0) deg += 360.0;
    return deg;
  }

  double _dist(num x1, num y1, num x2, num y2) {
    final double dx = (x2 - x1).toDouble();
    final double dy = (y2 - y1).toDouble();
    return math.sqrt(dx * dx + dy * dy);
  }
  */

  // Information about the game
  help(BuildContext context) async {
    PackageInfo version=await OPENWORLD.System.getAppVersion();

    showDialog(
      context: context,
       barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
             //  barrierDismissible: false, // user must tap button!
                backgroundColor: Colors.black.withOpacity(0.5),
                titlePadding: EdgeInsets.only(left: 25, right: 25),
                contentPadding: EdgeInsets.only(left: 25, right: 25),
                actionsPadding: EdgeInsets.only(left: 25, right: 25),
                title: const Text('Information', style: TextStyle(fontSize: 22)),
                content: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //crossAxisAlignment:CrossAxisAlignment.

                        children: [

                          // SizedBox(height:10),
                          Text(gamename, style: TextStyle(fontSize: 22, fontWeight:FontWeight.bold)),
                          //fontWeight:FontWeight.bold,
                         // Text("Second Temple 65AD Jerusalem",
                        //      style: TextStyle(fontSize: 15)),
                          SizedBox(height: 10),
                          GestureDetector(
                              onTap: () {
                                launchUrl(Uri.parse(
                                    "https://secondtemple.forthtemple.com"));//org"));
                              },
                              child:
                              Column(children: [
                               Row(children:[
                                 Expanded(child:SizedBox.shrink()),
                                 Column(children:[
                                 SizedBox(height:150,child: Image.asset(
                                'icons/forthtemple.jpg',
                                //height: 240
                              )),
                              Text("© 2026 Forth Temple Ltd",
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold)),
                              Text("All Rights Reserved",
                                  style: TextStyle(fontSize: 17.0)),
                                   Text( "Version:"+version.version+" "+version.buildNumber)
                              ]),
                               //  SizedBox(width:20),
                                 Expanded(child:SizedBox.shrink()),

                                 Column(children:[SizedBox(height:150,child: Image.asset(
                                   'icons/dad.jpg',
                                   //height: 240
                                 )),
                                   Text("Dedicated to my father \n"
                                       "Gerrit Linde 1944-2025")
                                 ]),
                                 Expanded(child:SizedBox.shrink()),

                               ]),
                              //  SizedBox(height: 25),

                              ])),
                          // Divider(color: Colors.black),
                          SizedBox(height: 55),
                          Container(
                            width:600,
                          child:Column(
                            children:[
                          Text('Credits'),
                          Text('“Heat” by Tsorthan Grove (opengameart.org/content/heat),\n'
                              '      Licensed under CC BY 4.0 (creativecommons.org/licenses/by/4.0). Trimmed\n'
                              'staccato [2018-08-01 140749].aif by shogood_shofar -- https://freesound.org/s/435894/ \n'
                              '      License: Attribution 3.0 Trimmed\n'
                              'car burning.wav by Hssmusic -- https://freesound.org/s/164939/ \n'
                              '      License: Attribution 4.0 Trimmed\n'
                              'Water sizzling on hot stove by VlatkoBlazek -- https://freesound.org/s/264811/ \n'
                              '      License: Attribution 4.0 Trimmed',
                              style:TextStyle(fontSize: 12.0)),
                              TextButton(
                                child: const Text('Licences'),
                                onPressed: () async {
                                  PackageInfo version=await OPENWORLD.System.getAppVersion();
                                  showLicensePage(
                                    context: context,
                                    applicationName: version.installerStore,//'Second Temple',
                                    applicationVersion: version.version+" "+version.buildNumber,//'1.0.0',
                                    applicationLegalese: '© 2026 Forth Temple Ltd',
                                  );
                                  //   Navigator.of(context).pop();
                                },
                              ),
                           ])
                          )

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


  // Settings for the game like sound and fullscreen
  settings(BuildContext context) async {

    bool soundon = !OPENWORLD.Sound.mute;
    bool musicon = !OPENWORLD.Musics.mute;
    bool fullscreen=await OPENWORLD.Persistence.get("fullscreen",def:true);
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
                     if (!kIsWeb&&(Platform.isLinux||Platform.isWindows||Platform.isMacOS))
                       Row(
                          children: [
                            Checkbox(
                              // tristate: true,
                              value: fullscreen,
                              onChanged: (value) {
                                setState(() {
                                  fullscreen = value!;
                                });
                              },
                            ),
                            Text('Full screen'),
                           // if (!kIsWeb&&Platform.isLinux)
                          //    Text(' - change appears when game restarted', style:TextStyle(fontSize: 12))
                          ]),
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
                    /*  kIsWeb ? SizedBox(width: 300, child: TextField(
                        autofocus: true,
                        controller: _textFieldController,
                        decoration: InputDecoration(hintText: "Coords"),
                      )) : SizedBox.shrink()*/
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
                    onPressed: () async {
                      OPENWORLD.Persistence.set("mute", !soundon);
                      OPENWORLD.Sound.setMute(!soundon); //mute=!soundon;
                      OPENWORLD.Persistence.set("musicmute", !musicon);
                      OPENWORLD.Musics.setMute(!musicon);
                      OPENWORLD.Room.mute(!soundon);
                      OPENWORLD.Persistence.set("fullscreen", fullscreen);
                      if (_textFieldController.text.contains(",")) {
                        var pos = _textFieldController.text.split(",");
                        OPENWORLD.Space.worldToLocalSurfaceObj(
                            threeJs.camera, double.parse(pos[0]), double.parse(pos[1]),
                            OPENWORLD.Camera.cameraoffset);
                      }
                      Navigator.of(context).pop();
                     // if (kIsWeb||!Platform.isLinux) {
                      if (!kIsWeb&&OPENWORLD.System.isDesktop()) {
                        bool wasFullscreen = await windowManager.isFullScreen();
                        if (fullscreen != wasFullscreen) {
                          await windowManager.setFullScreen(fullscreen);
                          if (!fullscreen) {
                            await windowManager.show();
                            await windowManager.focus();
                          }
                        }
                      }
                    //  }


                     // Future.delayed( Duration(milliseconds: 1000), () async {
                       // await windowManager.setFullScreen(fullscreen);
                      //});


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

  // Dialog to chat in multiplayer - is redundant in this version
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
   // final scl=0.0025*0.5;
    actor.scale.setValues(actorscale,actorscale,actorscale);//0.0025*0.5, 0.0025*0.5, 0.0025*0.5);

  }

  // Set actor chatter with default settings
 /* setActorChatter(actor, chatter) {
    OPENWORLD.Mob.setChatter(
        actor, chatter, start: false, z: 100, scale: 0.3, width: 400);

    OPENWORLD.BaseObject.setDistanceTrigger(actor, dist: 1.0, event:(action) {
      if (action) {
        OPENWORLD.Space.faceObjectAlways(actor, threeJs.camera);
        OPENWORLD.Mob.startChatter(actor);
      } else {
        OPENWORLD.Mob.pauseChatter(actor);
        OPENWORLD.Mob.clearText(actor);
        OPENWORLD.Space.removeFaceObjectAlways(actor);
        OPENWORLD.Space.objTurnLerp(actor, OPENWORLD.Mob.getInitTurn(actor), 1);
      }
    });
  }*/


  // Function creates chat between two actors so the setspeech of the two actors are in sync
  createChat(chat,{blank=''})
  {
    var lastkey;
    if (chat[0].keys.first is String)
       lastkey="0";
    else
      lastkey=0;

    var citizenmeetchatter=[];
    var citizenmeet2chatter=[];
    for (var line in chat!) {

      var key=line.keys.first;//.toInt();

      if (key==0||key=="0") {
        citizenmeetchatter.add(line[key]);
        if (lastkey==key)
          citizenmeet2chatter.add(blank);
      } else {
        citizenmeet2chatter.add(line[key]);
        if (lastkey==key)
          citizenmeetchatter.add(blank);

      }
      lastkey=key;
    }
    return [citizenmeetchatter,citizenmeet2chatter];

  }

  // mount horse
  mount() {
      if (OPENWORLD.You.indoors()) {
        print("mount did not mount because indoors");
        return;
      }
      setState(() {
        horseriding = true;

        //  roomname = 'E Dismount';
      });
      if (OPENWORLD.System.isDesktop()&&horsekeyboardcallback!=null)
        horsekeyboardcallback!.type=OPENWORLD.KeyboardCallbackType.unconditional;//alwaystrue=true;

      var horsepos=OPENWORLD.Space.localToWorldObj(_horse);
      OPENWORLD.Space.worldToLocalSurfaceObjLerp(
          threeJs.camera,
          horsepos.x, //worldpos.x,
          horsepos.y, // worldpos.y + 0.52,
          Glob.defaultcameraoffset, 0.5);
      OPENWORLD.You.drag = 0.2;
      var horseturn=OPENWORLD.Space.getObjTurn(_horse);
      OPENWORLD.Space.objTurnLerp(threeJs.camera,horseturn, 0.5);
     // OPENWORLD.Space.objTurnLerp(_horse, OPENWORLD.Camera.turn, 0.5);
      Future.delayed(Duration(milliseconds: 500), () async {
        OPENWORLD.You.drag = 1;
       /* if (!horseridingcloploaded) {
          horseridingcloploaded = true;
          horseridingclop = OPENWORLD.Sound.getAudioPlayer();
        }*/
        threeJs.camera.add(_horse.extra['riding']);
        // _horse.visible=false;
        _hotload.remove(_horse);
        //  print("mmmm"+_horse.parent.toString());
      /*  OPENWORLD.Sound.play(
            sound: horseridingclop,
            path: "sounds/horseclop.mp3",
            volume: 0.5,
            loop: true,
            fadein: 2,
            delay: 2);*/

        OPENWORLD.You.speed = horsespeed;

        //OPENWORLD.Sound.play(path: 'sounds/horse.mp3', volume: 0.5);
      });

      return true;

  }

  // Dismount the horse
  // offset if positive say 0.1 means the camera is offset left 0.1 of the horse
  dismount({offset}) {//}{left}) {
    print("dismount");
    if (horseriding) {
      print("dismount riding");
      var worldpos = OPENWORLD.You
          .getWorldPos();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          _horse,  worldpos.x,worldpos.y,0,6);//-25.49, 116.86,0,6);//12.67, 5.22, 0, 6); // 9.8,1.1, 0.14,3); //3.42);
      var dismountpos;
      if (offset == null || offset==0.0) // !left)
        dismountpos = OPENWORLD.Math.vectorMoveForward(
            worldpos.x, worldpos.y, OPENWORLD.Camera.turn, -0.18);//52);
      else {
        // For case of gabriel where want to dismount side saddle
        dismountpos = OPENWORLD.Math.vectorMoveForward(
            worldpos.x, worldpos.y,       OPENWORLD.Camera.turn-90, offset);
       // dismountpos = OPENWORLD.Math.vectorMoveForward(
       //     worldpos.x, worldpos.y,       OPENWORLD.Camera.turn, 0.1);
      //  dismountpos = OPENWORLD.Math.vectorMoveForward(
       //     dismountpos.x, dismountpos.y, OPENWORLD.Camera.turn, 0.2);
      }
      OPENWORLD.Space
          .worldToLocalSurfaceObjLerp(
          threeJs.camera,
          dismountpos.x, //worldpos.x,
          dismountpos.y, // worldpos.y + 0.52,
          Glob.defaultcameraoffset, 0.5);
      horseriding = false;
      if (OPENWORLD.System.isDesktop()&&horsekeyboardcallback!=null)
        horsekeyboardcallback!.type=OPENWORLD.KeyboardCallbackType.conditional;//alwaystrue=false;

      OPENWORLD.You.speed = defaultspeed;
     // horseridingclop.stop();
      threeJs.camera.clear();  // remove horse
      OPENWORLD.Space.objTurn(_horse,OPENWORLD.Camera.turn,normalize2world: true);
      _hotload.add(_horse);
      OPENWORLD.Camera.cameraoffset = Glob.defaultcameraoffset;
      return true;
     // OPENWORLD.Sound.play(path: 'sounds/horse.mp3', volume: 0.5);
     /* Future.delayed(Duration(
          milliseconds: (1000)
              .round()), () async {



      });*/
    } else {
      print("dismount not riding");

      //  callHorse();
    }
  }

  //  Create a horse keypress callback so that when a player presses 'E' they mount the horse if in the vicinity
  OPENWORLD.KeyboardCallback? horsekeyboardcallback=null;

  horseKeypress()
  {
    print("in add horsekeypress");
    if (OPENWORLD.KeyboardCallbacks.findByObject(_horse)==null) {
      print("adding horse keypress");
      horsekeyboardcallback=OPENWORLD.KeyboardCallbacks.createKeyboardCallback(
          'E', object: _horse, 0.5,facingdiff: 50,
              (keyboardcallback) {
            print("horse keypress" + keyboardcallback.toString()+" "+keyboardcallback.facingdiff.toString());
            if (!horseriding) {
              //var worldpos = OPENWORLD.You.getWorldPos();
              //var horsepos = OPENWORLD.Space.localToWorldObj(_horse);
              //if (OPENWORLD.You.level == 0 &&
              //    OPENWORLD.Math.vectorDistance(horsepos, worldpos) < 1) // never ride a donkey while not on ground level
               if ( mount()) {
               //  keyboardcallback.facingdiff = null;
                 print("mount keyboard press");
               //  keyboardcallback.alwaystrue=true;
               }
            } else {
              print("dismount");
              if (dismount()) {
                print("dismount keyboardpress");
               // keyboardcallback.facingdiff = 50.0;
              }
            }
          });
    }
  }

  /*
  speedUp(timeFactor) async {
    if (timeFactor>1&&!_showOverlay) {
      print("snapshot");
      final boundary = _repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(
            format: ui.ImageByteFormat.png);
        if (byteData != null) {
          print("snapshot set");
          setState(() {
            _blendOpacity = 1.0;
            _capturedImage = byteData.buffer.asUint8List();
            // print("xxx" + _capturedImage.toString());
            _showOverlay = true;

          });
          Future.delayed(Duration(
              milliseconds: (100)
                  .round()), () async {

              setState((){
                frameTimeFactor = timeFactor;//4.0;
              });

          });
        }
      }
    } else if (timeFactor<=1.0&&_showOverlay){
      frameTimeFactor=1.0;
      if (_showOverlay && !_isBlending) {
        _isBlending = true;
        _blendStartTime = DateTime.now();
      }
    }

  }
*/
  // Add an actor to the config list setting its name so it can be used in config
  configAddActor(name,actor,{scale, z})
  {
    OPENWORLD.Config.config['objects'].add({
      'name': name,
      'object': [
        {
          'type': 'actor',
          // 'filename': 'assets/actors/citizen/citizen4.glb',
          // 'shareanimations':'citizen',
          'z':z==null?actoroffset:z,
          's': scale==null?actorscale:scale,//0.01,
          // 't': 90
        }
      ]
    });
    OPENWORLD.Config.setObject(name,actor);
  }

  // Given a list of people find the closest person to that point and get the angle to the closest so that looks like people are talking to eachother
  closestPersonAngle(points) {
    for (var i=0; i<points.length; i++) {
      var closestdist=999999.0;
      var closestind=-1;
      for (var j=0; j<points.length; j++) {
        if (j!=i) {
          var dist=(points[i][0]-points[j][0]).abs()+(points[i][1]-points[j][1]).abs();
          if (dist<closestdist) {
            closestdist=dist;
            closestind=j;
          }
        }
      }
      var angle=OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector2(points[i][0],points[i][1]), THREE.Vector2(points[closestind][0],points[closestind][1]));
      points[i].add(angle);
    }
    return points;
  }

  // Create a set of points for a crowd in the area of minx,miny to maxx,maxy with a certain density never closer than mindist
  // Also has clustering so that people appear to cluster in groups
  List<List<double>> createCrowdPoints(
      minx,
      maxx,
      miny,
      maxy,
      density,  // people per unit squared
     mindist,  // closest allowed distance to another person
      List exclude,  {clusterlevel=0.6}
      ) {
    final List<List<double>> points = [];

    // 1. Calculate the dimensions and area of the bounding box
    final double width = maxx.toDouble() - minx.toDouble();
    final double height = maxy.toDouble() - miny.toDouble();
    final double area = width * height;

    // 2. Determine how many points to *attempt* based on density
    final int totalPointsToGenerate = (area * density.toDouble()).round();

    // 3. Generate random points, checking exclusion zones AND min-distance
    var lastx=0.0;
    var lasty=0.0;
    for (int i = 0; i < totalPointsToGenerate; i++) {
      var x,y;
      if (OPENWORLD.Math.random()<clusterlevel&&!(lastx==0&&lasty==0)) {
        // Have some clustering so people arent just randomly spread
        var spread=OPENWORLD.Math.randFloatSpread(mindist*5);
        if (spread<0)
          spread-=mindist;
        else
          spread+=mindist;
        x=lastx+spread;//OPENWORLD.Math.randFloatSpread(mindist*3);
        if (x<minx)
          x=minx.toDouble();
        else if (x>maxx)
          x=maxx.toDouble();
         spread=OPENWORLD.Math.randFloatSpread(mindist*5);
        if (spread<0)
          spread-=mindist;
        else
          spread+=mindist;

        y=lasty+spread;//OPENWORLD.Math.randFloatSpread(mindist*3);
        if (y<miny)
          y=miny.toDouble();
        else if (y>maxy)
          y=maxy.toDouble();
      } else {
        x = minx.toDouble() + (OPENWORLD.Math.random() * width);
        y = miny.toDouble() + (OPENWORLD.Math.random() * height);
      }

      // Check exclusion zones (zone = [cx, cy, size])
      bool isExcluded = false;
      for (final zone in exclude) {
        var width;
        var height;
        if (zone.length==3) {
          width = zone[2];
          height = zone[2];
        } else {
          width = zone[2];
          height = zone[3];
        }

        //if ((zone[0] - x).abs() < zone[2] / 2 &&
        ///(zone[1] - y).abs() < zone[2] / 2) {
        if ((zone[0] - x).abs() < width / 2 &&
            (zone[1] - y).abs() < height / 2) {
          isExcluded = true;
          break;
        }
      }
      if (isExcluded) continue;

      // Check minimum distance against already-accepted points
      bool tooClose = false;
      for (final p in points) {
        final double dx = p[0] - x;
        final double dy = p[1] - y;
        final double distSq = dx * dx + dy * dy;
        if (distSq < mindist * mindist) {
          tooClose = true;
          break;
        }
      }
      if (tooClose) continue;

      // Point is valid — round and add
      final double roundedX = double.parse(x.toStringAsFixed(2));
      final double roundedY = double.parse(y.toStringAsFixed(2));
      points.add([roundedX, roundedY]);
      lastx=roundedX;
      lasty=roundedY;
    }

    return points;
  }

  // Picks a random spot in positions and then constructs a mini position 2 back and 2 forward and have pool position actor
  // walk back and forwards between those positions
  // uses config actors so can have a lot of them
  createWalkers(positions,numwalkers, walkerlist, loop)
  {
    var spreadx=0.05;//25;
    var spready=0.25;//25;  // fudge to stop jumping up into the sky
    var v=positions[0]['v'];
    var posindexes = [];
    for (var i = 0; i < positions.length; i++)
      if (positions[i].containsKey('p')&&!positions[i].containsKey('randx')&&!positions[i].containsKey('randy')) {
        posindexes.add(i);
      }
    var positionsperwalker=[];
    for (var j = 0; j < numwalkers; j++) { // walker in walklist) {

      //var startposition=OPENWORLD.Math.randPick(positions);
      var ind;
      var firstind;
      var lastind;
      if (loop) {
        ind = OPENWORLD.Math.randInt(posindexes.length);
        firstind = (ind - 2) % posindexes.length;
        lastind = (ind + 2) % posindexes.length;
      } else{
        ind = OPENWORLD.Math.randInt(posindexes.length-4)+2;
        firstind = ind - 2;
        lastind = ind + 2;
      }
      var firstindex = posindexes[firstind];
      var lastindex = posindexes[lastind];
      List<Map> newpositions = [];
      List<Map> newpositions2 = [];
      int totalSteps = (lastindex - firstindex) % positions.length;
      for (int i = 0; i <= totalSteps; i++) {
        int currentindex = (firstindex + i) % positions.length;
        var position = positions[currentindex];
        var newposition={};
        var newposition2={};
        newposition['p']=position['p'].toList();
        newposition['v']=position['v'];
        if (position.containsKey('l'))
          newposition['l']=position['l'];
        // var newposition = {...position};
        ///var newposition= position.map(
        //      (key, value) => MapEntry(key, Map.of(value)),
        //);
     /*   newposition['p']?[0] = position['p'][0].toDouble() +
            OPENWORLD.Math.randFloatSpread(
                0.3); // to dont walk through eachother*/
        newposition['p']?[0] = position['p'][0].toDouble();
        newposition['p']?[1] = position['p'][1].toDouble();
        newposition2=Map.of(newposition);
        // randx so can switch off randspread and can transition to level correctly
        if (!position.containsKey('randx')||position['randx']) {
          newposition['p']?[0] += OPENWORLD.Math.randFloatSpread(spreadx); // to dont walk through eachother
          newposition2['p']?[0] += OPENWORLD.Math.randFloatSpread(spready); // to dont walk through eachother
        }// else
         // newposition['p']['randx']=false;
        if (!position.containsKey('randy')||position['randy']) {
          newposition['p']?[1] += OPENWORLD.Math.randFloatSpread(spreadx);
          newposition2['p']?[1] += OPENWORLD.Math.randFloatSpread(spready);
        }// else
       //     newposition['p']['randy']=false;

        newpositions.add(newposition);
        newpositions2.add(newposition2);  // reduce chance of colliding - create loop on way back this different
      }
      for (var k=newpositions2.length-2; k>=1; k--) {
        newpositions.add(newpositions2[k]);
      }

      positionsperwalker.add(newpositions);
      List<dynamic> startpos=[];
      var pos;
      //  var nextind;
      var level=0;
      if (OPENWORLD.Math.random() < 0.5) {
        pos = OPENWORLD.Math.interpolateTwoPoints(
            newpositions[1]['p'], newpositions[2]['p'],
            0.5 + OPENWORLD.Math.random() * 0.5);
        //  print("voot"+newpositions[1]['p'].toString()+" "+ newpositions[2]['p'].toString());
        //  nextind=2;
        if (newpositions[1].containsKey('l')&&newpositions[2]['l']!=null)
          level=newpositions[1]['l'];
      } else {
        pos = OPENWORLD.Math.interpolateTwoPoints(
            newpositions[2]['p'], newpositions[3]['p'],
            OPENWORLD.Math.random() * 0.5);
        if (newpositions[2].containsKey('l')&&newpositions[3]['l']!=null)
          level=newpositions[2]['l'];
        //  print("vootnn"+newpositions[2]['p'].toString()+" "+ newpositions[3]['p'].toString());
        // nextind=3;
      }
    //  if (!newposition['p'].containsKey('randx')||newposition['p']['randy'])
      pos[0] += OPENWORLD.Math.randFloatSpread(spreadx);
      pos[1] += OPENWORLD.Math.randFloatSpread(spready);
      startpos.add(pos[0]);
      startpos.add(pos[1]);
      startpos.add(level);
     /* if (newpositions[2].containsKey('l')&&newpositions[2]['l']!=null)
        startpos.add(newpositions[2]['l']);
      else
        startpos.add(0);*/
      /* var angle=OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(
            startpos[0].toDouble(), startpos[1].toDouble(), 0.0),
            THREE.Vector3(positions[nextind]['p'][0].toDouble(),
                positions[nextind]['p'][1].toDouble(), 0.0));
*/
      // var index = 2; //posindexes[ind];//OPENWORLD.Math.randPick(posindexes);

      //print("mmmm"+j.toString()+" "+startpos.toString()+" "+newpositions.toString());

      OPENWORLD.Config
          .config['positions']['poolpositions'][2]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(
                walkerlist[j % walkerlist.length]),
            //citizen3),
            'p': [
              startpos[0],//+ OPENWORLD.Math.randFloatSpread(0.3),
              startpos[1],// + OPENWORLD.Math.randFloatSpread(0.3),
              0
            ],
            'l':startpos[2],//level,
            //positions[index]['p'][0]+OPENWORLD.Math.randFloatSpread(0.3),positions[index]['p'][1]+OPENWORLD.Math.randFloatSpread(0.3),0],//-5.79, -13.06, 0], //3.2,-13.26,0],
            // Why must I do this to get the correct turn?
            't': 0,//angle,
            //180,
            //   't': OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(positions[index]['p'][0].toDouble(),positions[index]['p'][1].toDouble(),0.0),
            //      THREE.Vector3(positions[lastindex]['p'][0].toDouble(),positions[lastindex]['p'][1].toDouble(),0.0)), //180,
            'action': "idle",
            'randomduration': 0.1,
            "lerpopacity": 1,
            "label": j,
            "labelstartpos": startpos,
            // "labelangle":angle,
            "callbackonvisible": (actor) {
              if (gamestart==GameStart.bethphage)
                 setcancollide(actor,true);

              var positionjson = OPENWORLD.Config.getPositionForObject(actor);
              OPENWORLD.Space.resetRot(actor);
              // print("labell"+positionjson!['label'].toString());
              //  actor.extra['walker']=true;
              var newpositions=positionsperwalker[positionjson!['label']].toList();
              var startpos=positionjson!['labelstartpos'];
              newpositions.insert(2,{"p":[startpos[0],startpos[1],0],"v":v,"l":startpos[2]});
              newpositions.add({"action":"idle3","time":10});
              newpositions.insert(0,{"action":"idle3","time":10});

              //var worldpos=OPENWORLD.Space.localToWorldObj(actor);
              //  print("callbackonvis"+positionjson!['label'].toString()+" "+worldpos.toString()+" "+newpositions.toString());
              //    OPENWORLD.Space.objTurn(actor, positionjson!['labelangle']);
              OPENWORLD.Mob.moveToLoop(
                actor,
                newpositions,
                index: 3,// 3 because have inserted action idle at zero index !
                action: "walk",
                //   facenow:true,
               // looptype: OPENWORLD.Mob.LoopTypeReverseLoop, //.LoopTypeStop,
                surfaceonly: true,
                //   randomposition:true,
                //   level:1

                //   stopaction: "idle3",
                // delay:finishedtime
                // facedir: false
              ); // fadeout:null);//fadein:0.5); //
            },
            "callbackonhide": (actor) {
              if (gamestart==GameStart.bethphage)
                setcancollide(actor,false);

              OPENWORLD.Mob.removeObjectFromMoveTo(actor);
              // OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
            }
          });
    }


  }

  Future<void> initPage() async {

    ///threeJs.renderer!.shadowMap.autoUpdate = false;
    //threeJs.renderer!.shadowMap.needsUpdate = true;
   /* threeJs.windowResizeUpdate = (Size size) {
      print('resize update'+size.toString());
      threeJs.renderer?.resetState();
     // threeJs.renderer?.resetState();

    };*/
    OPENWORLD.System.active = true;
    if (kIsWeb)
      OPENWORLD.Persistence.gamename = "secondtemple"; // So that if two games in web wont mix up cookies in browser
    /*  OPENWORLD.Time.setTime(await OPENWORLD.Persistence.get("time",
        def: OPENWORLD.Math.random() *
            24));*/ //OPENWORLD.Math.random()*24);//);//12.0); //);
    // Set the game state if using progress persistence
    if (progresspersistence) {
      // Save the game state as go along otherwise use progress specified in gamestartpos
      // Here you are going through each game journey and getting the persistent game start for each game
      for (var gamekey in gamestartpos.keys) {
        var currentstate = await OPENWORLD.Persistence.get(gamekey.toString());
        if (currentstate != null && currentstate.length > 0) {
          print("have found gamestart "+gamekey.toString()+" progress "+currentstate.toString()+" "+currentstate.length.toString());
          // return dict[currentstate[currentstate.length - 1]];
          gamestartpos[gamekey]['progress'] = currentstate;
        } else {
          List<String> currentstate=[];
          gamestartpos[gamekey]['progress'] = currentstate;
        }
      }

    }
    Map dict=gamestartpos[gamestart];
    if (dict.containsKey('time'))
      OPENWORLD.Time.setTime(dict['time']);//-4);//+4);
    else
      OPENWORLD.Time.setTime(0);//-4);//+4);
    OPENWORLD.Time.daylength = 24;//1.0; // Takes an hour to do 24 hours

    OPENWORLD.Room.init();

    // Make player faster if on smartphone
   /* if (!kIsWeb) {
      defaultspeed *= 1.5; //8; //2m/s
    }*/
    OPENWORLD.You.speed = defaultspeed;

    // Set the client game url
    _session = CLIENT.Session(
        "https://forthtemple.com/secondtemple/serverdart/secondtemple.php");

    threeJs.camera = THREE.PerspectiveCamera(50, threeJs.width / threeJs.height, 0.01, 4000);
    OPENWORLD.Camera.init(threeJs.camera, Glob.defaultcameraoffset, threeJs.width, threeJs.height);

    OPENWORLD.Texture.defaultfontfamily = 'NanumMyeongjo';

    threeJs.camera.position.y = 999;

    // Set must wait 100ms when has triggered that touched an object
    OPENWORLD.BaseObject.touchtriggerwait = 0.1;

    clock = THREE.Clock();

    threeJs.scene = THREE.Scene();
    threeJs.scene.rotation.order = THREE.RotationOrders.yxz;//"YXZ";

    _hotload.clear();
    threeJs.scene.add(_hotload);

    // Set the ambient light in the scene
    var ambience = new THREE.AmbientLight(0x666666);
    threeJs.scene.add(ambience); //222222 ) );

    print("create sky");

    var skyGeo = THREE.SphereGeometry(-1000, 32, 15);
    // uniforms['topColor']['value']= hemiLight.color.getHex();//.groundColor;
    var skyMat = new THREE.ShaderMaterial.fromMap(SkyShader);

    var sky = THREE.Mesh(skyGeo, skyMat);
    sky.name='skymesh';
   // sky.position.y=-200;

    threeJs.scene.add(sky);

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

    var sunlight = new THREE.DirectionalLight(0x888888,1.0);//.PointLight(0x888888);///.PointLight(0x888888); //ffffff);
    sunlight.target=threeJs.camera;
   // Set sun shadows
    sunlight.shadow?.mapSize.width = 1024;
    sunlight.shadow?.mapSize.height = 1024;
    sunlight.shadow?.camera?.near = 0.01;
    sunlight.shadow?.camera?.far = 500;
    sunlight.castShadow = true;

    threeJs.scene.add(sunlight);
    //sunlight.shadow?.focus = 10;
    sunlight.shadow!.radius=1;

    var d=3.0;
    sunlight.shadow!.camera!.right =d;
    sunlight.shadow!.camera!.left = - d;
    sunlight.shadow!.camera!.top	= d;
    sunlight.shadow!.camera!.bottom = - d;


    // Specify the maps for the game
    // Each map has an map image with two points with a world position and corresponding pixel position on the map
    print("create maps");
    var maps = [
        OPENWORLD.MapItem('assets/maps/maplarge.jpg',
            worldx: 12.94, //-7.61,
            worldy:59.75,
            imagex:576,
            imagey: 309+70,
            worldx2: -43.96, //11.05,
            worldy2: -48.77,//-12.99,
            imagex2: 212,//371,
            imagey2: 996+70),//450),

        OPENWORLD.MapItem('assets/maps/map.jpg',
            worldx: 0.47,
            worldy: 3.48,
            imagex: 63,
            imagey: 53,
            worldx2: 9.06,
            worldy2: -2.0,
            imagex2: 1061,
            imagey2: 680)
      ];
    OPENWORLD.Maps.init(maps);

      // Initialise music with 4 tunes
      // Hatikvah has the highest chance of playing
    print("create music");
    var musics = [
        //OPENWORLD.MusicItem('sounds/hatikvah.mp3', chance: 0.5),
        OPENWORLD.MusicItem('sounds/harp.mp3', chance: 0.1),
        OPENWORLD.MusicItem('sounds/harp2.mp3', chance: 0.1),
        OPENWORLD.MusicItem('sounds/harp3.mp3', chance: 0.1),
      ];
    print("init music");
    OPENWORLD.Musics.init(musics);

    // Change sound mute based on settings
    print("set mute");
    OPENWORLD.Musics.setMute(
          await OPENWORLD.Persistence.get("musicmute", def: false));
    OPENWORLD.Sound.setMute(
          await OPENWORLD.Persistence.get("mute", def: false));
      // Initialize the time with the sunsphere, skymat and ambience so that can change these based upon the time of day giving a realistic sky
      print("init time");
   //   OPENWORLD.Time.init(sunSphere, skyMat, ambience);
    OPENWORLD.Time.init(sunlight, skyMat, ambience);
  //  OPENWORLD.Time.init(null, skyMat, ambience);

    OPENWORLD.Updateables.init();
    OPENWORLD.BaseObject.init();
    OPENWORLD.Actor.init();
    OPENWORLD.Light.init();
    OPENWORLD.Obstacles.init();
    OPENWORLD.Portals.init();
    OPENWORLD.KeyboardCallbacks.init();
    Tree.init();
    Vegetation.init();

    doorways=[];

    // Load the terrain that everything is place on top of
    print("load terrain"); //+OPENWORLD.Space.getMesh().toString());//_mesh.toString());

    THREE.Group? mesh = await AssetPack.loadOBJ(
        'assets/models/temple/temple.obj',
        mtlPath: 'assets/models/temple/temple.mtl');
  //  THREE.Group? mesh = await loader.fromAsset(
   //       'assets/models/temple/temple.obj');

     // THREE.Group?  mesh = await OPENWORLD.Model.createModel(
     //  'assets/models/temple/temple1251.glb');//r/horn.glb');
/*  this sort of works but the terrainsurface is bright white ex

  var gltfLoader = THREE.GLTFLoader();
    var gltfResult = await gltfLoader.fromAsset('assets/models/temple/temple1251.glb');

// Step 1: Update all world matrices before flattening the hierarchy
    gltfResult!.scene.updateWorldMatrix(true, true);

// Step 2: Flatten the nested GLB scene into a flat Group.
// Space.init() expects direct Mesh children (same structure as OBJLoader output).
// We bake each mesh's world transform in so positions are correct at the top level.
    THREE.Group mesh = THREE.Group();
    gltfResult.scene.traverse((child) {
      if (child is THREE.Mesh) {
        var clone = child.clone();
        clone.name = child.name; // Preserve the name so Space.init() finds "surface", "wall" etc.

        // Bake the world transform into the clone's local matrix.
        // Since the clone has no parent, its local transform must equal the world transform.
        clone.applyMatrix4(child.matrixWorld);

        // Step 3: Fix indexed geometry — convert to non-indexed for reliable raycasting.
        // GLB always uses indexed geometry; the three_js Dart raycaster works best non-indexed.
        if (clone.geometry?.index != null) {
          clone.geometry = clone.geometry!.toNonIndexed();
        }

        // Step 4: Compute bounds — the Raycaster needs these for its early-out bounding tests.
        // GLTFLoader in Dart does not always compute these automatically (unlike OBJLoader).
        clone.geometry?.computeVertexNormals();
        clone.geometry?.computeBoundingBox();
        clone.geometry?.computeBoundingSphere();

        mesh.add(clone);
      }
    });*/

    // Create a detail texture applied to the terrain surface only
                                                                                                                                                                                    print("load terrain detail");
   /*   THREE.Texture? texturefloor =await  AssetPack.loadTexture('assets/models/temple/ground5.jpg');//await THREE.TextureLoader()
       //   .fromAsset('assets/models/temple/ground5.jpg');//detailmap.png');
      texturefloor?.wrapS = THREE.RepeatWrapping;
      texturefloor?.wrapT = THREE.RepeatWrapping;
      texturefloor?.needsUpdate = true;
      texturefloor?.repeat.setValues(1*2, 6*2);*/
    // Load the normal maps
    normaltile = await  AssetPack.loadTexture('assets/models/temple/normaltile.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    normaltile2 =  await  AssetPack.loadTexture('assets/models/temple/normaltile2.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    normalcherubum =  await  AssetPack.loadTexture('assets/models/temple/normalcherubum.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    var normalrosette =  await  AssetPack.loadTexture('assets/models/temple/normalrosette.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    var normalpalm = await  AssetPack.loadTexture('assets/models/temple/normalpalm.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    var normalwallback =  await  AssetPack.loadTexture('assets/models/temple/normalwallback.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    var normalwindow = await  AssetPack.loadTexture('assets/models/temple/normalwindow.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    var normalbrick =  await  AssetPack.loadTexture('assets/models/temple/normalbrick.jpg');//');//assets/textures/bumpcolumnold.jpgtextures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    var normalbrick2=normalbrick?.clone();
    normalbrick2?.needsUpdate = true;
    var normalcedar = await  AssetPack.loadTexture('assets/models/temple/normalcedar.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    var normalclothes =  await  AssetPack.loadTexture('assets/models/temple/normalclothes.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    var normalhouse2 = await  AssetPack.loadTexture('assets/models/temple/normalhouse2.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
    var normalhuldah = await  AssetPack.loadTexture('assets/models/temple/normalhuldah.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
  //  var normalstep=  await THREE.TextureLoader()
  //      .fromAsset('assets/models/temple/normalstepold.jpg');//textures/water/Water_1_M_Normal.jpg');//THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');

    /*   This is the old secondary texture
    THREE.Texture? textureaerial = await THREE.TextureLoader()
          .fromAsset('assets/models/temple/detailmap.jpg');//jpg');//png');
      textureaerial?.wrapS = THREE.RepeatWrapping;
      textureaerial?.wrapT = THREE.RepeatWrapping;
      textureaerial?.needsUpdate = true;
      textureaerial?.repeat.setValues(80*2, 80*2);*/
   //   textureaerial?.generateMipmaps=false;


      // var bumpTexture = await THREE.TextureLoader().loadAsync('assets/textures/water/Water_1_M_Normal.jpg');
      //textureaerial.bumpMap = bumpTexture;
      //material.bumpScale = 0.015
 /*     var mataerial = new THREE.MeshPhongMaterial.fromMap({
        'map': textureaerial,
        //'alphaTest':0.1
        'transparent': true,
        'opacity':0.4 //4
        //'bumpMap': bumpTexture,
        //'normalMap': bumpTexture,
        //'bumpScale': 0.015
        //  'alphaTest': .5
      });*/
    bronzematclean = THREE.MeshStandardMaterial.fromMap( {
      //  'normalMap':grapevinemat?.map,
      //  'alphaMap':grapevinemat?.map,
      // 'envMap':grapevinemat?.map,
      'color': 0xff9933,
      'metalness':1.0,// 0,
      //'map': goldii,
      // 'transparent':true,
      'shininess':100.0,
      'roughness': 0.5,
      // 'em'
      // 'emissive':THREE.Color.fromHex32(0xffff00)
      //'envMap': gold,
      //'envMapIntensity': 0.5,// api['envMapIntensity'],
    } );

    bronzemat = THREE.MeshStandardMaterial.fromMap( {
      //  'normalMap':grapevinemat?.map,
      //  'alphaMap':grapevinemat?.map,
      // 'envMap':grapevinemat?.map,
      'color': 0xff9933,
      'metalness':1.0,// 0,
      //'map': goldii,
      // 'transparent':true,
      'shininess':100.0,
      'roughness': 0.5,
      // 'em'
      // 'emissive':THREE.Color.fromHex32(0xffff00)
      //'envMap': gold,
      //'envMapIntensity': 0.5,// api['envMapIntensity'],
    } );

      /*  var textureaerial=THREE.TextureLoader();
    textureaerial.needsUpdate = true;
    textureaerial.repeat.set(20, 20);

    var mataerial = new THREE.MeshBasicMaterial({
      'map': textureaerial,
      'transparent': true,
      //  'alphaTest': .5
    });*/
      threeJs.scene.add(mesh);
      print("space init");
      OPENWORLD.Space.init(mesh, threeJs.scene);

      // Load all the terrain sprite textures that are billboarded so that dont have massive number of calls each render
      var spritebillboardambiencecolor=null;
      if (!OPENWORLD.Time.isDay(OPENWORLD.Time.time)&&ambience != null) {
      //spriteMaterial.color = THREE.Color.fromHex32(0x000000);//Time._ambience!.color as THREE.Color;
        spritebillboardambiencecolor = ambience!.color as THREE.Color;
      //  print("mmcol"+spriteMaterial.color.red.toString()+" "+spriteMaterial.color.green.toString()+" "+spriteMaterial.color.blue.toString());
      }
      var grasstexture = await  AssetPack.loadTexture('assets/models/temple/grass.png');
      instancedGrass = InstancedBillboards.create(grasstexture!, 400, threeJs.scene,color:spritebillboardambiencecolor);
      var olivetexture = await  AssetPack.loadTexture('assets/models/temple/olive.png');
      instancedOlive = InstancedBillboards.create(olivetexture!, 400, threeJs.scene,color:spritebillboardambiencecolor);
      var olivefigtree = await  AssetPack.loadTexture('assets/models/temple/figtree.png');
      instancedFigtree = InstancedBillboards.create(olivefigtree!, 400, threeJs.scene,color:spritebillboardambiencecolor);
      var olivecyprus = await  AssetPack.loadTexture('assets/models/temple/cyprus.png');
      instancedCyprus = InstancedBillboards.create(olivecyprus!, 400, threeJs.scene,color:spritebillboardambiencecolor);

      var numsprites=0;
      mesh?.receiveShadow = true;
      mesh?.traverse((object) async {

        if (object is THREE.Mesh && object.material is THREE.Material && ! (object.material is THREE.GroupMaterial)) {

            var  mat=object.material;//?.clone();

         // if (object.name!='marker') {
            if (mat?.alphaMap != null) mat?.alphaMap = null;
            mat?.shininess = 0.0;
            // mat?.depthTest=true;
            mat?.alphaTest = 0.9; // Fixes issue of transparent textures being rendered in the wrong order
            // mat?.metalness=1;
            mat?.roughness = 1.0;
            mat?.transparent=false;  // !!! for water shader for some reason this needs to be false,

          mat?.emissive = THREE.Color.fromHex32(0x000000);//000000); //000000);
      //    }
          // Looks better with this color space
          mat?.map?.colorSpace = THREE.SRGBColorSpace;

          if (mat!=null ) {

            /* if (object.name=='olive') {
                      // print('olivee'+xworld.toString()+' '+yworld.toString());
                      olivetreesprite =object;
                      olivetreesprite.extra['positionorig']=olivetreesprite.position.clone();

                  }*/
           if (object.name=='shopfloorsurface-1') {
          // var bathsfloorsurface= OPENWORLD.BaseObject.getGroupByName(OPENWORLD.Space.mesh, "bathsfloorsurface");
            object.material = object.material?.clone();
            object.material?.color = THREE.Color.fromHex32(0x888888);
          //OPENWORLD.Texture.setColor(OPENWORLD.Space.mesh, groupname:"bathsfloorsurface",THREE.Color.fromHex32(0x000000));
          } else if (object.name.contains('marker')) {
              object.visible = false;
              THREE.BufferGeometry? geom = object.geometry;
              //print("steps geom "+geom!.attributes['position'].toString());
              var positionAttribute = geom!.attributes['position'];
              var vertex = new THREE.Vector3();
              //   var xsum=0.0, ysum=0.0, zsum=0.0;

              // Each marker is made up of 3 vertices
              for (var j = 0; j < positionAttribute.count; j += 3) {
                vertex.fromBuffer(
                    positionAttribute, j + 2); // last one is center
                if (object.name == 'markeressen')
                  // In reverse
                  citizenessenpath.insert(0, [vertex.x, -vertex.z]);
                //   print('vert' + j.toString() + ' ' + vertex.x.toString()+' '+ vertex.y.toString()+' '+ vertex.z.toString());

              }
                print('essene'+citizenessenpath.toString());

            } else if (object.name.contains('sprite')) {
              // Convert the sprite planes in the terrain to sprites eg vegetation and billboard them
              THREE.BufferGeometry? geom = object.geometry;
              //print("steps geom "+geom!.attributes['position'].toString());
              var positionAttribute = geom!.attributes['position'];
              var vertex = new THREE.Vector3();
              //   var xsum=0.0, ysum=0.0, zsum=0.0;

              // Each sprite is made up of 6 vertices
              for (var j = 0; j < positionAttribute.count; j += 6) {
                var minx = double.infinity;
                var maxx = double.negativeInfinity;
                var miny = double.infinity;
                var maxy = double.negativeInfinity;
                var minz = double.infinity;
                var maxz = double.negativeInfinity;
                // Get the x, y, z components of the current vertex
                for (var i = 0; i < 6; i++) {
                  vertex.fromBuffer(positionAttribute, j + i);
                  // Now 'vertex' contains the position of the current vertex in local space
                  // You can perform operations with 'vertex' here
                  // print('vert' + j.toString() + ' ' + vertex.x.toString());
                  if (vertex.x < minx)
                    minx = vertex.x;
                  if (vertex.x > maxx)
                    maxx = vertex.x;
                  if (-vertex.z < miny)
                    miny = -vertex.z;
                  if (-vertex.z > maxy)
                    maxy = -vertex.z;
                  if (vertex.y < minz)
                    minz = vertex.y;
                  else if (vertex.y > maxz)
                    maxz = vertex.y;
                }
                var xworld = (maxx + minx) / 2;
                var yworld = (maxy + maxy) / 2;
                var width = maxx - minx > maxy - miny ? maxx - minx : maxy -
                    miny;
                var height = maxz - minz;

                if (object.name.contains('olive')) {
                  instancedOlive.place(xworld,
                      (maxz + minz) / 2, -yworld,
                      width: width.toDouble(),
                      height: height.toDouble(),
                      local: true);
                } else if (object.name.contains('grass')) {
                  instancedGrass.place(xworld,
                      (maxz + minz) / 2, -yworld,
                      width: width.toDouble(),
                      height: height.toDouble(),
                      local: true);
                } else if (object.name.contains('figtree')) {
                  instancedFigtree.place(xworld,
                      (maxz + minz) / 2, -yworld,
                      width: width.toDouble(),
                      height: height.toDouble(),
                      local: true);
                } else if (object.name.contains('cyprus')) {
                  instancedCyprus.place(xworld,
                      (maxz + minz) / 2, -yworld,
                      width: width.toDouble(),
                      height: height.toDouble(),
                      local: true);
                  //  print("figtree");
                } else {
                  object.material?.map?.colorSpace = THREE.SRGBColorSpace;
                  THREE.SpriteMaterial spriteMaterial = THREE.SpriteMaterial
                      .fromMap({
                    'map': object.material?.map,

                    'transparent': false,
                    //false,//true  !!! for water shader for some reason this needs to be false,
                    'sizeAttenuation': true,
                    'alphaTest': 0.5
                  });
                  var sprite = new THREE.Sprite(spriteMaterial);
                  sprite.scale.setValues(
                      width.toDouble(), height.toDouble(), 1);
                  //sprite.position.y=height/2;
                  THREE.Group group = THREE.Group();
                  group.add(sprite);
                  group.position.x = xworld;
                  group.position.z = -yworld;
                  group.position.y = (maxz + minz) / 2;
                  if (!OPENWORLD.Time.isDay(OPENWORLD.Time.time)&&ambience != null) {
                    //spriteMaterial.color = THREE.Color.fromHex32(0x000000);//Time._ambience!.color as THREE.Color;
                      spriteMaterial.color = ambience!.color as THREE.Color;
                    //  print("mmcol"+spriteMaterial.color.red.toString()+" "+spriteMaterial.color.green.toString()+" "+spriteMaterial.color.blue.toString());
                  }

                  threeJs.scene.add(group);
                }
                numsprites++;
              }

              object.visible = false;
            }
            if (object.name.contains('transparent')) {
              // Allow meshes in the terrain be transparent
              mat.transparent = true;
              mat.opacity = 0.0;
            } else if (object.name == 'firealtarblood') {
              // Get the alter blood so can use in tamid
              firealtarblood = object;
              firealtarblood.visible=false;
            } else if (object.name == 'firealtarbloodse') {
              // Get the alter blood so can use in tamid
              firealtarbloodse = object;
              firealtarbloodse.visible=false;
            } else if (object.name=='creek') {
               // creekmat=mat;
                creek=object;
                creek?.visible=false;

              } else if (object.name.contains("panorama")) {
                // panorama should not be effected by light except ambient light so make it a basic material
               OPENWORLD.Texture.setBasicMaterial(object);

          //     object.material!.emissive =THREE.Color.fromHex32(0x333333);//ambience!.color as THREE.Color;// THREE.Color.fromHex32(0x555555);
               object.material!.color =  ambience!.color as THREE.Color;// THREE.Color.fromHex32(0x333333);// ambience!.color as THREE.Color;//THREE.Color.fromHex32(
               object.material!.transparent=true;
               object.material?.needsUpdate=true;

              //   0xffffff);
              } else if (object.name.contains('shiny')) {
                // Make the surface shiny
                mat.metalness = 0;
                mat.roughness = 0.1;
              //  mat.specular= THREE.Color.fromHex32(  0xeeeeee);
                mat?.shininess = 100;
              } else if (object.name.contains('gold')) {
                // Make material golden
                final material = THREE.MeshStandardMaterial.fromMap( {
                  'color': 0xffff33,
                  'metalness':1.0,// 0,
                  //'map': goldii,
                  'shininess':1.0,
                  'roughness': 0.5,
                 // 'em'
               //   'emissive':THREE.Color.fromHex32(0x000000)
                  //'envMap': gold,
                  //'envMapIntensity': 1.0,// api['envMapIntensity'],
                } );
                object.material=material;
              //  object.material?.normalMap?.repeat.setValues(1.0,-1.0);//80*2, 80*2);
                object.material?.needsUpdate=true;
                // Set normal map to gold surface
                if (object.name.contains('goldrosette'))
                  material?.normalMap=normalrosette;
                else if (object.name.contains('goldpalm')) {
                  material?.normalMap = normalpalm;
                  goldmaterialpalm=material;
                } else if (object.name.contains('goldtile')) {
                  material?.normalMap = normaltile2;
                //  material?.normalMap?.repeat.setValues(5.0,5.0);//80*2, 80*2);
                } else {
                  material?.normalMap = normalcherubum;
                 // material?.normalMap?.repeat.setValues(1.0, -1.0);
                }

                material?.normalMap?.wrapS = THREE.RepeatWrapping;
                material?.normalMap?.wrapT = THREE.RepeatWrapping;

              } else if (object.name.contains('bronze')) {
                // Make the surface bronze
                object.material=bronzemat;
                object.material?.needsUpdate=true;
              }
              if (object.name.contains("castshadow")) {
                // Have this mesh cast a shadow
                var opacity=object.material?.opacity;
                object.material?.transparent=opacity!<1.0;
                object.castShadow=true;
              } else if (object.name.contains("shadow")) {
                // Have this mesh receive shadows
                var opacity=object.material?.opacity;
//                object.material=THREE.MeshLambertMaterial.fromMap({'map': object.material?.map});;
                object.material?.transparent=opacity!<1.0;
                object.receiveShadow = true;
              }
              mat?.map?.generateMipmaps = false;
              if (object.name.contains("surfaceaerial")) {

                mat?.map?.generateMipmaps = false;

            /*  OPENWORLD.Texture.setGroupMaterial(object,mataerial);//secondarymaterial)
               old group material
               mat= object.material;
               if (mat?.alphaMap != null) mat?.alphaMap = null;
               mat?.shininess = 0.0;
               mat?.map?.generateMipmaps = false;;//minFilter=THREE.
               // mat?.depthTest=true;
               mat?.alphaTest=0.9;  // Fixes issue of transparent textures being rendered in the wrong order
               // mat?.metalness=1;
               mat?.roughness=1.0;

               mat?.emissive = THREE.Color.fromHex32(0x000000);//000000);
*/

               object.material?.needsUpdate=true;
             //    print("xxxx here");
            }
            if (object.name=="huldahroof") {
              mat?.normalMap = normalhuldah;
              mat?.normalScale = THREE.Vector2(2.0,2.0);
              mat?.normalMap?.wrapS = THREE.RepeatWrapping;
              mat?.normalMap?.wrapT = THREE.RepeatWrapping;

            }  else   if (object.name.contains("normal")) {//surface")&&!object.name.contains("hide")) {
              //  OPENWORLD.Texture.setGroupMaterial(object,matfloor);//secondarymaterial)
                //    object.material= THREE.GroupMaterial([  mataerial,mat]);
                mat= object.material;

                if (object.name.contains("normalbrick2")) {

                  mat?.normalMap = normalbrick2;
                  mat?.normalScale = THREE.Vector2(0.5,0.5);
                 // mat?.normalScale= THREE.Vector2(1.0,1.0);

                  mat?.normalMap?.repeat.setValues(2.0/4, 10.0/4); //80*2, 80*2);
                  mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                  mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                  print("normalbrick2");
                } else  if (object.name.contains("normalbrick")) {

                  mat?.normalMap = normalbrick;
                 // mat?.normalScale = THREE.Vector2(0.5,0.5);
                // mat?.normalScale= THREE.Vector2(1.0,1.0);
                  mat?.normalMap?.repeat.setValues(1.0, -1.0); //80*2, 80*2);
                //  mat?.normalMap?.repeat.setValues(2.0/4, 10.0/4); //80*2, 80*2);
                  mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                  mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                } else if (object.name.contains("normalwallback")) {
                  mat?.normalMap = normalwallback; //bumpTexture;
                  mat?.normalScale = THREE.Vector2(2.0, 2.0);
                  // mat?.normalScale= THREE.Vector2(2.0,2.0);
              //    mat?.normalMap?.repeat.setValues(1.0, -1.0); //80*2, 80*2);
                  mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                  mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                } else  if (object.name.contains("normalrosette")) {
                  mat?.normalMap = normalrosette; //bumpTexture;
                  mat?.normalScale= THREE.Vector2(8.0,8.0);
                  // mat?.normalScale= THREE.Vector2(2.0,2.0);
                //  mat?.normalMap?.repeat.setValues(1.0,1.0);//80*2, 80*2);
                  mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                  mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                  // OPENWORLD.Texture.setGroupMaterial(object,matmarble);
                } else  if (object.name.contains("normalwindow")) {
                    mat?.normalMap = normalwindow; //bumpTexture;
                    mat?.normalScale= THREE.Vector2(8.0,8.0);
                    // mat?.normalScale= THREE.Vector2(2.0,2.0);
                    mat?.normalMap?.repeat.setValues(1.0,1.0);//80*2, 80*2);
                    mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                    mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                 // OPENWORLD.Texture.setGroupMaterial(object,matmarble);
                } else if (object.name.contains("normaltile2")) {
                  mat?.normalMap = normaltile2; //bumpTexture;
                  mat?.normalScale= THREE.Vector2(0.08,0.08);
                  //   mat?.normalScale= THREE.Vector2(200.0,200.0);

                  //OPENWORLD.Texture.setBasicMaterial(object);
                 // object.material!.color= THREE.Color.fromHex32(0x000000);
                //  mat?.normalScale= THREE.Vector2(0.05,0.05);
                  //  mat?.normalMap?.repeat.setValues(4.0,4.0);//80*2, 80*2);
                  mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                  mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                  print("normaltile2");
                } else  if (object.name.contains("normalcedar")) {
                  mat?.normalMap = normalcedar; //bumpTexture;
                  mat?.normalScale= THREE.Vector2(10.0,10.0);
                  // mat?.normalScale= THREE.Vector2(2.0,2.0);
                  mat?.normalMap?.repeat.setValues(1.0,1.0);//80*2, 80*2);
                  mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                  mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                } else  if (object.name.contains("normalclothes")) {
                  mat?.normalMap = normalclothes; //bumpTexture;
                //  mat?.normalScale= THREE.Vector2(10.0,10.0);
                  // mat?.normalScale= THREE.Vector2(2.0,2.0);
                 // mat?.normalMap?.repeat.setValues(0.5,0.5);//80*2, 80*2);
                  mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                  mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                } else  if (object.name.contains("normalhouse2")) {
                  mat?.normalMap = normalhouse2; //bumpTexture;
                  //  mat?.normalScale= THREE.Vector2(10.0,10.0);
                  mat?.normalScale= THREE.Vector2(2.0,2.0);
                  // mat?.normalMap?.repeat.setValues(0.5,0.5);//80*2, 80*2);
                  mat?.normalMap?.repeat.setValues(1.0, -1.0); //80*2, 80*2);
                  mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                  mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                } else {
                  mat?.normalMap = normaltile; //bumpTexture;
                  mat?.normalScale= THREE.Vector2(0.2,0.2);
                //  mat?.normalMap?.repeat.setValues(4.0,4.0);//80*2, 80*2);
                  mat?.normalMap?.wrapS = THREE.RepeatWrapping;
                  mat?.normalMap?.wrapT = THREE.RepeatWrapping;
                }


                object.material?.needsUpdate=true;

            }
          }

        }
      });

      instancedFigtree.finish();
    instancedGrass.finish();
    instancedOlive.finish();
    instancedCyprus.finish();

    print("num mesh sprites"+numsprites.toString());


    // Create the cloud object that is a plane with a cloud texture
      print("create cloud");
      var geometry = new THREE.PlaneGeometry(2000, 2000);
      var texturei =
      await THREE.TextureLoader().fromAsset('assets/textures/clouds.png');
      texturei?.wrapS = THREE.RepeatWrapping;
      texturei?.wrapT = THREE.RepeatWrapping;
      texturei?.needsUpdate = true;

    texturei?.matrixAutoUpdate = true;
    texturei?.repeat.setValues(20, 20);
//      texturei?.repeat.setValues(50, 50);
      // var material = new THREE.MeshBasicMaterial( {'color': 0xffff00, 'side': THREE.FrontSide} );
      var material =
      THREE.MeshStandardMaterial.fromMap(
          {'map': texturei,
          //  'alphatest':0.1
            'transparent': true
          });

      var clouds = new THREE.Mesh(geometry, material);
      clouds.name='clouds';  // so dont cause flickering in water
      clouds.rotateX(THREE.MathUtils.degToRad(90));
      threeJs.scene.add(clouds);
      //clouds.renderOrder = 999;
      //clouds.material?.depthWrite = false; // already likely false, but make sure
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
  //  OPENWORLD.Weather.setRain(0);
      OPENWORLD.Weather.setRain(
          await OPENWORLD.Persistence.get("rain", def: 0.0));
      OPENWORLD.Weather.setFog(
          await OPENWORLD.Persistence.get("fog", def: 0.0));
      OPENWORLD.Weather.setRandomWeather(); // Will randomly get rain, fog, wind and cloud


      // This is the start room in the court of women outside the second temple
      roomCourtWomen = OPENWORLD.Room.createRoom(7.4, 0.32, name:"Court of Women",
          soundpath: Glob.roamsukkot||
              (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)&&
              // If doing tamid dont have loud courtyard sound
              gamestart!=GameStart.bethphage&&
              gamestart!=GameStart.hearth&&
              !(gamestart == GameStart.roam && widget.progress == 'tamid'))?"sounds/courtyard.mp3":null, volume:0.02,);//1.26);
     // roomCourtWomen.extra['name'] = "Court of Women";
      // Set information about the room for the guide
      roomCourtWomen.extra['guide'] = [
        "This is the Court of Women.",
        "Ritually pure women, children &",
        "prosletytes and men are",
        "allowed here.",
        "There is a lot of festivals",
        "with dancing and music",
        "that go on here " //as",
      ];
      threeJs.scene.add(roomCourtWomen);

      // Set distance trigger for the room and change the room name when you enter the room ie 'Court of Women'
      OPENWORLD.Room.setDistanceTrigger(roomCourtWomen,
          minx: 5.65, maxx: 9.1, miny: -1.4, maxy: 2.1, event:(action) {   //2.8
        if (action) {
          if (mounted)
            setState(() {
            //  print("in shofar");
              roomname = roomCourtWomen.extra['name'];
            });
        } else {
          if (roomname == roomCourtWomen.extra['name']) {
            if (mounted)
              setState(() {
                roomname = "";
              });
          }
        }
      });

      // ciziten.glb holds all the animations so load the actor without adding to the scene yet so can share animations with other actors
      seller = await OPENWORLD.Actor.createActor('assets/actors/citizen/citizen.glb',
         // texture: "assets/actors/citizen/bodyc4.png",
          z: actoroffset);
      addProgress();
      // Load the configuration file with shop items
      // Distance must move before config pool is updated
      OPENWORLD.Config.movediffx=0.3;
      OPENWORLD.Config.movediffy=0.3;
     // Distance must move before config pool distances are fully sorted
      OPENWORLD.Config.fullsortdiffx=1.0;
      OPENWORLD.Config.fullsortdiffy=1.0;
      await OPENWORLD.Config.loadconfig();

      await OPENWORLD.Config.createAllObjects(threeJs.scene);
      await OPENWORLD.Config.createPoolObjects();//threeJs.scene);

      // Create new animations by combining others
      OPENWORLD.Actor.createAnimation(seller, "squatright", "squat", "lookright", ["Bip01_Head"]);
      OPENWORLD.Actor.createAnimation(seller, "squatworkright", "squatwork", "lookright", ["Bip01_Head"]);
      OPENWORLD.Actor.createAnimation(seller, "squatleft", "squat", "lookleft", ["Bip01_Head"]);
      OPENWORLD.Actor.createAnimation(seller, "squatup", "squat", "lookup", ["Bip01_Head"]);
      OPENWORLD.Actor.createAnimation(seller, "squatpoint", "squat", "point", ["Bip01_R_Arm1","Bip01_R_Arm2"]);
      OPENWORLD.Actor.createAnimation(seller, "walkhandrightpoint", "walkhandright", "pointleft", ["Bip01_L_Arm1","Bip01_L_Arm2"]);
      OPENWORLD.Actor.createAnimation(seller, "idleholdpoint", "idlehold", "pointleft", ["Bip01_L_Arm1","Bip01_L_Arm2"]);
      OPENWORLD.Actor.createAnimation(seller, "walkstoop", "walkstraight", "stoopidle", ["Bip01_Spine"]);
      OPENWORLD.Actor.createAnimation(seller, "walkhandleft", "walk", "idleholdleft", ["Bip01_L_Arm1","Bip01_L_Arm2"]);
      OPENWORLD.Actor.createAnimation(seller, "sittablelookup", "sittableidle", "lookup", ["Bip01_Head"]);

      // Define the joystick
      _joystick = OPENWORLD.VirtualJoystick();
      _joystick?.joysticksize = 200;

      threeJs.domElement.addEventListener(THREE.PeripheralType.keyup, (event) {
        log("keyup");
        _joystick?.keyboard.onKeyChange(event, 'keyup');
      });

      threeJs.domElement.addEventListener(
          THREE.PeripheralType.keydown, (event) {
            var keyCode;
            if (event.keyId<255)
              keyCode = String.fromCharCode(event.keyId).toUpperCase();
            else
              keyCode=event.keyId;
            log("keydown"+keyCode.toString());
            OPENWORLD.KeyboardCallbacks.keydown(keyCode);

        _joystick?.keyboard.onKeyChange(event, 'keydown');
      });

      threeJs.domElement.addEventListener(
          THREE.PeripheralType.pointerdown, (event) {
        pointerdowntick = OPENWORLD.System.currentMilliseconds();
        _joystick?.onTouchDown(event.clientX, event.clientY);
      });

      threeJs.domElement.addEventListener(
          THREE.PeripheralType.pointerup, (event) {
        var numpoints;
        numpoints = 2;

        // Deal with clicking on an object
        if (!OPENWORLD.BaseObject.touchup(
            pointerdowntick, event, //threeJs.scene,
            threeJs.width,
            threeJs.height, numpoints)) {
          //   OPENWORLD.BaseObject.setHighLights(scale:1.000005,opacity:0.5);//hidehighlights();
          OPENWORLD.BaseObject.deselectHighLights(); //hidehighlights();
          setState(() {
            menuposx = -1;
          });
        }
      });

      threeJs.domElement.addEventListener(
          THREE.PeripheralType.pointermove, (event) {
        // this should be in openworld!!
        if (!_joystick?.getStickPressed()) {
          _joystick?.onTouch(
              event.clientX, event.clientY, threeJs.width, threeJs.height,
              clock.getDelta()); //clock.getDelta());
        }
      });


      // This room is within the second temple where the priest is and includes the minorah, showbread and altar of incense
     roomSanctuary = OPENWORLD.Room.createRoom(
        1.7 ,0.38, soundpath: "sounds/temple.mp3",name:"Sanctuary",
          volume: 0.4); //THREE.Object3D();
      OPENWORLD.Room.setIndoors(roomSanctuary, true);
    //  roomSanctuary.extra['name'] = 'Sanctuary';
      roomSanctuary.extra['guide'] = [
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
      threeJs.scene.add(roomSanctuary);

      OPENWORLD.Room.setDistanceTrigger(roomSanctuary,
                                                  //3.04
          miny: -0.41, maxy: 1.1, minx: 1.12, maxx: 3.15, event:(action) {
        //    0.74          1.84      0.21          1.88
            if (action) {
          if (mounted)
            setState(() {
              roomname = roomSanctuary.extra['name'];
            });
        } else {
          if (roomname == roomSanctuary.extra['name']) {
            if (mounted)
              setState(() {
                roomname = "";
              });
          }
        }
      });



      // This room is between the santuary and the court of women and has the eternal flame
      roomCourtIsrael = OPENWORLD.Room.createRoom(4.35, 0.39, name:'Court of the Priests',soundpath: "sounds/fire2.mp3", //3.2, 1.26,
          volume: 0.05,
        //  randomsoundpath: "sounds/moo1.mp3",
      //    randomsoundgap: 60
      ); //THREE.Object3D();
    //  roomCourtIsrael.extra['name'] = 'Court of the Priests';
      roomCourtIsrael.extra['guide'] = [
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
      threeJs.scene.add(roomCourtIsrael);

      OPENWORLD.Room.setDistanceTrigger(roomCourtIsrael,
          //    3.28
          minx: 3.15, maxx: 5.37, miny: -1.45, maxy: 2.12, event:(action) {
//          minx: 3.28 1.88, maxx: 5.37 5, miny: -1.45 -0.67, maxy: 2.12 2.8, event:(action) {
        if (action) {
          if (mounted)
            setState(() {
              roomname = roomCourtIsrael.extra['name'];
            });
        } else {
          if (roomname == roomCourtIsrael.extra['name']) {
            if (mounted)
              setState(() {
                roomname = "";
              });
          }
        }
      });

      OPENWORLD.Light.clock = clock;



      // Show cow and if near the cow then play moo sound - only during the day and not testing the tamid
    _cow = await OPENWORLD.Actor.createActor('assets/actors/cow.glb',duration: 2);
    addProgress();
    _cow.scale = THREE.Vector3(0.005 * 0.5, 0.005 * 0.5, 0.005 * 0.5);
    OPENWORLD.Space.objTurn(_cow, 0);
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)&&!Glob.roamtamid&&!Glob.roamketoret&&!Glob.testtamidfinal&&gamestart!=GameStart.bethphage) {
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            _cow, 4.6, 0.60, 0, 3,
            level: 1); //2.43, 0.59,0,3,lerpopacity:1);// 3.0, 2.4, 0.0, 3, lerpopacity: 1); //3.42);
      //          _cow,4.39, 0.60,0,3);//2.43, 0.59,0,3,lerpopacity:1);// 3.0, 2.4, 0.0, 3, lerpopacity: 1); //3.42);
        threeJs.scene.add(_cow);
        OPENWORLD.BaseObject.setDistanceTrigger(
            _cow, dist: 1.0, event: (action) async {
          if (action) {
            print("in cow");
            var moo = ((OPENWORLD.Math.random() * 3) + 1).floor().toString();
            OPENWORLD.Sound.play(delay: OPENWORLD.Math.random() * 10,
                path: 'sounds/moo' + moo + '.mp3',
                volume: 0.5);
            // var starttime=OPENWORLD.System.currentMilliseconds();
          }
        });
      }


    // Court of gentiles south
    roomSouthCourt = OPENWORLD.Room.createRoom(3.4, -6.2,name:"Court of Gentiles South",
        soundpath: !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/courtyard.mp3":null, volume: 0.05);

    threeJs.scene.add(roomSouthCourt);
    OPENWORLD.Room.setDistanceTrigger(roomSouthCourt,
        minx:  -3.47, maxx: 10.1, miny: -10.44, maxy: -2.47, event:(action) {
          if (action) {
            if (mounted)
              setState(() {
                roomname ='Court of Gentiles';
              });
          } else {
            if (mounted)
              setState(() {
                roomname = "";
              });
          }
        });

    // Royal stoa room with shops
    roomStoa = OPENWORLD.Room.createRoom(3.4, -11.68,name:"Royal Stoa",
          soundpath: !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/marketplace.mp3":null, volume: 0.05,roomspeed: 2.0 / 20,level:1); //THREE.Object3D(); courtyard.mp3

    OPENWORLD.Room.setAutoIndoors(roomStoa, true);

    roomStoa.extra['guide'] = [
        "You are at the Royal Stoa.",
        "Here a lot of commercial",
        "activity occurs such as",
        "banking and theres also",
        "law courts. Herod",
        "built it wanting it to be",
        "the greatest stoa in the",
        "world."
      ];
      threeJs.scene.add(roomStoa);


    OPENWORLD.Room.setDistanceTrigger(roomStoa,
          // -4.5
        minx: -5.34, maxx: 10.1, miny: -12.86, maxy: -10.44, event:(action) {

          if (action) {
            if (mounted)
              setState(() {
                roomname ='Royal Stoa';
              });
          } else {

              if (mounted)
                setState(() {
                  roomname = "";
                });

          }
        });

      // The court of the gentiles  is north of the court of women
      roomNorthCourt = OPENWORLD.Room.createRoom(3.84, 4.93,name:"Court of Gentiles North",
          soundpath:  !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/courtyard.mp3":null, volume: 0.05); //THREE.Object3D();

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
      threeJs.scene.add(roomNorthCourt);

      OPENWORLD.Room.setDistanceTrigger(roomNorthCourt,
                                     // 3.69
          minx: -3.47, maxx: 10.1, miny: 3.4, maxy: 6.37);//6);//  2.34 4.61 12.46);

      // This is outside the grand entrance where the baths are
      roomSouth = OPENWORLD.Room.createRoom(3.84, -16, name:"South Wall",
          soundpath:  !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/courtyard.mp3":null, volume: 0.05,roomspeed: 1.5 / 20); //THREE.Object3D();

      roomSouth.extra['guide'] = [
        "You are at the south wall.",
        "Here is the grand entrance to",
        "the temple for commoners.",
        "There are also baths for",
        "people to wash before",
        "entering the temple."
      ];
      OPENWORLD.Room.setAutoIndoors(roomSouth, true);
      threeJs.scene.add(roomSouth);


      OPENWORLD.Room.setDistanceTrigger(roomSouth,
           maxy: -13.1, miny: -16, minx: -5.4, maxx: 10.1, event:(action){
//          maxy: -13.1, miny: -28, minx: -9.3, maxx: 10.1, event:(action){
        if (action) {
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

     // createCitizens(seller, 4.2, -13.5, 0.4, 2);

    WaterSimple.initVertexData();

    wilddog = await OPENWORLD.Actor.createActor(
        'assets/actors/wilddog.glb',);
      addProgress();
    wilddog.scale.setValues(0.005 * convscale, 0.005 * convscale,
          0.005 * convscale); //25, 0.0025, 0.0025);

      OPENWORLD.Actor.createAnimation(wilddog , "eatright", "eat", "lookright", ["Joint14"]);



    sheeporig =
      await OPENWORLD.Actor.createActor(
          'assets/actors/sheep.glb', shareanimations: wilddog,
      //  duration: 0.2
      );
      addProgress();
      sheeporig.scale.setValues(0.005 * convscale, 0.005 * convscale,
          0.005 * convscale);
      OPENWORLD.BaseObject.setVisible(sheeporig, false,groupname:"collar");
      OPENWORLD.Space.objTurn(sheeporig.children[0], 0);
      OPENWORLD.Space.objTurn(sheeporig.children[1], 0);  //collar


      // This is the western wall with more sellers
      roomWest = OPENWORLD.Room.createRoom(-8.3, -7.08,name:"Western Wall",
          soundpath: !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/marketplace.mp3":null, volume: 0.05); //THREE.Object3D();  courtyard.mp3

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
      threeJs.scene.add(roomWest);

      OPENWORLD.Room.setDistanceTrigger(roomWest,
         minx: -9.3, maxx: -5.6, maxy: 1.4, miny: -13, event:(action) {
//          minx: -9.3, maxx: -5.6, maxy: -3.5, miny: -13, event:(action) { //-11
        if (action) {
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

      // Have cat wonder around house
      cat = await OPENWORLD.Actor.createActor(
          'assets/actors/cat.glb',
          z: 0);
      addProgress();
      cat.scale.setValues(0.01 * convscale, 0.01 * convscale, 0.01 * convscale);
      OPENWORLD.Space.objTurn(cat.children[0], 0);


    soldier2 = await OPENWORLD.Actor.createActor(
        'assets/actors/soldier/soldier2.glb',
       // 'assets/actors/soldier/soldier39.glb',
       // texture: "assets/actors/soldier/bodys.png",
        z: actoroffset,
        shareanimations: seller,
        randomduration: 0.1,
      //  action:"idlehold",
        castshadow: true);
    addProgress();

     silvermaterial = THREE.MeshStandardMaterial.fromMap({
      //  'normalMap': bumpTexture,
      'color': 0xffffff,
      'metalness': 1.0, // 0,
      //'map': goldii,
      'shininess': 1.0,
      'roughness': 0.5,
      // 'em'
      //   'emissive':THREE.Color.fromHex32(0x000000)
      //'envMap': gold,
      //'envMapIntensity': 1.0,// api['envMapIntensity'],
    });
    OPENWORLD.Texture.setMaterial(soldier2, silvermaterial!, groupname:"soldier_2");//silver");

    setActorSize(soldier2);
    configAddActor('soldier2',soldier2);


    OPENWORLD.Space.objTurn(soldier2, 0);

    ////  1. two men and 3 sheep  inc 0
    citizengroup=THREE.Group();
    var ycenterydiff=0.1; // this is so the center is between the sheep and the men
    citizen2 = await OPENWORLD.Actor.createActor(
        'assets/actors/citizen/citizen2.glb',
     //    texture: "assets/actors/citizen/citizen3.jpg",// !!!! why must I do this?  soldier/bodys.png",
        z: actoroffset,
        shareanimations: seller,
        randomduration: 0.1,
    //   duration:2.0,
       action:"walk",
       castshadow: true);
    addProgress();
    citizen2.position.z=-ycenterydiff;
    //(citizen2.material as THREE.MeshStandardMaterial).map=texture;
    setActorSize(citizen2);
    OPENWORLD.BaseObject.setVisible(
        citizen2, false, groupname: "citizen_2");

    citizengroup.add(citizen2);
    configAddActor('citizen2',citizen2);

    citizenoldman=await  OPENWORLD.Actor.createActor(
        'assets/actors/citizen/citizenoldman.glb',
        //    texture: "assets/actors/citizen/citizen3.jpg",// !!!! why must I do this?  soldier/bodys.png",
        z: actoroffset,
        shareanimations: seller,
        randomduration: 0.1,
        //   duration:2.0,
        action:"walk",
        castshadow: true);//OPENWORLD.Actor.copyActor(citizen2, texture: "assets/actors/citizen/citizen3.jpg",action:"walk",randomduration: 0.1);
    addProgress();
   // threeJs.scene.add(citizenoldman);
    citizengroup.add(citizenoldman);
    setActorSize(citizenoldman);
    citizenoldman.position.x=0.07;
    citizenoldman.position.z=-ycenterydiff;
    configAddActor('citizenoldman',citizenoldman);

    citizen3 = await OPENWORLD.Actor.createActor(
      //THREE.Group citizenf = await OPENWORLD.Model.createModel(
        'assets/actors/citizen/citizen3.glb', //citizenf.glb',
        //  groupname:"citizen_2",
        //  texture: "assets/actors/citizen/citizen3head3.jpg",
        //  groupname:"citizen_1",
        //  texture: "assets/actors/citizen/citizen3clothes.jpg",
        z: actoroffset,
        shareanimations: seller,
        castshadow: true,

        //     duration:0.7,
        //action: null,
        //"sittableidle",
        randomduration: 0.1
    );
    addProgress();
    setActorSize(citizen3);
    var shoegroup="citizen_5";//citizen_4
    setShoesGroup(citizen3,shoegroup);
   // sethasnoshoes(citizen3,true);
    configAddActor('citizen3',citizen3);

    OPENWORLD.BaseObject.setVisible(citizen3, true,groupname:"citizen_3");  // show pants
    OPENWORLD.BaseObject.setVisible(citizen3, true,groupname:"citizen_4");  // show clothes

    citizen32=await OPENWORLD.Actor.copyActor(citizen3,
        groupname:"citizen_2",
        texture: "assets/actors/citizen/citizen3head2.jpg",
        randomduration:0.1);//,action:"idle3");
    OPENWORLD.Model.setTexture(citizen32, "assets/actors/citizen/pants2.jpg",groupname:"citizen_3");
    OPENWORLD.Model.setTexture(citizen32, "assets/actors/citizen/citizen3clothes2.jpg",groupname:"citizen_4");
   // sethasnoshoes(citizen32,true);
    setShoesGroup(citizen32,shoegroup);
    configAddActor('citizen32',citizen32);

    citizen33=await OPENWORLD.Actor.copyActor(citizen3,
        groupname:"citizen_2",
        texture: "assets/actors/citizen/citizen3head3.jpg",
        randomduration:0.1);//,action:"idle3");
    OPENWORLD.Model.setTexture(citizen33, "assets/actors/citizen/pants3.jpg",groupname:"citizen_3");
    OPENWORLD.Model.setTexture(citizen33, "assets/actors/citizen/citizen3clothes3.jpg",groupname:"citizen_4");
  //  sethasnoshoes(citizen33,true);
    setShoesGroup(citizen33,shoegroup);
    configAddActor('citizen33',citizen33);

    citizen34=await OPENWORLD.Actor.copyActor(citizen32,
        groupname:"citizen_2",
        texture: "assets/actors/citizen/citizen3head4.jpg",
        randomduration:0.1);//,action:"idle3");
    OPENWORLD.Model.setTexture(citizen34, "assets/actors/citizen/pants4.jpg",groupname:"citizen_3");
    OPENWORLD.Model.setTexture(citizen34, "assets/actors/citizen/citizen3clothes4.jpg",groupname:"citizen_4");
    //sethasnoshoes(citizen34,true);
    setShoesGroup(citizen34,shoegroup);
    configAddActor('citizen34',citizen34);

    citizen35=await OPENWORLD.Actor.copyActor(citizen33,
        groupname:"citizen_2",
        texture: "assets/actors/citizen/citizen3head5.jpg",
        randomduration:0.1);//,action:"idle3");
    OPENWORLD.Model.setTexture(citizen35, "assets/actors/citizen/pants5.jpg",groupname:"citizen_3");
    OPENWORLD.Model.setTexture(citizen35, "assets/actors/citizen/citizen3clothes5.jpg",groupname:"citizen_4");
    //sethasnoshoes(citizen35,true);
    setShoesGroup(citizen35,shoegroup);
    configAddActor('citizen35',citizen35);

    citizen36=await OPENWORLD.Actor.copyActor(citizen34,
        groupname:"citizen_2",
        texture: "assets/actors/citizen/citizen3head6.jpg",
        randomduration:0.1);//,action:"idle3");
    //sethasnoshoes(citizen36,true);
    setShoesGroup(citizen36,shoegroup);
    configAddActor('citizen36',citizen36);

    for (var i = 0; i < 3; i++) {
      var sheep = await OPENWORLD.Actor.copyActor(sheeporig,castshadow: true,action:"walk", randomduration: 0.1);
      var yoffset=-(i+1)*0.05+OPENWORLD.Math.randFloat(-0.015,0.015)+ycenterydiff;;//, high).random()*0.05;

      OPENWORLD.Space.objTurn(sheep.children[0], 180);
      //  OPENWORLD.Space.objTurn(crab  ,90);  //e
      citizengroup.add(sheep);
      sheep.position.x=OPENWORLD.Math.randFloat(-0.014,0.014);
      sheep.position.z=-yoffset;

    }

    var topgroup=THREE.Group();
    topgroup.extra['setpitch']=true;
    topgroup.add(citizengroup);
    citizengroups.add(topgroup);
    threeJs.scene.add( topgroup);
    OPENWORLD.Space.readdObjFromHide(topgroup, dist: citizenhidedist);
   // OPENWORLD.Space.setObjlerpopacity(citizengroup,1);

    /////
    // 2. Donkey and lady with boy walking behind  inc 1
    THREE.Group donkeygroup=THREE.Group();
   // threeJs.scene.add( donkeygroup);

    citizenf2 = await OPENWORLD.Actor.createActor(
    //THREE.Group citizenf = await OPENWORLD.Model.createModel(
        'assets/actors/citizen/citizenf2.glb',//citizenf.glb',
        // texture: "assets/actors/citizen/citizenf2.jpg",
        z: actoroffset,
        shareanimations: seller,
        castshadow: true,
        duration:0.7,
        action:"sittableidle",
        randomduration: 0.1
        );
    addProgress();

    //print("comp"+citizenf.material.m)
    setActorSize(citizenf2);
    configAddActor('citizenf2',citizenf2);
   // OPENWORLD.Space.worldToLocalSurfaceObjHide(
   //     citizenf,-14.02, 65.07,0,3);//-14.05, 63.96,0,3);//-14.11, 64.25, 0.0, 3); //3.42);
   // threeJs.scene.add(citizenf);
    donkeygroup.add(citizenf2);
    OPENWORLD.Space.objTurn(citizenf2, 0);
    citizenf2.position.z=ycenterydiff;

    donkeyorig = await OPENWORLD.Actor.createActor(
        'assets/actors/donkey.glb',
       // 'assets/actors/donkey.glb',
        action:'walk',
        duration:1.7,
     //   shareanimations: horse,
        castshadow: true); //, duration:0.4);
    addProgress();
  //  OPENWORLD.Space.objTurn(donkey.children[0], 0);
    OPENWORLD.Space.objTurn(donkeyorig, 180); //OPENWORLD.Math.random()*360);
    // 0.0025 vs 0.006
  //  donkey.scale.setValues(0.01 * convscale, 0.01 * convscale,
   //     0.01 * convscale); //25, 0.0025, 0.0025);
    donkeyorig.scale.setValues(0.04 , 0.04,
        0.04); //25, 0.0025, 0.0025);
  //  donkeyorig.extra['donkeyname']='donkeyorig';
    OPENWORLD.BaseObject.setVisible(
      donkeyorig, false, groupname: "horse001_1");//donkey_1");  // hide rope

    donkeypack=await OPENWORLD.Actor.copyActor(donkeyorig,action:"walk");//,action:"idle3");

    //  var donkey=await OPENWORLD.Actor.copyActor(donkeyorig);
    var packdonkey = await OPENWORLD.Model.createModel(
        'assets/models/packdonkey.glb');
    addProgress();

    var boneu=OPENWORLD.Actor.wield(donkeypack, packdonkey, "ride");//Bip01_Ponytail1Nub_011");//ride");//Joint31");
    print("donkeypack"+boneu.toString());
    packdonkey.scale.setValues(0.04 , 0.04,
        0.04);
    packdonkey.position.y+=0.4;

    donkeypack.position.z=ycenterydiff;
    donkeygroup.add(donkeypack);

    topgroup=THREE.Group();
    topgroup.extra['setpitch']=true;
    topgroup.add(donkeygroup);
    citizengroups.add(topgroup);
    threeJs.scene.add( topgroup);

    OPENWORLD.Space.readdObjFromHide(topgroup, dist: citizenhidedist);
   // OPENWORLD.Space.setObjlerpopacity(donkeygroup,1);

    OPENWORLD.Space.objTurn(citizenf2,180);
    citizenf2.position.y=0.028;  //up
    citizenf2.position.z=-0.013+ycenterydiff;  // back

    child1= await OPENWORLD.Actor.createActor(
        'assets/actors/citizen/child.glb',
        // texture: "assets/actors/soldier/bodys.png",
        z: actoroffset,
        shareanimations: seller,
        randomduration: 0.1,
        duration:0.9,
        action:"walk",
        castshadow: true);
    addProgress();
    OPENWORLD.Mob.setName(child1,"child1citizenpath");

    setActorSize(child1);

    child1.scale.setValues(child1.scale.x*3/5, child1.scale.y*3/5, child1.scale.z*3/5);
    configAddActor('child1',child1,scale:actorscale*3/5,z:-0.1+ycenterydiff);
    donkeygroup.add(child1);
    child1.position.z=-0.1+ycenterydiff;


    ////// 3. Donkey and lady with child in lap with cart inc 2
    donkey3group=THREE.Group();

   // threeJs.scene.add( donkey3group);

    citizenf23oldlady=await OPENWORLD.Actor.copyActor(citizenf2, texture: "assets/actors/citizen/citizenf23oldlady.jpg");//,action:"idle3");
    configAddActor('citizenf23oldlady',citizenf23oldlady);

    citizenf22=await OPENWORLD.Actor.copyActor(citizenf2, texture: "assets/actors/citizen/citizenf22.jpg", action: "sittableidle",randomduration:0.1, duration:0.7, resetposition: true);//,action:"idle3");
    configAddActor('citizenf22',citizenf22);
    citizenf22.position.y=0.028;
    citizenf22.position.z=-0.013;
    donkey3group.add(citizenf22);
    var donkey3=await OPENWORLD.Actor.copyActor(donkeypack,action:"walk",resetposition: true);//,action:"idle3");
    //threeJs.scene.add( donkey3);
    donkey3.scale.setValues(0.04 , 0.04,
        0.04); //25, 0.0025, 0.0025);
    donkey3group.add(donkey3);

    topgroup=THREE.Group();
    topgroup.extra['setpitch']=true;
    topgroup.add(donkey3group);
    citizengroups.add(topgroup);
    threeJs.scene.add( topgroup);

   // citizengroups.add(THREE.Group().add(donkey3group));
    OPENWORLD.Space.readdObjFromHide(topgroup, dist: citizenhidedist);
//    OPENWORLD.Space.readdObjFromHide(donkey3group, dist: citizenhidedist);

    //OPENWORLD.Space.setObjlerpopacity(donkey3group,1);

    childgirl= await OPENWORLD.Actor.createActor(
        'assets/actors/citizen/childgirl.glb',
        // texture: "assets/actors/soldier/bodys.png",
        z: actoroffset,
        shareanimations: seller,
        action:"sittableidle",
        randomduration: 0.1,
        duration:0.7,
        castshadow: true);
    OPENWORLD.Mob.setName(childgirl,"childgirlcitizenpath");
    addProgress();
    setActorSize(childgirl);
    childgirl.scale.setValues(childgirl.scale.x*3/5, childgirl.scale.y*3/5, childgirl.scale.z*3/5);
    childgirl.position.y=0.042;
    configAddActor('childgirl',childgirl,scale:actorscale*3/5,z:0.042);
    donkey3group.add(childgirl);



    cart= await OPENWORLD.Actor.createActor(
        'assets/actors/cart.glb',
        // texture: "assets/actors/soldier/bodys.png",
     //   randomduration: 0.1,
        action:"roll",
        duration:3.0,
        castshadow: true);
    addProgress();
  //  var xcartoffset=-0.018;
   // var ycartoffset=0.05;
   // var zcartoffset=0.006;
    cart.scale.setValues(0.013,0.013,0.013);
    cart.position.z=-0.08;
    cart.position.y=0.006;

    OPENWORLD.Mob.setName(cart,"cart###");
    figs = await OPENWORLD.Model.createModel(
        'assets/models/figs.glb');
    addProgress();
    figs.position.setValues(0.0,2.5,0.0);
  // figs.scale.setValues(5.0,5.0,5.0);
    cart.add(figs);
    // spear.children[0].scale.setValues(5.0, 5.0, 5.0); //0.15, 0.15, 0.15);
    //OPENWORLD.Space.setTurnPitchRoll(leadanimal, 45+90, 0, 0);
    // OPENWORLD.Space.objRoll(pitchfork.children[0], 90);
    //  OPENWORLD.Space.objTurn(pitchfork.children[0], 20 + 180);
  //  OPENWORLD.Actor.wield(cart, figs,"body");
    donkey3group.add(cart);


    //// 4. two women - next to eachother - inc 3
    citizengroup=THREE.Group();
    citizenoldwoman = await OPENWORLD.Actor.createActor(
      'assets/actors/citizen/citizenoldwoman.glb',//citizenf.glb',
      // texture: "assets/actors/soldier/bodys.png",
      z: actoroffset,
      castshadow:true,
      shareanimations: seller,
      action:"walk",
      // action: "idle3",//"armsidle",//clap",
      //  randomduration: 0.1,
      //  basic:true
    );
    addProgress();
    setActorSize( citizenoldwoman);
    configAddActor('citizenoldwoman',citizenoldwoman);
    var citizenoldwomaniii=await OPENWORLD.Actor.copyActor(citizenoldwoman, randomduration:0.1, duration:0.7, resetposition: true,  action:"walk",);//,action:"idle3");
    citizenoldwomaniii.position.x=-ycenterydiff/2;
//    citizenoldwomaniii.position.z=-ycenterydiff;
    citizengroup.add(citizenoldwomaniii);

    citizenf3 = await OPENWORLD.Actor.createActor(
      'assets/actors/citizen/citizenf3.glb',//citizenf.glb',
      z: actoroffset,
      castshadow:true,
      shareanimations: seller,
      action: null,//"idle3",//"armsidle",//clap",
      //  randomduration: 0.1,
      //  basic:true
    );
    addProgress();
  //  print("vooooot");
  //  OPENWORLD.BaseObject.setVisible(
   //     citizenf3, false, groupname: "citizen_2");  // hide shows
  /*  OPENWORLD.BaseObject.setVisible(
        citizenf3, false, groupname: "citizen_1");  // hide shows
    OPENWORLD.BaseObject.setVisible(
        citizenf3, false, groupname: "citizen");  // hide shows
    OPENWORLD.BaseObject.setVisible(
        citizenf3, false, groupname: "citizen");  // hide shows
    print("vooooot");*/
    setActorSize(citizenf3);
    configAddActor('citizenf3',citizenf3);

    citizenf32=await OPENWORLD.Actor.copyActor(citizenf3,groupname:"citizen_2",texture: "assets/actors/citizen/citizenf3clothes2.jpg");//citizenf32.jpg");
    OPENWORLD.Model.setTexture(citizenf32, "assets/actors/citizen/citizenf3head2.jpg",groupname:"citizen_4");
    configAddActor('citizenf32',citizenf32);

    var citizenf32iii=await OPENWORLD.Actor.copyActor(citizenf32, randomduration:0.1, duration:0.7, resetposition: true,  action:"walk");//,action:"idle3");
    citizenf32iii.position.x=ycenterydiff/2;
//    citizenf32iii.position.z=ycenterydiff;
    citizengroup.add(citizenf32iii);
    topgroup=THREE.Group();
    topgroup.add(citizengroup);
    citizengroups.add(topgroup);
    threeJs.scene.add( topgroup);
    OPENWORLD.Space.readdObjFromHide(topgroup, dist: citizenhidedist);

    citizenf33=await OPENWORLD.Actor.copyActor(citizenf3,groupname:"citizen_2",texture: "assets/actors/citizen/citizenf3clothes3.jpg");//citizenf32.jpg");
    OPENWORLD.Model.setTexture(citizenf33, "assets/actors/citizen/citizenf3head3.jpg",groupname:"citizen_4");
    configAddActor('citizenf33',citizenf33);

    citizenf34=await OPENWORLD.Actor.copyActor(citizenf3,groupname:"citizen_2",texture: "assets/actors/citizen/citizenf3clothes4.jpg");//citizenf32.jpg");
    OPENWORLD.Model.setTexture(citizenf34, "assets/actors/citizen/citizenf3head4.jpg",groupname:"citizen_4");
    configAddActor('citizenf34',citizenf34);

    /// 5. father son - one behind the other? inc 4
  //  citizen2,citizen22,citizen23,citizen4,citizen42,citizen43,citizenoldman,citizenoldman2,citizenoldman22
    citizengroup=THREE.Group();
    citizen4 = await OPENWORLD.Actor.createActor(
      'assets/actors/citizen/citizen4.glb',//citizenf.glb',

      z: actoroffset,
      castshadow:true,
      shareanimations: seller,  action:"walk"
    //  action:null,// "idle3",//"armsidle",//clap",
      //  randomduration: 0.1,
      //  basic:true
    );
    addProgress();
    setActorSize(citizen4);
    configAddActor('citizen4',citizen4);
   // print("get config cit name"+OPENWORLD.Config.getObjectName(citizen4).toString());
    OPENWORLD.Actor.playAction(citizen4,action:"walk");
    citizen43 = await OPENWORLD.Actor.copyActor(
        citizen4,
        action: 'walk',//prostrate',
        texture: "assets/actors/citizen/citizen43.jpg",
        groupname: "citizen_1");
    configAddActor('citizen43',citizen43);
    addProgress();

    var citizen43ii=await OPENWORLD.Actor.copyActor(citizen43, randomduration:0.1, duration:0.7, resetposition: true,  action:"walk",);//,action:"idle3");
    citizen43ii.position.z=-ycenterydiff;
    citizengroup.add( citizen43ii);

    child12=await OPENWORLD.Actor.copyActor(child1,texture: "assets/actors/citizen/child12.jpg");
    configAddActor('child12',child12, scale:actorscale*3/5,z:-0.1+ycenterydiff);//
  //  );

    var child12ii=await OPENWORLD.Actor.copyActor(child12, randomduration:0.1, duration:0.7, resetposition: true,  action:"walk");//,action:"idle3");
    child12ii.position.z=ycenterydiff;
    citizengroup.add(child12ii);
    topgroup=THREE.Group();
    topgroup.extra['setpitch']=true;
    topgroup.add(citizengroup);
    citizengroups.add(topgroup);
    threeJs.scene.add( topgroup);
    OPENWORLD.Space.readdObjFromHide(topgroup, dist: citizenhidedist);

    /// 6. woman with sheep inc 5
    //  [citizenoldwoman,citizenf22,citizenf2,citizenf3,citizenf32]
    citizengroup=THREE.Group();
    var citizenf32iiii=await OPENWORLD.Actor.copyActor(citizenf32,  action:"walk");
    threeJs.scene.add(citizenf32iiii);
    citizengroup.add(citizenf32iiii);
    var sheepii = await OPENWORLD.Actor.copyActor(sheeporig,castshadow: true,action:"walk");
    sheepii.position.z=-50.0;
    sheepii.position.x=0.0;
    OPENWORLD.Space.objTurn(sheepii.children[0],0); // Why this be done
    OPENWORLD.Space.objTurn(sheepii.children[1],0);
    OPENWORLD.Space.objTurn(sheepii,0);
    sheepii.scale.setValues(
        0.7,0.7,0.7);
    citizenf32iiii.add(sheepii);
    OPENWORLD.BaseObject.setVisible(sheepii,true,groupname:"collar");
    topgroup=THREE.Group();
    topgroup.extra['setpitch']=true;
    topgroup.add(citizengroup);
    citizengroups.add(topgroup);
    threeJs.scene.add( topgroup);
    OPENWORLD.Space.readdObjFromHide(topgroup, dist: citizenhidedist);

    /// 7. man woman child girl -man women behind eachother - inc 6
    citizengroup=THREE.Group();
    citizen42 = await OPENWORLD.Actor.copyActor(
        citizen4, action: 'prostrate',
        texture: "assets/actors/citizen/citizen42.jpg",
        groupname: "citizen_1");
    addProgress();
    configAddActor('citizen42',citizen42);
    var citizen42ii=await OPENWORLD.Actor.copyActor(citizen42, randomduration:0.1, duration:0.7, resetposition: true,  action:"walk",);//,action:"idle3");
    citizen42ii.position.z=-ycenterydiff;
    citizengroup.add( citizen42ii);

    var citizenf22iiii=await OPENWORLD.Actor.copyActor(citizenf22,  action:"walk");
    citizenf22iiii.position.y=0.0;
    citizenf22iiii.position.z=ycenterydiff;
    threeJs.scene.add(citizenf22iiii);
    citizengroup.add(citizenf22iiii);

    //childgirl2,childgirl
    childgirl2=await OPENWORLD.Actor.copyActor(childgirl,texture: "assets/actors/citizen/childgirl2.jpg");
    addProgress();
    configAddActor('childgirl2',childgirl2,scale:actorscale*3/5,z:-0.1+ycenterydiff);
    //setActorSize(childgirl2);
    var childgirl2iiii=await OPENWORLD.Actor.copyActor(childgirl2, randomduration:0.1, duration:0.7, resetposition: true,  action:"walk");//,action:"idle3");
    childgirl2iiii.position.x=ycenterydiff;
    citizengroup.add(childgirl2iiii);
    topgroup=THREE.Group();
    topgroup.add(citizengroup);
    citizengroups.add(topgroup);
    threeJs.scene.add( topgroup);
    OPENWORLD.Space.readdObjFromHide(topgroup, dist: citizenhidedist);


    //// 8. two soldiers next to eachother inc 7
    citizengroup=THREE.Group();
    soldier23 = await OPENWORLD.Actor.copyActor(
        soldier2, randomduration: 0.1,
        texture: "assets/actors/soldier/head3.jpg",
        groupname:"soldier_3",
        action: "walk"); //, action:"idlehold");
    addProgress();

    OPENWORLD.Space.objTurn(soldier23,180);
    citizengroup.add(soldier23);
    configAddActor('soldier23',soldier23);

    soldier24 = await OPENWORLD.Actor.copyActor(
        soldier2, randomduration: 0.1,
        texture:"assets/actors/soldier/head4.jpg",
        groupname:"soldier_3",
        action: "walk");
    soldier24.position.x=ycenterydiff/2;
    configAddActor('soldier24',soldier24);
    addProgress();

    citizengroup.add(soldier24);
    OPENWORLD.Space.objTurn(soldier24,180);
    topgroup=THREE.Group();
    topgroup.add(citizengroup);
    citizengroups.add(topgroup);
    topgroup.extra['distancetriggerhitactor']=soldier23;

    if (OPENWORLD.Math.random()<0.02) {
      // Sometimes if you walk past the soldier he'll let off
      topgroup.extra['distancetriggerhitextra'] = (group) {
        if (!group.extra.containsKey('donefart')) {
          group.extra['donefart'] = true;
          OPENWORLD.Sound.play(path: "sounds/fart.wav", volume: 0.1);
          OPENWORLD.Mob.setSpeech(
              group.extra['distancetriggerhitactor'],
              ["Pardom me!", "Sorry about that"], z: 80,
              clearwhendone: true,
              width: 300,
              scale: 0.4);
          group.remove('distancetriggerhitextra');
        }
      };
    }
    threeJs.scene.add( topgroup);
    OPENWORLD.Space.readdObjFromHide(topgroup, dist: citizenhidedist);

    //// 9. one man inc 8
    citizengroup=THREE.Group();
    var citizen42iii = await OPENWORLD.Actor.copyActor(
        citizen42, randomduration: 0.1,
        texture: "assets/actors/soldier/head3.jpg",
        groupname:"soldier_3",
        action: "walk"); //, action:"idlehold");
    addProgress();

    OPENWORLD.Space.objTurn(citizen42iii,180);
    citizengroup.add(citizen42iii);

    topgroup=THREE.Group();
    topgroup.add(citizengroup);
    citizengroups.add(topgroup);
    threeJs.scene.add( topgroup);
    OPENWORLD.Space.readdObjFromHide(topgroup, dist: citizenhidedist);

    // Check if walking into someone and if so avoid
    for (var top in citizengroups) {
      top.position.x=9999.0; // fudge to stop all of these being visible if you are at the temple at 0,0
      OPENWORLD.BaseObject.setDistanceTrigger(top, dist: 0.15, event:(action) {
        if (action) {
          // If want to do anything extra when get close to a passing citizengroup
          if (top.extra.containsKey('distancetriggerhitextra'))
            top.extra['distancetriggerhitextra'](top);
          var worldpos = OPENWORLD.You.getWorldPos();
          var worldpostop = OPENWORLD.Space.localToWorldObj(top);
          // Check if the object is behind you, if so ignore
          //var ang=OPENWORLD.Space.getAngleBetweensObjs(worldpos, worldpostop);//threeJs.camera, top);
         var ang=OPENWORLD.Space.getAngleBetweensObjs(threeJs.camera, top);
          var angdiff=OPENWORLD.Math.standardAngleSigned(OPENWORLD.Math.angleDifference(ang,OPENWORLD.Camera.turn)).abs();
          if (angdiff<50) {
            var topangle = OPENWORLD.Space.getObjTurn(top);
            //  if you are more to the left left then move to left rather than right
            var avoidposleft = OPENWORLD.Math.vectorMoveForward3(
                worldpostop.x, worldpostop.y, topangle - 90, 0.1);// 0.15/2);
            var avoidposright = OPENWORLD.Math.vectorMoveForward3(
                worldpostop.x, worldpostop.y, topangle + 90, 0.1);// 0.15/2);
            var avoidpos;
            if (OPENWORLD.Math.vectorDistance(worldpos, avoidposleft) >
                OPENWORLD.Math.vectorDistance(worldpos, avoidposright))
              avoidpos = avoidposright;
            else
              avoidpos = avoidposleft;

            //   OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera, avoidpos.x, avoidpos.y,OPENWORLD.Camera.cameraoffset);
            OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                threeJs.camera, avoidpos.x, avoidpos.y,
                OPENWORLD.Camera.cameraoffset, 0.8);

          }
          print("getting close"+angdiff.toString()+" "+OPENWORLD.Math.standardAngle(ang).toString()+" "+OPENWORLD.Camera.turn.toString());
        } else {

        }
      });
    }


    //  ------ Essener

    var citizenxoffset=0.09;
    var yadd2=0.02;

    groupessener=[];
    // 0 -  2 women
    var groupessener1=[];
    groupessener.add(groupessener1);
    var citizen2ii=await OPENWORLD.Actor.copyActor(citizen2);
    threeJs.scene.add(citizen2ii);
    groupessener1.add([citizen2ii,0,0]);

  //  var citizenxoffset=0.09;
    var citizenf2ii=await OPENWORLD.Actor.copyActor(citizenf2);
    threeJs.scene.add(citizenf2ii);
//    var yadd2=0.02;
    groupessener1.add([citizenf2ii,citizenxoffset / 2,yadd2]);

    var child1iii=await OPENWORLD.Actor.copyActor(child1);
    threeJs.scene.add(child1iii);
    groupessener1.add([child1iii,0,yadd2+0.1]);

    var childgirlii=await OPENWORLD.Actor.copyActor(childgirl);
    threeJs.scene.add(childgirlii);
    groupessener1.add([childgirlii,0,yadd2-0.1]);


    // 1 -  2 men
    var xoffset=0.03;
    var groupessener2=[];
    groupessener.add(groupessener2);

    var citizen2iv =await OPENWORLD.Actor.copyActor(citizenoldman);//OPENWORLD.Actor.copyActor(citizen2, texture: "assets/actors/citizen/citizen3.jpg");
    threeJs.scene.add(citizen2iv);
    groupessener2.add([citizen2iv,-xoffset,0]);

    var citizen2v =await OPENWORLD.Actor.copyActor(citizen2);//OPENWORLD.Actor.copyActor(citizen2, texture: "assets/actors/citizen/citizen3.jpg");
    threeJs.scene.add(citizen2v);
    groupessener2.add([citizen2v,xoffset,0]);




    // 2 -  1 woman , 1 man and 1 child
    var groupessener3=[];
    groupessener.add(groupessener3);

    setActorSize(citizenf3);
    threeJs.scene.add(citizenf3);
    groupessener3.add([citizenf3,-xoffset,0]);

    threeJs.scene.add(citizen4);
    groupessener3.add([citizen4,xoffset,0]);

    threeJs.scene.add(child12);
    groupessener3.add([child12,xoffset,0.1]);

    // 3  old woman and child
    var groupessener4=[];
    groupessener.add(groupessener4);

//    var citizenoldwoman2=await OPENWORLD.Actor.copyActor(citizenoldwoman,action:'prostrate');

    citizenoldwoman = await OPENWORLD.Actor.createActor(
//      'assets/actors/citizen/citizen4.glb',//citizenf.glb',
//      'assets/actors/citizen/citizenf3.glb',//citizenf.glb',
      'assets/actors/citizen/citizenoldwoman.glb',//citizenf.glb',
      // texture: "assets/actors/soldier/bodys.png",
      z: actoroffset,
      castshadow:true,
      shareanimations: seller,
      // action: "idle3",//"armsidle",//clap",
      //  randomduration: 0.1,
      //  basic:true
    );
    addProgress();
    setActorSize(citizenoldwoman);
    configAddActor('citizenoldwoman',citizenoldwoman);

    threeJs.scene.add(citizenoldwoman);
    groupessener4.add([citizenoldwoman,-xoffset,0]);

    var childgirl2iiiv=await OPENWORLD.Actor.copyActor(childgirl2);//,texture: "assets/actors/citizen/childgirl2.jpg");
    threeJs.scene.add(childgirl2iiiv);
    groupessener4.add([childgirl2iiiv,xoffset,0]);

    // 4  two soldiers
    var groupessener5=[];
    groupessener.add(groupessener5);
    OPENWORLD.Space.resetRot(soldier2);
    var soldier5=await OPENWORLD.Actor.copyActor(soldier2);
    threeJs.scene.add(soldier5);
   // OPENWORLD.Space.objTurn(soldier5,0);
    groupessener5.add([soldier5,-xoffset,0]);


    soldier22 = await OPENWORLD.Actor.copyActor(
        soldier2, randomduration: 0.1,
        texture:"assets/actors/soldier/head2.jpg",
        groupname:"soldier_3",
        action: "idlehold"); //, action:"idlehold");
    configAddActor('soldier22',soldier22);
    OPENWORLD.Space.resetRot(soldier22);

    //var soldier6=await OPENWORLD.Actor.copyActor(soldier,action:null);
    threeJs.scene.add(soldier22);
   // OPENWORLD.Space.objTurn(soldier22,0);
    groupessener5.add([soldier22,xoffset,0]);


    // 5  man with his sheep
    var groupessener6=[];
    groupessener.add(groupessener6);
    citizen23 = await OPENWORLD.Actor.copyActor(
        citizen2, action: 'prostrate',
        texture: "assets/actors/citizen/citizen23.jpg",
        groupname: "citizen_1");
    configAddActor('citizen23',citizen23);

    var citizen2iii=await OPENWORLD.Actor.copyActor( citizen2,  action:"walkhandright");
    threeJs.scene.add(citizen2iii);
    citizen2iii.extra['essenerwalk']='walkhandright';
    THREE.Group leadanimal = await OPENWORLD.Model.createModel(
        'assets/models/leadanimal.glb');
    addProgress();
    // spear.children[0].scale.setValues(5.0, 5.0, 5.0); //0.15, 0.15, 0.15);
    OPENWORLD.Space.setTurnPitchRoll(leadanimal, 45+90, 0, 0);
    // OPENWORLD.Space.objRoll(pitchfork.children[0], 90);
    //  OPENWORLD.Space.objTurn(pitchfork.children[0], 20 + 180);
    OPENWORLD.Actor.wield(citizen2iii, leadanimal, "Bip01_R_Hand");

    var sheepiii = await OPENWORLD.Actor.copyActor(sheeporig,castshadow: true,action:"walk");
    sheepiii.position.z=-50.0;
    sheepiii.position.x=0.0;
    OPENWORLD.Space.objTurn(sheepiii.children[0],0); // Why this be done
    OPENWORLD.Space.objTurn(sheepiii.children[1],0);
    OPENWORLD.Space.objTurn(sheepiii,0);
    sheepiii.scale.setValues(
        0.7,0.7,0.7);
    citizen2iii.add(sheepiii);
    OPENWORLD.BaseObject.setVisible(sheepiii,true,groupname:"collar");
    groupessener6.add([citizen2iii,0.0,0]);


    // 6  woman with her donkey
    var groupessener7=[];
    groupessener.add(groupessener7);
    var citizenf2iiii=await OPENWORLD.Actor.copyActor(citizenf2,action:"walk");
    threeJs.scene.add(citizenf2iiii);
    groupessener7.add([citizenf2iiii,-0.02,0]);

    var donkeyii=await OPENWORLD.Actor.copyActor(donkeypack,action:"walk");
    threeJs.scene.add(donkeyii);
    groupessener7.add([donkeyii,0.02,0]);

    // 7  one woman
    var groupessener8=[];
    groupessener.add(groupessener8);
    var citizen34ii=await OPENWORLD.Actor.copyActor(citizenf34,action:"walk");
    threeJs.scene.add(citizen34ii);
    groupessener8.add([citizen34ii,0,0]);

    // 8  man with a goat
    var groupessener9=[];
    groupessener.add(groupessener9);

    var citizen42iv=await OPENWORLD.Actor.copyActor( citizen42,  action:"walkhandright");
    threeJs.scene.add(citizen42iv);
    citizen42iv.extra['essenerwalk']='walkhandright';
    OPENWORLD.Actor.wield(citizen42iv, leadanimal.clone(), "Bip01_R_Hand");

    goat = await await OPENWORLD.Actor.createActor(
      // 'assets/actors/citizen/citizen4.glb',//citizenf.glb',
//      'assets/actors/citizen/citizenf3.glb',//citizenf.glb',
      'assets/actors/goat.glb', //citizenf.glb',
      // texture: "assets/actors/soldier/bodys.png",
      // z: actoroffset,
      castshadow: true,
      shareanimations: wilddog,
      duration: 6,
      //action: "prostrate",//"armsidle",//clap",
      //  randomduration: 0.1,
      //  basic:true
    );
    addProgress();
    OPENWORLD.Space.objTurn(goat.children[0], 0);
    OPENWORLD.Space.objTurn(goat.children[1], 0);
    goat.scale.setValues(0.0062 * convscale, 0.0062 * convscale,
        0.0062 * convscale); //25, 0.0025, 0.0025);
    OPENWORLD.BaseObject.setVisible(goat, false,groupname:"collar");  // dont show the collar

    var goatiii = await OPENWORLD.Actor.copyActor(goat,castshadow: true,action:"walk");
    goatiii.position.z=-50.0;
    goatiii.position.x=0.0;
    OPENWORLD.Space.objTurn(goatiii.children[0],0); // Why this be done
    OPENWORLD.Space.objTurn(goatiii.children[1],0);
    OPENWORLD.Space.objTurn(goatiii,0);
    goatiii.scale.setValues(
        0.7,0.7,0.7);
    citizen42iv.add(goatiii);
    OPENWORLD.BaseObject.setVisible(goatiii,true,groupname:"collar");
    groupessener9.add([citizen42iv,0.0,0]);



    for (var group in groupessener) {
      // eg group is groupessener9
      for (var item in group) {
        // the item[0] is the object3d and the rest is the positions
        item[0].position.x=9999.0; // fudge so not visible at the ketoret eg 0,0
        OPENWORLD.Space.readdObjFromHide(item[0], dist: citizenhidedist);
      }
    }



//    var womanlist=[citizenoldwoman,citizenf2,citizenf,citizenf3,citizenf3ii,childgirl,childgirl2];
    groupwomen=[];
    var groupwomen1=[];
    groupwomen.add(groupwomen1);
    var citizenoldwomanii=await OPENWORLD.Actor.copyActor(citizenoldwoman);
  //  citizenoldwomanii.extra['movetoloopstopfunc']=womenMoveToLoopStop;
    threeJs.scene.add(citizenoldwomanii);
    groupwomen1.add([citizenoldwomanii,0,0]);

    citizenxoffset=0.09;
    var citizenf2iv=await OPENWORLD.Actor.copyActor(citizenf2);
   // citizenfiv.extra['movetoloopstopfunc']=womenMoveToLoopStop;
    citizenf2iv.extra['walkaction']='walkstraight';
    threeJs.scene.add(citizenf2iv);
    birdcageorig = await OPENWORLD.Model.createModel(
        'assets/models/birdcage.glb');
    birdcageorig.scale.setValues(0.003,0.003,0.003);
    addProgress();

    var birdcage = birdcageorig.clone();// await OPENWORLD.Model.createModel(
       // 'assets/models/birdcage.glb');
    //  OPENWORLD.Space.setTurnPitchRoll(horn.children[0], -90, 0, 0);
    OPENWORLD.Space.setTurnPitchRoll(birdcage, 0, 90, 0);
    birdcage.position.x=0.1;
    OPENWORLD.Actor.wield(citizenf2iv, birdcage, "Bip01_R_Hand");
    pigeon= await OPENWORLD.Model.createModel(
        'assets/models/pigeon.glb');
    addProgress();
    birdcage.add(pigeon);
    yadd2=0.02;
    groupwomen1.add([citizenf2iv,citizenxoffset / 2,yadd2]);

    var childgirliii=await OPENWORLD.Actor.copyActor(childgirl);
   // childgirliii.extra['movetoloopstopfunc']=womenMoveToLoopStop;
    threeJs.scene.add(childgirliii);
    groupwomen1.add([childgirliii,0,yadd2-0.1]);



    var groupwomen2=[];
    groupwomen.add(groupwomen2);
    var citizenf22ii=await OPENWORLD.Actor.copyActor(citizenf22);
   // citizenf2ii.extra['movetoloopstopfunc']=womenMoveToLoopStop;
    citizenf22ii.extra['walkaction']='walkstraight';
    threeJs.scene.add(citizenf22ii);
    groupwomen2.add([citizenf22ii,-0.05,0]);
    var goatii = await OPENWORLD.Actor.copyActor(goat,castshadow: true,action:"walk");
    goatii.position.z=-50.0;
    goatii.position.x=0.0;
    goatii.scale.setValues(
        0.7,0.7,0.7);
    citizenf22ii.add(goatii);
    citizenf22ii.extra['sacrifice']=goatii;
    OPENWORLD.BaseObject.setVisible(goatii,true,groupname:"collar");


    var childgirl2ii=await OPENWORLD.Actor.copyActor(childgirl2);
    threeJs.scene.add(childgirl2ii);
    groupwomen2.add([childgirl2ii,0.05,0]);
    //childgirl2ii.extra['movetoloopstopfunc']=womenMoveToLoopStop;

    var groupwomen3=[];
    groupwomen.add(groupwomen3);
    var citizenf3iii=await OPENWORLD.Actor.copyActor(citizenf3);
    citizenf3iii.extra['walkaction']='walkstraight';
    //citizenf3iii.extra['movetoloopstopfunc']=womenMoveToLoopStop;
    threeJs.scene.add(citizenf3iii);
    groupwomen3.add([citizenf3iii,0,0]);
    var sheep = await OPENWORLD.Actor.copyActor(sheeporig,castshadow: true,action:"walk");
    sheep.position.z=-50.0;
    sheep.position.x=0.0;
    OPENWORLD.Space.objTurn(sheep.children[0],0); // Why this be done
    OPENWORLD.Space.objTurn(sheep.children[1],0);
    OPENWORLD.Space.objTurn(sheep,0);
    sheep.scale.setValues(
        0.7,0.7,0.7);
    citizenf3iii.add(sheep);
    citizenf3iii.extra['sacrifice']=sheep;
    OPENWORLD.BaseObject.setVisible(sheep,true,groupname:"collar");
   // threeJs.scene.add(sheep);
  //  groupwomen3.add([sheep,0,0.2]);



    var groupwomen4=[];
    groupwomen.add(groupwomen4);
    var citizenf32ii=await OPENWORLD.Actor.copyActor(citizenf32);
    threeJs.scene.add(citizenf32ii);
    groupwomen4.add([citizenf32ii,-0.05,0]);
    var pigeon2= pigeon.clone();
    pigeon2.scale.setValues(
       1.2,1.2,1.2);
    pigeon2.position.y=8.0;
    OPENWORLD.Actor.wield(citizenf32ii, pigeon2, "Bip01_R_Hand");

    var childgirl2iii=await OPENWORLD.Actor.copyActor(childgirl2);
    threeJs.scene.add(childgirl2iii);
    groupwomen4.add([childgirl2iii,0.05,0]);

    for (var group in groupwomen)
      for (var item in group) {
        item[0].position.x=9999.0; // fudge so not visible at the ketoret eg 0,0
        OPENWORLD.Space.readdObjFromHide(item[0], dist: citizenhidedist);
      }


    // ---------- South Jerusalem House
    // Really should move back to hotload_lowercity
    var centerx=-16.93;
    var centery=-45.19;

    manger= await OPENWORLD.Model.createModel('assets/models/manger.glb');
    addProgress();
    threeJs.scene.add(manger);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        manger,centerx+(-17.65-centerx)*0.5, centery+(-45.39-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    manger.scale.setValues(0.03*0.5, 0.03*0.5, 0.03*0.5);

    var manger2=manger.clone();
    threeJs.scene.add(manger2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        manger2,centerx+(-17.50-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);

    // Why did you have basic true?
    hay= await OPENWORLD.Model.createModel('assets/models/hay.glb');//, basic:true);
    addProgress();
    hay.scale.setValues(0.03*0.5, 0.03*0.5, 0.03*0.5);
    instancedHays= InstancedModel.fromTemplate(hay, 30, threeJs.scene,name:'hay');
    instancedHays.hideDistance=3.0;
    instancedModels.add(instancedHays);
    instancedHaysHearth= InstancedModel.fromTemplate(hay, 20, threeJs.scene,name:'hayhearth');
    instancedHaysHearth.hideDistance=0.5;
    instancedModels.add(instancedHaysHearth);


    threeJs.scene.add(hay);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay,centerx+(-17.76-centerx)*0.5, centery+(-45.31-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
  /*  hay?.traverse( (child) {
      if(child is THREE.Mesh && child.material is THREE.MeshStandardMaterial){
        // print("oo"+(child.material as THREE.MeshStandardMaterial).name.toString());
        // !!!why must this be done
        child.material=THREE.MeshBasicMaterial.fromMap({'map': child.material?.map});
        child.material?.color= THREE.Color.fromHex32(0xaaaaaa);
       //var mat=child.material;
       // mat?.shininess = 0.0;
        // mat?.metalness=1;
       // mat?.roughness=1.0;
       // mat?.emissive = THREE.Color.fromHex32(0x000000);
      }
    });*/

   /* old cart with apples
    var cart2= await OPENWORLD.Actor.copyActor(cart,action:"idle");//await OPENWORLD.Model.createModel('assets/models/cart.glb');
    threeJs.scene.add(cart2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cart2,centerx+(-18.04-centerx)*0.5-0.01, centery+(-45.35-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
   // cart.scale.setValues(0.01 * convscale, 0.01 * convscale,
   //     0.01 * convscale);
    OPENWORLD.Space.objTurn(cart2,90);*/


    var smoke3 = Smoke();
    var smokeGroup2 =
    await smoke3.createSmoke('assets/textures/smoke/clouds64.png');
    addProgress();

    //var smokeGroup2=smokeGroup.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smokeGroup2,   -17.08, -45.05, 0.25,3);//centerx+(-17.02-centerx)*0.5, centery+(-45.58-centery)*0.5, 0.51*0.5, 3);
   /// OPENWORLD.Space.worldToLocalSurfaceObjHide(
   //     smokeGroup2,  -16.85,-45.25, 0.51*0.5, 3);
    smokeGroup2.scale.setValues(0.00007*0.5, 0.00007*0.5, 0.00007*0.5);
    OPENWORLD.Updateables.add(smoke3);
    threeJs.scene.add(smokeGroup2);

    // This is the general terrain sounds
    roomTerrain = OPENWORLD.Room.createRoom(0,0, volume: 0.05, name:"terrain",soundpathfunc: (room){
      print("room sound path func");
      var worldpos = OPENWORLD.You.getWorldPos();
      var forest=worldpos.x>16||worldpos.y<-57.7||worldpos.y>67||worldpos.x<-66||(worldpos.y<-1.6&&worldpos.x<-47)||(worldpos.x>4.2&&worldpos.y<-31.82);
      var jerusalem=!forest;
                             //-12.9 east pilgrims      // -16.7 is shop                          //9.6 is north of antonios
      var backyard=jerusalem&&(worldpos.x<-12.9||        (worldpos.y<-16.7&&worldpos.x>-3.8)||worldpos.y>9.6);
          //&&
         // !(worldpos.y< 20.0+0.5&& worldpos.y> 14.64-0.5&&worldpos.x>6.8-0.5&&worldpos.x< 8.98+0.5);  // Courtyard around bethesda
      var courtyard=jerusalem&&!backyard;
      OPENWORLD.Room.setBackgroundVolume(room,0.05);
      if (gamestart==GameStart.hearth)
        return "sounds/hearth.mp3";
      if (OPENWORLD.Time.isNight(OPENWORLD.Time.time))
        return "sounds/crickets.mp3";
      else if (forest) {
        OPENWORLD.Room.setBackgroundVolume(room,0.2);
        return 'sounds/forest.mp3';
      } else if (backyard) {
        OPENWORLD.Room.setBackgroundVolume(room,0.4);
        return 'sounds/backyard.mp3';
      } else if (courtyard)
        return 'sounds/courtyard.mp3';// OPENWORLD.Math.randPick(['sounds/courtyard.mp3','sounds/courtyard2.mp3']);

      /*,soundpath: "sounds/forest.mp3",*/
    });//, beforeenter:defaultBeforeEnter); //THREE.Object3D();
    OPENWORLD.Room.setDistanceTrigger( roomTerrain , dist:130,          event: (action) {
      //  maxy: 13.67, miny: 13.13, minx: 57.28, maxx: 57.73, event:(action) {
      if (action) {
        print ("in room default");

      } else {
      // this is never called because you are always inside
        print ("out room default ");
      }
    });
    // This so by default you dont enter roomTerrain
    OPENWORLD.BaseObject.removeDistanceTrigger(roomTerrain);

    // Show hotloaded objects - this function is called every time hotload
    chicken = await OPENWORLD.Actor.createActor(
        'assets/actors/chicken.glb',
        //    z: actoroffset,
        // shareanimations: dog, //_seagull,
        // action:"dance",
        //  castshadow: true,
        // action: null,
        randomduration: 0.1);
    addProgress();
    chicken.scale.setValues(0.0005, 0.0005, 0.0005);


    woodbundle = await OPENWORLD.Model.createModel(
        'assets/models/woodbundle.glb');
    addProgress();
   // woodbundle.scale.setValues(0.011, 0.011, 0.011);
    instancedWoodbundle = InstancedModel.fromTemplate(woodbundle, 40, threeJs.scene,name:'woodbundle');
    instancedWoodbundle.hideDistance=2.0;
    instancedModels.add(instancedWoodbundle);


    bedding = await OPENWORLD.Model.createModel(
        'assets/models/bedding.glb');
    addProgress();
    instancedBeddings = InstancedModel.fromTemplate(bedding, 100, threeJs.scene,name:'bedding');
    instancedBeddings.hideDistance=2.0;
    instancedModels.add(instancedBeddings);
    pillow = await OPENWORLD.Model.createModel(
        'assets/models/pillow.glb');
    addProgress();
    instancedPillows = InstancedModel.fromTemplate(pillow, 100, threeJs.scene,name:'pillow');
    instancedPillows.hideDistance=2.0;
    instancedModels.add(instancedPillows);
    robes = await OPENWORLD.Model.createModel(
        'assets/models/robeshanging.glb');
    addProgress();

    // there is one of these in lowercity
    fence2 = await OPENWORLD.Model.createModel('assets/models/fencesmall.glb',  // this is the rocks
      //  basic:true
      //   castshadow: true
    );
    addProgress();
    //  hotloadAdd(firsthotload, false, fence2);
//    _hotload.add(fence2);
    //  OPENWORLD.Space.worldToLocalSurfaceObjHide(
    //      fence2, -10.99, -49.59, 0.02,
    //       4); //-11.1, -49.88,-0.01,4);//-9.29, -51.97,0,4);//-9.52, -52.15,0,4);//-8.95, -52.09,-0.02, 4); // 3.2,2.5, 0.0);
    fence2.scale.setValues(0.02, 0.02, 0.02);

    sack= await OPENWORLD.Model.createModel('assets/models/sack.glb');
    addProgress();
    sack.scale.setValues(0.0002 , 0.0002 , 0.0002  );

    basketwickerfigs= await OPENWORLD.Model.createModel('assets/models/basketwicker/basketwicker.glb');
    addProgress();
    basketwickerfigs.scale.setValues(0.015 , 0.015 , 0.015 );

    basketwicker= basketwickerfigs.clone();
    OPENWORLD.BaseObject.setVisible(
        basketwicker, false, groupname: "figs");
    OPENWORLD.BaseObject.setVisible(
        basketwicker, false, groupname: "figstop");
    instancedBasketWicker = InstancedModel.fromTemplate( basketwicker,60, threeJs.scene,name:'basketwicker');
    instancedBasketWicker.hideDistance=7.0;
    instancedModels.add(instancedBasketWicker);

    basketwickerolives=    await OPENWORLD.Model.copyModel(basketwickerfigs,
        texture: "assets/models/basketwicker/olives.jpg",
        groupname: 'figs');
    addProgress();
    OPENWORLD.BaseObject.setVisible(
        basketwickerolives, false, groupname: "figstop");
    basketwickerolivesblack=    await OPENWORLD.Model.copyModel(basketwickerfigs,
        texture: "assets/models/basketwicker/olivesblack.jpg",
        groupname: 'figs');
    addProgress();
    OPENWORLD.BaseObject.setVisible(
        basketwickerolivesblack, false, groupname: "figstop");

    basketwickerdeepapples= await OPENWORLD.Model.createModel('assets/models/basketwickerdeepapples/basketwickerdeepapples.glb');
    addProgress();
    basketwickerdeepapples.scale.setValues(0.015 , 0.015 , 0.015 );
//    basketwickerdeepapples.scale.setValues(0.0005*0.5 , 0.0005*0.5 ,
  //      0.0005*0.5 );

    basketwickerdeeppears = await OPENWORLD.Model.copyModel(basketwickerdeepapples,
        texture: "assets/models/basketwickerdeepapples/pear.jpg",
        groupname: 'apples');
    addProgress();

    tannur = await OPENWORLD.Model.createModel(
        'assets/models/tannur.glb'); //oven.glb');
    addProgress();
    tannur.scale.setValues(0.03, 0.03, 0.03);

    oven = await OPENWORLD.Model.createModel(
        'assets/models/oven.glb');
    addProgress();
    oven.scale.setValues(0.044, 0.044, 0.044);

    tablelimestone = await OPENWORLD.Model.createModel(
        'assets/models/tablelimestone.glb');
    addProgress();
    tablelimestone.scale.setValues(0.02, 0.02, 0.02);


    pitchfork = await OPENWORLD.Model.createModel(
        'assets/models/pitchfork.glb');
    addProgress();
    pitchfork.children[0].scale.setValues(5.0, 5.0, 5.0);

    fence3 = await OPENWORLD.Model.createModel(   // this is the fence inside the barn
        'assets/models/fence3.glb');
    addProgress();
    fence3.scale.setValues(0.012, 0.012, 0.012);

    pot = await OPENWORLD.Model.createModel('assets/models/pot.glb');
    pot.scale.setValues(0.03 * 0.5, 0.03 * 0.5, 0.03 * 0.5);

    chisel = await OPENWORLD.Model.createModel(
        'assets/models/chisel.glb');
    addProgress();
    chisel.scale.setValues(0.007, 0.007, 0.007);

    hammer = await OPENWORLD.Model.createModel(
        'assets/models/hammer.glb');
    addProgress();
    hammer.scale.setValues(0.007, 0.007, 0.007);

    saw = await OPENWORLD.Model.createModel(
        'assets/models/saw.glb');
    addProgress();
    saw.scale.setValues(0.007, 0.007, 0.007);

    board = await OPENWORLD.Model.createModel('assets/models/board.glb');
    addProgress();
    board.scale.setValues(0.0003, 0.0011, 0.0011);

    shovel = await OPENWORLD.Model.createModel(
        'assets/models/shovel.glb');
    addProgress();
    shovel.scale.setValues(0.017, 0.017, 0.017);

    basket = await OPENWORLD.Model.createModel(
        'assets/models/basket.glb');
    addProgress();
    basket.scale.setValues(0.003, 0.003, 0.003);
    instancedBasket = InstancedModel.fromTemplate( basket,60, threeJs.scene,name:'basket');
    instancedBasket.hideDistance=7.0;
    instancedModels.add(instancedBasket);

    plate = await OPENWORLD.Model.createModel('assets/models/plate.glb');
    plate.scale.setValues(0.0012, 0.0012, 0.0012);
    addProgress();
//    plate.scale.setValues(0.0015, 0.0015, 0.0015);

    amphora = await OPENWORLD.Model.createModel(
        'assets/models/amphora.glb');
    addProgress();
    amphora.scale.setValues(0.033, 0.033, 0.033);

    cup = await OPENWORLD.Model.createModel('assets/models/cup.glb');
    addProgress();
    cup.scale.setValues(0.0004, 0.0004, 0.0004);
//    cup.scale.setValues(0.0005, 0.0005, 0.0005);
    instancedCup = InstancedModel.fromTemplate(cup,60, threeJs.scene,name:'cup');
    instancedCup.hideDistance=7.0;
    instancedModels.add(instancedCup);


    breadunleaven = await OPENWORLD.Model.createModel(
        'assets/models/breadunleaven.glb');
    addProgress();
    breadunleaven.scale.setValues(
        100.0, 100.0, 100.0); //0.0015,0.0015,0.0015);

    breadleavened= await OPENWORLD.Model.createModel(
        'assets/models/breadleavened.glb'); //,texture:"assets/detailmap.png");
    addProgress();
    breadleavened.scale.setValues(0.008,0.008,0.008);

    bread= breadleavened.clone();//await OPENWORLD.Model.createModel(
    //  'assets/models/breadleavened.glb'); //,texture:"assets/detailmap.png");
    bread.scale.setValues(0.0005,0.0005,0.0005);

    clothesline = await OPENWORLD.Model.createModel(
        'assets/models/clothesline.glb');
    addProgress();
    clothesline.scale.setValues(0.08 * 0.5, 0.08 * 0.5, 0.08 * 0.5);

    table = await OPENWORLD.Model.createModel('assets/models/table.glb');
    addProgress();
    table.scale.setValues(0.011, 0.011, 0.011);

    firepit = await OPENWORLD.Model.createModel(
        'assets/models/firepit.glb');
    addProgress();
    firepit.scale.setValues(0.03, 0.03, 0.03);

    cistern = await OPENWORLD.Model.createModel(
        'assets/models/cistern.glb');
    addProgress();
    cistern.scale.setValues(0.015, 0.015, 0.015);

    ladder = await OPENWORLD.Model.createModel(
        'assets/models/ladder.glb');
    addProgress();
    ladder.scale.setValues(0.014, 0.014, 0.014);  //0.013
//    ladder.scale.setValues(0.0135, 0.0135, 0.0135);  //0.013

    loom = await OPENWORLD.Model.createModel('assets/models/loom.glb');
    addProgress();
    loom.scale.setValues(0.007, 0.007, 0.007);

    loomweight = await OPENWORLD.Model.createModel(
        'assets/models/loomweight.glb');
    addProgress();
    loomweight.scale.setValues(0.007, 0.007, 0.007);

    doorhouse2= await await OPENWORLD.Model.createModel('assets/models/doorhouse2.glb');//OPENWORLD.Plane.loadPlane(
    addProgress();
    //  'assets/models/temple/house2door.jpg', 0.045, 0.165, doublesided:true);
    doorhouse2.scale.setValues(0.1, 0.12, 0.08);

    mortar = await OPENWORLD.Model.createModel(
        'assets/models/mortar.glb');
    addProgress();
    mortar.scale.setValues(0.006, 0.006, 0.006);

    packdonkeybuckets = await OPENWORLD.Model.createModel('assets/models/packdonkeybuckets.glb');
    addProgress();
    packdonkeybuckets.scale.setValues(0.002 , 0.002, 0.002);

    mati = await OPENWORLD.Model.createModel('assets/models/mat.glb');
    addProgress();
    mati.scale.setValues(1.0, 1.0, 1.0);

    clotheshanging = await OPENWORLD.Model.createModel(
        'assets/models/clotheshanging.glb');
    addProgress();
    clotheshanging.scale.setValues(0.007, 0.007, 0.007);

    lamp = await OPENWORLD.Model.createModel('assets/models/lamp.glb');
    addProgress();
    lamp.scale.setValues(0.005, 0.005, 0.005);

    matrolled = await OPENWORLD.Model.createModel(
        'assets/models/matrolled.glb');
    addProgress();
    matrolled.scale.setValues(0.01, 0.01, 0.01);
    instancedMatrolled = InstancedModel.fromTemplate(matrolled,60, threeJs.scene,name:'matrolled');
    instancedMatrolled.hideDistance=7.0;
    instancedModels.add(instancedMatrolled);

    jug = await OPENWORLD.Model.createModel('assets/models/jug.glb');
    addProgress();
    jug.scale.setValues(0.015, 0.015, 0.015);

    millstone = await OPENWORLD.Model.createModel(
        'assets/models/millstone.glb');
    addProgress();
    millstone.scale.setValues(0.03, 0.03, 0.03);

    citizenoldman2 = await OPENWORLD.Actor.createActor(
      'assets/actors/citizen/citizenoldman2.glb', //citizenf.glb',
      // texture: "assets/actors/soldier/bodys.png",
      z: actoroffset,
      castshadow: true,
      shareanimations: seller,
      //   action: "prostrate",//"armsidle",//clap",
      //  randomduration: 0.1,
      //  basic:true
    );
    addProgress();

    setActorSize(citizenoldman2);
    configAddActor('citizenoldman2',citizenoldman2);
    citizen22 = await OPENWORLD.Actor.copyActor(
        citizen2, action: 'prostrate',
        texture: "assets/actors/citizen/citizen22.jpg",
        groupname: "citizen_1");
    addProgress();
    configAddActor('citizen22',citizen22);


    citizenoldman22 = await OPENWORLD.Actor.copyActor(
        citizenoldman2, action: 'prostrate',
        texture: "assets/actors/citizen/citizenoldman22.jpg",
        groupname: "citizen_1");
    addProgress();
    configAddActor('citizenoldman22',citizenoldman22);

    hoe = await OPENWORLD.Model.createModel(
        'assets/models/hoe.glb');
    addProgress();
    hoe.scale.setValues(0.017, 0.017, 0.017);
    cratelentils = await OPENWORLD.Model.createModel(
        'assets/models/crate/crate.glb');
    addProgress();
    cratelentils.scale.setValues(0.02, 0.02, 0.02);
    crateclothes = cratelentils.clone();
    await OPENWORLD.Model.setTexture(
        crateclothes, "assets/models/crate/cloak.jpg", groupname: "left");
    addProgress();
    await OPENWORLD.Model.setTexture(
        crateclothes, "assets/models/crate/cloak2.jpg", groupname: "middle");
    addProgress();
    await OPENWORLD.Model.setTexture(
        crateclothes, "assets/models/crate/blanket.jpg", groupname: "right");
    addProgress();

    shopawning = await OPENWORLD.Model.createModel(
        'assets/models/shopawning.glb',castshadow:true);
    addProgress();
    shopawning.scale.setValues(0.45, 0.45, 0.45);
    instancedShopawnings = InstancedModel.fromTemplate(shopawning,30, threeJs.scene,name:'shopawning');
    instancedShopawnings.hideDistance=20.0;
    instancedModels.add(instancedShopawnings);


    bowl = await OPENWORLD.Model.createModel(
        'assets/models/bowl.glb',castshadow:true);
    addProgress();
    bowl.scale.setValues(0.006, 0.006, 0.006);
    OPENWORLD.BaseObject.setVisible(bowl, false,groupname:"liquid");

    boxlimestone = await OPENWORLD.Model.createModel(
        'assets/models/boxlimestone.glb',castshadow:true);
    addProgress();
    boxlimestone.scale.setValues(0.006, 0.006, 0.006);

    shofar = await OPENWORLD.Model.createModel(
        'assets/models/shofar.glb');
    addProgress();

    flute = await OPENWORLD.Model.createModel(
        'assets/models/flute.glb');

    lyrewield = await OPENWORLD.Model.createModel('assets/models/lyre.glb');
    lyrewield.position.y = 30.0;
    lyrewield.position.x = 5.0;
    lyrewield.position.z = 15.0;
    lyrewield.scale.setValues(10.0, 10.0, 10.0);
    addProgress();


    priest3 = await OPENWORLD.Actor.createActor(
      //THREE.Group citizenf = await OPENWORLD.Model.createModel(
        'assets/actors/priest/priest3.glb', //citizenf.glb',
        // texture: "assets/actors/soldier/bodys.png",
        z: actoroffset,
        shareanimations: seller,
        action: null, //"armsidle",//clap",
        //  randomduration: 0.1,
        castshadow: true //  basic:true
    );
    addProgress();
    setActorSize(priest3);
    final sashmaterial = THREE.MeshStandardMaterial.fromMap({
      //  'normalMap': bumpTexture,
      'color': 0xff3333,
      'metalness': 1.0, // 0,
      //'map': goldii,
      'shininess': 1.0,
      'roughness': 0.5,
      // 'em'
      //   'emissive':THREE.Color.fromHex32(0x000000)
      //'envMap': gold,
      //'envMapIntensity': 1.0,// api['envMapIntensity'],
    });
    OPENWORLD.Texture.setMaterial(
        priest3, sashmaterial, groupname: "citizen_2");

    priest32 = await OPENWORLD.Actor.copyActor(
      priest3, texture: "assets/actors/priest/head32.jpg",//priest32.jpg",
      groupname: "citizen_3",//1",
      castshadow: true,); //action:"laysideidle",   );
    addProgress();


    priest33 = await OPENWORLD.Actor.copyActor(
        priest3, texture: "assets/actors/priest/head33.jpg",//priest33.jpg",
        groupname: "citizen_3",//1",
        action: null,
        castshadow: true);
    addProgress();


    priest34 = await OPENWORLD.Actor.copyActor(
        priest3, texture: "assets/actors/priest/head34.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true); //"stoopdown",duration:2.0);//idle");
    addProgress();

    priest35 = await OPENWORLD.Actor.copyActor(
        priest3, texture: "assets/actors/priest/head35.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true); //"stoopdown",duration:2.0);//idle");
    addProgress();

    priest36 = await OPENWORLD.Actor.copyActor(
        priest3, texture: "assets/actors/priest/head36.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true); //"stoopdown",duration:2.0);//idle");
    addProgress();

    priest37 = await OPENWORLD.Actor.copyActor(
        priest3, texture: "assets/actors/priest/head37.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true); //"stoopdown",duration:2.0);//idle");
    addProgress();
    priest38 = await OPENWORLD.Actor.copyActor(
        priest3, texture: "assets/actors/priest/head38.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true); //"stoopdown",duration:2.0);//idle");
    addProgress();

    priest3clothed=await OPENWORLD.Actor.copyActor(
        priest3, texture: "assets/actors/priest/head31hair.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true);
    addProgress();
    await OPENWORLD.Model.setTexture(priest3clothed, "assets/actors/priest/priestclothed.jpg",groupname:"citizen_2");
    addProgress();
    await OPENWORLD.Model.setTexture(priest3clothed, "assets/actors/priest/priestclothed.jpg",groupname:"citizen_1");
    addProgress();
    priest3.extra['clothed']=priest3clothed;
    configAddActor('priest3clothed',priest3clothed);

    priest3clothed.extra['robes']=priest3;
    priest32clothed=await OPENWORLD.Actor.copyActor(
        priest3clothed, texture: "assets/actors/priest/head32hair.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true);
    addProgress();
    priest32.extra['clothed']=priest32clothed;
    priest32clothed.extra['robes']=priest32;
    priest33clothed=await OPENWORLD.Actor.copyActor(
        priest3clothed, texture: "assets/actors/priest/head33hair.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true);
    addProgress();
    await OPENWORLD.Model.setTexture(priest32clothed, "assets/actors/priest/priestclothed2.jpg",groupname:"citizen_2");
    addProgress();
    await OPENWORLD.Model.setTexture(priest32clothed, "assets/actors/priest/priestclothed2.jpg",groupname:"citizen_1");
    addProgress();
    priest33.extra['clothed']=priest33clothed;
    priest33clothed.extra['robes']=priest33;
    priest34clothed=await OPENWORLD.Actor.copyActor(
        priest32clothed, texture: "assets/actors/priest/head34hair.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true);
    addProgress();
    priest34.extra['clothed']=priest34clothed;
    priest34clothed.extra['robes']=priest34;
    priest35clothed=await OPENWORLD.Actor.copyActor(
        priest3clothed, texture: "assets/actors/priest/head35hair.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true);
    addProgress();
    priest35.extra['clothed']=priest35clothed;
    priest35clothed.extra['robes']=priest35;
    priest36clothed=await OPENWORLD.Actor.copyActor(
        priest32clothed, texture: "assets/actors/priest/head36hair.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true);
    addProgress();
    priest36.extra['clothed']=priest36clothed;
    priest36clothed.extra['robes']=priest36;
    priest37clothed=await OPENWORLD.Actor.copyActor(
        priest3clothed, texture: "assets/actors/priest/head37hair.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true);
    addProgress();
    priest37.extra['clothed']=priest37clothed;
    priest37clothed.extra['robes']=priest37;
    priest38clothed=await OPENWORLD.Actor.copyActor(
        priest32clothed, texture: "assets/actors/priest/head38hair.jpg",//priest34.jpg",
        groupname: "citizen_3",//1",
        castshadow: true);
    addProgress();
    priest38.extra['clothed']=priest38clothed;
    priest38clothed.extra['robes']=priest38;
    priestlist = [priest3, priest32, priest33, priest34, priest35, priest36, priest37, priest38];

    column = await OPENWORLD.Model.createModel(
        'assets/models/column.glb');
    addProgress();

    instancedColumns = InstancedModel.fromTemplate(column, 700, threeJs.scene,name:'column');
    instancedColumns.hideDistance=15.0;
    instancedModels.add(instancedColumns);
    instancedColumnsSiloam = InstancedModel.fromTemplate(column, 30, threeJs.scene,name:'columnsiloam');
    instancedColumnsSiloam.hideDistance=10.0;
    instancedModels.add(instancedColumnsSiloam);
    instancedColumnsBethesda = InstancedModel.fromTemplate(column, 200, threeJs.scene,name:'columnbethesda');
    instancedColumnsBethesda.hideDistance=10.0;
    instancedModels.add(instancedColumnsBethesda);


    goldmaterial = THREE.MeshStandardMaterial.fromMap({
      //  'normalMap': bumpTexture,
      'color': 0xffff33,
      'metalness': 1.0, // 0,
      //'map': goldii,
      'shininess': 1.0,
      'roughness': 0.5,
      // 'em'
      //   'emissive':THREE.Color.fromHex32(0x000000)
      //'envMap': gold,
      //'envMapIntensity': 1.0,// api['envMapIntensity'],
    });

    goldmaterialnormal = THREE.MeshStandardMaterial.fromMap({
      //  'normalMap': bumpTexture,
      'color': 0xffff33,
      'metalness': 1.0, // 0,
      //'map': goldii,
      'shininess': 1.0,
      'roughness': 0.5,
      // 'em'
      //   'emissive':THREE.Color.fromHex32(0x000000)
      //'envMap': gold,
      //'envMapIntensity': 1.0,// api['envMapIntensity'],
    });
    goldmaterialnormal?.normalMap = normalcherubum;
    goldmaterialnormal?.normalScale = THREE.Vector2(10.0, 10.0);
    goldmaterialnormal?.normalMap?.wrapS = THREE.RepeatWrapping;
    goldmaterialnormal?.normalMap?.wrapT = THREE.RepeatWrapping;
    citizenpathsouthfriend= generatePathSouthFriend();//getpathoffset(citizenpathsouth,false,0.07);

    shewbread = await OPENWORLD.Model.createModel(
        'assets/models/shewbread.glb');
    addProgress();
    shewbread.scale.setValues(0.03, 0.03, 0.03);

    altargreat = await OPENWORLD.Model.createModel(
        'assets/models/altargreat.glb');
    addProgress();
    altargreat.scale.setValues(0.9, 0.9, 0.9);

    clothespile = await OPENWORLD.Model.createModel(
        'assets/models/clothespile.glb'); //robes2ii.clone();
    addProgress();
    clothespile.scale.setValues(0.005 ,
        0.005 ,
        0.005 );

    spear = await OPENWORLD.Model.createModel(
        'assets/models/spear.glb');
    addProgress();

    seagull = await OPENWORLD.Actor.createActor(
        'assets/actors/seagull.glb', shareanimations: chicken,
        action: "fly",
        duration: 0.5);
    addProgress();
    // Set the shofar to be the default size
    seagull.scale.setValues(0.001, 0.001, 0.001);

    ring = await OPENWORLD.Model.createModel(
        'assets/models/ring.glb');//, castshadow:true);
    addProgress();
    //  _hotload.add(ring);
    ring.scale.setValues(0.0015, 0.0015, 0.0015);
    OPENWORLD.Texture.setMaterial(ring, bronzemat!);
    instancedRings = InstancedModel.fromTemplate(ring, 30, threeJs.scene,name:'ring');
    instancedRings.hideDistance=3.0;
    instancedModels.add(instancedRings);

    grapevine = await OPENWORLD.Model.createModel(
        'assets/models/grapevine.glb');
    addProgress();

    grapevine.scale.setValues(0.18, 0.18, 0.18);

    curtain = await OPENWORLD.Model.createModel(
        'assets/models/curtain.glb');
    addProgress();
    curtain.scale.setValues(0.3, 0.6, 0.6);

    chain = await OPENWORLD.Model.createModel(
        'assets/models/chain.glb');
    addProgress();
    chain.scale.setValues(0.6, 0.6, 0.6);

    pillar = await OPENWORLD.Model.createModel(
        'assets/models/pillar.glb');//,castshadow: true);
    addProgress();
    pillar.scale.setValues(0.035, 0.035, 0.035);
    OPENWORLD.BaseObject.setVisible(
        pillar,false, groupname: "carcass");
    instancedPillars = InstancedModel.fromTemplate(pillar, 10, threeJs.scene,name:'pillar');
    instancedPillars.hideDistance=4.0;
    instancedModels.add(instancedPillars);

    sheephead = await OPENWORLD.Model.createModel(
        'assets/models/meat/sheephead.glb');
    addProgress();
    sheepleg = await OPENWORLD.Model.createModel(
        'assets/models/meat/sheepleg.glb');
    addProgress();
    meatfrontleg = await OPENWORLD.Model.createModel(
        'assets/models/meat/meatfrontleg.glb');
    addProgress();
    meatchunk = await OPENWORLD.Model.createModel(
        'assets/models/meat/meatchunk.glb');
    addProgress();
    rib = await OPENWORLD.Model.createModel('assets/models/meat/rib.glb');
    addProgress();
    intestines = await OPENWORLD.Model.createModel(
        'assets/models/meat/intestines.glb');
    addProgress();
    shank = await OPENWORLD.Model.createModel(
        'assets/models/meat/shank.glb');
    addProgress();

    vesselbazichtamid = await OPENWORLD.Model.createModel('assets/models/vesselbazichtamid.glb');
    addProgress();
    OPENWORLD.Texture.setMaterial(vesselbazichtamid, silvermaterial!);

    vesselbowl = await OPENWORLD.Model.createModel(
        'assets/models/vesselbowl.glb');
    addProgress();
    OPENWORLD.Texture.setMaterial(
        vesselbowl, goldmaterial!, groupname: 'gold');
    vesseltray = await OPENWORLD.Model.createModel(
        'assets/models/vesseltray.glb');
    addProgress();
    OPENWORLD.Texture.setMaterial(
        vesseltray, goldmaterial!, groupname: 'gold');

    vesselpitcher = await OPENWORLD.Model.createModel(
        'assets/models/vesselpitcher.glb');
    addProgress();
    OPENWORLD.Texture.setMaterial(
        vesselpitcher, goldmaterial!); //,groupname:'gold');

    vessellist = [vesselbowl, vesseltray, vesselpitcher];

    doorwood = await OPENWORLD.Model.createModel(
        'assets/models/doorwood.glb');
    addProgress();
    doorwood.scale.setValues(0.2, 0.52, 0.2);
    OPENWORLD.Texture.setMaterial(doorwood, bronzematclean!,groupname:"handle");

    doornicanor=await OPENWORLD.Model.createModel(
        'assets/models/doornicanor.glb');
    addProgress();
    //  doornicanor.scale.setValues(0.2, 0.52, 0.2);
    OPENWORLD.Texture.setMaterial(
        doornicanor, bronzemat!, groupname: "door");
    OPENWORLD.Texture.setMaterial(
        doornicanor, goldmaterialpalm!, groupname: "palm");

    menorah = await OPENWORLD.Model.createModel('assets/models/menorah.glb');
    addProgress();
    menorahflamemat =
    await OPENWORLD.Texture.getMaterialByGroupname(menorah, "flamepng");
    OPENWORLD.Texture.setEmissive(menorah, THREE.Color.fromHex32(0xFFA500),
        groupname: "flamepng"); // emissive)
    menorah?.scale.setValues(0.02, 0.02, 0.02);
    OPENWORLD.Texture.setMaterial(menorah, goldmaterial!, groupname: "menorah");

    lampbronze = await OPENWORLD.Model.createModel('assets/models/lampbronze.glb');
    addProgress();
//    lampbronze.scale.setValues(0.005, 0.005, 0.005);
    OPENWORLD.Texture.setMaterial(lampbronze,bronzematclean!,groupname:"lamp");
    OPENWORLD.Texture.setEmissive(lampbronze, THREE.Color.fromHex32(0xFFA500),
        groupname: "flamepng"); // emissive)
    OPENWORLD.Texture.setMaterial(lampbronze,menorahflamemat!,groupname:"flamepng");

    laver = await OPENWORLD.Model.createModel(
        'assets/models/laver.glb', castshadow: true);
    addProgress();
    laver.scale.setValues(0.02, 0.02, 0.02);

    saltpile = await OPENWORLD.Model.createModel(
        'assets/models/saltpile.glb');
    addProgress();
    saltpile.scale.setValues(0.012, 0.012, 0.012);

    normalsalt = await THREE.TextureLoader()
         .fromAsset('assets/textures/normalsalt.jpg');
    addProgress();

    turban = await OPENWORLD.Model.createModel('assets/models/turban.glb');
    addProgress();
    turbanwield=turban.clone();
    turbanwield.scale.setValues(5.0, 5.0, 5.0);
    OPENWORLD.Space.setTurnPitchRoll(turbanwield, 90, -90, 0);

    OPENWORLD.Texture.setNormalMap(saltpile, normalsalt, normalScale: 2.0);

    firepan = await OPENWORLD.Model.createModel(
        'assets/models/firepan.glb');
    addProgress();
    OPENWORLD.Texture.setMaterial(firepan, silvermaterial!);
    OPENWORLD.BaseObject.setVisible(
        firepan, false, groupname: "ash");

    trumpet = await OPENWORLD.Model.createModel(
        'assets/models/trumpet.glb');
    addProgress();
    OPENWORLD.Texture.setMaterial(trumpet, silvermaterial!);

    donationchest = await OPENWORLD.Model.createModel(
        'assets/models/donationchest.glb');
    addProgress();
    OPENWORLD.Texture.setMaterial(donationchest, bronzemat!,groupname:"bronze");
    donationchest.scale.setValues(0.012, 0.012, 0.012);
    OPENWORLD.Mob.setName(donationchest,"donationchest");
    instancedDonationchest = InstancedModel.fromTemplate( donationchest, 15, threeJs.scene,name:'donationchest');
    instancedDonationchest.hideDistance=4.0;
    instancedModels.add(instancedDonationchest);

    money = await OPENWORLD.Model.createModel(
        'assets/models/money.glb');
    addProgress();
    money.scale.setValues(0.012, 0.012, 0.012);

    scales = await OPENWORLD.Model.createModel(
        'assets/models/scales.glb'); //,texture:"assets/detailmap.png");
    addProgress();
    scales.scale.setValues(0.007, 0.007, 0.007);
    OPENWORLD.Texture.setMaterial(scales, bronzemat!);

    dove=await OPENWORLD.Model.copyModel(pigeon,texture:"assets/models/dove.jpg");//pigeon.clone();
    addProgress();
    var dove2=dove.clone();
    dove2.position.x=-1.5;
    var dove3=dove.clone();
    dove3.position.x=1.5;

    birdcagedoves=birdcageorig.clone();//true);
    //  birdcagedove.scale.setValues(1.0,1.0,1.0);
    OPENWORLD.Mob.setInitTurn(dove2, OPENWORLD.Math.random()*360);
    OPENWORLD.Mob.setInitTurn(dove3, OPENWORLD.Math.random()*360);
    birdcagedoves.position.x=0.02;//-0.02;
    birdcagedoves.position.y=0.032;
    birdcagedoves.position.z=0.02;// forward back-0.04;
    birdcagedoves.add(dove2);
    birdcagedoves.add(dove3);

    birdcagepigeon=birdcageorig.clone();//true);
    //birdcagepigeon.scale.setValues(1.0,1.0,1.0);
    pigeon3=pigeon.clone();//await OPENWORLD.Model.copyModel(pigeon,texture:"assets/actors/dove.jpg");//pigeon.clone();
    birdcagepigeon.add(pigeon3);
    birdcagepigeon.position.x=-0.02;
    birdcagepigeon.position.y=0.032;
    birdcagepigeon.position.z=0.02;// forward back-0.04;
    OPENWORLD.Mob.setInitTurn(pigeon3, OPENWORLD.Math.random()*360);

    tablelow= await OPENWORLD.Model.createModel('assets/models/tablelow.glb');
    addProgress();
    tablelow.scale.setValues(0.017, 0.017, 0.017);
    instancedTablelow = InstancedModel.fromTemplate( tablelow,60, threeJs.scene,name:'tablelow');
    instancedTablelow.hideDistance=7.0;
    instancedModels.add(instancedTablelow);


    moneychest= await OPENWORLD.Model.createModel('assets/models/moneychest.glb');
    addProgress();
    OPENWORLD.Texture.setMaterial(moneychest, bronzemat!,groupname:"bronze");
    moneychest.scale.setValues(0.015, 0.015, 0.015);
    instancedMoneychest = InstancedModel.fromTemplate( moneychest,60, threeJs.scene,name:'moneychest');
    instancedMoneychest.hideDistance=7.0;
    instancedModels.add(instancedMoneychest);

    parchment= await OPENWORLD.Model.createModel('assets/models/parchment.glb');
    addProgress();
    parchment.scale.setValues(0.015, 0.015, 0.015);
    instancedParchment = InstancedModel.fromTemplate(parchment,100, threeJs.scene,name:'parchment');
    instancedParchment.hideDistance=7.0;
    instancedModels.add(instancedParchment);

    parchmentroll= await OPENWORLD.Model.createModel('assets/models/parchmentroll.glb');
    addProgress();
    parchmentroll.scale.setValues(0.015, 0.015, 0.015);
    instancedParchmentroll = InstancedModel.fromTemplate(parchmentroll,100, threeJs.scene,name:'parchmentroll');
    instancedParchmentroll.hideDistance=7.0;
    instancedModels.add(instancedParchmentroll);

    penreed= await OPENWORLD.Model.createModel('assets/models/penreed.glb');
    addProgress();
    penreed.scale.setValues(0.007, 0.007, 0.007);

    rope= await OPENWORLD.Model.createModel('assets/models/rope.glb');
    addProgress();
    rope.scale.setValues(0.007, 0.007, 0.007);

    stool= await OPENWORLD.Model.createModel('assets/models/stool.glb');
    addProgress();
    stool.scale.setValues(0.015, 0.015, 0.015);
    instancedStool = InstancedModel.fromTemplate( stool,60, threeJs.scene,name:'stool');
    instancedStool.hideDistance=7.0;
    instancedModels.add(instancedStool);

    tabletri = await OPENWORLD.Model.createModel(
        'assets/models/tabletri.glb');
    addProgress();
    tabletri.scale.setValues(0.018, 0.018, 0.018);

    torch = await OPENWORLD.Model.createModel(
        'assets/models/torch.glb');
    addProgress();
    torch.scale.setValues(5.0, 5.0, 5.0);
    OPENWORLD.Space.setTurnPitchRoll(torch, 90, -90, 0);

    knifewield = await OPENWORLD.Model.createModel(
        'assets/models/knife.glb');
    addProgress();
    //  OPENWORLD.Space.setTurnPitchRoll(horn.children[0], -90, 0, 0);
    OPENWORLD.Texture.setMaterial(
        knifewield, silvermaterial!, groupname: 'gold');
    knifewield.position.z = -3.0;
    OPENWORLD.Space.setTurnPitchRoll(knifewield, 0, 0, 180);

    herbshyssop = await OPENWORLD.Model.createModel(
        'assets/models/herbs/herbs.glb');
    herbshyssop.scale.setValues(0.006, 0.006, 0.006);
    // OPENWORLD.Space.objTurn(herbshyssop, 18);
    herbsmint = await OPENWORLD.Model.copyModel(
        herbshyssop, texture: "assets/models/herbs/mint.png");
    onions = await OPENWORLD.Model.copyModel(
        herbshyssop, texture: "assets/models/herbs/onions.png");

    childlist = [child12, child1];
    malelist=childlist.toList();
    manlist = [
      citizen2,
      citizen22,
      citizen23,
      citizen3,
      citizen32,
      citizen33,
      citizen34,
      citizen35 ,
      citizen36,
      citizen4,
      citizen42,
      citizen43,
      citizenoldman,
      citizenoldman2,
      citizenoldman22,
      priest3clothed
    ];
    for (var man in manlist)
      malelist.add(man);


    womanlist = [
      citizenoldwoman,
      citizenf22,
      citizenf2,
      citizenf3,
      citizenf32,
      citizenf33,
      citizenf34,
    ]; //,childgirl,childgirl2];

    adultlist=manlist.toList();
    for (var woman in womanlist)
      adultlist.add(woman);

    girllist = [childgirl2, childgirl];
    childrenlist=childlist.toList();
    for (var girl in girllist)
      childrenlist.add(girl);

    actorlist=girllist.toList();
    for (var woman in womanlist)
      actorlist.add(woman);
    for (var male in malelist)
      actorlist.add(male);

    soldierlist=[
      soldier2,
      soldier22,
      soldier23,
      soldier24
    ];

    var numwalkermodels = 20;
    walkerlist = [];
    for (var i = 0; i < numwalkermodels; i++)
      walkerlist.add(OPENWORLD.Math.randPick(actorlist, exclude: walkerlist));

    String response = await rootBundle.loadString('assets/rabbitexts.json');
    rabbitexts = await json.decode(response);

    response = await rootBundle.loadString('assets/rabbicourtwomen.json');
    rabbicourtwomen = await json.decode(response);

    response = await rootBundle.loadString('assets/travelsongs.json');
    travelsongs = await json.decode(response);

    response = await rootBundle.loadString('assets/chatsgeneral.json');
    chatsgeneral = await json.decode(response);

    await hotload(true);


      resetYou();



      // Set position from last time
    if (gamestart!=GameStart.none) {
      // If progress set then will be dealt with elsewhere

      var usedict=getusedict();

      var level;
      if (usedict.containsKey("l"))
        level=usedict['l'];
      else
        level=0;
      /* if (gamestartpos[gamestart]?.length==2) {
         level = 0;
       } else {
         level = gamestartpos[gamestart]![2];
       }*/
      OPENWORLD.You.level=level;
      var cameraoffset;
      if (usedict['p'].length>=3) //gamestart==GameStart.bethspage)
        cameraoffset=usedict['p'][2];//defaultcameraoffset/4;
      else
        cameraoffset=OPENWORLD.Camera.cameraoffset;
      // Map dict=gamestartpos[gamestart];

      OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera,    usedict['p'][0].toDouble(),usedict['p'][1].toDouble(),
          cameraoffset,level:level);// -25.51, 117.12, OPENWORLD.Camera.cameraoffset);  // womens gate start  -20.27, 92.24
      if (usedict.containsKey('t'))
        OPENWORLD.Camera.setTurn(usedict['t']);
    } else if (await OPENWORLD.Persistence.get("posx") != null) {
        // If position saved persistenly then put player to that position
        var x = await OPENWORLD.Persistence.get("posx");
        var y = await OPENWORLD.Persistence.get("posy");
        OPENWORLD.Space.worldToLocalSurfaceObj(
            threeJs.camera, x!, y!,
            OPENWORLD.Camera.cameraoffset); //home temple
         var turn = await OPENWORLD.Persistence.get("turn", def: 0);
             OPENWORLD.Camera.setTurn(turn);
          //OPENWORLD.Camera.setTurn(180);

        //}
      } else {
        print("Using default position");
        OPENWORLD.Space.worldToLocalSurfaceObj(
            threeJs.camera, -14.67, 65.47, // -26.05, 65.40,
            OPENWORLD.Camera.cameraoffset); //home temple

        OPENWORLD.Camera.setTurn(-90); //Space.objTurn(camera,-90);

        if (!kIsWeb) // Persistence doesnt work on web
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          //  userGuidanceController.show();
          });
      }

        var worldpos = OPENWORLD.You.getWorldPos();
        OPENWORLD.Config.showPoolsObjects(worldpos.x, worldpos.y);


    OPENWORLD.Config.showPoolsObjects(worldpos.x,worldpos.y);
    OPENWORLD.Actor.update(0.001);



    threeJs.addAnimationEvent((frameTime) async {
      /// print('uuu'+frameTime.toString()+" "+clock.getDelta().toString());;

      animate(frameTime);

    });
     animate(0.01,warmup:true);
     var warmuptime=3;
    for (var i=0; i<10*warmuptime; i++)
    Future.delayed(Duration(milliseconds: i*100), () async {
      animate(0.1,warmup:true);

    });
    Future.delayed(Duration(milliseconds: (warmuptime*1000).round()), () async {
      if (OPENWORLD.You.room==null) {
        OPENWORLD.BaseObject.reenableDistanceTrigger(roomTerrain);
        OPENWORLD.Room.update(0.1);  // Only haven't entered a room then allow them in roomTerrain

      }
      setState(() {
        OPENWORLD.System.loaded = true;
      });
    });

      threeJs.renderer?.sortObjects=true;


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

  // Redundant multiplayer code

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
        //!!! must fix
       // _globalKey.currentState?.pause = true;
      });
      var value = names[(OPENWORLD.Math.random() * names.length).floor()];
      //  FocusScope.of(context).unfocus();
      var name = await promptDialog(
          'Player Name', 'To play online enter your players name', value);


      setState(() {
        // loaded=true;
        // !!! must fix
        //_globalKey.currentState?.pause = false;
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
                action: "idle",
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
     /* Fluttertoast.showToast(
          msg: "You disconnected from the game",
          toastLength: Toast.LENGTH_LONG);*/
    }
    // }
    // Navigator.pop(context);
  }

  bool _threeDisposed = false;
  void _disposeThree() {
    if (_threeDisposed) return;
    _threeDisposed = true;
    threeJs.dispose();
    THREE.loading.clear();
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
    OPENWORLD.BaseObject.clearAllTimers();

    //if (horseridingcloploaded)
    //  horseridingclop.stop();
    if (OPENWORLD.System.loaded) {
      _timer.cancel();
      await disconnect();
      setState(() {
        OPENWORLD.System.loaded = false;
        //hasprayer = false;
        //inprayer = false;
       // priestblessing = false;
        //removed_horn = false;
        OPENWORLD.System.active = false;
      });
    }

    //threeJs.dispose();
    if (!kIsWeb && Platform.isIOS) _disposeThree();

    // A widget-tree-level rebuild (RestartWidget) was NOT enough to avoid
    // the WebGLRenderer crash on restart - the stale state survives at the
    // native ANGLE/GL context level, below Flutter's widget layer. So
    // instead of returning to the in-app menu, relaunch the whole process:
    // the next SecondTemplePage/ThreeJS created will be in a brand new
    // process with a fresh GL context, guaranteed not to collide with this
    // one's torn-down renderer state.
    await restartApplication(context);
  }

  // Once has connected to server change layout
  has_connected() {
    setState(() {
      prompttext = "";
    });
  }

  msg() async {
    // disable DomLikeListenable so can type
    //!! must fix
    //_globalKey.currentState?.pause = true;

    var msg = await chatDialog('Enter Message', '', '');

    // reenable DomLikeListenable so can use movement keyboard again
    //!! must fix
   // _globalKey.currentState?.pause = false;

    if (msg != null && msg != "") {
      CLIENT.You.msg.add(msg);
    }
  }


  var frames = 0;
  var frames10 = 0;
  //var lasttick=-1;
//  var prevhorseposx=-9999.0;
//  var prevhorseposy=-9999.0;
  var horseupdownspeed=1.0;
  var frameTimeFactor=1.0;
  //var pitchset=-9999.0;
  // var lastpitchset=-9999.0;
  var pitchdiff=-9999.0;
  var hasmovedhandler=null;
//  var inhitobstacle=false;
  var lastnothitx=-9999.0;
  var lastnothity=-9999.0;

  /// Times an OPENWORLD per-frame update call and prints it, when [showtime]
  /// is true. When false, this is just a direct call - no Stopwatch is
  /// allocated, so there's no overhead in normal play.
  void _timed(String label, bool showtime, void Function() fn) {
    if (!showtime) {
      fn();
      return;
    }
    final sw = Stopwatch()..start();
    fn();
    sw.stop();
    print('animate: ${label.padRight(20)} ${(sw.elapsedMicroseconds / 1000.0).toStringAsFixed(2)}ms');
  }

  animate(frameTime,{warmup=false})  {


    // log("animate2");
    final showtime =false; // flip to false to stop printing per-system frame timing

    if (!mounted ) {//|| disposed) {
      return;
    }

    if (!OPENWORLD.System.loaded&&!warmup) {
      return;
    }
    // log("animate3");

    frames++;
    frames10++;
    // var frameTime = clock.getDelta();


    //if (_space != null) {
    prevlocalx = threeJs.camera.position.x;
    prevlocaly = threeJs.camera.position.y;
    prevlocalz = threeJs.camera.position.z;


    _timed('water.updateReflections', showtime, () {
      for (var water in waterlist)
        if (water!=null&&water!.visible)
          water!.updateReflections(threeJs.renderer!, threeJs.scene, threeJs.camera);
    });

    if (mapshow) {
      // Get the map to display and maps pixel coordinates based on the world coordinates and show the marker where the player is
      // Shouldnt you do this every second?
      setState(() {
        var worldpos = OPENWORLD.You
            .getWorldPos(); //Space.localToWorldObj(camera);
        var map = OPENWORLD.Maps.getMapFromWorldcoords(worldpos.x, worldpos.y);
//        var map = OPENWORLD.Maps.getMapFromWorldcoords(12.0,58);//worldpos.x, worldpos.y);
        if (map != null) {
          mapx = map['imagepos'][0] / map['map'].width;
          mapy = map['imagepos'][1] / map['map'].height;
          print("map"+map.toString()+" "+mapx.toString()+" "+mapy.toString());

          //mapx=1.0;
          // mapy=1.0;
          mapfile = map['map'].filename;
          mapwidth = map['map'].width;
          mapheight = map['map'].height;
        } //else

      });
    }

    frameTime*=frameTimeFactor;  // this is to do a speed up of the game say if walking a long distance and is boring but this is redundant now
    // Where all the openworld updates are performed - every frame
    _timed('Actor.update', showtime, () => OPENWORLD.Actor.update(frameTime));

    //if (OPENWORLD.Math.random() < 0.1) {
    _timed('Mob.update', showtime, () => OPENWORLD.Mob.update(frameTime));
    //}
    //_smoke.update(frameTime);
    clock.getDelta();  // This is needed for the flames
    _timed('Updateables.update', showtime, () => OPENWORLD.Updateables.update(frameTime, clock.elapsedTime));

    var delta = frameTime;//clock.getDelta();
    var worldpos = OPENWORLD.You.getWorldPos();

    //print("del"+delta.toString());
    if (this._joystick != null) {

      this._joystick?.update(delta);

    }

    _timed('Space.update', showtime, () => OPENWORLD.Space.update(delta));
    _timed('Light.update', showtime, () => OPENWORLD.Light.update(delta)); // must be before space update otherwise night only will override hide
    _timed('BaseObject.update', showtime, () => OPENWORLD.BaseObject.update(delta));
    _timed('Texture.update', showtime, () => OPENWORLD.Texture.update(delta));

    if (gamestart==GameStart.hearth&&friendhearth.visible&&friendhearth.extra.containsKey('followhearth')&&friendhearth.extra['followhearth']) {

      var dist=OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, friendhearth);
      //  print("disttt"+dist.toString());
      var distfollow;
      if (OPENWORLD.You.indoors())
        distfollow=0.12;
      else if (OPENWORLD.You.room!=null&& OPENWORLD.You.room!.extra.containsKey('distfollow') )
        distfollow=OPENWORLD.You.room?.extra['distfollow'];
      else
        distfollow=0.18;
      //print('followhearth dist follow'+distfollow.toString()+" "+dist.toString());
      if (dist<1.0&&dist>distfollow) {//0.18) {
        var turn=OPENWORLD.Space.getObjTurn(friendhearth);
        // print("voot"+OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs().toString());
        if (OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs()<friendhearthanglediff) {
          //  print("vootlln");
          var friendpos = OPENWORLD.Space.localToWorldObj(friendhearth);
          var forwardpos=OPENWORLD.Math.vectorMoveForward(friendpos.x, friendpos.y, turn, 0.1);
          // If you are ahead of friend dont move forward
          if (OPENWORLD.Math.vectorDistance(friendpos,worldpos)<OPENWORLD.Math.vectorDistance(worldpos,OPENWORLD.Math.vector2tovector3(forwardpos))) {
            //   print("vooot"+(OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastmovetick).toString()+" "+(OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastturntick).toString());
            if (OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastmovetick>10000&&
                OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastturntick>10000&&
                !OPENWORLD.Space.objIsTurnLerp(threeJs.camera))
              OPENWORLD.Space.faceObjectLerp(threeJs.camera,friendhearth,1.0); //, time)
            var oldy=threeJs.camera.position.y;
            // var fct=0.18/distfollow; //if want close the make a bit faster when close up
            OPENWORLD.Space.objForwardSurface(threeJs.camera,
                - (horsespeed *dist)/// 8)
                    * frameTime * OPENWORLD.You.drag,
                OPENWORLD.Camera.cameraoffset,level:OPENWORLD.You.level);
            // Smooth any jumps
            threeJs.camera.position.y =
                threeJs.camera.position.y * 0.2 + oldy * 0.8;

          }//,normalize2world: true);

        }


      }


    } else if (gamestart==GameStart.lowercity&&dad.visible&&dad.extra.containsKey('followdad')&&dad.extra['followdad']) {
      // following dad to shops

      var dist=OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, dad);
      //  print("disttt"+dist.toString());
      if (dist<1.0&&dist>0.18) {
        var turn=OPENWORLD.Space.getObjTurn(dad);
        // print("voot"+OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs().toString());
        if (OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs()<120) {
          //  print("vootlln");
          var friendpos = OPENWORLD.Space.localToWorldObj(dad);
          var forwardpos=OPENWORLD.Math.vectorMoveForward(friendpos.x, friendpos.y, turn, 0.1);
          // If you are ahead of dad dont move forward
          if (OPENWORLD.Math.vectorDistance(friendpos,worldpos)<OPENWORLD.Math.vectorDistance(worldpos,OPENWORLD.Math.vector2tovector3(forwardpos))) {
            //   print("vooot"+(OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastmovetick).toString()+" "+(OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastturntick).toString());
            if (OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastmovetick>10000&&
                OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastturntick>10000&&
                !OPENWORLD.Space.objIsTurnLerp(threeJs.camera))
              OPENWORLD.Space.faceObjectLerp(threeJs.camera, dad,1.0); //, time)
            var oldy=threeJs.camera.position.y;
            OPENWORLD.Space.objForwardSurface(threeJs.camera,
                - (horsespeed *dist)/// 8)
                    * frameTime * OPENWORLD.You.drag,
                OPENWORLD.Camera.cameraoffset,level:OPENWORLD.You.level);
            // Smooth any jumps
            threeJs.camera.position.y =
                threeJs.camera.position.y * 0.2 + oldy * 0.8;

          }//,normalize2world: true);

        }


      }
      if (donkeypackbuckets.extra.containsKey('followdad')&&donkeypackbuckets.extra['followdad']) {
        var dist=OPENWORLD.Space.getDistanceBetweenObjs(donkeypackbuckets, dad);
        // print("disttt"+dist.toString());
        if (dist<1.0&&dist>0.07) {
          if (!OPENWORLD.Space.objIsTurnLerp(donkeypackbuckets))
            OPENWORLD.Space.faceObjectLerp(donkeypackbuckets, dad, 1.0);//,normalize2world: true);

          var oldy=donkeypackbuckets.position.y;
          var distforward= (horsespeed *dist)
              * frameTime * OPENWORLD.You.drag*2;
          OPENWORLD.Space.objForwardSurface(donkeypackbuckets, distforward, 0.0);//,normalize2world: true);

          //print("donkey forward"+distforward.toString()+" "+dist.toString());//((horsespeed / 8)
          //    * frameTime * OPENWORLD.You.drag).toString());
          // smooth the donkeys z position so doesn't jump on the steps
          donkeypackbuckets.position.y =
              donkeypackbuckets.position.y * 0.2 + oldy * 0.8;

        }

      }

    } else if (!horseriding&&  gamestart==GameStart.womensgate&&
        womensgategroup.length>0&&womensgategroup[0].extra.containsKey('followingfriend')&&Glob.hasstabled){
      // Case where get off near the bethesda stables and follow your friends but on foot
       //print("not horseriding but following friend womensgate");
      var tofollow=womensgategroup[womensgategroup[0].extra['followingfriend']];
      var dist=OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, tofollow);
      //  print("disttt"+dist.toString());
      if (dist<1.0&&dist>0.25) {
        var turn=OPENWORLD.Space.getObjTurn(tofollow);
        // print("voot"+OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs().toString());
        if (OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs()<120) {
          //  print("vootlln");
          var friendpos = OPENWORLD.Space.localToWorldObj(
              tofollow);
          var forwardpos=OPENWORLD.Math.vectorMoveForward(friendpos.x, friendpos.y, turn, 0.1);
          // If you are ahead of your friend dont move forward
          if (OPENWORLD.Math.vectorDistance(friendpos,worldpos)<OPENWORLD.Math.vectorDistance(worldpos,OPENWORLD.Math.vector2tovector3(forwardpos))) {
            // if (!OPENWORLD.Space.objIsTurnLerp(threeJs.camera))
            if (OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastmovetick>10000&&
                OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastturntick>10000&&
                !OPENWORLD.Space.objIsTurnLerp(threeJs.camera))
              OPENWORLD.Space.faceObjectLerp(threeJs.camera, tofollow,1.0); //, time)
            var speedinc=(dist-0.25)/40;
            //   print("speedinc"+speedinc.toString()+" "+horsespeed.toString());
            OPENWORLD.Space.objForwardSurface(threeJs.camera,
                - (horsespeed /2+speedinc)
                    * frameTime * OPENWORLD.You.drag,
                OPENWORLD.Camera.cameraoffset,level:OPENWORLD.You.level);
          }//,normalize2world: true);

        }
        //(citizenpathsouthfriend2
        //    var friendpos = OPENWORLD.Space.localToWorldObj(
        //    friendbethspagegroup);

      }
    } else if (!horseriding&& friendbethphagegroup!=null&&friendbethphagegroup!.extra.containsKey('followingfriend')&&friendbethphagegroup!.extra['followingfriend']&&
                  Glob.hasreachedsiloam) {
      // Case where get off near the water gate and follow your friend up
      // print("not horseriding but following friend bethspage");
      var tofollow;
      if (!friendbethphagegroup!.extra['friendold'].visible)
        // Means you are following the group that contains your friend and his donkey
        tofollow=friendbethphagegroup!;
      else
        // Means stable boy has taken the donkey and your friend is now seperated so follow your friend instead
        tofollow=friendbethphagegroup!.extra['friendold'];
      var dist=OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, tofollow);//friendbethphagegroup);
      //  print("disttt"+dist.toString());
      if (dist<1.0&&dist>0.2&&!friendbethphagegroup!.extra['friendwaiting']) {
        var turn=OPENWORLD.Space.getObjTurn(tofollow);//friendbethphagegroup);
        // print("voot"+OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs().toString());
        if (OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs()<90) {
          //  print("vootlln");
          var friendpos = OPENWORLD.Space.localToWorldObj(
              tofollow);//friendbethphagegroup);
          var forwardpos=OPENWORLD.Math.vectorMoveForward(friendpos.x, friendpos.y, turn, 0.1);
          // If you are ahead of your friend dont move forward
          if (OPENWORLD.Math.vectorDistance(friendpos,worldpos)<OPENWORLD.Math.vectorDistance(worldpos,OPENWORLD.Math.vector2tovector3(forwardpos))) {
            if (OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastmovetick>10000&&
                OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastturntick>10000&&
                !OPENWORLD.Space.objIsTurnLerp(threeJs.camera))
              //    if (!OPENWORLD.Space.objIsTurnLerp(threeJs.camera))
              OPENWORLD.Space.faceObjectLerp(threeJs.camera, tofollow,1.0); //, time)
            var oldy=threeJs.camera.position.y;
            OPENWORLD.Space.objForwardSurface(threeJs.camera,
                - (horsespeed /2)
                    * frameTime * OPENWORLD.You.drag,
                OPENWORLD.Camera.cameraoffset,level:OPENWORLD.You.level);
            threeJs.camera.position.y =
                threeJs.camera.position.y * 0.2 + oldy * 0.8;
          }//,normalize2world: true);

        }
        //(citizenpathsouthfriend2
        //    var friendpos = OPENWORLD.Space.localToWorldObj(
        //    friendbethphagegroup);

      } else if (dist>1&&friendbethphagegroup!.extra['friendold'].visible&&!friendbethphagegroup!.extra['friendwaiting']&&
          !(worldpos.y>-1.58&&worldpos.x<7)//5.96)// if at the tamid this you've already arrived
      ) {

        print("friend waiting stop friend");
        OPENWORLD.BaseObject.clearAll(
            tofollow); //childgirlii);  // so forgets previous movetoloop
        // !! why must I do this
        var friendpos = OPENWORLD.Space.localToWorldObj(tofollow);
        OPENWORLD.Space.worldToLocalSurfaceObj(
            tofollow,
            friendpos.x, //worldpos.x,
            friendpos.y, 0,level:OPENWORLD.You.level
        );

        //  OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['friend'],
        //      action: "sittableidle");
        OPENWORLD.Actor.playAction(
            tofollow,
            action: "idle");

        OPENWORLD.Space.faceObjectLerp(
            tofollow, threeJs.camera, 1.0,
            normalize2world: true);

        OPENWORLD.Mob.setSpeech(tofollow,
          ["Hey, we're nearly there.",
            "Lets go"], z: 80,
          width: 300,
          //  clearwhendone: true,
          minwait: 5,
          scale: 0.4,
          randwait: 0,
          //   delay:9
        );
        friendbethphagegroup!.extra['friendwaiting'] = true;

      }  else if  (dist<0.5&&friendbethphagegroup!.extra['friendold'].visible&&friendbethphagegroup!.extra['friendwaiting']) {
        print("restart folloow friend");

        friendbethphagegroup!.extra['friendwaiting']=false;
        Glob.donebathing!();

        OPENWORLD.Mob.clearText(friendbethphagegroup!.extra['friendold']);

      }

    } else  if (horseriding&&_horse.extra['riding']!=null) {//me!=null) {//&&ismoving) {
      // print("pitch"+OPENWORLD.Camera.pitch.toString());
      // Move the horse you are riding on up and down slightly
      OPENWORLD.Camera.cameraoffset = horsecameraoffset; // 0.15;

      var roll;
      if (ismoving) {
        horseupdownspeed+=OPENWORLD.Math.randFloatSpread(frameTime*4);
        // print('xxx'+frameTime.toString()+' '+horseupdownspeed.toString());
        if ( horseupdownspeed>1.5)
          horseupdownspeed=1.5;
        else if ( horseupdownspeed<0.5)
          horseupdownspeed=0.5;
        roll = horseupdownspeed * math.sin(clock.getElapsedTime() * 3 % (math.pi));
//          roll=0.35 * math.sin(clock.getElapsedTime() * 5 % (math.pi));
      } else
        roll=0;
      roll-=OPENWORLD.Camera.pitch;
      var pitch=1.0 * math.sin(clock.getElapsedTime() * 1 % (math.pi));
      var turn=2.0 * math.sin(clock.getElapsedTime() * 0.5 % (math.pi));

      //print("in horse riding"+clock.getElapsedTime().toString()+" "+turn.toString()+" "+pitch.toString()+" "+roll.toString());
      //                                                                    pitch
      OPENWORLD.Space.setTurnPitchRoll(_horse.extra['riding'], turn,pitch, roll);//0.35 * math.sin(clock.getElapsedTime() * 5 % (math.pi)));// -OPENWORLD.Camera.pitch);
      //print("drag"+OPENWORLD.You.drag.toString());
      if (pitchdiff==-9999.0||OPENWORLD.Camera.pitchset!=-9999.0) {//double.nan) {
        //..print("set ptichdiff"+pitchdiff.toString()+" "+OPENWORLD.Camera.pitchset.toString());
        var pitchcamera=OPENWORLD.Space.getTerrainPitch(threeJs.camera);
        pitchdiff=OPENWORLD.Math.angleDifference(OPENWORLD.Camera.pitch,pitchcamera);
        OPENWORLD.Camera.pitchset=-9999.0;
      }

      var speedinc=0.0;
      // womensgate journey riding a donkey
      if (gamestart==GameStart.womensgate&&horseriding&&_horse.extra['riding']!=null) {

        var closestfriend=null;
        var closestdist=99999.0;
        for (var i=0; i< womensgategroup.length-1; i++) {//pos in citizenpathsouth) {
          //  for (var i=0; i< womensgategroup.length-1; i++) {//pos in citizenpathsouth) {
          var pos= OPENWORLD.Space.localToWorldObj(womensgategroup[i]);
          var dist=OPENWORLD.Math.vectorDistance(worldpos, THREE.Vector3(pos[0],pos[1],0.0));

          if (dist<closestdist) {
            closestdist = dist;
            closestfriend =  womensgategroup[i];
          }

        }
        // print('rrrrrr'+closestdist.toString());


        //  var dist=OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, closestfriend);
        //  print("disttt"+dist.toString());
        if (closestdist<1.5) {//&&closestdist>0.3) {//18) {//18) {

          speedinc=(closestdist>0.4)?closestdist/20:-(0.4-closestdist)/20;
          var turn=OPENWORLD.Space.getObjTurn(closestfriend);//friendbethphagegroup);
          //  print("voot"+speedinc.toString());//OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs().toString());
          if (OPENWORLD.Math.angleDifference(turn, OPENWORLD.Camera.turn).abs()<120) {
            //  print("vootlln");
            var friendpos = OPENWORLD.Space.localToWorldObj(closestfriend);
            var forwardpos=OPENWORLD.Math.vectorMoveForward(friendpos.x, friendpos.y, turn, 0.1);
            // If you are ahead of dad dont move forward
            if (OPENWORLD.Math.vectorDistance(friendpos,worldpos)<OPENWORLD.Math.vectorDistance(worldpos,OPENWORLD.Math.vector2tovector3(forwardpos))) {
              //   print("vooot"+(OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastmovetick).toString()+" "+(OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastturntick).toString());
              if (OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastmovetick>10000&&
                  OPENWORLD.System.currentMilliseconds()-OPENWORLD.Keyboard.lastturntick>10000&&
                  !OPENWORLD.Space.objIsTurnLerp(threeJs.camera))
                OPENWORLD.Space.faceObjectLerp(threeJs.camera, closestfriend,1.0); //, time)

            }//,normalize2world: true);

          }

        }


        // bethspage journey riding donkey and following your friend
      }  else if (gamestart==GameStart.bethphage&&friendbethphagegroup!=null&&friendbethphagegroup!.extra.containsKey('followingfriend')&&friendbethphagegroup!.extra['followingfriend']) {
        var friendpos = OPENWORLD.Space.localToWorldObj(
            friendbethphagegroup!);
        var dist=OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, friendbethphagegroup);
        // print("disttt"+dist.toString());
        // bethspage journey riding donkey and following your friend and your friend is waiting
        if (friendbethphagegroup!.extra['friendwaiting']&&dist<0.5) {
          // Restart the horse if your friend is waiting - here you find the positions in the path that are closest to where you are
          print("restart horse");
          OPENWORLD.Mob.pauseSpeech(friendbethphagegroup!.extra['friend']);
          OPENWORLD.Mob.clearText(friendbethphagegroup!.extra['friend']);
          List<Map> positions = Glob.getCurrentPathSouthFriend!();
          OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['frienddonkey'], action: "walk");

          OPENWORLD.Mob.clearText(friendbethphagegroup);
          //print("positions" + positions.toString());

          // This is for friend waiting
          OPENWORLD.Mob.moveToLoop(friendbethphagegroup,
              positions,
              // hidedist:0,
              lerpopacity: 1.0,
              surfaceonly: true,
              normalize2world: true,
              looptype: OPENWORLD.Mob.LoopTypeStop
            // facedir: true,
            //  duration:1.0,
            //facenow: true,
            ///randomduration: 0.1,
            //  reverseloop:true,
            //action: "walk" //straight"
          );
          friendbethphagegroup!.extra['friendwaiting']=false;
          //bethspage journey riding donkey and following your friend and your friend isn't waiting
        } else if (dist<1&&!friendbethphagegroup!.extra['friendwaiting']) {
          //  print("firned  chat");
          //  friendbethphagegroup!.extra['friendwaiting']=false;

          var friendposturn = OPENWORLD.Space.getObjTurn(
              friendbethphagegroup);
          // In order to talk to your friend idealpos is where you should be
          THREE.Vector2 idealpos = OPENWORLD.Math.vectorMoveForward(
              friendpos.x, friendpos.y, friendposturn - 180,
              0.2);//15); // right behind your friend
          // idealpos=OPENWORLD.Math.vectorMoveForward(idealpos.x, idealpos.y, friendposturn-180-90, 0.1);  // right behind your friend offset 0.1
          var distideal = OPENWORLD.Math.vectorDistance(worldpos, THREE.Vector3(idealpos.x,idealpos.y,0.0));
          var distfriend = OPENWORLD.Math.vectorDistance(worldpos, friendpos);
//          var distideal = OPENWORLD.Math.vectorDistance3(threeJs.camera.position, THREE.Vector3(idealpos.x,idealpos.y,0.0));
          var angletoideal=OPENWORLD.Math.getAngleBetweenPoints(worldpos, idealpos);
          var anglediff=OPENWORLD.Math.angleDifference(OPENWORLD.Camera.turn, angletoideal);
          // If you are pointing towards the idealpos then speed up to get to that spot
          if (anglediff.abs()<100&&distfriend>distideal) {
            speedinc+=distideal/50;

          } else if (anglediff.abs()>100||distfriend<distideal)  // If you ahead or to the side the slow down a bit
            speedinc-=distideal/10;

          //  if (!friendbethphagegroup!.extra['friendwaiting']) {
          // If you are to the left of your friend have your friend angle his head to his left and vice versa
          var angletofriend = OPENWORLD.Math.getAngleBetweenPoints(
              worldpos, friendpos);
          var friendanglediff = OPENWORLD.Math.angleDifference(
              OPENWORLD.Camera.turn, angletofriend); //friendposturn);
          //print("friend angle"+friendanglediff.toString()+" "+friendbethphagegroup!.extra['friendaction']+" "+OPENWORLD.Camera.turn.toString()+" "+OPENWORLD.Math.standardAngle(friendposturn).toString()+" "+ angletofriend.toString());
          if (friendanglediff > 0 &&
              friendbethphagegroup!.extra['friendaction'] == "sittableleft") {
            OPENWORLD.Actor.playAction(
                friendbethphagegroup!.extra['friend'],
                action: "sittableright", duration: 1.2);
            friendbethphagegroup!.extra['friendaction'] = "sittableright";
            OPENWORLD.Space.objTurnLerp(friendbethphagegroup!.extra['friend'], 15-180, 1);
          } else if (friendanglediff < 0 &&
              friendbethphagegroup!.extra['friendaction'] ==
                  "sittableright") {
            OPENWORLD.Actor.playAction(
                friendbethphagegroup!.extra['friend'], action: "sittableleft",
                duration: 1.2);
            friendbethphagegroup!.extra['friendaction'] = "sittableleft";
            OPENWORLD.Space.objTurnLerp(friendbethphagegroup!.extra['friend'], -15-180, 1);
          }
          //  }

          Glob.nextfriendtick!(anglediff);
          //  print("anglediff"+OPENWORLD.Math.standardAngleSigned(anglediff).toString()+" "+ OPENWORLD.Math.standardAngle(angletoideal).toString()+" "+distideal.toString()+" "+distfriend.toString()+" "+OPENWORLD.Math.standardAngle(friendposturn).toString()+" "+speedinc.toString());
          // if (distideal < dist) {
          //
          //}
        } else {
          // print("friend waiting");
          if (!friendbethphagegroup!.extra['friendwaiting']) {
            print("friend waiting stop friend");
            OPENWORLD.BaseObject.clearAll(
                friendbethphagegroup!); //childgirlii);  // so forgets previous movetoloop
            // !! why must I do this
            OPENWORLD.Space.worldToLocalSurfaceObj(
                friendbethphagegroup!,
                friendpos.x, //worldpos.x,
                friendpos.y, // worldpos.y + 0.52,
                -0.002);

            //  OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['friend'],
            //      action: "sittableidle");
            OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['frienddonkey'], action: "idle");
            OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['frienddonkey'], action: "idle", delay:1);
            OPENWORLD.Actor.playAction(
                friendbethphagegroup!.extra['friend'], action: "sittableidle",
                duration: 1.2,delay:2);
            OPENWORLD.Space.faceObjectLerp(
                friendbethphagegroup!, threeJs.camera,1.0,normalize2world: true);
            //OPENWORLD.Space.faceObjectAlways(
            //    friendbethphagegroup!, threeJs.camera,normalize2world: true);
            //  OPENWORLD.Space.faceObjectAlways(
            //    friendbethphagegroup!.extra['friend'], threeJs.camera);//,normalize2world: true);

            //OPENWORLD.Time.setTimeLerp(10, 60);
            OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friend'],
              ["Hey, still coming?",
                "You need a rest?"], z: 80,
              width: 300,
              //  clearwhendone: true,
              minwait: 5,
              scale: 0.4,
              randwait: 0,
              //   delay:9
            );
            friendbethphagegroup!.extra['friendwaiting']=true;
          }

        }


        //OPENWORLD.Space.objForwardLerp(object, moveamt, time)
        // print("dist to frind"+dist.toString());

      }
      // !! This is what moves you forward when you are riding a horse
      var oldz=threeJs.camera.position.y;
      OPENWORLD.Space.objForwardSurface(threeJs.camera, -(horsespeed/2+speedinc)*frameTime*OPENWORLD.You.drag,OPENWORLD.Camera.cameraoffset);//,normalize2world: true);
      threeJs.camera.position.y=threeJs.camera.position.y*0.1+oldz*0.9;
//      OPENWORLD.Space.objForwardSurface(threeJs.camera, -(horsespeed/2)*frameTime*OPENWORLD.You.drag,OPENWORLD.Camera.cameraoffset);//,normalize2world: true);
      var pitchcamera=OPENWORLD.Space.getTerrainPitch(threeJs.camera);
      //OPENWORLD.Camera.setPitch(pitchcamera+pitchdiff);
      OPENWORLD.Camera.setPitch(OPENWORLD.Camera.pitch*0.9+0.1*(pitchcamera+pitchdiff));
      // print("pitch camera"+pitchcamera.toString()+" "+OPENWORLD.Camera.pitch.toString());
      //  OPENWORLD.Camera.setPitch(
      //   /*-OPENWORLD.Camera.pitch+ */   0.35 * math.sin(clock.getElapsedTime() * 5 % (math.pi)));
    } else {
      // This doesn't work - in pool of siloam pitch is wrong direction
      /* if (pitchdiff==-9999.0||OPENWORLD.Camera.pitchset!=-9999.0) {//double.nan) {
        //..print("set ptichdiff"+pitchdiff.toString()+" "+OPENWORLD.Camera.pitchset.toString());
        var pitchcamera=-OPENWORLD.Space.getTerrainPitch(threeJs.camera,level:OPENWORLD.You.level);
        pitchdiff=OPENWORLD.Math.angleDifference(OPENWORLD.Camera.pitch,pitchcamera);
        OPENWORLD.Camera.pitchset=-9999.0;
      }
      var pitchcamera=-OPENWORLD.Space.getTerrainPitch(threeJs.camera,level:OPENWORLD.You.level);
      if (pitchcamera.abs()<10)
        pitchcamera=0.0;

      //OPENWORLD.Camera.setPitch(pitchcamera+pitchdiff);

      //if ((pitchcamera-OPENWORLD.Camera.pitch).abs()>10)
        OPENWORLD.Camera.setPitch(OPENWORLD.Camera.pitch*0.9+0.1*(pitchcamera+pitchdiff));*/

    }
    // shouldn't OPENWORLD.Mob.isInMoveTo(womensgategroup[0]) always be true? here
                                                      // use isInsurfacelerp in cases when they've stopped so positions dont go out of sync
    if (gamestart==GameStart.womensgate&&OPENWORLD.Space.isInSurfaceLerp(womensgategroup[0])&&(//)OPENWORLD.Mob.isInMoveTo(womensgategroup[0])&&(
        (horseriding&&_horse.extra['riding']!=null)||
            (womensgategroup.length>0&&womensgategroup[0].extra.containsKey('followingfriend')/*&&OPENWORLD.Mob.isInMoveTo(womensgategroup[0])*/))&&
        !(worldpos.y<34&&worldpos.y>30.5&&worldpos.x<-25.4&&worldpos.x>-28.4)  // not a very nice fudge so stop the ridiculous avoidance at fishgate
    ){
      // Stop ridiculous look where friends walk through npcs coming the other way
      for (var top in citizengroups) {
        if (top.visible) {
          for (var friend in womensgategroup) {
            if (friend.visible) {
              var dist = OPENWORLD.Space.getDistanceBetweenObjs(top, friend);
              var thresh=0.15;
              if ((dist < thresh&&!friend.extra.containsKey('movetimer'))||(friend.extra.containsKey('movetimer')&&friend.extra['movetop']==top)) {//&&!top.extra.containsKey('ismoving')) {//fading')) {
//                if (dist < 0.1&&(!friend.extra.containsKey('movedist')||friend.extra['movedist']<0.05)) {//&&!top.extra.containsKey('ismoving')) {//fading')) {
                // If your friends are about to hit someone then move them
                if (!friend.extra.containsKey('movetimer')) {
                  friend.extra['movedist']=0.0;
                  friend.extra['movetop']=top;
                  var t = Timer.periodic(const Duration(seconds: 1), (t) {
                    if (!friend.extra['movetop'].visible)
                      print("NOTTTT visible");
                    var dist = OPENWORLD.Space.getDistanceBetweenObjs(friend.extra['movetop'], friend);
                    if (dist>=thresh&&friend.extra['movedist']==0.0) {//<0.005) {//thresh/20) {
                      print("jolt back iii" + friend.extra['movedist'].toString());
                     // friend.extra['movedist'] = 0.0;
                      friend.extra.remove('movetimer');
                      friend.extra.remove('moveleft');
                      t.cancel();
                    }

                  });

                  friend.extra['movetimer']=t;
                }
                //  top.extra['ismoving']=true;//fading']=true;
                //   OPENWORLD.Texture.opacityLerp(top, 0.0, 1.0);
                //  OPENWORLD.Texture.opacityLerp(top, 1.0, 1.0,delay:1.0);


                var friendpos = OPENWORLD.Space.localToWorldObj(friend);
                var worldpostop = OPENWORLD.Space.localToWorldObj(friend.extra['movetop']);//top);
                // Check if the object is behind you, if so ignore
                //var ang=OPENWORLD.Space.getAngleBetweensObjs(worldpos, worldpostop);//threeJs.camera, top);
             //   var ang = OPENWORLD.Space.getAngleBetweensObjs(friend, top);
                var friendangle=OPENWORLD.Space.getObjTurn(friend);
              //  var angdiff = OPENWORLD.Math.standardAngleSigned(
              //      OPENWORLD.Math.angleDifference(
              //          ang, friendangle)).abs();
                //  if (angdiff < 50) {
               // var topangle = OPENWORLD.Space.getObjTurn(top);
                // If close move away
                // friend.extra['movedist'] is how far you are way from your position you'd be otherwise
                var movedist;
                if (dist<thresh) {
                  // Stop the issue where when you stop and your friends all stop, they bounce around if citizen path walker walks through them
                  if (OPENWORLD.You.getObjDistance(friend)<1.2)
                    movedist = friend.extra['movedist'] + frameTime * 0.02; //0.001;
                  else
                    movedist = friend.extra['movedist'];
                }else
                  movedist=  friend.extra['movedist']-frameTime*0.01;//0.001;
                if (movedist<0) {
                  movedist = 0.0;
                 // friend.extra.remove('movetimer');
                //  friend.extra.remove('moveleft');
                }else if (movedist>thresh)
                  movedist=thresh;

                //  if you are more to the left left then move to left rather than right
                var avoidposleft = OPENWORLD.Math.vectorMoveForward3(
                    friendpos.x, friendpos.y,friendangle-90,// 90,//topangle - 90,
                    movedist);// 0.05); // 0.15/2);
                //var avoidposleft = OPENWORLD.Math.vectorMoveForward3(
                //     worldpostop.x, worldpostop.y, topangle - 90,
                //    movedist);// 0.05); // 0.15/2);
                var avoidposright = OPENWORLD.Math.vectorMoveForward3(
                    friendpos.x, friendpos.y,friendangle+90, // -90,//topangle - 90,
                    //  worldpostop.x, worldpostop.y, topangle + 90,
                    movedist);// 0.05); // 0.15/2);
                friend.extra['movedist']=movedist;
                var avoidpos;
                if (!friend.extra.containsKey('moveleft')) {
                  if (OPENWORLD.Math.vectorDistance(
                      worldpostop, avoidposleft) >
                      OPENWORLD.Math.vectorDistance(
                          worldpostop, avoidposright)) {
                    avoidpos = avoidposleft;
                    friend.extra['moveleft']=true;
                  } else {
                    avoidpos = avoidposright;
                    friend.extra['moveleft']=false;
                  }
                } else {
                  if (friend.extra['moveleft'])
                    avoidpos=avoidposleft;
                  else
                    avoidpos=avoidposright;
                }


                //   OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera, avoidpos.x, avoidpos.y,OPENWORLD.Camera.cameraoffset);
                OPENWORLD.Space.worldToLocalSurfaceObj(
                    friend, avoidpos.x, avoidpos.y, 0);
                // OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                //     friend, avoidpos.x, avoidpos.y, 0, 0.8);
               // print("friend hit"+angdiff.toString()+" "+avoidpos.toString()+" "+friendpos.toString()+" "+movedist.toString());//topangle.toString());
                //  }

              }// else if (friend.extra['movedist']!=0.0) {
                // So dont jolt into correct position
               // OPENWORLD.Space.worldToLocalSurfaceObj(
               //     friend, avoidpos.x, avoidpos.y, 0);

              //}
            }
          }
        }
      }

    }

    // var wallhit=false;

    // this is true when you hit a key or move joystick
    if (prevlocalx != threeJs.camera.position.x || prevlocalz != threeJs.camera.position.z) {
      if (hasmovedhandler!=null) {
        print("had moved handler");
        hasmovedhandler();
        hasmovedhandler=null;
      }

      /*if (OPENWORLD.You.drag<1)
          OPENWORLD.You.drag*=1.1;
        else if (OPENWORLD.You.drag>1)
          OPENWORLD.You.drag=1;*/

      var intersectmob=false;
      for (var actor in OPENWORLD.Actor.actorlist) {
        if (!intersectmob&&actor.visible&&actor.parent!=null&&
            !(actor.extra.containsKey('cancollide')&&actor.extra['cancollide'])&&(actor.position.y-threeJs.camera.position.y).abs()<0.1) {//!actor.extra['path'].contains("chicken")) {
          //var level=OPENWORLD.Space.getObjLevel(actor);  // The level can change so cannot just keep a copy of it
          // print("actor level"+level.toString()+ " "+OPENWORLD.BaseObject.getName(actor));
          //  if (level==OPENWORLD.You.level) {
          var pos = OPENWORLD.Space.localToWorldObj(actor);
          var angle=OPENWORLD.Math.getAngleBetweenPoints(worldpos,pos);
          // Only if looking in direction of actor do you stop collision  //OPENWORLD.Camera.turn
          var newworldpos=OPENWORLD.You.getWorldPos();
          var prevworldpos=OPENWORLD.Space.localToWorld(prevlocalx,prevlocaly,prevlocalz);
          var anglemove=OPENWORLD.Math.getAngleBetweenPoints(prevworldpos,newworldpos);
          // print("anglemove"+anglemove.toString()+" "+prevworldpos.toString()+" "+newworldpos.toString());

          //  var anglemove=OPENWORLD.Math.getAngleBetweenPoints(worldpos, forwardworldpos);
          //var diff=OPENWORLD.Math.angleDifference(angle,OPENWORLD.You.getMoveDir()).abs();
          var diff=OPENWORLD.Math.angleDifference(angle,anglemove).abs();
          if (diff<50) {
            // var prevworldpos=OPENWORLD.Space.localToWorld(prevlocalx,prevlocaly,prevlocalz);
            // var anglemove=OPENWORLD.Math.getAngleBetweenPoints(prevworldpos,worldpos);
            //  print("llll"+OPENWORLD.You.getMoveDir().toString());//anglemove.toString()+" "+prevworldpos.toString()+" "+worldpos.toString());
            // OPENWORLD.Camera.turn
            var forwardworldpos = OPENWORLD.Math.vectorMoveForward(
                worldpos.x, worldpos.y, anglemove,0.04);//OPENWORLD.You.getMoveDir(), 0.04);
            var dist;
            if (horseriding && _horse.extra['riding'] != null)
              dist = 0.10 / 2; //0.12;
            else
              dist = 0.07 / 2;

            intersectmob = OPENWORLD.Math.vectorDistance(
                pos,
                THREE.Vector3(forwardworldpos.x, forwardworldpos.y, 0.0)) <
                dist;
//          intersectmob=OPENWORLD.Math.vectorDistance(pos, worldpos)<dist;
            if (intersectmob) {
              // var origpos=actor.position.clone();
              // OPENWORLD.Space.objForwardLerp(actor, 0.0, 0.1,offset:0.1);
              //  OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(actor, pos.x,pos.y, 0.0,0.1,delay:1.0);
              //  print("intersect mob"+OPENWORLD.Mob.getName(actor));
              // Stop the situation where you're stuck inside a mob item and can't move
              intersectmob = OPENWORLD.Math.vectorDistance(
                  pos, THREE.Vector3(prevlocalx, -prevlocalz, 0)) <
                  dist; //0.07;
              if (!intersectmob) {
                print(
                    "actor intersect" + OPENWORLD.BaseObject.getName(actor) +
                        " " + worldpos.z.toString() + " " + pos.z.toString()+" diff"+diff.toString()+' dist'+dist.toString()+" movedir"+OPENWORLD.You.getMoveDir().toString());//+' anglemove'+anglemove.toString());

                if (actor.extra.containsKey('hittrigger'))
                  actor.extra['hittrigger'](actor);
                threeJs.camera.position.x = prevlocalx;
                threeJs.camera.position.z = prevlocalz;
              }
            }
          } else {

          }
          //}
        }
      }

      //  if (!inhitobstacle) {
      var hits = OPENWORLD.Obstacles.getHits(worldpos.x, worldpos.y);
      if (hits.length > 0) {

        OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera,  lastnothitx, lastnothity,OPENWORLD.Camera.cameraoffset,level:OPENWORLD.You.level);
        hits[0].executeCallback();

      } else {
        lastnothitx=worldpos.x;
        lastnothity=worldpos.y;
      }

      // Wall detection - if hit wall put player back to where they were
      // calculate objects intersecting the picking ray
      var offsetz;
      if (worldpos.y>80&&horseriding&&_horse.extra['riding']!=null) {
        offsetz = 0.2;
        //   print("horse wall offsetz");

      } else
        offsetz=OPENWORLD.Space.wallintersectoffsetz;
      //offsetz=0.013;
      var distintersect;
      _timed('Space.distanceWall', showtime, () {
        distintersect = OPENWORLD.Space.distanceWall(
            prevlocalx, prevlocaly, prevlocalz, offsetz: offsetz);
      });
      //print("interesect wall"+distintersect.toString());
      //  if (distintersect >= 0) {
      var disthit;
      if (OPENWORLD.You.speed>0.5)
        disthit=0.1;
      else if (OPENWORLD.You.indoors())
        disthit=0.02;
      else
        disthit=0.04;

      if (horseriding&&_horse.extra['riding']!=null) {
        var prevworldpos=OPENWORLD.Space.localToWorld(prevlocalx,prevlocaly,prevlocalz);
        var anglehit=OPENWORLD.Math.getAngleBetweenPoints(prevworldpos,worldpos);
        var anglediff=OPENWORLD.Math.angleDifference(anglehit, OPENWORLD.Camera.turn);
        // print("anglell"+OPENWORLD.Math.getAngleBetweenPoints(prevworldpos,worldpos).toString());//THREE.Vector3(prevlocalx,prevlocaly,prevlocalz) ,threeJs.camera.position).toString());
        if (anglediff < 90)
          disthit = 0.16; // if on horse dont want horse head going into wall
      }

      //if (distintersect>0)
      //  print("has hit wall"+distintersect.toString());
      var dostop = distintersect >= 0 && distintersect < disthit;//0.1;//0.3  ;
      if (dostop) {
        print("wall intersect");
        threeJs.camera.position.x = prevlocalx;
        threeJs.camera.position.z = prevlocalz;
        //  wallhit=true;
      } else {

      }
      //  }/* else if (disposed == -2) {
      // what is this for?
      // prevlocalx = -1;
      // }*/

      // Increase speed if riding a horse
      var usespeed;
      if (horseriding)
        usespeed = horsespeed;
      else if (OPENWORLD.You.indoors()) {
        if (OPENWORLD.Room.getRoomSpeed(OPENWORLD.You.room)!=null) {
          // print("indoor speed"+OPENWORLD.Room.getRoomSpeed(OPENWORLD.You.room).toString());
          usespeed = OPENWORLD.Room.getRoomSpeed(OPENWORLD.You.room);
        } else
          usespeed = indoorspeed;
        // print("is indoors");
      } else
        usespeed = defaultspeed;
      OPENWORLD.You.speed = usespeed;

      // Show pool objects based upon current camera position
      OPENWORLD.Config.showPoolsObjects(worldpos.x, worldpos.y);


      if (horseriding) {
        // var horseposx=-9999.0;
        // var horseposy=-9999.0;
        if (OPENWORLD.You.indoors()) {
          // Get off the horse because indoors
          print("exit horse");
          dismount();

        } else {

        }
      } // else
      _timed('You.update', showtime, () => OPENWORLD.You.update()); // To get move dir


    }


    _timed('Portals.update', showtime, () => OPENWORLD.Portals.update());

    // render();
    //if (_osound != null)
    _timed('Sound.update', showtime, () => OPENWORLD.Sound.update());

    if (OPENWORLD.Math.random() < 0.1)
      _timed('Musics.update', showtime, () => OPENWORLD.Musics.update()); // dont need to do it very often

    _timed('Time.update', showtime, () => OPENWORLD.Time.update(frameTime));

    _timed('Weather.update', showtime, () => OPENWORLD.Weather.update(frameTime));

    _timed('Room.update', showtime, () => OPENWORLD.Room.update(frameTime));

    /* if (horseriding && ismoving) {
      // Up and down when ride horse
      OPENWORLD.Camera.setPitch(
          0.35 * math.sin(clock.getElapsedTime() * 5 % (math.pi)));
    }*/

    if (creek!=null&&creek!.visible)
      creek!.material?.map?.offset.y += frameTime * 0.03; // 0.001;

    if (olivetree!=null)//&&olivetree.visible)
      Tree.updateWind(frameTime);

    // Flicker the minorah candles
    if (menorahflamemat!=null) { //&&menorah!=null&&menorah!.visible) {

      menorahflamemat?.map?.offset.x+=OPENWORLD.Math.randFloatSpread(0.4)*frameTime;// += frameTime * 0.03; // 0.001;
      var x=menorahflamemat?.map?.offset.x;
      if (x!>0.1)
        menorahflamemat?.map?.offset.x=0.1;
      else if (x<-0.1)
        menorahflamemat?.map?.offset.x=-0.1;
      var y=menorahflamemat?.map?.offset.y;
      menorahflamemat?.map?.offset.y+=OPENWORLD.Math.randFloatSpread(0.2)*frameTime;// += frameTime * 0.03; // 0.001;
      if (y!>0.1)
        menorahflamemat?.map?.offset.y=0.1;
      else if (y<-0.1)
        menorahflamemat?.map?.offset.y=-0.1;
      // print("menorah");
    } //else if (menorahflamemat==null)
    // print("menorh null");


    if (!(!_isBlending || _blendStartTime == null)) {
      final elapsed = DateTime.now().difference(_blendStartTime!);
      final progress = elapsed.inMilliseconds / _blendDuration.inMilliseconds;
      OPENWORLD.Space.forcecheckhide=true;
      print("progresss"+progress.toString());
      setState(() {
        if (progress >= 1.0) {
          _blendOpacity = 0.0;
          _isBlending = false;
          _showOverlay = false;

        } else {
          _blendOpacity = 1.0 - progress;
        }

      });
    }
  }



  var lastconnection = -1;
  var doneinterval = true;
  //var pitchset=-9999.0;
  // called every second
  clientInterval() async
  {
    // So that if in background dont keep doing interval
    if (OPENWORLD.System.appstate != AppLifecycleState.resumed || !doneinterval)
      return;

    doneinterval = false;
    var pos = OPENWORLD.Space.localToWorldObj(threeJs.camera);
    //OPENWORLD.Camera.turn
    print("pos: " + pos.x.toStringAsFixed(2) + ", " + pos.y.toStringAsFixed(2) +
        ", t" + OPENWORLD.Camera.turn.toStringAsFixed(
        2)+" "+OPENWORLD.Camera.pitch.toString()+", pitch"+OPENWORLD.Space.getTerrainPitch(threeJs.camera).toStringAsFixed(
        2)+", "+OPENWORLD.You.level.toString());//+' '+OPENWORLD.You.speed.toString());//+); //+" shofar"+_shofar.toString());

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
          "turn": OPENWORLD.Space.getObjTurn(threeJs.camera).toString(),
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
        OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera, ret["player_pos"][0],
            ret["player_pos"][1], OPENWORLD.Camera.cameraoffset);
      }
      if (ret.containsKey('num_players')) {
        num_players = ret["num_players"];
      }


      // Only show max_message message
      msgs.addAll(ret["msg"]);
      if (msgs.length > max_message) {
       // msgs.splice(0, msgs.length - max_message - 1);
        msgs.removeRange(0, msgs.length - max_message - 1);
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
          threeJs.scene.remove(players[i].actor); //mixer.getRoot());
          players_removed.add(players[i]);
          players.removeAt(i);;//splice(i, 1);
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

            players_removed.removeAt(0);//splice(0, 1);
          } else {
            //alert('clone');
            var _has_name;
            var player_model;
            if ((players.length) % 3 == 0) {
              print("citizen model iii" + citizen2.toString());

              player_model =
              await OPENWORLD.Actor.copyActor(citizen2); //.clone();

            } else if ((players.length) % 3 == 1) {
              print("citizen model ii" + citizen22.toString());
              player_model = await OPENWORLD.Actor.copyActor(citizen22);
                 // texture: "assets/actors/shofar/shofar2.jpg"); //clone();

            } else {
              print("citizen model  " + citizen23.toString());
              player_model = await OPENWORLD.Actor.copyActor(citizen23);//_shofar,
                  //texture: "assets/actors/shofar/shofar3.jpg"); //.clone();

            }
            player = CLIENT.Player(player_model); //THREE.AnimationMixer(player_model));
          }
          threeJs.scene.add(player?.actor); //mixer.getRoot());
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
                player.actor, action: "walk", duration: 1, stopallactions: true);

            // player.clipAction( player.getRoot().geometry.animations[4] ).play();
          } else if (dist < stopdist && player.isWalking) {
            print('is not walking');
            player.isWalking = false;
            await OPENWORLD.Actor.playAction(
                player.actor, action: "idle2", duration: 1, stopallactions: true);

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
  int nextcizitengroupheartbeat=0;
  int nextcizitenessengroupheartbeat=0;
  int nextcizitenwomengroupheartbeat=0;
  var ismoving = false;

  heartbeat() async {
    // So that if in background dont keep ticking
    if (OPENWORLD.System.appstate != AppLifecycleState.resumed)
      return;

    for (var i=callwhentrues.length-1; i>=0; i--) {//callwhenitem in callwhentrues) {
      var callwhenitem=callwhentrues[i];
      if (callwhenitem[0]()) {
        callwhenitem[1]();//callback();
        callwhentrues.removeAt(i);
      }
    }

    // Save player state
    var worldpos = OPENWORLD.You.getWorldPos(); //Space.localToWorldObj(camera);
    //instancedColumns.updateVisibility(worldpos);//threeJs.camera.position);
    //print("vvvv"+instancedModels.length.toString());
    for (var instancedmodel in instancedModels)
      instancedmodel.updateVisibility(threeJs.camera.position);//worldpos);
    if (worldpos.x != prevposx || worldpos.y != prevposy) {
      ismoving = true;

      OPENWORLD.Persistence.set("posx", worldpos.x);
      OPENWORLD.Persistence.set("posy", worldpos.y);
    } else
      ismoving = false;
   /* if (horseriding&&horseridingcloploaded) {
      if (ismoving)
        horseridingclop.setVolume(0.5);
      else
        horseridingclop.setVolume(0.01); // so doesnt turn off
    }*/
    OPENWORLD.Persistence.set("turn", OPENWORLD.Camera.turn);

    // Save currrent time
    OPENWORLD.Persistence.set("time", OPENWORLD.Time.time);
    // Save weather
    if (saveweather) {
      OPENWORLD.Persistence.set("rain", OPENWORLD.Weather.rain);
      OPENWORLD.Persistence.set("wind", OPENWORLD.Weather.wind);
      OPENWORLD.Persistence.set("cloud", OPENWORLD.Weather.cloud);
      OPENWORLD.Persistence.set("fog", OPENWORLD.Weather.fog);
    }

    // Stop a player going out of bounds of the game by slowing their speed
    var drag = -1.0;
    const diff = 2.0;
    const miny = -65;
    const maxy =120;// 96;
    const minx = -88;
    const maxx = 121;
    if (worldpos.x < minx + diff)
      drag = defaultdrag *
          ((worldpos.x - minx) / diff); //(1-((diff-worldpos.x)/diff));
    else if (worldpos.x > maxx - diff) { //(mudwidth-2)-diff) {
      // print("drag x");
      drag = defaultdrag * (maxx - worldpos.x) /
          diff; //((mudwidth - 2)- worldpos.x) / diff;
    } else if (worldpos.y < miny + diff)
      drag = defaultdrag *
          ((worldpos.y - miny) / diff); //(1-((diff-worldpos.x)/diff));
    else if (worldpos.y > maxy - diff) { //(mudwidth-2)-diff) {
      // print("drag x");
      drag = defaultdrag * (maxy - worldpos.y) /
          diff; //((mudwidth - 2)- worldpos.x) / diff;
    }
    if (drag != -1.0) {
      OPENWORLD.You.drag = drag;
    } else
      OPENWORLD.You.drag = defaultdrag;


    var cntvisible = 0;
    var notvisible = [];
    for (var i=0; i<citizengroups.length; i++) {//soldierpath in citizengroups) {
      var soldierpath=citizengroups[i];
      if (soldierpath.visible) {
        cntvisible++;

      } else {
       // up mount of olives can only have two people walking next to eachother because of steepness - that is:
       // 3 two ladies next to eachother
       // 7 two soldiers
        if (worldpos.y<17 &&worldpos.x>24) {
          if (i == 3 || i == 7 || i==8)
            notvisible.add(soldierpath);
          // citizengroups[2] is the cart which should not enter bezethda therefore dont include it unless it is outside the wall
        } else if ((worldpos.y>64&&i==2)||(worldpos.y<0&&i==2)||i!=2)
          notvisible.add(soldierpath);
      }
    }
    // var tickcheck;
    //if (cntvisible==0)
    //   tickcheck=1;
    // else
    //  tickcheck=10;
    //if (cntvisible==1)
    //   tickcheck+=OPENWORLD.Math.randInt(20); // Make wait if more than 1 visible already
    // This I think is the northern group of piglrims coming through the gate of the women
    var goingnorth;
    if (worldpos.y<17 &&worldpos.x>24) {
      // This is east of the creek
      if (worldpos.x<57) {
        goingnorth = (worldpos.x > prevposx); // this means going east
        print("goingnorth iii"+goingnorth.toString());
      } else {
        goingnorth = (worldpos.y < prevposy); // this means going south  because looping back round south
        print("goingnorth ii"+goingnorth.toString()+" "+worldpos.y.toString()+" "+ prevposy.toString());
      }
    } else if (ismoving)
      goingnorth = (worldpos.y > prevposy);
    else
      goingnorth =
          OPENWORLD.Math.standardAngle(OPENWORLD.Camera.turn) < 90 ||
              OPENWORLD.Math.standardAngle(OPENWORLD.Camera.turn) > 270;
  //  if (worldpos.y>0) {

   // print("goingnorth"+goingnorth.toString());
    // worldpos.x -5.5 and 6.93 means only if west of the western wall do you show the citizenpath -stop citizenpath showing while say doing the ketoret
    if ((nextcizitengroupheartbeat == 0 || nextcizitengroupheartbeat == heartbeattick)&&
        OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)&&
        !(worldpos.x>-5.5&&worldpos.y<6.93&&worldpos.x<10.3)) {  //x,y -5.5, 6.93 north west corner of second temple  10.3 is eastern x
                                                                    // so is basically saying if your within the temple mount dont do this path
                                                                     // you have awful setup where includes citizenpathsouth! so have to do this
     // print("i am in citizengroup!!");
      if (cntvisible <5&&notvisible.length>0) {
        var soldierpath = notvisible[OPENWORLD.Math.randInt(notvisible.length)];
        //  print("solider not visible");


        // want soldier to come in from in front of you in past the hide distance
        var closesty;
        if (worldpos.x > 57) {
          // Horrible fudge so that get walkers coming the bethspage!!!
          if (goingnorth)
            closesty = worldpos.y - citizenhidedist;
          else
            closesty = worldpos.y + citizenhidedist;

        } else {
          if (goingnorth)
            closesty = worldpos.y + citizenhidedist;
          else
            closesty = worldpos.y - citizenhidedist;
        }
        var usecitizenpath;
                                 // This is south west corner of western wall
        if ( worldpos.y >17||(worldpos.y>-10.6&&worldpos.x<-5.57)) {
          // use citizen path
          if (worldpos.y >21) {  // 21 is about the level of bethesda pool
            // Is this so some go on that alternative friend path?
            if (OPENWORLD.Math.random() < 0.5)//||worldpos.y<21)
              usecitizenpath = citizenpath;
            else
              usecitizenpath = friendpath;  //womensgate friend path
          } else
            usecitizenpath = citizenpath;
        } else {
          print("using citizenpath south");
          usecitizenpath = citizenpathsouth;
        }

       /* if (worldpos.y < 17)
          usecitizenpath = citizenpathsouth;
        else {
          // Is this so some go on that alternative friend path
          if (OPENWORLD.Math.random()<0.5)
            usecitizenpath = citizenpath;
          else
            usecitizenpath = friendpath;
        }*/
        // This has issue where can pop into existence if too close
        var closestind = -1;
        var closestdist = 9999.0;
        for (var i = 0; i < usecitizenpath.length; i++) {
          var dist = OPENWORLD.Math.vectorDistance(
              THREE.Vector3(worldpos.x, closesty, 0),
              THREE.Vector3(usecitizenpath[i][0], usecitizenpath[i][1], 0));
          if (dist < closestdist) {
            closestdist = dist;
            closestind = i;
          }
        }


        if (closestdist < 5) {
          List<Map> citizenpositions = [];
          if (goingnorth) {
            // citizenpath goes from north to south
            for (var i = closestind; i < usecitizenpath.length; i++) {
              var position = usecitizenpath[i];
              citizenpositions.add(
                  {"p": [position[0], position[1], 0], "v": 0.05});

              /// print(
              //    "mmm" + position[0].toString() + " " +
              //        position[1].toString());
            }
          } else {
            for (var i = closestind; i >= 0; i--) {
              var position = usecitizenpath[i];
              citizenpositions.add(
                  {"p": [position[0], position[1], 0], "v": 0.05});
              //print(
              //    "nnn" + position[0].toString() + " " +
              //       position[1].toString());
            }
          }
          // Make sure that hide distance isn't smaller than the distance from the camera
          var dist = OPENWORLD.Math.vectorDistance(
              THREE.Vector3(worldpos.x, worldpos.y, 0), THREE.Vector3(
              usecitizenpath[closestind][0], usecitizenpath[closestind][1], 0));
          if (dist + 0.2 > citizenhidedist)
            OPENWORLD.Space.setObjHideDist(soldierpath, dist + 0.2); // soldierpath.extra['cameradist'] = dist + 0.2; // Cheat so appears
          else
            OPENWORLD.Space.setObjHideDist(soldierpath, citizenhidedist);
         /* if (goingnorth) {
          //  print("citizenpath turn going north");
            OPENWORLD.Space.objTurn(soldierpath, 180);
          }  else {
         //   print("citizenpath turn going south");
            OPENWORLD.Space.objTurn(soldierpath, 0);
          }*/
          //   soldierpath.extra['cameradist'] = citizenhidedist;
          if (soldierpath.extra.containsKey('movetoloopindex'))
            soldierpath.extra.remove('movetoloopindex');
        //  print("solider cameradist" + dist.toString() + " " +
       //       OPENWORLD.Space.objIsHide(soldierpath).toString());



          print("citiznepathsouth"+ citizenpositions.toString());
          OPENWORLD.Mob.moveToLoop(soldierpath,
            citizenpositions,
            //  duration: 1.0,
            //  randomduration: 0.1,
           // facedir: worldpos.y < 17,//0,
            facenow: true,
            surfaceonly: true,
            normalize2world: usecitizenpath!=citizenpathsouth,//true,
            looptype: OPENWORLD.Mob
                .LoopTypeReverseLoop, //                reverseloop: true,
            // action: "walk" //straight"
          );
        }
      }
    }

    if (heartbeattick>nextcizitengroupheartbeat)
      nextcizitengroupheartbeat=(heartbeattick+10+OPENWORLD.Math.randInt(20)).toInt();


    // Essener path all the way south to all the way to the temple mount

      cntvisible = 0;
      notvisible = [];
      for (var i = 0; i < groupessener.length; i++) {
        // Dont show the soldiers,goats, donekeys if south of the temple
      //  8 6 5 4
        if (worldpos.y < -13.77||(worldpos.y >= -6.6&&//13.77&&    past tunnel can have goats and sheep
          //  i!=8&& man with a goat
            i!=6&&  // woman with donkey
          //  i!=5&& man with his sheep
            i!=4// two soldiers
        )||(worldpos.y >= -13.77&&   // if in tunnel no goats or sheep
             i!=8&&// man with a goat
            i!=6&&  // woman with donkey
              i!=5&& //man with his sheep
            i!=4// two soldiers
        )
        )  { //i < groupessener.length - 1 ||
        //    (groupessener.length - 1 == i && worldpos.y < -13.77)) {
          var group = groupessener[i];
          if (group[0][0].visible) {  // looks like you get the first item in the list of group
            cntvisible++;

            //  OPENWORLD.Space.objNormalize2World(soldierpath);
          } else
            notvisible.add(group);
        }
      }


      if ((nextcizitenessengroupheartbeat == 0 ||
          nextcizitenessengroupheartbeat == heartbeattick)&&OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)&&notvisible.length>0) {
        if (cntvisible < 7) {
          var group;
          //  if (worldpos.y<-13.77)
          group = notvisible[OPENWORLD.Math.randInt(notvisible.length)];
          //   else
          //     group= notvisible[OPENWORLD.Math.randInt(notvisible.length)-1];  // if in temple mount do not include soldiers when is the last one
          //  print("solider not visible");


          // want soldier to come in from in front of you in past the hide distance
          var closesty;
          if (goingnorth)
            closesty = worldpos.y + citizenhidedist;
          else
            closesty = worldpos.y - citizenhidedist;
          var closestind = -1;
          var closestdist = 9999.0;
          for (var i = 0; i < citizenessenpath.length; i++) {
            var dist = OPENWORLD.Math.vectorDistance(
                THREE.Vector3(worldpos.x, closesty, 0),
                THREE.Vector3(
                    citizenessenpath[i][0], citizenessenpath[i][1], 0));
            if (dist < closestdist) {
              closestdist = dist;
              closestind = i;
            }
          }
          if (closestdist < 5) {

            for (var item in group) {
              var xadd = item[1];
              var yadd = item[2];
              List<Map> citizenpositions = [];


              if (goingnorth) {
                // citizenpath goes from north to south
                for (var i = closestind; i < citizenessenpath.length; i++) {
                  var position = citizenessenpath[i];
                  var level;
                  if (position[1]<-6.85) //94) //7.02)//-6.91)
//                  if (position[1]<-6.96)
                    level=0;
                  else
                    level=1;
                  citizenpositions.add(
                      {
                        "p": [position[0] + xadd, position[1] + yadd, 0],
                        "v": 0.05,"l":level
                      });

                }
              } else {
                for (var i = closestind; i >= 0; i--) {
                  var position = citizenessenpath[i];
                  var level;
                  if (position[1]<-6.85) //94) //7.02)//-6.91)
//                  if (position[1]<-6.96)
                    level=0;
                  else
                    level=1;
                  if (i > 0)
                    citizenpositions.add(
                        {
                          "p": [position[0] - xadd, position[1] - yadd, 0],"l":level, "v": 0.05
                        });
                  else {
                    // When reach nicanor gate you pray
                    citizenpositions.add(
                        {
                          "p": [
                            position[0] - xadd +
                                OPENWORLD.Math.randFloatSpread(0.5),
                            position[1] - yadd +
                                OPENWORLD.Math.randFloatSpread(0.5),
                            0],"l":level,
                          "v": 0.05
                        });
                    citizenpositions.add({
                      "action": "idle3",//prostrate",
                      "time": 60,
                      "duration": null,
                      "z": 0,
                      "t": 270
                    },);
                    // citizenpositions.add(
                    //     [position[0] - xadd+OPENWORLD.Math.randFloatSpread(0.5), position[1] - yadd+OPENWORLD.Math.randFloatSpread(0.5), 0, 0.05]);
                  }

                  //print(
                  //    "nnn" + position[0].toString() + " " +
                  //       position[1].toString());
                }
              }

              item[0].extra.remove('movetoloopindex');
              OPENWORLD.BaseObject.clearTimers(item[0]);

              var action;
              if (item[0].extra.containsKey('essenerwalk'))
                action=item[0].extra['essenerwalk'];  // eg walkhandright for sheep
              else
                action='walk';
              OPENWORLD.Mob.moveToLoop(item[0], citizenpositions,
                  duration: 1.0,
                  randomduration: 0.1,
                  surfaceonly: true,
                  // remove so that smooth on steps
                  // index: ind,
                  facedir: true,
                  looptype: OPENWORLD.Mob.LoopTypeReverseLoop,
                  //reverseloop: true,
                  action: action// "walk" //straight"
              );
            }
          }
        }
      }
      if (heartbeattick > nextcizitenessengroupheartbeat)
        nextcizitenessengroupheartbeat =
            (heartbeattick + 10 + OPENWORLD.Math.randInt(20)).toInt();


    cntvisible=0;
    notvisible=[];
    for (var i=0; i< groupwomen.length; i++) {
        var group = groupwomen[i];
        if (group[0][0].visible) {
          cntvisible++;
        } else
          notvisible.add(group);

    }

    if ((nextcizitenwomengroupheartbeat==0|| nextcizitenwomengroupheartbeat==heartbeattick)&&OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {

      if (cntvisible < 3) {
        var group;
        //  if (worldpos.y<-13.77)
        group= notvisible[OPENWORLD.Math.randInt(notvisible.length)];
        //   else
        //     group= notvisible[OPENWORLD.Math.randInt(notvisible.length)-1];  // if in temple mount do not include soldiers when is the last one
        //  print("solider not visible");


        // want soldier to come in from in front of you in past the hide distance

        var closestind = -1;
        var closestdist = 9999.0;

        for (var i = 0; i <citizenwomenpath.length; i++) {
          var dist = OPENWORLD.Math.vectorDistance(
              THREE.Vector3(worldpos.x, worldpos.y,0),//closesty, 0),
              THREE.Vector3(citizenwomenpath[i][0], citizenwomenpath[i][1], 0));
          if (dist < closestdist) {
            closestdist = dist;
            closestind = i;
          }
        }
        if (closestdist < 5&&closestind>0) {
          print("womengroupclosestind"+closestind.toString()+" "+citizenwomenpath.length.toString());
          for (var item in group) {
            var xadd = item[1];
            var yadd = item[2];
            List<Map> citizenpositions = [];
            // var zadd;
         ///   if (goingnorth) {
              // citizenpath goes from north to south
              for (var i = closestind-1; i < citizenwomenpath.length; i++) {
                var position = citizenwomenpath[i];
                /* if (position[1]>-50)
                  zadd=0.02;
                else
                  zadd=0;*/
                var level;
                if (position[1]<7.7)
                  level=1;
                else
                  level=0;
                if (i==citizenwomenpath.length-1)
                  citizenpositions.add(
                      {"p":[position[0] + xadd+OPENWORLD.Math.randFloatSpread(0.4), position[1] + yadd+OPENWORLD.Math.randFloatSpread(0.4), 0], "v":0.05,"l":level,
                        "callback":(actor){
                          print("woman stop");
                          OPENWORLD.Actor.playAction(actor,action:"idle3");////, clampWhenFinished: true,
                              //stopallactions: true);
                          if (actor.extra.containsKey('sacrifice'))
                            OPENWORLD.Actor.playAction(actor.extra['sacrifice'],action:"idle",duration:6);
//                            OPENWORLD.Actor.playAction(actor.extra['sacrifice'],action:"idle", clampWhenFinished: true,stopallactions: true,duration:6);
                        }
                   });
                else
                  citizenpositions.add(
                      {"p":[position[0] + xadd, position[1] + yadd, 0],"v": 0.05,"l":level});

                /// print(
                //    "mmm" + position[0].toString() + " " +
                //        position[1].toString());
              }

           // }
            item[0].extra.remove('movetoloopindex');
            OPENWORLD.BaseObject.clearTimers(item[0]);

            //OPENWORLD.Actor.playAction(actor,action:"idle3", clampWhenFinished: true,
            //    stopallactions: true);
            if (item[0].extra.containsKey('sacrifice'))  // Set the goat and sheep back to walking again in case stopped at the second temple
              OPENWORLD.Actor.playAction(item[0].extra['sacrifice'],action:"walk", clampWhenFinished: true,stopallactions: true);//,duration:6);

            // Stop when reach the second temple
            OPENWORLD.Mob.moveToLoop(item[0], citizenpositions,
                duration: 1.0,
                randomduration: 0.1,
                surfaceonly: true,  // remove so that smooth on steps
                // index: ind,
                facedir: true,
             //   level:1,
                looptype:OPENWORLD.Mob.LoopTypeStop,//                reverseloop: true,
                action: item[0].extra.containsKey('walkaction')?item[0].extra['walkaction']:"walk"  //straight"
            );
          }

        }
      }
    }
    if (heartbeattick>nextcizitenwomengroupheartbeat)
      nextcizitenwomengroupheartbeat=(heartbeattick+10+OPENWORLD.Math.randInt(20)).toInt();



    // This is what is turning your horse when you are going along citizenpathsouth
    // will this still work without using citizenpathsouthoffset
    if (gamestart==GameStart.bethphage&&horseriding&&_horse.extra['riding']!=null) {
      //var mindist=9999.0;
      // var citizenpathsouthoffset=pathoffset(citizenpathsouth,false,0.05);
       for (var i=0; i<citizenpathsouthfriend.length-1; i++) {//pos in citizenpathsouth) {
         var pos= citizenpathsouthfriend[i];
         var dist=OPENWORLD.Math.vectorDistance(worldpos, THREE.Vector3(pos[0],pos[1],0.0));
         if (dist<0.2) {
           var dir=OPENWORLD.Math.getAngleBetweenPoints(worldpos, THREE.Vector3(citizenpathsouthfriend[i+1][0],citizenpathsouthfriend[i+1][1],0.0));
           print("hit citizenpathsouth dirr"+dir.toString()+" "+OPENWORLD.Camera.turn.toString());
           if (OPENWORLD.Math.angleDifference(dir, OPENWORLD.Camera.turn)<90)
             OPENWORLD.Space.objTurnLerp(threeJs.camera, dir,1.0);//angle, time)
         }
         //if (dist<mindist)
        //   mindist=dist;

       }
       //print("mindist horse"+mindist.toString());
    }

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
    prevposx = worldpos.x;
    prevposy = worldpos.y;

  }


}
