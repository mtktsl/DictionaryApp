
import UIKit

//NOTE: This implementation belongs to Kerim Caglar
//I was already going to do the same things so instead i fetched it
//github: https://github.com/kcaglarr
public protocol LoadingShower: AnyObject {
    func showLoading()
    func hideLoading()
}

public extension LoadingShower {
    func showLoading() {
        LoadingView.shared.startLoading()
    }
    func hideLoading() {
        LoadingView.shared.hideLoading()
    }
}
