//
//  Unarchive.swift
//  Mangamiiyo
//
//  Created by mba on 2021/01/04.
//

import Foundation

class Unarchive {
    //var tempUnarc:String = "/Volumes/RAMDisk/dist/"
    var tempUnarc:String = pathDirUnarc
    func selectUnrchive(pathFile:String) {
        self.cleanFiles()

        Swift.print("zip path :" + pathFile);
        let strExt = String(pathFile.suffix(3));
        switch strExt {
        case "pdf":
            self.unarchiveXDA(pathFile: pathFile)
            //
            //nazeka ugokanai? string to url no sei?
            //let sourceURL = URL(string: pathFile)!
            //let destinationURL = URL(fileURLWithPath: tempUnarc)
            //let _ = convertPDF(at: sourceURL, to: destinationURL, fileType: .jpg, dpi: 200)
        default:
            self.unarchiveXDA(pathFile: pathFile)
        }
    }

    func unarchiveXDA(pathFile:String) {
        let xun = XADArchive.init(file: pathFile)
        xun?.extract(to: tempUnarc)
        Swift.print(xun!.numberOfEntries())
        for i in 0 ..< xun!.numberOfEntries() {
            Swift.print(xun!.size(ofEntry: i))
        }
    }
        
    func listedFiles(){
        let fileManager = FileManager.default
        do {
            mangaFiles = try fileManager.subpathsOfDirectory(atPath: self.tempUnarc)
        } catch {
        }
    }
    
    func cleanFiles(){
        do {
            try FileManager.default.removeItem(atPath: Unarchive().tempUnarc)
        } catch {
        }
    }
}

