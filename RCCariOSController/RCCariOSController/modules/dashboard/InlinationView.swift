//
//  InlinationView.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import UIKit

//class InclinationView: UIView {
//    var image: UIImage?
//    var imageScale: CGFloat = 0.5
//
//    var rotation: CGFloat = 0
//
//    override func draw(_ rect: CGRect) {
//        let context = UIGraphicsGetCurrentContext()
//
//        let scaledWidth = frame.size.width * imageScale
//        let scaleHeight = frame.size.height * imageScale
//
//        context?.translateBy(x: 0.5 * scaledWidth, y: 0.5 * scaleHeight)
//        context?.rotate(by: deg2rad(rotation))
////
////
////
////
////        CGContextTranslateCTM(context, 0.5f * size.width, 0.5f * size.height ) ;
////        CGContextRotateCTM( context, radians( 90 ) ) ;
////
////
////        CGSize size = image.size
////
////        UIGraphicsBeginImageContext(size);
////        CGContextRef context = UIGraphicsGetCurrentContext();
////
////        // If this is commented out, image is returned as it is.
////        CGContextRotateCTM (context, radians(90));
////
////        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
////        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
////        UIGraphicsEndImageContext();
////
////        return newImage;
//    }
//
//    func deg2rad(_ number: CGFloat) -> CGFloat {
//        return number * .pi / 180
//    }
//}
