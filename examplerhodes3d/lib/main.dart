import 'dart:io';
import 'dart:ui';


import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Rhodes3DPage.dart';

import 'package:openworld/openworld.dart' as OPENWORLD;

// This was theme.dart in the three_dart version
class AppColor {
  //ok 594400
  static const primary = Colors.white; //Color(0xffbb308a);
}

const MethodChannel _restartChannel = MethodChannel('rhodes3d/restart');

/// Restarts the game. Same as in the new Second Temple.
/// Creating a second three_js viewer in the same process can crash the renderer so instead of going back to
/// the splash page the whole application is restarted which gives a brand new engine and GL context
/// - Desktop: relaunches the process (fresh engine + GL context).
/// - Android: relaunches the app's activity and kills the old process
///   (also a fresh engine + GL context). Needs a 'rhodes3d/restart' method channel in MainActivity
///   like the one used by Second Temple, otherwise falls back to going back to the start screen
/// - iOS: apps can't relaunch themselves, so this returns to the start
///   screen instead (pass [context] from Rhodes3DPage).
Future<void> restartApplication([BuildContext? context]) async {
  print('restartApplication');
  if (kIsWeb) {
    // Nothing to relaunch on the web so just go back to the start screen
    if (context != null && context.mounted)
      Navigator.of(context).popUntil((route) => route.isFirst);
    return;
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Process.start(
      Platform.resolvedExecutable,
      Platform.executableArguments,
      mode: ProcessStartMode.detached,
    );
    exit(0);
  }

  if (Platform.isAndroid) {
    try {
      await _restartChannel.invokeMethod('restart');
      return; // process is killed natively
    } catch (e) {
      print("Android restart failed, falling back to soft restart: $e");
    }
  }

  // iOS (and Android fallback): back to the first screen in this navigator
  if (context != null && context.mounted) {
    print("navigator close");
    Navigator.of(context).popUntil((route) => route.isFirst);
  } else {
    print("navigator close failed");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb&&(Platform.isLinux||Platform.isWindows||Platform.isMacOS)) {

    await WindowManager.instance.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(1440, 900),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: gamename,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      // Windowed by default. Set the persistent value "fullscreen" to true to start full screen (eg for steam)
      bool fs = await OPENWORLD.Persistence.get("fullscreen", def: false);
      print("fullscreen"+fs.toString());
      if (fs) await windowManager.setFullScreen(true);
      await windowManager.show();      // show FIRST so WS_VISIBLE is part of the saved style
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: gamename,
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
