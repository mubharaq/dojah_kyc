import 'dart:convert';

import 'package:dojah_kyc/dojah_kyc.dart';

///
class DojahFunctions {
  /// webview data
  static String createWidgetHtml(
    DojahConfig config,
  ) =>
      '''
      <html lang="en">
                        <head>
                            <meta charset="UTF-8">
                                <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, shrink-to-fit=1"/>

                            <title>Dojah Inc.</title>
                        </head>
                        <body>

                        <script src="https://widget.dojah.io/widget.js"></script>
                        <script>
                                  const options = {
                                      app_id: "${config.appId}",
                                      p_key: "${config.publicKey}",
                                      type: "${config.type}",
                                      config: ${json.encode(config.configData)},
                                      user_data: ${json.encode(
        config.userData ?? {},
      )},
                                      gov_data: ${json.encode(config.govtData ?? {})},
                                      metadata: ${json.encode(config.metaData ?? {})},
                                      reference_id: "${config.referenceId}",
                                      onSuccess: function (response) {
                                      window.flutter_inappwebview.callHandler('onSuccessCallback', response)
                                      },
                                      onError: function (err) {
                                        window.flutter_inappwebview.callHandler('onErrorCallback', err)
                                      },
                                      onClose: function () {
                                        window.flutter_inappwebview.callHandler('onCloseCallback', 'close')
                                      }
                                  }
                                    const connect = new Connect(options);
                                    connect.setup();
                                    connect.open();
                              </script>
                        </body>
                      </html>
                      ''';
}
