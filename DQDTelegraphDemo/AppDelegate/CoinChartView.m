//
//  CoinChartView.m
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/6/28.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import "CoinChartView.h"
#import "AAChartKit.h"
#import "AAItemStyle.h"
#import "AALegend.h"
#import "DQDTelegraphDemo-Swift.h"


@interface CoinChartView()<AAChartViewDidFinishLoadDelegate>
@property (nonatomic,strong)AAChartView * aaChartView;

@end
@implementation CoinChartView

-(instancetype)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {

		
	}
	return self;
}

- (void)addOptions:(NSArray *)dataArr timeType:(NSInteger)timeType isBTC:(BOOL)isBTC{
	
	if (_aaChartView) {
		[_aaChartView removeFromSuperview];
		_aaChartView = nil;
	}
	_aaChartView = [[AAChartView alloc]init];
	_aaChartView.frame = self.bounds;
	_aaChartView.scrollEnabled = false;
	_aaChartView.delegate = self;
	
	[self addSubview:_aaChartView];
	
	AAOptions *aaOptions = [self configureDoubleYAxisChartOptions:dataArr timeType:timeType isBTC:isBTC];
	
	[_aaChartView aa_drawChartWithOptions:aaOptions];
	_aaChartView.isClearBackgroundColor = YES;
}
- (void)AAChartViewDidFinishLoad{
	if ([self.delegate respondsToSelector:@selector(chartFinishedLoad)]) {
		[self.delegate chartFinishedLoad];
	}
}
- (AAOptions *)configureDoubleYAxisChartOptions:(NSArray *)dataArr timeType:(NSInteger)timeType isBTC:(BOOL)isBTC{
	if (dataArr.count == 0) {
		return nil;
	}
	
	NSMutableArray *priceArr = [NSMutableArray array];
	NSMutableArray *priceBtcArr = [NSMutableArray array];
	NSMutableArray *volumeArr = [NSMutableArray array];
	NSMutableArray *timeArr = [NSMutableArray array];
	NSMutableArray *capArr = [NSMutableArray array];
	NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
	f.numberStyle = NSNumberFormatterDecimalStyle;
	
	for (CoinStatusStruct *model in dataArr) {

		[capArr addObject:[f numberFromString:model.availableSupply]];
		[priceBtcArr addObject:[f numberFromString:model.priceBtc]];
		[priceArr addObject:[f numberFromString:model.priceUsd]];
		[volumeArr addObject:[f numberFromString:model.volumeusd24h]];
		[timeArr addObject:[self getDateStr:model.updatedTime timeType:(NSInteger)timeType]];
	}
//	NSLog
	//交易量
	NSNumber *maxVolume = volumeArr.firstObject;
	NSNumber *minVolume = volumeArr.firstObject;
	for (NSNumber *number in volumeArr) {
		
		if ([number compare:maxVolume] != NSOrderedAscending) {
			maxVolume = number;
		}
		if ([number compare:minVolume] == NSOrderedAscending) {
			minVolume = number;
		}
	}
	//USD价格
	NSNumber *maxPrice = priceArr.firstObject;
	NSNumber *minPrice = priceArr.firstObject;
	
	for (NSNumber *number in priceArr) {
		if ([number compare:maxPrice] != NSOrderedAscending) {
			maxPrice = number;
		}
		if ([number compare:minPrice] == NSOrderedAscending) {
			minPrice = number;
		}
		
	}
	
	//BTC 价格
	NSNumber *maxBtcPrice = priceBtcArr.firstObject;
	NSNumber *minBtcPrice = priceBtcArr.firstObject;
	
	for (NSNumber *number in priceBtcArr) {
		if ([number compare:maxBtcPrice] != NSOrderedAscending) {
			maxBtcPrice = number;
		}
		if ([number compare:minBtcPrice] == NSOrderedAscending) {
			minBtcPrice = number;
		}
		
	}
	//计算差值，平衡图标
	double minPriceFlexsible = 0.7;
	double maxPriceFlexsible = 1.3;
	double minVolumeFle = 0.7;
	double maxVolumeFle = 2.0;
	
	if (timeType == 1) {//一天
		minPriceFlexsible = 0.98;
		maxPriceFlexsible = 1.02;
		minVolumeFle = 0.95;
		maxVolumeFle = 1.4;
	}else if(timeType == 0) {//hour
		minPriceFlexsible = 0.993;
		maxPriceFlexsible = 1.007;
		minVolumeFle = 0.993;
		maxVolumeFle = 1.007;
	}else{
		minPriceFlexsible = 0.95;
		maxPriceFlexsible = 1.05;
		minVolumeFle = 0.7;
		maxVolumeFle = 2.0;
	}
	
	
	NSArray *priceYArr = [self scientificNumberWithmin:minPrice max:maxPrice minFlexsible:minPriceFlexsible maxFlexsible:maxPriceFlexsible withFormatter:f];
	NSArray *priceBTCYArr = [self scientificNumberWithmin:minBtcPrice max:maxBtcPrice minFlexsible:minPriceFlexsible maxFlexsible:maxPriceFlexsible withFormatter:f];
	NSArray *volumeYArr = [self volumescientificNumberWithmin:minVolume max:maxVolume minFlexsible:minVolumeFle maxFlexsible:maxVolumeFle withFormatter:f];
	
	//end
	AATitle *aaTitle = AAObject(AATitle)
	.textSet(@"");
	
	AALabels *labels = (AAObject(AALabels)
						.enabledSet(true)//设置 y 轴是否显示数字
						.styleSet(AAObject(AAStyle)
								  .colorSet(@"#999999")//yAxis Label font color   //356AF6
								  .fontSizeSet(@"10px")//yAxis Label font size
								  .fontWeightSet(AAChartFontWeightTypeRegular)//yAxis Label font weight
								  )
//						.formatSet(@"{value:.,0f}")//让y轴的值完整显示 而不是100000显示为100k
						);
	
	AALabels *xlabels = (AAObject(AALabels)
						.enabledSet(true)
						.styleSet(AAObject(AAStyle)
								  .colorSet(@"#999999")//yAxis Label font color   //356AF6
								  .fontSizeSet(@"10px")//yAxis Label font size
								  .fontWeightSet(AAChartFontWeightTypeRegular)//yAxis Label font weight
								  )
						//						.formatSet(@"{value:.,0f}")//让y轴的值完整显示 而不是100000显示为100k
						);
	
	//y 轴
	//Volume
	AAYAxis *yAxisOne = AAObject(AAYAxis)
	.visibleSet(false)
	.labelsSet(labels.formatSet(@"{value}"))//
	.titleSet(AAObject(AATitle)
			  .textSet(@"交易量")
			  )
	.oppositeSet(false)
	.tickPositionsSet(volumeYArr);
	
	
	//USD
	AAYAxis *yAxisTwo = AAObject(AAYAxis)
	.visibleSet(true)
	.gridLineWidthSet(@0)
	.labelsSet(labels.formatSet(@"{value}"))
	.titleSet(AAObject(AATitle)
			  .textSet(@"")
			  )
	.oppositeSet(true)
	.tickPositionsSet(priceYArr);
	
	
	//BTC
	AAYAxis *yAxisThree = AAObject(AAYAxis)
	.visibleSet(false)
	.labelsSet(labels.formatSet(@"{value}"))
	.titleSet(AAObject(AATitle)
			  .textSet(@"")
			  )
	.tickPositionsSet(priceBTCYArr);
	
	//x轴
	AAXAxis *xAxis = AAObject(AAXAxis)
	.visibleSet(true)
	.labelsSet(xlabels.formatSet(@"{value}"))
	.categoriesSet(timeArr.copy);
	
	
	NSMutableArray *yAxisArr = [NSMutableArray arrayWithArray:@[
																yAxisOne,
																yAxisTwo,
																yAxisThree
																]];
	if (isBTC) {
		[yAxisArr removeLastObject];
	}

	NSMutableArray *aaSeries = [NSMutableArray arrayWithArray:@[
																AAObject(AASeriesElement)
																.colorSet(@"#DDDDDD")
																.nameSet(@"Volume(USD)")
																.typeSet(AAChartTypeColumn)
																.borderWidthSet(@0)
																.yAxisSet(@0)
																.dataSet(volumeArr.copy)
																.showInLegendSet(@(false))
																.dataLabelsSet(AAObject(AADataLabels)
																			   .enabledSet(false)
																			   )
																
																,
																AAObject(AASeriesElement)
																.colorSet(@"#356AF6")
																.nameSet(@"Price(USD)")
																.typeSet(AAChartTypeSpline)
																.yAxisSet(@1)
																.dataSet(priceArr.copy)
																.dataLabelsSet(AAObject(AADataLabels)
																			   .enabledSet(false)
																			   )
																,
																AAObject(AASeriesElement)
																.colorSet(@"#FFBE24")
																.nameSet(@"Price(BTC)")
																.typeSet(AAChartTypeSpline)
																.yAxisSet(@2)
																.dataSet(priceBtcArr.copy)
																.dataLabelsSet(AAObject(AADataLabels)
																			   .enabledSet(false)
																			   )
																
																]];
	if (isBTC) {
		[aaSeries removeLastObject];
	}

	//提示框样式
	AATooltip *aaTooltip = AAObject(AATooltip).sharedSet(true).enabledSet(true);
	aaTooltip.backgroundColor = @"#282828";//1E59F5
	aaTooltip.borderColor = @"#282828";
	aaTooltip.borderRadius = @(4);
	aaTooltip.style = @{@"color":@"#FFFFFF",
						@"fontSize":@"9px",};
//	aaTooltip.crosshairs = YES;
	//图例样式
	AAItemStyle *aaItemStyle = AAObject(AAItemStyle)
	.colorSet(@"#C2C2C2")
//	.cursorSet(@"pointer")
	.fontSizeSet(@"9px")
	.fontWeightSet(AAChartFontWeightTypeBold);//字体为细体字
	
	AAOptions *chartOptions = AAObject(AAOptions);
	chartOptions.title = aaTitle;
	chartOptions.yAxis = (id)yAxisArr;
	chartOptions.xAxis = xAxis;
	chartOptions.tooltip = aaTooltip;
	
	//Legend(图例)
	AALegend *aaLegend = AAObject(AALegend)
	.itemStyleSet(aaItemStyle)
	.enabledSet(true)
	.layoutSet(AALegendLayoutTypeHorizontal)
	.alignSet(AALegendAlignTypeCenter)
	.itemMarginTopSet(@(2));
	
	
	chartOptions.series = aaSeries;
	
	//用于设置图表的透明度为0
	AAChart *aaChart = AAObject(AAChart)
	.backgroundColorSet(@"rgba(0,0,0,0)")
	.marginLeftSet(@(20));
	
	chartOptions.chart = aaChart;
	
	chartOptions.legend = aaLegend;
	
	//用于设置Column的宽度
	AAPlotOptions *plotOptions = AAObject(AAPlotOptions);
	AASeries *aaplotSeries = AAObject(AASeries);
	AAChartModel *aaChartModel= AAObject(AAChartModel);
	aaplotSeries.animation = (AAObject(AAAnimation)
							  .easingSet(aaChartModel.animationType)
							  .durationSet(aaChartModel.animationDuration)
							  );
	plotOptions.series = aaplotSeries;
	
	AADataLabels *aaDataLabels;
	AAColumn *aaColumn = (AAObject(AAColumn)
						  .borderWidthSet(@0)
						  .groupingSet(YES)
						  .groupPaddingSet(@0.1)
						  .pointPaddingSet(@0.1)
						  .dataLabelsSet(aaDataLabels));
	plotOptions.column = aaColumn;
	chartOptions.plotOptions = plotOptions;

	if ([self getArfterDigitZeroCount:priceYArr.firstObject] > 5) {
		chartOptions.tooltip.valueDecimals = @9;
		chartOptions.plotOptions.area.dataLabels.format = @"{point.y:.9f}";
	}
	return chartOptions;
}

