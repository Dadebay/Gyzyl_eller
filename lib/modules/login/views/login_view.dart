import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/modules/login/controllers/auth_service.dart';

class LoginView extends StatefulWidget {
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  dynamic onTap(BuildContext context) async {
    if (phoneNumberController.text.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen geçerli bir telefon numarası girin.')),
      );
      return;
    }
    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen şifrenizi girin.')),
      );
      return;
    }

    await AuthService().login(
      phone: '+993${phoneNumberController.text}',
      password: passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorConstants.kPrimaryColor2,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Içeri gir',
          style: TextStyle(
            color: ColorConstants.fonts,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorConstants.background,
        elevation: 0,
      ),
      backgroundColor: ColorConstants.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Text(
                'Ulgama girmek we kod almak üçin telefon belginizi giriziň',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefon belgiňiz',
                  prefixText: '+993 ',
                  prefixStyle: TextStyle(fontSize: 16, color: Colors.black),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Açar söz',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (bool? newValue) {},
                  activeColor: ColorConstants.kPrimaryColor2,
                ),
                Text(
                  'Ähli şertleri bilen ',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                GestureDetector(
                  onTap: () {
                    print('Yalasygyny tıklandı!');
                  },
                  child: Text(
                    'yalasygyny',
                    style: TextStyle(
                      color: ColorConstants.kPrimaryColor2,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => onTap(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.kPrimaryColor2,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Dowam et',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.whiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    