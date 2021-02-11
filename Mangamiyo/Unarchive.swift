//
//  Unarchive.swift
//  Mangamiiyo
//
//  Created by mba on 2021/01/04.
//

import Foundation

//ファイルの解凍、解凍先ファイルを管理するクラス
class Unarchive {
    init() {
        Swift.print("Unarchive init.")
    }
    
    deinit {
        Swift.print("Unarchive deinit.")
    }
    //解凍先のPATH。
    //ただし、メインメニューからの指定とドキュメントフォルダとして初期化される
    //var tempUnarc:String = "/Volumes/RAMDisk/dist/"
    //var tempUnarc:String = pathDirUnarc
    //ドラッグアンドドロップされた後に呼び出される
    func selectUnrchive(pathFile:String) {
        self.cleanFiles()
        //Swift.print("zip path :" + pathFile);
        let strExt = String(pathFile.suffix(3));
        switch strExt {
        case "pdf":
            self.unarchiveXDA(pathFile: pathFile)
            //
            //pdfからの画像化を自前で実装しようとした。
            //しかし動かないしXADMasterで対応できたのでコメントアウト
            //let sourceURL = URL(string: pathFile)!
            //let destinationURL = URL(fileURLWithPath: pathDirUnarchcurrent)
            //let _ = convertPDF(at: sourceURL, to: destinationURL, fileType: .jpg, dpi: 200)
        default:
            self.unarchiveXDA(pathFile: pathFile)
        }
    }

    //ファイルの実際の解凍を行う。
    //XADArchive.extractメソッドだけでも解凍は可能だがアーカイブ順で解凍される。
    //1ページ目から解凍されなければ最初に表示されるファイルが、解凍された中で先頭ファイルとなる。
    //そこで一旦はファイル一覧をXADArchive.nameで生成後にファイル名でゴリゴリとソートする。
    //（ファイル名から無理やり数字部分だけと取り出してソート）
    //加えてファイル名と対応するアーカイブファイルとしてのインデックスも並べ替える。
    //ファイル名として早い順からインデックス単位でアーカイブを解凍する。
    func unarchiveXDA(pathFile:String) {
        let charset = "cp932"
        let cfEncoding = CFStringConvertIANACharSetNameToEncoding(charset as CFString)
        let nsEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
        let xun = XADArchive.init(file: pathFile)
        if(xun == nil){
            return
        }
        
        xun?.setNameEncoding(nsEncoding)
        //xun?.extract(to: pathDirUnarcCurrent, subArchives: true)
        
        /*
        var arrName:[[Int]] = []
        //まずはアーカイブ内のファイル名とインデックスを取り出し配列化する。
        for i in 0 ..< xun!.numberOfEntries() {
            //Swift.print(xun!.size(ofEntry: i))
            //Swift.print(xun!.name(ofEntry: i) ?? "null")
            let strName = xun!.name(ofEntry: i)!.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined().suffix(4)
            if (strName.count != 0){
                let numName:Int = Int(strName)!
                arrName.append([Int(i), numName])
            }
        }
        */
        
        var arrName:[[String]] = []
        var arrNameIndex:[Int] = []
        xun?.setNameEncoding(nsEncoding)
        //まずはアーカイブ内のファイル名とインデックスを取り出し配列化する。
        for i in 0 ..< xun!.numberOfEntries() {
            let strName = xun!.name(ofEntry: i)
            if (strName?.count != 0){
                arrName.append([String(i), String(strName!)])
            }
        }

        //ファイル名をソート。合わせてそれに紐づくインデックスもソートされる。
        //ソート後、ファイル名順でアーカイブのインデックスを指定して解凍。
        arrName = arrName.sorted{$0[1].localizedStandardCompare($1[1]) == ComparisonResult.orderedAscending
        }
        //Swift.print(arrName)
        for i in 0 ..< xun!.numberOfEntries() {
            arrNameIndex.append(Int(arrName[Int(i)][0])!)
        }
        Swift.print("actually index :", arrNameIndex)
        /*
        if (arrName.count > 10) {
            for i in 0 ..< 9 {
                xun!.extractEntry(Int32(arrName[i][0])!, to: pathDirUnarch)
                //Swift.print(xun!.name(ofEntry: Int32(arrName[i][0])) ?? "null")
            }
        }
 */
        
        //xun?.extract(to: pathDirUnarch, subArchives: true)
        xun?.extractEntriesActually(arrNameIndex, to: pathDirUnarch, subArchives: true)
    }
    
    //解凍先のディレクトリ内のファイルを列挙する。
    //このメソッドは解凍中に何度か呼び出され、解凍中のファイル閲覧に利用される。
    func listedFiles(){
        let fileManager = FileManager.default
        do {
            Swift.print("pathDirUnarchCurrent Path: ", pathDirUnarch)
            mangaFiles = try fileManager.subpathsOfDirectory(atPath: pathDirUnarch)
        } catch {
        }
    }
    
    //解凍先のディレクトリの削除。
    //アプリ起動時、終了時、新しいファイル読み込み時に実行される。
    func cleanFiles(){
        do {
            try FileManager.default.removeItem(atPath: pathDirUnarch)
        } catch {
        }
    }
}

