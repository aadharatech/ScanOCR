Pod::Spec.new do |spec|
  spec.name         = "ScanOCR"
  spec.version      = "1.0.0"
  spec.summary      = "ScanOCR framework to scan ocr"
  spec.description  = "ScanOcr framework to scan ocr and give output as string"
  spec.homepage     = "https://github.com/aadharatech/ScanOCR"
  spec.license      = "MIT"
  spec.author       = { "Aadhar Mathur" => "aadhar.m@atechnos.com" }
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/aadharatech/ScanOCR.git", :tag => "1.0.0" }
  spec.source_files = "ScanOCR/**/*.{h,m,swift}"
  spec.xcconfig = { "OTHER_LDFLAGS" => "-lz" }
  spec.dependency "TesseractOCRiOS", "~> 4.0.0"

end
