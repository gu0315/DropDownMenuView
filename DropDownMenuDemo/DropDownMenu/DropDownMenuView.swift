//
//  DropDownMenuView.swift
//  DropDownMenuDemo
//
//  Created by 顾钱想 on 2020/8/3.
//  Copyright © 2020 顾钱想. All rights reserved.
//

import UIKit
import Foundation
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHight = UIScreen.main.bounds.height
@objc public enum DMenuViewColumnType: Int, RawRepresentable {
    case DMenuViewColumnTypeTableView                         //只有一个tableView
    case DMenuViewColumnTypeCollectionView                    //只有一个CollectionView
    case DMenuViewColumnTypeDoubleTableView                   //双链表,左右各一个tableView
    case DMenuViewColumnTypeLeftTableViewRightCollectionView  //左侧tableView,右侧CollecTionView
}

public class DMRowData:NSObject {
    ///标题
    var titleStr:String?
    ///fileNum
    var fileNum:String?
    ///图标名称
    var imgIcon:String?

    init(titleStr: String, fileNum: String = "", imgIcon: String = "") {
        self.titleStr = titleStr
        self.fileNum = fileNum
        self.imgIcon = imgIcon
    }

    init(rowData: DMRowData) {
        self.titleStr = rowData.titleStr
        self.fileNum = rowData.fileNum
        self.imgIcon = rowData.imgIcon
    }
}



@objc public protocol DMenuViewDataSource: NSObjectProtocol {
    /// 菜单返回有多少列
    /// - Parameter menu: 菜单
    @objc func numberOfColumnsInMenu(menu:DropDownMenuView) -> Int

    /// 选中左侧第几列显示多少行
    /// - Parameters:
    ///   - menu: 菜单
    ///   - column: 第几列
    /// - Returns: 返回的行数
    @objc func numberOfRowsInColumn(menu:DropDownMenuView, column: Int) -> Int

    /// 左侧TableView对应的每行的数据
    /// - Parameters:
    ///   - menu: 菜单
    ///   - column: 第几列
    ///   - row: 第几行
    /// - Returns: 菜单第几列第几行的数据
    @objc func titleForRowAtIndexPath(menu:DropDownMenuView, column:Int, row: Int) -> DMRowData

    /// 设置菜单第右column列,左侧TableView第row行的右侧CollectionView或者TableView有多少条数据
    /// - Parameters:
    ///   - menu: 菜单
    ///   - column: 第几列
    ///   - row: 左侧TableView第row行
    /// - Returns: Data
    @objc optional func numberOfRightItemInMenu(menu:DropDownMenuView, column: Int, row: Int) -> Int
    /// 设置菜单第右column列,左侧TableView第row行的右侧CollectionView或者TableView对应的每行的数据
    /// - Parameters:
    ///   - menu: 菜单
    ///   - column: 第几列
    ///   - row: 左侧TableView第row行
    /// - Returns: Data
    @objc optional func titleForRightRowAtIndexPath (menu:DropDownMenuView, column: Int, leftRow: Int, rightRow: Int) -> DMRowData

    /// 返回菜单第column列的类型,默认只有一个tableView
    /// - Parameters:
    ///   - menu: 菜单
    ///   - column: 第几列
    @objc optional func columnTypeInMenu(menu:DropDownMenuView, column: Int) -> DMenuViewColumnType
    
    /// 菜单第column列左边tableView所占比例
    /// - Parameters:
    ///   - menu: 菜单
    ///   - column: 第几列
    @objc optional func leftTableViewWidthScale(menu:DropDownMenuView, column: Int) -> CGFloat
}

@objc public protocol DMenuViewDelegate: NSObjectProtocol {
    /// 点击回掉
    /// - Parameters:
    ///   - menu: 菜单
    ///   - column: 第几列
    ///   - leftRow: 左侧第多少行
    ///   - rightRow: 右侧第多少行
    @objc optional func didSelectRowAtIndexPath(menu:DropDownMenuView, column: Int, leftRow: Int, rightRow: Int);

    /// 标签选择显示状态
    /// - Parameters:
    ///   - menu:  菜单
    ///   - isShow: 是否显示
    @objc optional func menuIsShow(menu:DropDownMenuView, isShow: Bool)
}

// MARK: - 指示器图标位置枚举
public enum IndicatorAlignType {
    case IndicatorAlignRight               //指示图标居右
    case IndicatorAlignCloseToTitle        //指示图标挨着文字
}

public class DropDownMenuView: UIView,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource {
    var configuration = DMConfiguration()
    ///菜单分区标题
    var menuTitles:NSArray = []
    ///标签UILabel
    var titleTextLayers = [CATextLayer]()
    ///三角指示
    var indicatorsLayers = [CAShapeLayer]()
    ///当前选中列
    var currentSelectedMenudIndex:Int = 0
    ///是否显示
    var show:Bool = false
    ///背景View
    var backGroundView = UIView()
    ///左侧TableView选中的Row,或者单个CollectionView选中的Item
    private var selectRowArray = [Int]()
    ///右侧TableView或者CollectionView选中的Item
    private var rightSelectRowArray = [Int]()

