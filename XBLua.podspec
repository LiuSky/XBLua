Pod::Spec.new do |s|
  s.name             = 'XBLua'
  s.version          = '5.4.6'
  s.summary          = 'A short description of XBLua.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/327847390@q.com/XBLua'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '327847390@q.com' => '327847390@qq.com' }
  s.source           = { :git => 'https://github.com/327847390@q.com/XBLua.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.static_framework = true
  s.ios.deployment_target = '11.0'
  
  s.subspec "Lua" do |ss|
    ss.source_files = "XBLua/Classes/Lua/**.{h,m,c}"
  end

  s.subspec "Debug" do |ss|
    ss.source_files = "XBLua/Classes/Debug/**.{h,m,c}"
  end

  s.subspec "XBSDK" do |ss|
    ss.source_files = "XBLua/Classes/XBSDK/**.{h,m,c}"
  end

end
