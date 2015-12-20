@import Cocoa;

#include <stdbool.h>
#include <stdio.h>
#include "draw.h"
#include "view.h"
#include "items.h"

// TODO: Parse these from command-line opts.
#define window_height 50
#define display_bottom true

char *toReturn = "";

int main(int argc, const char **argv) {
  initDraw();

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

  XmenuMainView *view = [[XmenuMainView alloc] initWithFrame:windowRect items:itemList];
  [view setWantsLayer:YES];
  [window setContentView:view];
  [window makeFirstResponder:view];
  [NSApp run];
  [view release];
  puts(toReturn);

  return 0;
}
