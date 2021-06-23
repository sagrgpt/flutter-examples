import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:interactive_list/models/errors.dart';

class DogRepo {

  final url = Uri.parse('https://dog.ceo/api/breeds/image/random/4');

  Future<List<String>> fetchItem() async{
    var response = await http.get(url);
    if(response.statusCode == 200) {
      final body = response.body;
      final map = json.decode(body);
      final List<dynamic> imageList = map['message'];
      return imageList.map((e) => e as String).toList();
    }
    throw NetworkException();
  }

}