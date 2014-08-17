#import <Cocoa/Cocoa.h>
#import "draw.h"
#import "view.h"
#include <string.h>

#define prompt_s "$"

@implementation XmenuMainView
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame: frame];
	return self;
}

- (void)drawRect:(NSRect)rect
{
	DrawCtx drawCtx;
	drawCtx.nbg = mkColor("#ffffff");
	drawCtx.sbg = mkColor("#f00");
	drawCtx.nfg = mkColor("#0F0");
	drawCtx.sfg = mkColor("#00f");
	drawCtx.x = 0;
	drawCtx.font_siz = 14.0; // TODO: Fix shadows
	[[NSColor colorWithCGColor: drawCtx.nbg] set];
	NSRectFill(rect);
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

	CFStringRef itemName = CFStringCreateWithCString(NULL, " Test String ", kCFStringEncodingUTF8);
	CFStringRef psFont = CFStringCreateWithCString(NULL, "Consolas", kCFStringEncodingUTF8);
	CTFontDescriptorRef fontDesc = CTFontDescriptorCreateWithNameAndSize(psFont, drawCtx.font_siz);
	CTFontRef font = CTFontCreateWithFontDescriptor(fontDesc, 0.0, NULL);
	drawCtx.font = font;
	drawCtx.h = rect.size.height;
	drawCtx.w = rect.size.width;
	while (drawText(ctx, &drawCtx, itemName));
//	CFRelease(itemName);
//	CFRelease(attrs);
}

@end
