#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>

static CFMachPortRef eventTap = NULL;
static BOOL heldButtons[5] = {NO};

static void PostFn(BOOL down) {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)0x3f, down);
    if (!event) return;
    CGEventSetFlags(event, down ? kCGEventFlagMaskSecondaryFn : 0);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}

static void PostReturn(BOOL down) {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)0x24, down);
    if (!event) return;
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}

static void PostDelete(BOOL down) {
    // macOS 虚拟键码 0x33 是 Delete（向左删除）。
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)0x33, down);
    if (!event) return;
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}

static void ReleaseHeldKeys(void) {
    if (heldButtons[2]) PostFn(NO);
    if (heldButtons[3]) PostReturn(NO);
    if (heldButtons[4]) PostDelete(NO);
    memset(heldButtons, 0, sizeof(heldButtons));
}

static CGEventRef MouseCallback(CGEventTapProxy proxy, CGEventType type,
                                CGEventRef event, void *refcon) {
    (void)proxy;
    (void)refcon;
    if (type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput) {
        // An interrupted event stream may have lost a button-up event.
        ReleaseHeldKeys();
        if (eventTap) CGEventTapEnable(eventTap, true);
        return event;
    }

    if (type != kCGEventOtherMouseDown && type != kCGEventOtherMouseUp) return event;

    int64_t button = CGEventGetIntegerValueField(event, kCGMouseEventButtonNumber);

    if (button == 2) {
        heldButtons[2] = (type == kCGEventOtherMouseDown);
        if (type == kCGEventOtherMouseDown) PostFn(YES);
        if (type == kCGEventOtherMouseUp) PostFn(NO);
        return NULL;
    }

    if (button == 3) {
        heldButtons[3] = (type == kCGEventOtherMouseDown);
        if (type == kCGEventOtherMouseDown) PostReturn(YES);
        if (type == kCGEventOtherMouseUp) PostReturn(NO);
        return NULL;
    }

    if (button == 4) {
        heldButtons[4] = (type == kCGEventOtherMouseDown);
        if (type == kCGEventOtherMouseDown) PostDelete(YES);
        if (type == kCGEventOtherMouseUp) PostDelete(NO);
        return NULL;
    }

    return event;
}

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property NSStatusItem *statusItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;
    NSDictionary *options = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt: @YES};
    if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"需要辅助功能权限";
        alert.informativeText = @"请在“系统设置 → 隐私与安全性 → 辅助功能”中允许“鼠标语音侧键助手”，然后重新打开本应用。";
        [alert addButtonWithTitle:@"打开系统设置"];
        [alert addButtonWithTitle:@"退出"];
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            NSURL *url = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"];
            [[NSWorkspace sharedWorkspace] openURL:url];
        }
        [NSApp terminate:nil];
        return;
    }

    CGEventMask mask = CGEventMaskBit(kCGEventOtherMouseDown) |
                       CGEventMaskBit(kCGEventOtherMouseUp);
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap,
                                kCGEventTapOptionDefault, mask,
                                MouseCallback, NULL);
    if (!eventTap) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"无法监听鼠标";
        alert.informativeText = @"请确认已授予辅助功能权限，然后重新打开应用。";
        [alert runModal];
        [NSApp terminate:nil];
        return;
    }

    CFRunLoopSourceRef source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), source, kCFRunLoopCommonModes);
    CFRelease(source);
    CGEventTapEnable(eventTap, true);

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.title = @"Fn";
    self.statusItem.button.toolTip = @"鼠标语音侧键助手 · Mouse Voice and Side Buttons";

    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *state = [[NSMenuItem alloc] initWithTitle:@"运行中：中键 → Fn" action:nil keyEquivalent:@""];
    state.enabled = NO;
    [menu addItem:state];
    NSMenuItem *sideButtons = [[NSMenuItem alloc] initWithTitle:@"后退键 → 回车；前进键 → Delete" action:nil keyEquivalent:@""];
    sideButtons.enabled = NO;
    [menu addItem:sideButtons];
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@"q"];
    quit.target = NSApp;
    [menu addItem:quit];
    self.statusItem.menu = menu;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    (void)notification;
    ReleaseHeldKeys();
    if (eventTap) {
        CGEventTapEnable(eventTap, false);
        CFRelease(eventTap);
        eventTap = NULL;
    }
}

@end

int main(int argc, const char *argv[]) {
    (void)argc;
    (void)argv;
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}
