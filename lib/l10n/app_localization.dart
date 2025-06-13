import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localization_en.dart';
import 'app_localization_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localization.dart';
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
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te')
  ];

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @salesrep.
  ///
  /// In en, this message translates to:
  /// **'Sales Rep'**
  String get salesrep;

  /// No description provided for @customerform.
  ///
  /// In en, this message translates to:
  /// **'Customer Form'**
  String get customerform;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Family Head Name'**
  String get name;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @eenadunewspaper.
  ///
  /// In en, this message translates to:
  /// **'Eenadu newspaper : '**
  String get eenadunewspaper;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @feedbacktoimprovepaper.
  ///
  /// In en, this message translates to:
  /// **'Feedback to improve Eenadu paper'**
  String get feedbacktoimprovepaper;

  /// No description provided for @pleaseenterfeedback.
  ///
  /// In en, this message translates to:
  /// **'Please enter a short feedback'**
  String get pleaseenterfeedback;

  /// No description provided for @readnewspaper.
  ///
  /// In en, this message translates to:
  /// **' Read Newspaper : '**
  String get readnewspaper;

  /// No description provided for @currentnewpaper.
  ///
  /// In en, this message translates to:
  /// **'Current Newspaper'**
  String get currentnewpaper;

  /// No description provided for @pleaseprovidecurrentnewspaper.
  ///
  /// In en, this message translates to:
  /// **'Please provide current Newspaper name'**
  String get pleaseprovidecurrentnewspaper;

  /// No description provided for @reasonfornottakingeenadunewspaper.
  ///
  /// In en, this message translates to:
  /// **'Reason for not taking Eenadu Newspaper'**
  String get reasonfornottakingeenadunewspaper;

  /// No description provided for @reasonfornotreadingnewspaper.
  ///
  /// In en, this message translates to:
  /// **'Reason for not Reading Newspaper'**
  String get reasonfornotreadingnewspaper;

  /// No description provided for @daysforeenaduoffer.
  ///
  /// In en, this message translates to:
  /// **'15 days free Eenadu offer : '**
  String get daysforeenaduoffer;

  /// No description provided for @reasonfornottakingoffer.
  ///
  /// In en, this message translates to:
  /// **'Reason for not taking free offer'**
  String get reasonfornottakingoffer;

  /// No description provided for @employed.
  ///
  /// In en, this message translates to:
  /// **'Employed : '**
  String get employed;

  /// No description provided for @jobtype.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobtype;

  /// No description provided for @governmentjob.
  ///
  /// In en, this message translates to:
  /// **'Government Job'**
  String get governmentjob;

  /// No description provided for @privatejob.
  ///
  /// In en, this message translates to:
  /// **'Private Job'**
  String get privatejob;

  /// No description provided for @profession.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get profession;

  /// No description provided for @govtjobtype.
  ///
  /// In en, this message translates to:
  /// **'Govt Job Type'**
  String get govtjobtype;

  /// No description provided for @centraljob.
  ///
  /// In en, this message translates to:
  /// **'Central Job'**
  String get centraljob;

  /// No description provided for @statejob.
  ///
  /// In en, this message translates to:
  /// **'State Job'**
  String get statejob;

  /// No description provided for @jobprofession.
  ///
  /// In en, this message translates to:
  /// **'Job Profession'**
  String get jobprofession;

  /// No description provided for @jobdesignation.
  ///
  /// In en, this message translates to:
  /// **'Job Designation'**
  String get jobdesignation;

  /// No description provided for @companyname.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyname;

  /// No description provided for @fathersname.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name'**
  String get fathersname;

  /// No description provided for @mothername.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name'**
  String get mothername;

  /// No description provided for @spousename.
  ///
  /// In en, this message translates to:
  /// **'Spouse\'s Name'**
  String get spousename;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @mobilenumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobilenumber;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @agencyname.
  ///
  /// In en, this message translates to:
  /// **'Agency name'**
  String get agencyname;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language :'**
  String get chooseYourLanguage;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @houseNumber.
  ///
  /// In en, this message translates to:
  /// **'House Number'**
  String get houseNumber;

  /// No description provided for @streetNo.
  ///
  /// In en, this message translates to:
  /// **'Street Number'**
  String get streetNo;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'Pin Code'**
  String get pinCode;

  /// No description provided for @familyDetails.
  ///
  /// In en, this message translates to:
  /// **'Family Details'**
  String get familyDetails;

  /// No description provided for @addressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetails;

  /// No description provided for @newsPaperDetails.
  ///
  /// In en, this message translates to:
  /// **'Newspaper Details'**
  String get newsPaperDetails;

  /// No description provided for @employmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Employment Details'**
  String get employmentDetails;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Name'**
  String get pleaseEnterName;

  /// No description provided for @todaysHouseCount.
  ///
  /// In en, this message translates to:
  /// **'Today House Count'**
  String get todaysHouseCount;

  /// No description provided for @todaysTargetLeft.
  ///
  /// In en, this message translates to:
  /// **'Today Target Left'**
  String get todaysTargetLeft;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historyPage.
  ///
  /// In en, this message translates to:
  /// **'History Page'**
  String get historyPage;

  /// No description provided for @iagreeandcontinue.
  ///
  /// In en, this message translates to:
  /// **'I Agree & Continue'**
  String get iagreeandcontinue;

  /// No description provided for @i.
  ///
  /// In en, this message translates to:
  /// **'1.I '**
  String get i;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **' \',\n DOB: '**
  String get dob;

  /// No description provided for @withmobileno.
  ///
  /// In en, this message translates to:
  /// **': ,  with the Mobile no. '**
  String get withmobileno;

  /// No description provided for @herebystate.
  ///
  /// In en, this message translates to:
  /// **' ,hereby state that I have read the notice for consent issued by Eenadu  u/s 5 r/s 6(3) of DPDP Act, as I intended to subscribe to Eenadu Pellipandiri services. \n'**
  String get herebystate;

  /// No description provided for @dpdptext2.
  ///
  /// In en, this message translates to:
  /// **'2. The purpose of my subscription to Eenadui services is to search for suitable alliances for marriage. Therefore I am providing my personal data like name, father\'s name, date of birth, place of birth, religion, caste, sect, sub-sect, gothram, educational qualifications, career information, salary/income to Eenadu Pellipandiri.\n\n'**
  String get dpdptext2;

  /// No description provided for @twothreefourfive.
  ///
  /// In en, this message translates to:
  /// **'2. The purpose of my subscription to Eenadu  services is to search for suitable alliances for marriage. Therefore I am providing my personal data like name, father\'s name, date of birth, place of birth, religion, caste, sect, sub-sect, gothram, educational qualifications, career information, salary/income to Eenadu Pellipandiri.\n\n3. I hereby agree to process my personal data digitally and to display the same on the website and to share with prospective brides/grooms.\n\n4. I hereby affirm that I am giving my consent for digital processing of my personal data by Eenadu Pellipandiri out of my free will for the specified purpose of seeking alliances and I state there is neither coercion nor misrepresentation nor I was forced to give consent.\n\n5. I am hereby giving my consent by clicking on the below tab hereunder.\n\n'**
  String get twothreefourfive;

  /// No description provided for @sectiontext.
  ///
  /// In en, this message translates to:
  /// **'Under section 6 (1) 5 of DPDP (Digital Personal Data Protection) Act 2023'**
  String get sectiontext;

  /// No description provided for @ushodayapvtltd.
  ///
  /// In en, this message translates to:
  /// **'Ushodaya Enterprises Private Limited '**
  String get ushodayapvtltd;

  /// No description provided for @concentform.
  ///
  /// In en, this message translates to:
  /// **'CONSENT FORM'**
  String get concentform;

  /// No description provided for @unitManger.
  ///
  /// In en, this message translates to:
  /// **'Unit Manager'**
  String get unitManger;

  /// No description provided for @agentName.
  ///
  /// In en, this message translates to:
  /// **'Agent Name : '**
  String get agentName;

  /// No description provided for @pleaseEnterPinCodeNuber.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Pin Code Number'**
  String get pleaseEnterPinCodeNuber;

  /// No description provided for @pleaseEnterCityName.
  ///
  /// In en, this message translates to:
  /// **'Please Enter City Name'**
  String get pleaseEnterCityName;

  /// No description provided for @pleaseEnterAddressName.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Address Name'**
  String get pleaseEnterAddressName;

  /// No description provided for @pleaseEnterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Your Mobile Number'**
  String get pleaseEnterMobileNumber;

  /// No description provided for @houseVisited.
  ///
  /// In en, this message translates to:
  /// **'House\'s Visited'**
  String get houseVisited;

  /// No description provided for @targetLeft.
  ///
  /// In en, this message translates to:
  /// **'Target Left'**
  String get targetLeft;

  /// No description provided for @myRouteMap.
  ///
  /// In en, this message translates to:
  /// **'My Route Map'**
  String get myRouteMap;

  /// No description provided for @plannedDetails.
  ///
  /// In en, this message translates to:
  /// **'Planned Details'**
  String get plannedDetails;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @routeDetailsWillComeHere.
  ///
  /// In en, this message translates to:
  /// **'Route Details will come here...'**
  String get routeDetailsWillComeHere;

  /// No description provided for @plannedDetailsWillComeHere.
  ///
  /// In en, this message translates to:
  /// **'Planned Details Will Come Here...'**
  String get plannedDetailsWillComeHere;

  /// No description provided for @daysOfferAccepted15.
  ///
  /// In en, this message translates to:
  /// **'15 days offer accepted'**
  String get daysOfferAccepted15;

  /// No description provided for @daysOfferRejected15.
  ///
  /// In en, this message translates to:
  /// **'15 days offer rejected'**
  String get daysOfferRejected15;

  /// No description provided for @alreadySubscribed.
  ///
  /// In en, this message translates to:
  /// **'Already Subscribed'**
  String get alreadySubscribed;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
