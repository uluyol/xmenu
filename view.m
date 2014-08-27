#import <Cocoa/Cocoa.h>
#import "draw.h"
#import "util.h"
#import "view.h"
#include <string.h>

#define promptCStr "$"

@implementation XmenuMainView
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame: frame];
	return self;
}

- (id)initWithFrameAndItems:(NSRect)frame Items:(ItemList)itemList
{
	self = [super initWithFrame: frame];
	[self setItemList:itemList];
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

	CFStringRef itemName = CFStringCreateWithCString(NULL, pad("Test String"), kCFStringEncodingUTF8);
	CFStringRef psFont = CFStringCreateWithCString(NULL, "Consolas", kCFStringEncodingUTF8);
	CFStringRef promptStr = CFStringCreateWithCString(NULL, pad(promptCStr), kCFStringEncodingUTF8);
	CTFontDescriptorRef fontDesc = CTFontDescriptorCreateWithNameAndSize(psFont, drawCtx.font_siz);
	CTFontRef font = CTFontCreateWithFontDescriptor(fontDesc, 0.0, NULL);
	drawCtx.font = font;
	drawCtx.h = rect.size.height;
	drawCtx.w = rect.size.width;
	drawText(ctx, &drawCtx, promptStr, true);
	drawInput(ctx, &drawCtx);
	drawText(ctx, &drawCtx, itemName, true);
	while (drawText(ctx, &drawCtx, itemName, false));
//	CFRelease(itemName);
//	CFRelease(attrs);
}

@end
