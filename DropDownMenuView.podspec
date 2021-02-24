Pod::Spec.new do |s|
    s.name         = "DropDownMenuView"
    s.version      = "0.0.1"
    s.ios.deployment_target = '10.0'
    s.summary      = "DropDownMenuView"
    s.homepage     = "https://github.com/gu0315/DropDownMenuView"
    s.license  = 'MIT'
    s.author             = { "顾钱想" => "228383741@qq.com" }
    s.social_media_url   = "https://www.jianshu.com/p/0ea1a4c49fba"
    s.source       = { :git => "https://github.com/gu0315/DropDownMenuView.git", :tag => s.version }
    s.source_files  = "DropDownMenuDemo/DropDownMenu"
    s.swift_version = "4.2"
  s.swift_versions = ['4.2', '5.0', '5.1']
end
