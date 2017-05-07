Pod::Spec.new do |s|
  s.name         = "DatabaseManager"
  s.version      = "0.0.1"
  s.license      = "MIT"
  s.summary      = "upgrate database table cloumn"
  s.description  = <<-DESC
    upgrate database table cloumn with FMDB
                   DESC
  s.homepage     = "https://github.com/yangyongzheng/DatabaseManager"
  s.author             = { "yangyongzheng" => "youngyongzheng@qq.com" }
  s.social_media_url   = "http://twitter.com/yangyongzheng"
  s.source       = { :git => "https://github.com/yangyongzheng/DatabaseManager.git", :tag => s.version", :submodules => true }
  s.platform     = :ios, "7.0"
  s.requires_arc = true

  s.public_header_files = "DatabaseManager/**/DatabaseHeader.h"
  s.source_files  = "DatabaseManager/**/DatabaseHeader.h"

  s.dependency "FMDB", "~> 2.6.2"

end
