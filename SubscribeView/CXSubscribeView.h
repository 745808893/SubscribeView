//
//  CXSubscribeView.h
//  CXSubscribeViewDemo
//
//  Created by wls on 2018/5/16.
//  Copyright © 2018年 ChaoXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#define STARTTIME @"startTime"
#define ENDTIME @"endTime"
#define WEEKTIME @"weekTime"
#define REMARK @"remark"
@protocol CXSubscribeViewDelegate <NSObject>
/**
 * 选中变化
 * info   {@"startTime":@"",@"endTime":@"",@"weekTime":@""}
 */
-(void)selecChangedWithInfo:(NSDictionary *)info;

@end
@interface CXSubscribeView : UIView
@property(nonatomic,weak) id <CXSubscribeViewDelegate> delegate;
@property(nonatomic,readonly)NSArray *headGridInfo;
@property(nonatomic,readonly)NSArray *leftGridInfo;
/**
 * 添加自己的预约
 * 数组元素为字典 {@"startTime":@"",@"endTime":@"",@"weekTime":@""}
 */
-(void)addSelectedDataWithSelectInfo:(NSArray *)selectInfo;

/**
 * 添加他人的预约
 * 数组元素为字典 {@"startTime":@"",@"endTime":@"",@"weekTime":@"",@"remark":@""}
 */
-(void)addOtherSelectedDataWithInfo:(NSArray *)otherSelectedInfo;

/**
 * 获取当前选中的预约
 * 数组元素为字典 {@"startTime":@"",@"endTime":@"",@"weekTime":@""}
 */
- (NSArray *)getCurrentSelectInfo;

@end
