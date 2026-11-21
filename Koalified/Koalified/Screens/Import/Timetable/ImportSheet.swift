//
//  ImportSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 21/11/2026.
//

import SwiftUI
import WebKit

struct TimetableWebView: UIViewRepresentable {
    let url: URL
    let onLink: (URL) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onLink: onLink) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        config.userContentController.addUserScript(
            WKUserScript(source: Coordinator.finder, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        )
        config.userContentController.add(context.coordinator, name: "timetableLink")

        let web = WKWebView(frame: .zero, configuration: config)
        web.uiDelegate = context.coordinator
        web.navigationDelegate = context.coordinator
        web.isUserInteractionEnabled = true
        web.scrollView.keyboardDismissMode = .interactive
        web.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
        web.load(URLRequest(url: url))
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
        let onLink: (URL) -> Void
        init(onLink: @escaping (URL) -> Void) { self.onLink = onLink }

        static let finder = #"""
        (function () {
          // Do not touch Okta / SSO login pages so username & password inputs stay instant
          var host = window.location.hostname || '';
          if (host.indexOf('okta.com') !== -1 || host.indexOf('auth.uq.edu.au') !== -1) {
            return;
          }

          var sent = false;
          function scan() {
            if (sent) { return true; }
            // Never run while a sign-in form is on screen, whatever host it is served from.
            if (document.querySelector('input[type="password"], input[name="identifier"], input[name="username"]')) {
              return false;
            }
            // The page ships an unfilled template ("[%= iCalURL %]") before the real link arrives,
            // so skip anything that still contains template markers.
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

        func userContentController(_ c: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let text = message.body as? String, let url = URL(string: text) else { return }
            // Safety net: never hand on an unfilled page template.
            guard !text.contains("[%"), !text.contains("%5B%25") else { return }
            onLink(url)
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
                let httpsString = url.absoluteString.replacingOccurrences(of: "webcal://", with: "https://", options: .caseInsensitive)
                if let httpsURL = URL(string: httpsString) {
                    onLink(httpsURL)
                }
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

    var body: some View {
        NavigationStack {
            TimetableWebView(url: targetURL) { link in
                onLink(link.absoluteString)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("UQ Timetable")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDone()
                    }
                    .font(.fredoka(.subheadline, .bold))
                }
            }
        }
        // Prevents SwiftUI's sheet drag gesture from hijacking taps on Okta's text fields
        .interactiveDismissDisabled()
    }
}



#Preview {
    ImportSheet(onLink: { _ in }, onDone: {})
}
