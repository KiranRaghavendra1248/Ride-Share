import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> makePostRequest(String baseUrl, String route, Map<String, dynamic> requestBody) async {
  String apiUrl = '$baseUrl/$route';

  try {
    // Make the API call and await the response
    http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Parse the response JSON
      dynamic responseData = json.decode(response.body);
      // Return the parsed response
      return responseData;
    } else {
      // Handle error response
      print('Error response from server: ${response.body}');
      return null;
    }
  } catch (e) {
    // Handle any exceptions
    print('Exception: $e');
    return null;
  }
}

Future<dynamic> makeGetRequest(String baseUrl, String route) async {

  String apiUrl = '$baseUrl/$route';

  try {
    // Make the API call and await the response
    http.Response response = await http.get(
      Uri.parse(apiUrl),
    );

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Parse the response JSON
      dynamic responseData = json.decode(response.body);
      // Return the parsed response
      return responseData;
    } else {
      // Handle error response
      print('Error response from server: ${response.body}');
      return null;
    }
  } catch (e) {
    // Handle any exceptions
    print('Exception: $e');
    return null;
  }
}