//传入时间戳，返回一个需要字符串
- (NSString *)getDateStr:(NSString *)str timeType:(NSInteger)timeType{
	NSString *dateStr = [self getDateStringWithTimeStr:str];
	NSArray *dateArr = [dateStr componentsSeparatedByString:@"/"];
//	NSString *nowStr = [self currentDateStr];
//	NSArray *nowArr = [nowStr componentsSeparatedByString:@"/"];
	if (dateArr.count != 5) {
		return @"";
	}
	NSMutableString *resultStr = [NSMutableString string];
	if (timeType == 0 || timeType == 1) {//1hour,1day
		[resultStr appendString:dateArr[3]];
		[resultStr appendString:@":"];
		[resultStr appendString:dateArr[4]];
	} else if (timeType == 2 || timeType == 3){//week,month
		//month
		[resultStr appendString:dateArr[1]];
		[resultStr appendString:@"/"];
		[resultStr appendString:dateArr[2]];
//		[resultStr appendString:@" "];
//		[resultStr appendString:dateArr[3]];
//		[resultStr appendString:@":"];
//		[resultStr appendString:dateArr[4]];
	}else if (timeType == 5 || timeType == 4){//year,all
		[resultStr appendString:dateArr[0]];
		[resultStr appendString:@"/"];
		[resultStr appendString:dateArr[1]];
		[resultStr appendString:@"/"];
		[resultStr appendString:dateArr[2]];
	}
	
	return resultStr.copy;
}
// 时间戳转时间,时间戳为13位是精确到毫秒的，10位精确到秒
- (NSString *)getDateStringWithTimeStr:(NSString *)str{
	NSTimeInterval time=[str doubleValue];//传入的时间戳str如果是精确到毫秒的记得要/1000
	NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
	//设定时间格式,这里可以设置成自己需要的格式
	[dateFormatter setDateFormat:@"yyyy/MM/dd/HH/mm"];
	NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
	return currentDateStr;
}
//获取当前时间
- (NSString *)currentDateStr{
	NSDate *currentDate = [NSDate date];//获取当前时间，日期
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
	[dateFormatter setDateFormat:@"yyyy/MM/dd/HH/mm"];//设定时间格式,这里可以设置成自己需要的格式@"YYYY/MM/dd hh:mm:ss SS "
	NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
	return dateString;
}

