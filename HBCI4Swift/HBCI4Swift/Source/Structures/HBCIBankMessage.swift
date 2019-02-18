//
//  HBCIBankMessage.swift
//  HBCI4Swift
//
//  Created by Frank Emminghaus on 10.02.19.
//  Copyright © 2019 Frank Emminghaus. All rights reserved.
//

import Foundation

public struct HBCIBankMessage {
    public let header:String;
    public let message:String;
    
    public init?(element: HBCISyntaxElement) {
        if let hd = element.elementValueForPath("betreff") as? String, let text = element.elementValueForPath("text") as? String {
            self.header = hd;
            self.message = text;
        } else {
            logDebug("BankMessage could not be extracted");
            logDebug(element.description);
            return nil;
        }
    }
}
