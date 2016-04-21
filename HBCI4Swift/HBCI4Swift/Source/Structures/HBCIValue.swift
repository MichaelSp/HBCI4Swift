//
//  HBCIValue.swift
//  HBCI4Swift
//
//  Created by Frank Emminghaus on 21.04.16.
//  Copyright © 2016 Frank Emminghaus. All rights reserved.
//

import Foundation

public struct HBCIValue {
    public let value:NSDecimalNumber;
    public let currency:String;
    
    public init(value:NSDecimalNumber, date:NSDate, currency:String) {
        self.value = value;
        self.currency = currency;
    }
    
    public init?(element: HBCISyntaxElement) {
        if let cd = element.elementValueForPath("debitcredit") as? String,
            value = element.elementValueForPath("value") as? NSDecimalNumber,
            curr = element.elementValueForPath("curr") as? String {
                self.value = cd == "C" ? value:NSDecimalNumber.zero().decimalNumberBySubtracting(value);
                self.currency = curr;
        } else {
            logError("Value could not be extracted");
            logError(element.description);
            return nil;
        }
    }
}
