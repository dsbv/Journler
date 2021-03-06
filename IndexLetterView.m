//
//  IndexLetterView.m
//  Journler
//
//  Created by Philip Dow on 1/31/07.
//  Copyright 2007 Sprouted, Philip Dow. All rights reserved.
//

/*
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 and the following disclaimer in the documentation and/or other materials provided with the
 distribution.
 
 * Neither the name of the author nor the names of its contributors may be used to endorse or
 promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Basically, you can use the code in your free, commercial, private and public projects
// as long as you include the above notice and attribute the code to Philip Dow / Sprouted
// If you use this code in an app send me a note. I'd love to know how the code is used.

// Please also note that this copyright does not supersede any other copyrights applicable to
// open source code used herein. While explicit credit has been given in the Journler about box,
// it may be lacking in some instances in the source code. I will remedy this in future commits,
// and if you notice any please point them out.

#import "IndexLetterView.h"

#import <SproutedUtilities/SproutedUtilities.h>

/*
#import "NSBezierPath_AMShading.h"
#import "NSBezierPath_AMAdditons.h"
*/

#define kMaxAdditionalSpace 20

@implementation IndexLetterView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		selectionRange = NSMakeRange(0,0);
		
		//NSFont *defaultFont = [NSFont boldSystemFontOfSize:26];
		NSFont *defaultFont = [NSFont fontWithName:@"Times-Roman" size:26];
		if ( defaultFont == nil ) defaultFont = [NSFont boldSystemFontOfSize:26];
		
		/*
		NSData *defaultFontData = [[NSUserDefaults standardUserDefaults] dataForKey:@"DefaultEntryFont"];
		if ( defaultFontData != nil )
			defaultFont = [NSUnarchiver unarchiveObjectWithData:defaultFontData];
		*/
		defaultFont = [[NSFontManager sharedFontManager] convertFont:defaultFont toHaveTrait:NSBoldFontMask];
		//defaultFont = [[NSFontManager sharedFontManager] convertFont:defaultFont toHaveTrait:NSItalicFontMask];
		
		textShadow = [[NSShadow alloc] init];
		[textShadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.94]];
		[textShadow setShadowOffset:NSMakeSize(2,-2)];
		//[textShadow setShadowBlurRadius:5.0];
		
		[self setLetters:[IndexLetterView englishLetters]];
		[self setFont:defaultFont];
    }
    return self;
}

- (void) dealloc
{
	[letters release];
	[font release];
	[textShadow release];
	
	[super dealloc];
}

#pragma mark -

+ (NSString*) englishLetters
{
	return @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
}

- (NSString*) letters
{
	return letters;
}

- (void) setLetters:(NSString*)aString
{
	if ( letters != aString )
	{
		[letters release];
		letters = [aString copyWithZone:[self zone]];
	}
}

- (NSString*) selectedLetter
{
	return [[self letters] substringWithRange:selectionRange];
}

- (NSFont*) font
{
	return font;
}

- (void) setFont:(NSFont*)aFont
{
	if ( font != aFont )
	{
		[font release];
		font = [aFont copyWithZone:[self zone]];
	}
}

#pragma mark -

- (id) target
{
	return target;
}

- (void) setTarget:(id)anObject
{
	target = anObject;
}

- (SEL) action
{
	return action;
}

- (void) setAction:(SEL)anAction
{
	action = anAction;
}

#pragma mark -

