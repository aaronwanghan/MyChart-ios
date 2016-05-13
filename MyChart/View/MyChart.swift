//
//  MyChart.swift
//  MyChart
//
//  Created by wh-pc on 16/5/11.
//  Copyright © 2016年 hope. All rights reserved.
//

import UIKit

struct ChartValue {
    var time:NSTimeInterval;
    var value:Int;
    
    init(_ time:NSTimeInterval,_ value:Int)
    {
        self.time = time;
        self.value = value;
    }
}

let attributes = [
    NSFontAttributeName:UIFont.systemFontOfSize(10),
    NSForegroundColorAttributeName: UIColor.whiteColor()
];

class MyChart: UIControl
{
    let radius:CGFloat = 10;
    let p:CGFloat = 5;
    var point:CGPoint?;
    var values:[ChartValue] = [ChartValue(1403366400000.0 , 109),
                               ChartValue(1403452800000.0 , 110),
                               ChartValue(1403539200000.0 , 100),
                               ChartValue(1403625600000.0 , 109),
                               ChartValue(1404057600000.0 , 110),
                               ChartValue(1404230400000.0 , 108)];
    var ytitle:String = "kg";
    
    @IBInspectable var color:UIColor = UIColor.clearColor(){
        didSet{
            self.setNeedsDisplay();
        }
    };
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.point = touches.first!.locationInView(self);
        self.setNeedsDisplay();
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.point = nil;
        self.setNeedsDisplay();
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.point = touches.first!.locationInView(self);
        self.setNeedsDisplay();
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        self.drawBackGround(rect);
        self.drawLines(rect);
        
        if self.point != nil {
            let str = "\(self.point!.x) , \(self.point!.y)" as NSString;
            let attributes = [
                NSFontAttributeName:UIFont.systemFontOfSize(10),
                NSForegroundColorAttributeName: UIColor.whiteColor()
            ];
            str.drawInRect(CGRectMake(self.point!.x, self.point!.y - 20, 100, 50), withAttributes: attributes);
        }
        
        (self.ytitle as NSString).drawInRect(CGRectMake( 2*p + radius, rect.height/2 - 20, 100, 20), withAttributes: attributes);
        
        
        let vRect = CGRectMake(2*p + radius, 2*p + radius, rect.width - 4*p - 2*radius, rect.height - 5*p - 2*radius);
        
