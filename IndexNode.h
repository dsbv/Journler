//
//  IndexNode.h
//  Journler
//
//  Created by Philip Dow on 2/6/07.
//  Copyright 2007 Sprouted, Philip Dow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JournlerObject;

@interface IndexNode : NSObject <NSCopying> {
	
	NSInteger count;
	NSInteger frequency;
	NSString *title;
	
	IndexNode *parent;
	NSArray *children;
	
	id representedObject;
}

- (int) count;
- (void) setCount:(int)aCount;

- (int) frequency;
- (void) setFrequency:(int)aFrequency;

- (NSString*) title;
- (void) setTitle:(NSString*)aString;

- (id) representedObject;
- (void) setRepresentedObject:(id)anObject;

- (IndexNode*) parent;
- (void) setParent:(IndexNode*)aNode;

- (NSArray*) children;
- (void) setChildren:(NSArray*)anArray;

- (unsigned) childCount;
- (BOOL) isLeaf;

@end
