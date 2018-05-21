//
//  CXSubscribeView.m
//  CXSubscribeViewDemo
//
//  Created by wls on 2018/5/16.
//  Copyright © 2018年 ChaoXing. All rights reserved.
//

#import "CXSubscribeView.h"
#import "UIView+DrawGrid.h"
#define SCREENW [UIScreen mainScreen].bounds.size.width
#define SCREENH [UIScreen mainScreen].bounds.size.height
#define ITEMWIDTH SCREENW/6
#define ITEMHRIGHT 40
#define SELECTINGCOLOR [UIColor colorWithRed:0.99 green:0.80 blue:0.80 alpha:1.00]
//列
#define CONTENTLINE 7
//行
#define CONTENTCOLUMN 10

#define KLIVEISIPHONEX  MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width)==812.0
#define IPHONEXLIVETOPSPACE      (KLIVEISIPHONEX?24:0)
#define IPHONEXLIVEBOTTOMSPACE   (KLIVEISIPHONEX?34:0)

//需求只返回上到下的
typedef struct {
    int top;
    int bottom;
}vRange;

@interface CXSubscribeView ()
@property (nonatomic,strong) UIScrollView *bgScrollView;
@property (nonatomic,strong) UIScrollView *contentScrollView;
@property (nonatomic,strong) UIView *subscribeHeadView;
@property (nonatomic,strong) UIView *subscribeLeftView;
@property (nonatomic,strong) UIView *subscribeView;
@property (nonatomic,strong) UILongPressGestureRecognizer *swipeToChooseGesture;
@property (nonatomic,strong) UITapGestureRecognizer *tapToChooseGesture;
@property (nonatomic,strong) NSMutableArray *isSelectArr;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *otherSubscribedArr;
@property (nonatomic,strong) NSMutableArray *subscribedArr;
@property (nonatomic,strong) NSMutableArray *unableSelectArr;
@property (nonatomic,strong) NSMutableArray *currentSelectArr;
@property (nonatomic,assign) NSInteger lastPressedIndex;
@property (nonatomic,strong) NSArray *leftTimeArr;
@property (nonatomic,strong) NSArray *headTimeArr;
//多选开始的列
@property (nonatomic,assign) NSInteger mutSelectStartLine;
//多选开始的Index
@property (nonatomic,assign) NSInteger mutSelectStartIndex;
@end

