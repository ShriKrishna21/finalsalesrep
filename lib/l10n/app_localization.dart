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

  /// No description provided for @familyheadname.
  ///
  /// In en, this message translates to:
  /// **'Family Head Name'**
  String get familyheadname;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
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
  /// **'Government job'**
  String get governmentjob;

  /// No description provided for @privatejob.
  ///
  /// In en, this message translates to:
  /// **'Private job'**
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
  /// **'Central job'**
  String get centraljob;

  /// No description provided for @statejob.
  ///
  /// In en, this message translates to:
  /// **'State job'**
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
  /// **'Mobile Number'**
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
  /// **'\',\\n DOB: '**
  String get dob;

  /// No description provided for @withmobileno.
  ///
  /// In en, this message translates to:
  /// **': ,  with the Mobile no. '**
  String get withmobileno;

  /// No description provided for @herebystate.
  ///
  /// In en, this message translates to:
  /// **' ,hereby state that I have read the notice for consent issued by Eenadu  u/s 5 r/s 6(3) of DPDP Act, as I intended to subscribe to Eenadu Pellipandiri services. \\n'**
  String get herebystate;

  /// No description provided for @dpdptext2.
  ///
  /// In en, this message translates to:
  /// **'2. The purpose of my subscription to Eenadui services is to search for suitable alliances for marriage. Therefore I am providing my personal data like name, father\'s name, date of birth, place of birth, religion, caste, sect, sub-sect, gothram, educational qualifications, career information, salary/income to Eenadu Pellipandiri.\\n\\n'**
  String get dpdptext2;

  /// No description provided for @twothreefourfive.
  ///
  /// In en, this message translates to:
  /// **'2. The purpose of my subscription to Eenadu  services is to search for suitable alliances for marriage. Therefore I am providing my personal data like name, father\'s name, date of birth, place of birth, religion, caste, sect, sub-sect, gothram, educational qualifications, career information, salary/income to Eenadu Pellipandiri.\\n\\n3. I hereby agree to process my personal data digitally and to display the same on the website and to share with prospective brides/grooms.\\n\\n4. I hereby affirm that I am giving my consent for digital processing of my personal data by Eenadu Pellipandiri out of my free will for the specified purpose of seeking alliances and I state there is neither coercion nor misrepresentation nor I was forced to give consent.\\n\\n5. I am hereby giving my consent by clicking on the below tab hereunder.\\n\\n'**
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

  /// No description provided for @circulationInchargeScreen.
  ///
  /// In en, this message translates to:
  /// **'Circulation Incharge Screen'**
  String get circulationInchargeScreen;

  /// No description provided for @circulationIncharge.
  ///
  /// In en, this message translates to:
  /// **'Circulation Incharge'**
  String get circulationIncharge;

  /// No description provided for @numberOfResources.
  ///
  /// In en, this message translates to:
  /// **'Number Of Resources'**
  String get numberOfResources;

  /// No description provided for @agents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agents;

  /// No description provided for @subscriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get subscriptionDetails;

  /// No description provided for @housesCount.
  ///
  /// In en, this message translates to:
  /// **'Houses Count'**
  String get housesCount;

  /// No description provided for @housesVisited.
  ///
  /// In en, this message translates to:
  /// **'Houses Visited'**
  String get housesVisited;

  /// No description provided for @eenaduSubscription.
  ///
  /// In en, this message translates to:
  /// **'Eenadu Subscription'**
  String get eenaduSubscription;

  /// No description provided for @willingToChange.
  ///
  /// In en, this message translates to:
  /// **'Willing To Change'**
  String get willingToChange;

  /// No description provided for @notInterested.
  ///
  /// In en, this message translates to:
  /// **'Not Interested'**
  String get notInterested;

  /// No description provided for @routeMap.
  ///
  /// In en, this message translates to:
  /// **'Route Map'**
  String get routeMap;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @createUser.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get createUser;

  /// No description provided for @emailOrUserId.
  ///
  /// In en, this message translates to:
  /// **'Email / User Id'**
  String get emailOrUserId;

  /// No description provided for @aadharNumber.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Number'**
  String get aadharNumber;

  /// No description provided for @uploadAadharPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Aadhar Photo'**
  String get uploadAadharPhoto;

  /// No description provided for @tapToSelectAadharImage.
  ///
  /// In en, this message translates to:
  /// **'Tap To Select Aadhar Image'**
  String get tapToSelectAadharImage;

  /// No description provided for @panNumber.
  ///
  /// In en, this message translates to:
  /// **'PAN Number'**
  String get panNumber;

  /// No description provided for @uploadPanCardPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload PAN Card Photo'**
  String get uploadPanCardPhoto;

  /// No description provided for @tapToSelectPanCardImage.
  ///
  /// In en, this message translates to:
  /// **'Tap To Select Pan Card Image'**
  String get tapToSelectPanCardImage;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @jobRole.
  ///
  /// In en, this message translates to:
  /// **'Job Role'**
  String get jobRole;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @regionalHead.
  ///
  /// In en, this message translates to:
  /// **'Regional Head   '**
  String get regionalHead;

  /// No description provided for @karimnagar.
  ///
  /// In en, this message translates to:
  /// **'KarimNagar'**
  String get karimnagar;

  /// No description provided for @unit1.
  ///
  /// In en, this message translates to:
  /// **'Unit 1'**
  String get unit1;

  /// No description provided for @unitName.
  ///
  /// In en, this message translates to:
  /// **'Unitname'**
  String get unitName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **' Password'**
  String get password;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'   Phone'**
  String get phone;

  /// No description provided for @selectrole.
  ///
  /// In en, this message translates to:
  /// **' Selectrole'**
  String get selectrole;

  /// No description provided for @userid.
  ///
  /// In en, this message translates to:
  /// **' Userid'**
  String get userid;

  /// No description provided for @taptoselectimage.
  ///
  /// In en, this message translates to:
  /// **'Tap to select image'**
  String get taptoselectimage;

  /// No description provided for @segmentincharge.
  ///
  /// In en, this message translates to:
  /// **'Segment Incharge'**
  String get segmentincharge;

  /// No description provided for @approvedagents.
  ///
  /// In en, this message translates to:
  /// **'Approved Agents'**
  String get approvedagents;

  /// No description provided for @inprogressagents.
  ///
  /// In en, this message translates to:
  /// **'In-progress Agents'**
  String get inprogressagents;

  /// No description provided for @office1staff.
  ///
  /// In en, this message translates to:
  /// **'Office1Staff'**
  String get office1staff;

  /// No description provided for @officestaffdashboard.
  ///
  /// In en, this message translates to:
  /// **'Office Staff Dashboard'**
  String get officestaffdashboard;

  /// No description provided for @viewcreatedagents.
  ///
  /// In en, this message translates to:
  /// **'ViewCreatedAgents'**
  String get viewcreatedagents;

  /// No description provided for @createagent.
  ///
  /// In en, this message translates to:
  /// **'Create Agent'**
  String get createagent;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @aadhar.
  ///
  /// In en, this message translates to:
  /// **'Aadhar'**
  String get aadhar;

  /// No description provided for @enteravalidname.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid name '**
  String get enteravalidname;

  /// No description provided for @unitnotfound.
  ///
  /// In en, this message translates to:
  /// **'Unit not found'**
  String get unitnotfound;

  /// No description provided for @entervalidphone.
  ///
  /// In en, this message translates to:
  /// **'Enter valid phone'**
  String get entervalidphone;

  /// No description provided for @entervalidemail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get entervalidemail;

  /// No description provided for @entervalidpassword.
  ///
  /// In en, this message translates to:
  /// **'Enter valid password'**
  String get entervalidpassword;

  /// No description provided for @addressCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Address can\'t be empty'**
  String get addressCantBeEmpty;

  /// No description provided for @invalidAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Invalid Aadhaar'**
  String get invalidAadhaar;

  /// No description provided for @enterpannumber.
  ///
  /// In en, this message translates to:
  /// **'Enter PAN Number'**
  String get enterpannumber;

  /// No description provided for @aadhaarmustbe12digits.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar must be 12 digits'**
  String get aadhaarmustbe12digits;

  /// No description provided for @invalidpannumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid PAN Number'**
  String get invalidpannumber;

  /// No description provided for @panmustbelikeABCDE1234F.
  ///
  /// In en, this message translates to:
  /// **'PAN Must Be Like ABCDE1234F'**
  String get panmustbelikeABCDE1234F;

  /// No description provided for @fathersnamecannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Name Cannot Be Empty'**
  String get fathersnamecannotbeempty;

  /// No description provided for @mothersnamecannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Name Cannot Be Empty'**
  String get mothersnamecannotbeempty;

  /// No description provided for @spousenamecannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Spouse Name Cannot Be Empty '**
  String get spousenamecannotbeempty;

  /// No description provided for @housenumbercannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'House Number Cannot Be Empty'**
  String get housenumbercannotbeempty;

  /// No description provided for @streetnumbercannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Street Number Cannot Be Empty'**
  String get streetnumbercannotbeempty;

  /// No description provided for @citycannotbeempty.
  ///
  /// In en, this message translates to:
  /// **' City Cannot Be Empty '**
  String get citycannotbeempty;

  /// No description provided for @pincodecannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'PinCode Cannot Be Empty'**
  String get pincodecannotbeempty;

  /// No description provided for @placecannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Place Cannot Be Empty'**
  String get placecannotbeempty;

  /// No description provided for @landmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark '**
  String get landmark;

  /// No description provided for @landmarkcannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'landMarkCannotBeEmpty'**
  String get landmarkcannotbeempty;

  /// No description provided for @mobilenumbercannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number Cannot Be Empty'**
  String get mobilenumbercannotbeempty;

  /// No description provided for @feedbackcannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Feedback Cannot Be Empty'**
  String get feedbackcannotbeempty;

  /// No description provided for @currentnewspapercannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Current Newspaper Cannot Be Empty'**
  String get currentnewspapercannotbeempty;

  /// No description provided for @reasonfornottakingcannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Reason For Not Taking Cannot Be Empty'**
  String get reasonfornottakingcannotbeempty;

  /// No description provided for @reasonfornotreadingcannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Reason For Not Reading Cannot Be Empty'**
  String get reasonfornotreadingcannotbeempty;

  /// No description provided for @fieldcannotbeempty.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be empty'**
  String get fieldcannotbeempty;

  /// No description provided for @selectdepartment.
  ///
  /// In en, this message translates to:
  /// **'Select Department'**
  String get selectdepartment;

  /// No description provided for @jobdepartment.
  ///
  /// In en, this message translates to:
  /// **'Job Department'**
  String get jobdepartment;

  /// No description provided for @psupublicsectorundertaking.
  ///
  /// In en, this message translates to:
  /// **'PSU / Public Sector Undertaking'**
  String get psupublicsectorundertaking;

  /// No description provided for @designation.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get designation;

  /// No description provided for @confirmlogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmlogout;

  /// No description provided for @logoutconfirmation.
  ///
  /// In en, this message translates to:
  /// **'logoutConfirmation'**
  String get logoutconfirmation;

  /// No description provided for @areyousureyouwanttologout.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure You Want To Logout?'**
  String get areyousureyouwanttologout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @createincharge.
  ///
  /// In en, this message translates to:
  /// **'Create Incharge'**
  String get createincharge;

  /// No description provided for @nousersfoundinthisunit.
  ///
  /// In en, this message translates to:
  /// **'No Users Found In This Unit'**
  String get nousersfoundinthisunit;

  /// No description provided for @ustomerformsofunit.
  ///
  /// In en, this message translates to:
  /// **'Customer Forms of Unit'**
  String get ustomerformsofunit;

  /// No description provided for @aadhaarnumber.
  ///
  /// In en, this message translates to:
  /// **'AadhaarNumber'**
  String get aadhaarnumber;

  /// No description provided for @invalidaadhaarnumber.
  ///
  /// In en, this message translates to:
  /// **'InvalidAadhaarNumber'**
  String get invalidaadhaarnumber;

  /// No description provided for @pleaseenteraadhaarnumber.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Aadhaar Number'**
  String get pleaseenteraadhaarnumber;

  /// No description provided for @enteravalidunitname.
  ///
  /// In en, this message translates to:
  /// **'Please Enter A Valid Unitname'**
  String get enteravalidunitname;

  /// No description provided for @enteravalidphonenumber.
  ///
  /// In en, this message translates to:
  /// **'Enter A Valid Phone Number'**
  String get enteravalidphonenumber;

  /// No description provided for @enteravalidemail.
  ///
  /// In en, this message translates to:
  /// **'Enter A Valid Email'**
  String get enteravalidemail;

  /// No description provided for @pleaseenteravalidpassword.
  ///
  /// In en, this message translates to:
  /// **'Please Enter A Valid Password'**
  String get pleaseenteravalidpassword;

  /// No description provided for @unitnamecantbeempty.
  ///
  /// In en, this message translates to:
  /// **'Unit Name Can\'t Be Empty'**
  String get unitnamecantbeempty;

  /// No description provided for @totalhistory.
  ///
  /// In en, this message translates to:
  /// **'Total History'**
  String get totalhistory;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @unitmanager.
  ///
  /// In en, this message translates to:
  /// **'UnitManager'**
  String get unitmanager;

  /// No description provided for @viewallcustomerforms.
  ///
  /// In en, this message translates to:
  /// **'ViewAllCustomerForms'**
  String get viewallcustomerforms;

  /// No description provided for @circulationhead.
  ///
  /// In en, this message translates to:
  /// **'CirculationHead'**
  String get circulationhead;

  /// No description provided for @customerforms.
  ///
  /// In en, this message translates to:
  /// **'CustomerForms'**
  String get customerforms;

  /// No description provided for @assignroutemapandtarget.
  ///
  /// In en, this message translates to:
  /// **'Assign Routemap and Target'**
  String get assignroutemapandtarget;

  /// No description provided for @createofficestaff.
  ///
  /// In en, this message translates to:
  /// **'Create Officestaff'**
  String get createofficestaff;

  /// No description provided for @agentswaitingapproval.
  ///
  /// In en, this message translates to:
  /// **'Agents Waiting Approval'**
  String get agentswaitingapproval;

  /// No description provided for @assignroutetarget.
  ///
  /// In en, this message translates to:
  /// **'Assign Route & Target'**
  String get assignroutetarget;

  /// No description provided for @selectagent.
  ///
  /// In en, this message translates to:
  /// **'SelectAgent'**
  String get selectagent;

  /// No description provided for @routeandtargetassignedsuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Route and Target assigned successfully'**
  String get routeandtargetassignedsuccessfully;

  /// No description provided for @bothassignmentsfailed.
  ///
  /// In en, this message translates to:
  /// **'Both assignments failed'**
  String get bothassignmentsfailed;

  /// No description provided for @routeassignmentfailed.
  ///
  /// In en, this message translates to:
  /// **'Route assignment failed'**
  String get routeassignmentfailed;

  /// No description provided for @targetassignmentfailed.
  ///
  /// In en, this message translates to:
  /// **'Target assignment failed'**
  String get targetassignmentfailed;

  /// No description provided for @nousersfound.
  ///
  /// In en, this message translates to:
  /// **'No Users Found'**
  String get nousersfound;

  /// No description provided for @totalagents.
  ///
  /// In en, this message translates to:
  /// **'Total Agents '**
  String get totalagents;

  /// No description provided for @filterbydate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterbydate;

  /// No description provided for @nocustomerformsavailable.
  ///
  /// In en, this message translates to:
  /// **'No Customer Forms Available'**
  String get nocustomerformsavailable;

  /// No description provided for @routemap.
  ///
  /// In en, this message translates to:
  /// **'Route Map'**
  String get routemap;

  /// No description provided for @enterroutemap.
  ///
  /// In en, this message translates to:
  /// **'Enter Route Map'**
  String get enterroutemap;

  /// No description provided for @assigntarget.
  ///
  /// In en, this message translates to:
  /// **'Assign Target'**
  String get assigntarget;

  /// No description provided for @entertarget.
  ///
  /// In en, this message translates to:
  /// **'Enter Target'**
  String get entertarget;

  /// No description provided for @pleaseenteravalidunit.
  ///
  /// In en, this message translates to:
  /// **'Please Enter A Valid Unit'**
  String get pleaseenteravalidunit;

  /// No description provided for @passwordrequired.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordrequired;

  /// No description provided for @addressrequired.
  ///
  /// In en, this message translates to:
  /// **'Address required'**
  String get addressrequired;

  /// No description provided for @unnamedagent.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Agent'**
  String get unnamedagent;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @approveagents.
  ///
  /// In en, this message translates to:
  /// **'Approve Agents'**
  String get approveagents;

  /// No description provided for @norecordsfound.
  ///
  /// In en, this message translates to:
  /// **'No Records Found'**
  String get norecordsfound;

  /// No description provided for @alldates.
  ///
  /// In en, this message translates to:
  /// **'All Dates'**
  String get alldates;

  /// No description provided for @fetchcustomerforms.
  ///
  /// In en, this message translates to:
  /// **'Fetch Customer Forms'**
  String get fetchcustomerforms;

  /// No description provided for @searchbyidorfamilyheadname.
  ///
  /// In en, this message translates to:
  /// **'Search by ID or Family Head Name'**
  String get searchbyidorfamilyheadname;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @freeoffer.
  ///
  /// In en, this message translates to:
  /// **'Free Offer'**
  String get freeoffer;

  /// No description provided for @jobWorkingstate.
  ///
  /// In en, this message translates to:
  /// **'jobWorkingState'**
  String get jobWorkingstate;

  /// No description provided for @agentlogin.
  ///
  /// In en, this message translates to:
  /// **'Agent Login'**
  String get agentlogin;

  /// No description provided for @todayhistory.
  ///
  /// In en, this message translates to:
  /// **'Today History'**
  String get todayhistory;

  /// No description provided for @routemapassign.
  ///
  /// In en, this message translates to:
  /// **'Route Map Assign'**
  String get routemapassign;

  /// No description provided for @createregionalhead.
  ///
  /// In en, this message translates to:
  /// **'Create Regional Head'**
  String get createregionalhead;

  /// No description provided for @nounitsfound.
  ///
  /// In en, this message translates to:
  /// **'noUnitsFound'**
  String get nounitsfound;
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
