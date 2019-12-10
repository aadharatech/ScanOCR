//
//  OCRScan.swift
//  ScanneriOS
//
//  Created by Aadhar Mathur on 08/12/19.
//  Copyright © 2019 Aadhar Mathur. All rights reserved.
//

import AVFoundation
import TesseractOCR

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

public var recognizableCharacters = "[A-Z0-9]{4}(-[A-Z0-9]{4}){3}"

open class ScannerObject: NSObject,G8TesseractDelegate {
    fileprivate        var characters = recognizableCharacters
        
        private  var strValue : String = ""
        private var strArr : [String] = []
        private var strValue1 : String = ""
     private var count : Int = 0
     private var counter : Int = 0
      private var defaults = UserDefaults.standard
      //  fileprivate     var network = globalNetwork
        
        //MARK: Setup
        
        ///SwiftOCR's delegate
        open weak var delegate: OCRScanDelegate?
        
        ///Radius in x axis for merging blobs
        open      var xMergeRadius:CGFloat = 1
        ///Radius in y axis for merging blobs
        open      var yMergeRadius:CGFloat = 3
        
        ///Only recognize characters on White List
        open      var characterWhiteList: String? = nil
        ///Don't recognize characters on Black List
        open      var characterBlackList: String? = nil
        
        ///Confidence must be bigger than the threshold
        open      var confidenceThreshold:Float = 0.1
        
        //MARK: Recognition data
        
        ///All SwiftOCRRecognizedBlob from the last recognition
        open      var currentOCRRecognizedBlobs = [OCRScanRecognizedBlob]()
        
        
        //MARK: Init
    public   override init(){}
        
        public   init(recognizableCharacters: String) {
            self.characters = recognizableCharacters
            //self.network = network
        }
        
//        public   init(image: OCRImage, delegate: OCRScanDelegate?, _ completionHandler: @escaping (String) -> Void){
//            self.delegate = delegate
//           recognize(image, completionHandler)
//        }
//        
//        public   init(recognizableCharacters: String, image: OCRImage, delegate: OCRScanDelegate?, _ completionHandler: @escaping (String) -> Void) {
//            self.characters = recognizableCharacters
//         //   self.network = network
//            self.delegate = delegate
//            recognize(image, completionHandler)
//        }
        
        /**
         
         Performs ocr on the image.
         
         - Parameter image:             The image used for OCR
         - Parameter completionHandler: The completion handler that gets invoked after the ocr is finished.
         
         */
    
    
    open   func recognize(_ image: UIImage, _ completionHandler: @escaping (String) -> Void){
                    guard let tesseract  = G8Tesseract(language: "eng") else { return }
                   // tesseract.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890()-+*!/?.,@#$%&"
                    tesseract.charWhitelist = "[A-Z0-9]{4}(-[A-Z0-9]{4}){3}"
                    tesseract.charBlacklist = "\n"
                    
                    tesseract.engineMode = .lstmOnly
                    tesseract.pageSegmentationMode = .sparseText
                    //tesseract.pageSegmentationMode = .sparseText
                    
            //        tesseract.engineMode = .lstmOnly
            //        tesseract.pageSegmentationMode = .sparseText
                    tesseract.image = image
                    tesseract.recognize()
                    print(tesseract.recognizedText!)
                    let recognizeVar = tesseract.recognizedText!
                    if let match = recognizeVar.range(of: "[A-Z0-9]{4}(-[A-Z0-9]{4}){3}", options: .regularExpression) {
                        print(recognizeVar.substring(with: match))
                        completionHandler(recognizeVar.substring(with: match))
                       // label.text = recognizeVar.substring(with: match)
                    /* if let match = test.range(of: "(?<=')[^']+", options: .regularExpression) {
                        print(test.substring(with: match))
                    } */
                    }
    }
    
    fileprivate func successfull() {
        print("Scan Successfull")
    }
      
      open   func recognizeInRect(_ image: OCRImage, rect: CGRect, completionHandler: @escaping (String) -> Void){
          DispatchQueue.global(qos: .userInitiated).async {
              #if os(iOS)
                  let cgImage        = image.cgImage
                  let croppedCGImage = cgImage?.cropping(to: rect)!
                  let croppedImage   = OCRImage(cgImage: croppedCGImage!)
              #else
                  let cgImage        = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
                  let croppedCGImage = cgImage.cropping(to: rect)!
                  let croppedImage   = OCRImage(cgImage: croppedCGImage, size: rect.size)
              #endif
              
              self.recognize(croppedImage, completionHandler)
              
          }
      }
}

// MARK: OCRScanDelegate

public protocol OCRScanDelegate: class {
    
    /**
     
     Implement this method for a custom image preprocessing algorithm. Only return a binary image.
     
     - Parameter inputImage: The image to preprocess.
     - Returns:              The preprocessed, binarized image that SwiftOCR should use for OCR. If you return nil SwiftOCR will use its default preprocessing algorithm.
     
     */
    
    func preprocessImageForOCR(_ inputImage: OCRImage) -> OCRImage?
    
}

extension OCRScanDelegate {
    func preprocessImageForOCR(_ inputImage: OCRImage) -> OCRImage? {
        return nil
    }
}

// MARK: SwiftOCRRecognizedBlob

public struct OCRScanRecognizedBlob {
    
    public let charactersWithConfidence: [(character: Character, confidence: Float)]!
    public let boundingBox:              CGRect!
    
    init(charactersWithConfidence: [(character: Character, confidence: Float)]!, boundingBox: CGRect) {
        self.charactersWithConfidence = charactersWithConfidence.sorted(by: { $0.confidence > $1.confidence })
        self.boundingBox = boundingBox
    }
    
}

extension String {
    
    //[A-Z0-9]{4}(-[A-Z0-9]{4}){3}
    
    var containsSpecialCharacter: Bool {
       let regex = "[A-Z0-9]{4}(-[A-Z0-9]{4}){3}"
       let testString = NSPredicate(format:"SELF MATCHES %@", regex)
       return testString.evaluate(with: self)
    }
    
    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }

    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }
}