@implementation CXSubscribeView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpUI];
        _lastPressedIndex = -1;
    }
    return self;
}
//确认预约
- (NSArray *)getCurrentSelectInfo{
    NSLog(@"%@",self.isSelectArr);
    if (self.currentSelectArr.count>0) {
        [self.currentSelectArr removeAllObjects];
    }
    for (int i=0; i<self.isSelectArr.count; i++) {
        if ([self.isSelectArr[i] isEqualToString:@"1"]) {
            [self.currentSelectArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    NSMutableArray *resuleLineArr = [NSMutableArray array];
    for (int i =0; i<self.headTimeArr.count; i++) {
        NSMutableArray *tmpLineArr = [NSMutableArray array];
        for (NSString*index in self.currentSelectArr) {
            NSInteger line = [self getlineWithIndex:[index integerValue]];
            if (line == i) {
                [tmpLineArr addObject:index];
            }
        }
        if (tmpLineArr.count>0) {
            [resuleLineArr addObject:tmpLineArr];
        }
    }
    //    NSMutableArray *pieceArr = [NSMutableArray array];
    //    NSMutableDictionary *submitInfo = [NSMutableDictionary dictionary];
    NSMutableArray *selectInfo = [NSMutableArray array];
    int count = CONTENTCOLUMN*CONTENTLINE;
    int arr1D[count];
    for(int k=0;k<count;k++)
    {
        arr1D[k] = [self.isSelectArr[k] intValue];
    }
    int arr2D[CONTENTCOLUMN][CONTENTLINE];
    int m,n;
    //一维维整型数组转换为二维整型数组
    for(m=0;m<CONTENTCOLUMN;m++)
    {
        for(n=0;n<CONTENTLINE;n++)
        {
            arr2D[m][n]=arr1D[m*CONTENTLINE+n];
        }
    }
    for (int i =0; i<resuleLineArr.count; i++) {
        NSMutableArray *tmpmutarr = resuleLineArr[i];
        if (tmpmutarr.count>1) {
            //如果大于一个，需要遍历将连续的找出来
            int j;
            for ( j = 0; j<tmpmutarr.count; j++) {
                NSInteger tmpIndex = [tmpmutarr[j] integerValue];
                int tmpLine = (short)[self getlineWithIndex:tmpIndex];
                int tmpColumn = (short)[self getcolumnWithIndex:tmpIndex];
                vRange range = funVerticalContinuousRange(arr2D, tmpColumn, tmpLine);
                if (range.top == range.bottom) {
                    //只有一个选中
                    NSDictionary *info = [self getSelectInfoWithIndex:tmpIndex];
                    [selectInfo addObject:info];
                }else{
                    //有多个选中
                    //相邻的结束的行
                    int startColumn = range.top;
                    int endColumn = range.bottom;
                    int lastSelectColumnIndex = (short)[self getcolumnWithIndex:[[tmpmutarr lastObject] integerValue]];
                    int startIndex = CONTENTLINE*startColumn + tmpLine;
                    int endIndex = CONTENTLINE*endColumn + tmpLine;
                    if (endColumn == lastSelectColumnIndex) {
                        NSDictionary *info = [self getSelectInfoWithStartColumn:startIndex endColumn:endIndex];
                        [selectInfo addObject:info];
                        break;
                    }else{
                        NSDictionary *info = [self getSelectInfoWithStartColumn:startIndex endColumn:endIndex];
                        [selectInfo addObject:info];
                        NSString *endObj = [NSString stringWithFormat:@"%d",endIndex];
                        int nextIndex = (short)[tmpmutarr indexOfObject:endObj];
                        j = nextIndex;
                    }
                }
            }
            
        }else{
            //如果这一列里就只选中一个直接添加
            NSDictionary *info = [self getSelectInfoWithIndex:[tmpmutarr[0] integerValue]];
            [selectInfo addObject:info];
        }
    }
    NSLog(@"预约的信息%@",selectInfo);
    return [selectInfo copy];
}
//配置自己预约的
-(void)addSelectedDataWithSelectInfo:(NSArray *)selectInfo{
    if (selectInfo&&selectInfo.count>0) {
        for (NSDictionary *info in selectInfo) {
            [self configSelectedDataWithStartTime:info[STARTTIME] endTime:info[ENDTIME] date:info[WEEKTIME] text:@"已预约"];
        }
    }
}
-(void)configSelectedDataWithStartTime:(NSString *)start endTime:(NSString *)end date:(NSString *)date text:(NSString *)text{
    NSInteger startIndex = [self getTimeIndexWithTime:start];
    NSInteger endIndex = [self getTimeIndexWithTime:end];
    NSInteger lineIndex = [self getlineWithDateTime:date];
    CGRect frame = CGRectMake(ITEMWIDTH*lineIndex, ITEMHRIGHT*startIndex, ITEMWIDTH, ITEMHRIGHT*(endIndex-startIndex));
    [self.unableSelectArr addObject:@(frame)];
    [self configSubscribeWithFrame:frame text:text];
}
-(void)configSubscribeWithFrame:(CGRect)frame text:(NSString *)text{
    CGRect tframe = frame;
    CAShapeLayer *selectionLayer = [[CAShapeLayer alloc] init];
    selectionLayer.fillColor = [UIColor clearColor].CGColor;
    selectionLayer.actions = @{@"hidden":[NSNull null]};
    CAGradientLayer *gradientLayer2 =  [CAGradientLayer layer];
    gradientLayer2.frame = tframe;
    [gradientLayer2 setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.96 green:0.84 blue:0.43 alpha:1.00] CGColor],(id)[[UIColor colorWithRed:0.98 green:0.75 blue:0.44 alpha:1.00] CGColor], nil]];
    [gradientLayer2 setLocations:@[@0.33,@0.66,@1]];
    [gradientLayer2 setStartPoint:CGPointMake(0, 0)];
    [gradientLayer2 setEndPoint:CGPointMake(1, 1)];
    [self.subscribeView.layer addSublayer:gradientLayer2];
    UILabel *textLabl = [[UILabel alloc] initWithFrame:tframe];
    textLabl.text = text;
    textLabl.textColor = [UIColor whiteColor];
    textLabl.backgroundColor = [UIColor clearColor];
    textLabl.textAlignment = NSTextAlignmentCenter;
    textLabl.font = [UIFont systemFontOfSize:13];
    textLabl.numberOfLines = 0;
    [self.subscribeView addSubview:textLabl];
}
//配置他人预约的
-(void)addOtherSelectedDataWithInfo:(NSArray *)otherSelectedInfo{
    if (otherSelectedInfo) {
        for (NSDictionary *infoDic in otherSelectedInfo) {
            [self configOtherSelectedDataWithStartTime:infoDic[STARTTIME] endTime:infoDic[ENDTIME] date:infoDic[WEEKTIME] text:infoDic[REMARK]];
        }
    }
}
-(void)configOtherSelectedDataWithStartTime:(NSString *)start endTime:(NSString *)end date:(NSString *)date text:(NSString *)text{
    NSInteger startIndex = [self getTimeIndexWithTime:start];
    NSInteger endIndex = [self getTimeIndexWithTime:end];
    NSInteger lineIndex = [self getlineWithDateTime:date];
    CGRect frame = CGRectMake(ITEMWIDTH*lineIndex, ITEMHRIGHT*startIndex, ITEMWIDTH, ITEMHRIGHT*(endIndex-startIndex));
    [self.unableSelectArr addObject:@(frame)];
    [self configOtherSubscribeWithFrame:frame text:text];
}
-(void)configOtherSubscribeWithFrame:(CGRect)frame text:(NSString *)text{
    CGRect tframe = frame;
    CAShapeLayer *selectionLayer = [[CAShapeLayer alloc] init];
    selectionLayer.fillColor = [UIColor clearColor].CGColor;
    selectionLayer.actions = @{@"hidden":[NSNull null]};
    CAGradientLayer *gradientLayer2 =  [CAGradientLayer layer];
    gradientLayer2.frame = tframe;
    [gradientLayer2 setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] CGColor],(id)[[UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] CGColor], nil]];
    [gradientLayer2 setLocations:@[@0.33,@0.66,@1]];
    [gradientLayer2 setStartPoint:CGPointMake(0, 0)];
    [gradientLayer2 setEndPoint:CGPointMake(1, 1)];
    [self.subscribeView.layer addSublayer:gradientLayer2];
    UILabel *textLabl = [[UILabel alloc] initWithFrame:tframe];
    textLabl.text = text;
    textLabl.textColor = [UIColor whiteColor];
    textLabl.backgroundColor = [UIColor clearColor];
    textLabl.textAlignment = NSTextAlignmentCenter;
    textLabl.numberOfLines = 0;
    textLabl.font = [UIFont systemFontOfSize:13];
    [self.subscribeView addSubview:textLabl];
}
//选中时更新具体时间信息
- (void)updateCurrentSelecedDateWithStartTimeIndex:(NSInteger)startIndex endTimeIndex:(NSInteger)endIndex{
    NSString *selectStartTime = @"00:00";
    NSString *selectEndTime = @"00:00";
    NSString *selectWeekTime = @"--";
    if (startIndex == endIndex) {
        //选中一个格子
        NSDictionary *dic = [self getSelectInfoWithIndex:endIndex];
        selectStartTime = dic[STARTTIME];
        selectEndTime = dic[ENDTIME];
        selectWeekTime = dic[WEEKTIME];
    }else{
        //选中相邻多个格子
        NSDictionary *startDic = [self getSelectInfoWithIndex:startIndex];
        NSDictionary *endDic = [self getSelectInfoWithIndex:endIndex];
        selectStartTime = startDic[STARTTIME];
        selectEndTime = endDic[ENDTIME];
        selectWeekTime = endDic[WEEKTIME];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(selecChangedWithInfo:)]) {
        [self.delegate selecChangedWithInfo:@{STARTTIME:selectStartTime,ENDTIME:selectEndTime,WEEKTIME:selectWeekTime}];
    }
