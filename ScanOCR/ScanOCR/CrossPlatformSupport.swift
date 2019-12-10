//
//  CrossPlatformSupport.swift
//  ScanneriOS
//
//  Created by Aadhar Mathur on 08/12/19.
//  Copyright © 2019 Aadhar Mathur. All rights reserved.
//

#if os(iOS)
    import UIKit
    public typealias OCRColor   = UIColor
    public typealias OCRFont    = UIFont
    public typealias OCRImage   = UIImage
#else
    import Cocoa
    public typealias OCRColor   = NSColor
    public typealias OCRFont    = NSFont
    public typealias OCRImage   = NSImage
#endif
