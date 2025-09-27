# Resend Code 倒计时功能

## 功能描述

在确认注册页面（confirmation page）中，为 "重新发送验证码" 按钮添加了60秒倒计时功能。

## 实现特性

- ✅ 滑动验证：点击"重新发送验证码"前需要先通过滑动验证
- ✅ 60秒倒计时：滑动验证通过且发送成功后，按钮会被禁用60秒
- ✅ 实时倒计时显示：按钮文本会显示剩余秒数，如"重新发送 (45秒)"
- ✅ 自动恢复：倒计时结束后，按钮自动恢复可点击状态
- ✅ 视觉反馈：倒计时期间按钮文本颜色变为禁用色
- ✅ 验证失败保护：滑动验证失败时不会启动倒计时
- ✅ 内存管理：页面销毁时自动清理Timer，防止内存泄漏
- ✅ **持久化状态**：倒计时状态保存在全局状态中，页面切换不会丢失
- ✅ **跨页面一致性**：用户离开confirmation页面再返回时，倒计时状态依然有效

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
