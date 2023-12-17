// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:powerretailrep/api/api.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/login_button.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home_screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? scanResult;
  String notesText = '';
  String? lat;
  String? long;
  String? visitType;
  bool isLoading = false;
  bool isSending = false;
  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
    setState(() {
      scanResult = barcodeScanRes;
    });
  }

  void onScanPressed() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (isLocationServiceEnabled == false) {
      showMyBar(context, 'من فضلك فعل الوصول للموقع');
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    ApiModel().determinePosition().catchError((e) {
      print(e);
      showErrorBar(context);
    }).then((value) {
      setState(() {
        lat = value.latitude.toString();
        long = value.longitude.toString();
      });
      if (lat == null || long == null) {
        showMyBar(context, 'خطأ في تحديد موقع الزيارة');
        return;
      }
      print(value);
      scanQR().catchError((e) {
        print(e);
        return;
      }).then((_) {
        if (scanResult == null) {
          showMyBar(context, 'خطأ في مسح الكود');
          return;
        }
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Power Retail'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  LogInButton(
                    text: 'مسح لإدخال زيارة',
                    onTap: () {
                      setState(() {
                        visitType = 'visite';
                      });
                      onScanPressed();
                    },
                    color: Colors.amber,
                    icon: Icons.qr_code,
                  ),
                  LogInButton(
                    text: 'مسح لإدخال فاتورة',
                    onTap: () {
                      setState(() {
                        visitType = 'card';
                      });
                      onScanPressed();
                    },
                    color: Colors.blue,
                    icon: Icons.qr_code,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10),
                    child: CustomFormField(
                      labelText: 'ادخال ملاحظات',
                      textInputAction: TextInputAction.newline,
                      minLines: 5,
                      onChanged: (String? value) {
                        setState(() {
                          notesText = value!;
                        });
                      },
                    ),
                  ),
                  isSending == true
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : LogInButton(
                          text: 'ارسال',
                          onTap: () {
                            print('$scanResult,$lat, $long, $visitType,');
                            if (scanResult != null &&
                                lat != null &&
                                long != null &&
                                visitType != null) {
                              print('$scanResult,$lat, $long, $visitType,');
                              setState(() {
                                isSending = true;
                              });
                              ApiModel()
                                  .reportVisit(context, lat, long, visitType,
                                      scanResult, notesText)
                                  .catchError((e) {
                                print(e);
                                setState(() {
                                  isSending = false;
                                });
                                return;
                              }).then((_) {
                                setState(() {
                                  isSending = false;
                                });
                              });
                            }
                          },
                          color: Colors.grey.shade800,
                          icon: Icons.send,
                        ),
                ],
              ),
      ),
    );
  }
}
