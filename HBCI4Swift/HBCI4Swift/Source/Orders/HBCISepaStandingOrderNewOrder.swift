//
//  HBCISepaStandingOrderNewOrder.swift
//  HBCI4Swift
//
//  Created by Frank Emminghaus on 16.05.15.
//  Copyright (c) 2015 Frank Emminghaus. All rights reserved.
//

import Foundation

public struct HBCISepaStandingOrderNewPar {
    var maxUsage:Int;
    var minPreDays:Int;
    var maxPreDays:Int;
    var cycleMonths:String;
    var daysPerMonth:String;
    var cycleWeeks:String?
    var daysPerWeek:String?
}

public class HBCISepaStandingOrderNewOrder : HBCIOrder {
    var standingOrder:HBCIStandingOrder;
    
    public init?(message: HBCICustomMessage, order:HBCIStandingOrder) {
        self.standingOrder = order;
        super.init(name: "SepaStandingOrderNew", message: message);
        if self.segment == nil {
            return nil;
        }
    }
    
    public func enqueue() ->Bool {
        if !standingOrder.validate() {
            return false;
        }
        
        // check if order is supported
        if !user.parameters.isOrderSupportedForAccount(self, number: standingOrder.account.number, subNumber: standingOrder.account.subNumber) {
            logError(self.name + " is not supported for account " + standingOrder.account.number);
            return false;
        }
        
        // create SEPA data
        if let gen = HBCISepaGeneratorFactory.creditGenerator(self.user) {
            if let data = gen.documentForTransfer(standingOrder) {
                if let iban = standingOrder.account.iban, bic = standingOrder.account.bic {
                    var values:Dictionary<String,AnyObject> = ["My.iban":iban, "My.bic":bic, "sepapain":data, "sepadescr":gen.sepaFormat.urn, "details.firstdate":standingOrder.startDate,
                        "details.timeunit":standingOrder.cycleUnit == HBCIStandingOrderCycleUnit.monthly ? "M":"W", "details.turnus":standingOrder.cyle,
                        "details.execday":standingOrder.executionDay];
                    if let lastDate = standingOrder.lastDate {
                        values["details.lastdate"] = lastDate;
                    }
                    if self.segment.setElementValues(values) {
                        // add to dialog
                        msg.addOrder(self);
                        return true;
                    } else {
                        logError("Could not set values for SepaTransfer");
                    }
                } else {
                    if standingOrder.account.iban == nil {
                        logError("IBAN is missing for SEPA transfer");
                    }
                    if standingOrder.account.bic == nil {
                        logError("BIC is missing for SEPA transfer");
                    }
                }
            }
        }
        return false;
    }
    
    override func updateResult(result:HBCIResultMessage) {
        super.updateResult(result);
        
        for segment in resultSegments {
            standingOrder.orderId = segment.elementValueForPath("orderId") as? String;
        }
    }

    public class func getParameters(user:HBCIUser) ->HBCISepaStandingOrderNewPar? {
        if let seg = user.parameters.parametersForJob("SepaStandingOrderNew") {
            if let elem = seg.elementForPath("ParSepaStandingOrderNew") {
                let maxUsage = elem.elementValueForPath("maxusage") as! Int;
                let minPreDays = elem.elementValueForPath("minpretime") as! Int;
                let maxPreDays = elem.elementValueForPath("maxpretime") as! Int;
                let cm = elem.elementValueForPath("turnusmonths") as! String;
                let dpm = elem.elementValueForPath("dayspermonth") as! String;
                let cw = elem.elementValueForPath("turnusweeks") as? String;
                let dpw = elem.elementValueForPath("daysperweek") as? String;
                return HBCISepaStandingOrderNewPar(maxUsage: maxUsage, minPreDays: minPreDays, maxPreDays: maxPreDays, cycleMonths: cm, daysPerMonth: dpm, cycleWeeks: cw, daysPerWeek: dpw);
            }
        }
        return nil;
    }

    
}