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
    
    
    var timerSlide = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return event
        }
        let DocumentsPath = NSHomeDirectory() + "/tmp/Mangamiiyo/works/"
        pathDirUnarc = UserDefaults.standard.string(forKey: "unarchPath") ?? DocumentsPath
        Swift.print(DocumentsPath, pathDirUnarc)
        
        numShowTimer = UserDefaults.standard.double(forKey: "strShowTime")
        openRight = UserDefaults.standard.bool(forKey: "openRight")
        doublePageSpread = UserDefaults.standard.bool(forKey: "doublePageSpread")
        Swift.print(UserDefaults.standard.double(forKey: "strShowTime"), UserDefaults.standard.bool(forKey: "openRight"), UserDefaults.standard.bool(forKey: "doublePageSpread"))
        
        // Do any additional setup after loading the view.
        dragDropView.acceptedFileExtensions = ["zip", "rar", "pdf"]
        dragDropView.delegate = self
    }

    override func keyDown(with event: NSEvent) {
        Swift.print(event.keyCode)
        if (openRight) {
            switch event.keyCode{
                case 123:
                    self.fowardPage()
                case 124:
                    self.backPage()
                default:
                    Swift.print(event.keyCode)
            }
        }else{
            switch event.keyCode{
                case 124:
                    self.fowardPage()
                case 123:
                    self.backPage()
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
    func delegateClickLeft(_ dragDropView: ADragDropView) {
        self.fowardPage()
    }
    
    func delegateClickRight(_ dragDropView: ADragDropView) {
        self.backPage()
    }
    
    func dragDropView(_ dragDropView: ADragDropView, droppedFileWithURL URL: URL) {
        var timerList = Timer()

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
            Unarchive().selectUnrchive(pathFile: URL.path.removingPercentEncoding!)
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
    
    func dragDropView(_ dragDropView: ADragDropView, droppedFilesWithURLs URLs: [URL]) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Please drop only one file"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func initManga (){
        pathManagaFiles = mangaFiles.filter {($0.contains(".jpg") || $0.contains(".jpeg") || $0.contains(".gif") || $0.contains(".png") || $0.contains(".bmp")) && !$0.contains("__MACOSX/")}
        var i = 0;
        for path in pathManagaFiles{
            pathManagaFiles[i] = Unarchive().tempUnarc.appending(path)
            i += 1
        }
        printManga()
    }
    
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
