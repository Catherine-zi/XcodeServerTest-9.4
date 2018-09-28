//
//  HSDrawLayerProtocol.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/28.
//  Copyright © 2017年 hanson. All rights reserved.
//

import Foundation
import UIKit

public enum HSChartType: Int {
    case timeLineForDay
    case timeLineForFiveday
    case kLineForDay
    case kLineForWeek
    case kLineForMonth
	case kLineForHour
	case kLineForMinutes
}

protocol HSDrawLayerProtocol {
    
    var theme: HSTimeLineStyle { get }
    
    func drawLine(lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint, strokeColor: UIColor, fillColor: UIColor, isDash: Bool, isAnimate: Bool) -> CAShapeLayer
    
    func drawTextLayer(frame: CGRect, text: String, foregroundColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat) -> CATextLayer
        
    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?) -> CAShapeLayer
	
	//qq--add 长按时添加一个图例浮层
	func getLegendlayer(isLeft: Bool,frame: CGRect, model: AnyObject?, legendTitleArr: [String]) -> CAShapeLayer
    
}

extension HSDrawLayerProtocol {
    
    var theme: HSTimeLineStyle {
        return HSTimeLineStyle()
    }
    
    func drawLine(lineWidth: CGFloat,
                  startPoint: CGPoint,
                  endPoint: CGPoint,
                  strokeColor: UIColor,
                  fillColor: UIColor,
                  isDash: Bool = false,
                  isAnimate: Bool = false) -> CAShapeLayer {
        
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.fillColor = fillColor.cgColor
        
        if isDash {
            lineLayer.lineDashPattern = [3, 3]
        }
        
        if isAnimate {
            let path = CABasicAnimation(keyPath: "strokeEnd")
            path.duration = 1.0
            path.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            path.fromValue = 0.0
            path.toValue = 1.0
            lineLayer.add(path, forKey: "strokeEndAnimation")
            lineLayer.strokeEnd = 1.0
        }
        
        return lineLayer
    }
    
