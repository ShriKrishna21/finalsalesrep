import 'package:finalsalesrep/total_history.dart';
import 'package:flutter/widgets.dart';

class CommonApiClass {
  static String subDomain =
      "https://salesrep.esanchaya.com/api"; // SubDomain For All Api's

//Agent Total History Api To See The Of Agent Collected Data
  static String totalHistory = "$subDomain/customer_forms_info_id  ";
// Agent Profile Api
  static String agentProfile = "$subDomain/token_validation";
//  CreateRegionalHead  Api
  static String createregionalhead = "$subDomain/sales_rep_user_creation";
// Profile Screen Api
  static String Profilescreen = "$subDomain/token_validation";
// Agent Coustmer Form Api
  static String customerform = "$subDomain/api/customer_form";
//No Of Agents Api
  static String noOfAgents = "$subDomain/api/users_you_created"; //////////////
//One Day Agent
  static String oneDayAgent = "$subDomain/api/customer_forms_info_one_day";
// Particular Agent Customer Forms Service
  static String ParticularAgentCustomerFormsService =
      "$subDomain/api/customer_forms_info_id";
// Login Screen Api
  static String Loginscreen = "$subDomain/web/session/authenticate";
// Create Agent
  static String CreateAgent = "$subDomain/sales_rep_user_creation";
//No Of Resources
  static String Noofresources = "$subDomain/api/users_you_created";
//Agent Details Screen
  static String AgentDetailsScreen = "$subDomain/api/customer_forms_info";
//Circulation incharge screen
  static String Circulationinchargescreen = "$subDomain/api/users_you_created";
}
