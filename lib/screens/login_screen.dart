import 'package:flutter/material.dart';
import 'package:powerretailrep/api/api.dart';

import '../widgets/custom_form_field.dart';
import '../widgets/login_button.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  String? password;
  String? phoneNo;
  bool showPassWord = false;
  bool isLoading = false;
  final _form = GlobalKey<FormState>();
  final phoneNode = FocusNode();
  final passwordNode = FocusNode();

  void saveForm() {
    _form.currentState!.validate();
    bool isValid = _form.currentState!.validate();
    if (isValid == true) {
      _form.currentState!.save();
      setState(() {
        isLoading = true;
      });
      ApiModel().logIn(context, phoneNo, password).then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
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
      body: Form(
        key: _form,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            children: [
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    'تسجيل الدخول',
                    style: commonTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                child: CustomFormField(
                  focusNode: phoneNode,
                  labelText: 'البريد الالكتروني',
                  textInputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'أدخل البريد الالكتروني';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (String? value) {
                    setState(() {
                      phoneNo = value;
                    });
                  },
                  onSubmitted: (String? value) {
                    setState(() {
                      phoneNo = value;
                    });
                    FocusScope.of(context).requestFocus(passwordNode);
                  },
                  onSaved: (String? value) {
                    setState(() {
                      phoneNo = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                child: CustomFormField(
                  focusNode: passwordNode,
                  labelText: 'كلمة المرور',
                  maxLines: 1,
                  obscure: showPassWord == true ? false : true,
                  suffixIconButton: IconButton(
                    icon: Icon(
                      showPassWord == false
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassWord == false
                            ? showPassWord = true
                            : showPassWord = false;
                      });
                    },
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'أدخل كلمة المرور';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (String? value) {
                    setState(() {
                      password = value;
                    });
                  },
                  onSubmitted: (String? value) {
                    setState(() {
                      password = value;
                    });
                  },
                  onSaved: (String? value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              isLoading == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : LogInButton(
                      text: 'تسجيل الدخول',
                      color: Colors.blue,
                      icon: Icons.send_to_mobile_outlined,
                      onTap: () {
                        saveForm();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
