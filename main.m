@import Cocoa;

#include <stdbool.h>
#include <stdio.h>
#include "draw.h"
#include "view.h"
#include "items.h"

// TODO: Parse these from command-line opts.
#define window_height 50
#define display_bottom true
#define promptCStr "$"

char *toReturn = "";

int main(int argc, const char **argv) {
  DrawCtx drawCtx;
  drawCtx.nbg = mkColor("#ffffff");
  drawCtx.sbg = mkColor("#f00");
  drawCtx.nfg = mkColor("#0F0");
  drawCtx.sfg = mkColor("#00f");
  drawCtx.x = 0;
  drawCtx.font_siz = 14.0;  // TODO: Fix shadows

  CFStringRef promptStr = CFStringCreateWithCString(NULL, promptCStr, kCFStringEncodingUTF8);
  CFStringRef fontStr = CFStringCreateWithCString(NULL, "Consolas", kCFStringEncodingUTF8);
  CTFontDescriptorRef fontDesc = CTFontDescriptorCreateWithNameAndSize(fontStr, drawCtx.font_siz);
  CTFontRef font = CTFontCreateWithFontDescriptor(fontDesc, 0.0, NULL);
  CFRelease(fontStr);
  drawCtx.font = font;

  initDraw(&drawCtx);

  ItemList itemList = ReadStdin();
  if (itemList.len) {
    itemList.item[0].sel = true;
  }

  [NSAutoreleasePool new];
  [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

  NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
  CGFloat y = screenFrame.origin.y;
  if (!display_bottom) {
    y += screenFrame.size.height - window_height;
  }

  NSRect windowRect = NSMakeRect(screenFrame.origin.x, y, screenFrame.size.width, window_height);
  NSWindow *window = [[[BorderlessWindow alloc] initWithContentRect:windowRect
                                                          styleMask:NSBorderlessWindowMask
                                                            backing:NSBackingStoreBuffered
                                                              defer:NO] autorelease];
  [window makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];

  XmenuMainView *view = [[XmenuMainView alloc] initWithFrame:windowRect
                                                       items:itemList
                                                     drawCtx:&drawCtx
                                                   promptStr:promptStr];
  [view setWantsLayer:YES];
  [window setContentView:view];
  [window makeFirstResponder:view];
  [NSApp run];
  [view release];
  if (toReturn != NULL) {
    puts(toReturn);
  }

  return 0;
}
