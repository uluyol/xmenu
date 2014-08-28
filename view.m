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

- (id)initWithFrame:(NSRect)frame items:(ItemList)itemList
{
	self = [super initWithFrame: frame];
	self.itemList = itemList;
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

	CFStringRef promptStr = CFStringCreateWithCString(NULL, pad(promptCStr), kCFStringEncodingUTF8);
	CFStringRef psFont = CFStringCreateWithCString(NULL, "Consolas", kCFStringEncodingUTF8);
	CTFontDescriptorRef fontDesc = CTFontDescriptorCreateWithNameAndSize(psFont, drawCtx.font_siz);
	CTFontRef font = CTFontCreateWithFontDescriptor(fontDesc, 0.0, NULL);
	CFRelease(psFont);
	drawCtx.font = font;
	drawCtx.h = rect.size.height;
	drawCtx.w = rect.size.width;
	drawText(ctx, &drawCtx, promptStr, true);
	drawInput(ctx, &drawCtx);
	ItemList list = self.itemList;
	for (int i = 0; i < list.len; i++) {
		Item *itemp = list.items+i;
		if (!drawText(ctx, &drawCtx, itemp->text, itemp->out))
			break;
	}
}

@end
