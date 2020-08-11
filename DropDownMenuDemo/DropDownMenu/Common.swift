//
//  common.swift
//  DropDownMenuDemo
//
//  Created by 顾钱想 on 2020/8/4.
//  Copyright © 2020 顾钱想. All rights reserved.
//

import UIKit

class Common: NSObject {
   static let share = Common()
   let kScreenHeight = UIScreen.main.bounds.height
   public func isX() -> Bool {
       if UIDevice.current.model == "iPad"{
           return false
       }
       if kScreenHeight >= 812 {
           return true
       }
       return false
   }

   public func bottomHeight() -> CGFloat {
       var ht:CGFloat = 0.0;
       if UIDevice.current.model != "iPad"{
           if kScreenHeight >= 812 {
            ht = 34.0
           }
       }
       return ht
   }
   /// 导航栏和状态栏的高度
   public func topHeight() -> CGFloat {
       if #available(iOS 13.0, *) {
         let statusBar = UIView(frame: UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
         return statusBar.frame.size.height + (UIApplication.shared.windows.first?.rootViewController?.navigationController?.navigationBar.frame.size.height ?? 0)
       } else {
          return UIApplication.shared.statusBarFrame.size.height + (UIApplication.shared.keyWindow?.rootViewController?.navigationController?.navigationBar.frame.size.height ?? 0)
       }
    }

}
