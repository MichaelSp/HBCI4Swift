//
//  HBCISepaCollectiveTransferOrder.swift
//  HBCI4Swift
//
//  Created by Frank Emminghaus on 24.05.15.
//  Copyright (c) 2015 Frank Emminghaus. All rights reserved.
//

import Foundation

public struct HBCISepaCollectiveTransferPar {
    public var maxNum:Int;
    public var needsTotal:Bool;
    public var singleTransferAllowed:Bool;
}


public class HBCISepaCollectiveTransferOrder : HBCIAbstractSepaTransferOrder {
    
    public init?(message: HBCICustomMessage, transfer:HBCISepaTransfer) {
        super.init(name: "SepaCollectiveTransfer", message: message, transfer: transfer);
        if self.segment == nil {
            return nil;
        }
    }
    
    public override func enqueue() ->Bool {
        
        if transfer.date != nil {
            logError("SEPA Transfer: date is not allowed");
            return false;
        }
        return super.enqueue();
    }

    public class func getParameters(user:HBCIUser) ->HBCISepaCollectiveTransferPar? {
        if let seg = user.parameters.parametersForJob("SepaCollectiveTransfer") {
            if let elem = seg.elementForPath("ParSepaCollectiveTransfer") {
                let maxNum = elem.elementValueForPath("maxnum") as! Int;
                let needsTotal = elem.elementValueForPath("maxnum") as! Bool;
                let sta = elem.elementValueForPath("cansingletransfer") as! Bool;
                return HBCISepaCollectiveTransferPar(maxNum: maxNum, needsTotal: needsTotal, singleTransferAllowed: sta);
            }
        }
        return nil;
    }


}