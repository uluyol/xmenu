@import Cocoa;
@import Foundation;

#include <string.h>
#include "draw.h"
#include "util.h"
#include "view.h"

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
  PrevStack *ns = ecalloc(1, sizeof(PrevStack *));
  ns->prev = ps;
  ns->idx = idx;
  return ns;
}

@implementation XmenuMainView {
  DrawCtx *drawCtx_;
  ItemList items_;
  ItemList filtered_;
  Item *selected_;
  CFMutableStringRef curText_;
  PrevStack *ps_;
  CFStringRef promptStr_;
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  curText_ = CFStringCreateMutable(kCFAllocatorDefault, 0);
  return self;
}

- (id)initWithFrame:(NSRect)frame
              items:(ItemList)itemList
            drawCtx:(DrawCtx *)drawCtx
          promptStr:(CFStringRef)promptStr {
  self = [super initWithFrame:frame];
  drawCtx_ = drawCtx;
  itemList.item[0].sel = TRUE;
  items_ = itemList;
  ItemListFrom(&(filtered_), itemList);
  selected_ = filtered_.item;
  curText_ = CFStringCreateMutable(kCFAllocatorDefault, 0);
  promptStr_ = promptStr;
  return self;
}

- (void)keyUp:(NSEvent *)event {
  NSLog(@"Key released: %@", event);
}

- (void)keyDown:(NSEvent *)event {
  Item *newSel = selected_ + 1;
  NSString *curString;
  NSUInteger bufsiz;
  BOOL success;
  char *s;
  NSEventModifierFlags flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
  if (flags == NSControlKeyMask) {
    switch ([event keyCode]) {
      case 13:  // Ctrl+W
        break;
      case 32:  // Ctrl+U
        CFStringReplaceAll(curText_, CFSTR(""));
        ItemListReset(&filtered_);
        ItemListFilter(&filtered_, items_, curText_);
        self.needsDisplay = YES;
        break;
    }
    return;
  }

  switch ([event keyCode]) {
    case 51:  // backspace
      if (ps_ != NULL) {
        CFStringDelete(curText_, CFRangeMake(ps_->idx, CFStringGetLength(curText_) - ps_->idx));
        ps_ = PrevStackPop(ps_);
        ItemListReset(&filtered_);
        ItemListFilter(&filtered_, items_, curText_);
        if (filtered_.len != 0) {
          filtered_.item[0].sel = TRUE;
          selected_ = filtered_.item;
        } else {
          selected_ = NULL;
        }
        self.needsDisplay = YES;
      }
      break;
    case 53:  // escape
      toReturn = NULL;
      [NSApp stop:self];
      break;
    case 126:  // up arrow
    case 123:  // left arrow
      newSel = selected_ - 1;
    case 125:  // down arrow
    case 124:  // right arrow
      if (selected_ == NULL) {
        break;
      }
      if (filtered_.item <= newSel && newSel < filtered_.item + filtered_.len) {
        selected_->sel = FALSE;
        selected_ = newSel;
        selected_->sel = TRUE;
      }
      self.needsDisplay = YES;
      break;
    case 36:  // return/enter
      if (selected_ == NULL) {
        curString = (NSString *)curText_;
      } else {
        curString = (NSString *)selected_->text;
      }
      bufsiz = [curString maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
      s = ecalloc(bufsiz, sizeof(char));
      success = [curString getCString:s maxLength:bufsiz encoding:NSUTF8StringEncoding];
      if (!success) {
        NSLog(@"unable to write return string");
      }
      toReturn = s;
      [NSApp stop:self];
      break;
    case 9:  // tab
    default:
      NSLog(@"Key pressed: %@", event);
      ps_ = PrevStackPush(ps_, CFStringGetLength(curText_));
      CFStringAppend(curText_, (CFStringRef)event.characters);
      ItemListReset(&filtered_);
      ItemListFilter(&filtered_, items_, curText_);
      if (filtered_.len != 0) {
        filtered_.item[0].sel = TRUE;
        selected_ = filtered_.item;
      } else {
        selected_ = NULL;
      }
      self.needsDisplay = YES;
      break;
  }
}

- (void)drawRect:(NSRect)rect {
  [[NSColor colorWithCGColor:drawCtx_->nbg] set];
  NSRectFill(rect);

  CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
  drawCtx_->x = 0;
  drawCtx_->h = rect.size.height;
  drawCtx_->w = rect.size.width;

  drawText(ctx, drawCtx_, promptStr_, true);
  drawInput(ctx, drawCtx_, curText_);
  // TODO: Fix drawing so that the currently selected item is always
  //       visible.
  for (int i = 0; i < filtered_.len; i++) {
    Item *ip = filtered_.item + i;
    if (!drawText(ctx, drawCtx_, ip->text, ip->sel)) {
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
