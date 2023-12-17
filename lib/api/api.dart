// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:powerretailrep/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiModel {
  String domainName = 'mr-ahmed.site';
// GETTING DEVICE LOCATION:
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

// lOG IN API CALL:
  Future<void> logIn(
      BuildContext context, String? eMail, String? passWord) async {
    var url = Uri.parse(
        'https://$domainName/market/api_cart/api.php/?loginRep_post=all');

    var body = {
      'email': eMail,
      'password': passWord,
    };

    try {
      var response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        if (jsonData['result'] == 'Success') {
          SharedPreferences _pref = await SharedPreferences.getInstance();
          _pref.setString('user_id', jsonData['user_id'].toString());
          Navigator.of(context).pushNamed(HomeScreen.routeName);
        } else {
          showErrorBar(context);
        }
      } else {
        showErrorBar(context);
      }
    } catch (e) {
      print(e);
    }
  }
// VISIT REPORTING API CALL

  Future<void> reportVisit(
    BuildContext context,
    String? lat,
    String? long,
    String? visitType,
    String? scanResult,
    String? notes,
  ) async {
    String? userId;
    SharedPreferences _pref = await SharedPreferences.getInstance();
    userId = _pref.getString('user_id');

    var url = Uri.parse(
        'https://$domainName/market/api_cart/api.php/?add_visite=all&visite_date=${DateTime.now().toString()}&visite_latitude=$lat&visite_longitude=$long&visite_type=$visitType&visite_store=$scanResult&visite_nots=$notes&visite_user=$userId');
    print('user id : $userId');
    if (userId != null) {
      try {
        var response = await http.get(url);
        if (response.statusCode == 200) {
          print(response.body);
          var jsonData = jsonDecode(response.body);
          if (jsonData['result'] == 'Success') {
            showMyBar(context, 'تمت العملية بنجاح');
          } else {
            showErrorBar(context);
          }
        } else {
          showErrorBar(context);
        }
      } catch (e) {
        print(e);
        showErrorBar(context);
      }
    }
  }
}

void showErrorBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 3),
      content: Text(
        'خطأ في الإتصال ...',
        textDirection: TextDirection.rtl,
      )));
}

void showMyBar(BuildContext context, String? content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(
        content!,
        textDirection: TextDirection.rtl,
      )));
}
