/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit


class FrameView: UIView {
	var isGoodFrame = false;
	
	func setGoodFrame() {
		isGoodFrame = true;
		
		DispatchQueue.main.async {
			self.setNeedsDisplay()
		}
	}
	
	func setBadFrame() {
		isGoodFrame = false;
		
		DispatchQueue.main.async {
			self.setNeedsDisplay()
		}
	}
	
  func clear() {
		isGoodFrame = false
    DispatchQueue.main.async {
      self.setNeedsDisplay()
    }
  }
  
  override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		context.saveGState()

		// 3
		defer {
			context.restoreGState()
		}
		// 2
		
		context.setFillColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5).cgColor)
		// 3
		context.fill(bounds)

		let radius: CGFloat = UIScreen.main.bounds.size.width * 0.45
		
		if(isGoodFrame) {
			context.setFillColor(UIColor.green.cgColor)
		} else {
			context.setFillColor(UIColor.red.cgColor)
		}
		
		context.addEllipse(in: CGRect(x: (UIScreen.main.bounds.size.width*0.5) - radius,y: (UIScreen.main.bounds.size.height*0.5) - radius, width: 2.0 * radius, height: 2.0 * radius))
		context.drawPath(using: .fill)
		
		let radius2: CGFloat = UIScreen.main.bounds.size.width * 0.43
		context.setFillColor(UIColor.clear.cgColor)
		context.setBlendMode(.clear)
		context.addEllipse(in: CGRect(x: (UIScreen.main.bounds.size.width*0.5) - radius2,y: (UIScreen.main.bounds.size.height*0.5) - radius2, width: 2.0 * radius2, height: 2.0 * radius2))
		
		context.drawPath(using: .fill)
  }
}
