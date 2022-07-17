
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations returned
/// by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru')
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'Eds Test App'**
  String get appName;

  /// No description provided for @listOfUsers.
  ///
  /// In ru, this message translates to:
  /// **'Список пользователей'**
  String get listOfUsers;

  /// No description provided for @listOfUsersError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить список пользователей'**
  String get listOfUsersError;

  /// No description provided for @userInfoError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить информацию о пользователе'**
  String get userInfoError;

  /// No description provided for @fullName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get address;

  /// No description provided for @site.
  ///
  /// In ru, this message translates to:
  /// **'Сайт'**
  String get site;

  /// No description provided for @company.
  ///
  /// In ru, this message translates to:
  /// **'Компания'**
  String get company;

  /// No description provided for @companyName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get companyName;

  /// No description provided for @bs.
  ///
  /// In ru, this message translates to:
  /// **'Bs'**
  String get bs;

  /// No description provided for @catchPhrase.
  ///
  /// In ru, this message translates to:
  /// **'Крылатая фраза'**
  String get catchPhrase;

  /// No description provided for @album.
  ///
  /// In ru, this message translates to:
  /// **'Альбом'**
  String get album;

  /// No description provided for @albumInfoError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить информацию альбома'**
  String get albumInfoError;

  /// No description provided for @albums.
  ///
  /// In ru, this message translates to:
  /// **'Альбомы'**
  String get albums;

  /// No description provided for @viewAll.
  ///
  /// In ru, this message translates to:
  /// **'Посмотреть все'**
  String get viewAll;

  /// No description provided for @posts.
  ///
  /// In ru, this message translates to:
  /// **'Посты'**
  String get posts;

  /// No description provided for @albumsList.
  ///
  /// In ru, this message translates to:
  /// **'Список альомов'**
  String get albumsList;

  /// No description provided for @albumsListError.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка загрузки альбомов'**
  String get albumsListError;

  /// No description provided for @image.
  ///
  /// In ru, this message translates to:
  /// **'Изображение'**
  String get image;

  /// No description provided for @imageLoadingError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить изображение'**
  String get imageLoadingError;

  /// No description provided for @description.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get description;

  /// No description provided for @postsList.
  ///
  /// In ru, this message translates to:
  /// **'Список постов'**
  String get postsList;

  /// No description provided for @postsListError.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка загрузки постов'**
  String get postsListError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
