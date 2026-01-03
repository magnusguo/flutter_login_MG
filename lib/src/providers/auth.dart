import 'package:flutter/material.dart';
import 'package:flutter_login_MG/flutter_login.dart';

/// Represents the current authentication mode: sign up or login.
enum AuthMode {
  /// User is creating a new account.
  signup,

  /// User is logging into an existing account.
  login,
}

/// Represents the type of authentication being used.
enum AuthType {
  /// Username and password authentication
  userPassword,

  /// Third-party provider (e.g., Google, Facebook)
  provider,
}

/// The callback triggered after login.
/// The result is an error message; callback succeeds if the message is null.
typedef LoginCallback = Future<String?>? Function(LoginData);

/// The callback triggered after signup.
/// The result is an error message; callback succeeds if the message is null.
typedef SignupCallback = Future<String?>? Function(SignupData);

/// Callback for submitting additional signup fields as a key-value map.
/// The result is an error message; callback succeeds if the message is null.
typedef AdditionalFieldsCallback = Future<String?>? Function(
    Map<String, String>);

/// Callback to validate or prepare before showing additional signup fields.
/// The result is an error message; callback succeeds if the message is null.
typedef BeforeAdditionalFieldsCallback = Future<String?>? Function(SignupData);

/// Callback to determine whether additional signup data is required.
typedef ProviderNeedsSignUpCallback = Future<bool> Function();

/// Auth callback used by providers (e.g., Google).
/// The result is an error message; callback succeeds if the message is null.
typedef ProviderAuthCallback = Future<String?>? Function();

/// Direct callback for providers with no result message.
typedef ProviderDirectCallback = Future<void>? Function();

/// Callback to recover password using the provided input string (typically email).
/// The result is an error message; callback succeeds if the message is null.
typedef RecoverCallback = Future<String?>? Function(String);

/// Callback for confirming signup with a verification code.
/// The result is an error message; callback succeeds if the message is null.
typedef ConfirmSignupCallback = Future<String?>? Function(String, SignupData);

/// Callback to determine if signup confirmation is required based on the login data.
typedef ConfirmSignupRequiredCallback = Future<bool> Function(LoginData);

/// Callback for confirming password recovery with a code.
/// The result is an error message; callback succeeds if the message is null.
typedef ConfirmRecoverCallback = Future<String?>? Function(String, LoginData);

/// Provides and manages authentication state and callbacks.
class Auth with ChangeNotifier {
  /// Creates an instance of [Auth] to manage the login/signup state and related callbacks.
  Auth({
    this.loginProviders = const [],
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.onConfirmRecover,
    this.onConfirmSignup,
    this.confirmSignupRequired,
    this.onResendCode,
    this.beforeAdditionalFieldsCallback,
    String username = '',
    String password = '',
    String confirmPassword = '',
    AuthMode initialAuthMode = AuthMode.login,
    this.termsOfService = const [],
  })  : _username = username,
        _password = password,
        _confirmPassword = confirmPassword,
        _mode = initialAuthMode;

  /// Callback triggered when user logs in.
  final LoginCallback? onLogin;

  /// Callback triggered when user signs up.
  final SignupCallback? onSignup;

  /// Callback triggered for password recovery.
  final RecoverCallback? onRecoverPassword;

  /// List of third-party login providers.
  final List<LoginProvider> loginProviders;

  /// Callback for confirming recovery via code.
  final ConfirmRecoverCallback? onConfirmRecover;

  /// Callback for confirming sign up via code.
  final ConfirmSignupCallback? onConfirmSignup;

  /// Callback to determine if confirmation step is required during sign up.
  final ConfirmSignupRequiredCallback? confirmSignupRequired;

  /// Callback triggered when user requests to resend confirmation code.
  final SignupCallback? onResendCode;

  /// List of terms of service agreements.
  final List<TermOfService> termsOfService;

  /// Callback triggered before additional signup fields are shown.
  final BeforeAdditionalFieldsCallback? beforeAdditionalFieldsCallback;

  AuthType _authType = AuthType.userPassword;

  /// The type of authentication being used (password or provider).
  AuthType get authType => _authType;
  set authType(AuthType authType) {
    _authType = authType;
    notifyListeners();
  }

