//
//  ColorUtils.swift
//  RadioFmApp
//
//  Created by Alvaro on 12/11/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit

class ColorUtils: NSObject {

    // MARK: - Singleton

    static let shared = ColorUtils()
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }

    // MARK: - Functions

    /**
     Function that creates a image with color as parameter
     - parameter color: The color variable for the image
     - returns: The image created with the color
     */
    func getImageFor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /**
     Function that render a button
     - parameter originalView: The original button to render
     - parameter color: The color that needs to render the button
     - parameter transparent: Wheter the button has transparent background or white
     - returns: The rendered button
     */
    func renderButton(_ originalView: UIButton, color: UIColor, transparent: Bool) -> UIButton {
        let button = originalView
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = transparent ? .clear : .white
        button.setTitleColor(color, for: .normal)
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 1.0
        return button
    }

    /**
     Function that render a image view with a color
     - parameter originalView: The original image view to render
     - parameter color: The color that needs to render the image
     - parameter userInteraction: Wheter the user interaction in the image is on or not
     - returns: The image view rendered with the color
     */
    func renderImage(_ originalView: UIImageView, color: UIColor, userInteraction: Bool) -> UIImageView {
        let imageView = originalView
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.isUserInteractionEnabled = userInteraction
        imageView.tintColor = color
        return imageView
    }

    /**
     Function that rotates the view
     - parameter view: The view to rotate
     */
    func rotate(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = (Float) (2 * Double.pi)
        animation.repeatCount = Float.infinity
        animation.fromValue = 0.0
        animation.duration = 1.0
        view.layer.add(animation, forKey: "rotation")
    }

    /**
     Function that scales an image in a frame
     - parameter sourceImage: The original image to scale
     - parameter size: The frame size to scale the image
     - returns: The image scaled
     */
    func scale(_ sourceImage: UIImage?, size: CGSize) -> UIImage {
        if let sourceImage = sourceImage {
            let oldWidth = sourceImage.size.width
            let oldHeight = sourceImage.size.height
            let scaleFactor = oldWidth > oldHeight ? size.width / oldWidth : size.height / oldHeight
            let scaledSize = CGSize(width: oldWidth * scaleFactor, height: oldHeight * scaleFactor)
            UIGraphicsBeginImageContext(scaledSize)
            sourceImage.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resultImage ?? UIImage()
        } else { return UIImage() }
    }

    /**
     Function that signs with a black stroke over a view
     - parameter view: The UIImage view to uncover
     - parameter frameSize: The screen frame size to deal with
     - parameter points: The list of points of the stroke
     - parameter moved: Whether the stroke moved or not
     - returns: The UIImage created with the stroke on it
     */
    func sign(_ view: UIImageView, frameSize: CGSize, points: [CGPoint], moved: Bool) -> UIImage? {
        UIGraphicsBeginImageContext(view.frame.size)
        view.draw(CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height))
        if let context = UIGraphicsGetCurrentContext() {
            if moved { // moved
                context.move(to: points[0])
                context.addLine(to: points[1])
                context.setLineCap(.round)
                context.setLineWidth(150.0)
                context.setStrokeColor(UIColor.black.cgColor)
            } else { // not moved
                context.setLineCap(.round)
                context.setLineWidth(150.0)
                context.setStrokeColor(UIColor.black.cgColor)
                context.move(to: points[0])
                context.addLine(to: points[0])
            }
            context.strokePath()
            let graphicImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return graphicImage
        } else { return nil }
    }
}
