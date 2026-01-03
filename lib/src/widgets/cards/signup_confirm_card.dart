part of 'auth_card_builder.dart';

class _ConfirmSignupCard extends StatefulWidget {
  const _ConfirmSignupCard({
    required this.onBack,
    required this.onSubmitCompleted,
    required this.loadingController,
    required this.keyboardType,
    required this.initialIsoCode,
    super.key,
    this.loginAfterSignUp = true,
  });

  final bool loginAfterSignUp;
  final VoidCallback onBack;
  final VoidCallback onSubmitCompleted;
  final AnimationController loadingController;
  final TextInputType? keyboardType;
  final String? initialIsoCode;

  @override
  _ConfirmSignupCardState createState() => _ConfirmSignupCardState();
}

class _ConfirmSignupCardState extends State<_ConfirmSignupCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  // List of animation controller for every field
  late AnimationController _fieldSubmitController;

  var _isSubmitting = false;
  var _code = '';
  
  // Resend code countdown timer (for UI updates)
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();

    _fieldSubmitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Check and restore countdown state from Auth provider
    _checkAndRestoreCountdown();
  }

  void _checkAndRestoreCountdown() {
    final auth = Provider.of<Auth>(context, listen: false);
    if (!auth.canResendCode) {
      _startResendTimer();
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final auth = Provider.of<Auth>(context, listen: false);
      if (auth.canResendCode) {
        timer.cancel();
        if (mounted) {
          setState(() {}); // Trigger UI update
        }
      } else {
        if (mounted) {
          setState(() {}); // Update countdown display
        }
      }
    });
  }

  @override
  void dispose() {
    _fieldSubmitController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<bool> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formRecoverKey.currentState!.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState!.save();
    await _fieldSubmitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onConfirmSignup!(
      _code,
      LoginData(
        name: auth.username,
        password: auth.password,
        isoCode: auth.phoneIsoCode,
        dialCode: auth.phoneDialCode,
        purePhoneNumber: auth.purePhoneNumber,
      ),
    );

    if (error != null) {
      if (mounted) {
        showErrorToast(context, messages.flushbarTitleError, error);
      }
      setState(() => _isSubmitting = false);
      await _fieldSubmitController.reverse();
      return false;
    }

    if (mounted) {
      showSuccessToast(
        context,
        messages.flushbarTitleSuccess,
        messages.confirmSignupSuccess,
      );
      //验证码验证成功了, 清空codeSentToPhoneNumber
      auth.codeSentToPhoneNumber = '';
    }

    setState(() => _isSubmitting = false);
    await _fieldSubmitController.reverse();

    if (!widget.loginAfterSignUp) {
      auth.mode = AuthMode.login;
      widget.onSubmitCompleted();
      return false;
    }

    widget.onSubmitCompleted();
    return true;
  }


  Future<bool> _resendCode() async {
    final auth = Provider.of<Auth>(context, listen: false);
    
    if (!auth.canResendCode) return false;
    
    FocusScope.of(context).unfocus();

    // 先进行滑动验证
    final captchaResult = await showSliderCaptcha(context, 'Verification_Img.png');
    
    if (!captchaResult) {
      // 滑动验证失败，不执行后续逻辑，也不启动倒计时
      return false;
    }

    // 检查widget是否还mounted
    if (!mounted) return false;

    final messages = Provider.of<LoginMessages>(context, listen: false);

    await _fieldSubmitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onResendCode!(
      SignupData.fromSignupForm(
        name: auth.username,
        password: auth.password,
        termsOfService: auth.getTermsOfServiceResults(),
        isoCode: auth.phoneIsoCode,
        dialCode: auth.phoneDialCode,
        purePhoneNumber: auth.purePhoneNumber,
      ),
    );

    if (error != null) {
      if (mounted) {
        showErrorToast(context, messages.flushbarTitleError, error);
      }

      setState(() => _isSubmitting = false);
      await _fieldSubmitController.reverse();
      return false;
    }

    if (mounted) {
      showSuccessToast(
        context,
        messages.flushbarTitleSuccess,
        messages.resendCodeSuccess,
      );
    }

    setState(() => _isSubmitting = false);
    await _fieldSubmitController.reverse();
    
    // Set resend time in Auth provider and start timer
    auth.setResendCodeTime(DateTime.now());
    _startResendTimer();
    
    return true;
  }

  Widget _buildConfirmationCodeField(double width, LoginMessages messages) {
    return AnimatedTextFormField(
      loadingController: widget.loadingController,
      width: width,
      labelText: messages.confirmationCodeHint,
      prefixIcon: const Icon(FontAwesomeIcons.solidCircleCheck),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: (value) {
        if (value!.isEmpty) {
          return messages.confirmationCodeValidationError;
        }
        return null;
      },
      onSaved: (value) => _code = value!,
      keyboardType: widget.keyboardType,
      initialIsoCode: widget.initialIsoCode,
    );
  }

  Widget _buildResendCode(ThemeData theme, LoginMessages messages) {
    return Consumer<Auth>(
      builder: (context, auth, child) {
        final canResend = auth.canResendCode;
        final countdown = auth.resendCountdownSeconds;
        
        return ScaleTransition(
          scale: widget.loadingController,
          child: MaterialButton(
            onPressed: (!_isSubmitting && canResend) ? _resendCode : null,
            child: Text(
              canResend 
                ? messages.resendCodeButton
                : '重新发送 (${countdown}秒)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: canResend 
                  ? theme.textTheme.bodyMedium?.color
                  : theme.disabledColor,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton(ThemeData theme, LoginMessages messages) {
    return ScaleTransition(
      scale: widget.loadingController,
      child: AnimatedButton(
        controller: _fieldSubmitController,
        text: messages.confirmSignupButton,
        onPressed: !_isSubmitting ? _submit : null,
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme, LoginMessages messages) {
    return ScaleTransition(
      scale: widget.loadingController,
      child: MaterialButton(
        onPressed: !_isSubmitting ? widget.onBack : null,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: theme.primaryColor,
        child: Text(messages.goBackButton),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min<double>(deviceSize.width * 0.75, 360);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    // 动态构建确认信息文本，包含用户名 2025-10-02 01:54:30
    final countryCode = auth.additionalSignupData?['countryCode'] ?? '';
    final confirmIntroText = auth.username.isNotEmpty
        ? '${messages.confirmSignupIntro} $countryCode ${auth.username} ${messages.confirmSignupIntro2}'
        : messages.confirmSignupIntro;

    return FittedBox(
      child: Card(
        child: Container(
          padding: const EdgeInsets.only(
            left: cardPadding,
            top: cardPadding + 10.0,
            right: cardPadding,
            bottom: cardPadding,
          ),
          width: cardWidth,
          alignment: Alignment.center,
          child: Form(
            key: _formRecoverKey,
            child: Column(
              children: <Widget>[
                ScaleTransition(
                  scale: widget.loadingController,
                  child: Text(
                    confirmIntroText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 20),
                _buildConfirmationCodeField(textFieldWidth, messages),
                const SizedBox(height: 10),
                _buildResendCode(theme, messages),
                _buildConfirmButton(theme, messages),
                _buildBackButton(theme, messages),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
