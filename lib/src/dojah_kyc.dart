import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dojah_kyc/dojah_kyc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

///Dojah KYC WebView
class DojahKyc extends StatefulWidget {
  ///
  const DojahKyc({
    required this.config,
    required this.onSuccess,
    required this.onClosed,
    required this.onError,
    super.key,
    this.errorWidget,
    this.showLogs = false,
    this.isDismissible = true,
  });

  /// config data for four kyc process
  final DojahConfig config;

  /// Success callback
  final ValueChanged<dynamic> onSuccess;

  /// Error callback
  final ValueChanged<dynamic> onError;

  /// Popup Close callback
  final VoidCallback onClosed;

  /// Error Widget
  final Widget? errorWidget;

  /// Show [DojahKyc] Logs
  final bool showLogs;

  /// Toggle dismissible mode
  final bool isDismissible;

  /// Show Dialog with a custom child
  Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        isDismissible: isDismissible,
        enableDrag: false,
        useSafeArea: true,
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxHeight: context.screenHeight(.8),
        ),
        builder: (context) => Scaffold(
          resizeToAvoidBottomInset: true,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DojahKyc(
                config: config,
                onClosed: onClosed,
                onSuccess: onSuccess,
                onError: onError,
                showLogs: showLogs,
                errorWidget: errorWidget,
              ),
            ),
          ),
        ),
      );

  @override
  State<DojahKyc> createState() => _DojahKycState();
}

class _DojahKycState extends State<DojahKyc> {
  InAppWebViewController? _controller;
  InAppWebViewSettings options = InAppWebViewSettings(
    clearCache: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    useShouldOverrideUrlLoading: true,
    transparentBackground: true,
    javaScriptCanOpenWindowsAutomatically: true,
    cacheEnabled: false,
    allowsBackForwardNavigationGestures: false,
  );
  bool isLoading = true;

  bool _hasError = false;
  bool get hasError => _hasError;
  set hasError(bool val) {
    _hasError = val;
    if (mounted) setState(() {});
  }

  bool isGranted = false;
  int loadingPercent = 0;
  Future<void> initPermissions() async {
    await Permission.camera.request().then((value) {
      if (value.isPermanentlyDenied) {
        openAppSettings();
      }
    });
    if (await Permission.camera.request().isGranted) {
      setState(() {
        isGranted = true;
      });
    } else {
      Permission.camera.onDeniedCallback(() {
        Permission.camera.request();
      });
    }
  }

  void reloadWebView() {
    if (_controller != null) {
      setState(() {
        isLoading = true;
      });

      _controller?.loadData(
        data: DojahFunctions.createWidgetHtml(widget.config),
        baseUrl: WebUri.uri(Uri.parse('https://widget.dojah.io')),
        historyUrl: WebUri.uri(Uri.parse('https://widget.dojah.io')),
      );
    }
  }

  /// Handle Logger initialization
  Future<void> _handleInit() async {
    DojahLogger.showLogs = widget.showLogs;
    await initPermissions();
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && isLoading) {
        DojahLogger.e('Widget appears stuck, attempting reload');
        reloadWebView();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _handleInit();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConnectivityResult>>(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        final noConnection =
            snapshot.data?.contains(ConnectivityResult.none) ?? false;
        if (hasError == true) {
          return Center(
            child:
                widget.errorWidget ?? const Text('An unknown error occurred'),
          );
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            if (isLoading == true) ...[
              const CupertinoActivityIndicator(),
            ],
            if (snapshot.hasData == true && noConnection) ...[
              const CupertinoActivityIndicator(
                radius: 20,
              ),
            ],
            if (isGranted)
              InAppWebView(
                initialSettings: options,
                initialData: InAppWebViewInitialData(
                  baseUrl: WebUri.uri(Uri.parse('https://widget.dojah.io')),
                  historyUrl: WebUri.uri(Uri.parse('https://widget.dojah.io')),
                  data: DojahFunctions.createWidgetHtml(widget.config),
                ),
                onWebViewCreated: (controller) {
                  _controller = controller;
                  _controller?.addJavaScriptHandler(
                    handlerName: 'onSuccessCallback',
                    callback: (response) {
                      widget.onSuccess(response);
                    },
                  );
                  _controller?.addJavaScriptHandler(
                    handlerName: 'onCloseCallback',
                    callback: (response) {
                      widget.onClosed();
                    },
                  );
                  _controller?.addJavaScriptHandler(
                    handlerName: 'onErrorCallback',
                    callback: (error) {
                      widget.onError(error);
                    },
                  );
                },
                onLoadStop: (_, __) => setState(() {
                  isLoading = false;
                  loadingPercent = 100;
                }),
                onReceivedError: (_, __, code) {
                  _hasError = true;
                  DojahLogger.e('Load Error: $code');
                },
                onProgressChanged: (_, v) => setState(() {
                  loadingPercent = v;
                  if (loadingPercent == 100) {
                    isLoading = false;
                  }
                }),
                onReceivedHttpError: (_, __, statusCode) {
                  DojahLogger.e('Http Error: $statusCode');
                },
                onConsoleMessage: (_, consoleMessage) {
                  DojahLogger.e('Console error: ${consoleMessage.message}');
                },
                onLoadStart: (_, __) => setState(() {
                  isLoading = true;
                }),
                onGeolocationPermissionsShowPrompt: (_, origin) async {
                  return GeolocationPermissionShowPromptResponse(
                    allow: true,
                    origin: origin,
                    retain: true,
                  );
                },
                shouldOverrideUrlLoading: (controller, action) async {
                  return NavigationActionPolicy.ALLOW;
                },
                onPermissionRequest: (_, request) async {
                  DojahLogger.e('Permission requested: ${request.resources}');
                  if (Platform.isAndroid) {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  } else {
                    if (request.resources
                            .contains(PermissionResourceType.CAMERA) &&
                        !isGranted) {
                      final status = await Permission.camera.request();
                      setState(() {
                        isGranted = status.isGranted;
                      });
                    }

                    return PermissionResponse(
                      resources: request.resources,
                      action: isGranted
                          ? PermissionResponseAction.GRANT
                          : PermissionResponseAction.DENY,
                    );
                  }
                },
              )
            else
              const CupertinoActivityIndicator(
                radius: 20,
              ),
          ],
        );
      },
    );
  }
}
