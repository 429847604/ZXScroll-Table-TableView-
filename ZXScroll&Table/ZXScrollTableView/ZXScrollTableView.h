//
//  ZXScrollTableView.h
//  PartyMaster
//
//  Created by zhaoxu on 16/4/11.
//  Copyright © 2016年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZXScrollTableViewDelegate <NSObject>

- (void)scrollViewChange:(CGFloat)x;
- (void)scrollViewDidTheTag:(NSInteger)theTag;

@end

@interface ZXScrollTableView : UIView

@property (weak,nonatomic) id<ZXScrollTableViewDelegate> delegate;

@property (assign,nonatomic) NSInteger btnTag;
@property (assign,nonatomic) int tableCount;

@end
