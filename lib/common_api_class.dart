import 'package:finalsalesrep/total_history.dart';
import 'package:flutter/widgets.dart';

class CommonApiClass {
  // ✅ Fixed: Removed trailing slash to avoid `//` in final URLs
  static String subDomain = "https://salesrep.esanchaya.com";

  // Agent Total History API to see agent-collected data
  static String totalHistory = "$subDomain/customer_forms_info_id";

  // Agent Profile API
  static String agentProfile = "$subDomain/token_validation";

  // Create Regional Head API
  static String createregionalhead = "$subDomain/sales_rep_user_creation";

  // Profile Screen API
  static String Profilescreen = "$subDomain/token_validation";

  // Agent Customer Form API
  static String customerform = "$subDomain/api/customer_form";

  // Number of Agents API
  static String noOfAgents = "$subDomain/api/users_you_created";

  // One Day Agent API
  static String oneDayAgent = "$subDomain/api/customer_forms_info_one_day";

  // Particular Agent Customer Forms Service
  static String ParticularAgentCustomerFormsService = "$subDomain/api/customer_forms_info_id";

  // Login Screen API
  static String Loginscreen = "$subDomain/web/session/authenticate";

  // Create Agent
  static String CreateAgent = "$subDomain/sales_rep_user_creation";

  // Number of Resources
  static String Noofresources = "$subDomain/api/users_you_created";

  // Agent Details Screen
  static String AgentDetailsScreen = "$subDomain/api/customer_forms_info";

  // Circulation Incharge Screen
  static String Circulationinchargescreen = "$subDomain/api/users_you_created";

  
  static String  agentUnitWise = "$subDomain/api/agents_info_based_on_the_unit";
}


  