- (void)drawRect:(NSRect)aRect
{
	NSInteger i, offset = 10;
	float requiredWidth;
	float addedSpacePerLetter = 0;
	NSRect bds = [self bounds];
	
	//NSBezierPath *roundedBounds = [NSBezierPath bezierPathWithRoundedRect:bds cornerRadius:8];
	
	//[[NSColor whiteColor] set];
	//[roundedBounds fill];
	//NSRectFill(bds);
	
	//[[NSColor lightGrayColor] set];
	//[roundedBounds stroke];
	//NSFrameRect(bds);
	
	// reset to default font
	//[self setFont:[NSFont boldSystemFontOfSize:26]];
	[self setFont:[[NSFontManager sharedFontManager] convertFont:[self font] toSize:26]];
	
	requiredWidth = [self requiredWidthForFont:[self font]];
	while ( requiredWidth > bds.size.width )
	{
		//[self setFont:[NSFont boldSystemFontOfSize:[[self font] pointSize] - 2]];
		[self setFont:[[NSFontManager sharedFontManager] convertFont:[self font] toSize:[[self font] pointSize] - 2]];
		requiredWidth = [self requiredWidthForFont:[self font]];
	}
	
	addedSpacePerLetter = ( bds.size.width - requiredWidth ) / [[self letters] length];
	if ( addedSpacePerLetter < 0.0 ) addedSpacePerLetter = 0;
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName, 
		[NSColor blackColor], NSForegroundColorAttributeName,
		textShadow, NSShadowAttributeName, nil];
	
	for ( i = 0; i < [[self letters] length]; i++ )
	{
		NSString *aLetter = [[self letters] substringWithRange:NSMakeRange(i,1)];
		NSSize aSize = [aLetter sizeWithAttributes:attrs];
		
		[aLetter drawAtPoint:NSMakePoint(offset, bds.size.height/2 - aSize.height/2) withAttributes:attrs];
		
		offset += aSize.width;
		offset += ( [[self font] pointSize] / 3 );
		
		offset += ( addedSpacePerLetter > kMaxAdditionalSpace ? kMaxAdditionalSpace : addedSpacePerLetter);
	}
	
	//[[self letters] drawInRect:bds withAttributes:attrs];
}

- (void)resetCursorRects
{
	NSInteger i, offset = 10;
	NSRect bds = [self bounds];
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName, 
		[NSColor blackColor], NSForegroundColorAttributeName,
		textShadow, NSShadowAttributeName, nil];
	
	float addedSpacePerLetter = 0;
	addedSpacePerLetter = ( bds.size.width - [self requiredWidthForFont:[self font]] ) / [[self letters] length];
	if ( addedSpacePerLetter < 0.0 ) addedSpacePerLetter = 0;
	
	for ( i = 0; i < [[self letters] length]; i++ )
	{
		NSString *aLetter = [[self letters] substringWithRange:NSMakeRange(i,1)];
		NSSize aSize = [aLetter sizeWithAttributes:attrs];
		
		NSRect aRect = NSMakeRect(offset ,0, aSize.width, bds.size.height);
		
		if ( aRect.origin.x + aRect.size.width <= bds.size.width )
			[self addCursorRect:aRect cursor:[NSCursor pointingHandCursor]];
		
		offset += aSize.width;
		offset += ( [[self font] pointSize] / 3 );
		
		offset += ( addedSpacePerLetter > kMaxAdditionalSpace ? kMaxAdditionalSpace : addedSpacePerLetter);
	}
}

- (float) requiredWidthForFont:(NSFont*)aFont
{
	NSInteger i, offset = 10;
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName, 
		[NSColor blackColor], NSForegroundColorAttributeName,
		textShadow, NSShadowAttributeName, nil];
	
	for ( i = 0; i < [[self letters] length]; i++ )
	{
		NSString *aLetter = [[self letters] substringWithRange:NSMakeRange(i,1)];
		NSSize aSize = [aLetter sizeWithAttributes:attrs];
		
		offset += aSize.width;
		offset += ( [[self font] pointSize] / 3 );
	}
	
	return offset;
}

#pragma mark -

- (void)mouseDown:(NSEvent *)theEvent
{
	NSInteger i, offset = 10;
	NSRect bds = [self bounds];
	NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		[self font], NSFontAttributeName, 
		[NSColor blackColor], NSForegroundColorAttributeName,
		textShadow, NSShadowAttributeName, nil];
		
	float addedSpacePerLetter = 0;
	addedSpacePerLetter = ( bds.size.width - [self requiredWidthForFont:[self font]] ) / [[self letters] length];
	if ( addedSpacePerLetter < 0.0 ) addedSpacePerLetter = 0;
	
	for ( i = 0; i < [[self letters] length]; i++ )
	{
		NSString *aLetter = [[self letters] substringWithRange:NSMakeRange(i,1)];
		NSSize aSize = [aLetter sizeWithAttributes:attrs];
		
		NSRect aRect = NSMakeRect(offset, 0, aSize.width, bds.size.height);
		
		if ( NSPointInRect(localPoint,aRect) )
		{
			if ( [[self target] respondsToSelector:[self action]] )
			{
				selectionRange = NSMakeRange(i,1);
				[[self target] performSelector:[self action] withObject:self];
			}
			
			break;
		}
		
		offset += aSize.width;
		offset += ( [[self font] pointSize] / 3 );
		offset += ( addedSpacePerLetter > kMaxAdditionalSpace ? kMaxAdditionalSpace : addedSpacePerLetter);
	}
}

@end
