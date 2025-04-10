import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:uuid/uuid.dart';

// clolors that we use in our app
const titleColor = Color(0xFF010F07);
const primaryColor = Color(0xFF22A45D);
const accentColor = Color(0xFFEF9920);
const bodyTextColor = Color(0xFF868686);
const inputColor = Color(0xFFFBFBFB);

const double defaultPadding = 16;
const Duration kDefaultDuration = Duration(milliseconds: 250);

const TextStyle kButtonTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const EdgeInsets kTextFieldPadding = EdgeInsets.symmetric(
  horizontal: defaultPadding,
  vertical: defaultPadding,
);

// Text Field Decoration
const OutlineInputBorder kDefaultOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(6)),
  borderSide: BorderSide(
    color: Color(0xFFF3F2F2),
  ),
);

const InputDecoration otpInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.zero,
  counterText: "",
  errorStyle: TextStyle(height: 0),
);

const kErrorBorderSide = BorderSide(color: Colors.red, width: 1);

// Validator
final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'Password must be at least 8 digits long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-/])',
      errorText: 'Passwords must have at least one special character')
]);

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: 'Enter a valid email address')
]);

final requiredValidator =
    RequiredValidator(errorText: 'This field is required');
final matchValidator = MatchValidator(errorText: 'passwords do not match');

final phoneNumberValidator = MinLengthValidator(10,
    errorText: 'Phone Number must be at least 10 digits long');

  //
  String generateUuid() {
    const uuid = Uuid();
    return uuid.v4(); // Generate a version 4 (random) UUID
  }

int getCurrentTimestampInSeconds() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

// Common Text
final Center kOrText = Center(
    child: Text("Or", style: TextStyle(color: titleColor.withOpacity(0.7))));
//my custom variables
const METADATA_URL = 'https://api.npoint.io/978163b950fb63cd979f';
//global variables
Map<String, String> glb_allUsers = {};  //key: username, value: full name
String glb_otc_market_uri = "";
String glb_fin_key = "";
String glb_fin_uri = "";
String glb_gem_key = "";
String glb_gem_uri = "";
String glb_avatar_uri = "";
bool glb_isDebug = true;  //todo: change it when RELEASE app
String glb_backend_uri = "http://10.115.136.192:3000/";  //our backend url
//
int glb_page_length = 50;
//OTC END POINTS
String CHATBOT_UNAVAILABLE = 'The AI service is unavailable now. Please try in another time.';
Map<String, String> OTC_HEADER = {'origin': 'https://www.otcmarkets.com'};
String otc_getSnapshots = "otcapi/index/snapshot";
String otc_getActiveStocks = 'otcapi/market-data/active/current?page=1&pageSize=50&sortOn=tradeCount';
//FINHUB
String fin_ipoCalendar = 'calendar/ipo?token=';
//our Backend end points
String getStockChart = 'stock/chart?symbol='; //webview
String getAllUsers = 'user/get_all';
String getStockDetails = 'stock/list_by_symbols?symbol_list=';
String searchStocks = 'stock/list_pagination?keyword=';
String postGetChatboxContent = 'stock/chatbot';

String getCommentsByStock = 'comment/list_pagination?limit=$glb_page_length&symbol_list=';
String getLatestComments = 'comment/list_pagination?limit=$glb_page_length&skip=';
String putLikeComment = 'comment/like_comment';

String createNewComment = 'comment/create_new_comment';
String deleteComment = 'comment/delete_comment';