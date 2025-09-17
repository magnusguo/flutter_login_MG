import 'package:flutter/material.dart';
import 'package:slider_captcha/slider_captcha.dart';

// part of 'auth_card_builder.dart';

/// 显示滑动验证码对话框
///
/// 返回 `true` 表示验证成功，`false` 表示验证失败或取消
Future<bool> showSliderCaptcha(BuildContext context, String image_name) async {
  final captchaController = SliderController();
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '安全验证',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('请完成滑动验证以继续注册'),
                  const SizedBox(height: 20),
                  SliderCaptcha(
                    controller: captchaController,
                    image: Image.asset(
                      'assets/images/$image_name',
                      fit: BoxFit.fitWidth,
                    ),
                    colorBar: Colors.blue,
                    // colorCaptChar: Colors.blue, // 使用默认颜色
                    onConfirm: (isSuccess) async {
                      if (isSuccess) {
                        await Future<void>.delayed(const Duration(milliseconds: 500));
                        Navigator.of(context).pop(true); // 验证成功
                      } else {
                        // 验证失败，重新生成验证码
                        captchaController.create();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // 取消验证
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          captchaController.create(); // 刷新验证码
                        },
                        child: const Text('刷新'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ) ??
      false;
}
