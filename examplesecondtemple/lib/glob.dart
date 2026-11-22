// Global vars used everywhere
class Glob
{
  static var doorwoodhewnstoneeast;
  static var doorwoodhewnstonewest;
  static var doorwayhewnstone;
  static var lampbronzehewnstoneeast;
  static var lampbronzehewnstonewest;
  static var grouplamphewnstoneeast;
  static var grouplamphewnstonewest;
  static var fireWidth = 2;
  static var fireHeight = 4;
  static var fireDepth = 2;
  static var sliceSpacing = 0.5;
  static var doorgoldnicanoreastgatenorth;
  static var doorwaynicanoreastgatenorth;
  static var doorgoldnicanoreastgatesouth;
  static var doorwaynicanoreastgatesouth;
  static var doornicanornorth;
  static var doornicanorsouth;
  static var doorwaynicanor;
  static Function? createTamidCourtCrowd;//createCourtCrowd;//(courtwomennum, courtisraelnum);
  static var pillarcarcass;
  static var finaltableposx=4.05-0.01;  // table where the meat goes
  static var finaltableposy=1.28;
  static var roamtamid=false;
  static var mikvehportal;
  static List meatlist=[];
  static var sixprieststartposx=3.94;
  static var sixprieststartposy=0.57;
  static var sixpriestsdiff=0.1;
  static var threeprieststartposx=4.13;
  static var threeprieststartposy=0.48+0.02;
  static var tamidhearthposx=4.85;
  static var tamidhearthposy=-1.79;
  static Function? threepriestswield;
  static Function? meatonpillar;
  static Function? tamid;
  static Function? tamidhewnstonepriestposx;
  static var tamidhewnstonepriestposy=-1.76;
  static Function? meatdropaltar;
  static Function? meatdropall;
  static var roamketoret=false;
  static Function? tools;
  static Function? ketoret;
  //  static var priestfirepangetposx= 4.02;
  //  static var priestfirepangetposy= -0.5;
  static var priestassistantposx=4.85;//4.85;
  static var priestassistantposy=-1.80;//-1.29;
  static var priestincenseposx= 4.98;//, 4.95;
  static var priestincenseposy=-1.76;//-1.29;
  static var priestincense;
  static var priestassistant;
  static var priestfirepan;
  static var priestfirepanget;
  static var ketoretstartposx= 4.94;
  static var ketoretstartposy= -1.80;
  static var testtamidfinal=false;
  static var firepanposx = 4.09;
  static var firepanposy = -0.81;
  static Function? tamiditems;
  static var firepanground;
  static var libationbowlposx= 4.51;
  static var libationbowlposy=-0.29;
  static Function? tamidfinal;
  static Function? showblood;
  static var roamsukkot=false;// lampstandslit=false;
  static Function? nextfriendtick;
  static Function? getCurrentPathSouthFriend;
  static Function? donebathing;

  static var sixpriests=[];  // So can be used by bethphage journey
  static var threepriests=[];
  static var hewnstonpriestlist=[];

  static final double defaultcameraoffset = 0.15 * 0.5; //35;

 static var hasstabled=false;  // for womensgate
 static var hasreachedsiloam=false; // for bethphage
 static var hasdonebeforegate=false; // so that know have got off donkey and gone up to watergate for timing
 static var watersiloam;
 static var bathingstep=-1;

 static var fruitseller;  // fruit seller at shop if not lowercity
}