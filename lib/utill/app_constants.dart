

import 'package:local_govt_mw/common/enums/local_caches_types_enum.dart';
import 'package:local_govt_mw/localisation/models/lauguage_model.dart';
import 'package:local_govt_mw/utill/images.dart';

class AppConstants {
  static const String appName = 'NAML';
  static const String slogan = 'A Member of the NICO group';
  static const String appVersion = '1.0'; ///Flutter SDK 3.35.7
  static const LocalCachesTypeEnum cachesType = LocalCachesTypeEnum.all;

  static const String baseUrl = 'https://nico-customerportal.com:8082';

  static const String googleServerClientId = 'client_id here';
  static const String userId = 'userId';

  static const String name = 'name';


  // status
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String processing = 'processing';
  static const String processed = 'processed';
  static const String delivered = 'delivered';
  static const String failed = 'failed';
  static const String returned = 'returned';
  static const String cancelled = 'canceled';
  static const String maintenanceModeTopic = 'maintenance_mode_start_user_app';
  static const String countryCode = 'country_code';
  static const String languageCode = 'language_code';
  static const String theme = 'theme';





  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.en, languageName: 'English', countryCode: 'US', languageCode: 'en'),
  ];


  static const reviewList = ['very_bad', 'bad', 'good', 'very_good', 'best'];


  static const double maxSizeOfASingleFile = 10;
  static const double maxLimitOfTotalFileSent = 5;
  static const double maxLimitOfFileSentINConversation = 25;
  static const double fileImageMaxLimit = 2;

  static const List<String> filterTypeList = ['all', 'debit', 'credit'];


  static const List<String> videoExtensions = [
    'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mpeg', 'mpg', 'm4v', '3gp', 'ogv'
  ];

  static const List<String> imageExtensions = [
    'jpg', 'jpeg', 'jpe', 'jif', 'jfif', 'jfi', 'png', 'gif', 'webp', 'tiff', 'tif', 'bmp', 'svg',
  ];

  static const List<String> documentExtensions = [
    'doc', 'docx', 'txt', 'csv', 'xls', 'xlsx', 'rar', 'tar', 'targz', 'zip', 'pdf',
  ];



}
