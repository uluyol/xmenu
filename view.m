@import Cocoa;
@import Foundation;

#include <string.h>
#include "draw.h"
#include "util.h"
#include "view.h"

#define promptCStr "$"

extern char *toReturn;

PrevStack *PrevStackPop(PrevStack *ps) {
  if (ps == NULL) {
    NSLog(@"PrevStackPop: got null");
    return ps;
  }
  PrevStack *ret = ps->prev;
  free(ps);
  return ret;
}

PrevStack *PrevStackPush(PrevStack *ps, CFIndex idx) {
  PrevStack *ns = malloc(sizeof(PrevStack *));
  ns->prev = ps;
  ns->idx = idx;
  return ns;
}

@implementation XmenuMainView

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  self.curText = CFStringCreateMutable(kCFAllocatorDefault, 0);
  return self;
}

- (id)initWithFrame:(NSRect)frame items:(ItemList)itemList {
  self = [super initWithFrame:frame];
  self.itemList = itemList;
  self.curText = CFStringCreateMutable(kCFAllocatorDefault, 0);
  return self;
}

- (void)keyUp:(NSEvent *)event {
  NSLog(@"Key released: %@", event);
}

- (void)keyDown:(NSEvent *)event {
  NSString *curString;
  switch ([event keyCode]) {
    case 51:  // backspace
      if (self.ps) {
        CFStringDelete(
            self.curText,
            CFRangeMake(self.ps->idx,
                        CFStringGetLength(self.curText) - self.ps->idx));
        self.ps = PrevStackPop(self.ps);
        self.needsDisplay = YES;
      }
      break;
    case 53:  // escape
      curString = (NSString *)self.curText;
      NSUInteger bufsiz =
          [curString maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding] +
          1;
      char *s = calloc(bufsiz, sizeof(char));
      BOOL success = [curString getCString:s
                                 maxLength:bufsiz
                                  encoding:NSUTF8StringEncoding];
      if (!success) {
        NSLog(@"unable to write return string");
      }
      toReturn = s;
      [NSApp stop:self];
      break;
    case 126:
    case 125:
    case 124:
    case 123:
      NSLog(@"Arrow key pressed!");
      break;
    default:
      NSLog(@"Key pressed: %@", event);
      self.ps = PrevStackPush(self.ps, CFStringGetLength(self.curText));
      CFStringAppend(self.curText, (CFStringRef)event.characters);
      self.needsDisplay = YES;
      break;
  }
}

- (void)drawRect:(NSRect)rect {
  DrawCtx drawCtx;
  drawCtx.nbg = mkColor("#ffffff");
  drawCtx.sbg = mkColor("#f00");
  drawCtx.nfg = mkColor("#0F0");
  drawCtx.sfg = mkColor("#00f");
  drawCtx.x = 0;
  drawCtx.font_siz = 14.0;  // TODO: Fix shadows
  [[NSColor colorWithCGColor:drawCtx.nbg] set];
  NSRectFill(rect);

  CFStringRef promptStr =
      CFStringCreateWithCString(NULL, pad(promptCStr), kCFStringEncodingUTF8);
  CFStringRef psFont =
      CFStringCreateWithCString(NULL, "Consolas", kCFStringEncodingUTF8);
  CTFontDescriptorRef fontDesc =
      CTFontDescriptorCreateWithNameAndSize(psFont, drawCtx.font_siz);
  CTFontRef font = CTFontCreateWithFontDescriptor(fontDesc, 0.0, NULL);
  CFRelease(psFont);
  drawCtx.font = font;
  drawCtx.h = rect.size.height;
  drawCtx.w = rect.size.width;

  CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

  drawText(ctx, &drawCtx, promptStr, true);
  drawText(ctx, &drawCtx, self.curText, false);
  drawInput(ctx, &drawCtx);
  ItemList list = self.itemList;
  for (int i = 0; i < list.len; i++) {
    Item *itemp = list.item + i;
    if (!drawText(ctx, &drawCtx, itemp->text, itemp->sel)) {
      break;
    }
  }
}

@end

@implementation BorderlessWindow

- (BOOL)canBecomeKeyWindow {
  return YES;
}
- (BOOL)canBecomeMainWindow {
  return YES;
}

@end
