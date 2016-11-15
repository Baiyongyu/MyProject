//
//  QMShortVideoController.h
//  inongtian
//
//  Created by KevinCao on 2016/10/28.
//  Copyright © 2016年 qianmo. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^ShortVideoSuccessBlock)(QMImageModel *);

@interface QMShortVideoController : BaseViewController
@property (nonatomic, assign) NSTimeInterval videoMaximumDuration;
@property (nonatomic, assign) NSTimeInterval videoMinimumDuration;

@property(nonatomic,copy)ShortVideoSuccessBlock shortVideoSuccessBlock;
@end