//
//  MyChart2.swift
//  MyChart
//
//  Created by wh-pc on 16/5/12.
//  Copyright © 2016年 hope. All rights reserved.
//

import UIKit

struct ChartItem {
    var rect:CGRect!;
    var time:NSTimeInterval!;
    
    init(_ rect:CGRect, _ time:NSTimeInterval){
        self.rect = rect;
        self.time = time;
    }
}

class MyChart2: UIControl
{
    @IBInspectable var color:UIColor = UIColor.clearColor(){
        didSet{
            self.setNeedsDisplay();
        }
    };
    
    let MIN_DATE_NUM:Int = 4;
    let MIN_ITEM_WIDTH:CGFloat = 15;
    let TITLES_WIDTH:CGFloat = 40;
    
    var maxDateNum:Int!;
    
    let radius:CGFloat = 10;
    let p:CGFloat = 5;
    
    private var chartItems:[ChartItem] = [];

    private var dateNum:Int = 0;
    private var dateLength:CGFloat!;
    
    var barDatas:[ChartData] = []{
        didSet{
            self.setNeedsDisplay();
        }
    };
    
    
    var minDate:NSTimeInterval = 0;
    var maxDate:NSTimeInterval = 0;
    var minValue:CGFloat? = nil;
    var maxValue:CGFloat? = nil;
    
