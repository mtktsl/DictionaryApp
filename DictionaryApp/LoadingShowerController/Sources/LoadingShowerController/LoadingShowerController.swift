
import UIKit

public protocol LoadingShowerController where Self: UIViewController {
    func showLoading()
    func hideLoading()
}

public extension LoadingShowerController {
    func showLoading() {
        LoadingView.shared.startLoading()
    }
    func hideLoading() {
        LoadingView.shared.hideLoading()
    }
}
