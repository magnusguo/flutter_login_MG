import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login_MG/flutter_login.dart';
import 'package:flutter_login_example/constants.dart';
import 'package:flutter_login_example/custom_route.dart';
import 'package:flutter_login_example/dashboard_screen.dart';
import 'package:flutter_login_example/users.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/auth';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 200);

  Future<String?> _loginUser(LoginData data) {
    return Future<void>.delayed(loginTime).then((_) {
      if (!mockUsers.containsKey(data.name)) {
        return 'User not exists';
      }
      if (mockUsers[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) async {
    // 显示滑动验证
    final captchaResult = await showSliderCaptcha(context, 'Verification_Img.png');
    
    if (!captchaResult) {
      return '滑动验证失败，请重试';
    }
    
    // 验证通过后，执行注册逻辑
    return Future<void>.delayed(loginTime).then((_) {
      // 这里可以添加实际的注册逻辑
      return null; // 返回 null 表示注册成功
    });
  }

  Future<String?> _recoverPassword(String name) {
    return Future<void>.delayed(loginTime).then((_) {
      if (!mockUsers.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  Future<String?> _signupConfirm(String error, LoginData data) {
    return Future<void>.delayed(loginTime).then((_) {
      return null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: Constants.appName,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      logo: const AssetImage('assets/images/ecorp.png'),
      // backgroundImage: const AssetImage('assets/images/bgr.jpg'),
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      userType: LoginUserType.phone,
      navigateBackAfterRecovery: true,
      onConfirmRecover: _signupConfirm,
      onConfirmSignup: _signupConfirm,
      loginAfterSignUp: false,
      autofocus: true,
      loginProviders: [
        LoginProvider(
          button: Buttons.linkedIn,
          label: 'Sign in with LinkedIn',
          callback: () async {
            return null;
          },
          providerNeedsSignUpCallback: () {
            // put here your logic to conditionally show the additional fields
            return Future.value(true);
          },
        ),
        LoginProvider(
          icon: FontAwesomeIcons.githubAlt,
          callback: () async {
            debugPrint('start github sign in');
            await Future<void>.delayed(loginTime);
            debugPrint('stop github sign in');
            return null;
          },
        ),
      ],
      termsOfService: [
        TermOfService(
          id: 'newsletter',
          mandatory: false,
          text: 'Newsletter subscription',
        ),
        TermOfService(
          id: 'general-term',
          mandatory: true,
          text: 'Term of services',
          linkUrl: 'https://github.com/NearHuscarl/flutter_login',
        ),
      ],
      additionalSignupFields: [
        UserButtonField(
          // userType: LoginUserType.contryCodeWithPhoneDisplay,

          keyName: 'countryCode',
          icon: const Icon(FontAwesomeIcons.globe, size: 18),
          title: '手机号国家/区号',
          rightText: '中国 +86',
          rightTextColor: Colors.grey,
          rightTextSize: 13,
          onTap: (keyName) async {
            debugPrint('点击了国家/区号选择: $keyName');
            // 这里可以打开国家/区号选择对话框
            return null; // 暂时不更新值
          },
        ),

        UserButtonField(
          keyName: 'gender',
          title: '性 别',
          icon: const Icon(FontAwesomeIcons.venusMars, size: 18),
          rightText: '男',
          rightTextColor: Colors.grey,
          onTap: (keyName) async {
            debugPrint('点击了性别选择: $keyName');
            // 这里可以打开性别选择对话框
            // 模拟用户选择，实际应用中这里会打开选择器对话框
            // final selectedGender = await _showGenderPicker(context);
            return null; // 返回选择的值，会自动更新显示
          },
        ),
        UserButtonField(
          keyName: 'birthplace',
          title: '出生地',
          icon: const Icon(FontAwesomeIcons.locationDot, size: 18),
          rightText: '选择城市',
          rightTextColor: Colors.blue,
          rightTextSize: 13,
          onTap: (keyName) async {
            debugPrint('点击了出生地选择: $keyName');
            // 这里可以打开城市选择器
            return null; // 暂时不更新值
          },
        ),

          UserButtonField(
          keyName: 'birthtime',
          title: '出生时辰',
          icon: const Icon(FontAwesomeIcons.clock, size: 18),
          rightText: '选择时辰',
          rightTextColor: Colors.blue,
          rightTextSize: 13,
          onTap: (keyName) async {
            debugPrint('点击了出生时辰选择: $keyName');
            // 这里可以打开时辰选择器
            return null; // 暂时不更新值
          },
        ),

        const UserFormField(keyName: '本人姓名'),
        // const UserFormField(keyName: 'Surname'),
        // UserFormField(
        //   keyName: 'phone_number',
        //   displayName: 'Phone Number',
        //   userType: LoginUserType.phone,
        //   fieldValidator: (value) {
        //     final phoneRegExp = RegExp(
        //       r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$',
        //     );
        //     if (value != null &&
        //         value.length < 7 &&
        //         !phoneRegExp.hasMatch(value)) {
        //       return "This isn't a valid phone number";
        //     }
        //     return null;
        //   },
        // ),
        
      ],
      // scrollable: true,
      // hideProvidersTitle: false,
      // loginAfterSignUp: false,
      // hideForgotPasswordButton: true,
      // hideSignUpButton: true,
      // disableCustomPageTransformer: true,
        messages: LoginMessages(
         additionalSignUpFormDescription: '您好!\n请填写以下信息完成注册',
         confirmSignupIntro: '验证码已发送到您的手机:\n',
         confirmSignupIntro2: '\n请输入验证码以确认您的账户。',
      //   userHint: 'User',
      //   passwordHint: 'Pass',
      //   confirmPasswordHint: 'Confirm',
      //   loginButton: 'LOG IN',
      //   signupButton: 'REGISTER',
      //   forgotPasswordButton: 'Forgot huh?',
      //   recoverPasswordButton: 'HELP ME',
      //   goBackButton: 'GO BACK',
      //   confirmPasswordError: 'Not match!',
      //   recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
      //   recoverPasswordDescription: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
      //   recoverPasswordSuccess: 'Password rescued successfully',
      //   flushbarTitleError: 'Oh no!',
      //   flushbarTitleSuccess: 'Succes!',
      //   providersTitle: 'login with'
      ),
      // theme: LoginTheme(
      //   primaryColor: Colors.teal,
      //   accentColor: Colors.yellow,
      //   errorColor: Colors.deepOrange,
      //   pageColorLight: Colors.indigo.shade300,
      //   pageColorDark: Colors.indigo.shade500,
      //   logoWidth: 0.80,
      //   titleStyle: TextStyle(
      //     color: Colors.greenAccent,
      //     fontFamily: 'Quicksand',
      //     letterSpacing: 4,
      //   ),
      //   // beforeHeroFontSize: 50,
      //   // afterHeroFontSize: 20,
      //   bodyStyle: TextStyle(
      //     fontStyle: FontStyle.italic,
      //     decoration: TextDecoration.underline,
      //   ),
      //   textFieldStyle: TextStyle(
      //     color: Colors.orange,
      //     shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
      //   ),
      //   buttonStyle: TextStyle(
      //     fontWeight: FontWeight.w800,
      //     color: Colors.yellow,
      //   ),
      //   cardTheme: CardTheme(
      //     color: Colors.yellow.shade100,
      //     elevation: 5,
      //     margin: EdgeInsets.only(top: 15),
      //     shape: ContinuousRectangleBorder(
      //         borderRadius: BorderRadius.circular(100.0)),
      //   ),
      //   inputTheme: InputDecorationTheme(
      //     filled: true,
      //     fillColor: Colors.purple.withOpacity(.1),
      //     contentPadding: EdgeInsets.zero,
      //     errorStyle: TextStyle(
      //       backgroundColor: Colors.orange,
      //       color: Colors.white,
      //     ),
      //     labelStyle: TextStyle(fontSize: 12),
      //     enabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.blue.shade700, width: 4),
      //       borderRadius: inputBorder,
      //     ),
      //     focusedBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.blue.shade400, width: 5),
      //       borderRadius: inputBorder,
      //     ),
      //     errorBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.red.shade700, width: 7),
      //       borderRadius: inputBorder,
      //     ),
      //     focusedErrorBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.red.shade400, width: 8),
      //       borderRadius: inputBorder,
      //     ),
      //     disabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.grey, width: 5),
      //       borderRadius: inputBorder,
      //     ),
      //   ),
      //   buttonTheme: LoginButtonTheme(
      //     splashColor: Colors.purple,
      //     backgroundColor: Colors.pinkAccent,
      //     highlightColor: Colors.lightGreen,
      //     elevation: 9.0,
      //     highlightElevation: 6.0,
      //     shape: BeveledRectangleBorder(
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //     // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      //     // shape: CircleBorder(side: BorderSide(color: Colors.green)),
      //     // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
      //   ),
      // ),
      userValidator: (value) {
           final phoneRegExp = RegExp(
              r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$',
            );
            if (value != null &&
                value.length < 7 &&
                !phoneRegExp.hasMatch(value)) {
              return '请输入正确的手机号, 本步骤无需输入国家区号';
          }
          return null;
        },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        debugPrint('Login info');
        debugPrint('Name: ${loginData.name}');
        debugPrint('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (signupData) {
        debugPrint('Signup info');
        debugPrint('Name: ${signupData.name}');
        debugPrint('Password: ${signupData.password}');

        signupData.additionalSignupData?.forEach((key, value) {
          debugPrint('$key: $value');
        });
        if (signupData.termsOfService.isNotEmpty) {
          debugPrint('Terms of service: ');
          for (final element in signupData.termsOfService) {
            debugPrint(
              ' - ${element.term.id}: ${element.accepted == true ? 'accepted' : 'rejected'}',
            );
          }
        }
        return _signupUser(signupData);
      },
      onResendCode: (signupData) async {
        debugPrint('Resend code for: ${signupData.name}');
        // 模拟发送验证码的延时
        await Future<void>.delayed(const Duration(seconds: 2));
        // 返回null表示发送成功，返回错误信息表示发送失败
        return null;
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(
          FadePageRoute<void>(
            builder: (context) => const DashboardScreen(),
          ),
        );
      },
      onRecoverPassword: (name) {
        debugPrint('Recover password info');
        debugPrint('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
      headerWidget: const IntroWidget(),
    );
  }
}

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'You are trying to login/sign up on server hosted on ',
              ),
              TextSpan(
                text: 'example.com',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          textAlign: TextAlign.justify,
        ),
        Row(
          children: <Widget>[
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('Authenticate'),
            ),
            Expanded(child: Divider()),
          ],
        ),
      ],
    );
  }
}
