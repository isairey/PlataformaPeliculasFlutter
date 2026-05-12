import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:adblocker_webview/adblocker_webview.dart';
import '../utils/adblock_checker.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import '../models/movie.dart';
import '../core/constants/constants.dart';
import '../core/streaming/streaming_servers.dart';
import '../widgets/server_selector_sheet.dart';
import '../providers/adblocker.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  final int season;
  final int episode;
  final StreamingServer initialServer;

  const PlayerScreen({
    super.key,
    required this.movie,
    this.season = 1,
    this.episode = 1,
    this.initialServer = StreamingServer.videasy,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  static const _pipChannel = MethodChannel('com.moviesync/pip');

  late StreamingServer _currentServer;
  int _webViewKey = 0;

  bool _isLoading = true;
  bool _hasError = false;
  bool _isLandscapeLocked = false;
  bool _isInPip = false;
  bool _isPipSupported = false;
  bool _controlsVisible = true;
  final _adblockerController = AdBlockerWebviewController.instance;

  double _brightness = 0.5;
  double _volume = 0.5;
  bool _showBrightnessIndicator = false;
  bool _showVolumeIndicator = false;
  IconData _indicatorIcon = Icons.brightness_6;
  double _indicatorValue = 0.5;

  @override
  void initState() {
    super.initState();
    _currentServer = widget.initialServer;
    WidgetsBinding.instance.addObserver(this);
    _initOrientation();

    checkAdblockerStatus().then((detected) {
      if (detected) debugPrint("Adblock detected!");
    });
    _checkPipSupport();
    _setupPipListener();
    _initVolumeAndBrightness();
  }

  Future<void> _initVolumeAndBrightness() async {
    try {
      _brightness = await ScreenBrightness().application;
      _volume = await VolumeController.instance.getVolume();
      VolumeController.instance.addListener((v) {
        if (mounted) setState(() => _volume = v);
      });
    } catch (_) {}
  }

  void _initOrientation() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _checkPipSupport() async {
    try {
      final v = await _pipChannel.invokeMethod<bool>('isPipSupported');
      if (mounted) setState(() => _isPipSupported = v ?? false);
    } catch (_) {}
  }

  void _setupPipListener() {
    _pipChannel.setMethodCallHandler((call) async {
      if (call.method == 'pipChanged' && mounted) {
        setState(() => _isInPip = call.arguments as bool);
      }
    });
  }

  Future<void> _enterPip() async {
    try {
      await _pipChannel.invokeMethod('enterPip');
    } catch (_) {}
  }

  void _toggleOrientationLock() {
    setState(() => _isLandscapeLocked = !_isLandscapeLocked);
    SystemChrome.setPreferredOrientations(
      _isLandscapeLocked
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
    );
  }

  Future<void> _switchServer() async {
    final result = await ServerSelectorSheet.show(context, _currentServer);
    if (result == null || result == _currentServer || !mounted) return;
    setState(() {
      _currentServer = result;
      _isLoading = true;
      _hasError = false;
      _webViewKey++;
    });
  }

  void _retryLoad() {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _webViewKey++;
    });
  }

  String _buildUrl() {
    return StreamingServers.buildUrl(
      _currentServer,
      widget.movie.id,
      widget.movie.mediaType,
      season: widget.season,
      episode: widget.episode,
    );
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Widget _buildLoadingOverlay() {
    final poster = widget.movie.posterPath != null
        ? '${ApiConstants.imageBaseUrl}${widget.movie.posterPath}'
        : null;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (poster != null)
          CachedNetworkImage(
              imageUrl: poster,
              fit: BoxFit.cover,
              errorWidget: (c, e, s) => Container(color: Colors.grey[900]))
        else
          Container(color: Colors.grey[900]),
        Container(color: Colors.black.withValues(alpha: 0.75)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (poster != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                      imageUrl: poster, width: 100, height: 150, fit: BoxFit.cover),
                ),
              const SizedBox(height: 20),
              Text(
                widget.movie.title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (widget.movie.mediaType == 'tv')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'S${widget.season} · E${widget.episode}',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 20),
              const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(color: Colors.red, strokeWidth: 3)),
              const SizedBox(height: 10),
              Text(
                'Loading ${StreamingServers.getInfo(_currentServer).name}...',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 12),
            const Text('Failed to load', style: TextStyle(color: Colors.white, fontSize: 17)),
            const SizedBox(height: 4),
            const Text('Try a different server',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: _retryLoad,
                    child: const Text('Retry', style: TextStyle(color: Colors.red))),
                const SizedBox(width: 16),
                ElevatedButton(
                    onPressed: _switchServer,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Switch Server')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final serverInfo = StreamingServers.getInfo(_currentServer);
    return AnimatedOpacity(
      opacity: _controlsVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      widget.movie.mediaType == 'tv'
                          ? '${widget.movie.title} · S${widget.season} E${widget.episode}'
                          : widget.movie.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: _controlsVisible ? _switchServer : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: serverInfo.badgeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: serverInfo.badgeColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(serverInfo.icon, color: serverInfo.badgeColor, size: 14),
                          const SizedBox(width: 4),
                          Text(serverInfo.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  if (_isPipSupported)
                    IconButton(
                      icon: const Icon(Icons.picture_in_picture_alt,
                          color: Colors.white, size: 22),
                      onPressed: _enterPip,
                    ),
                  IconButton(
                    icon: Icon(
                      _isLandscapeLocked
                          ? Icons.screen_lock_landscape
                          : Icons.screen_rotation,
                      color: _isLandscapeLocked ? Colors.red : Colors.white,
                      size: 22,
                    ),
                    onPressed: _toggleOrientationLock,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateBrightness(double dy) {
    setState(() {
      _brightness -= dy * 0.01;
      _brightness = _brightness.clamp(0.0, 1.0);
      _showBrightnessIndicator = true;
      _showVolumeIndicator = false;
      _indicatorIcon = _brightness > 0.5 ? Icons.brightness_7 : Icons.brightness_low;
      _indicatorValue = _brightness;
    });
    ScreenBrightness().setApplicationScreenBrightness(_brightness);
    _hideIndicatorAfterDelay();
  }

  void _updateVolume(double dy) {
    setState(() {
      _volume -= dy * 0.01;
      _volume = _volume.clamp(0.0, 1.0);
      _showVolumeIndicator = true;
      _showBrightnessIndicator = false;
      _indicatorIcon = _volume > 0.5 ? Icons.volume_up : (_volume > 0 ? Icons.volume_down : Icons.volume_off);
      _indicatorValue = _volume;
    });
    VolumeController.instance.setVolume(_volume);
    _hideIndicatorAfterDelay();
  }

  void _hideIndicatorAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showBrightnessIndicator = false;
          _showVolumeIndicator = false;
        });
      }
    });
  }

  Widget _buildGestureControls() {
    return Stack(
      children: [
        Positioned(
          left: 0, top: 40, bottom: 40, width: 80,
          child: GestureDetector(
            onVerticalDragUpdate: (d) => _updateBrightness(d.delta.dy),
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          right: 0, top: 40, bottom: 40, width: 80,
          child: GestureDetector(
            onVerticalDragUpdate: (d) => _updateVolume(d.delta.dy),
            child: Container(color: Colors.transparent),
          ),
        ),
        if (_showBrightnessIndicator || _showVolumeIndicator)
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_indicatorIcon, color: Colors.white, size: 36),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: _indicatorValue,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInPip) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: AdBlockerWebview(
          key: ValueKey(_webViewKey),
          url: Uri.parse(_buildUrl()),
          shouldBlockAds: _currentServer != StreamingServer.videasy && _currentServer != StreamingServer.movies111,
          userAgent: StreamingServers.getInfo(_currentServer).headers['User-Agent'],
          adBlockerWebviewController: _adblockerController,
          onLoadStart: (url) {
            if (_currentServer != StreamingServer.videasy && _currentServer != StreamingServer.movies111) {
              _adblockerController.runScript(AdBlocker.earlyJsInjection);
            }
          },
          onLoadFinished: (url) {
            if (_currentServer != StreamingServer.videasy && _currentServer != StreamingServer.movies111) {
              _adblockerController.runScript(AdBlocker.domCleanerJs);
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _controlsVisible = !_controlsVisible),
        child: Stack(
          children: [
            AdBlockerWebview(
              key: ValueKey(_webViewKey),
              url: Uri.parse(_buildUrl()),
              shouldBlockAds: _currentServer != StreamingServer.videasy && _currentServer != StreamingServer.movies111,
              userAgent: StreamingServers.getInfo(_currentServer).headers['User-Agent'],
              adBlockerWebviewController: _adblockerController,
              onLoadStart: (url) {
                if (_currentServer != StreamingServer.videasy && _currentServer != StreamingServer.movies111) {
                  _adblockerController.runScript(AdBlocker.earlyJsInjection);
                }
                if (url.toString().contains(StreamingServers.getInfo(_currentServer).embedHost)) {
                  if (mounted) setState(() { _isLoading = true; _hasError = false; });
                }
              },
              onLoadFinished: (url) {
                if (_currentServer != StreamingServer.videasy && _currentServer != StreamingServer.movies111) {
                  _adblockerController.runScript(AdBlocker.domCleanerJs);
                }
                if (url.toString().contains(StreamingServers.getInfo(_currentServer).embedHost)) {
                  if (mounted) setState(() => _isLoading = false);
                } else if (mounted) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) setState(() => _isLoading = false);
                  });
                }
              },
              onLoadError: (url, code) {
         
                if (url != null && url.toString().startsWith(_buildUrl())) {
                  if (mounted) setState(() { _isLoading = false; _hasError = true; });
                }
              },
            ),

            if (_isLoading) _buildLoadingOverlay(),
            if (_hasError) _buildErrorOverlay(),

            _buildGestureControls(),
            _buildControls(),
          ],
        ),
      ),
    );
  }
}
