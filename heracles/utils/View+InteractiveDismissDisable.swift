//
//  View+InteractiveDismissDisable.swift
//  heracles
//
//  Created by Miłosz Koczorowski on 06/10/2024.
//


/*
 * Workaround current limitations of `interactiveDismissDisable` which allows to
 * react on user's attempt to dismiss a sheet and f.e. show a confirmation dialog
 *
 * Source: https://gist.github.com/peterfriese/8fb3d76bdbe21b84495b79b3a86bf898
 * https://peterfriese.dev/blog/2021/swiftui-confirmation-dialogs/
 */

import SwiftUI

extension View {
  public func interactiveDismissDisabled(_ isDisabled: Bool = true, onAttemptToDismiss: (() -> Void)? = nil) -> some View {
    InteractiveDismissableView(view: self, isDisabled: isDisabled, onAttemptToDismiss: onAttemptToDismiss)
  }
  
  public func interactiveDismissDisabled(_ isDisabled: Bool = true, attemptToDismiss: Binding<Bool>) -> some View {
    InteractiveDismissableView(view: self, isDisabled: isDisabled) {
      attemptToDismiss.wrappedValue.toggle()
    }
  }
  
}

private struct InteractiveDismissableView<T: View>: UIViewControllerRepresentable {
  let view: T
  let isDisabled: Bool
  let onAttemptToDismiss: (() -> Void)?
  
  func makeUIViewController(context: Context) -> UIHostingController<T> {
    UIHostingController(rootView: view)
  }
  
  func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {
    context.coordinator.dismissableView = self
    uiViewController.rootView = view
    uiViewController.parent?.presentationController?.delegate = context.coordinator
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
    var dismissableView: InteractiveDismissableView
    
    init(_ dismissableView: InteractiveDismissableView) {
      self.dismissableView = dismissableView
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
      !dismissableView.isDisabled
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
      dismissableView.onAttemptToDismiss?()
    }
  }
}
