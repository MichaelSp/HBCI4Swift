//
//  HBCITanOrder.swift
//  HBCI4Swift
//
//  Created by Frank Emminghaus on 02.03.15.
//  Copyright (c) 2015 Frank Emminghaus. All rights reserved.
//

import Foundation

class HBCITanOrder : HBCIOrder {
    
    // we only support process variant 2 by now
    var process:String?
    var orderRef:String?
    var listIndex:String?
    var tanMediumName:String?
    
    // results
    var challenge:String?
    var challenge_hhd_uc:Data?
    
    // todo(?)
    
    
    init?(message:HBCICustomMessage) {
        super.init(name: "TAN", message: message);
        if self.segment == nil {
            return nil;
        }
    }
    
    func finalize(_ refOrder:HBCIOrder?) ->Bool {
        if let process = self.process {
            var values:Dictionary<String,Any> = ["process":process, "notlasttan":false];
            if tanMediumName != nil {
                values["tanmedia"] = tanMediumName!
            }
            /*
            if process == "1" || process == "2" {
                values["notlasttan"] = false;
            }
            */
            if orderRef != nil {
                values["orderref"] = orderRef;
            }
            
            if let refOrder = refOrder {
                values["ordersegcode"] = refOrder.segment.code;
            }
            
            if segment.setElementValues(values) {
                return true;
            } else {
                logInfo("Values could not be set for TAN order");
                return false;
            }
        } else {
            logInfo("Could not create TAN order - missing process info");
            return false;
        }
    }
    
    func enqueue() ->Bool {
        if finalize(nil) {
            return msg.addOrder(self);
        }
        return false;
    }
    
    override func updateResult(_ result:HBCIResultMessage) {
        super.updateResult(result);
        
        // get challenge information
        if let seg = resultSegments.first {
            self.challenge = seg.elementValueForPath("challenge") as? String;
            self.orderRef = seg.elementValueForPath("orderref") as? String;
            
            if seg.version > 3 {
                self.challenge_hhd_uc = seg.elementValueForPath("challenge_hhd_uc") as? Data;
            }
        }
    }

}
