//
//  PDFtoImage.swift
//  Mangamiyo
//
//  Created by mba on 2021/01/09.
//
//Reference: https://stackoverflow.com/questions/45775394/how-to-convert-pdf-to-png-efficiently
//
import Foundation
import Quartz

//How to use
//let sourceURL = URL(string: "http://files.shareholder.com/downloads/AAPL/4907179320x0x952191/4B5199AE-34E7-47D7-8502-CF30488B3B05/10-Q_Q3_2017_As-Filed_.pdf")!
//let destinationURL = URL(fileURLWithPath: "/Users/mike/PDF")
//let urls = try convertPDF(at: sourceURL, to: destinationURL, fileType: .png, dpi: 200)
//
//

struct ImageFileType {
    var uti: CFString
    var fileExtention: String

    // This list can include anything returned by CGImageDestinationCopyTypeIdentifiers()
    // I'm including only the popular formats here
    static let bmp = ImageFileType(uti: kUTTypeBMP, fileExtention: "bmp")
    static let gif = ImageFileType(uti: kUTTypeGIF, fileExtention: "gif")
    static let jpg = ImageFileType(uti: kUTTypeJPEG, fileExtention: "jpg")
    static let png = ImageFileType(uti: kUTTypePNG, fileExtention: "png")
    static let tiff = ImageFileType(uti: kUTTypeTIFF, fileExtention: "tiff")
}

func convertPDF(at sourceURL: URL, to destinationURL: URL, fileType: ImageFileType, dpi: CGFloat = 200) -> Bool {
    let pdfDocument = CGPDFDocument(sourceURL as CFURL)!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue

    var urls = [URL](repeating: URL(fileURLWithPath : "/"), count: pdfDocument.numberOfPages)
    DispatchQueue.concurrentPerform(iterations: pdfDocument.numberOfPages) { i in
        // Page number starts at 1, not 0
        let pdfPage = pdfDocument.page(at: i + 1)!

        let mediaBoxRect = pdfPage.getBoxRect(.mediaBox)
        let scale = dpi / 72.0
        let width = Int(mediaBoxRect.width * scale)
        let height = Int(mediaBoxRect.height * scale)

        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)!
        context.interpolationQuality = .high
        context.setFillColor(.white)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.scaleBy(x: scale, y: scale)
        context.drawPDFPage(pdfPage)

        let image = context.makeImage()!
        let imageName = sourceURL.deletingPathExtension().lastPathComponent
        let imageURL = destinationURL.appendingPathComponent("\(imageName)-Page\(i+1).\(fileType.fileExtention)")

        let imageDestination = CGImageDestinationCreateWithURL(imageURL as CFURL, fileType.uti, 1, nil)!
        CGImageDestinationAddImage(imageDestination, image, nil)
        CGImageDestinationFinalize(imageDestination)

        urls[i] = imageURL
    }
    return true
}
