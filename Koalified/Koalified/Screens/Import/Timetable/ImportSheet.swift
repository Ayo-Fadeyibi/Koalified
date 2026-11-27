//
//  ImportSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 21/11/2026.
//

import SwiftUI
import WebKit

/// Owns the sign-in web view for as long as a sign-in is in progress.
/// Switching to Okta Verify sends Koalified to the background, and SwiftUI can rebuild the sheet's views
/// when it comes back. A rebuilt web view starts the login again from the password step, so the web view
/// lives here instead and is handed back to whichever view is on screen. Ended on Done, Sign out or
/// once the link is found.
final class TimetableWebSession {
    private(set) static var current: TimetableWebSession?

    let webView: WKWebView
    let coordinator: TimetableWebView.Coordinator

    private init(url: URL) {
        coordinator = TimetableWebView.Coordinator()

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Only inject into the main frame so Okta's hidden iframes aren't touched at all
        config.userContentController.addUserScript(
            WKUserScript(source: TimetableWebView.Coordinator.finder, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        )
        config.userContentController.addUserScript(
            WKUserScript(source: TimetableWebView.Coordinator.nativeFieldTaps, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        )
        config.userContentController.add(coordinator, name: "timetableLink")

        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = coordinator
        webView.navigationDelegate = coordinator
        webView.load(URLRequest(url: url))
    }

    /// The session in progress, or a new one that starts loading `url`.
    static func resume(url: URL) -> TimetableWebSession {
        if let current { return current }
        let session = TimetableWebSession(url: url)
        current = session
        return session
    }

    /// Loads the page again after a failed load, e.g. once the phone is back online.
    /// If nothing has loaded yet, starts from `url`.
    static func retry(url: URL) {
        guard let webView = current?.webView else { return }
        if webView.backForwardList.currentItem == nil {
            webView.load(URLRequest(url: url))
        } else {
            webView.reload()
        }
    }

    /// Throws the web view away. The next `resume` starts a fresh sign-in.
    static func end() {
        guard let current else { return }
        // The content controller holds its message handler strongly, so drop it or the coordinator leaks.
        current.webView.configuration.userContentController.removeScriptMessageHandler(forName: "timetableLink")
        current.webView.removeFromSuperview()
        self.current = nil
    }
}

struct TimetableWebView: UIViewControllerRepresentable {
    let url: URL
    let onLink: (URL) -> Void
    /// Called when a page fails to load because the phone has no connection.
    let onOffline: () -> Void

    func makeCoordinator() -> Coordinator { TimetableWebSession.resume(url: url).coordinator }

    func makeUIViewController(context: Context) -> WebContainerViewController {
        context.coordinator.onLink = onLink
        context.coordinator.onOffline = onOffline
        return WebContainerViewController(webView: TimetableWebSession.resume(url: url).webView)
    }

    func updateUIViewController(_ vc: WebContainerViewController, context: Context) {
        // Keep the callbacks current in case the view that presented the sheet was rebuilt.
        context.coordinator.onLink = onLink
        context.coordinator.onOffline = onOffline
    }

    // No dismantleUIViewController: the web view belongs to `TimetableWebSession`, so the sign-in
    // survives a rebuilt view. `TimetableWebSession.end()` does the cleanup.

    static func signOut() async {
        let store = WKWebsiteDataStore.default()
        await store.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
    }

    /// Plain UIViewController that shows the session's web view. The web view is added as a subview,
    /// not used as `view`, so a rebuilt container can take it over from the old one.
    final class WebContainerViewController: UIViewController {
        let webView: WKWebView

        init(webView: WKWebView) {
            self.webView = webView
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) { fatalError() }

        override func viewDidLoad() {
            super.viewDidLoad()
            attachWebView()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // If another container briefly took the web view, take it back.
            attachWebView()
        }

        private func attachWebView() {
            guard webView.superview !== view else { return }
            webView.frame = view.bounds
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(webView)   // also removes it from any previous container
        }
    }

    final class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
        /// Set by the view on screen; updated if that view is rebuilt.
        var onLink: (URL) -> Void = { _ in }
        var onOffline: () -> Void = {}

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            reportIfOffline(error)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            reportIfOffline(error)
        }

        /// Only no-connection failures show the offline screen. Others (e.g. a cancelled load when the
        /// page redirects) are left to the page itself.
        private func reportIfOffline(_ error: Error) {
            let nsError = error as NSError
            guard nsError.domain == NSURLErrorDomain,
                  URLError.Code(rawValue: nsError.code).meansOffline else { return }
            onOffline()
        }

        static let finder = #"""
        (function () {
          // Stay off every sign-in page (old UQ Authenticate and Okta) so login works untouched.
          var host = window.location.hostname || '';
          if (host.indexOf('okta.com') !== -1 || host.indexOf('auth.uq.edu.au') !== -1 ||
              host.indexOf('signin.uq.edu.au') !== -1) {
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
        /// Only runs on that page: on Okta's sign-in (signin.uq.edu.au) blocking touches breaks the login.
        static let nativeFieldTaps = #"""
        (function () {
          if ((window.location.hostname || '').indexOf('auth.uq.edu.au') === -1) { return; }
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

        /// Schemes the web view loads itself; anything else is an app link for iOS to open.
        private static let webSchemes: Set<String> = ["http", "https", "about", "data", "blob", "javascript"]

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
            // A web view can't open app links (e.g. Okta Verify's oktaverify://) and silently drops them,
            // which sends UQ's sign-in back to the password step. Hand them to iOS like Safari does.
            if let url = navigationAction.request.url,
               let scheme = url.scheme?.lowercased(),
               !Self.webSchemes.contains(scheme) {
                UIApplication.shared.open(url)
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
    /// True after a page failed to load because the phone has no connection.
    @State private var isOffline = false
    /// True while the UQ sign-in data is being cleared.
    @State private var isSigningOut = false

    var body: some View {
        NavigationStack {
            TimetableWebView(
                url: targetURL,
                onLink: { link in
                    TimetableWebSession.end()
                    onLink(link.absoluteString)
                },
                onOffline: { withAnimation(.easeOut(duration: 0.25)) { isOffline = true } }
            )
            .id(webViewID)
            .overlay {
                if isOffline {
                    offlineCard
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                }
            }
            .loadingOverlay(isPresented: isSigningOut, message: "Signing out…")
            .navigationTitle("UQ Timetable")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign out") {
                        Task {
                            isSigningOut = true
                            defer { isSigningOut = false }
                            await TimetableWebView.signOut()
                            TimetableLinkStore.delete()
                            TimetableWebSession.end()   // the next web view starts a fresh sign-in
                            isOffline = false
                            webViewID = UUID()
                        }
                    }
                    .font(.fredoka(.subheadline, .bold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        TimetableWebSession.end()
                        onDone()
                    }
                    .font(.fredoka(.subheadline, .bold))
                }
            }
        }
        .interactiveDismissDisabled()
    }

    /// Covers the web view (which would show a blank or browser error page) with a plain explanation.
    private var offlineCard: some View {
        ZStack(alignment: .top) {
            Color.screenBackground.ignoresSafeArea()
            EmptyStateView(
                header1: "No connection",
                title1: "You're offline",
                message1: "Connect to Wi-Fi or mobile data, then try again to sign in to UQ.",
                primaryTitle1: "Try again",
                primaryAction1: {
                    withAnimation(.easeIn(duration: 0.2)) { isOffline = false }
                    TimetableWebSession.retry(url: targetURL)
                }
            )
            .padding(Layout.screenPadding)
        }
    }
}

#Preview {
    ImportSheet(onLink: { _ in }, onDone: {})
}
