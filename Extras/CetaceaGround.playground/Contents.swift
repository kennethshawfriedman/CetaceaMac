import Cocoa

var str = "Hello, playground"

class CetaceaConnect {
	
	func getCetaceaEntry(_ incomingCompletionHandler: @escaping (Data) -> Void) {
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
	
	func saveCetaceaEntry(entry:String) {
		
		
		let userID:NSString = "22"
		let entryTemp:NSString = "wow!"
		let timeStamp:NSString = "2018-07-02T00:45:57.945Z"
		let postBodyValues:[String : Any] = ["entry": entryTemp, "timestamp": timeStamp, "user_id": userID]
		
		let postBodyNS = NSDictionary.init(dictionary: postBodyValues)
		
		var data = Data.init()
		
		//let data : NSData = NSKeyedArchiver.archivedData(withRootObject: postBodyValues) as NSData
		do {
			data = try JSONSerialization.data(withJSONObject:postBodyNS, options:.prettyPrinted)
			
			let decoded = try JSONSerialization.jsonObject(with: data, options: [])
			
			print(decoded)
			
			//guard JSONSerialization.isValidJSONObject(data) else { fatalError("Problem with JSON!")}
			
		} catch {
			print("no go")
		}
		
		
		guard let url = URL.init(string: "http://cetacea.xyz/api/journal") else { fatalError("Problem with URL!") }
		var postRequest = URLRequest.init(url: url)
		postRequest.setValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
		postRequest.setValue("*/*", forHTTPHeaderField: "Accept")
		postRequest.setValue("www.cetacea.xyz", forHTTPHeaderField: "Host")
		postRequest.setValue("en-us", forHTTPHeaderField: "Accept-Language")
		postRequest.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
		postRequest.setValue("http://www.cetacea.xyz", forHTTPHeaderField: "Origin")
		postRequest.setValue("http://www.cetacea.xyz/journal", forHTTPHeaderField: "Referer")
//		//skipping length, hopefully!
		postRequest.setValue("71", forHTTPHeaderField: "Content-Length")
		postRequest.setValue("1", forHTTPHeaderField: "DNT")
		postRequest.setValue("keep-alive", forHTTPHeaderField: "Connection")
		postRequest.setValue("G_AUTHUSER_H=0; G_ENABLED_IDPS=google", forHTTPHeaderField: "Cookie")
		
		let x = "{\"user_id\":22,\"entry\":\"what...\",\"timestamp\":\"2018-07-24T02:40:29.105Z\"}"
		
		postRequest.httpBody = Data.init(base64Encoded: x)

		let task = URLSession.shared.dataTask(with: postRequest) {
			data, response, error in
			print("made it!")
			print(response ?? "no good")
			print(error ?? "no erroer")
			// Your completion handler code here
		}
		task.resume()
		print("here we are")
		
	}
	
	public func printHey() {
		print("hey")
	}
	
}


let handler: (Data) -> Void = { data in
	do {
		let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
		print(json ?? "no JSON!")
	} catch {
		print("whoops!")
	}
}

let cc = CetaceaConnect()
cc.printHey()


//cc.saveCetaceaEntry(entry: "this is it, how are you")
//cc.getCetaceaEntry(handler)




