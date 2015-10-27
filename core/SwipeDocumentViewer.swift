//
//  SwipeDocumentViewer.swift
//  sample
//
//  Created by satoshi on 10/13/15.
//  Copyright © 2015 Satoshi Nakajima. All rights reserved.
//

#if os(OSX)
import Cocoa
#else
import UIKit
#endif

protocol SwipeDocumentViewerDelegate: NSObjectProtocol {
    func browseTo(url:NSURL)
}

protocol SwipeDocumentViewer {
    func documentTitle() -> String?
    func loadDocument(document:[String:AnyObject], size:CGSize, url:NSURL?, state:[String:AnyObject]?) throws
    func hideUI() -> Bool
    func landscape() -> Bool
    func setDelegate(delegate:SwipeDocumentViewerDelegate)
    func becomeZombie()
    func saveState() -> [String:AnyObject]?
}

enum SwipeError: ErrorType {
    case InvalidDocument
}