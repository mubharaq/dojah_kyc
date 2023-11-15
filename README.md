# Dojah Kyc ![Dojah-logo](https://dojah.io/_next/static/media/logo.f53bd2b5.svg)

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

Unofficial Dojah KYC widget

## Installation 💻

**❗ In order to start using Dojah Kyc you must add necessary permissions for Camera and/or Location in your AndroidManifext.xml file for Android and info.plist for iOS**

To use the widget in your Flutter project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  dojah_kyc: 0.1.0+1 # Replace with the latest version
```

Then run:

```bash
flutter pub get
```

## Usage

Import the package in your Dart file:

```dart
import 'package:dojah_kyc/dojah_kyc.dart';
```
### Example

```dart
     await DojahKyc(
            config: const DojahConfig(
            publicKey: "test_pk_xxxxxxxxxxxx",
            appId: 'xxxxxxxxxxxxxxxxxx',
            type: 'custom',
            configData: {
            'widget_id': 'xxxxxxxxxxxxxx',
            "pages": [
            {
            "page": "user-data",
            "config": {"enabled": false}
            },
            {
            "page": "government-data",
            "config": {"bvn": true, "selfie": true}
            },
            ]
            }),
            showLogs: true,
            onClosed: () {
            print('closed');
            Navigator.pop(context);
            },
            onSuccess: (v) {
            print(v.toString());
            Navigator.pop(context);
            },
            onError: (v) {
            print(v.toString());
            Navigator.pop(context);
            },
            ).show(context);
```

### Parameters

- **config (required):** An instance of `DojahConfig` containing the necessary information for the verification process. Refer to https://api-docs.dojah.io/docs/flutter-sdk for detailed reference.

- **showLogs (optional):** A boolean flag indicating whether to show logs during the verification process. Default is `false`.

- **onClosed (optional):** A callback function that gets triggered when the widget is closed.

- **onSuccess (optional):** A callback function that gets triggered when the verification is successful. It receives a dynamic parameter representing the success response.

- **onError (optional):** A callback function that gets triggered when an error occurs during the verification process. It receives an error message as a parameter.


[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[dojah_logo]: https://dojah.io/_next/static/media/logo.f53bd2b5.svg
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
