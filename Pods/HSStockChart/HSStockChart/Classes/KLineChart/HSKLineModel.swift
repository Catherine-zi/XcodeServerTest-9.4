//
//  HSKLineModel.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/8/29.
//  Copyright © 2016年 hanson. All rights reserved.
//

//import SwiftyJSON

public class HSKLineModel: NSObject {

    public var date: String = ""
	public var originDate: String = ""//date的原始数据
    public var open: String = ""
    public var close: String = ""
    public var high: String = ""
    public var low: String = ""
    public var volume: String = ""
    public var ma5: String = ""
    public var ma10: String = ""
    public var ma20: String = ""
    public var ma30: String = ""
//    public var diff: CGFloat = 0
//    public var dea: CGFloat = 0
//    public var macd: CGFloat = 0
//    public var rate: CGFloat = 0
	public var isCalculatedMa5: Bool = false
	public var isCalculatedMa10: Bool = false
	public var isCalculatedMa20: Bool = false
}