    var lineDatas:[ChartData] = []{
        didSet{
            
            if !self.lineDatas.isEmpty {
                var num:CGFloat = 1;
                for data in self.lineDatas {
                    data.lengths = [num,1,0];
                    if self.minDate == 0 || (!data.items.isEmpty && data.items.first!.time < self.minDate) {
                        self.minDate = data.items.first!.time;
                    }
                    
                    if self.maxDate == 0 || (!data.items.isEmpty && data.items.last!.time > self.maxDate) {
                        self.maxDate = data.items.last!.time;
                    }
                    
                    if self.maxValue == nil || self.maxValue < data.maxValue {
                        self.maxValue = data.maxValue;
                    }
                    
                    if self.minValue == nil || self.minValue > data.minValue {
                        self.minValue = data.minValue;
                    }
                    
                    num += 2;
                }
            } else {
                self.minDate = 0;
                self.maxDate = 0;
                
                self.minValue = nil;
                self.maxValue = nil;
            }
            
            self.setNeedsDisplay();
        }
    };
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.viewInit();
    }
    
    private func viewInit() {
        self.maxDateNum = Int((UIScreen.mainScreen().bounds.width - 2*p - 2*radius - TITLES_WIDTH)/MIN_ITEM_WIDTH);
    }
    
    
    var yTitle:String? = nil {
        didSet{
            self.setNeedsDisplay();
        }
    }
    
    private var startPoint:CGPoint?;
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.startPoint = touches.first!.locationInView(self);
        self.setNeedsDisplay();
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let endPoint = touches.first!.locationInView(self);
        
        let num = self.startPoint!.x - endPoint.x;
        
        if !self.chartItems.isEmpty && Int(num/self.dateLength) != 0 {
            
            let startData = self.chartItems.first!.time;
            let endDate = self.chartItems.last!.time;
            
            let newStartDate = startData + Double(Int(num/self.dateLength))*24*60*60*1000;
            let newEndDate = endDate + Double(Int(num/self.dateLength))*24*60*60*1000;
            if newStartDate < self.minDate || newEndDate > self.maxDate {
                return;
            }

            print(Double(Int(num/self.dateLength)));
            self.chartItemsInit(endDate + Double(Int(num/self.dateLength))*24*60*60*1000, num: self.dateNum);
            
            self.startPoint = endPoint;
            self.setNeedsDisplay();
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        self.maxDateNum = Int((self.bounds.width - 2*p - 2*radius - TITLES_WIDTH)/MIN_ITEM_WIDTH);
        self.dateLength = MIN_ITEM_WIDTH;
        
        if self.dateNum == 0 || self.dateNum > self.maxDateNum {
            self.dateNum = self.maxDateNum;
        }
        
        var time:NSTimeInterval = 0;
        if !self.lineDatas.isEmpty {
            for ldata in self.lineDatas {
                if !ldata.items.isEmpty && ldata.items.last!.time > time {
                    time = ldata.items.last!.time
                }
            }
        } else if !self.barDatas.isEmpty {
            for bdata in self.barDatas {
                if !bdata.items.isEmpty && bdata.items.last!.time > time {
                    time = bdata.items.last!.time
                }
            }
        }
        
        self.chartItemsInit((time == 0 ? getNowDaytimeInterval() : time), num: self.dateNum);
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(ctx, true);
        
        //背景
        self.drawBackGround(rect,ctx);
        //架构线
        self.drawBackGroundLines(rect,ctx);
        //曲线图
        self.drawDatas(rect,ctx);
        
        //y轴标题
        self.drawYTitle(rect,ctx);
        //y轴刻度和数值
        self.drawYLabelsAndLines(rect,ctx);
        //x轴 时间
        self.drawXLabels(rect,ctx);
        //曲线标示说明
        self.drawDatasTitle(rect,ctx);
        
    }
    
    func drawBackGround(rect:CGRect,_ ctx:CGContextRef?)
    {
        CGContextBeginTransparencyLayer(ctx, nil);
        
        let w = rect.width - 2*p;
        let h = rect.height - 2*p;
        
        // |-------
        CGContextMoveToPoint(ctx, p + radius, p);
        
        // --
        //   |
        CGContextAddArcToPoint(ctx, w + p, p, w + p, p + radius, radius);
        
        //   |
        // --
        CGContextAddArcToPoint(ctx, w + p, h + p, w + p - radius, h + p, radius);
        
        // |
        //  --
        CGContextAddArcToPoint(ctx, p, h + p, p, h + p - radius, radius);
        
        //  --
        // |
        CGContextAddArcToPoint(ctx, p, p, p + radius, p, radius);
        
        self.color.set();
        CGContextFillPath(ctx);
        
        CGContextEndTransparencyLayer(ctx);
    }
    
    func drawBackGroundLines(rect:CGRect,_ ctx:CGContextRef?)
    {
        CGContextBeginTransparencyLayer(ctx, nil);
        
        UIColor.whiteColor().set();
        
        CGContextMoveToPoint(ctx, p + radius, rect.height - 2*p - radius);
        CGContextAddLineToPoint(ctx, rect.width - p - radius - TITLES_WIDTH, rect.height - 2*p - radius);
        CGContextStrokePath(ctx);
        
        CGContextEndTransparencyLayer(ctx);
    }
    
    func drawDatas(rect:CGRect,_ ctx:CGContextRef?)
    {
        let x = p + radius;
        let y = p + radius;
        let h = rect.height - 4*p - 2*radius;
        let w = rect.width - 2*p - 2*radius - TITLES_WIDTH;
        
        if !self.barDatas.isEmpty {
            for i in 0 ... self.barDatas.count-1 {
                self.drawBarChart(CGRectMake(x, y, w, h),ctx,self.barDatas[i],i,self.barDatas.count);
            }
        }
        
        for data in self.lineDatas {
            self.drawLineChart(CGRectMake(x, y, w, h),ctx,data);
        }
    }
    
    private func drawLineChart(rect:CGRect,_ ctx:CGContextRef?,_ data:ChartData)
    {
        if self.chartItems.isEmpty {
            return;
        }
        
        CGContextBeginTransparencyLayer(ctx, nil);
        UIColor.whiteColor().set();

        CGContextAddRect(ctx, rect);
        CGContextClip(ctx);
        
        CGContextSetShadowWithColor(ctx, CGSizeMake(2, 1), 4,UIColor.blackColor().CGColor);
        
        var num = 0;
        var inum = 0;
        for i in 0 ... (data.items.count - 1) {
            let item = data.items[i];
            
            for j in num ... self.chartItems.count-1 {
                let chartItem = self.chartItems[j];
                
                if chartItem.time == item.time {
                    let point = self.itemToPoint(chartItem,item,self.maxValue!,self.minValue!);
                    CGContextAddArc(ctx, point.x, point.y, 2, 0, CGFloat(2*M_PI), 0);
                    CGContextFillPath(ctx);
                    
                    if i > 0 {
                        let onPoint = self.itemToPoint(chartItem, data.items[i-1],self.maxValue!,self.minValue!);
                        CGContextMoveToPoint(ctx, onPoint.x, onPoint.y);
                        CGContextAddLineToPoint(ctx, point.x, point.y);
                        
                        CGContextSetLineDash(ctx, 0, data.lengths, data.lengths.count);
                        CGContextStrokePath(ctx);
                    }
                    
                    inum = i;
                    num = j;
                    break;
                }
            }
        }
        
        if num != self.chartItems.count && inum < data.items.count-1 {
            let point = self.itemToPoint(chartItems.last!,data.items[inum],self.maxValue!,self.minValue!);
            let nextPoint = self.itemToPoint(chartItems.last!, data.items[inum+1], self.maxValue!, self.minValue!);
            
            CGContextMoveToPoint(ctx, point.x, point.y);
            CGContextAddLineToPoint(ctx, nextPoint.x, nextPoint.y);
            
            CGContextSetLineDash(ctx, 0, data.lengths, data.lengths.count);
            CGContextStrokePath(ctx);
        }
        
        CGContextEndTransparencyLayer(ctx);
    }
    
    private func drawBarChart(rect:CGRect,_ ctx:CGContextRef?,_ data:ChartData,_ dataNum:Int,_ datasCount:Int)
    {
        CGContextBeginTransparencyLayer(ctx, nil);
        let colorNum = 1.0 - CGFloat(dataNum)*0.1;
        UIColor(red: colorNum, green: colorNum, blue: colorNum, alpha: colorNum).set();
        
        var num = 0;
        for i in 0 ... (data.items.count - 1) {
            let item = data.items[i];
            
            for j in num ... self.chartItems.count-1 {
                let chartItem = self.chartItems[j];
                
                if chartItem.time == item.time {
                    let brect = self.barItemToRect(chartItem,item,data.maxValue,data.minValue,dataNum,datasCount);
                    CGContextAddRect(ctx, brect);
                    
                    CGContextFillPath(ctx);
                    num = j;
                    break;
                }
            }
        }
        
        CGContextEndTransparencyLayer(ctx);
    }
    
    private func barItemToRect(chartItem:ChartItem,_ item:ChartDataItem,_ maxValue:CGFloat,_ minValue:CGFloat,_ dataNum:Int,_ datasCount:Int) -> CGRect
    {
        let ynum = Double(chartItem.rect.height) / Double(maxValue - minValue);
        let p = chartItem.rect.width/10;
        let w = chartItem.rect.width*4/5/CGFloat(datasCount);
        let h = CGFloat(Double(item.value - minValue)*ynum);
        
        let x = chartItem.rect.origin.x + p + w*CGFloat(dataNum);
        
        let y = CGFloat(Double(chartItem.rect.height) - Double(item.value - minValue)*ynum + Double(chartItem.rect.origin.y));
        
        return CGRectMake(x, y, w, h);
    }
    
    private func itemToPoint(chartItem:ChartItem,_ item:ChartDataItem,_ maxValue:CGFloat,_ minValue:CGFloat) -> CGPoint
    {
        let ynum = Double(chartItem.rect.height) / Double(maxValue - minValue);
        let x = CGFloat((item.time - chartItem.time)/(24*60*60*1000))*chartItem.rect.width + chartItem.rect.origin.x + chartItem.rect.width/2;

        let y = CGFloat(Double(chartItem.rect.height) - Double(item.value - minValue)*ynum + Double(chartItem.rect.origin.y));
        
        return CGPointMake(x, y);
    }
    
    func drawYTitle(rect:CGRect,_ ctx:CGContextRef?)
    {
        //self.yTitle = "kg";
        
        let attributes = [
            NSFontAttributeName:UIFont.systemFontOfSize(10),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ];
        
        if self.yTitle != nil {
            (self.yTitle! as NSString).drawInRect(CGRectMake(2*p, rect.height/2 - 10, 200, 20), withAttributes: attributes);
        }
    }
    
    func drawYLabelsAndLines(rect:CGRect,_ ctx:CGContextRef?)
    {
        let attributes = [
            NSFontAttributeName:UIFont.systemFontOfSize(10),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ];
        
        let x = p + radius;
        let y = 2*p + radius;
        let h = rect.height - 5*p - 2*radius;
        
        if self.maxValue != nil {
            self.drawYLine(rect, ctx, y: p + radius);
            
            "\(self.maxValue!)".drawInRect(CGRectMake(x, y - 10, 100, 10), withAttributes: attributes);
        }
        
        if self.minValue != nil {
            self.drawYLine(rect,ctx, y: y + h);
            
            "\(self.minValue!)".drawInRect(CGRectMake(x, y + h - 10, 100, 10), withAttributes: attributes);
        }
    }
    
    private func drawYLine(rect:CGRect,_ ctx:CGContextRef?,y:CGFloat)
    {
        let x = 2*p + radius;
        let w = rect.width - 4*p - 2*radius - TITLES_WIDTH;
        
        CGContextBeginTransparencyLayer(ctx, nil);
        UIColor.whiteColor().set();
        CGContextSetLineWidth(ctx, 0.5);

        CGContextMoveToPoint(ctx, x, y);
        CGContextAddLineToPoint(ctx, x + w, y);
        CGContextStrokePath(ctx);
        CGContextEndTransparencyLayer(ctx);
    }
    
    func drawXLabels(rect:CGRect,_ ctx:CGContextRef?)
    {
        let attributes = [
            NSFontAttributeName:UIFont.systemFontOfSize(10),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ];

        for chartItem in self.chartItems {
            let str = time1970ToString(chartItem.time, dateformat: "dd");
            let pSize = str.boundingRectWithSize(
                CGSizeMake(rect.width,0),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attributes, context: nil);
            let x = chartItem.rect.origin.x + chartItem.rect.width/2 - pSize.width/2;
            let y = chartItem.rect.origin.y + chartItem.rect.height + p + radius/2 - pSize.height/2;
            
            str.drawInRect(CGRectMake(x, y, pSize.width, pSize.height), withAttributes: attributes);
        }
        
    }
    
    func drawDatasTitle(rect:CGRect,_ ctx:CGContextRef?)
    {
        let attributes = [
            NSFontAttributeName:UIFont.systemFontOfSize(8),
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ];
        
        CGContextBeginTransparencyLayer(ctx, nil);
        let x = rect.width - radius - TITLES_WIDTH;
        var y = p + radius;
        let h:CGFloat = 10;
        
        for data in self.lineDatas {
            
            let pSize = data.title.boundingRectWithSize(
                CGSizeMake(TITLES_WIDTH,0),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attributes, context: nil);
            let lw = TITLES_WIDTH/3;
            
            CGContextMoveToPoint(ctx, x, y + h/2);
            CGContextAddLineToPoint(ctx, x + lw, y + h/2);
            
            CGContextSetLineDash(ctx, 0, data.lengths, data.lengths.count);
            CGContextStrokePath(ctx);
            
            data.title.drawInRect(CGRectMake(x + lw, y + h/2 - pSize.height/2 , TITLES_WIDTH - lw, pSize.height), withAttributes: attributes);
            
            y += (h + p);
        }
        
        var dataNum = 0;
        for data in self.barDatas {
            let pSize = data.title.boundingRectWithSize(
                CGSizeMake(TITLES_WIDTH,0),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attributes, context: nil);
            let bw:CGFloat = 5;
            
            CGContextAddRect(ctx, CGRectMake(x + h/2 - bw/2, y + h/2 - bw/2, 5, 5));
            let colorNum = 1.0 - CGFloat(dataNum)*0.1;
            UIColor(red: colorNum, green: colorNum, blue: colorNum, alpha: colorNum).set();
            CGContextFillPath(ctx);
            
            data.title.drawInRect(CGRectMake(x + h, y + h/2 - pSize.height/2 , TITLES_WIDTH - h, pSize.height), withAttributes: attributes);
            
            dataNum += 1;
            y += (h + p);
        }
        
        CGContextEndTransparencyLayer(ctx);
    }
    
    private func chartItemsInit(endDate:NSTimeInterval,num:Int)
    {
        self.chartItems.removeAll();
        
        if num < 1 {
            return;
        }
        
        var time = NSTimeInterval(endDate);
        var x = self.bounds.width - p - radius - TITLES_WIDTH;
        let y = p + radius;
        let iw = (self.bounds.width - 2*p - 2*radius - TITLES_WIDTH)/CGFloat(num);
        let ih = self.bounds.height - 4*p - 2*radius;
        for _ in 1 ... num {
            x -= iw;
            let rect = CGRectMake(x, y, iw, ih);
            self.chartItems.insert(ChartItem(rect,time), atIndex: 0);
            time -= 24*60*60*1000;
        }
    }
}

