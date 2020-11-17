

# DropDownMenuView 下拉菜单

标签选择器下拉菜单,通过代理设置数据, 支持高度自适应,支持双链表联动tableView和collectionView,链表宽度设置,通过DMConfiguration配置样式,使用方便简单

#Requirements

```
* Swift 5
```

```
* iOS 10.0 +
```

## Demo

[![aOdDgg.gif](https://s1.ax1x.com/2020/08/11/aOdDgg.gif)](https://imgchr.com/i/aOdDgg)

s://imgchr.com/i/aOUBIf)

[![aOUri8.md.gif](https://s1.ax1x.com/2020/08/11/aOUri8.md.gif)](https://imgchr.com/i/aOUri8)

ps://imgchr.com/i/aOdW5V)

[![aOUBIf.md.gif](https://s1.ax1x.com/2020/08/11/aOUBIf.md.gif)

# Use

**@objc** **public** **protocol** DMenuViewDataSource: NSObjectProtocol {

  /// 菜单返回有多少列

  /// - **Parameter** menu: 菜单

  **@objc** **func** numberOfColumnsInMenu(menu:DropDownMenuView) -> Int



  /// 选中左侧第几列显示多少行

  /// - **Parameters**:

  ///  - menu: 菜单

  ///  - column: 第几列

  /// - **Returns**: 返回的行数

  **@objc** **func** numberOfRowsInColumn(menu:DropDownMenuView, column: Int) -> Int



  /// 左侧TableView对应的每行的数据

  /// - **Parameters**:

  ///  - menu: 菜单

  ///  - column: 第几列

  ///  - row: 第几行

  /// - **Returns**: 菜单第几列第几行的数据

  **@objc** **func** titleForRowAtIndexPath(menu:DropDownMenuView, column:Int, row: Int) -> DMRowData



  /// 设置菜单第右column列,左侧TableView第row行的右侧CollectionView或者TableView有多少条数据

  /// - **Parameters**:

  ///  - menu: 菜单

  ///  - column: 第几列

  ///  - row: 左侧TableView第row行

  /// - **Returns**: Data

  **@objc** **optional** **func** numberOfRightItemInMenu(menu:DropDownMenuView, column: Int, row: Int) -> Int

  /// 设置菜单第右column列,左侧TableView第row行的右侧CollectionView或者TableView对应的每行的数据

  /// - **Parameters**:

  ///  - menu: 菜单

  ///  - column: 第几列

  ///  - row: 左侧TableView第row行

  /// - **Returns**: Data

  **@objc** **optional** **func** titleForRightRowAtIndexPath (menu:DropDownMenuView, column: Int, leftRow: Int, rightRow: Int) -> DMRowData



  /// 返回菜单第column列的类型,默认只有一个tableView

  /// - **Parameters**:

  ///  - menu: 菜单

  ///  - column: 第几列

  **@objc** **optional** **func** columnTypeInMenu(menu:DropDownMenuView, column: Int) -> DMenuViewColumnType

   

  /// 菜单第column列左边tableView所占比例

  /// - **Parameters**:

  ///  - menu: 菜单

  ///  - column: 第几列

  **@objc** **optional** **func** leftTableViewWidthScale(menu:DropDownMenuView, column: Int) -> CGFloat

}



**@objc** **public** **protocol** DMenuViewDelegate: NSObjectProtocol {

  /// 点击回掉

  /// - **Parameters**:

  ///  - menu: 菜单

  ///  - column: 第几列

  ///  - leftRow: 左侧第多少行

  ///  - rightRow: 右侧第多少行

  **@objc** **optional** **func** didSelectRowAtIndexPath(menu:DropDownMenuView, column: Int, leftRow: Int, rightRow: Int);



  /// 标签选择显示状态

  /// - **Parameters**:

  ///  - menu: 菜单

  ///  - isShow: 是否显示

  **@objc** **optional** **func** menuIsShow(menu:DropDownMenuView, isShow: Bool)

}



