// Defines the journey types, the positions at different progress points in the journey and also
// in the initial progress screen includes images and text associated about the journey eg about the bethphage journey
import 'glob.dart';

// The 4 journey and also the roam which just places the player at a certain position in the game at a certain time
enum GameStart {roam, womensgate, bethphage, lowercity,hearth,none}


Map  gamestartpos = {
  GameStart.lowercity:

  {"p":[ -16.57-0.04, -45.32-0.015],"l":2,"time":8, "t":90,
    'progress':[
      'finishedmeal','leavehome','lefthome', 'pilgrim1',
      //'pilgrim2','pilgrim3','pilgrim4',
    //  'pilgrim5','reachshop'
   ],
    "finishedmeal":{"p":[-17.00+0.15, -45.28],"l":0,"t":334},
    "leavehome":{"p":[-17.00+0.15+0.04+0.04+0.02, -45.28],"l":0,"t":270},
    "lefthome":{"p":[-17.54, -45.29],"l":0,"t":56} , //-17.49, -45.26
    "pilgrim1":{"p":[ -12.10, -46.12-0.3],"l":0,"t":0}, // pilgrims road from house
    "pilgrim2":{"p":[ -11.42, -42.38],"l":0,"t":0}, // pilgrims road from house
    "pilgrim3":{"p":[ -10.00, -37.46],"l":0,"t":0}, // pilgrims road from house
    "pilgrim4":{"p":[-9.29-0.02, -34.13],"l":0,"t":0}, // pilgrims road from house
    "pilgrim5":{"p":[-7.19+0.02, -26.7],"l":0,"t":0}, // pilgrims road from house
    "reachshop":{"p":[ -6.54,-20.44-0.2],"l":0,"t":0}, //reached back of  shop
    'progressmsg':[
      {'progress':10,'msg':"You and your husband have a busy morning getting getting ready for your store. ",'img':'icons/lowercity4.jpg'},
      {'progress':40,'msg':"Luckily you've got your donkey that makes the long journey up the pilgrims road a lot easier ",'img':'icons/lowercity2.jpg'},
      {'progress':80,'msg':"Also your husband helps a bit too",'img':'icons/lowercity3.jpg'},
    ]
  },
  // {"p":[-17.00+0.15, -45.28]},// inside house
  //   {"p":[ -12.10, -46.12]}, //pilgrims road from house
  //   {"p":[ -11.42, -42.38]}, //pilgrims road from house further up
  //  {"p":[ -10.19+0.04, -37.46]}, //pilgrims road from house further up
  //  {"p":[ -9.44, -34.13]}, //pilgrims road from house further up
  // {"p":[  -7.19, -26.7]}, //pilgrims road from house further up
  //{"p":[  -6.54,-20.44-0.2]}, //reached shop

  //  {"p":[ -6.27-0.015, -20.47],"t":90},//-6.24, -20.45],"t":90},// -6.08, -20.45]}, //shop
  //'friend',
  //'absoloms',
  GameStart.bethphage:
  { "p": [57.55, 13.45,Glob.defaultcameraoffset/4],"l":1, "t":0,"time":8,
    "progress":[

      'lefthome',
      'kidron',
      'zechariah','olive', 'goatmischeif',
      'beforegate',
   //   'siloam',
    //  'donebathing','pilgrimsroad','pilgrimsroad2',
   //    'courtgentiles', 'courtwomen',
    //  'tamid',
    //  'ketoret',
     // 'tamidfinal'
    ],
    //   "friend":{"p":[53.5, 12.93],"l":0,"t":270},
    "lefthome":{"p":[57.28, 12.91],"l":0,"t":270},
    "kidron":{"p":[23.43, 9.91],"l":0,"t":217},
    // "absoloms":{"p":[21.24, -7.37],"l":0,"t":180},q
    "zechariah":{"p":[16.54, -12.98],"l":0,"t":200},  //17.72, -11.68
    "olive":{"p":[12.66, -21.11],"l":0,"t":200},  //11.64, -20.83
    "goatmischeif":{"p":[2.09, -35.29],"l":0,"t":200},
    "beforegate":{"p":[-1.19, -43.79],"l":0,"t":200},  //-1.62, -45.72
    "siloam":{"p":[-7.90, -52.45-0.1],"l":0,"t":300},
    "donebathing":{"p":[-9.07+0.1, -51.21-0.3],"l":0,"t":316},
    "pilgrimsroad":{"p":[-6.86, -25.64],"l":0,"t":0},
    "pilgrimsroad2":{"p":[-5.89, -19.36],"l":0,"t":0},
    "courtgentiles":{"p":[6.99, -3.91],"l":1,"t":0},
    "courtwomen":{"p":[  6.76, -0.73],"l":1,"t":310},//6.00+0.2, 0.20
    "tamid":{"p":[ 5.16, 1.44],"l":1,"t":227},  // means start the tamid  5 + 0.05, 1.37 5.23, -0.26
    "ketoret":{"p":[ 5.23, -0.26],"l":1,"t":230},  // means start the ketoret
    "tamidfinal":{"p":[ 5.23, -0.26],"l":1,"t":230},
    'progressmsg':[
      {'progress':20,'msg':"Get up at your home at Bethphage on the Mount of Olives",'img':'icons/bethphage3.jpg'},
      {'progress':40,'msg':"Today you are going on a pilgrimage to the Second Temple",'img':'icons/bethphage4.jpg'},
      {'progress':80,'msg':"Along the way meet up with friends",'img':'icons/bethphage5.jpg'},
    ]

  }, // bethphage roof
  //  "p":[54.23, 12.93],  // friend with donkey
  //  "p":[23.43, 9.91],//  kidron north of bridge
  //   "p":[ 49.01, 0.49], // bridge altar
  //  "p":[21.24, -7.37], //absaloms tomb
  //"p":[17.72, -11.68],  // zechariah tomb
  // "p":[11.64, -20.83], // olive picking
  //  { "p":[8.79-0.2, -26.81], "time":12, "t":180} // sit wall
  //  "p":[15.15, -32.17], //silwan
  // "p":[2.09, -35.29], // goat mischeif
  //{ "p":[-1.62, -45.72],"t":180,"time":12} //goats
  //  { "p":[-7.90, -52.45],"time":12,"t":300} // pool siloam  //-8.06, -51.77  -8.1,-52.3-0.1
  //  { "p":[-9.07+0.1, -51.21-0.3],"time":12,"t":300} // done bathing
  //    { "p":[-6.86, -25.64],"time":12,"t":0} // along pilgrims road
  // { "p":[-5.89, -19.36],"time":12,"t":0} // top pilgrims road
//    { "p":[6.99, -3.91],"time":12,"t":0,"l":1} // south court gentiles
//  {"p":[ 6.00+0.2, 0.20],"t":270,"l":1} // court of women
//  {"p":[5.23, -0.26],"t":270,"l":1,"donetamid":true,"idoneketoret":true} // ketoret  // 5.14, 0.55  5.17, -0.38
  // "p":[-11.23, -53.64],//animal yard
  //], "time":12},//8}, // 49.42, 0.42   58.70, 4.91],//57.37, 12.90],//, 1],
  GameStart.womensgate:
  {"p":[-25.51, 117.12],"time":12,"t":166, //+0.7
    "progress":[
      "moshe", "approachinggate", "pastgate",
      "pastgate2","pastgate3","pastgate4",
      "stables",
      "bethesda", "goingnorth", "eastwest", "fishgate", "westernwall", "wilsonsarch",
      "soreg",
      //"courtofwomen"
    ],
    "moshe": {"p":[-21.41, 99.0],"t":166},  // past moshe
    "approachinggate": {"p":[-15.36, 70.36],"t":166},
    "pastgate": {"p":[-13.49-0.04, 62.30],"t":166},
    "pastgate2": {"p":[-6.91, 48.13],"t":166},
    "pastgate3": {"p":[-5.86+0.03, 39.61],"t":136},
    "pastgate4": {"p":[ -0.81+0.08,32.53],"t":159},
    "stables": {"p":[ 3.55+0.15,21.8-0.7],"t":159},  //is a bit redundant give its so close to the pool 3.55+0.15,21.8+0.5+0.5    3.13, 22.56
    "bethesda": {"p":[  6.35,16.83+0.5],"t":159},
    "goingnorth": {"p":[  -0.60, 31.97],"t":330},  //-0.81,32.53
    "eastwest": {"p":[-15.2+0.5,40.66-0.1],"t":290},
    "fishgate": {"p":[ -24.6+0.2, 30.1],"t":180},
    "westernwall": {"p":[  -5.68,2.05],"t":180},
    "wilsonsarch":{"p":[ -6.03,-11.2],"t":180},
    "soreg":{"p":[ 5.23-0.4,-5.94-0.1],"t":20,"l":1},  // -0.2 so path isn't blocked
    "courtofwomen":{"p":[ 7.27+0.045,-1.39 ],"t":-45,"l":1},  //
    'progressmsg':[
      {'progress':10,'msg':"You are on a pilgrimage with your family on your way south through the northern part of Jerusalem, bethesda",'img':'icons/womensgate2.jpg'},
      {'progress':40,'msg':"After chidlbirth you are expected to make yourself ritually pure and you start by going to the pool of bethesda to bathe",'img':'icons/womensgate3.jpg'},
      {'progress':80,'msg':"Buy an offering at the Royal Stoa",'img':'icons/womensgate4.jpg'},
    ]

  },
  //   {"p":[-22.41, 103.01]},
  //  {"p":[-21.41, 99.0]}, // past your friend Moshe
  //   {"p":[-15.36, 70.36]}, // approaching gate
  //  {"p":[-13.49, 62.30]}, // past gate
//   {"p":[-6.91, 48.13]}, // further past gate
  //  {"p":[-5.86+0.03, 39.61]}, // even further past gate
  // {"p":[ -0.81+0.08,32.53]}, // even further past gate
  //  {"p":[ 3.55+0.15,21.8+0.5]}, // stables
  //  {"p":[  6.35,16.83+0.5]}, // pool bethesda
  //  {"p":[ 3.55+0.15,21.8+0.5],"t":330}, // stables going north
  // {"p":[-0.81,32.53],"t":330}, //  even further past gate going north
  // {"p":[-5.86-0.05, 39.61+0.05],"t":290}, //  that east west part
  //   {"p":[-15.2+0.5,40.66-0.1],"t":290}, //  that east west part middle
  //  {"p":[  -19.67,38.2-0.2],"t":290}, //  that east west part middle
  //   {"p":[  -24.6+0.2, 30.1]}, //  fishgate
  //  {"p":[  -15.07,18.81]}, //  past fishgate
  //{"p":[  -5.68,2.05],"t":180}, //  start western wall
//    {"p":[ -6.03,-11.2],"t":180}, //  past wilsons arch
  // {"p":[ 5.23,-5.94-0.1],"t":20,"l":1}, //  approaching soreg
  //  {"p":[ 7.27+0.045,-1.39 ],"t":-45,"l":1}, // court of women  //6.62, -0.64-0.02

  //   {"p":[-29.21, 116.31]},  worker
  GameStart.roam:
  { //"p":[   -8.06, -51.77 ],"time":12,  // siloam
    // "p":[ 1.07, -13.92],"time":12,  // southern wall
//    "p":[-17.00+0.15, -45.28],"time":12, // lowercity home
  //     "p": [57.55, 13.45],"time":12, // bethphage home
    //   "p":[  -13.65+0.1, 64.71],"time":12, //womens gate
     "p":[ -6.04, -2.35],"time":12, // wilsons arch below
    //  "p":[  -2.93, -46.72],"time":12, // fountain gate
   //  "p":[ 3.84, -5.66],"l":1,"time":12, // court gentiles south
    //  "p":[ -9.44, -34.13],"time":12, //pilgrims road further up
   // "p":[-69.2, 35.2],"time":12,  // psephinus tower
    //"p":[  5,1.37 ],"l":1,"time":0, // court israel
   //     "p":[ 0.80-0.02, 2.93+0.05],"l":1,"time":4, "t":50,  // hearth,  so dont trigger your friend
   // "p":[ 2.3, 4.9],"l":1,"time":12,  // court gentiles north
  //  "p":[ -6.04, -2.68],"l":1,"time":12,  // wilsons arch on bridge
   // "p":[ 1-5.87, -11.98],"t":180, "time":12, "l":1, // robinsons arch
  //  "p":[   8.59, 1.31 ],"time":12,"l":1, // court of women
    "tamid":{"p":[5.16, 1.44 ],"t":227,"l":1,"time":12,'progressmsg':[
      {'progress':20,'msg':"The Tamid was a daily ritual for the atonement of the nation of Israel before God"},
    ]},
    "ketoret":{"p":[3.17, 0.53 ],"t":142,"l":1,"time":12,'progressmsg':[
      {'progress':20,'msg':"The Ketoret was a daily ritual requesting connection and unity with God and his protection against plague and harm"},
    ]}, //2.54, 0.58 264  2.54,0.4     3.16, 0.52 t121
    "siloam":{"p":[ -10.28, -50.56, ],"time":12,"t":166,'progressmsg':[
      {'progress':20,'msg':"The pool of Siloam was the largest and most used Mikveh in Jerusalem for purification before entering the Temple"},  //representing divine vulnerability
    ]},// pool of siloam     -8.06, -51.77  //-9.99, -50.66  t180
    "southernwall": {"p":[ 1.07, -13.92],"time":12}, // southern wall
    "westernwall":{"p":[-6.09, -13.31],"t":6,"time":12}, // western wall     -5.84, -13.17
    "bethesda":{"p":[  6.55, 16.74, ],"t":137.99,"time":12,/* 6.35,16.83+0.5 /'progressmsg':[
          {'progress':20,'msg':"You are on a pilgrimage with your family on your way south through the northern part of Jerusalem, bethesda",'img':'icons/womensgate2.jpg'},
          {'progress':40,'msg':"Make yourself ritually pure at the pool of bethesda",'img':'icons/womensgate3.jpg'},
          {'progress':80,'msg':"Buy an offering at the Royal Stoa",'img':'icons/womensgate4.jpg'},
        ]*/}, // bethesda
    "stoa":{"p":[   -4.42, -12.83, ],"t":57,"time":12,"l":1, 'progressmsg':[
    {'progress':20,'msg':"The Royal Stoa was the financial and legal hub of Jerusalem"}]
      // "It was week long pilgrimage festival"
    }, //stoa  //-2.55, -11.6
    "sukkot":{"p":[8.21, 0.45 ],"t":270,"time":0,"l":1,
      'progressmsg':[
      {'progress':20,'msg':"Sukkot was a week long pilgrimage festival. For Sukkot they lit the lamps at the Temple at night and it was so bright women could do needle work by the light of it's glow throughout Jerusalem. "
         // "It was week long pilgrimage festival"
      },  //representing divine vulnerability
      ],

    }, //stoa  //-2.55, -11.6
  },

//    {"p":[  -13.65+0.1, 64.71],"time":0},    // Womans gate
  //  {"p":[   -8.06, -51.77 ],"time":12},// pool of siloam
  //  -11.13, -53.18 // pool siloam women
  //  {"p":[  -11, -58.5],"time":12},    // Essen
  //  {"p":[  -2.93, -46.72],"time":0},    // to fountain gate

//   {"p":[  5,1.37 ],"l":1,"time":12}, // court of israel
  // {"p":[  2.54,0.41 ],"l":1,"time":12}, // sanctuary
  //    {"p":[   8.59, 1.31 ],"time":12,"l":1}, // court of women
  //    {"p":[ 0.80-0.02, 2.93+0.05],"l":1,"time":4, "t":50},  // hearth,  so dont trigger your friend
  ///    {"p":[ 3.84, -5.66],"l":1,"time":12},  // court gentiles south
//   {"p":[ 2.3, 4.9],"l":1,"time":12},  // court gentiles north
  // {"p":[ 1.07, -13.92],"time":12},  // southern wall
  //  {"p":[ -5.84, -13.17],"time":12},  // western wall
  //    {"p":[ -6.04, -2.35],"time":12},  // wilsons arch below
  //  {"p":[ -6.04, -2.68],"l":1,"time":12},  // wilsons arch on bridge
  //   {"p":[6.8,14.35], "time":12},//5.5, 13.3],"time":12},  // pool israel
  //  {"p":[3.9,22], "time":12},//5.5, 13.3],"time":12},  //bethesda stable
  //   {"p":[-69.2, 35.2],"time":12},  // psephinus tower
  //  {"p":[-45.7, -47.5],"time":12},  // essene gate
  //     {"p":[   -2.55, -11.6 ],"time":12,"l":1}, // stoa
  // {"p":[0.67, 2.42],"l":1,"time":12, "t":270},  // hearth, sheep
  //     {"p":[  -12.10, -46.12],"time":12, "t":0},  //pilgrims road from house
  //     {"p":[ -9.44, -34.13],"time":12}, //pilgrims road from house further up
  //   {"p":[   4.83, -1.7+0.5 ],"l":1,"time":12}, // chamber of the hewn stone
  //   {"p":[-17.00+0.15, -45.28],"time":12} , // lowercity home
  //  { "p": [57.55-0.5, 13.45],"time":12}, // bethphage
  //  { "p": [57.55, 13.45],"time":12}, // bethphage home
  // { "p": [-54.3, -42.9],"time":12}, // serpents pool
  // { "p": [-46, -47.51],"time":12}, // proper essen gate

  GameStart.hearth: {"p":[ 0.80-0.02, 2.93+0.05,Glob.defaultcameraoffset/2],"l":1,"time":4, "t":50,
    "progress":[
      'mikveh', 'tolottery','lottery', 'tosecurity',
      'security', 'terumat', 'opendoors', 'tamidlottery',
     'getlamb','lambslaughter',
      'tamid',
      'shema','ketoret'
    ],
    "mikveh":{"p":[ 0.80-0.02, 2.93+0.03 ],"l":1,"t":334},  // has done mikveh
//    "mikveh":{"p":[ 0.80-0.02, 2.93+0.05 ],"l":1,"t":334},  // has done mikveh
    "tolottery":{"p":[0.78, 2.56],"l":1,"t":144},
    "lottery":{"p":[0.78, 2.56],"l":1,"t":144},
    "tosecurity":{"p":[0.66, 1.51],"l":1,"t":144},
    "security":{"p":[5.04, -0.96],"l":1,"t":36},
    "terumat":{"p":[5.15-0.1,-0.81-0.2],"l":1,"t":280},
    "opendoors":{"p":[5.15-0.1,-0.81-0.2],"l":1,"t":280},  // you have opened the doors
    "tamidlottery":{"p":[ 4.96, -1.58 - 0.01],"l":1,"t":225},  // you have done the tamid lottery
    "getlamb":{"p":[  3.98+0.05, 0.51],"l":1,"t":337},  // you have got the lamb
    "lambslaughter":{"p":[  3.94+6*0.1,0.57],"l":1,"t":290},//-45},  // lamb has been slaughtered
    "tamid":{"p":[ Glob.tamidhearthposx,Glob.tamidhearthposy],"l":1,"t":0},  // tamid complete   4.85, -1.79
    "shema":{"p":[ Glob.priestassistantposx, Glob.priestassistantposy],"l":1,"t":0},  // shema complete
    "ketoret":{"p":[Glob.ketoretstartposx,Glob.ketoretstartposy,],"l":1,"t":10},  // ketoret complete   4.94, -1.80  4.93, -1.78 Glob.priestincenseposx-0.05,Glob.priestincenseposy Glob.priestassistantposx, Glob.priestassistantposy
    'progressmsg':[
      {'progress':20,'msg':"You're a new priest after your first night in the chamber of the hearth. Luckily your friend is here to show you the ropes",'img':'icons/hearth2.jpg'},
      {'progress':40,'msg':"Its a busy day with many tasks like the morning inspection",'img':'icons/hearth3.jpg'},
      {'progress':80,'msg':"Also taking part in the rituals",'img':'icons/hearth4.jpg'},
    ]

  },  //0.58, 2.88
//    GameStart.hearth: {"p":[ 0.80-0.02, 2.93+0.05,defaultcameraoffset/2],"l":1,"time":4, "t":50},  //0.58, 2.88


}; //-13.49+0.1, 62.30]};//-15.36, 70.36]};//]};//]};//-21.41, 99.0]};//]};//]};//-22.41, 103.01]};//]};//]};