    func drawTextLayer(frame: CGRect,
                       text: String,
                       foregroundColor: UIColor,
                       backgroundColor: UIColor = UIColor.clear,
                       fontSize: CGFloat = 10) -> CATextLayer {
        
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = foregroundColor.cgColor
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        
        return textLayer
    }
    
    
    /// 获取纵轴的标签图层
    func getYAxisMarkLayer(frame: CGRect, text: String, y: CGFloat, isLeft: Bool) -> CATextLayer {
        let textSize = theme.getTextSize(text: text)
        let yAxisLabelEdgeInset: CGFloat = 5
        var labelX: CGFloat = 0
        
        if isLeft {
            labelX = yAxisLabelEdgeInset
        } else {
            labelX = frame.width - textSize.width - yAxisLabelEdgeInset
        }
        
        let labelY: CGFloat = y - textSize.height / 2.0
        
        let yMarkLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: textSize.width, height: textSize.height),
                                       text: text,
                                       foregroundColor: theme.textColor)
        
        return yMarkLayer
    }
	func getLegendlayer(isLeft: Bool,frame: CGRect, model: AnyObject?,legendTitleArr: [String]) -> CAShapeLayer {
		
		let layerW: CGFloat = 143
		let layerH: CGFloat = 101
		let layerX: CGFloat = isLeft ? 15 : (frame.size.width - layerW - 15)
		let layerY = theme.viewMinYGap
		
		let linePath = UIBezierPath()
		linePath.move(to: CGPoint(x: layerX, y: layerY))
		
		let legendLayer = CAShapeLayer()
		let legendFrame = CGRect(x: layerX, y: layerY, width: layerW, height: layerH)
		legendLayer.frame = legendFrame
		legendLayer.backgroundColor = theme.legendColor.cgColor
		legendLayer.cornerRadius = 8.0
	
		guard let model = model else {
			return legendLayer
		}
		//add TextLayer
		var legendContentStrs: [String] = legendTitleArr
		if model.isKind(of: HSKLineModel.self) {
			let entity = model as! HSKLineModel
			legendContentStrs[0] = entity.date.hschart.toDate("yyyyMMddHHmmss")?.hschart.toString("yyyy/MM/dd HH:mm") ?? ""
			var formatStr = "." + "\(getZeroCount(value: entity.open))"
			legendContentStrs[6] = entity.open.hschart.toStringWithFormat(formatStr)
			formatStr = "." + "\(getZeroCount(value: entity.high))"
			legendContentStrs[7] = entity.high.hschart.toStringWithFormat(formatStr)
			formatStr = "." + "\(getZeroCount(value: entity.low))"
			legendContentStrs[8] = entity.low.hschart.toStringWithFormat(formatStr)
			formatStr = "." + "\(getZeroCount(value: entity.close))"
			legendContentStrs[9] = entity.close.hschart.toStringWithFormat(formatStr)
			legendContentStrs[10] = entity.volume.hschart.toStringWithFormat(".2")
		}
		
		let margin: CGFloat = 15
		let padding: CGFloat = 2
		var textLayerX: CGFloat = margin
		var textLayerY: CGFloat = margin
		
		var rightLayerY: CGFloat = 0
		for (index,value) in legendContentStrs.enumerated() {
			
			let layerSize = getTextSize(text: value, fontSize: theme.legendTextFont, addOnWith: 0, addOnHeight: 0)
			let textLayer:CATextLayer
			if index == 0 {
				textLayer = drawTextLayer(frame: CGRect(x: textLayerX, y: textLayerY, width: layerSize.width, height: layerSize.height), text: value, foregroundColor: theme.legendTimeColor, backgroundColor: UIColor.clear, fontSize: theme.legendTextFont)
				textLayer.alignmentMode = "left"
				
				textLayerY = textLayerY + padding + layerSize.height
				rightLayerY = textLayerY
			}else if index < 6 {
				
				textLayer = drawTextLayer(frame: CGRect(x: textLayerX, y: textLayerY, width: layerSize.width, height: layerSize.height), text: value, foregroundColor: theme.legendContentColor, backgroundColor: UIColor.clear, fontSize: theme.legendTextFont)
				textLayer.alignmentMode = "left"

				textLayerY = textLayerY + padding * 0.5 + layerSize.height
				
			}else {//value Text
				textLayer = drawTextLayer(frame: CGRect(x: (layerW - margin - layerSize.width), y: rightLayerY, width: layerSize.width, height: layerSize.height), text: value, foregroundColor: theme.legendContentColor, backgroundColor: UIColor.clear, fontSize: theme.legendTextFont)
				textLayer.alignmentMode = "right"
				
				rightLayerY = rightLayerY + padding * 0.5 + layerSize.height
			}
			
			legendLayer.addSublayer(textLayer)
		}

		
		return legendLayer
	}
    /// 获取长按显示的十字线及其标签图层
    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?) -> CAShapeLayer {
        let highlightLayer = CAShapeLayer()
        
        let corssLineLayer = CAShapeLayer()
//        var volMarkLayer = CATextLayer()
//        var yAxisMarkLayer = CATextLayer()
//        var bottomMarkLayer = CATextLayer()
//        var bottomMarkerString = ""
//        var yAxisMarkString = ""
//        var volumeMarkerString = ""

        guard let model = model else { return highlightLayer }

        if model.isKind(of: HSKLineModel.self) {
            let entity = model as! HSKLineModel
			
			let formatStr = "." + "\(getZeroCount(value: entity.close))"
//            yAxisMarkString = entity.close.hschart.toStringWithFormat(formatStr)
//			bottomMarkerString = entity.date.hschart.toDate("yyyyMMddHHmmss")?.hschart.toString("yyyy/MM/dd HH:mm") ?? ""
//            volumeMarkerString = entity.volume.hschart.toStringWithFormat(".2")

        } else if model.isKind(of: HSTimeLineModel.self){
            let entity = model as! HSTimeLineModel
//            yAxisMarkString = entity.price.hschart.toStringWithFormat(".2")
//            bottomMarkerString = entity.time
//            volumeMarkerString = entity.volume.hschart.toStringWithFormat(".2")

        } else{
            return highlightLayer
        }

        let linePath = UIBezierPath()
        // 竖线
        linePath.move(to: CGPoint(x: pricePoint.x, y: 0))
        linePath.addLine(to: CGPoint(x: pricePoint.x, y: frame.height))

        // 横线
        linePath.move(to: CGPoint(x: frame.minX, y: pricePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: pricePoint.y))

        // 标记交易量的横线
        linePath.move(to: CGPoint(x: frame.minX, y: volumePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: volumePoint.y))

        // 交叉点
        //linePath.addArc(withCenter: pricePoint, radius: 3, startAngle: 0, endAngle: 180, clockwise: true)

        corssLineLayer.lineWidth = theme.lineWidth
        corssLineLayer.strokeColor = theme.crossLineColor.cgColor
        corssLineLayer.fillColor = theme.crossLineColor.cgColor
        corssLineLayer.path = linePath.cgPath

        // 标记标签大小
//        let yAxisMarkSize = theme.getTextSize(text: yAxisMarkString)
//        let volMarkSize = theme.getTextSize(text: volumeMarkerString)
//        let bottomMarkSize = theme.getTextSize(text: bottomMarkerString)

//        var labelX: CGFloat = 0
//        var labelY: CGFloat = 0

        // 纵坐标标签
//        if pricePoint.x > frame.width / 2 {
//            labelX = frame.minX
//        } else {
//            labelX = frame.maxX - yAxisMarkSize.width
//        }
//        labelY = pricePoint.y - yAxisMarkSize.height / 2.0
//        yAxisMarkLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: yAxisMarkSize.width, height: yAxisMarkSize.height),
//                                       text: yAxisMarkString,
//                                       foregroundColor: UIColor.white,
//                                       backgroundColor: theme.textColor)

        // 底部时间标签
//        let maxX = frame.maxX - bottomMarkSize.width
//        labelX = pricePoint.x - bottomMarkSize.width / 2.0
//        labelY = frame.height * theme.uperChartHeightScale
//        if labelX > maxX {
//            labelX = frame.maxX - bottomMarkSize.width
//        } else if labelX < frame.minX {
//            labelX = frame.minX
//        }
//        bottomMarkLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: bottomMarkSize.width, height: bottomMarkSize.height),
//                                        text: bottomMarkerString,
//                                        foregroundColor: UIColor.white,
//                                        backgroundColor: theme.textColor)

        // 交易量右标签
//        if pricePoint.x > frame.width / 2 {
//            labelX = frame.minX
//        } else {
//            labelX = frame.maxX - volMarkSize.width
//        }
//        let maxY = frame.maxY - volMarkSize.height
//        labelY = volumePoint.y - volMarkSize.height / 2.0
//        labelY = labelY > maxY ? maxY : labelY
//        volMarkLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: volMarkSize.width, height: volMarkSize.height),
//                                        text: volumeMarkerString,
//                                        foregroundColor: UIColor.white,
//                                        backgroundColor: theme.textColor)

        highlightLayer.addSublayer(corssLineLayer)
//        highlightLayer.addSublayer(yAxisMarkLayer)
//        highlightLayer.addSublayer(bottomMarkLayer)
//        highlightLayer.addSublayer(volMarkLayer)
//
        return highlightLayer
    }
    
    func getTextSize(text: String, fontSize: CGFloat = 10, addOnWith: CGFloat = 5, addOnHeight: CGFloat = 0) -> CGSize {
        let size = text.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)])
        let width = ceil(size.width) + addOnWith
        let height = ceil(size.height) + addOnWith
        
        return CGSize(width: width, height: height)
    }
	func getZeroCount(value:CGFloat) -> Int{
		if value <= 0 {
			return 0
		}
		let formatStr = NSString(format: "%f", value)
		let str = NSString(format: "%@", NSNumber.init(value: formatStr.floatValue))
//		let str = NSNumber.init(value: Double(value)).stringValue
		if !str.contains(".") {
			return 0
		}
		let arr = str.components(separatedBy: ".")
		guard let subStr = arr.last else {
			return 0
		}
		return subStr.lengthOfBytes(using: String.Encoding.utf8) > 9 ? 9 : subStr.lengthOfBytes(using: String.Encoding.utf8)
	}
}
