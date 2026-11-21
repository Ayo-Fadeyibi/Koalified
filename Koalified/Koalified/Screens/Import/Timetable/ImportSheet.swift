//
//  ImportSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 21/11/2026.
//

import SwiftUI
import WebKit

struct TimetableWebView: UIViewControllerRepresentable {
    let url: URL
    let onLink: (URL) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onLink: onLink) }

    func makeUIViewController(context: Context) -> WebContainerViewController {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Only inject into the main frame so Okta's hidden iframes aren't touched at all
        config.userContentController.addUserScript(
            WKUserScript(source: Coordinator.finder, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        )
        config.userContentController.addUserScript(
            WKUserScript(source: Coordinator.nativeFieldTaps, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        )
        config.userContentController.add(context.coordinator, name: "timetableLink")

        let web = WKWebView(frame: .zero, configuration: config)
        web.uiDelegate = context.coordinator
        web.navigationDelegate = context.coordinator

        let vc = WebContainerViewController(webView: web)
        web.load(URLRequest(url: url))
        return vc
    }

    func updateUIViewController(_ vc: WebContainerViewController, context: Context) {}

    static func dismantleUIViewController(_ vc: WebContainerViewController, coordinator: Coordinator) {
        vc.webView.configuration.userContentController.removeScriptMessageHandler(forName: "timetableLink")
    }

    static func signOut() async {
        let store = WKWebsiteDataStore.default()
        await store.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
    }

    /// Plain UIViewController whose view is the web view.
    final class WebContainerViewController: UIViewController {
        let webView: WKWebView

        init(webView: WKWebView) {
            self.webView = webView
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) { fatalError() }

        override func loadView() {
            self.view = webView
        }
    }

    final class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
        let onLink: (URL) -> Void
        init(onLink: @escaping (URL) -> Void) { self.onLink = onLink }

        static let finder = #"""
        (function () {
          var host = window.location.hostname || '';
          if (host.indexOf('okta.com') !== -1 || host.indexOf('auth.uq.edu.au') !== -1) {
            return;
          }

          var sent = false;
          function scan() {
            if (sent) { return true; }
            if (document.querySelector('input[type="password"], input[name="identifier"], input[name="username"]')) {
              return false;
            }
            function isReal(link) {
              var decoded = link;
              try { decoded = decodeURIComponent(link); } catch (e) {}
              return /^(https?|webcal):/i.test(link) && decoded.indexOf('[%') === -1 && decoded.indexOf('%]') === -1;
            }
            var candidates = [];
            document.querySelectorAll('a[title="This iCalendar URL"]').forEach(function (a) { candidates.push(a.href); });
            document.querySelectorAll('input.text[disabled]').forEach(function (i) { candidates.push(i.value); });
            var link = candidates.find(isReal) || '';
            if (link) {
              sent = true;
              window.webkit.messageHandlers.timetableLink.postMessage(link);
              return true;
            }
            return false;
          }
          if (scan()) { return; }
          var tries = 0;
          var timer = setInterval(function () {
            if (scan() || ++tries >= 40) { clearInterval(timer); }
          }, 1500);
        })();
        """#

        /// UQ's sign-in page runs a fast-click script that cancels every `touchend` and fakes the click itself.
        /// That's fine for buttons and checkboxes, but on text fields it stops iOS from showing the keyboard.
        /// A capture listener on `window` runs before the page's own listeners, so stopping touches on text
        /// fields there keeps them away from that script and lets iOS handle the tap natively.
        static let nativeFieldTaps = #"""
        (function () {
          var textTypes = /^(text|password|email|search|tel|url|number)$/i;
          function isTextField(target) {
            var el = target && target.closest ? target.closest('input, textarea') : null;
            if (!el || el.disabled || el.readOnly) { return false; }
            return el.tagName === 'TEXTAREA' || textTypes.test(el.type || 'text');
          }
          ['touchstart', 'touchend'].forEach(function (type) {
            window.addEventListener(type, function (e) {
              if (isTextField(e.target)) { e.stopPropagation(); }
            }, true);
          });
        })();
        """#

        static func httpsURL(from text: String) -> URL? {
            var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.lowercased().hasPrefix("webcal://") {
                trimmed = "https://" + trimmed.dropFirst("webcal://".count)
            }
            return URL(string: trimmed)
        }

        private var hasReported = false

        private func report(_ text: String) {
            guard !hasReported, let url = Self.httpsURL(from: text) else { return }
            hasReported = true
            onLink(url)
        }

        func userContentController(_ c: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let text = message.body as? String else { return }
            guard !text.contains("[%"), !text.contains("%5B%25") else { return }
            report(text)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if let url = navigationAction.request.url,
               url.scheme?.lowercased() == "webcal" {
                report(url.absoluteString)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}

struct ImportSheet: View {
    let onLink: (String) -> Void
    let onDone: () -> Void

    private let targetURL = URL(string: "https://my.uq.edu.au/student-timetable")!
    @State private var webViewID = UUID()

    var body: some View {
        NavigationStack {
            TimetableWebView(url: targetURL) { link in
                onLink(link.absoluteString)
            }
            .id(webViewID)
            .navigationTitle("UQ Timetable")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign out") {
                        Task {
                            await TimetableWebView.signOut()
                            TimetableLinkStore.delete()
                            webViewID = UUID()
                        }
                    }
                    .font(.fredoka(.subheadline, .bold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDone()
                    }
                    .font(.fredoka(.subheadline, .bold))
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    ImportSheet(onLink: { _ in }, onDone: {})
}
