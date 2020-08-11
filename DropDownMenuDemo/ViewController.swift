//
//  ViewController.swift
//  DropDownMenuDemo
//
//  Created by 顾钱想 on 2020/8/3.
//  Copyright © 2020 顾钱想. All rights reserved.
//

import UIKit

class ViewController: UIViewController,DMenuViewDelegate,DMenuViewDataSource {
  var menu:DropDownMenuView!
  var sorts = ["综合排序","直播榜","好评榜","新上线"]
  var movices: [(String,String,[String])] = [("排行","385",["排行","销量","好评","距离","人气"]),("电影","12",["电影","速度与激情1","李小龙","肖生克的救赎","极限特工"]),("酒店","128",["酒店","四季","如家","皇家酒店"]),("地区","789",["地区","安徽","南京","合肥"])]
  var areas = [["华语","敢死队1","敢死队2","敢死队3","敢死队4","敢死队1","敢死队2","敢死队3","敢死队4"],["香港地区","李小龙1","李小龙2","李小龙3","李小龙1","李小龙2","李小龙3"],["美国","极限特工1","极限特工2","极限特工3","极限特工4"],["欧洲","极限特工1","极限特工2","极限特工3","极限特工4","极限特工1","极限特工2","极限特工3","极限特工4"],["韩国","极限特工1","极限特工2","极限特工3","极限特工4"],["日本","苍老师1","苍老师2","苍老师3","苍老师4","苍老师1","苍老师2","苍老师3","苍老师4","苍老师1","苍老师2","苍老师3","苍老师4","苍老师1","苍老师2","苍老师3","苍老师4","苍老师1","苍老师2","苍老师3","苍老师4","苍老师1","苍老师2","苍老师3","苍老师4"]]
  var years = ["2020","2019","2018","2017","2016","2015"]
  override func viewDidLoad() {
      super.viewDidLoad()
      self.title = "Menu"
      self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
      menu = DropDownMenuView.init(frame:CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 44))
      let configuration = DMConfiguration()
      configuration.isAdaptiveHeight = true
      menu.configuration = configuration;
      ///如需自定义,先配置在设置代理
      menu.delegate = self
      menu.dataSource = self
      self.view.addSubview(menu)
  }

  func initData() {

  }
    
  // MARK: - DropdownMenuViewDelegate,DropdownMenuViewDataSource
  func didSelectRowAtIndexPath(menu: DropDownMenuView, column: Int, leftRow: Int, rightRow: Int) {
      if (rightRow >= 0) {
           print("点击了 \(column) - \(leftRow) - \(rightRow) 项目")
      }else {
           print("点击了 \(column) - \(leftRow) 项目")
      }
  }

  func menuIsShow(menu: DropDownMenuView, isShow: Bool) {
     if isShow {
        print("---------------展开-----------")
     } else {
        print("---------------关闭-----------")
     }
  }

  func columnTypeInMenu(menu: DropDownMenuView, column: Int) -> DMenuViewColumnType {
      switch column {
      case 0:
        return .DMenuViewColumnTypeTableView
      case 1:
         return .DMenuViewColumnTypeCollectionView
      case 2:
         return .DMenuViewColumnTypeDoubleTableView
      case 3:
         return .DMenuViewColumnTypeLeftTableViewRightCollectionView
      default:
         return .DMenuViewColumnTypeTableView;
      }
  }

  func titleForRowAtIndexPath(menu: DropDownMenuView, column: Int, row: Int) -> DMRowData {
      switch column {
      case 0:
        return DMRowData.init(titleStr: sorts[row])
      case 1:
        return DMRowData.init(titleStr: years[row])
      case 2:
        return DMRowData.init(titleStr: movices[row].2.first ?? "", fileNum: movices[row].1 , imgIcon: movices[row].0 )
      case 3:
        return DMRowData.init(titleStr: areas[row].first ?? "")
      default:
        return DMRowData.init(titleStr: "")
      }
 }

   func titleForRightRowAtIndexPath(menu: DropDownMenuView, column: Int, leftRow: Int, rightRow: Int) -> DMRowData {
        if column == 2 {
           return DMRowData.init(titleStr: movices[leftRow].2[rightRow] )
        } else if column == 3 {
           return DMRowData.init(titleStr: areas[leftRow][rightRow])
        }
        return DMRowData.init(titleStr: "")
  }

  func leftTableViewWidthScale(menu: DropDownMenuView, column: Int) -> CGFloat {
     switch column {
     case 0:
        return 1
     case 1:
        return 1
     case 2:
        return 0.5
     case 3:
        return 0.3
     default:
        return 1
     }
  }

  func numberOfRowsInColumn(menu: DropDownMenuView, column: Int) -> Int {
     switch column {
     case 0:
        return sorts.count
     case 1:
        return years.count
     case 2:
        return movices.count
     case 3:
        return areas.count
     default:
        return sorts.count
     }
  }

  func numberOfRightItemInMenu(menu: DropDownMenuView, column: Int, row: Int) -> Int {
     if column == 2 {
        if movices.count > row {
           return movices[row].2.count
        } else {
           return 0
        }
     } else if column == 3 {
        if areas.count > row {
           return areas[row].count
        } else {
           return 0
        }
    }
    return 0
  }

  func numberOfColumnsInMenu(menu: DropDownMenuView) -> Int {
     return 4
  }
}