        ChartValues(rect: vRect,values: self.values).drawValues();
        
    }
    
    func drawLines(rect:CGRect)
    {
        let ctx = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(ctx, true);
        
        UIColor.whiteColor().set();
       
        CGContextMoveToPoint(ctx, 2*p + radius, rect.height - 2*p - radius);
        CGContextAddLineToPoint(ctx, rect.width - 2*p - radius, rect.height - 2*p - radius);
        CGContextStrokePath(ctx);
    }
    
    func drawBackGroundPath(ctx:CGContextRef?,rect:CGRect)
    {
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
    }
    
    func drawBackGround(rect:CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(ctx, true);
        
        //let w = rect.width - 2*p;
        //let h = rect.height - 2*p;
        
        self.color.set();
        self.drawBackGroundPath(ctx, rect: rect);
        CGContextFillPath(ctx);
        CGContextSaveGState(ctx);

        /*self.drawBackGroundPath(ctx, rect: rect);
        CGContextClip(ctx);
        
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let startColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8);
        let startColorComponents = CGColorGetComponents(startColor.CGColor);
        
        let endColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1);
        let endColorComponents = CGColorGetComponents(endColor.CGColor);
        
        let colorComponents = [startColorComponents[0],
                               startColorComponents[1],
                               startColorComponents[2],
                               startColorComponents[3],
                               endColorComponents[0],
                               endColorComponents[1],
                               endColorComponents[2],
                               endColorComponents[3]];
        let locations:[CGFloat] = [0.0,1.0];
        let gradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, 2);
        let startPoint = CGPointMake(w, 0);
        let endPoint = CGPointMake(w, h);
        
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, []);
        CGContextSaveGState(ctx);*/
    }
    
    class ChartValues {
        
        var rect:CGRect;
        var x:CGFloat {
            return self.rect.origin.x;
        };
        var y:CGFloat {
            return self.rect.origin.y;
        };
        var w:CGFloat {
            return self.rect.width;
        };
        var h:CGFloat {
            return self.rect.height;
        };
        
        var points:[CGPoint] = [];
        
        var maxValue:Int? = nil;
        var minValue:Int? = nil;
        var maxY:CGFloat? = nil;
        var minY:CGFloat? = nil;
        
        var values:[ChartValue] = [] {
            didSet{
                self.points = self.valuesToPoints(self.values);
            }
        };

        init(rect:CGRect,values:[ChartValue]){
            self.rect = rect;
            self.points = self.valuesToPoints(values);
        }
        
        func drawValues()
        {
            let ctx = UIGraphicsGetCurrentContext();
            CGContextSetAllowsAntialiasing(ctx, true);
            
            if self.minY != nil {
                self.drawLine(ctx, y: self.minY!);
                
                ("\(self.minValue!)" as NSString).drawInRect(CGRectMake(self.x, self.y + self.h - 10, 20, 10), withAttributes: attributes);
            }
            
            if self.maxY != nil {
                self.drawLine(ctx, y: self.maxY!);
                
                ("\(self.maxValue!)" as NSString).drawInRect(CGRectMake(self.x, self.y - 10, 20, 10), withAttributes: attributes);
            }
            
            UIColor.whiteColor().set();
            
            var i = 0;
            for point in self.points {
                
                CGContextAddArc(ctx, point.x, point.y, 2, 0, CGFloat(2*M_PI), 0);
                CGContextFillPath(ctx);
                CGContextSaveGState(ctx);
                
                if i > 0 {
                    let onPoint = self.points[i-1];
                    CGContextMoveToPoint(ctx, onPoint.x, onPoint.y);
                    CGContextAddLineToPoint(ctx, point.x, point.y);
                    CGContextStrokePath(ctx);
                    CGContextSaveGState(ctx);
                }
                
                i += 1;
            }
            
            CGContextMoveToPoint(ctx, self.x, self.y + self.h);
            for point in self.points {
                CGContextAddLineToPoint(ctx, point.x, point.y);
            }
            
            CGContextAddLineToPoint(ctx, self.x + self.w, self.y + self.h);
            
            CGContextClip(ctx);
            
            let colorSpace = CGColorSpaceCreateDeviceRGB();
            let startColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5);
            let startColorComponents = CGColorGetComponents(startColor.CGColor);
            
            let endColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0);
            let endColorComponents = CGColorGetComponents(endColor.CGColor);
            
            let colorComponents = [startColorComponents[0],
                                   startColorComponents[1],
                                   startColorComponents[2],
                                   startColorComponents[3],
                                   endColorComponents[0],
                                   endColorComponents[1],
                                   endColorComponents[2],
                                   endColorComponents[3]];
            let locations:[CGFloat] = [0.0,1.0];
            let gradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, 2);
            let startPoint = CGPointMake(self.x + self.w, self.y);
            let endPoint = CGPointMake(self.x + self.w, self.y + h);
            
            CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, []);
            CGContextSaveGState(ctx);

        }
        
        private func drawLine(ctx:CGContextRef?,y:CGFloat)
        {
            CGContextBeginTransparencyLayer(ctx, nil);
            UIColor.whiteColor().set();
            CGContextSetLineWidth(ctx, 0.5);
            //CGContextSetLineDash(ctx, 0, [3,1,3], 3);
            CGContextMoveToPoint(ctx, self.x, y);
            CGContextAddLineToPoint(ctx, self.x + self.w, y);
            CGContextStrokePath(ctx);
            CGContextEndTransparencyLayer(ctx);
        }
        
        
        private func valuesToPoints(values:[ChartValue]) -> [CGPoint] {
            if values.isEmpty {
                return [];
            }
            
            var points:[CGPoint] = [];
            
            let maxTime:NSTimeInterval = values.last!.time;
            let minTime:NSTimeInterval = values.first!.time;
            
            for value in values {
                
                if maxValue == nil || value.value > maxValue {
                    maxValue = value.value;
                }
                
                if minValue == nil || value.value < minValue {
                    minValue = value.value;
                }
            }
            
            if self.maxValue == self.minValue {
                self.maxValue = self.minValue! + 10;
            }
            
            let ynum = self.h / CGFloat(maxValue! - minValue!);
            let xnum = self.w / CGFloat(maxTime - minTime);
            
            for value in values {
                let x = CGFloat(value.time - minTime)*xnum + self.x;
                let y = self.h - CGFloat(value.value - minValue!)*ynum + self.y;
                
                if value.value == self.minValue {
                    self.minY = y;
                } else if value.value == self.maxValue {
                    self.maxY = y;
                }
                
                points.append(CGPointMake(x, y));
            }
            
            return points;
        }
    }
}
