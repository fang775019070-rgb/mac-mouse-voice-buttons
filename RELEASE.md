# 鼠标语音侧键助手（Mouse Voice and Side Buttons）v1.1.0

公开试用版。中键模拟 Fn；后退侧键模拟回车；前进侧键模拟向左删除。适合语音输入后的提交和纠错，减少手在鼠标与键盘之间的移动。

下载 `MouseVoiceButtons-v1.1.0-universal.zip` 并解压，在系统设置中授予本应用辅助功能权限，然后重新打开。系统听写需先设置 Fn 快捷方式；“按两次 Fn”对应双击中键。

Apple 芯片 / Intel 通用构建，macOS 11 构建目标。本地签名，尚未 Apple 开发者签名或公证。编译与签名校验通过；不同鼠标、驱动和系统版本仍需实机验证。运行时会替换中键及两颗侧键的原始功能，退出即可恢复。

## English

Public preview of a native macOS mouse remapping utility: middle button → Fn, back side button → Return, forward side button → Backspace. These mappings put dictation, submission and correction near the pointing hand. Configure a Fn based voice input shortcut first and grant Accessibility access.

The release is a universal arm64/x86_64 build, ad-hoc signed and not notarized. Compilation and signature verification passed; runtime compatibility across all devices and system versions has not been verified. Original middle/side clicks are consumed while the app runs. Quit the Fn menu bar app to restore them.

Built from the public source by GitHub Actions. SHA256 checksums included. MIT License.
