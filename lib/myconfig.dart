class MyConfig {
  // Update this IP to your local server IP
  static const String baseUrl = "http://172.20.10.2";
  static const String backend = '/mymovewise/backend';

  // AI Configuration
  static const String geminiApiKey = "AIzaSyAjpnLYddTFUqSgpEohw-mnGE-tjAu--qY";
  static const String systemInstruction = """
    DONT PUT ANY MOTIVATIONAL SPEECH AT THE BEGINNING, JUST GO STRAIGHT TO WORKOUT RECOMMENDATIONS. 
    You are the MoveWise AI Coach. Based on the user's input, recommend 3 exercises 
    that might be found in a gym dataset (Body Part, Equipment, Level). 
    Keep the tone encouraging and professional.
  """;
}
