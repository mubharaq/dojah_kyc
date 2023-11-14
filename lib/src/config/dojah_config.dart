import 'dart:convert';

/// Config object passed to Dojah
class DojahConfig {
  ///
  const DojahConfig({
    required this.publicKey,
    required this.appId,
    required this.type,
    required this.configData,
    this.referenceId,
    this.userData,
    this.govtData,
    this.metaData,
  });

  /// Your public key an be found on your dashboard settings
  final String publicKey;

  /// Your app id can be found on your dashboard settings.
  final String appId;

  /// dojah verification config object
  final Map<String, dynamic> configData;

  /// values are 'custom','verification','identification','liveness'.
  final String type;

  /// referenceId character length must be greater than 10
  final String? referenceId;

  /// optional user data e.g name
  final Map<String, dynamic>? userData;

  /// optional govt data e.g bvn
  final Map<String, dynamic>? metaData;

  /// optional govt data e.g bvn
  final Map<String, dynamic>? govtData;

  ///
  bool get isProd => publicKey.contains('test') == false;

  ///
  DojahConfig copyWith({
    required Map<String, dynamic>? configData,
    String? publicKey,
    String? appId,
    String? type,
    String? referenceId,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? metaData,
    Map<String, dynamic>? govtData,
  }) {
    return DojahConfig(
      publicKey: publicKey ?? this.publicKey,
      appId: appId ?? this.appId,
      configData: configData ?? this.configData,
      type: type ?? this.type,
      userData: userData ?? this.userData,
      govtData: govtData ?? this.govtData,
      metaData: metaData ?? this.metaData,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  ///
  Map<String, dynamic> toMap() {
    return {
      'p_key': publicKey,
      'app_id': appId,
      'user_data': userData,
      'gov_data': govtData,
      'metadata': metaData,
      'reference_id': referenceId,
      'type': type,
      'config': configData,
    };
  }

  ///
  String toJson() => json.encode(toMap());
}
