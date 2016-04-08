//
//  SwipeBook.swift
//  Swipe
//
//  Created by satoshi on 6/2/15.
//  Copyright (c) 2015 Satoshi Nakajima. All rights reserved.
//

#if os(OSX)
import Cocoa
#else
import UIKit
#endif

import AVFoundation

private func MyLog(text:String, level:Int = 0) {
    let s_verbosLevel = 0
    if level <= s_verbosLevel {
        NSLog(text)
    }
}

public class SwipeBook: NSObject, SwipePageDelegate {
    // Public properties
    public var viewSize:CGSize?
    public var pageIndex = 0
    public var langId = "en"

    // Private properties
    private let bookInfo:[String:AnyObject]
    private let url:NSURL?
    private var sceneActive:SwipeScene?

    //
    // Calculated properties (Public)
    //
    public var currenPage:SwipePage {
        return self.pages[self.pageIndex]
    }
    //
    // Lazy properties (Public)
    //
    private lazy var langs:[[String:AnyObject]]? = {
        return self.bookInfo["languages"] as? [[String:AnyObject]]
    }()
    public func languages() -> [[String:AnyObject]]? {
        return self.langs
    }
    
    public lazy var title:String? = {
        if let title = self.bookInfo["title"] as? String {
            return title
        }
        return nil
    }()

    public lazy var horizontal:Bool = {
        return self.paging == "leftToRight"
    }()

    public lazy var orientation:String = {
        if let paging = self.bookInfo["orientation"] as? String {
            return paging
        }
        return "portrait"
    }()
    
    public lazy var landscape:Bool = {
        return self.orientation == "landscape"
    }()
    
    public lazy var viewstate:Bool = {
        if let state = self.bookInfo["viewstate"] as? Bool {
            return state
        }
        return true
    }()
    
    public lazy var pages:[SwipePage] = {
        var pages = [SwipePage]()
        if let pageInfos = self.bookInfo["pages"] as? [[String:AnyObject]] {
            for (index, pageInfo) in pageInfos.enumerate() {
                let page = SwipePage(index:index, pageInfo: pageInfo, delegate: self)
                pages.append(page)
            }
        }
        return pages
    }()
    
    //
    // Lazy properties (Private)
    //
    private lazy var namedElements:[NSObject:AnyObject] = {
        if let elements = self.bookInfo["elements"] as? [NSObject:AnyObject] {
            return elements
        }
        return [NSObject:AnyObject]()
    }()

    private lazy var scenes:[String:SwipeScene] = {
        var ret = [String:SwipeScene]()
        if let scenes = self.bookInfo["scenes"] as? [String:[String:AnyObject]] {
            for (key, info) in scenes {
                ret[key] = SwipeScene(name:key, info: info, baseURL:self.url)
            }
        }
        return ret
    }()

    private lazy var namedPaths:[NSObject:AnyObject] = {
        if let paths = self.bookInfo["paths"] as? [NSObject:AnyObject] {
            return paths
        }
        return [NSObject:AnyObject]()
    }()
    
    private lazy var paging:String = {
        if let paging = self.bookInfo["paging"] as? String {
            return paging
        }
        return "vertical"
    }()
    
    public lazy var backgroundColor:CGColor = {
        if let value = self.bookInfo["bc"] as? String {
            return SwipeParser.parseColor(value)
        }
        return UIColor.blackColor().CGColor
    }()
    
    public lazy var dimension:CGSize = {
        let size = UIScreen.mainScreen().bounds.size
        if let dimension = self.bookInfo["dimension"] as? [CGFloat] {
            if dimension.count == 2 {
                if dimension[0] == 0.0 {
                    return CGSizeMake(dimension[1] / size.height * size.width, dimension[1])
                } else if dimension[1] == 0.0 {
                    return CGSizeMake(dimension[0], dimension[0] / size.width * size.height)
                }
                return CGSizeMake(dimension[0], dimension[1])
            }
        }
        return size
    }()
    
