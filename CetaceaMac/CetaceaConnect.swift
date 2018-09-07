//
//  CetaceaConnect.swift
//  CetaceaMac
//
//  Created by Kenneth Friedman on 7/1/18.
//  Copyright © 2018 Kenneth Friedman. All rights reserved.
//

import Cocoa

class CetaceaConnect: NSObject {
	
	public static func getCetaceaEntry(_ incomingCompletionHandler: @escaping (Data) -> Void) {
		let urlSession = URLSession.shared
		guard let url = URL.init(string: "http://cetacea.xyz/api/journal?id=22") else { fatalError("Problem with URL!") }
		let getRequest = URLRequest.init(url: url)
		
		let urlHandler: (Data?, URLResponse?, Error?) -> Void = { (data, urlR, error) in
			guard let realData = data else { fatalError("No data!") }
			incomingCompletionHandler(realData)
		}
		
		let task = urlSession.dataTask(with: getRequest, completionHandler: urlHandler)
		task.resume()
	}
	
	public static func setCetaceaEntry(_ incomingEntry:String, _ incomingCompletionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
		let headers = [
			"Content-Type": "text/plain;charset=UTF-8",
			"Accept": "*/*",
			"Host": "www.cetacea.xyz",
			"Accept-Language": "en-us",
			"Accept-Encoding": "gzip, deflate",
			"Origin": "http://www.cetacea.xyz",
			"Referer": "http://www.cetacea.xyz/journal",
			"DNT": "1",
			"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15",
			"Connection": "keep-alive",
			"Cookie": "G_AUTHUSER_H=0; G_ENABLED_IDPS=google",
			"Cache-Control": "no-cache",
		]
		
		let dateString = Formatter.iso8601.string(from: Date())
		let userIDKey = "user_id"
		let entryKey = "entry"
		let timestampKey = "timestamp"
		let userID = 22
		let entry = String.init(cString: incomingEntry.cString(using: String.Encoding.utf8)!)
		//let entry = String(incomingEntry.cString(using: String.Encoding.utf8))// .cStringUsing(NSUTF8StringEncoding))
//		let entry = incomingEntry
		let httpBodyString = "{\"\(userIDKey)\":\(userID),\"\(entryKey)\":\"\(entry)\",\"\(timestampKey)\":\"\(dateString)\"}"
		let httpBodyUTF8Encoded = httpBodyString.data(using: String.Encoding.utf8)
		let postData = NSData(data: httpBodyUTF8Encoded!)
		let request = NSMutableURLRequest(url: NSURL(string: "http://www.cetacea.xyz/api/journal")! as URL,
										  cachePolicy: .useProtocolCachePolicy,
										  timeoutInterval: 5.0)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = headers
		request.httpBody = postData as Data
		let session = URLSession.shared

		let dataTask = session.dataTask(with: request as URLRequest, completionHandler: incomingCompletionHandler)
		dataTask.resume()
	}
}


extension Formatter {
	static let iso8601: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}()
}
