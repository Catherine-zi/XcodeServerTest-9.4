//
//  HSHighLight.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class HSKLineUpFrontView: UIView, HSDrawLayerProtocol {

    var rrText = CATextLayer()
    var volText = CATextLayer()
    var maxMark = CATextLayer()
    var midMark = CATextLayer()
    var minMark = CATextLayer()
//	var secondMark = CATextLayer()//新增两个Y轴
//	var fourMark = CATextLayer()
    var maxVolMark = CATextLayer()
    var yAxisLayer = CAShapeLayer()
    
    var corssLineLayer = CAShapeLayer()
	var legendLayer = CAShapeLayer()
    var volMarkLayer = CATextLayer()
    var leftMarkLayer = CATextLayer()
    var bottomMarkLayer = CATextLayer()
    var yAxisMarkLayer = CATextLayer()
	
	var ma5Text = CATextLayer()
	var ma10Text = CATextLayer()
	var ma20Text = CATextLayer()
	
    var uperChartHeight: CGFloat {
        get {
            return theme.uperChartHeightScale * self.frame.height
        }
    }
    var lowerChartTop: CGFloat {
        get {
            return uperChartHeight + theme.xAxisHeitht
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        drawMarkLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            // 交给下一层级的view响应事件（解决该 view 在 scrollView 上面到时scrollView无法滚动问题）
            return nil
        }
        return view
    }
    
	func configureAxis(max: String, min: String, maxVol: String, ma5: String,ma10: String,ma20: String) {

		let maxDecimal = Decimal(string: max) ?? Decimal(0)
		let minDecimal = Decimal(string: min) ?? Decimal(0)
		
        let maxPriceStr = NSDecimalNumber(decimal: maxDecimal).stringValue
        let minPriceStr = NSDecimalNumber(decimal: minDecimal).stringValue
		
		var midPriceStr = "0"
		
		let midDecimal: Decimal = (maxDecimal + minDecimal) / 2
		midPriceStr = NSDecimalNumber.init(decimal: midDecimal).stringValue
		
		
		let maxVolStr = Decimal(string: maxVol)
        maxMark.string = maxPriceStr
        minMark.string = minPriceStr
        midMark.string = midPriceStr
//		secondMark.string = secondPriceStr
//		fourMark.string = fourPriceStr
        maxVolMark.string = maxVolStr
		
			let ma5Str = "ma5:" + ma5
			ma5Text.string = ma5Str
			
			let ma10Str = "ma10:" + ma10
			ma10Text.string = ma10Str
			
			let ma20Str = "ma20:" + ma20
			ma20Text.string = ma20Str
			
			var ma5Frame = ma5Text.frame
			ma5Frame.size.width = theme.getTextSize(text: ma5Str).width
			ma5Text.frame = ma5Frame
			
			var ma10Frame = ma10Text.frame
			ma10Frame.origin.x = theme.getTextSize(text: ma5Str).width + 10
			ma10Frame.size.width = theme.getTextSize(text: ma10Str).width
			ma10Text.frame = ma10Frame
			
			var ma20Frame = ma20Text.frame
			ma20Frame.origin.x = ma10Frame.origin.x + theme.getTextSize(text: ma10Str).width + 10
			ma20Frame.size.width = theme.getTextSize(text: ma20Str).width
			ma20Text.frame = ma20Frame
		
    }
    
    func drawMarkLayer() {
//        rrText = getYAxisMarkLayer(frame: frame, text: "不复权", y: theme.viewMinYGap, isLeft: true)
		ma5Text = getYAxisMarkLayer(frame: frame, text: "ma5:0.0000", y: theme.viewMinYGap * 0.5, isLeft: true)
		ma5Text.foregroundColor = theme.ma5Color.cgColor
		ma10Text = getYAxisMarkLayer(frame: frame, text: "ma10:0.0000", y: theme.viewMinYGap * 0.5, isLeft: true)
		ma10Text.foregroundColor = theme.ma10Color.cgColor
		ma20Text = getYAxisMarkLayer(frame: frame, text: "ma20:0.0000", y: theme.viewMinYGap * 0.5, isLeft: true)
		ma20Text.foregroundColor = theme.ma20Color.cgColor
		
		let defaultText = "0.0000000"
        volText = getYAxisMarkLayer(frame: frame, text: "Volume", y: lowerChartTop + theme.volumeGap, isLeft: true)
        maxMark = getYAxisMarkLayer(frame: frame, text: defaultText, y: theme.viewMinYGap, isLeft: false)
        minMark = getYAxisMarkLayer(frame: frame, text: defaultText, y: uperChartHeight - theme.viewMinYGap, isLeft: false)
        midMark = getYAxisMarkLayer(frame: frame, text: defaultText, y: uperChartHeight / 2, isLeft: false)
//		secondMark = getYAxisMarkLayer(frame: frame, text: defaultText, y: , isLeft: true)
//		fourMark = getYAxisMarkLayer(frame: frame, text: defaultText, y: , isLeft: true)
        maxVolMark = getYAxisMarkLayer(frame: frame, text: defaultText, y: lowerChartTop + theme.volumeGap, isLeft: false)
//        self.layer.addSublayer(rrText)
        self.layer.addSublayer(volText)
        self.layer.addSublayer(maxMark)
        self.layer.addSublayer(minMark)
        self.layer.addSublayer(midMark)
//		self.layer.addSublayer(secondMark)
//		self.layer.addSublayer(fourMark)
        self.layer.addSublayer(maxVolMark)
		self.layer.addSublayer(ma5Text)
		self.layer.addSublayer(ma10Text)
		self.layer.addSublayer(ma20Text)
    }
    
	func drawCrossLine(pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?, legendArr: [String]) {
        corssLineLayer.removeFromSuperlayer()
		legendLayer.removeFromSuperlayer()
        corssLineLayer = getCrossLineLayer(frame: frame, pricePoint: pricePoint, volumePoint: volumePoint, model: model)
		legendLayer = getLegendlayer(isLeft: (frame.size.width * 0.5 < pricePoint.x),frame: frame, model: model, legendTitleArr: legendArr)
		
        self.layer.addSublayer(corssLineLayer)
		self.layer.addSublayer(legendLayer)
    }
	
    func removeCrossLine() {
        self.corssLineLayer.removeFromSuperlayer()
		self.legendLayer.removeFromSuperlayer()
    }
	
//	func getFormatCount(max: CGFloat,min: CGFloat) -> Int{
//
//		var count: Int = 0
//		count = getZeroCount(value: max)
//		count = getZeroCount(value: min) > count ? getZeroCount(value: min) : count
//
//		return count
//	}
//	func getZeroCount(value:CGFloat) -> Int{
//		if value <= 0 {
//			return 0
//		}
//
//		let formatStr = NSString(format: "%f", value)
//		let str = NSString(format: "%@", NSNumber.init(value: formatStr.floatValue))//NSNumber.init(value: Double(value)).stringValue
//		print("str = \(str)")
//		if !str.contains(".") {
//			return 0
//		}
//		let arr = str.components(separatedBy: ".")
//		guard let subStr = arr.last else {
//			return 0
//		}
//		return subStr.lengthOfBytes(using: String.Encoding.utf8) > 9 ? 9 : subStr.lengthOfBytes(using: String.Encoding.utf8)
//	}
}
