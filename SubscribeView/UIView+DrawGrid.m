//
//  UIView+DrawGrid.m
//  CXSubscribeViewDemo
//
//  Created by wls on 2018/5/15.
//  Copyright © 2018年 ChaoXing. All rights reserved.
//

#import "UIView+DrawGrid.h"
#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)

#define ItemTag 180503

@implementation UIView (DrawGrid)
- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas colorInfo:(NSDictionary *)colorInfo lineColor:(UIColor *)color{
    [self drawListWithRect:rect line:line columns:columns datas:datas colorInfo:colorInfo lineInfo:nil lineColor:color];
}

- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas colorInfo:(NSDictionary *)colorInfo lineInfo:(NSDictionary *)lineInfo lineColor:(UIColor *)color{
    [self drawListWithRect:rect line:line columns:columns datas:datas colorInfo:colorInfo lineInfo:lineInfo backgroundColorInfo:nil lineColor:color];
}

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
- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas colorInfo:(NSDictionary *)colorInfo lineInfo:(NSDictionary *)lineInfo backgroundColorInfo:(NSDictionary *)backgroundColorInfo lineColor:(UIColor *)color{
    NSInteger index = 0;
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat h = (1.0) * rect.size.height / columns;
    NSInteger newLine = 0;
    for (NSInteger i = 0; i < columns; i++) {
        
        // 判断合并单元格
        if (lineInfo) {
            for (NSInteger a = 0; a < lineInfo.allKeys.count; a++) {
                
                // 新的列数
                NSInteger newColumn = [lineInfo.allKeys[a] integerValue];
                if (i == newColumn) {
                    newLine = [lineInfo[lineInfo.allKeys[a]] integerValue];
                } else {
                    newLine = line;
                }
            }
        } else {
            newLine = line;
        }
        
        for (NSInteger j = 0; j < newLine; j++) {
            CGFloat w = (1.0) * rect.size.width / newLine;
            CGRect frame = (CGRect){x + w * j, y + h * i, w, h};
            // 画线
            [self drawRectWithRect:frame lineColor:color];
            
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            UIColor *textColor = [colorInfo objectForKey:[NSString stringWithFormat:@"%ld", (long)index]];
            if (!textColor) {
                textColor = [UIColor grayColor];
            }
            label.textColor = textColor;
            UIColor *backgroundColor = [backgroundColorInfo objectForKey:[NSString stringWithFormat:@"%ld", (long)index]];
            if (!backgroundColor) {
                backgroundColor = [UIColor clearColor];
            }
            label.backgroundColor = backgroundColor;
            label.font = [UIFont systemFontOfSize:13];
            label.text = datas[index];
            label.numberOfLines = 0;
            label.tag = ItemTag + index;
            index++;
        }
    }
}

- (void)drawRectWithRect:(CGRect)rect lineColor:(UIColor *)color{
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat w = (1.0) * rect.size.width;
    CGFloat h = (1.0) * rect.size.height;
    if (((int)(y * [UIScreen mainScreen].scale) + 1) % 2 == 0) {
        y += SINGLE_LINE_ADJUST_OFFSET;
    }
    if (((int)(x * [UIScreen mainScreen].scale) + 1) % 2 == 0) {
        x += SINGLE_LINE_ADJUST_OFFSET;
    }
    [self drawLineWithFrame:(CGRect){x, y, w, 1} type:1 color:color];
    [self drawLineWithFrame:(CGRect){x + w, y, 1, h} type:2 color:color];
    [self drawLineWithFrame:(CGRect){x, y + h, w, 1} type:1 color:color];
    [self drawLineWithFrame:(CGRect){x, y, 1, h} type:2 color:color];
}

- (void)drawLineWithFrame:(CGRect)frame lineType:(LineDirectionType)lineType color:(UIColor *)color lineWidth:(CGFloat)lineWidth {
    // 创建贝塞尔曲线
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    linePath.lineWidth = lineWidth;
    [linePath moveToPoint:CGPointMake(0, 0)];
    // 重点：判断是水平方向还是垂直方向
    [linePath addLineToPoint: lineType == HorizontalType ? CGPointMake(frame.size.width, 0) : CGPointMake(0, frame.size.height)];
    // 创建CAShapeLayer
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.strokeColor = color.CGColor;
    lineLayer.lineWidth = lineWidth;
    lineLayer.frame = frame;
    lineLayer.path = linePath.CGPath;
    [self.layer addSublayer:lineLayer];
}

- (void)drawLineWithFrame:(CGRect)frame type:(NSInteger)type color:(UIColor *)color {
    [self drawLineWithFrame:frame lineType:type color:color lineWidth:0.7];
}

- (void)drawLineWithFrame:(CGRect)frame type:(NSInteger)type {
    [self drawLineWithFrame:frame type:type color:[UIColor blackColor]];
}

/**
 * 创建一个表格
 * line：列数
 * columns：行数
 * data：数据
 * lineColor 分割线的颜色
 */
- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas lineColor:(UIColor *)color{
    [self drawListWithRect:rect line:line columns:columns datas:datas colorInfo:nil lineColor:color];
}

/**
 * 创建一个表格
 * line：列数
 * columns：行数
 * data：数据
 * lineInfo：行信息，传入格式：@{@"0" : @"3"}意味着第一行创建3个格子
 * lineColor 分割线的颜色
 */
- (void)drawListWithRect:(CGRect)rect line:(NSInteger)line columns:(NSInteger)columns datas:(NSArray *)datas lineInfo:(NSDictionary *)lineInfo lineColor:(UIColor *)color{
    [self drawListWithRect:rect line:line columns:columns datas:datas colorInfo:nil lineInfo:lineInfo lineColor:color];
}

// 根据tag拿到对应的label
- (UILabel *)getLabelWithIndex:(NSInteger)index {
    // 防止重复的tag，拿到第一个
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)v;
            if (v.tag == index + ItemTag) {
                return label;
            }
        }
    }
    return [self viewWithTag:index + ItemTag];
}
@end
