//
//  ViewController.swift
//  CetaceaMac
//
//  Created by Kenneth Friedman on 6/30/18.
//  Copyright © 2018 Kenneth Friedman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet var textView: NSTextView!
	@IBOutlet var timestampLabel: NSTextField!
	@IBOutlet var savingLabel: NSTextField!
	
	//State variables
	private var isUpdating:Bool = false
	private var needsUpdating:Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//set up code & UI
		textView.delegate = self
		textView.isRichText = false
		
		let font = NSFont(name: "Avenir", size: 14)
		if let avenirFont = font {
			let attributes = NSDictionary(object: avenirFont, forKey: NSAttributedString.Key.font as NSCopying)
			textView.typingAttributes = attributes as! [NSAttributedString.Key : Any]
		}
		
		disableTextViewEditing()
		hideSavingInfo()

		//on launch, get most recent entry
		CetaceaConnect.getCetaceaEntry({ (data:Data) in
			self.parseIncomingData(data: data)
		})
	}
	
	//parseIncomingdata does three things: (1) Sets up needed variables (2) parses incoming json (3) acts on the parsed data
	private func parseIncomingData(data:Data) {
		
		var entry = ""
		//var userID = ""
		var timestamp = ""
		
		do {
			let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
			print("go")
			print(json)
			
			let entryKey = "entry"
			if let incomingEntry = json[entryKey] as? String {
				entry = incomingEntry
			}
			
			//let userIDKey = "userId"
			//if let incomingUserID = json[userIDKey] as? String {
			//	userID = incomingUserID
			//}
			
			let timestampKey = "timestamp"
			if var incomingTimestamp = json[timestampKey] as? String {
				
				incomingTimestamp = String("\(incomingTimestamp) UTC")
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "MMM d, yyyy h:mm:ss a zzz" // Pass any format here you want according to your date response
				let convDate = dateFormatter.date(from: incomingTimestamp)
				if let utcDate = convDate {
					let dateFormatter2 = DateFormatter()
					dateFormatter2.dateFormat = "MMM d, yyyy h:mm:ss a"
					let timeZoneDateTime = dateFormatter2.string(from: utcDate)
					print(timeZoneDateTime)
					timestamp = timeZoneDateTime
				}
			}

		} catch let error as NSError {
			print("Failed to load: \(error.localizedDescription)")
		}
		
		//Act on the parsed data
		DispatchQueue.main.async {
			self.writeIncomingEntryToTextView(entry: entry)
			self.writeTimestampToLabel(timestamp: timestamp)
			self.enableTextViewEditing()
		}
	}
	
	//// Modify text view editing ability ///
	private func enableTextViewEditing() {
		self.textView.isEditable = true
	}
	
	private func disableTextViewEditing() {
		self.textView.isEditable = false
	}
	
	//// update UI ////
	private func writeIncomingEntryToTextView(entry:String) {
		self.textView.string = entry
	}
	
	private func writeTimestampToLabel(timestamp:String) {
		self.timestampLabel.stringValue = timestamp
	}
	
	private func hideSavingInfo() {
		DispatchQueue.main.async {
			self.savingLabel.isHidden = true
		}
	}
	
	private func showSavingInfo() {
		DispatchQueue.main.async {
			self.savingLabel.isHidden = false
		}
	}

	private func sendTextToCetacea() {
		self.isUpdating = true
		showSavingInfo()
		guard var textViewString = textView.textStorage?.string else { return }
		textViewString = textViewString.replacingOccurrences(of: "\n", with: "\\n")
		textViewString = textViewString.replacingOccurrences(of: "\"", with: "\\\"")
		print(textViewString)
		CetaceaConnect.setCetaceaEntry(textViewString, { (data, response, error) -> Void in
			self.updateForSuccessfulSave(data, response, error)
		})
	}
	
	private func updateForSuccessfulSave(_ data:Data?,_ response:URLResponse?, _ error:Error?) {
		//update that it is no longer updating
		self.isUpdating = false
		hideSavingInfo()
		
		//process response
		//guard let httpResponse = response else { return }
		//print(httpResponse)
		
		//check to reupdate
		self.checkForReSave()
	}
	
	private func checkForReSave() {
		//re-update if changes have been made while updating
		guard self.needsUpdating else { return }
		self.needsUpdating = false
		DispatchQueue.main.sync {
			self.sendTextToCetacea()
		}
	}
}

extension ViewController : NSTextViewDelegate {
	
	func textDidChange(_ notification: Notification) {
		if (isUpdating) {
			needsUpdating = true
		} else {
			sendTextToCetacea()
		}
	}
}
