//
//  ViewController.swift
//  Mangamiyo
//
//  Created by mba on 2021/01/06.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var dragDropView: ADragDropView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var imageViewSub1: NSImageView!
    @IBOutlet weak var imageViewSub2: NSImageView!
    @IBOutlet weak var pageSlider: NSSlider!
    @IBOutlet weak var buttonSlideshow: NSButton!
    @IBOutlet weak var textFileName: NSTextField!
    
    var timerSlide = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate:AppDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.viewController = self
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return event
        }
        //UserDefaultsを利用して初期化や解凍先の設定。
        let DocumentsPath = NSHomeDirectory() + "/tmp/Mangamiiyo/works/"
        pathDirUnarc = UserDefaults.standard.string(forKey: "unarchPath") ?? DocumentsPath
        Swift.print(DocumentsPath, pathDirUnarc)
        
        numShowTimer = UserDefaults.standard.double(forKey: "strShowTime")
        openRight = UserDefaults.standard.bool(forKey: "openRight")
        doublePageSpread = UserDefaults.standard.bool(forKey: "doublePageSpread")
        Swift.print(UserDefaults.standard.double(forKey: "strShowTime"), UserDefaults.standard.bool(forKey: "openRight"), UserDefaults.standard.bool(forKey: "doublePageSpread"))
        
        // Do any additional setup after loading the view.
        //ドラッグアンドドロップ可能な拡張子の設定。
        dragDropView.acceptedFileExtensions = ["zip", "rar", "pdf"]
        dragDropView.delegate = self
    }

    //キーボードのデリゲート処理
    //なぜかKeyDownだと二重カウントされるため、KeyUpで対処
    //beep音が出てしまったので別で対処。
    override func keyUp(with event: NSEvent) {
        if (openRight) {
            Swift.print(event.keyCode)
            switch event.keyCode{
                case 123:
                    self.fowardPage()
                    break
                case 124:
                    self.backPage()
                    break
                default:
                    Swift.print(event.keyCode)
            }
        }else{
            switch event.keyCode{
                case 124:
                    self.fowardPage()
                    break
                case 123:
                    self.backPage()
                    break
                default:
                    Swift.print(event.keyCode)
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func actionPageSlider(_ sender: NSSlider) {
        if(openRight) {
            mangaIndex = -pageSlider.integerValue
        }else{
            mangaIndex = pageSlider.integerValue
        }
        printManga()
    }
    @IBAction func actionSlideshow(_ sender: NSButton) {
        if (sender.state == NSControl.StateValue.on) {
            timerSlide = Timer.scheduledTimer(withTimeInterval: numShowTimer, repeats: true, block: { (timer) in
                self.fowardPage()
            })
            Swift.print("Start Slideshow.")
        }else{
            timerSlide.invalidate()
            Swift.print("End Slidshow.")
        }
    }
    @IBAction func strShowTimer(_ sender: NSTextField) {
        Swift.print(numShowTimer)
        numShowTimer = sender.doubleValue
    }
}

extension ViewController: ADragDropViewDelegate {
override var acceptsFirstResponder: Bool {
        return true
    }
    
    func delegateClickLeft(_ dragDropView: ADragDropView) {
        self.fowardPage()
    }
    
    func delegateClickRight(_ dragDropView: ADragDropView) {
        self.backPage()
    }
    
    //ドラッグアンドドロップされた際にデリゲート処理するメソッド。
    //実際の処理は中で呼びされるdragDropManga()で対応
    func dragDropView(_ dragDropView: ADragDropView, droppedFileWithURL URL: URL) {
        dragDropManga(pathFile: URL.path.removingPercentEncoding! as NSString)
    }
    
    func dragDropView(_ dragDropView: ADragDropView, droppedFilesWithURLs URLs: [URL]) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Please drop only one file"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    //ファイルの履歴管理のためUseDefaults(forKey: "history")にファイルPATHを追加する。
    //同じファイルPATHが格納されている場合は処理させずreturnで終了する。
    func manageUDHistory(pathFile:NSString) {
        let defaults = UserDefaults.standard
        var strArrHistory = defaults.array(forKey: "history")
        if (strArrHistory == nil) {
            strArrHistory = []
        }
        for strHistory in strArrHistory! {
            if((strHistory as! NSString).isEqual(to: pathFile)) {
                Swift.print("Exist path.")
                return
            }
        }
        strArrHistory?.append(pathFile)
        defaults.set(strArrHistory, forKey:"history")
        strArrHistory = defaults.array(forKey: "history")
        //Swift.print(strArrHistory)
        if let myDelegate = NSApplication.shared.delegate as? AppDelegate {
            myDelegate.createHistoryMenu()
        }
    }
    
    //ファイルをドラッグアンドドロップされた際に呼びされるメソッド
    //解凍処理のスレッド管理を行っている。
    //合わせて解凍中はファイルの列挙のためにTimer機能でファイル一覧のグローバル変数への格納を逐次実施する。
    //これがファイル一覧のメソッド→Unarchive().listedFiles()
    func dragDropManga(pathFile:NSString) {
        var timerList = Timer()
        manageUDHistory(pathFile: pathFile)
        if (doublePageSpread) {
            mangaIndex = 1
        }else{
            mangaIndex = 0
        }

        let groupUnarch = DispatchGroup()
        let queueUnarch = DispatchQueue(label: "unarchive")
        
        timerList = Timer.scheduledTimer(withTimeInterval: numDirMonitor, repeats: true, block: { (timer) in
            Swift.print("timer")
            Unarchive().listedFiles()
            self.initManga()
        })
        
        queueUnarch.async(group: groupUnarch) {
            Unarchive().selectUnrchive(pathFile: pathFile as String)
            DispatchQueue.main.async {
            }
        }
        groupUnarch.notify(queue: queueUnarch){
            Unarchive().listedFiles()
            Swift.print("unArhive done.")
            timerList.invalidate()
            DispatchQueue.main.async {
                self.initManga()
            }
        }
    }
    
    //ファイル一覧のグローバル変数（mangaFiles）から余計なファイルを取り除き、
    //最終的なファイル一覧のグローバル変数を生成する（pathManagaFiles）
    func initManga (){
        pathManagaFiles = mangaFiles.filter {($0.contains(".jpg") || $0.contains(".jpeg") || $0.contains(".gif") || $0.contains(".png") || $0.contains(".bmp")) && !$0.contains("__MACOSX/")}
        Swift.print("Befora sort: ", pathManagaFiles)
        pathManagaFiles = pathManagaFiles.sorted{$0.localizedStandardCompare($1) == ComparisonResult.orderedAscending
        }
        Swift.print("After sort: ", pathManagaFiles)
        var i = 0;
        for path in pathManagaFiles{
            pathManagaFiles[i] = Unarchive().tempUnarc.appending(path)
            i += 1
        }
        imageView.image = nil
        imageViewSub1.image = nil
        imageViewSub2.image = nil
        printManga()
    }
    
    //ファイル一覧のグローバル変数（pathManagaFiles）から実際にページを表示する。
    //オプション表示の処理も行う。
    //右開き処理の関して　例）1-5ページのファイルの場合
    //　　　右開き True：スライダーを-5から0とする
    //　　　右開き Fales：スライダーを0から5とする
    //見開き True：表示するViewを１ページ用のimageViewから、
    //　　　　　　　見開き用のView（imageViewSub1,imageViewSub2）に変更する。
    func printManga() {
        pageSlider.numberOfTickMarks=pathManagaFiles.count
        if(openRight) {
            pageSlider.intValue = -Int32(mangaIndex)
            pageSlider.maxValue = 0
            pageSlider.minValue = -Double(pathManagaFiles.count)
            Swift.print("Page Slider: ", pageSlider.maxValue, pageSlider.intValue)
        }else{
            pageSlider.intValue = Int32(mangaIndex)
            pageSlider.maxValue = Double(pathManagaFiles.count)
            pageSlider.minValue = 0
            Swift.print("Page Slider: ", pageSlider.maxValue, pageSlider.intValue)
        }
        Swift.print("count: " + String(pathManagaFiles.count))
        if(pathManagaFiles.count > 0 && mangaIndex < pathManagaFiles.count){
            if (doublePageSpread) {
                if (mangaIndex - 1 <= 0) {
                    mangaIndex = 1
                }
                if (mangaIndex >= pathManagaFiles.count) {
                    mangaIndex = pathManagaFiles.count - 1
                }
                imageViewSub1.image = NSImage(contentsOfFile: pathManagaFiles[mangaIndex-1])
                imageViewSub2.image = NSImage(contentsOfFile: pathManagaFiles[mangaIndex])
                imageView.image = nil
            } else {
                imageView.image = NSImage(contentsOfFile: pathManagaFiles[mangaIndex])
                imageViewSub1.image = nil
                imageViewSub2.image = nil
            }
        }
    }

    func fowardPage() {
        if(mangaIndex >= 0 && mangaIndex < pathManagaFiles.count-1){
            if (doublePageSpread) {
                mangaIndex += 2
            }else{
                mangaIndex += 1
            }
        }
        self.printManga()
    }
    
    func backPage() {
        if(mangaIndex > 0){
            if (doublePageSpread) {
                mangaIndex -= 2
            }else{
                mangaIndex -= 1
            }
        }
        self.printManga()
    }
    
}
