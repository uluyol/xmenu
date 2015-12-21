@import Cocoa;
@import Foundation;

#include <string.h>
#include "draw.h"
#include "util.h"
#include "view.h"

extern char *toReturn;

@implementation XmenuMainView {
  DrawCtx *drawCtx_;
  ItemList items_;
  ItemList filtered_;
  Item *selected_;
  CFMutableStringRef curText_;
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

- (void)keyDown:(NSEvent *)event {
  Item *newSel = selected_ + 1;
  NSString *curString;
  NSUInteger bufsiz;
  BOOL success;
  BOOL curTextChanged = NO;
  char *s;
  NSEventModifierFlags flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
  if (flags == NSControlKeyMask) {
    switch ([event keyCode]) {
      case 13:  // Ctrl+W
        if (CFStringGetLength(curText_) != 0) {
          curString = (NSString *)curText_;
          NSRange spaceRange = [curString rangeOfString:@" " options:NSBackwardsSearch];
          if (spaceRange.location == NSNotFound) {
            CFStringReplaceAll(curText_, CFSTR(""));
          } else {
            CFStringDelete(curText_, CFRangeMake(spaceRange.location, CFStringGetLength(curText_) -
                                                                          spaceRange.location));
          }
          curTextChanged = YES;
        }
        break;
      case 32:  // Ctrl+U
        CFStringReplaceAll(curText_, CFSTR(""));
        curTextChanged = YES;
        break;
      case 0:  // Ctrl+A
        if (filtered_.len != 0) {
          selected_ = ItemListSetSelected(&filtered_, selected_, filtered_.item);
          self.needsDisplay = YES;
        }
        break;
      case 14:  // Ctrl+E
        if (filtered_.len != 0) {
          selected_ =
              ItemListSetSelected(&filtered_, selected_, filtered_.item + filtered_.len - 1);
          self.needsDisplay = YES;
        }
        break;
      case 4:  // Ctrl+H
        if (CFStringGetLength(curText_) != 0) {
          CFStringDelete(curText_, CFStringGetRangeOfComposedCharactersAtIndex(
                                       curText_, CFStringGetLength(curText_) - 1));
          curTextChanged = YES;
        }
        break;
    }
    goto post_keycode;
  }

  switch ([event keyCode]) {
    case 51:  // backspace
      if (CFStringGetLength(curText_) != 0) {
        CFStringDelete(curText_, CFStringGetRangeOfComposedCharactersAtIndex(
                                     curText_, CFStringGetLength(curText_) - 1));
        curTextChanged = YES;
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
    case 48:  // tab
      if (selected_ != NULL) {
        CFStringReplaceAll(curText_, selected_->text);
        curTextChanged = YES;
        break;
      }
    default:
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

post_keycode:
  if (curTextChanged) {
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

  CGFloat preItemX = drawCtx_->x;
  bool foundSel = FALSE;
  for (int i = 0; i < filtered_.len; i++) {
    Item *ip = filtered_.item + i;
    if (!drawText(ctx, drawCtx_, ip->text, ip->sel)) {
      if (foundSel) {
        break;
      } else {
        drawCtx_->x = preItemX;
        clearRight(ctx, drawCtx_);
        i--;
      }
    }
    foundSel = foundSel || ip->sel;
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

- (void)setupWindowForEvents {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowDidResignKey:)
                                               name:NSWindowDidResignMainNotification
                                             object:self];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowDidResignKey:)
                                               name:NSWindowDidResignKeyNotification
                                             object:self];
}

- (void)windowDidResignKey:(NSNotification *)note {
  toReturn = NULL;
  [NSApp stop:self];
}

@end
