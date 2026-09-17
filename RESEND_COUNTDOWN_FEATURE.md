# Resend Code 倒计时功能

## 功能描述

确认注册页的「重新发送验证码」按钮支持可配置冷却，默认首次 30 秒、重发成功后 60 秒。

## 实现特性

- 滑动验证：资料页首次提交、确认页点重发，都必须先过滑块才发码
- 两档冷却：`initialResendCooldownSeconds`（首次）/ `subsequentResendCooldownSeconds`（重发）
- 预置秒数：`ResendCooldown.s5` … `s60`，也可传入任意正整数
- 返回资料页再提交：不发码、不重新滑块，倒计时按剩余秒数继续
- 发码失败可用 `ResendCooldownController.clear()` 立刻恢复可点
- 状态在 `Auth` 中持久化，切页不丢

## 修改的文件

### 1. `lib/src/widgets/cards/auth_card_builder.dart`
- 添加了 `import 'dart:async';` 导入

### 2. `lib/src/providers/auth.dart`
- 添加了持久化倒计时状态管理：
  - `DateTime? _resendCodeTime` - 最后发送验证码的时间
  - `bool get canResendCode` - 检查是否可以重新发送（60秒间隔）
  - `int get resendCountdownSeconds` - 获取剩余倒计时秒数
  - `void setResendCodeTime(DateTime? time)` - 设置发送时间

### 3. `lib/src/widgets/cards/signup_confirm_card.dart`
- 移除本地倒计时状态，改为使用Auth provider的全局状态
- 添加 `_checkAndRestoreCountdown()` 方法在页面初始化时恢复倒计时
- 添加 `_startResendTimer()` 方法用于UI更新
- 修改 `_resendCode()` 方法，使用Auth provider管理状态
- 修改 `_buildResendCode()` 方法，使用Consumer监听Auth状态变化
- 添加滑动验证逻辑和mounted状态检查

### 4. `example/lib/login_screen.dart`
- 添加了 `onResendCode` 回调函数的示例实现

## 使用方法

在使用 `FlutterLogin` 组件时，需要提供 `onResendCode` 回调：

```dart
FlutterLogin(
  // ... 其他配置
  onResendCode: (signupData) async {
    // 实现重新发送验证码的逻辑
    // 返回 null 表示发送成功
    // 返回错误信息字符串表示发送失败
    return null;
  },
  // ... 其他配置
)
```

## 用户体验

1. 用户点击"重新发送验证码"按钮
2. 系统显示滑动验证对话框
3. 用户完成滑动验证：
   - 验证失败：对话框关闭，不执行后续操作
   - 验证成功：继续执行发送逻辑
4. 系统调用 `onResendCode` 回调发送验证码
5. 如果发送成功，按钮立即变为"重新发送 (60秒)"并被禁用
6. 每秒更新倒计时显示："重新发送 (59秒)"、"重新发送 (58秒)"...
7. 倒计时结束后，按钮恢复为"Resend Code"并重新可点击

## 技术细节

- 使用 `showSliderCaptcha` 显示滑动验证对话框
- 使用 `DateTime` 记录发送时间，计算时间差实现倒计时
- 使用 `Timer.periodic` 实现UI实时更新
- 使用 `Consumer<Auth>` 监听全局状态变化
- 使用 `Provider.of<Auth>` 访问和修改全局状态
- 在 `dispose` 中取消Timer防止内存泄漏
- 添加 `mounted` 检查防止async操作中使用已销毁的context
- 支持中文倒计时显示
- **持久化存储**：状态保存在Auth provider中，跨页面保持一致

## 兼容性

- 该功能向后兼容，不影响现有代码
- 如果不提供 `onResendCode` 回调，resend按钮不会显示
- 倒计时功能仅在 signup confirmation 页面生效
