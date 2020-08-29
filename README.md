# DropDownMenuView 下拉菜单

标签选择器下拉菜单,通过代理设置数据,回调 支持高度自适应,支持双链表联动,tableView和collectionView,通过DMConfiguration配置样式,使用方便简单

#Requirements

```
* Swift 5
```

```
* iOS 10.0 +
```
#Use
@objc public protocol DMenuViewDataSource: NSObjectProtocol {
    ///返回有多少列
    @objc func numberOfColumnsInMenu(menu:DropDownMenuView) -> Int
    ///左侧TableView每列有多少条数据
    @objc func numberOfRowsInColumn(menu:DropDownMenuView, column: Int) -> Int
    ///左侧TableView对应的每行的数据
    @objc func titleForRowAtIndexPath(menu:DropDownMenuView, column:Int, row: Int) -> DMRowData
    ///右侧CollectionView或者TableView有多少条数据
    @objc optional func numberOfRightItemInMenu(menu:DropDownMenuView, column: Int, row: Int) -> Int
    ///右侧CollectionView或者TableView对应的每行的数据
    @objc optional func titleForRightRowAtIndexPath (menu:DropDownMenuView, column: Int, leftRow: Int, rightRow: Int) -> DMRowData
    ///返回每列的类型,默认只有一个tableView
    @objc optional func columnTypeInMenu(menu:DropDownMenuView, column: Int) -> DMenuViewColumnType
    ///左边tableView所占比例
    @objc optional func leftTableViewWidthScale(menu:DropDownMenuView, column: Int) -> CGFloat
}

@objc public protocol DMenuViewDelegate: NSObjectProtocol {
    ///点击回掉
    @objc optional func didSelectRowAtIndexPath(menu:DropDownMenuView, column: Int, leftRow: Int, rightRow: Int);
    ///标签选择显示状态
    @objc optional func menuIsShow(menu:DropDownMenuView, isShow: Bool)
}

#Screenshots

[![aOdDgg.gif](https://s1.ax1x.com/2020/08/11/aOdDgg.gif)](https://imgchr.com/i/aOdDgg)

[![aOUBIf.md.gif](https://s1.ax1x.com/2020/08/11/aOUBIf.md.gif)](https://imgchr.com/i/aOUBIf)

[![aOUri8.md.gif](https://s1.ax1x.com/2020/08/11/aOUri8.md.gif)](https://imgchr.com/i/aOUri8)

[![aOdW5V.md.gif](https://s1.ax1x.com/2020/08/11/aOdW5V.md.gif)](https://imgchr.com/i/aOdW5V)



