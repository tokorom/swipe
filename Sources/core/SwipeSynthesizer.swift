//
//  SwipeSynthesizer.swift
//  sample
//
//  Created by satoshi on 9/21/15.
//  Copyright © 2015 Satoshi Nakajima. All rights reserved.
//

#if os(OSX)
import Cocoa
public typealias AVSpeechSynthesizer = NSSpeechSynthesizer
#else
import UIKit
#endif

import AVFoundation

public class SwipeSymthesizer: NSObject {
    private static let singleton = SwipeSymthesizer()
    let synth = AVSpeechSynthesizer()
    
    public static func sharedInstance() -> SwipeSymthesizer {
        return SwipeSymthesizer.singleton
    }

    // <BookObjectDelegate> method
    public func synthesizer() -> AVSpeechSynthesizer {
        return self.synth
    }
}
