//
//  Logger.swift
//  handloan
//
//  Created by Mehul Bhavani on 25/02/22.
//

import Foundation

class Logger {
    static func debug(_ object: Any? = nil, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
        Logger.log(object, file: fileName, method: methodName, line: lineNumber)
    }
    static func error(_ object: Any, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
        Logger.log("ERROR: \(object)", file: fileName, method: methodName, line: lineNumber)
    }
    
    private static func log(_ object: Any?, file: String, method: String, line: Int) {
        let filename = (file as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        var logMessage = "[\(filename).\(method)][L:\(line)]"
        if let message = object {
            logMessage = "[\(filename).\(method)][L:\(line)]\(message)"
        }
        
        print("\(logMessage)")
    }
}

extension Dictionary {
    func jsonify() -> String {
        do {
            var options: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]
            if #available(OSX 10.15, *) {
                options = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
            }
            let theJSONData = try JSONSerialization.data(withJSONObject: self, options: options)
            if let theJSONText = String(data: theJSONData, encoding: .utf8) {
                return theJSONText
            }
        } catch {
            Logger.error(error.localizedDescription)
            return "{\nerror:\(error.localizedDescription)\n}"
        }
        return "{}"
    }
}