//    NSLog(@"开始时间：%@,结束时间：%@,当前日期：%@",selectStartTime,selectEndTime,selectWeekTime);
}
- (void)handleTapToChoose:(UIPanGestureRecognizer *)gesture{
    CGPoint translatedPoint = [gesture locationInView:self.subscribeView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            
        case UIGestureRecognizerStateChanged: {
            
            break;
        }
        case UIGestureRecognizerStateEnded:
            for (NSInteger i = 0; i < CONTENTLINE*CONTENTCOLUMN; i ++) {
                if (![self isSubscribedContainsPoint:translatedPoint]) {
                    UILabel *label = [self.subscribeView getLabelWithIndex:i];
                    bool iscontains = CGRectContainsPoint(label.frame,translatedPoint);
                    if (iscontains) {
                        if ([self.isSelectArr[i] isEqualToString:@"0"]) {
                            self.isSelectArr[i] = @"1";
                            label.backgroundColor = SELECTINGCOLOR;
                            label.textColor = [UIColor redColor];
                            [self updateCurrentSelecedDateWithStartTimeIndex:i endTimeIndex:i];
                        }
                        //                        else if ([self.isSelectArr[i] isEqualToString:@"1"]){
                        //                            self.isSelectArr[i] = @"0";
                        //                            label.backgroundColor = [UIColor clearColor];
                        //                            label.textColor = [UIColor grayColor];
                        //                        }
                    }
                    else{
                        if ([self.isSelectArr[i] isEqualToString:@"1"]) {
                            self.isSelectArr[i] = @"0";
                            label.backgroundColor = [UIColor clearColor];
                            label.textColor = [UIColor grayColor];
                        }
                    }
                }
            }
        case UIGestureRecognizerStateCancelled: {
            break;
        }
        default:
            break;
    }
    
}
- (void)handleSwipeToChoose:(UILongPressGestureRecognizer *)pressGesture
{
    CGPoint translatedPoint = [pressGesture locationInView:self.subscribeView];
    switch (pressGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            for (NSInteger i = 0; i < CONTENTLINE*CONTENTCOLUMN; i ++) {
                if ([self.isSelectArr[i] isEqualToString:@"1"]){
                    self.isSelectArr[i] = @"0";
                    UILabel *label = [self.subscribeView getLabelWithIndex:i];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor grayColor];
                }
            }
            for (NSInteger i = 0; i < CONTENTLINE*CONTENTCOLUMN; i ++) {
                if (![self isSubscribedContainsPoint:translatedPoint]) {
                    UILabel *label = [self.subscribeView getLabelWithIndex:i];
                    bool iscontains = CGRectContainsPoint(label.frame,translatedPoint);
                    if (iscontains ) {
                        _mutSelectStartLine = [self getlineWithIndex:i];
                        _mutSelectStartIndex = i;
                    }
                }
            }
        }
        case UIGestureRecognizerStateChanged: {
            for (NSInteger i = 0; i < CONTENTLINE*CONTENTCOLUMN; i ++) {
                if (![self isSubscribedContainsPoint:translatedPoint]) {
                    UILabel *label = [self.subscribeView getLabelWithIndex:i];
                    bool iscontains = CGRectContainsPoint(label.frame,translatedPoint);
                    if (iscontains && self.lastPressedIndex != i) {
                        self.lastPressedIndex = i;
                        NSInteger currentLine = [self getlineWithIndex:i];
                        if ([self.isSelectArr[i] isEqualToString:@"0"]&&currentLine == _mutSelectStartLine) {
                            self.isSelectArr[i] = @"1";
                            label.backgroundColor = SELECTINGCOLOR;
                            label.textColor = [UIColor redColor];
                        }
                        //                        else if ([self.isSelectArr[i] isEqualToString:@"1"]){
                        //                            self.isSelectArr[i] = @"0";
                        //                            label.backgroundColor = [UIColor clearColor];
                        //                            label.textColor = [UIColor grayColor];
                        //                        }
                        NSArray *pomitArr = [self getCurrentLineItemFromIndex:_mutSelectStartIndex toIndex:i];
                        for (NSString *pomitStr in pomitArr) {
                            NSInteger pomitIndex = [pomitStr integerValue];
                            if ([self.isSelectArr[pomitIndex] isEqualToString:@"0"]) {
                                self.isSelectArr[pomitIndex] = @"1";
                                UILabel *pomitLabel = [self.subscribeView getLabelWithIndex:pomitIndex];
                                pomitLabel.backgroundColor = SELECTINGCOLOR;
                                pomitLabel.textColor = [UIColor redColor];
                            }
                        }
                    }
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{
            for (NSInteger i = 0; i < CONTENTLINE*CONTENTCOLUMN; i ++) {
                if (![self isSubscribedContainsPoint:translatedPoint]) {
                    UILabel *label = [self.subscribeView getLabelWithIndex:i];
                    bool iscontains = CGRectContainsPoint(label.frame,translatedPoint);
                    if (iscontains ) {
                        [self updateCurrentSelecedDateWithStartTimeIndex:_mutSelectStartIndex endTimeIndex:i];
                    }
                }
            }
        }
            break;
        case UIGestureRecognizerStateCancelled: {
            self.lastPressedIndex = -1;
            break;
        }
        default:
            break;
    }
    
}
//获取最终的起止时间和对应的日期
-(NSDictionary *)getSelectInfoWithIndex:(NSInteger)index{
    NSDictionary *setimeDic = [self getTimeStrWithInex:index];
    NSString *weekTime = [self getWeekTimeWithTime:index];
    NSMutableDictionary *tmpInfo = [NSMutableDictionary dictionary];
    [tmpInfo setObject:setimeDic[STARTTIME] forKey:STARTTIME];
    [tmpInfo setObject:setimeDic[ENDTIME] forKey:ENDTIME];
    [tmpInfo setObject:weekTime forKey:WEEKTIME];
    return [tmpInfo copy];
}
-(NSDictionary *)getSelectInfoWithStartColumn:(NSInteger)startIndex endColumn:(NSInteger)endIndex {
    NSDictionary *startTimeDic = [self getTimeStrWithInex:startIndex];
    NSDictionary *endTimeDic = [self getTimeStrWithInex:endIndex];
    //这里用起止都已一样因为在同一列
    NSString *weekTime = [self getWeekTimeWithTime:startIndex];
    NSMutableDictionary *tmpInfo = [NSMutableDictionary dictionary];
    [tmpInfo setObject:startTimeDic[STARTTIME] forKey:STARTTIME];
    [tmpInfo setObject:endTimeDic[ENDTIME] forKey:ENDTIME];
    [tmpInfo setObject:weekTime forKey:WEEKTIME];
    return [tmpInfo copy];
}
//获取对应的日期
- (NSString *)getWeekTimeWithTime:(NSInteger)index{
    NSArray *timeArr = self.headTimeArr;
    NSInteger lineIndex = [self getlineWithIndex:index];
    NSString *tmpWeekTime = @"";
    for (int i=0; i<timeArr.count; i++) {
        if (lineIndex == i) {
            tmpWeekTime = self.headTimeArr[i];
        }
    }
    return tmpWeekTime;
}
//获取所在index（起点0）单选
- (NSInteger)getIndexWithStartTime:(NSString *)start endTime:(NSString *)end date:(NSString *)date{
    NSInteger lineIndex = [self getlineWithDateTime:date];
    NSInteger columnIndex = [self getcolumnWithStartTime:start endTime:end];
    return lineIndex*self.headTimeArr.count+columnIndex;
}
//获取所在列 (起点为0) 单选
- (NSInteger)getlineWithDateTime:(NSString *)time{
    NSArray *timeArr = self.headTimeArr;
    NSInteger lineIndex = 0;
    for (int i=0; i<timeArr.count; i++) {
        if ([time isEqualToString:timeArr[i]]) {
            lineIndex = i;
        }
    }
    return lineIndex;
}
//(起点为0)
- (NSInteger)getlineWithIndex:(NSInteger)index{
    return index%7;
}
//获取所在行 (起点为0) 单选
- (NSInteger)getcolumnWithStartTime:(NSString *)start endTime:(NSString *)end{
    NSArray *timeArr = self.leftTimeArr;
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    for (int i=0; i<timeArr.count; i++) {
        if ([start isEqualToString:timeArr[i]]) {
            startIndex = i;
        }
        if ([end isEqualToString:timeArr[i]]) {
            endIndex = i;
        }
    }
    return endIndex-startIndex-1;
}
//(起点为0)
- (NSInteger)getcolumnWithIndex:(NSInteger)index{
    return index/7;
}
//行时间转换index
- (NSInteger)getTimeIndexWithTime:(NSString *)time{
    NSArray *timeArr = self.leftTimeArr;
    NSInteger tindex = 0;
    for (int i=0; i<timeArr.count; i++) {
        if ([time isEqualToString:timeArr[i]]) {
            tindex = i;
        }
    }
    return tindex;
}
//获取所在行对应的起止时间
- (NSDictionary *)getTimeStrWithInex:(NSInteger)index{
    NSArray *timeArr = self.leftTimeArr;
    NSMutableDictionary *startendTime = [NSMutableDictionary dictionary];
    NSInteger realindex = [self getcolumnWithIndex:index];
    for (int i=0; i<timeArr.count; i++) {
        if (realindex == i) {
            [startendTime setObject:self.leftTimeArr[realindex] forKey:STARTTIME];
            [startendTime setObject:self.leftTimeArr[realindex+1] forKey:ENDTIME];
        }
    }
    return startendTime;
}
//获取当前列从findex-tindex之间的元素
-(NSArray *)getCurrentLineItemFromIndex:(NSInteger)findex toIndex:(NSInteger)tIndex{
    NSMutableArray *possibleOmit = [NSMutableArray array];
    //    NSInteger line = [self getlineWithIndex:findex];
    NSInteger frow = [self getcolumnWithIndex:findex];
    NSInteger trow = [self getcolumnWithIndex:tIndex];
    NSInteger count = trow-frow-1;
    NSInteger tmpIndex = findex;
    for (int i=0; i<count; i++) {
        tmpIndex += CONTENTLINE;
        [possibleOmit addObject:[NSString stringWithFormat:@"%ld",(long)tmpIndex]];
    }
    return [possibleOmit copy];
}
//获取当前周的日期信息
- (NSArray *)getCurrentWeekDateWithDateFormat:(NSString *)format{
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitDay
                                         fromDate:now];
    
    // 得到星期几
    //    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:format];
    NSMutableArray *weekArr = [NSMutableArray array];
    NSInteger tmpdiff = 0;
    NSDateComponents *tmpDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    for (int i=0; i<7; i++) {
        [tmpDayComp setDay:day+tmpdiff];
        NSDate *tmpDayOfWeek= [calendar dateFromComponents:tmpDayComp];
        [weekArr addObject:[formater stringFromDate:tmpDayOfWeek]];
        tmpdiff++;
    }
    return [weekArr copy];
}
//获取当前周几的数据
- (NSArray *)getCurrentWeekInfo{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitDay
                                         fromDate:now];
    NSInteger day = [comp day];
    NSDateComponents *tmpDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    NSMutableArray *weekInfo = [NSMutableArray array];
    NSInteger tmpdiff = 0;
    for (int i=0; i<7; i++) {
        [tmpDayComp setDay:day+tmpdiff];
        NSDate *tmpDayOfWeek= [calendar dateFromComponents:tmpDayComp];
        NSString *weekStr = [self weekdayStringFromDate:tmpDayOfWeek];
        [weekInfo addObject:weekStr];
        tmpdiff++;
    }
    return [weekInfo copy];
}
//通过日期获取到周几
- (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    return [weekdays objectAtIndex:theComponents.weekday];
}
//触点是否在已选的范围
-(BOOL)isSubscribedContainsPoint:(CGPoint)point{
    bool iscontains = false;
    for (int i=0; i<self.unableSelectArr.count; i++) {
        CGRect frame = [self.unableSelectArr[i] CGRectValue];
        bool contain = CGRectContainsPoint(frame,point);
        if (contain) {
            iscontains = true;
        }
    }
    return iscontains;
}
// 搜索与第i行第j列值相同的联通点，如果联通点超过2个则输出对应的信息
vRange funVerticalContinuousRange(int  p[][CONTENTLINE], int i ,int j)
{
    bool b[CONTENTCOLUMN][CONTENTLINE] = {0};     // 是否已搜索过
    int n = p[i][j];        // 当前要判断的值
    int nNum[4] = {0};      // 联通的方向索引 0：左；1：右；2：上；3：下
    int nCount = 1;         // 计数器
    
    // 初始化方向索引
    
    nNum[0] = j;
    nNum[1] = j;
    
    nNum[2] = i;
    nNum[3] = i;
    
    
    //向左搜索
    if (j != 0)
    {
        for (int h = j - 1; h != 0; --h)
        {
            if (!b[i][h])
            {
                b[i][h] = true;
                if (p[i][h] == n )
                {
                    nNum[0] = h;
                    nCount++;
                }
                else
                {
                    break;
                }
            }
        }
    }
    
    //向右搜索
    if (j != CONTENTLINE-1)
    {
        for (int h = j + 1; h != CONTENTLINE; ++h)
        {
            if (!b[i][h])
            {
                b[i][h] = true;
                if (p[i][h] == n )
                {
                    nNum[1] = h;
                    nCount++;
                }
                else
                {
                    break;
                }
                
            }
        }
    }
    //向上搜索
    if (i != 0)
    {
        for (int h = i - 1; h != -1; --h)
        {
            if (!b[h][j])
            {
                b[h][j] = true;
                if (p[h][j] == n )
                {
                    nNum[2] = h;
                    nCount++;
                }
                else
                {
                    break;
                }
            }
        }
    }
    //向下搜索
    if (i != CONTENTCOLUMN-1)
    {
        for (int h = i + 1; h != CONTENTCOLUMN; ++h)
        {
            if (!b[h][j])
            {
                b[h][j] = true;
                if (p[h][j] == n )
                {
                    nNum[3] = h;
                    nCount++;
                }
                else
                {
                    break;
                }
            }
        }
    }
//    if (nCount > 1)
//    {
//        NSLog(@"与%d,%d联通的点：%d 左起:%d 右至:%d 上起:%d 下至:%d ",i,j,nCount,nNum[0],nNum[1],nNum[2],nNum[3]);
//    }
//    else
//        NSLog(@"与%d,%d联通的点不足2个",i,j);
    //如果需要横向相邻 就返回左nNum[0] 右nNum[1]
    vRange resultRange;
    resultRange.top = nNum[2];
    resultRange.bottom = nNum[3];
    return resultRange;
}
-(void)setUpUI{
    //背景
    self.bgScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.bgScrollView.contentSize = CGSizeMake(0,ITEMHRIGHT*11);
    self.bgScrollView.showsVerticalScrollIndicator = NO;
    self.bgScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.bgScrollView];
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.contentScrollView.contentSize = CGSizeMake(ITEMWIDTH*8,ITEMHRIGHT*12);
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    [self.bgScrollView addSubview:self.contentScrollView];
    //头部
    self.subscribeHeadView = [[UIView alloc] initWithFrame:CGRectMake(ITEMWIDTH, 0, ITEMWIDTH*7, ITEMHRIGHT)];
    NSMutableArray *weekArr = [NSMutableArray array];
    NSArray *weekDate = [self getCurrentWeekDateWithDateFormat:@"MM.dd"];
    NSArray *weekTitle = self.headTimeArr;
    for (int i= 0; i<weekDate.count; i++) {
        [weekArr addObject:[NSString stringWithFormat:@"%@\n(%@)",weekTitle[i],weekDate[i]]];
    }
    [self.subscribeHeadView drawListWithRect:self.subscribeHeadView.bounds line:7 columns:1 datas:[weekArr copy] lineColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00]];
    [self.contentScrollView addSubview:self.subscribeHeadView];
    
    //左边
    self.subscribeLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, -ITEMHRIGHT/2, ITEMWIDTH, ITEMHRIGHT*12)];
    NSMutableArray *tmarr = [NSMutableArray array];
    [tmarr addObject:@""];
    [tmarr addObjectsFromArray:self.leftTimeArr];
    [self.subscribeLeftView drawListWithRect:self.subscribeLeftView.bounds line:1 columns:12 datas:tmarr lineColor:[UIColor clearColor]];
    self.subscribeLeftView.backgroundColor = [UIColor whiteColor];
    [self.bgScrollView addSubview:self.subscribeLeftView];
    
    //内容
    self.subscribeView = [[UIView alloc] initWithFrame:CGRectMake(ITEMWIDTH, ITEMHRIGHT, ITEMWIDTH*CONTENTLINE, ITEMHRIGHT*CONTENTCOLUMN)];
    [self.subscribeView drawListWithRect:self.subscribeView.bounds line:CONTENTLINE columns:CONTENTCOLUMN datas:[self.dataArr copy] lineColor:[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00]];
    [self.contentScrollView addSubview:self.subscribeView];
    //添加手势
    [self.subscribeView addGestureRecognizer:self.swipeToChooseGesture];
    [self.subscribeView addGestureRecognizer:self.tapToChooseGesture];
    //    [self.bgScrollView.panGestureRecognizer requireGestureRecognizerToFail:self.swipeToChooseGesture];
    [self.tapToChooseGesture requireGestureRecognizerToFail:self.swipeToChooseGesture];
}
- (UILongPressGestureRecognizer *)swipeToChooseGesture
{
    if (!_swipeToChooseGesture) {
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToChoose:)];
        pressGesture.enabled = YES;
        pressGesture.numberOfTouchesRequired = 1;
        pressGesture.minimumPressDuration = 0.2;
        _swipeToChooseGesture = pressGesture;
    }
    return _swipeToChooseGesture;
}
- (UITapGestureRecognizer *)tapToChooseGesture
{
    if (!_tapToChooseGesture) {
        UITapGestureRecognizer *pressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToChoose:)];
        pressGesture.enabled = YES;
        _tapToChooseGesture = pressGesture;
    }
    return _tapToChooseGesture;
}