  AuthMode _mode = AuthMode.login;

  /// Current authentication mode (login or signup).
  AuthMode get mode => _mode;
  set mode(AuthMode value) {
    _mode = value;
    notifyListeners();
  }

  /// True if currently in login mode.
  bool get isLogin => _mode == AuthMode.login;

  /// True if currently in signup mode.
  bool get isSignup => _mode == AuthMode.signup;

  /// The current step in a multi-card signup process.
  int currentCardIndex = 0;

  /// Returns the opposite of the current [AuthMode].
  AuthMode opposite() {
    return _mode == AuthMode.login ? AuthMode.signup : AuthMode.login;
  }

  /// Switches the current mode between login and signup.
  AuthMode switchAuth() {
    if (mode == AuthMode.login) {
      mode = AuthMode.signup;
    } else if (mode == AuthMode.signup) {
      mode = AuthMode.login;
    }
    return mode;
  }

  String _username = '';

  /// Email or username entered by the user.
  String get username => _username;
  set username(String username) {
    _username = username;
    notifyListeners();
  }

  String _password = '';

  /// Password entered by the user.
  String get password => _password;
  set password(String password) {
    _password = password;
    notifyListeners();
  }

  String _confirmPassword = '';

  /// Confirmation password entered by the user during sign up.
  String get confirmPassword => _confirmPassword;
  set confirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  Map<String, String>? _additionalSignupData;

  /// Additional signup fields entered by the user.
  Map<String, String>? get additionalSignupData => _additionalSignupData;
  set additionalSignupData(Map<String, String>? additionalSignupData) {
    _additionalSignupData = additionalSignupData;
    notifyListeners();
  }

  // International phone number components
  String? _phoneIsoCode;

  /// The ISO country code for international phone number (e.g., "US", "CA", "CN").
  String? get phoneIsoCode => _phoneIsoCode;
  set phoneIsoCode(String? value) {
    _phoneIsoCode = value;
    notifyListeners();
  }

  String? _phoneDialCode;

  /// The country dial code with + prefix (e.g., "+1", "+86").
  String? get phoneDialCode => _phoneDialCode;
  set phoneDialCode(String? value) {
    _phoneDialCode = value;
    notifyListeners();
  }

  String? _purePhoneNumber;

  /// The pure phone number without the country dial code (e.g., "2022626879").
  String? get purePhoneNumber => _purePhoneNumber;
  set purePhoneNumber(String? value) {
    _purePhoneNumber = value;
    notifyListeners();
  }

  /// 设置从Additional Signup Fields 跳转 verification code page时 是否应该发送验证码 2025-09-28 23:17:01
  /// 没有此设置, 每次从 additional signup fields 跳转 verification code page时 都会发送验证码 容易被滥用
  String _codeSentToPhoneNumber = '';
  /// 如果为空 则还没发送过, 如果不为空 则发送过.
  String get codeSentToPhoneNumber => _codeSentToPhoneNumber;
  set codeSentToPhoneNumber(String value) {
    _codeSentToPhoneNumber = value;
    notifyListeners();
  }


  ///发送验证码按钮60秒倒计时 
  DateTime? _resendCodeTime;

  /// The time when the resend code was last sent.
  DateTime? get resendCodeTime => _resendCodeTime;
  
  /// Sets the resend code time and notifies listeners.
  void setResendCodeTime(DateTime? time) {
    _resendCodeTime = time;
    notifyListeners();
  }

  /// Checks if the user can resend the code (60 seconds have passed).
  bool get canResendCode {
    if (_resendCodeTime == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_resendCodeTime!);
    return difference.inSeconds >= 60;
  }

  /// Gets the remaining seconds before the user can resend the code.
  int get resendCountdownSeconds {
    if (_resendCodeTime == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(_resendCodeTime!);
    final remaining = 60 - difference.inSeconds;
    return remaining > 0 ? remaining : 0;
  }

 


  /// Returns a list of [TermOfServiceResult] based on user selections.
  List<TermOfServiceResult> getTermsOfServiceResults() {
    return termsOfService
        .map((e) => TermOfServiceResult(term: e, accepted: e.checked))
        .toList();
  }
}
