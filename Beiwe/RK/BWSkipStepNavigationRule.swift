//
//  BWSkipStepNavigationRule.swift
//  Beiwe
//
//  Created by Keary Griffin on 11/28/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//
//  Debuged and modified by Zexing Gao on 06/10/18.
//


import Foundation

@objc class OpTuple : NSObject {
    let op: String;
    let values: AnyObject;
    init(op: String, values: AnyObject) {
        self.op = op;
        self.values = values;
    }
}

struct OpFunction {
    let minArgs: Int;
    let maxArgs: Int;
    let evalFunc: ([NSNumber]) -> NSNumber;
    init(minArgs: Int, maxArgs: Int, evalFunc: @escaping ([NSNumber]) -> NSNumber) {
        self.minArgs = minArgs;
        self.maxArgs = maxArgs;
        self.evalFunc = evalFunc;
    }

    func eval(_ args: [NSNumber?]) -> NSNumber {
        if (args.count < minArgs || (maxArgs != -1 && args.count > maxArgs)) {
            return 0;
        }
        return evalFunc(args.flatMap { return $0! } );
    }
}

class BWSkipStepNavigationRule : ORKSkipStepNavigationRule {

    var displayIf: [String:AnyObject]?;
    lazy var operatorMap: [String: OpFunction] = {
        [unowned self] in
        var opDict: [String:OpFunction] = [:];
        opDict["=="] = OpFunction(minArgs: 2, maxArgs: 2) { args in
            return (args[0].doubleValue == args[1].doubleValue) ? 1 : 0;
        };
        opDict["<"] = OpFunction(minArgs: 2, maxArgs: 2) { args in
            return (args[0].doubleValue < args[1].doubleValue) ? 1 : 0;
        };
        opDict["<="] = OpFunction(minArgs: 2, maxArgs: 2) { args in
            return (args[0].doubleValue <= args[1].doubleValue) ? 1 : 0;
        };
        opDict[">"] = OpFunction(minArgs: 2, maxArgs: 2) { args in
            return (args[0].doubleValue > args[1].doubleValue) ? 1 : 0;
        };
        opDict[">="] = OpFunction(minArgs: 2, maxArgs: 2) { args in
            return (args[0].doubleValue >= args[1].doubleValue) ? 1 : 0;
        };
        opDict["not"] = OpFunction(minArgs: 1, maxArgs: 1) { args in
            return (args[0].intValue == 0) ? 1 : 0;
        };
        opDict["and"] = OpFunction(minArgs: 1, maxArgs: -1) { args in
            var hasAFalse = args.contains { $0.intValue == 0 };
            return hasAFalse ? 0 : 1;
        };
        opDict["or"] = OpFunction(minArgs: 1, maxArgs: -1) { args in
            var hasATrue = args.contains { $0.intValue != 0 };
            return hasATrue ? 1 : 0;
        };
        opDict["nand"] = OpFunction(minArgs: 1, maxArgs: -1) { args in
            var hasAFalse = args.contains { $0.intValue == 0 };
            return hasAFalse ? 1 : 0;
        };
        opDict["nor"] = OpFunction(minArgs: 1, maxArgs: -1) { args in
            var hasATrue = args.contains { $0.intValue != 0 };
            return hasATrue ? 0 : 1;
        };


        return opDict;
        }();

    convenience init(displayIf: [String:AnyObject]) {
        self.init(coder: NSCoder());//deleted ! after NSCoder())
        self.displayIf = displayIf;
    }

    required init(coder: NSCoder) {//deleted ? after init
        super.init(coder: coder);
    }
    
    override func stepShouldSkip(with taskResult: ORKTaskResult) -> Bool {
        guard let displayIf = displayIf else {
            return false;
        }

        if let res = evaluateLogic(displayIf as AnyObject, taskResult: taskResult) {
            log.info("displayIf eval: \(res)");
            return res.intValue == 0;
        } else {
            return true;
        }
    }

    func valueForStepResult(_ stepResult: ORKStepResult) -> NSNumber? {
        if let results = stepResult.results, results.count > 0 {
            switch (results[0]) {
            case let choiceResult as ORKChoiceQuestionResult:
                if let choiceAnswers = choiceResult.choiceAnswers {
                    for idx in 0...choiceAnswers.count {
                        if let num: NSNumber = choiceAnswers[idx] as? NSNumber {
                            let numValue: Int = num.intValue;
                            if (numValue >= 0) {
                                return numValue as NSNumber;
                            }
                        }
                    }
                }
                return nil;
            case let questionResult as ORKQuestionResult:
                if let answer = questionResult.answer {
                    return Double(String(describing: answer)) as NSNumber?;
                }

                return nil;
            case let scaleResult as ORKScaleQuestionResult:
                if let answer = scaleResult.scaleAnswer {
                    return answer;
                }
                return nil;
            default:
                return nil;
            }
        } else {
            return nil;
        }

    }


    func evaluateLogic(_ value: AnyObject, taskResult: ORKTaskResult) -> NSNumber? {
        switch(value) {
        case let x as NSNumber:
            // If it's a number, just return it
            return x;
        case let questionId as NSString:
            // If it's a string, return nil or the value of the question answer
            if let questionIdStr = questionId as? String {
                let stepResult = taskResult.stepResult(forStepIdentifier: questionIdStr);
                if let stepResult = stepResult {
                    return valueForStepResult(stepResult);
                } else {
                    return nil;
                }
            }
            return nil;
        case let dict as [String:AnyObject]:
            // If this is a dict, convert it to an "and" array of operators
            var ar: [AnyObject] = [];
            for (key, val) in dict {
                ar.append(OpTuple(op: key, values: val));
            }
            return evaluateLogic(OpTuple(op: "and", values: ar as AnyObject), taskResult: taskResult);
        case let opTuple as OpTuple:
            // It's an operator, evaluate all of the array elements
            // If it's not an array, treat it as a single value and force into an array
            var opValues: [NSNumber?] = [ ];
            if let values = opTuple.values as? [AnyObject] {
                for v in values {
                    opValues.append(evaluateLogic(v, taskResult: taskResult))
                }
            } else {
                opValues.append(evaluateLogic(opTuple.values, taskResult: taskResult));
            }
            // If any of the values are nil, the result is false
            if (opValues.contains { $0 == nil }) {
                return 0;
            }

            if let opFunc = operatorMap[opTuple.op] {
                return opFunc.eval(opValues);
            } else {
                return nil;
            }


        default:
            // I dunno, but let's force evaluate to false
            return nil;
        }
    }
}
