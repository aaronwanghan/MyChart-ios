//
//  ChartData.swift
//  MyChart
//
//  Created by wh-pc on 16/5/12.
//  Copyright © 2016年 hope. All rights reserved.
//

import UIKit

class ChartData
{
    var minValue:CGFloat!;
    var maxValue:CGFloat!;
    var lengths:[CGFloat] = [1,1];
    
    var items:[ChartDataItem] = [] {
        didSet{
            self.initValues();
        }
    };
    
    var title:String!;
    
    init(_ items:[ChartDataItem],_ title:String)
    {
        self.items = items;
        self.title = title;
        self.initValues();
    }
    
    private func initValues(){
        if self.items.isEmpty {
            self.minValue = 0;
            self.maxValue = 0;
            return;
        }
        
        self.minValue = self.items.first!.value;
        self.maxValue = self.minValue;
        
        for item in self.items {
            if self.minValue > item.value {
                self.minValue = item.value;
            } else if self.maxValue < item.value {
                self.maxValue = item.value;
            }
        }
        
        if self.maxValue == self.minValue {
            self.maxValue = self.minValue + 10;
        }
    }
}

class ChartDataItem
{
    var time:NSTimeInterval!;
    var value:CGFloat!;
    
    init(_ time:NSTimeInterval,_ value:CGFloat)
    {
        self.time = time;
        self.value = value;
    }
}