//
//  LockoutController.m
//  Journler
//
//  Created by Philip Dow on 10/24/06.
//  Copyright 2006 Sprouted, Philip Dow. All rights reserved.
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

#import "LockoutController.h"
#import "NSString+JournlerAdditions.h"

#import <SproutedUtilities/SproutedUtilities.h>
#import <SproutedInterface/SproutedInterface.h>

#warning progress indicator: progress

@implementation LockoutController

- (id) initWithPassword:(NSString*)aString
{
	if ( self = [super initWithWindowNibName:@"Lockout"] ) 
	{
		numAttempts = 1;
		mode = kLockoutModePassword;
		checksum = nil;
		validatedPassword = nil;
		password = [aString copyWithZone:[self zone]];
	}
	return self;
}

- (id) initWithChecksum:(NSString*)aString
{
	if ( self = [super initWithWindowNibName:@"Lockout"] ) 
	{
		numAttempts = 1;
		mode = kLockoutModeChecksum;
		password = nil;
		validatedPassword = nil;
		checksum = [aString copyWithZone:[self zone]];
	}
	return self;
}

- (void) awakeFromNib
{
	NSInteger borders[4] = {0,0,0,0};
	[gradient setBorders:borders];
	[gradient setBordered:NO];
}

- (void) dealloc 
{
	[password release];
	[checksum release];
	[validatedPassword release];
	
	[super dealloc];
}

#pragma mark -

- (BOOL) confirmPassword 
{
	return ( [NSApp runModalForWindow:[self window]] == NSRunStoppedResponse );
}

- (BOOL) confirmChecksum
{
	return ( [NSApp runModalForWindow:[self window]] == NSRunStoppedResponse );
}

- (NSString*) validatedPassword
{
	return validatedPassword;
}

#pragma mark -

- (IBAction) okay:(id)sender 
{
	//NSLog(@"%s - beginning",__PRETTY_FUNCTION__);
	
	NSString *passwordCheck = [passwordField stringValue];
	
	if ( mode == kLockoutModePassword )
	{
		//NSLog(@"%s - kLockoutModePassword, beginning",__PRETTY_FUNCTION__);
		
		if ( [passwordCheck isEqualToString:password] ) 
		{
			//NSLog(@"%s - correct password, stopping modal, beginning",__PRETTY_FUNCTION__);
			
			validatedPassword = [passwordCheck retain];
			[NSApp stopModal];
			
			//NSLog(@"%s - correct password, stopping modal, ending",__PRETTY_FUNCTION__);
		}
		else 
		{
			//NSLog(@"%s - incorrect password, beginning",__PRETTY_FUNCTION__);
			
			NSBeep();
			if ( ++numAttempts > 3 )
				[NSApp abortModal];
				
			[attemptsField setStringValue:[NSString stringWithFormat:@"%i/3",numAttempts]];
			
			//NSLog(@"%s - incorrect password, ending",__PRETTY_FUNCTION__);
		}
		
		//NSLog(@"%s - kLockoutModePassword, ending",__PRETTY_FUNCTION__);
	}
	else if ( mode == kLockoutModeChecksum )
	{
		//NSLog(@"%s - kLockoutModeChecksum, beginning",__PRETTY_FUNCTION__);
		
		NSString *aDigest = [passwordCheck journlerMD5Digest];
		if ( [aDigest isEqualToString:checksum] ) 
		{
			//NSLog(@"%s - correct password, stopping modal, beginning",__PRETTY_FUNCTION__);
			
			validatedPassword = [passwordCheck retain];
			[NSApp stopModal];
			
			//NSLog(@"%s - correct password, stopping modal, ending",__PRETTY_FUNCTION__);
		}
		else 
		{
			//NSLog(@"%s - incorrect password, beginning",__PRETTY_FUNCTION__);
			
			NSBeep();
			if ( ++numAttempts > 3 )
				[NSApp abortModal];
				
			[attemptsField setStringValue:[NSString stringWithFormat:@"%i/3",numAttempts]];
			
			//NSLog(@"%s - incorrect password, ending",__PRETTY_FUNCTION__);
		}
		
		//NSLog(@"%s - kLockoutModeChecksum, ending",__PRETTY_FUNCTION__);
	}
	
	//NSLog(@"%s - ending",__PRETTY_FUNCTION__);
}

- (IBAction) cancel:(id)sender 
{
	[NSApp abortModal];
}

- (IBAction) hide:(id)sender 
{	
	[NSApp hide:sender];
}

- (IBAction) unhide:(id)sender
{
	[[self window] setDefaultButtonCell:[okButton cell]];
	[[self window] enableKeyEquivalentForDefaultButtonCell];
}

- (IBAction) showProgressIndicator:(id)sender
{
	//NSLog(@"%s - beginning",__PRETTY_FUNCTION__);
	
	if ( ![self isWindowLoaded] )
		[self window];
	
	//NSLog(@"[progress setIndeterminate:YES]");
	[progress setIndeterminate:YES];
	
	//NSLog(@"[progress setHidden:NO]");
	[progress setHidden:NO];
	
	//NSLog(@"[progressLabel setHidden:NO]");
	[progressLabel setHidden:NO];
	
	//NSLog(@"[progressLabel display]");
	[progressLabel display];
	
	//NSLog(@"[progress startAnimation:sender]");
	[progress startAnimation:sender];
	
	//[[self window] display];
	
	//NSLog(@"%s - ending",__PRETTY_FUNCTION__);
}

- (IBAction) hideProgressIndicator:(id)sender
{
	if ( ![self isWindowLoaded] )
		[self window];

	[progress stopAnimation:sender];
	[progress setHidden:YES];
	[progressLabel setHidden:YES];
	
	//[[self window] display];
}

- (IBAction) enableLockedOutControls:(id)sender
{
	if ( ![self isWindowLoaded] )
		[self window];

	[lockoutField setHidden:NO];
	[hideButton setHidden:NO];
}

@end
