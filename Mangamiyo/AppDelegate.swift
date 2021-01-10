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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Unarchive().cleanFiles()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        Unarchive().cleanFiles()
    }


    @IBAction func menuOpenRight(_ sender: NSMenuItem) {
        if (sender.state == .on) {
            //sender.state = .off
            openRight = false
        }else{
            //sender.state = .on
            openRight = true
        }
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
        Swift.print(doublePageSpread)
    }

}
