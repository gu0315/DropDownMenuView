Pod::Spec.new do |s|
    s.name         = "DropDownMenuDemo"
    s.version      = "1.0.0"
    s.ios.deployment_target = '10.0'
    s.summary      = "DropDownMenuDemo"
    s.homepage     = "https://github.com/gu0315/DropDownMenuView"
    s.license              = { :type => "MIT", :file => "LICENSE" }
    s.author             = { "顾钱想" => "228383741@qq.com" }
    s.social_media_url   = "https://camo.githubusercontent.com/4ea2e5b2c9aac727d6b34427136f88695db1ab8d8fdc9968d04726877feb0900/68747470733a2f2f73312e617831782e636f6d2f323032302f30382f31312f614f644467672e676966"
    s.source       = { :git => "https://github.com/gu0315/DropDownMenuView.git", :tag => s.version }
    s.source_files  = "DropDownMenu/*.{h,m}"
    s.resources          = "DropDownMenuDemo/DropDownMenuDemo.bundle"
    s.requires_arc = true
end