-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        for (int i = 0; i<CONTENTLINE*CONTENTCOLUMN; i++) {
            [_dataArr addObject:@""];
        }
    }
    return _dataArr;
}
-(NSArray *)headTimeArr{
    if (!_headTimeArr) {
        _headTimeArr = [NSArray arrayWithArray:[self getCurrentWeekInfo]];
    }
    return _headTimeArr;
}
-(NSArray *)leftTimeArr{
    if (!_leftTimeArr) {
        _leftTimeArr = @[@"08:00", @"09:00", @"10:00", @"11:00", @"12:00", @"13:00", @"14:00", @"15:00", @"16:00", @"17:00", @"18:00"];
    }
    return _leftTimeArr;
}
-(NSMutableArray *)isSelectArr{
    if (!_isSelectArr) {
        _isSelectArr = [NSMutableArray array];
        for (int i = 0; i < CONTENTLINE*CONTENTCOLUMN; i ++) {
            [_isSelectArr addObject:@"0"];
        }
    }
    return _isSelectArr;
}
-(NSMutableArray *)otherSubscribedArr{
    if (!_otherSubscribedArr) {
        _otherSubscribedArr = [NSMutableArray array];
    }
    return _otherSubscribedArr;
}
-(NSMutableArray *)subscribedArr{
    if (!_subscribedArr) {
        _subscribedArr = [NSMutableArray array];
    }
    return _subscribedArr;
}
-(NSMutableArray *)unableSelectArr{
    if (!_unableSelectArr) {
        _unableSelectArr = [NSMutableArray array];
    }
    return _unableSelectArr;
}
-(NSMutableArray *)currentSelectArr{
    if (!_currentSelectArr) {
        _currentSelectArr = [NSMutableArray array];
    }
    return _currentSelectArr;
}
-(NSArray *)headGridInfo{
    return [self.headTimeArr copy];
}
-(NSArray *)leftGridInfo{
    return [self.leftTimeArr copy];
}
@end
