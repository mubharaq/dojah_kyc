import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dojah_kyc/dojah_kyc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
        enableDrag: isDismissible,
        context: context,
        isScrollControlled: true,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: context.screenHeight(.9),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Center(
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
          ],
        ),
      );

  @override
  State<DojahKyc> createState() => _DojahKycState();
}

class _DojahKycState extends State<DojahKyc> {
  InAppWebViewController? _controller;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      clearCache: true,
      useShouldOverrideUrlLoading: true,
      supportZoom: false,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );
  bool isLoading = true;

  bool _hasError = false;
  bool get hasError => _hasError;
  set hasError(bool val) {
    _hasError = val;
    if (mounted) setState(() {});
  }

  int loadingPercent = 0;

  @override
  void initState() {
    super.initState();
    _handleInit();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConnectivityResult>(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        /// Show error view
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
            if (snapshot.hasData == true &&
                snapshot.data != ConnectivityResult.none) ...[
              const CupertinoActivityIndicator(
                radius: 20,
              ),
            ],
            InAppWebView(
              initialOptions: options,
              initialData: InAppWebViewInitialData(
                baseUrl: Uri.parse('https://widget.dojah.io'),
                androidHistoryUrl: Uri.parse('https://widget.dojah.io'),
                data: DojahFunctions.createWidgetHtml(
                  widget.config,
                ),
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
              onLoadStop: (controller, url) => setState(() {
                isLoading = false;
                loadingPercent = 100;
              }),
              onLoadError: (controller, url, code, message) {
                // Handle page loading errors
                _hasError = true;
                DojahLogger.e('Load Error: $message');
              },
              onProgressChanged: (controller, v) => setState(() {
                loadingPercent = v;
                if (loadingPercent == 100) {
                  isLoading = false;
                }
              }),
              onLoadHttpError: (controller, url, statusCode, description) {
                // Capture http error;
                DojahLogger.e('Http Error: $description');
              },
              onConsoleMessage: (controller, consoleMessage) {
                // Capture console messages
                DojahLogger.e('Console error: ${consoleMessage.message}');
              },
              onLoadStart: (controller, url) => setState(() {
                isLoading = true;
              }),
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Handle Logger initialization
  Future<void> _handleInit() async {
    DojahLogger.showLogs = widget.showLogs;
  }
}
