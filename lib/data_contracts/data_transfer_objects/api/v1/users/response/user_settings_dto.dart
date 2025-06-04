
import 'package:dawarich/data/drift/database/sqlite_client.dart';

class UserSettingsDto {

  String immichUrl;
  String immichApiKey;
  String photoprismUrl;
  String photoprismApiKey;


  UserSettingsDto({
    required this.immichUrl,
    required this.immichApiKey,
    required this.photoprismUrl,
    required this.photoprismApiKey});

  factory UserSettingsDto.fromJson(Map<String, dynamic> json) {
    return UserSettingsDto(
      immichUrl: json["immich_url"],
      immichApiKey: json["immich_api_key"],
      photoprismUrl: json["photoprism_url"],
      photoprismApiKey: json["photoprism_api_key"]
    );
  }

  factory UserSettingsDto.fromDatabase(UserSettingsTableData userSettings) {
    return UserSettingsDto(
      immichUrl: userSettings.immichUrl,
      immichApiKey: userSettings.immichApiKey,
      photoprismUrl: userSettings.photoprismUrl,
      photoprismApiKey: userSettings.photoprismApiKey
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     "immich_url": immichUrl,
  //     "immich_api_key": immichApiKey,
  //     "photoprism_url": photoprismUrl,
  //     "photoprism_api_key": photoprismApiKey
  //   };
  // }

}