//
//  View+customHeaderView.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 14/02/2025.
//

import SwiftUI

func decodeBase64(_ base64: String) -> String {
    guard let data = Data(base64Encoded: base64),
          let decoded = String(data: data, encoding: .utf8) else {
        fatalError("Failed to decode base64 string: \(base64)")
    }
    return decoded
}

public extension View {
    @ViewBuilder func customHeaderView<Content: View>(@ViewBuilder _ headerView: @escaping () -> Content, height: CGFloat) -> some View {
        overlay(content: {
            CustomNavigationHeaderView(headerView: headerView, height: height)
                .frame(width: 0, height: 0)
        })
    }
}

public struct CustomNavigationHeaderView<HeaderView: View>: UIViewControllerRepresentable {
    @ViewBuilder public var headerView: () -> HeaderView
    let height: CGFloat

    public func makeUIViewController(context: Context) -> UIViewController {
        return ViewControllerMapper(headerView: headerView, height: height)
    }

    class ViewControllerMapper: UIViewController {
        let headerView: () -> HeaderView
        let height: CGFloat

        init(headerView: @escaping () -> HeaderView, height: CGFloat) {
            self.headerView = headerView
            self.height = height
            super.init(nibName: nil, bundle: nil)
        }

        override func viewWillAppear(_ animated: Bool) {
            guard let navigationController = self.navigationController,
                  let navigationItem = navigationController.visibleViewController?.navigationItem else { return }

            let paletteClassName = decodeBase64("X1VJTmF2aWdhdGlvbkJhclBhbGV0dGU=")
            let _UINavigationBarPalette = NSClassFromString(paletteClassName) as! UIView.Type

            let castedHeaderView = UIHostingController(rootView: headerView()).view
            castedHeaderView?.frame.size.height = height
            castedHeaderView?.backgroundColor = .clear

            let allocSelector = decodeBase64("YWxsb2M=")
            let initWithContentViewSelector = decodeBase64("aW5pdFdpdGhDb250ZW50Vmlldzo=")

            let palette = _UINavigationBarPalette.perform(NSSelectorFromString(allocSelector))
                .takeUnretainedValue()
                .perform(NSSelectorFromString(initWithContentViewSelector), with: castedHeaderView)
                .takeUnretainedValue()

            let setBottomPaletteSelector = decodeBase64("X3NldEJvdHRvbVBhbGV0dGU6")
            navigationItem.perform(NSSelectorFromString(setBottomPaletteSelector), with: palette)

            super.viewWillAppear(animated)
        }

        required init?(coder: NSCoder) {
            fatalError(decodeBase64("aW5pdChjb2RlcikgaGFzIG5vdCBiZWVuIGltcGxlbWVudGVk"))
        }
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
