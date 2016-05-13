//
//  ViewController.swift
//  MyChart
//
//  Created by wh-pc on 16/5/11.
//  Copyright © 2016年 hope. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var chartView: MyChart2!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = [ChartDataItem(1403366400000.0 , 109),
                     ChartDataItem(1403452800000.0 , 110),
                     ChartDataItem(1403539200000.0 , 100),
                     ChartDataItem(1403625600000.0 , 109),
                     ChartDataItem(1404057600000.0 , 110),
                     ChartDataItem(1404230400000.0 , 108)];
        
        let items1 = [ChartDataItem(1403366400000.0 , 59),
                     ChartDataItem(1403452800000.0 , 50),
                     ChartDataItem(1403539200000.0 , 50),
                     ChartDataItem(1403625600000.0 , 59),
                     ChartDataItem(1404057600000.0 , 50),
                     ChartDataItem(1404230400000.0 , 48)];
        
        let item2 = [ChartDataItem(1403366400000.0 , 2),
                     ChartDataItem(1403452800000.0 , 4),
                     ChartDataItem(1403539200000.0 , 8),
                     ChartDataItem(1403625600000.0 , 1),
                     ChartDataItem(1404057600000.0 , 5),
                     ChartDataItem(1404230400000.0 , 2)];
        
        self.chartView.lineDatas = [ChartData(items,"l1"),ChartData(items1,"l2")];
        
        self.chartView.barDatas = [ChartData(item2,"b1"),ChartData(items1,"b2"),ChartData(items,"b3")];

        self.chartView.yTitle = "kg";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

