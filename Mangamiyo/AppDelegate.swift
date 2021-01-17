//
//  AppDelegate.swift
//  Mangamiyo
//
//  Created by mba on 2021/01/06.
//

import Cocoa

var mangaFiles: [String] = []
var mangaIndex:Int = 0
var pathManagaFiles: [String] = []
var numShowTimer:Double = 5.0
var openRight:Bool = false
var doublePageSpread:Bool = false
let numDirMonitor:Double = 0.5
var pathDirUnarc:String = ""

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var menuHistory: NSMenuItem!
    var viewController: ViewController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Unarchive().cleanFiles()
        createHistoryMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        Unarchive().cleanFiles()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed (_ theApplication: NSApplication) -> Bool {
            Swift.print("App close.")
            return true
        }
    
    func windowShouldClose(_ sender: Any) {
        NSApplication.shared.terminate(self)
        }

    func createHistoryMenu() {
        let menuForParent = NSMenu()
        let strArryHistory = UserDefaults.standard.array(forKey: "history")
        //ここでnilを弾かないと初期値が履歴が無い場合にエラーが出るので対処。
        if(strArryHistory == nil){
            menuHistory.submenu = menuForParent
            return
        }
        for strHistory in strArryHistory! {
            let tempStrHitory:NSString = (strHistory as? NSString)!
            let strHistoryFilename:NSString = tempStrHitory.components(separatedBy: "/")[tempStrHitory.components(separatedBy: "/").count-1] as NSString
            Swift.print(strHistoryFilename)
            let menuItem = NSMenuItem(title: strHistory as! String, action: #selector(callInitManga(sender:)), keyEquivalent: "")
            menuForParent.addItem(menuItem)
        }
        menuHistory.submenu = menuForParent
    }
    
    @objc func callInitManga(sender: NSMenuItem) {
        let pathFile = sender.title
        Swift.print(pathFile)
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.viewController.dragDropManga(pathFile: pathFile as NSString)
      }
    
    @IBAction func menuOpenRight(_ sender: NSMenuItem) {
        if (sender.state == .on) {
            //sender.state = .off
            openRight = false
        }else{
            //sender.state = .on
            openRight = true
        }
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.viewController.printManga()
        Swift.print(openRight)
    }
    
    @IBAction func menuUnarchPath(_ sender: NSMenuItem) {
        let alert = NSAlert()
        alert.messageText = "Unarchive Path"
        alert.informativeText = "Please, input unarshive path. e.g) /Users/User Name/tmp/Mangamiyo/works/"
        let DocumentsPath = NSHomeDirectory() + "/tmp/Mangamiyo/works/"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancle")
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.stringValue = UserDefaults.standard.string(forKey: "unarchPath") ?? DocumentsPath
        alert.accessoryView = input
        
        let ret = alert.runModal()

        switch ret {
        case .alertFirstButtonReturn:
            UserDefaults.standard.set(input.stringValue, forKey: "unarchPath")
            pathDirUnarc = input.stringValue
            print(input.stringValue)
        case .alertSecondButtonReturn:
            UserDefaults.standard.removeObject(forKey: "unarchPath")
            print("Reset")
        case .alertThirdButtonReturn:
            print("cancle")
        default: break
        }
    }

    @IBAction func menuDoublePageSpread(_ sender: NSMenuItem) {
        if (sender.state == .on) {
            //sender.state = .off
            doublePageSpread = false
        }else{
            //sender.state = .on
            doublePageSpread = true
        }
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.viewController.printManga()
        Swift.print(doublePageSpread)
    }

    @IBAction func actionMenuFile(_ sender: NSMenuItem) {
        Swift.print("file file file")
    }
    
    @IBAction func removeRecent(_ sender: NSMenuItem) {
        let alert = NSAlert()
        alert.messageText = "Remove Recent All History"
        alert.addButton(withTitle: "Remove")
        alert.addButton(withTitle: "Cancle")
        let ret = alert.runModal()
        switch ret {
            case .alertFirstButtonReturn:
                UserDefaults.standard.removeObject(forKey: "history")
                let menuForParent = NSMenu()
                menuHistory.submenu = menuForParent
                print("Reset")
            case .alertSecondButtonReturn:
                print("cancle")
            default: break
        }
    }
}
