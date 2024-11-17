
import 'dart:io';
import 'dart:ui';


import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import 'theme.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Rhodes3DPage.dart';

import 'package:openworld/openworld.dart' as OPENWORLD;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb&&(Platform.isLinux||Platform.isWindows||Platform.isMacOS)) {

    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle(gamename);
      final screens = PlatformDispatcher.instance.displays;
      final fSize = screens.first.size;

      windowManager.setSize(Size(  1440,900));
      // windowManager.setSize(Size(fSize.width, fSize.height));
      // windowManager.setPosition(Offset(0.0,0.0));
      windowManager.setAlignment(Alignment.center);
    });
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{

  @override
  void didChangeAppLifecycleState(AppLifecycleState state)  {
    //setState(() {
    OPENWORLD.System.appstate=state;
    var unmute=state==AppLifecycleState.resumed;
    var mute=state==AppLifecycleState.inactive;
  //  if (state!=AppLifecycleState.resumed) {
      //SecondTemplePage.close();
    // Mute everything if go into background
    if (unmute) {
      OPENWORLD.Room.mute(false);
      OPENWORLD.Weather.mute(false);
      OPENWORLD.Musics.setMute(false); //stop();
      OPENWORLD.Sound.setMute(false);

      if (OPENWORLD.You.room!=null&&OPENWORLD.You.room!.extra.containsKey('trigger')&&OPENWORLD.You.room!.extra.containsKey('triggeronresume')) {
        print("trigger room");
        print("so when resume hear roomdefault sounds");
        OPENWORLD.You.room?.extra['trigger'].trigger(true);
      }
      //StateRhodes3D.setMute();
    }
    if (mute) {
      if (roomdefaultsoundloaded) {
        roomdefaultsound11.stop();
        roomdefaultsound12.stop();
        roomdefaultsound21.stop();
        roomdefaultsound22.stop();
      }
      OPENWORLD.Room.mute(true);
      OPENWORLD.Weather.mute(true);
      OPENWORLD.Musics.setMute(true); //stop();
      OPENWORLD.Sound.setMute(true);
    }

 //   }
    //  _notification = state;
    print("change state:"+state.toString());
    //});
  }

  @override
  void initState() {
    // permissions();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     // title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'NanumMyeongjo',
              bodyColor: Colors.white,
              fontSizeFactor: 1.1,
              fontSizeDelta: 2.0,
            ),
        colorScheme: ColorScheme.dark(primary: AppColor.primary),
        //primary:Colors.),//ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: Rhodes3DSplashPage(),
    );
  }
}

class Rhodes3DSplashPage extends StatefulWidget {
  const Rhodes3DSplashPage({super.key});

  @override
  State<Rhodes3DSplashPage> createState() => _Rhodes3DSplashPageState();
}


class _Rhodes3DSplashPageState extends State<Rhodes3DSplashPage> {//}with WidgetsBindingObserver{
  // int _counter = 0;


  void start() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Rhodes3DPage()), //JPage(groups: groups)),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    //SystemChrome.setEnabledSystemUIOverlays([]);
    //print("uuwddd"+MediaQuery.of(context).size.width.toString());
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("icons/rhodes3d.jpg"),
//        image: AssetImage(rnd<0.5?"icons/temple.jpg":"icons/templenight.jpg"),
            fit: BoxFit.cover,
          ),
        ),child:Scaffold(
      backgroundColor: Colors.transparent,

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1 ,color: Colors.white),//transparent), //color is transparent so that it does not blend with the actual color specified
                    borderRadius: const BorderRadius.all(const Radius.circular(6.0)),
                    color: Colors.black,//.withOpacity(0.5) // Specifies the background color and the opacity
                ),
                child: Padding(padding:EdgeInsets.only(left:10,top:0,right:10,bottom:0),
                    child:Text(gamename, style:TextStyle(fontSize:30, color:Colors.white, fontWeight: FontWeight.bold)))),
            SizedBox(height:20),
            //(0xfffffd6d)
            Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1 ,color: Colors.transparent), //color is transparent so that it does not blend with the actual color specified
                  borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
                  gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.5),//Color(0xFF3366FF),
                        Colors.white.withOpacity(0.5),//Color(0xFF00CCFF),
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(0.5, 0.5),
                      stops: [0.0, 1],
                      //   tileMode: TileMode.clamp),
                      tileMode: TileMode.mirror),

                ),

                child: Padding(padding:EdgeInsets.only(left:20,top:20,right:20,bottom:10),
                    child: Column(
                        children:[Container(padding:EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                border: Border.all(width: 1 ,color: Colors.transparent), //color is transparent so that it does not blend with the actual color specified
                                borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                                color: Colors.black.withOpacity(0.5) // Specifies the background color and the opacity
                            ),
                           child:Text(
                               "Welcome to Lindos in the southern Greek island of Rhodes.\n"+
                               "Its 1522 and theres going to be an invasion\n"+
                               "with the Ottaman Empires Suleiman and his huge army.\n"+
                               "There are spies in Lindos giving details on our defences.\n"+
                               "We need help uncovering them\n"+
                               "to save us from obliteration", textAlign: TextAlign.center,
                            style:TextStyle(fontSize:17, color:Colors.white, fontFamily: 'NanumMyeongjo', fontWeight: FontWeight.bold))),
                          SizedBox(height:20),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor:Colors.black,
                                side: BorderSide(
                                  width: 3.0,
                                  color: Colors.white,
                                ),),
                              onPressed: () {
                                start();
                              },
                              //Color(0xff926b01)
                              child: Text("Begin", style:TextStyle(fontSize:20, color:Colors.white,fontWeight: FontWeight.bold)))
                        ]))),

          ],
        ),
      ),
    )
    );
  }
}

