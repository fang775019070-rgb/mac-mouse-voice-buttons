# 鼠标语音侧键助手 — Mouse Voice and Side Buttons

[中文说明](README.md) · [Downloads](https://github.com/fang775019070-rgb/mac-mouse-voice-buttons/releases)

A native macOS menu bar utility for mouse based dictation and text editing.

| Button reported by macOS | Mapping |
| --- | --- |
| Middle button, number 2 | Fn down / up |
| Back side button, number 3 | Return down / up |
| Forward side button, number 4 | Backspace (macOS Delete) down / up |

Side button numbers vary by mouse and driver. The app applies these mappings globally to all mice; it does not select one device.

## Why remap the side buttons?

When dictating, submitting text and correcting recognition errors are often more useful than navigating backward and forward. The thumb buttons keep these actions near the pointing hand and reduce movement between the mouse and keyboard.

Trigger a voice input tool with the middle button, inspect the result, and press the back side button to submit in a chat app that sends on Return. Select incorrect text and press the forward side button to delete it. Return may instead insert a line break or confirm a dialog, depending on the focused application. Delete does not locate mistakes automatically.

The original middle and side button clicks are consumed while this app runs. Quit it through its **Fn** menu to restore normal browser navigation and middle click behavior. Left/right clicks and wheel scrolling are not remapped.

## Setup

1. Download the release ZIP, extract it, move the app to Applications and open it.
2. Grant the app access in **System Settings → Privacy & Security → Accessibility**, then reopen it. You may need to add the app to the list manually.
3. The **Fn** menu bar item indicates that the event tap was created. Login startup is optional and can be enabled through macOS Login Items.
4. Enable macOS Dictation and choose a Fn based shortcut. If your shortcut is **Press Fn Twice**, double click the middle button. A single click is not automatically doubled. Third party voice tools must also be configured to respond to Fn.

This utility simulates a key; speech recognition is handled by macOS or your chosen voice tool. It does not record audio. See [Apple's Dictation guide](https://support.apple.com/guide/mac-help/use-dictation-mh40584/mac) for the system shortcut and privacy settings.

The download is ad-hoc signed, not Developer ID signed or notarized. If macOS blocks it, verify the repository and SHA256 checksum, then use the system's Privacy & Security **Open Anyway** flow. Keep the system's overall security protection enabled.

## Build and compatibility

On a Mac with Xcode Command Line Tools:

```sh
zsh build.sh
```

The output is `dist/鼠标语音侧键助手.app`, a universal arm64/x86_64 application with a macOS 11 deployment target. Compilation and signature verification were completed on Apple silicon and GitHub's macOS runner. Runtime compatibility across all mice, Intel hardware and macOS versions has not been verified. Vendor software may intercept side buttons before the app receives them.

The program subscribes only to other mouse button down/up events. It does not capture typed text, store input, make network requests or collect telemetry. Synthetic keys that remain pressed are released on normal exit and on event tap interruptions.

Based on the author's original personal MouseMiddleFn utility. Personal launch configuration is excluded. The public project provides a reproducible build and release workflow.

MIT License. See [LICENSE](LICENSE).
