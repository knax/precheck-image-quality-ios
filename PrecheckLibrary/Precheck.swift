//
//  Precheck.swift
//  MyFramework
//
//  Created by Bangun Kreatif on 02/02/23.
//

import Foundation
import UIKit

public class Precheck {
	public static var configuration: PrecheckConfiguration = PrecheckConfiguration()
	
	public static func initialize(configuration: PrecheckConfiguration) {
		self.configuration = configuration
	}
	
	public static func startPrecheck(selfRef: UIViewController, onSuccess: ((_ image: String)-> Void)?, onError: ((_ errorCode: Int)-> Void)?) {
		let storyboard = UIStoryboard(name: "PrecheckViewController", bundle: Bundle(for: Precheck.self))
		let vc = storyboard.instantiateViewController(withIdentifier: "PrecheckViewController") as? PrecheckViewController
		vc?.configuration = self.configuration
		vc?.onSuccess = onSuccess
		vc?.onError = onError
		
		print("navigation controller exist: \(selfRef.navigationController != nil)")
		selfRef.navigationController?.pushViewController(vc!, animated: true)
	}
}
