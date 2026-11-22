
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openworld/asset_pack.dart';
import 'package:openworld/openworld.dart' as OPENWORLD;
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:window_manager/window_manager.dart';
import 'gamestart.dart';
import 'theme.dart';
import 'SecondTemplePage.dart';

bool mute=false;

/// Fully relaunches the application as a new OS process, then terminates
/// the current one. Unlike a widget-tree rebuild, this gives you a brand
/// new Flutter engine and native ANGLE/GL context - it's the only reliable
/// way found so far to guarantee the next SecondTemplePage/ThreeJS created
/// is genuinely the first one, not a second instance sharing state with a
/// previous one in the same process.
///
/// Note: only meaningful on desktop (Windows/Linux/macOS) - there's no
/// equivalent concept on web or mobile, so this is a no-op there.
/*Future<void> restartApplication() async {
  if (kIsWeb || !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return;
  }
  final executable = Platform.resolvedExecutable;
  final arguments = Platform.executableArguments;

  await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.detached,
  );

  exit(0);
}*/
const MethodChannel _restartChannel = MethodChannel('secondtemple/restart');

/// Restarts the game.
/// - Desktop: relaunches the process (fresh engine + GL context).
/// - Android: relaunches the app's activity and kills the old process
///   (also a fresh engine + GL context). Needs the MainActivity code.
/// - Web: reloads the page (fresh app + WebGL context).
/// - iOS: apps may not quit or relaunch themselves, so instead the native
///   side throws away the Flutter engine (freeing the whole Dart heap,
///   GL context and textures) and starts a new one, which runs main()
///   again. Needs the AppDelegate.swift code.
/// If the native side isn't set up, it falls back to returning to the
/// start screen (pass [context] from SecondTemplePage).
Future<void> restartApplication([BuildContext? context]) async {
  print('restartApplication');
  if (kIsWeb) {
    // Web: reload the page by opening the game's own URL in the same tab.
    // Like the desktop relaunch, this gives a brand new Flutter app and
    // WebGL context, so the next journey starts clean.
    await launchUrl(Uri.base, webOnlyWindowName: '_self');
    return;
  } else {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await Process.start(
        Platform.resolvedExecutable,
        Platform.executableArguments,
        mode: ProcessStartMode.detached,
      );
      exit(0);
    }

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        // Stop the menu music so the old engine's player isn't left playing
        try {
          await music?.stop();
        } catch (_) {}
        print("restart channel");
        await _restartChannel.invokeMethod('restart');
        return; // Android: process is killed. iOS: this engine is destroyed.
      } catch (e) {
        print("Native restart failed, falling back to soft restart: $e");
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

}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const _kA = [0x32, 0xf9, 0x6f, 0x8a, 0xae, 0x20, 0xf3, 0x15, 0x66, 0xa1, 0xe3, 0x1e, 0x9f, 0xcb, 0x18, 0xe4, 0x10, 0x52, 0x42, 0xa9, 0x74, 0xe5, 0x5c, 0xa0, 0x5a, 0xa5, 0x65, 0x98, 0xa9, 0x11, 0xa5, 0x7a];

  await AssetPack.init(key: AssetPack.keyFromParts([_kA, kB, kC]));

  if (!kIsWeb&&(Platform.isLinux||Platform.isWindows||Platform.isMacOS)) {

    await WindowManager.instance.ensureInitialized();
    WindowOptions windowOptions =  WindowOptions(
      size: Size(1440, 900),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: gamename,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      bool fs = await OPENWORLD.Persistence.get("fullscreen", def: true);
      print("fullscreen"+fs.toString());
      if (fs) await windowManager.setFullScreen(true);
      await windowManager.show();      // show FIRST so WS_VISIBLE is part of the saved style
      await windowManager.focus();
    });

  }
  runApp(const MyApp());
}
class MyApp extends StatefulWidget{
  const MyApp({super.key,}) ;
  @override
  MyAppState createState() => MyAppState();
}
// -----------------------------------------------------------------------
// JourneyCard
//
// A single "journey" tile for the game's start screen.
//
// - `buttonLabel` (e.g. "Womens Gate") is shown as a bold title bar
//   across the top of the card.
// - `title` (e.g. "Pilgrimage from Jerico") is shown as a subtitle bar
//   under the artwork.
// - Hovering fades in the full `description` over the artwork, and
//   smoothly scales the whole card up (classic game-menu "focus" effect).
//
// Resuming vs. restarting a journey:
// - Pass `inprogress: true` when the player already has saved progress
//   on this journey. This shows a small "IN PROGRESS" badge on the card.
// - If you ALSO pass `onRestart`, the hover overlay swaps the plain
//   description for two explicit buttons - "Continue" (calls onPressed)
//   and "Start Over" (calls onRestart) - so the choice only appears when
//   there's actually a decision to make. In that mode the whole-card tap
//   is disabled in favor of those two buttons, to avoid an accidental
//   restart or an ambiguous tap.
// - If `inprogress` is true but `onRestart` is omitted, the card just
//   shows the badge and keeps the simple "tap anywhere to continue"
//   behavior from before.
// - If `inprogress` is false (the default), the card behaves exactly as
//   it did previously: tap anywhere to start, hover to preview.
// -----------------------------------------------------------------------
class JourneyCard extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool inprogress;
  final VoidCallback? onRestart;
  /// Demo only: shows the card greyed out with a "FULL GAME" badge.
  /// Tapping it calls [onPressed], which should show the full-game prompt.
  final bool locked;
  /// Line added under the description on a locked card.
  final String lockedNote;

  const JourneyCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.buttonLabel,
    required this.onPressed,
    this.inprogress = false,
    this.onRestart,
    this.locked = false,
    this.lockedNote = "Available in the full game.",
  });

  @override
  State<JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<JourneyCard> {
  bool _hovering = false;

  /// Phones/tablets have no hover, so there the first tap "hovers" the card
  /// (shows the description / Continue-Start Over), and the next tap starts.
  static bool get _isTouch =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  void _handleTap(bool showChoice) {
    if (_isTouch && !_hovering) {
      setState(() => _hovering = true);
      return;
    }
    if (!showChoice) _activate(widget.onPressed);
  }

  /// Runs a card action. On touch screens it first un-highlights the card,
  /// so it isn't still selected when the player returns to this screen.
  void _activate(VoidCallback? action) {
    if (action == null) return;
    if (_isTouch && _hovering) setState(() => _hovering = false);
    action();
  }

  static const double _cardWidth = 200;
  static const double _cardHeight = 260;

  @override
  Widget build(BuildContext context) {
    // Only offer an explicit Continue/Start Over choice once there is
    // somewhere to route the "Start Over" tap to.
    final bool showChoice =
        !widget.locked && widget.inprogress && widget.onRestart != null;

    return TapRegion(
      // Touch: tapping anywhere else closes this card's overlay again
      onTapOutside: (_) {
        if (_isTouch && _hovering) setState(() => _hovering = false);
      },
      child: MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // When the two-button choice is showing, the buttons themselves
        // handle taps, so the whole-card tap is switched off to avoid an
        // ambiguous "which action did that tap mean?" situation.
        // (On touch screens the first tap only reveals the overlay.)
        onTap: (showChoice && !_isTouch) ? null : () => _handleTap(showChoice),
        child: AnimatedScale(
          scale: _hovering ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _cardWidth,
                height: _cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _hovering
                        ? const Color(0xffe0b24a) // warm gold glow on hover
                        : Colors.white,
                    width: _hovering ? 3.0 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _hovering
                          ? const Color(0xffe0b24a).withOpacity(0.55)
                          : Colors.black.withOpacity(0.4),
                      blurRadius: _hovering ? 18 : 6,
                      spreadRadius: _hovering ? 1 : 0,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipRRect(
                  // Inset radius so the content's curve sits neatly inside
                  // the border's curve, instead of both sharing the same
                  // radius (which made the border look cut off at corners).
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Full-bleed artwork behind everything
                      // (greyscale when locked in the demo)
                      widget.locked
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0, 0, 0, 0.75, 0,
                              ]),
                              child: Image.asset(
                                widget.imagePath,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              widget.imagePath,
                              fit: BoxFit.cover,
                            ),

                      // Top gradient blending into the scene, with the
                      // button label (e.g. "WOMENS GATE") sitting on it
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.black.withOpacity(0.0),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.buttonLabel.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 160,
                                height: 1.5,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom gradient blending into the scene, with the
                      // journey title (e.g. "Pilgrimage from Jerico") on it
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.85),
                              ],
                            ),
                          ),
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Hover overlay: if there's saved progress with a
                      // restart handler, the Continue / Start Over choice
                      // is pinned at the top, with the description below
                      // it in a scrollable area (so long descriptions
                      // don't overflow the card). Otherwise it's just the
                      // description, as before.
                      IgnorePointer(
                        // invisible overlay buttons must not be tappable
                        ignoring: !_hovering,
                        child: AnimatedOpacity(
                        opacity: _hovering ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          color: Colors.black.withOpacity(0.78),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showChoice) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xffe0b24a),
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(
                                      width: 1.5,
                                      color: Color(0xffe0b24a),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                  ),
                                  onPressed: () => _activate(widget.onPressed),
                                  child: const Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      width: 1.5,
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                  ),
                                  onPressed: widget.onRestart == null
                                      ? null
                                      : () => _activate(widget.onRestart),
                                  child: const Text(
                                    "Start Over",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight,
                                        ),
                                        child: Center(
                                          child: Text(
                                            widget.locked
                                                ? "${widget.description}\n\n${widget.lockedNote}"
                                                : widget.description,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              ),

              // "IN PROGRESS" badge, floating above the top border so it
              // reads at a glance without needing to hover.
              if (widget.inprogress && !widget.locked)
                Positioned(
                  top: -8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xffe0b24a),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        "IN PROGRESS",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

              // "FULL GAME" badge with a lock, shown on locked demo cards.
              if (widget.locked)
                Positioned(
                  top: -8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 10, color: Colors.black),
                          SizedBox(width: 3),
                          Text(
                            "FULL GAME",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
var music;

/// "This journey is currently only available on Steam or iTunes." with
/// "Steam" and "iTunes" as tappable links to the store pages.
/// A StatefulWidget so the tap recognizers can be disposed properly.
class _StoreLinksText extends StatefulWidget {
  const _StoreLinksText();

  static const String steamUrl =
      'https://store.steampowered.com/app/4067520/Second_Temple/';
  static const String appStoreUrl =
      'https://apps.apple.com/us/app/second-temple/id6593662011';

  @override
  State<_StoreLinksText> createState() => _StoreLinksTextState();
}

class _StoreLinksTextState extends State<_StoreLinksText> {
  late final TapGestureRecognizer _steamTap = TapGestureRecognizer()
    ..onTap = () => _open(_StoreLinksText.steamUrl);
  late final TapGestureRecognizer _appStoreTap = TapGestureRecognizer()
    ..onTap = () => _open(_StoreLinksText.appStoreUrl);

  Future<void> _open(String url) async {
    try {
      // External browser/app; on web this opens a new tab
      await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
    } catch (e) {
      print("could not open $url: $e");
    }
  }

  @override
  void dispose() {
    _steamTap.dispose();
    _appStoreTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(
      color: Color(0xffe0b24a),
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
      decorationColor: Color(0xffe0b24a),
    );
    return Text.rich(
      TextSpan(
        style: const TextStyle(color: Colors.white),
        children: [
          const TextSpan(text: "This journey is currently only available on "),
          TextSpan(
            text: "Steam",
            style: link,
            recognizer: _steamTap,
            mouseCursor: SystemMouseCursors.click,
          ),
          const TextSpan(text: " or "),
          TextSpan(
            text: "iTunes",
            style: link,
            recognizer: _appStoreTap,
            mouseCursor: SystemMouseCursors.click,
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }
}

class MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  String onPage = '';
  double pageLocation = 0;

  @override
  initState()  {
    // TODO: implement initState
    super.initState();

    playMusic();

  }

  playMusic() async {
    mute=await OPENWORLD.Persistence.get("musicmute", def: false);
    if (!mute) {
      //Prelude in F# Minorccii.mp3,  silver_bulletcc.mp3,saviorii.mp3
      //imaginary_friendii.mp3 too modern
      //interlude.mp3 too soft and weak
      //desert_settlementii.mp3 bit too dramatic and modern
      //trumpets.mp3 is good because authentic but drops off too quick -possibly need whole thing
      //              possibly need trumpeters screenshot to have it make sene
      // heatii.mp3 best so far
      //idiotsinspaceii.mp3 sounds out of place



      music = OPENWORLD.Sound.getAudioPlayer();
      OPENWORLD.Sound.play(sound: music, path: 'sounds/heatii.mp3', volume: 1);
    }
  }

  Widget build(BuildContext context) {

    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: gamename,
      //  theme: CSS.darkTheme,
        home: Scaffold(
          appBar:null,
          body: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(

              textTheme: Theme.of(context).textTheme.apply(
                fontFamily: 'NanumMyeongjo', //Cinzel', //',
                bodyColor: Colors.white,
                fontSizeFactor: 1.1,
                fontSizeDelta: 2.0,
              ),
              colorScheme: ColorScheme.dark(primary: AppColor.primary),
              //primary:Colors.),//ColorScheme.fromSeed(seedColor: Colors.black),
              useMaterial3: true,
            ),
            home: SecondTempleSplashPage(),

          ),
        )
      )
    );
  }
}


class SecondTempleSplashPage extends StatefulWidget {
  const SecondTempleSplashPage({super.key});

  @override
  State<SecondTempleSplashPage> createState() => _SecondTempleSplashPageState();
}

enum GameTabs {journey,roam1,roam2}

class _SecondTempleSplashPageState extends State<SecondTempleSplashPage> {//}with WidgetsBindingObserver{


  //var showroam=false
  GameTabs gametab=GameTabs.journey;

  // Which way the tab content should slide: +1 = new content enters from
  // the right (old content exits left), -1 = new content enters from the
  // left (old content exits right). Recomputed each time the tab changes,
  // based on whether we're moving forward or backward through the
  // journey -> roam1 -> roam2 sequence.
  double _slideDirection = 1.0;

  int _tabIndex(GameTabs t) => GameTabs.values.indexOf(t);

  final bool demo=true;

  /// true  = Steam build: [demo] decides whether journeys are locked.
  /// false = App Store build (macOS/iOS): journeys start locked and are
  ///         unlocked with the in-app purchase [fullGameProductId].
  final bool steam=true;

  // ---------------------------------------------------------------------
  // App Store in-app purchase
  // ---------------------------------------------------------------------

  /// The non-consumable product ID created in App Store Connect.
  static const String fullGameProductId = 'com.forthtemple.secondtemplebuy';//';
  static const String _unlockKey = 'fullgameunlocked';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  ProductDetails? _fullGameProduct;
  bool _storeAvailable = false;
  bool _fullGameUnlocked = false;
  bool _purchasePending = false;
  bool _restoring = false;

  /// App Store mode only applies on Apple platforms.
  bool get _appStoreMode =>
      !steam && !kIsWeb && (Platform.isMacOS || Platform.isIOS);

  /// Whether the full-game journeys are locked right now.
  bool get _locked =>
      steam ? demo : (_appStoreMode ? !_fullGameUnlocked : false);

  /// Demo on Android, web and Linux: Hearth and Ketoret aren't sold there
  /// yet, so they're shown locked with a "Steam or iTunes" message instead.
  /// (kIsWeb is checked first because Platform isn't available on web.)
  bool get _androidLocked =>
      demo && (kIsWeb || Platform.isAndroid || Platform.isLinux);

  /// What the Hearth and Ketoret cards actually use.
  bool get _journeyLocked => _locked || _androidLocked;

  static const String _androidLockedText =
      "Currently only available on Steam or iTunes.";

  Future<void> _initStore() async {
    _fullGameUnlocked =
        await OPENWORLD.Persistence.get(_unlockKey, def: false) == true;
    if (mounted) setState(() {});

    // Listen before anything else so no purchase updates are missed
    // (including ones left unfinished from a previous run).
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (e) => _showMessage("App Store error: $e"),
    );

    _storeAvailable = await _iap.isAvailable();
    if (_storeAvailable) {
      final response = await _iap.queryProductDetails({fullGameProductId});
      if (response.error != null) {
        print("App Store product query error: ${response.error}");
      }
      if (response.notFoundIDs.isNotEmpty) {
        print("App Store product not found: ${response.notFoundIDs}");
      }
      _fullGameProduct = response.productDetails.isNotEmpty
          ? response.productDetails.first
          : null;
    }
    if (mounted) setState(() {});
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != fullGameProductId) {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }
      switch (purchase.status) {
        case PurchaseStatus.pending:
          // eg waiting for Ask to Buy approval or payment confirmation
          setState(() => _purchasePending = true);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _unlockFullGame(
              restored: purchase.status == PurchaseStatus.restored);
          break;
        case PurchaseStatus.canceled:
          setState(() => _purchasePending = false);
          _showMessage("Purchase cancelled.");
          break;
        case PurchaseStatus.error:
          setState(() => _purchasePending = false);
          _showMessage(
              "The purchase couldn't be completed: ${purchase.error?.message ?? 'unknown error'}");
          break;
      }
      // Always finish the transaction, otherwise the App Store keeps
      // re-sending it every time the game starts.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _unlockFullGame({bool restored = false}) async {
    await OPENWORLD.Persistence.set(_unlockKey, true);
    final wasUnlocked = _fullGameUnlocked;
    setState(() {
      _fullGameUnlocked = true;
      _purchasePending = false;
      _restoring = false;
    });
    if (!wasUnlocked) {
      _showMessage(restored
          ? "Your purchase has been restored. All journeys are unlocked."
          : "Thank you! All journeys are now unlocked.");
    }
  }

  Future<void> _buyFullGame() async {
    if (!_storeAvailable || _fullGameProduct == null) {
      _showMessage("The App Store isn't available right now. Please try again later.");
      _initStoreRetry();
      return;
    }
    setState(() => _purchasePending = true);
    try {
      final started = await _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: _fullGameProduct!));
      if (!started) setState(() => _purchasePending = false);
    } catch (e) {
      setState(() => _purchasePending = false);
      _showMessage("The purchase couldn't be started: $e");
    }
  }

  Future<void> _restorePurchases() async {
    if (!_storeAvailable) {
      _showMessage("The App Store isn't available right now. Please try again later.");
      return;
    }
    setState(() => _restoring = true);
    try {
      await _iap.restorePurchases();
    } catch (e) {
      setState(() => _restoring = false);
      _showMessage("Couldn't restore purchases: $e");
      return;
    }
    // Restored purchases arrive on the purchase stream. If nothing has
    // arrived after a few seconds there was nothing to restore.
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _restoring) {
        setState(() => _restoring = false);
        if (!_fullGameUnlocked) {
          _showMessage("No previous purchase was found for this Apple ID.");
        }
      }
    });
  }

  /// Re-query the store, eg if it wasn't reachable at startup.
  Future<void> _initStoreRetry() async {
    _storeAvailable = await _iap.isAvailable();
    if (_storeAvailable && _fullGameProduct == null) {
      final response = await _iap.queryProductDetails({fullGameProductId});
      _fullGameProduct = response.productDetails.isNotEmpty
          ? response.productDetails.first
          : null;
    }
    if (mounted) setState(() {});
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 4)),
    );
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  /// The FULL game's Steam App ID (not the demo's or the playtest's).
  static const String fullGameSteamAppId = '4067520';

  /// Opens the full game's store page in the Steam client, falling back to
  /// the store website if Steam can't be opened.
  Future<void> _openFullGameInSteam() async {
    final steam = Uri.parse('steam://store/$fullGameSteamAppId');
    final web = Uri.parse('https://store.steampowered.com/app/$fullGameSteamAppId/');
    bool ok = false;
    try {
      ok = await launchUrl(steam);
    } catch (_) {}
    if (!ok) {
      try {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      } catch (e) {
        print("could not open Steam store: $e");
      }
    }
  }

  /// Shown when a locked journey is tapped.
  void _showFullGameDialog(String journeyName) {
    if (_androidLocked) {
      _showAndroidLockedDialog(journeyName);
      return;
    }
    if (_appStoreMode) {
      _showUnlockDialog(journeyName);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xffe0b24a), width: 1.5),
        ),
        title: Text(journeyName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "This journey is part of the full game.\nWould you like to view Second Temple on Steam?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Not now", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffe0b24a),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _openFullGameInSteam();
            },
            child: const Text("View on Steam",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  /// Android/web/Linux demo version of the locked-journey prompt: just a message.
  void _showAndroidLockedDialog(String journeyName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xffe0b24a), width: 1.5),
        ),
        title: Text(journeyName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const _StoreLinksText(),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffe0b24a),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _goToTab(GameTabs newTab) {
    setState(() {
      _slideDirection = _tabIndex(newTab) >= _tabIndex(gametab) ? 1.0 : -1.0;
      gametab = newTab;
    });
  }

  /// App Store version of the locked-journey prompt (no mention of Steam,
  /// which Apple doesn't allow).
  void _showUnlockDialog(String journeyName) {
    final price = _fullGameProduct?.price;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xffe0b24a), width: 1.5),
        ),
        title: Text(journeyName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          _fullGameProduct == null
              ? "This journey is part of the full game.\n\nThe App Store isn't available right now, please try again later."
              : "This journey is part of the full game.\n\nUnlock the full game to play every journey.",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Not now", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restorePurchases();
            },
            child: const Text("Restore Purchases",
                style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffe0b24a),
              foregroundColor: Colors.black,
            ),
            onPressed: _fullGameProduct == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    _buyFullGame();
                  },
            child: Text(
                price == null ? "Unlock full game" : "Unlock full game – $price",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  var gamestates={};

  /// True from the moment a journey is tapped until its page is on screen.
  /// Shows the "Loading…" overlay and blocks further taps, so a second tap
  /// during the delay can't open a second SecondTemplePage.
  bool _starting = false;
  bool _continue = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gamestart();
    if (_appStoreMode) _initStore();

  }

  gamestart() async {
    for (var gamekey in gamestartpos.keys) {
      //!(gamestartpos[gamekey].containsKey('progress')&&gamestartpos[gamekey]['progress'].length>0)) {
      var currentstate = await OPENWORLD.Persistence.get(gamekey.toString());
      if (currentstate != null && currentstate.length > 0) {
        gamestates[gamekey]=currentstate;
        print("have found gamestart "+gamekey.toString()+" progress "+currentstate.toString()+" "+currentstate.length.toString());
        // return dict[currentstate[currentstate.length - 1]];
        // gamestartpos[gamekey]['progress'] = currentstate;
      }
    }
    setState(()  {
     // gamestates[GameStart.womensgate]={};
     // gamestates[GameStart.womensgate]['progress']='moshe';
      gamestates=gamestates;



    });


  }
  Future<void> start({gamestart,progress, restart=false}) async {
    if (_starting) return; // already starting a journey
    setState(() {
      _starting = true;
      _continue=!restart&&gamestates[gamestart]!=null;
     // _restart=restart;
    });
    // Let the loading overlay actually paint before the heavy work of
    // building the game page starts, otherwise it never gets shown.
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
   // var music2= OPENWORLD.Sound.getAudioPlayer();
    if (!mute) {
      OPENWORLD.Sound.fadeOut(music,8);
      var ticks = 0;
      // Artifically fade the sound
      Timer.periodic(new Duration(milliseconds: 100), (t) {
        OPENWORLD.Sound.update();
        if (ticks * 10 > 4000) // after 4 seconds cancel
          t.cancel();

        ticks++;

        //userGuidanceController.show(subIndex:1);
      });

      //desert_settlementii.mp3,interlude.mp3,imaginary_friendii.mp3
      //heatii.mp3
     // OPENWORLD.Sound.play(path: 'sounds/trumpets.mp3', volume: 1);
    }
  //  OPENWORLD.Sound.playFade(music, music2, 2.0);

    if (restart) {
      await OPENWORLD.Persistence.remove(gamestart.toString()) ;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SecondTemplePage(gamestart:gamestart,progress:progress)), //JPage(groups: groups)),
    );
    // Back on this screen (eg the iOS soft restart): allow taps again and
    // refresh the IN PROGRESS badges.
    if (mounted) {
      setState(() {

       _starting = false;

      }
    );
      this.gamestart(); // 'this.' because the parameter is also called gamestart
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
 //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Container(
      color: Colors.black,
       /* decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("icons/ark.jpg"),
            fit: BoxFit.cover,
          ),
        ),*/
        child:Scaffold(
      backgroundColor: Colors.transparent,

      body:
    //  Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
      //  child:
      Stack(children: [
      Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(OPENWORLD.Math.random()<0.5?'icons/stoa.jpg':'icons/sukkot2.jpg'),//background.jpg'),//stoa.jpg'),
              fit: OPENWORLD.System.isSmartphone()?BoxFit.fitHeight:BoxFit.cover, // Scales the image to fill the container
            )),
        child:

        Column(

        //  mainAxisAlignment: MainAxisAlignment.start,//center,
          children: <Widget>[
            (!kIsWeb&&(Platform.isWindows||Platform.isLinux||Platform.isMacOS)) || (_appStoreMode && !_fullGameUnlocked)?
                Container(
                  alignment: Alignment.topLeft,
               padding:EdgeInsets.all(20),
            child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[

                  // App Store: always-visible Restore Purchases (Apple requires
                  // a way to restore), plus a progress note while the App
                  // Store is working on a purchase or restore.
                  if (_appStoreMode && !_fullGameUnlocked)
                    TextButton(
                      onPressed: (_purchasePending || _restoring) ? null : _restorePurchases,
                      child: const Text("Restore Purchases",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  if (_appStoreMode && (_purchasePending || _restoring))
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8),
                      child: Row(children: [
                        const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text(_restoring ? "Restoring purchases…" : "Waiting for the App Store…",
                            style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ]),
                    ),
                  Expanded(child: SizedBox.shrink()),
                  if (!kIsWeb&&(Platform.isWindows||Platform.isLinux||Platform.isMacOS))
                  Tooltip(
                      message: 'Exit Game', // The visual text hint that pops up
                      child:GestureDetector(
                        onTap: () {
                          exit(0);
                        },

                        child: Image.asset(
                          'icons/close.png',
                          width: 28,
                          height: 28,
                        ),
                      )
                  ),
                ])):SizedBox.shrink(),

            Expanded(child:SizedBox.shrink()),
            //(0xfffffd6d)
            Row(
              children:[
               // Expanded(flex:1,child:SizedBox.shrink()),
                Expanded(flex:7,child: Container(

                decoration: BoxDecoration(
                  border: Border.all(width: 1 ,color: Colors.transparent), //color is transparent so that it does not blend with the actual color specified
                  borderRadius: const BorderRadius.all(const Radius.circular(30.0)),
                  gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.5),//Color(0xFF3366FF),
                        Colors.yellow,//Color(0xFF00CCFF),
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(0.5, 0.5),
                      stops: [0.0, 1],
                      //   tileMode: TileMode.clamp),
                      tileMode: TileMode.mirror),

                ),

                child: Padding(padding:EdgeInsets.only(left:20,top:20,right:20,bottom:10),
                    child: Column(
                        children:[

                      // Shrinks the row of 5 cards to fit narrow screens (eg a
                      // phone in landscape). scaleDown never enlarges, so on
                      // desktop, where they already fit, nothing changes.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          final isIncoming = child.key == ValueKey(gametab);
                          final dir = isIncoming ? _slideDirection : -_slideDirection;
                          return SlideTransition(
                            position: Tween<Offset>(begin: Offset(dir, 0), end: Offset.zero)
                                .animate(animation),
                            child: child,
                          );
                        },
                        child: gametab==GameTabs.journey
                        ? Row(
                        key: const ValueKey(GameTabs.journey),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        JourneyCard(
                          title: "Pilgrimage to the Temple",
                          description:
                          "From your home in bethphage on the Mount of Olives, travel to the Second Temple to witness the Tamid",
                          imagePath: "icons/bethphage.jpg",
                          inprogress:gamestates[GameStart.bethphage]!=null,
                          buttonLabel: "bethphage",//+gamestates[GameStart.bethphage].toString(),
                          onPressed: () => start(gamestart: GameStart.bethphage),
                          onRestart: () {
                            // TODO: clear the saved progress for this journey
                            // here (however OPENWORLD.Persistence exposes a
                            // delete/reset call) before starting fresh, e.g.
                            // OPENWORLD.Persistence.remove(GameStart.womensgate.toString());
                            start(gamestart: GameStart.bethphage, restart:true);
                          },
                        ),
                        const SizedBox(width: 40),
                        JourneyCard(
                          title: "Your Lower city home",
                          description:
                          "Wake up at your family home in the lower city of Jerusalem and you and your husband get ready for the busy day ahead at your shop.",
                          imagePath: "icons/lowercity.jpg",
                          inprogress: gamestates[GameStart.lowercity]!=null,
                          buttonLabel: "Lower City",//+gamestates[GameStart.lowercity][gamestates[GameStart.lowercity].length-1],//gamestates[GameStart.lowercity]!=null?gamestates[GameStart.lowercity][0]:'',
                          onPressed: () => start(gamestart: GameStart.lowercity),
                          onRestart: () {
                            // TODO: clear the saved progress for this journey
                            // here (however OPENWORLD.Persistence exposes a
                            // delete/reset call) before starting fresh, e.g.
                            // OPENWORLD.Persistence.remove(GameStart.womensgate.toString());
                            start(gamestart: GameStart.lowercity, restart:true);
                          },
                        ),
                        const SizedBox(width: 40),
                        JourneyCard(
                          title: "Day as a priest",
                          description:
                          "Wake up in the Chamber of the Hearth at the Second Temple and perform your duties.",
                          imagePath: "icons/hearth.jpg",
                          inprogress: gamestates[GameStart.hearth]!=null,
                          buttonLabel: "Hearth",//+gamestates[GameStart.hearth].toString(),
                          locked: _journeyLocked,
                          lockedNote: _androidLocked
                              ? _androidLockedText
                              : "Available in the full game.",
                          onPressed: () => _journeyLocked
                              ? _showFullGameDialog("Day as a priest")
                              : start(gamestart: GameStart.hearth),
                          onRestart: () {
                            // TODO: clear the saved progress for this journey
                            // here (however OPENWORLD.Persistence exposes a
                            // delete/reset call) before starting fresh, e.g.
                            // OPENWORLD.Persistence.remove(GameStart.womensgate.toString());
                            start(gamestart: GameStart.hearth, restart:true);
                          },
                        ),
                        const SizedBox(width: 40),
                        JourneyCard(
                          title: "Pilgrimage from Jericho",
                          description:
                          "You go on a pilgrimage to the Second Temple for purification after giving birth. You are travelling from the north from Jericho. "
                              "Bathe at the pool of bethesda, go through the Royal Stoa and get your offering. Then make your way to the "
                              "Court of Women to sacrifice your offering",
                          imagePath: "icons/womensgate.jpg",
                          // Swap this for a real check against your saved
                          // state, e.g. gamestates[GameStart.womensgate] != null
                          inprogress: gamestates[GameStart.womensgate]!=null,
                          buttonLabel: "Womens Gate",//+gamestates[GameStart.womensgate].toString(),
                          onPressed: () => start(gamestart: GameStart.womensgate),
                          onRestart: () {
                            // TODO: clear the saved progress for this journey
                            // here (however OPENWORLD.Persistence exposes a
                            // delete/reset call) before starting fresh, e.g.
                            // OPENWORLD.Persistence.remove(GameStart.womensgate.toString());
                            start(gamestart: GameStart.womensgate, restart:true);
                          },
                        ),
                        const SizedBox(width: 40),
                        JourneyCard(
                          title: "Ceremonies  →",
                          description: "Take part in ceremonies at the Temple",
                          imagePath: "icons/ketoret.jpg",
                          buttonLabel: "Explore Temple Ceremonies →",
                          onPressed: () {
                            _goToTab(GameTabs.roam1);
                          },//=> start(gamestart: GameStart.roam),
                        ),
                      ],
                    )
                        : gametab==GameTabs.roam1
                        ? Row(
                            key: const ValueKey(GameTabs.roam1),
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              JourneyCard(
                                title: "← Back to Journeys",
                                description:
                                "Go back to choosing a journey",
                                imagePath: "icons/journeys.jpg",
                                buttonLabel: "← Journeys",
                                onPressed: () {
                                   // showroam=false;
                                    _goToTab(GameTabs.journey);
                                },
                              ),
                              const SizedBox(width: 40),
                              JourneyCard(
                                title: "Watch the Tamid",
                                description:
                                "Go to the Second Temple and watch the Tamid which was for the atonement of the nation of Israel before God",
                                imagePath: "icons/hearth4.jpg",
                                buttonLabel: "Tamid",
                                onPressed: () => start(gamestart: GameStart.roam,progress:'tamid'),
                              ),
                              const SizedBox(width: 40),
                              JourneyCard(
                                title: "ketoret",
                                description:
                                "Go inside the Sanctuary watch the ketoret where an incense offering was made",
                                imagePath: "icons/ketoret.jpg",
                                buttonLabel: "ketoret",
                                locked: _journeyLocked,
                                lockedNote: _androidLocked
                                    ? _androidLockedText
                                    : "Available in the full game.",
                                onPressed: () => _journeyLocked
                                    ? _showFullGameDialog("Ketoret")
                                    : start(gamestart: GameStart.roam,progress:'ketoret'),
                              ),
                              const SizedBox(width: 40),
                              JourneyCard(
                                title: "Sukkot",
                                description:
                                "Visit the court of women for Sukkot, where they lit the four lamps at night lighting up the whole of Jerusalem",
                                imagePath: "icons/sukkot.jpg",
                                buttonLabel: "Sukkot",
                                onPressed: () => start(gamestart: GameStart.roam,progress:'sukkot'),
                              ),
                              const SizedBox(width: 40),
                              JourneyCard(
                                title: "More Roaming  →",
                                description: "Take a quick trip to even more parts of Jerusalem",
                                imagePath: "icons/roam.jpg",
                                buttonLabel: "More places to roam Jerusalem →",
                                onPressed: () {
                                    //showroam=true;
                                    _goToTab(GameTabs.roam2);
                                },//=> start(gamestart: GameStart.roam),
                              ),

                            ],
                          )
                        : Row(
                          key: const ValueKey(GameTabs.roam2),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            JourneyCard(
                                title: "← Back to journeys",
                                description:
                                "Go back to choosing a journey",
                                imagePath: "icons/journeys.jpg",
                                buttonLabel: "← Journeys",
                                onPressed: () {
                                    _goToTab(GameTabs.journey);
                                },
                              ),

                            const SizedBox(width: 40),
                            JourneyCard(
                              title: "Pool of Siloam",
                              description:
                              "Go to the Pool of Siloam",
                              imagePath: "icons/siloam.jpg",
                              buttonLabel: "Siloam",
                              onPressed: () => start(gamestart: GameStart.roam,progress:'siloam'),
                            ),
                            const SizedBox(width: 40),

                            JourneyCard(
                              title: "Western Wall",
                              description:
                              "Go to the Western Wall. See the shops and throngs of people",
                              imagePath: "icons/westernwall.jpg",
                              buttonLabel: "Western wall",
                              onPressed: () => start(gamestart: GameStart.roam,progress:'westernwall'),
                            ),
                            const SizedBox(width: 40),
                            JourneyCard(
                              title: "bethesda",
                              description:
                              "Go to the pool of bethesda",
                              imagePath: "icons/bethesda.jpg",
                              buttonLabel: "Pool of bethesda",
                              onPressed: () => start(gamestart: GameStart.roam,progress:'bethesda'),
                            ),
                            const SizedBox(width: 40),
                            JourneyCard(
                              title: "Royal Stoa",
                              description:
                              "Go to the grand Royal Stoa.",
                              imagePath: "icons/womensgate4.jpg",
                              buttonLabel: "Royal Stoa",
                              onPressed: () => start(gamestart: GameStart.roam,progress:'stoa'),
                            ),

                          ],
                        ),
                      ), // closes AnimatedSwitcher's child ternary and the AnimatedSwitcher itself
                      ), // closes FittedBox

                         SizedBox(height:10),

                        ])))),
            //    Expanded(flex:1,child:SizedBox.shrink()),
              ]),

          ],
        )),

      // Loading overlay shown as soon as a journey is tapped
      if (_starting)
        Positioned.fill(
          child: AbsorbPointer(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xffe0b24a),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text((_continue?"Continue ":"Starting")+ " journey…",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    //  ),
    )
    );
  }
}



