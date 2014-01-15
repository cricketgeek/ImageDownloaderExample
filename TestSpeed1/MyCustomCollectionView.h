//
//  MyCustomCollectionView.h
//  TestSpeed1
//
//  Created by Mark Jones on 1/14/14.
//  Copyright (c) 2014 Mark Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCustomCollectionView : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
