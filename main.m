/*
 * File: OSXWindow.m
 *
 * Brief:
 * Creates a OSX/Cocoa application and window
 * without interface builder and XCode.
 *
 * Compile with:
 * gcc OSXWindow.m -o OSXWindow -framework Cocoa
 */

#import <stdio.h>
#import <Cocoa/Cocoa.h>
#import "view.h"
#import "items.h"

int main(int argc, const char * argv[])
{
	ItemList itemList = ReadStdin();

	// Autorelease Pool:
	// Objects declared in this scope will be automatically
	// released at the end of it, when the pool is "drained".
	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	// Create a shared app instance.
	// This will initialize the global variable
	// 'NSApp' with the application instance.
	[NSApplication sharedApplication];

	// Create a window:

	// Style flags
	NSUInteger windowStyle =
			(NSTitledWindowMask  |
			 NSClosableWindowMask |
			 NSResizableWindowMask);

	// Window bounds (x, y, width, height)
	NSRect windowRect = NSMakeRect(0, 0, 800, 50);

	NSWindow *window = [[NSWindow alloc]
		initWithContentRect:windowRect
		styleMask:windowStyle
		backing:NSBackingStoreBuffered
		defer:NO];
	[window autorelease];
	[window setStyleMask:NSBorderlessWindowMask];
	[window makeKeyAndOrderFront:nil];
	// Window controller
//	NSWindowController * windowController =
//		[[NSWindowController alloc] initWithWindow:window];
//	[windowController autorelease];

	// This will add a simple text view to the window,
	// so we can write a test string on it.
//	NSTextView * textView = [[NSTextView alloc] initWithFrame:windowRect];
//	[textView autorelease];
	XmenuMainView *mainView = [[XmenuMainView alloc]
		initWithFrameAndItems:windowRect
		Items:itemList];
	[mainView autorelease];
	[window setContentView:mainView];
//	for (int i = 0; i < itemList->len; i++) {
//		[textView insertText: [NSString stringWithUTF8String: itemList->items[i].text]];
//	}
//	[textView insertText:@"Hello OSX/Cocoa world!"];

	// TODO: Create app delegate to handle system events.
	// TODO: Create menus (especially Quit!)

	// Show window and run event loop
	[window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
	[window orderFrontRegardless];
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp run];

	[pool drain];

	return (0);
}