    public weak var delegate: DMenuViewDelegate?

    public weak var dataSource: DMenuViewDataSource? {
        didSet {
            guard let dataSource = dataSource else { return }
            ///有多少分区
            configuration.numOfMenu = dataSource.numberOfColumnsInMenu(menu: self)
            backGroundView = UIView.init(frame: CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: kScreenHight))
            backGroundView.backgroundColor = configuration.maskColor
            backGroundView.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer.init(target: self, action: #selector(self.backgroundTapped))
            backGroundView.addGestureRecognizer(gesture)

            ///移除标签,标签分割线
            for titleTextLayer in titleTextLayers {
                titleTextLayer.removeFromSuperlayer()
            }
            for layer in indicatorsLayers {
                layer.removeFromSuperlayer()
            }
            titleTextLayers.removeAll()
            selectRowArray.removeAll()
            rightSelectRowArray.removeAll()
            let textCenterX:CGFloat = self.frame.size.width / CGFloat((configuration.numOfMenu * 2))
            let centerY = self.frame.height / 2
            for i in 0 ..< configuration.numOfMenu {
                selectRowArray.append(0)
                rightSelectRowArray.append(-1)
                let titlePosition = CGPoint.init(x: CGFloat((i*2+1))*textCenterX, y: centerY)
                var titleText = dataSource.titleForRowAtIndexPath(menu: self, column: i, row: 0).titleStr
                if((dataSource.titleForRightRowAtIndexPath?(menu: self, column: i, leftRow: 0, rightRow: 0)) != nil && (dataSource.columnTypeInMenu?(menu: self, column: i) == .DMenuViewColumnTypeDoubleTableView || dataSource.columnTypeInMenu?(menu: self, column: i) == .DMenuViewColumnTypeLeftTableViewRightCollectionView)) {
                    titleText = dataSource.titleForRightRowAtIndexPath!(menu: self, column: i, leftRow: 0, rightRow: 0).titleStr
                }
                let titleLayer = self.createTextLayerWithStr(str: titleText ?? "", color: configuration.titleColor, point: titlePosition, index: i)
                self.layer.addSublayer(titleLayer)
                titleTextLayers.append(titleLayer)
                ///是否显示分割线
                if (configuration.isShowSeparator) {
                    let separatorPosition = CGPoint(x:(CGFloat((i+1)) * self.frame.size.width / CGFloat(configuration.numOfMenu)) + 1,y: self.frame.size.height / 2)
                    let separator = self.createSeparatorLineWithColor(color: configuration.separatorColor, point: separatorPosition)
                    self.layer.addSublayer(separator)
                }

                let indicatorPosition = CGPoint(x:(CGFloat((i+1)) * self.frame.size.width / CGFloat(configuration.numOfMenu)) - 15,y: self.frame.size.height / 2)
                let indicator = self.createIndicatorWithColor(color: .lightGray, point: indicatorPosition)

                self.layer.addSublayer(indicator)
                indicatorsLayers.append(indicator)
                ///更新指示器的位置
                self.layoutIndicator(indicator: indicator, title: titleLayer)
            }
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    // TODO:外部不可访问的属性
    private lazy var leftTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 0))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(TagTableViewCell.self, forCellReuseIdentifier: "TagTableViewCell")
        return tableView
    }()

    private lazy var rightTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 0))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(TagTableViewCell.self, forCellReuseIdentifier: "TagTableViewCell")
        return tableView
    }()

   private lazy var collectionView: UICollectionView = {
         let layout = UICollectionViewFlowLayout()
         layout.itemSize = CGSize.init(width: 75, height: 25)
         layout.scrollDirection = .vertical
         layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
         layout.minimumLineSpacing = 10
         let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
         collectionView.backgroundColor = UIColor.white
         collectionView.showsHorizontalScrollIndicator = false
         collectionView.showsVerticalScrollIndicator = false
         collectionView.isPagingEnabled = true
         collectionView.delegate = self
         collectionView.dataSource = self
         collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCollectionViewCell")
         return collectionView
    }()

    ///初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        ///添加头部点击事件
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(menuTaped(sender:)))
        self.addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UITapGestureRecognizer
    @objc func menuTaped(sender: UITapGestureRecognizer) {
        guard let dataSource = dataSource else { return }
        let touchPoint = sender.location(in: self)
        let tapIndex:Int = Int(touchPoint.x / (self.frame.size.width / CGFloat(configuration.numOfMenu)))
        for i in 0 ..< configuration.numOfMenu {
            ///选中时向下
            if  indicatorsLayers[i].fillColor == configuration.highlightedTextColor.cgColor {
                self.animateIndicatorShapeLayer(indicator: indicatorsLayers[currentSelectedMenudIndex], forward: false) {
                    self.animateTitle(title: titleTextLayers[currentSelectedMenudIndex], forward: false) {
                    }
                }
            }
        }
        if  tapIndex == currentSelectedMenudIndex && show {
            //收缩
            self.animateIndicatorShapeLayer(indicator: indicatorsLayers[currentSelectedMenudIndex], forward: false) {
                show = false
                currentSelectedMenudIndex = tapIndex
                titleTextLayers[tapIndex].foregroundColor = configuration.titleColor.cgColor
                self.animateBackGroundView(show: false) {
                    self.animateContentView(isShow: false) {}
                }
            }
        } else {
            currentSelectedMenudIndex = tapIndex
            //展开
            //代理返回要刷新那个控制器
            guard let columnType = dataSource.columnTypeInMenu?(menu: self, column: tapIndex) else {
                 ///刷新默认单个tableView
                 leftTableView.reloadData()
                 return
            }
            switch columnType {
            case .DMenuViewColumnTypeTableView:
                 leftTableView.reloadData()
            case .DMenuViewColumnTypeCollectionView:
                 collectionView.reloadData()
            case .DMenuViewColumnTypeDoubleTableView:
                 leftTableView.reloadData()
                 rightTableView.reloadData()
            case .DMenuViewColumnTypeLeftTableViewRightCollectionView:
                 leftTableView.reloadData()
                 collectionView.reloadData()
            }
            self.animateIndicatorShapeLayer(indicator: indicatorsLayers[currentSelectedMenudIndex], forward: true) {
                self.animateTitle(title: titleTextLayers[tapIndex], forward: true) {
                    self.animateBackGroundView(show: true) {
                        self.animateContentView(isShow: true) {
                            self.show = true
                            self.delegate?.menuIsShow?(menu: self, isShow: true)
                        }
                    }
                }
            }
        }
    }
    ///创建CATextLayer
    private func createTextLayerWithStr(str: String, color: UIColor, point: CGPoint, index: Int) -> CATextLayer {
        let size = self.calculateTitleSizeWithStr(str: str)
        let textLayer = CATextLayer()
        textLayer.bounds = CGRect.init(x: 0, y: 0, width: min(size.width, self.frame.size.width / CGFloat(configuration.numOfMenu) - 35), height: size.height);
        textLayer.fontSize = configuration.fontSize
        textLayer.alignmentMode = .center
        textLayer.truncationMode = .end
        textLayer.foregroundColor = configuration.titleColor.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.string = str
        textLayer.position = point
        return textLayer
    }

    /// 计算标签尺寸
    private func calculateTitleSizeWithStr(str: String) -> CGSize {
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: CGFloat(16.0))]
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = str.boundingRect(with: CGSize.init(width: 280, height: 0), options:options,  attributes: attributes, context: nil)
        return CGSize.init(width: CGFloat(ceilf(Float(rect.size.width))+2), height: rect.size.height)
    }

    /// 绘制Menu分割线
    private func createSeparatorLineWithColor(color: UIColor, point: CGPoint) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let height = self.frame.size.height * configuration.separatorHeighPercent
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x: point.x, y: (self.frame.height - height) / 2))
        path.addLine(to: CGPoint.init(x: point.x, y: (self.frame.height - height) / 2 + height))
        layer.path = path.cgPath
        layer.lineWidth = 1
        layer.strokeColor = color.cgColor
        layer.lineJoin = .round
        layer.lineCap = .round
        return layer
    }

    ///绘制指示图标三角形
    private func createIndicatorWithColor(color: UIColor, point: CGPoint) -> CAShapeLayer {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0,y: 0))
        path.addLine(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: 4, y: 5))
        path.close()

        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = 0.8
        layer.fillColor = color.cgColor
        let boundingPath = layer.path?.copy(strokingWithWidth: layer.lineWidth, lineCap: CGLineCap.butt, lineJoin: CGLineJoin.miter, miterLimit: layer.miterLimit)
        layer.bounds = (boundingPath ?? CGPath.init(rect: CGRect.zero, transform: [])).boundingBoxOfPath
        layer.position = point
        return layer
    }

    ///更新指示器位置
    private func layoutIndicator(indicator:CALayer, title: CATextLayer) {
        guard let str = title.string as? String  else {return}
        let size = self.calculateTitleSizeWithStr(str: str)
        let sizeWidth = min(size.width, self.frame.size.width / CGFloat(configuration.numOfMenu) - 30)
        title.bounds = CGRect.init(x: 0, y: 0, width: sizeWidth, height: size.height)
        if configuration.indicatorAlignType == .IndicatorAlignCloseToTitle {
            indicator.frame.origin.x = title.frame.maxX + 3
        }
    }

    ///指示器旋转
    private func animateIndicatorShapeLayer(indicator:CAShapeLayer, forward: Bool, complete: () -> Void) {
       // 开启事务
       CATransaction.begin()
       CATransaction.setAnimationDuration(0.1)
       CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))
       let anim = CAKeyframeAnimation.init(keyPath: "transform.rotation")
       anim.values = forward ? [0, CGFloat.pi] : [CGFloat.pi, 0]
       anim.fillMode = .forwards
       anim.isRemovedOnCompletion = false
       indicator.add(anim, forKey: anim.keyPath)
       CATransaction.commit()
       if forward {
          //展开
          indicator.fillColor = configuration.highlightedTextColor.cgColor
       } else {
          //收缩
          indicator.fillColor = configuration.textColor.cgColor
       }
       complete()
    }

    ///更新标签选择器标题
    private func animateTitle(title: CATextLayer, forward: Bool, complete: () -> Void) {
        var str = ""
        if (title.string != nil) {
            str = title.string as! String
        }
        let size = self.calculateTitleSizeWithStr(str: str)
        let sizeWidth = (size.width < (self.frame.size.width / CGFloat(configuration.numOfMenu)) - 25) ? size.width : self.frame.size.width / CGFloat(configuration.numOfMenu) - 25
        title.bounds = CGRect.init(x: 0, y: 0, width: sizeWidth, height: size.height)
        if forward {
           title.foregroundColor = configuration.highlightedTextColor.cgColor
        } else {
           title.foregroundColor = configuration.textColor.cgColor
        }
        complete()
    }

    ///位置计算
    private func animateContentView(isShow: Bool, complete:@escaping () -> Void) {
        guard let dataSource = dataSource else { return }
        var columnType: DMenuViewColumnType = .DMenuViewColumnTypeTableView
        if dataSource.columnTypeInMenu?(menu: self, column: currentSelectedMenudIndex) != nil {
            columnType = dataSource.columnTypeInMenu!(menu: self, column: currentSelectedMenudIndex)
        }
        var scale: CGFloat = columnType == .DMenuViewColumnTypeTableView ? 1 : 0.5;
        if dataSource.leftTableViewWidthScale?(menu: self, column: currentSelectedMenudIndex) != nil {
            scale = dataSource.leftTableViewWidthScale!(menu: self, column: currentSelectedMenudIndex)
        }
        let maxheight = (self.superview?.frame.size.height ?? kScreenHight) - self.frame.size.height - Common.share.bottomHeight() - Common.share.topHeight()
        let originy = self.frame.origin.y + self.frame.size.height
        let originx = self.frame.origin.x
        if isShow {
            switch columnType {
            case .DMenuViewColumnTypeTableView:
                 leftTableView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth, height: 0)
                 rightTableView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth, height: 0)
                 collectionView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth, height: 0)
                 self.superview?.addSubview(leftTableView)
                 leftTableView.tableFooterView = UIView.init(frame: .zero)
            case .DMenuViewColumnTypeCollectionView:
                 leftTableView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth, height: 0)
                 rightTableView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth, height: 0)
                 collectionView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth, height: 0)
                 self.superview?.addSubview(collectionView)
            case .DMenuViewColumnTypeDoubleTableView:
                 leftTableView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth * scale, height: 0)
                 rightTableView.frame = CGRect.init(x: kScreenWidth * scale, y: originy, width: kScreenWidth * (1 - scale), height: 0)
                 collectionView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth, height: 0)
                 self.superview?.addSubview(leftTableView)
                 self.superview?.addSubview(rightTableView)
                 leftTableView.tableFooterView = UIView.init(frame: .zero)
                 rightTableView.tableFooterView = UIView.init(frame: .zero)
            case .DMenuViewColumnTypeLeftTableViewRightCollectionView:
                 leftTableView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth * scale, height: 0)
                 rightTableView.frame = CGRect.init(x: originx, y: originy, width: kScreenWidth, height: 0)
                 collectionView.frame = CGRect.init(x: kScreenWidth * scale, y: originy, width: kScreenWidth * (1 - scale), height: 0)
                 self.superview?.addSubview(leftTableView)
                 self.superview?.addSubview(collectionView)
                 leftTableView.tableFooterView = UIView.init(frame: .zero)
            }
            UIView.animate(withDuration: 0.2, animations: {
                switch columnType {
                case .DMenuViewColumnTypeTableView:
                     let num = self.leftTableView.numberOfRows(inSection: 0)
                     if self.configuration.isAdaptiveHeight {
                        let leftTableViewHeight = CGFloat(num) * self.configuration.cellHeight >= maxheight ? maxheight : CGFloat(num) * self.configuration.cellHeight
                        self.leftTableView.frame = CGRect.init(x: self.leftTableView.frame.origin.x, y: originy, width: kScreenWidth, height: leftTableViewHeight)
                     } else {
                        self.leftTableView.frame = CGRect.init(x: self.leftTableView.frame.origin.x, y: originy, width: kScreenWidth, height: self.configuration.contentViewHeight)
                     }
                case .DMenuViewColumnTypeCollectionView:
                     if self.configuration.isAdaptiveHeight {
                        self.collectionView.reloadData()
                        var tempHt = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                        tempHt = tempHt > maxheight ? maxheight : tempHt + 10
                        self.collectionView.frame = CGRect.init(x: self.collectionView.frame.origin.x, y: originy, width: kScreenWidth, height: tempHt)
                     } else {
                        self.collectionView.frame = CGRect.init(x: self.collectionView.frame.origin.x, y: originy, width: kScreenWidth, height: self.configuration.contentViewHeight)
                     }
                case .DMenuViewColumnTypeDoubleTableView:
                     _ = self.compareUpdateHeight()
                case .DMenuViewColumnTypeLeftTableViewRightCollectionView:
                     _ = self.compareUpdateHeight()
                }
            }) { (finished) in
                complete()
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                   switch columnType {
                   case .DMenuViewColumnTypeTableView:
                   self.leftTableView.frame = CGRect.init(x: self.leftTableView.frame.origin.x, y: originy, width: self.leftTableView.frame.size.width, height: 0)
                   case .DMenuViewColumnTypeCollectionView:
                        self.collectionView.frame = CGRect.init(x: self.collectionView.frame.origin.x, y: originy, width: self.collectionView.frame.size.width, height: 0)
                   case .DMenuViewColumnTypeDoubleTableView:
                        self.leftTableView.frame = CGRect.init(x: self.leftTableView.frame.origin.x, y: originy, width: self.leftTableView.frame.size.width, height: 0)
                        self.rightTableView.frame = CGRect.init(x: self.rightTableView.frame.origin.x, y: originy, width: self.rightTableView.frame.size.width, height: 0)
                   case .DMenuViewColumnTypeLeftTableViewRightCollectionView:
                        self.leftTableView.frame = CGRect.init(x: self.leftTableView.frame.origin.x, y: originy, width: self.leftTableView.frame.size.width, height: 0)
                        self.collectionView.frame = CGRect.init(x: self.collectionView.frame.origin.x, y: originy, width: self.collectionView.frame.size.width, height: 0)
                   }
            }) { (finished) in
                self.removeListFromSuperview()
                complete()
            }
        }
    }

    ///移除View
    private func removeListFromSuperview() {
        if leftTableView.superview != nil {
           leftTableView.removeFromSuperview()
        }
        if rightTableView.superview != nil {
           rightTableView.removeFromSuperview()
        }
        if collectionView.superview != nil {
           collectionView.removeFromSuperview()
        }
    }

    ///比价双链表高度,并返回最大高度
    private func compareUpdateHeight() -> CGFloat {
        guard let dataSource = dataSource else { return configuration.contentViewHeight}
        let num = self.leftTableView.numberOfRows(inSection: 0)
        let maxheight = (self.superview?.frame.size.height ?? kScreenHight) - self.frame.size.height - Common.share.bottomHeight() - Common.share.topHeight()
        var leftTableViewHeight = configuration.contentViewHeight
        if configuration.isAdaptiveHeight {
            leftTableViewHeight = CGFloat(num) * self.configuration.cellHeight >= maxheight ? maxheight : CGFloat(num) * configuration.cellHeight
        }
        var columnType: DMenuViewColumnType = .DMenuViewColumnTypeTableView
        if dataSource.columnTypeInMenu?(menu: self, column: currentSelectedMenudIndex) != nil {
            columnType = dataSource.columnTypeInMenu!(menu: self, column: currentSelectedMenudIndex)
        }
        if columnType == .DMenuViewColumnTypeDoubleTableView {
            ///比较leftTableView和rightTableView高度
            let rightNum = rightTableView.numberOfRows(inSection: 0)
            var rightTableViewHeight = configuration.contentViewHeight
            if configuration.isAdaptiveHeight {
                rightTableViewHeight = CGFloat(rightNum) * self.configuration.cellHeight >= maxheight ? maxheight : CGFloat(rightNum) * configuration.cellHeight
            }
            self.leftTableView.frame = CGRect.init(x: self.leftTableView.frame.origin.x, y: self.leftTableView.frame.origin.y, width: self.leftTableView.frame.size.width, height: max(leftTableViewHeight,rightTableViewHeight))
            self.rightTableView.frame = CGRect.init(x:self.rightTableView.frame.origin.x, y: self.rightTableView.frame.origin.y, width: self.rightTableView.frame.size.width, height: max(leftTableViewHeight,rightTableViewHeight))
            return max(leftTableViewHeight,rightTableViewHeight)
        } else if columnType == .DMenuViewColumnTypeLeftTableViewRightCollectionView {
           if configuration.isAdaptiveHeight {
              self.collectionView.reloadData()
              var tempHt = self.collectionView.collectionViewLayout.collectionViewContentSize.height - 0.5
              tempHt = tempHt > maxheight ? maxheight : tempHt
              self.leftTableView.frame = CGRect.init(x: self.leftTableView.frame.origin.x, y: self.leftTableView.frame.origin.y, width: self.leftTableView.frame.size.width, height: max(leftTableViewHeight,tempHt))
              self.collectionView.frame = CGRect.init(x: self.collectionView.frame.origin.x, y: self.collectionView.frame.origin.y, width: self.collectionView.frame.size.width, height: max(leftTableViewHeight,tempHt))
              return max(leftTableViewHeight,tempHt)
           }
           return configuration.contentViewHeight
        }
        return configuration.contentViewHeight
    }

    /// 背景颜色
    private func animateBackGroundView(show: Bool, complete: () -> Void)  {
        if show {
            self.superview?.addSubview(backGroundView)
            backGroundView.superview?.addSubview(self)
            UIView.animate(withDuration: 0.2) {
                self.backGroundView.backgroundColor = self.configuration.maskColor
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.backGroundView.backgroundColor = self.configuration.maskColor
            }) { (complete) in
                self.backGroundView.removeFromSuperview()
            }
        }
        complete()
    }

    @objc private func backgroundTapped() {
        self.animateIndicatorShapeLayer(indicator: indicatorsLayers[currentSelectedMenudIndex], forward: false) {
           self.animateTitle(title: titleTextLayers[currentSelectedMenudIndex], forward: false) {
               self.animateBackGroundView(show: false) {
                   self.animateContentView(isShow: false) {
                       self.show = false
                       self.delegate?.menuIsShow?(menu: self, isShow: false)
                   }
               }
           }
        }
    }

    ///刷新数据
    func reloadData() {
        self.animateBackGroundView(show: false) {
            self.animateContentView(isShow: false) {
                self.animateContentView(isShow: false) {
                    self.show = false
                    let id = self.dataSource
                    self.dataSource = nil
                    self.dataSource = id
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension DropDownMenuView {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        var columnType: DMenuViewColumnType = .DMenuViewColumnTypeCollectionView
        if dataSource.columnTypeInMenu?(menu: self, column: currentSelectedMenudIndex) != nil {
            columnType = dataSource.columnTypeInMenu!(menu: self, column: currentSelectedMenudIndex)
        }
        if columnType == .DMenuViewColumnTypeCollectionView {
            return dataSource.numberOfRowsInColumn(menu: self, column: currentSelectedMenudIndex)
        } else {
            return dataSource.numberOfRightItemInMenu?(menu: self, column: currentSelectedMenudIndex, row: selectRowArray[currentSelectedMenudIndex]) ?? 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        guard let dataSource = dataSource else { return cell}
        cell.textLab.textColor = configuration.textColor
        cell.textLab.font = configuration.cellTitleFont
        cell.textLab.highlightedTextColor = UIColor.white
        var columnType: DMenuViewColumnType = .DMenuViewColumnTypeCollectionView
        if dataSource.columnTypeInMenu?(menu: self, column: currentSelectedMenudIndex) != nil {
            columnType = dataSource.columnTypeInMenu!(menu: self, column: currentSelectedMenudIndex)
        }
        if columnType == .DMenuViewColumnTypeCollectionView {
            if selectRowArray[currentSelectedMenudIndex] == indexPath.row {
                cell.textLab.isHighlighted = true
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                cell.textLab.backgroundColor = configuration.highlightedTextColor
            } else {
                cell.textLab.isHighlighted = false
                cell.textLab.backgroundColor = UIColor.init(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            }
            cell.textLab.text = dataSource.titleForRowAtIndexPath(menu: self, column: currentSelectedMenudIndex, row: indexPath.row).titleStr
        } else {
            if rightSelectRowArray[currentSelectedMenudIndex] == indexPath.row {
                cell.textLab.isHighlighted = true
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                cell.textLab.backgroundColor = configuration.highlightedTextColor
            } else {
                cell.textLab.isHighlighted = false
                cell.textLab.backgroundColor = UIColor.init(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            }
            cell.textLab.text = dataSource.titleForRightRowAtIndexPath?(menu: self, column: currentSelectedMenudIndex, leftRow: selectRowArray[currentSelectedMenudIndex], rightRow:configuration.isRemainMenuTitle ? indexPath.row : 0).titleStr
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = dataSource else { return }
        var columnType: DMenuViewColumnType = .DMenuViewColumnTypeTableView
        if dataSource.columnTypeInMenu?(menu: self, column: currentSelectedMenudIndex) != nil {
            columnType = dataSource.columnTypeInMenu!(menu: self, column: currentSelectedMenudIndex)
        }
        let title = titleTextLayers[currentSelectedMenudIndex]
        if columnType == .DMenuViewColumnTypeCollectionView {
            selectRowArray[currentSelectedMenudIndex] = indexPath.row
            title.string = dataSource.titleForRowAtIndexPath(menu: self, column: currentSelectedMenudIndex, row: indexPath.row).titleStr
        } else {
            rightSelectRowArray[currentSelectedMenudIndex] = indexPath.row
            title.string = dataSource.titleForRightRowAtIndexPath?(menu: self, column: currentSelectedMenudIndex, leftRow: selectRowArray[currentSelectedMenudIndex], rightRow:configuration.isRemainMenuTitle ? indexPath.row : 0).titleStr
        }
        self.animateIndicatorShapeLayer(indicator: indicatorsLayers[currentSelectedMenudIndex], forward: false) {
           self.animateTitle(title: titleTextLayers[currentSelectedMenudIndex], forward: false) {
               self.layoutIndicator(indicator:indicatorsLayers[currentSelectedMenudIndex] , title: titleTextLayers[currentSelectedMenudIndex])
               self.animateBackGroundView(show: false) {
                   self.animateContentView(isShow: false) {
                       self.show = false
                       self.delegate?.menuIsShow?(menu: self, isShow: false)
                       if columnType == .DMenuViewColumnTypeCollectionView {
                           self.delegate?.didSelectRowAtIndexPath?(menu: self, column: self.currentSelectedMenudIndex, leftRow: indexPath.row, rightRow: -1)
                       } else {
                           self.delegate?.didSelectRowAtIndexPath?(menu: self, column: self.currentSelectedMenudIndex, leftRow: self.selectRowArray[self.currentSelectedMenudIndex], rightRow: indexPath.row)
                       }
                   }
               }
           }
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension DropDownMenuView {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        if tableView == leftTableView {
            return dataSource.numberOfRowsInColumn(menu: self, column: currentSelectedMenudIndex)
        } else {
            if dataSource.numberOfRightItemInMenu?(menu: self, column: currentSelectedMenudIndex, row: selectRowArray[currentSelectedMenudIndex]) != nil{
                return dataSource.numberOfRightItemInMenu?(menu: self, column: currentSelectedMenudIndex, row: selectRowArray[currentSelectedMenudIndex]) ?? 0
            }
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configuration.cellHeight
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TagTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell", for: indexPath) as! TagTableViewCell
        var columnType: DMenuViewColumnType = .DMenuViewColumnTypeTableView
        guard let dataSource = dataSource else { return cell}
        if dataSource.columnTypeInMenu?(menu: self, column: currentSelectedMenudIndex) != nil {
            columnType = dataSource.columnTypeInMenu!(menu: self, column: currentSelectedMenudIndex) 
        }
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = bgView
        cell.textLabel?.font = configuration.cellTitleFont
        cell.textLabel?.highlightedTextColor = configuration.highlightedTextColor
        cell.textLabel?.textColor = configuration.textColor
        ///是否是双链表
        let isHaveItem = (columnType == .DMenuViewColumnTypeDoubleTableView || columnType == .DMenuViewColumnTypeLeftTableViewRightCollectionView)
        if tableView == leftTableView {
            if indexPath.row == selectRowArray[currentSelectedMenudIndex] {
               cell.isHighlighted = true
               cell.accessoryView = isHaveItem ? nil : UIImageView.init(image: UIImage.init(named: "dui"))
               tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
               cell.isHighlighted = false
               cell.accessoryView = nil
            }
            cell.textLabel?.text = dataSource.titleForRowAtIndexPath(menu: self, column: currentSelectedMenudIndex, row: indexPath.row).titleStr
            let imgIcon = dataSource.titleForRowAtIndexPath(menu: self, column: currentSelectedMenudIndex, row: indexPath.row).imgIcon
            if imgIcon?.isEmpty ?? true {
                cell.imageView?.image = nil
            } else {
                cell.imageView?.image = UIImage.init(named: imgIcon ?? "")
            }

            let fileNum = dataSource.titleForRowAtIndexPath(menu: self, column: currentSelectedMenudIndex, row: indexPath.row).fileNum
            if fileNum?.isEmpty ?? true {
                cell.detailTextLabel?.text = nil
            } else {
                cell.detailTextLabel?.textColor = indexPath.row == selectRowArray[currentSelectedMenudIndex] ? configuration.highlightedTextColor : configuration.textColor;
                cell.detailTextLabel?.font = configuration.cellTitleFont;
                cell.detailTextLabel?.text = "\(fileNum ?? "")"
            }
        } else {
            if indexPath.row == rightSelectRowArray[currentSelectedMenudIndex] {
               cell.isHighlighted = true
               cell.accessoryView = isHaveItem ? nil : UIImageView.init(image: UIImage.init(named: "dui"))
               tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
               cell.isHighlighted = false
               cell.accessoryView = nil
            }
            cell.textLabel?.text = dataSource.titleForRightRowAtIndexPath?(menu: self, column: currentSelectedMenudIndex, leftRow: selectRowArray[currentSelectedMenudIndex], rightRow:configuration.isRemainMenuTitle ? indexPath.row : 0).titleStr
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        let title = titleTextLayers[currentSelectedMenudIndex]
        if tableView == leftTableView {
            if selectRowArray[currentSelectedMenudIndex] != indexPath.row {
               rightSelectRowArray[currentSelectedMenudIndex] = -1
            }
            selectRowArray[currentSelectedMenudIndex] = indexPath.row
            title.string = dataSource?.titleForRowAtIndexPath(menu: self, column: currentSelectedMenudIndex, row: indexPath.row).titleStr
            if dataSource?.columnTypeInMenu?(menu: self, column: currentSelectedMenudIndex) == .DMenuViewColumnTypeDoubleTableView{
                self.animateTitle(title: title, forward: true) {
                    self.layoutIndicator(indicator:indicatorsLayers[currentSelectedMenudIndex] , title: titleTextLayers[currentSelectedMenudIndex])
                    rightTableView.reloadData()
                    _ = self.compareUpdateHeight()
                    self.delegate?.didSelectRowAtIndexPath?(menu: self, column: currentSelectedMenudIndex, leftRow: indexPath.row, rightRow: -1)
                }
            } else if dataSource?.columnTypeInMenu?(menu: self, column: currentSelectedMenudIndex) == .DMenuViewColumnTypeLeftTableViewRightCollectionView{
                self.animateTitle(title: title, forward: true) {
                    self.layoutIndicator(indicator:indicatorsLayers[currentSelectedMenudIndex] , title: titleTextLayers[currentSelectedMenudIndex])
                    collectionView.reloadData()
                    _ = self.compareUpdateHeight()
                    self.delegate?.didSelectRowAtIndexPath?(menu: self, column: currentSelectedMenudIndex, leftRow: indexPath.row, rightRow: -1)
                }
            } else {
                self.animateIndicatorShapeLayer(indicator: indicatorsLayers[currentSelectedMenudIndex], forward: false) {
                    self.animateTitle(title: titleTextLayers[currentSelectedMenudIndex], forward: false) {
                        self.layoutIndicator(indicator:indicatorsLayers[currentSelectedMenudIndex] , title: titleTextLayers[currentSelectedMenudIndex])
                        self.animateBackGroundView(show: false) {
                            self.animateContentView(isShow: false) {
                                self.show = false
                                self.delegate?.menuIsShow?(menu: self, isShow: false)
                                self.delegate?.didSelectRowAtIndexPath?(menu: self, column: self.currentSelectedMenudIndex, leftRow: indexPath.row, rightRow: -1)
                            }
                        }
                    }
                }
            }
        } else {
            rightSelectRowArray[currentSelectedMenudIndex] = indexPath.row
            title.string = dataSource?.titleForRightRowAtIndexPath?(menu: self, column: currentSelectedMenudIndex, leftRow: selectRowArray[currentSelectedMenudIndex], rightRow:configuration.isRemainMenuTitle ? indexPath.row : 0).titleStr
            self.animateIndicatorShapeLayer(indicator: indicatorsLayers[currentSelectedMenudIndex], forward: false) {
                self.animateTitle(title: titleTextLayers[currentSelectedMenudIndex], forward: false) {
                    self.layoutIndicator(indicator:indicatorsLayers[currentSelectedMenudIndex] , title: titleTextLayers[currentSelectedMenudIndex])
                    self.animateBackGroundView(show: false) {
                        self.animateContentView(isShow: false) {
                            self.show = false
                            self.delegate?.menuIsShow?(menu: self, isShow: false)
                            self.delegate?.didSelectRowAtIndexPath?(menu: self, column: self.currentSelectedMenudIndex, leftRow: self.selectRowArray[self.currentSelectedMenudIndex], rightRow: indexPath.row)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewCell
class TagCollectionViewCell: UICollectionViewCell {
    var textLab = UILabel()
    override init(frame: CGRect) {
      super.init(frame: frame)
      self.makeUI()
    }

    func makeUI() {
        textLab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        textLab.textAlignment = .center;
        textLab.layer.cornerRadius = 5
        textLab.layer.masksToBounds = true
        self.addSubview(textLab)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewCell
class TagTableViewCell: UITableViewCell {
    required init?(coder aDecoder:NSCoder) {
       super.init(coder: aDecoder)
    }

    override init(style:UITableViewCell.CellStyle, reuseIdentifier:String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier);
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addLine()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
       super.setSelected(selected, animated: animated)
       // Configure the view for the selected state
    }

    func addLine() {
       self.contentView.addSubview(line)
    }
    lazy var line: UIView = {
        let line = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height - 0.8, width: kScreenWidth , height: 0.8))
        line.backgroundColor = UIColor.lightGray
        return line
    }()

}

