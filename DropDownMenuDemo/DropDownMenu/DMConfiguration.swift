//
//  DMConfiguration.swift
//  DropDownMenuDemo
//
//  Created by 顾钱想 on 2020/8/3.
//  Copyright © 2020 顾钱想. All rights reserved.
//

import UIKit

final class DMConfiguration {
    ///Cell的高度,默认44
    var cellHeight:CGFloat = 44;
    ///内容的高度
    var contentViewHeight:CGFloat = 300;
    ///是否自适应高度,默认为False
    var isAdaptiveHeight:Bool = false
    ///标题颜色
    var textColor:UIColor = UIColor.darkGray
    // 当有二级列表时，点击row 是否调用点击代理方法
    var isRefreshWhenHaveRightItem:Bool = false
    ///标题选中颜色
    var highlightedTextColor:UIColor = UIColor.orange
    ///有多少分区
    var numOfMenu:Int = 0;
    ///字体大小
    var fontSize:CGFloat = 15
    ///标题的颜色
    var titleColor:UIColor = .darkGray
    ///是否显示分割线颜色.默认显示
    var isShowSeparator:Bool = true
    ///分割线占比高度
    var separatorHeighPercent:CGFloat = 0.5;
    ///分割线颜色
    var separatorColor:UIColor = .lightGray
    ///指示器图标位置,默认文字右侧
    var indicatorAlignType:IndicatorAlignType = .IndicatorAlignCloseToTitle
    ///背景颜色
    var maskColor:UIColor = UIColor.init(white: 0.4, alpha: 0.2)
    ///切换条件时是否更改menu title
    var isRemainMenuTitle:Bool = true
    ///cell文字大小
    var cellTitleFont = UIFont.systemFont(ofSize: 14)
    init() {
       self.defaultValue()
    }

    func defaultValue() {

    }
}