    private lazy var scale:CGSize = {
        if let size = self.viewSize {
            let scale = size.width / self.dimension.width
            return CGSizeMake(scale, scale)
        }
        return CGSizeMake(1.0, 1.0)
    }()

    private lazy var markdown:SwipeMarkdown = {
        let info = self.bookInfo["markdown"] as? [String:AnyObject]
        let markdown = SwipeMarkdown(info:info, scale:self.scale, dimension:self.dimension)
        return markdown
    }()
    
    private lazy var voices:[String:[String:AnyObject]] = {
        if let info = self.bookInfo["voices"] as? [String:[String:AnyObject]] {
            return info
        }
        return [String:[String:AnyObject]]()
    }()
    
    // Initializer/Deinitializer
    /*
    init?(url:NSURL) {
        self.url = url
        if let data = NSData(contentsOfURL: url),
               script = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as? [String:AnyObject] {
            self.bookInfo = script
            super.init()
        } else {
            self.bookInfo = [String:AnyObject]()
            super.init()
            return nil
        }
    }
    */

    public init?(bookInfo:[String:AnyObject], url:NSURL?) {
        self.url = url
        self.bookInfo = bookInfo
    }
    
    deinit {
        MyLog("SwipeBook deinit", level:1)
    }
    
    // <SwipePageDelegate> method
    public func dimension(page:SwipePage) -> CGSize {
        return self.dimension
    }

    // <SwipePageDelegate> method
    public func scale(page:SwipePage) -> CGSize {
        return self.scale
    }
    
    // <SwipePageDelegate> method
    public func prototypeWith(name:String?) -> [String:AnyObject]? {
        if let key = name,
           let value = self.namedElements[key] as? [String:AnyObject] {
            return value
        }
        return nil
    }
    
    // <SwipePageDelegate> method
    public func sceneWith(name:String?) -> SwipeScene? {
        let key = (name == nil) ? "*" : name!
        if let value = self.scenes[key] {
            return value
        }
        return nil
    }

    // <SwipePageDelegate> method
    public func pathWith(name:String?) -> AnyObject? {
        if let key = name,
           let value:AnyObject = self.namedPaths[key] {
            return value
        }
        return nil
    }

#if !os(OSX) // REVIEW
    // <SwipePageDelegate> method
    public func speak(utterance:AVSpeechUtterance) {
        MyLog("SwipeBook speak", level:2)
        let synthesizer = SwipeSymthesizer.sharedInstance().synthesizer()
        synthesizer.speakUtterance(utterance)
    }

    // <SwipePageDelegate> method
    public func stopSpeaking() {
        MyLog("SwipeBook stop", level:2)
        let synthesizer = SwipeSymthesizer.sharedInstance().synthesizer()
        synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
    }
#endif

    // <SwipePageDelegate> method
    public func baseURL() -> NSURL? {
        return url
    }
    
    // <SwipePageDelegate> method
    public func voice(k:String?) -> [String:AnyObject] {
        let key = (k == nil) ? "*" : k!
        if let voice = voices[key] {
            return voice
        }
        return [String:AnyObject]()
    }

    // <SwipePageDelegate> method
    public func languageIdentifier() -> String? {
        return langId
    }

    public func sourceCode() -> String {
        if let url = self.url {
            let data = NSData(contentsOfURL: url)
            return NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
        }
        return "N/A"
    }
    
    public func setActivePage(page:SwipePage) {
        if self.sceneActive != page.scene {
            MyLog("SwipeBook setActive \(self.sceneActive), \(page.scene)", level:1)
            if let scene = self.sceneActive {
                scene.didLeave()
            }
            if let scene = page.scene {
                scene.didEnter(page.prefetcher)
            }
            self.sceneActive = page.scene
        }
    }

    public func currentPageIndex() -> Int {
        return self.pageIndex
    }

    public func parseMarkdown(markdowns:[String]) -> NSAttributedString {
        return self.markdown.parse(markdowns)
    }
}
