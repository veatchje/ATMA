//
//  FolderCollectionViewCell.m
//  TrackApp
//
//  Created by Collins, Brian C  on 1/24/13.
//  Copyright (c) 2013 ATMA. All rights reserved.
//

//BRIAN CODE START

#import "FolderCollectionViewCell.h"

@implementation FolderCollectionViewCell
@synthesize folderImage = _folderImage;
@synthesize folderName = _folderName;


// TODO: Find out what todo.
- (id)initWithFrame:(CGRect)frame
{
    printf("Init");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
        tap.numberOfTapsRequired = 1;
        
        [self addGestureRecognizer:tap];
        printf("tap added to cell: %s", [self.folderName.text UTF8String]);
        //[tap release];
    }
    return self;
}

- (void)veiwTapped:(id)sender
{
    printf("Cell tapped: %s", [self.folderName.text UTF8String]);
}



- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSelector:@selector(singleTapOnCell:) withObject:indexPath];
    // TODO: Folder change code here!
    
    
    printf("%d", [indexPath row]);
}

@end

//BRIAN CODE END