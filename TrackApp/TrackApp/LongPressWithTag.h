//
//  LongPressWithTag.h
//  TrackApp
//
//  Created by Veatch, James E on 5/15/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LongPressWithTag : UILongPressGestureRecognizer {

    NSInteger* tag;
    
}

- (void) setTag: (NSInteger) newTag;
- (NSInteger) getTag;

@end