//矫正价格的纵坐标
static CGFloat showArea = 0.618;
- (NSArray <NSNumber *>*)scientificNumberWithmin:(NSNumber *)min max:(NSNumber *)max minFlexsible:(double)minFlexsible maxFlexsible:(double)maxFlexsible withFormatter:(NSNumberFormatter *)formatter{
	
	NSNumber *minResult;
	double dif = [max doubleValue] - [min doubleValue];
	double bottomArea = (dif / showArea - dif) * 0.5;
	if (([min doubleValue] - bottomArea) > 0) {
		minResult = [NSNumber numberWithDouble:([min doubleValue] - bottomArea)];
	}else {
		minResult = [NSNumber numberWithDouble:([min doubleValue] * minFlexsible)];
	}
	
	NSNumber *maxResult = [NSNumber numberWithDouble:([max doubleValue] + bottomArea)];
	dif = [maxResult doubleValue] - [minResult doubleValue];
	
	double flexOne = 0.25;
	double flexTwo = 0.5;
	double flexThree = 0.75;
	NSNumber *flexOneRe;
	NSNumber *flexTwoRe;
	NSNumber *flexThreeRe;
	NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:5];
	
	formatter.roundingMode = NSNumberFormatterRoundFloor;
	
	int count = 0;
	if (dif > 1 && [maxResult doubleValue] > 1 && [minResult doubleValue] >1) {
		count = 2;//默认两位小数
	}else {
		
		for (int i = 0; i < 3; i++) {//dif,min,max
			if (i == 0) {
				count = (count > [self getArfterDigitZeroCount:minResult]) ? count : [self getArfterDigitZeroCount:minResult];
			}
			if (i == 1) {
				count = (count > [self getArfterDigitZeroCount:maxResult]) ? count : [self getArfterDigitZeroCount:maxResult];
			}
			if (i == 2) {
				count = (count > [self getArfterDigitZeroCount:[NSNumber numberWithDouble:dif]]) ? count : [self getArfterDigitZeroCount:[NSNumber numberWithDouble:dif]];
			}
		}
		count = count + 2;
		
	}
	
	flexOneRe = [self getReStoreNumber:[NSNumber numberWithDouble:(dif * flexOne + [minResult doubleValue])] formatter:formatter zeroCount:count];
	flexTwoRe = [self getReStoreNumber:[NSNumber numberWithDouble:(dif * flexTwo + [minResult doubleValue])] formatter:formatter zeroCount:count];
	flexThreeRe = [self getReStoreNumber:[NSNumber numberWithDouble:(dif * flexThree + [minResult doubleValue])] formatter:formatter zeroCount:count];
	
	minResult = [self getReStoreNumber:minResult formatter:formatter zeroCount:count];
	
	maxResult = [self getReStoreNumber:maxResult formatter:formatter zeroCount:count];
	
	[mutableArr addObject:minResult];
	[mutableArr addObject:flexOneRe];
	[mutableArr addObject:flexTwoRe];
	[mutableArr addObject:flexThreeRe];
	[mutableArr addObject:maxResult];
	
	return mutableArr.copy;
}
- (NSArray <NSNumber *>*)volumescientificNumberWithmin:(NSNumber *)min max:(NSNumber *)max minFlexsible:(double)minFlexsible maxFlexsible:(double)maxFlexsible withFormatter:(NSNumberFormatter *)formatter{
	
	NSNumber *minResult = [NSNumber numberWithDouble:([min doubleValue] * minFlexsible)];
	NSNumber *maxResult = [NSNumber numberWithDouble:([max doubleValue] * maxFlexsible)];
	double flexOne = 0.25;
	double flexTwo = 0.5;
	double flexThree = 0.75;
	NSNumber *flexOneRe;
	NSNumber *flexTwoRe;
	NSNumber *flexThreeRe;
	NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:5];
	
	formatter.roundingMode = NSNumberFormatterRoundFloor;
	
	
	double dif = [maxResult doubleValue] - [minResult doubleValue];
	
	if (dif > 1 && [maxResult doubleValue] > 1 && [minResult doubleValue] >1) {
		minResult = [NSNumber numberWithDouble:ceil([minResult doubleValue])];
		maxResult = [NSNumber numberWithDouble:ceil([maxResult doubleValue])];
		
		flexOneRe = [NSNumber numberWithDouble:ceil(dif * flexOne + [minResult doubleValue])];
		flexTwoRe = [NSNumber numberWithDouble:ceil(dif * flexTwo + [minResult doubleValue])];
		flexThreeRe = [NSNumber numberWithDouble:ceil(dif * flexThree + [minResult doubleValue])];
	}else {
		
		
		int count = 0;
		
		for (int i = 0; i < 3; i++) {//dif,min,max
			if (i == 0) {
				count = (count > [self getArfterDigitZeroCount:minResult]) ? count : [self getArfterDigitZeroCount:minResult];
			}
			if (i == 1) {
				count = (count > [self getArfterDigitZeroCount:maxResult]) ? count : [self getArfterDigitZeroCount:maxResult];
			}
			if (i == 2) {
				count = (count > [self getArfterDigitZeroCount:[NSNumber numberWithDouble:dif]]) ? count : [self getArfterDigitZeroCount:[NSNumber numberWithDouble:dif]];
			}
		}
		flexOneRe = [self getReStoreNumber:[NSNumber numberWithDouble:(dif * flexOne + [minResult doubleValue])] formatter:formatter zeroCount:count];
		flexTwoRe = [self getReStoreNumber:[NSNumber numberWithDouble:(dif * flexTwo + [minResult doubleValue])] formatter:formatter zeroCount:count];
		flexThreeRe = [self getReStoreNumber:[NSNumber numberWithDouble:(dif * flexThree + [minResult doubleValue])] formatter:formatter zeroCount:count];
		
		minResult = [self getReStoreNumber:minResult formatter:formatter zeroCount:count];
		
		maxResult = [self getReStoreNumber:maxResult formatter:formatter zeroCount:count];
	}
	
	[mutableArr addObject:minResult];
	[mutableArr addObject:flexOneRe];
	[mutableArr addObject:flexTwoRe];
	[mutableArr addObject:flexThreeRe];
	[mutableArr addObject:maxResult];
	
	return mutableArr.copy;

}
- (NSNumber *)getReStoreNumber:(NSNumber *)number formatter:(NSNumberFormatter *)formatter zeroCount:(int)count{
	
	formatter.maximumFractionDigits = count;

	NSString *str = [formatter stringFromNumber:number];
	return [formatter numberFromString:str];
}
//返回小数点后有几个0
- (int)getArfterDigitZeroCount:(NSNumber *)number{
	
	if ([number compare:@(1)] != NSOrderedAscending) {
		return 0;
	}
	NSDecimalNumber *decimalNumber = [NSDecimalNumber numberWithDouble:number.doubleValue];
	
	NSString *str = [NSString stringWithFormat:@"%@",decimalNumber];
	NSArray *arr = [str componentsSeparatedByString:@"."];
	NSString *subStr = arr.lastObject;
	
	int count = 0;
	NSRange range;
	for(int i = 0; i < subStr.length; i += range.length){
		range = [subStr rangeOfComposedCharacterSequenceAtIndex:i];
		NSString *s = [subStr substringWithRange:range];
		if ([s isEqualToString:@"0"]) {
			count++;
			continue;
		}else {
			break;
		}
	}
	
	return count;
}
@end
