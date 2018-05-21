//
//  UIView+DrawGrid.h
//  CXSubscribeViewDemo
//
//  Created by wls on 2018/5/15.
//  Copyright © 2018年 ChaoXing. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,LineDirectionType) {
    VerticalType,      //垂直
    HorizontalType     //水平
};
@interface UIView (DrawGrid)
    
/**
  * 创建一个表格
  * line：列数
  * columns：行数
  * data：数据
  * lineColor 分割线的颜色
*/
- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas lineColor:(UIColor *)color;
    
    
/**
  * 创建一个表格
  * line：列数
  * columns：行数
  * data：数据
  * lineInfo：行信息，传入格式：@{@"0" : @"3"}意味着第一行创建3个格子
  * lineColor 分割线的颜色
*/
- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas lineInfo:(NSDictionary *)lineInfo lineColor:(UIColor *)color;
    
/**
  * 创建一个表格
  * line：列数
  * columns：行数
  * data：数据
  * colorInfo：颜色信息，传入格式：@{@"0" : [UIColor redColor]}意味着第一个格子文字将会变成红色
  * lineColor 分割线的颜色
*/
- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas colorInfo:(NSDictionary *)colorInfo lineColor:(UIColor *)color;
/**
 * 创建一个表格
 * line：列数
 * columns：行数
 * data：数据
 * colorInfo：颜色信息，传入格式：@{@"0" : [UIColor redColor]}意味着第一个格子文字将会变成红色
 * lineInfo：行信息，传入格式：@{@"0" : @"3"}意味着第一行创建3个格子
 * lineColor 分割线的颜色
 */
- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas colorInfo:(NSDictionary *)colorInfo lineInfo:(NSDictionary *)lineInfo lineColor:(UIColor *)color;
/**
 * 创建一个表格
 * line：列数
 * columns：行数
 * data：数据
 * colorInfo：颜色信息，传入格式：@{@"0" : [UIColor redColor]}意味着第一个格子文字将会变成红色
 * lineInfo：行信息，传入格式：@{@"0" : @"3"}意味着第一行创建3个格子
 * backgroundColorInfo：行信息，传入格式：@{@"0" : [UIColor redColor]}意味着第一个格子背景颜色变成红色
 * lineColor 分割线的颜色
 */
- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas colorInfo:(NSDictionary *)colorInfo lineInfo:(NSDictionary *)lineInfo backgroundColorInfo:(NSDictionary *)backgroundColorInfo lineColor:(UIColor *)color;
/**
 * 获取第index个格子的label
 */
- (UILabel *)getLabelWithIndex:(NSInteger)index;
    
/**
 * 画一条线
 * frame: 线的frame
 * color：线的颜色
 * lineWidth：线宽
 */
- (void)drawLineWithFrame:(CGRect)frame lineType:(LineDirectionType)lineType color:(UIColor *)color lineWidth:(CGFloat)lineWidth;
@end
