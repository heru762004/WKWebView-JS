//
//  TestWebViewController.swift
//  TestENETS
//
//  Created by Heru Prasetia on 13/2/19.
//  Copyright © 2019 Heru Prasetia. All rights reserved.
//

import UIKit
import WebKit

class TestWebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    

    var webView : WKWebView!
    var webConfig : WKWebViewConfiguration?
    var stateMachineStateName: String?
    var stateMachineEventName: String?
    var additionalScript: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = WKWebView(frame: self.view.frame, configuration: self.getWebConfig()!)
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.webView.frame = self.view.frame
        self.view.addSubview(self.webView)
        loadHTML()
        // Do any additional setup after loading the view.
    }
    
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    private func loadHTML() {
        print("[DebitViewController] \(#function)")
        
        let url = URL(string : "http://localhost/enets/test_dbs.html")
//        let url = URL(string : "https://www.lohjason.com/TestRepo/popuptestimm")
        
        if let url = url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let webView = self.webView {
                webView.load(request)
            }
        }
    }
    
    private func getWebConfig ()-> WKWebViewConfiguration? {
        if webConfig == nil {
            self.webConfig = WKWebViewConfiguration()
            
            let preference = WKPreferences()
            preference.javaScriptEnabled = true
            preference.javaScriptCanOpenWindowsAutomatically = true
            
            self.webConfig?.preferences = preference
            
            let userController = WKUserContentController()
            userController.add(self, name: "onReceivedData")
            
            let js : String = getUserScript()!
            let userScript = WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
            userController.addUserScript(userScript)
            
            let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            
            let jstest = "window.open = function(open) { return function (url, name, features) { window.location.href = url; return window; }; } (window.open);"
            
            let jstest2 = "var formsCollection = document.getElementsByTagName('form'); for(var i=0;i<formsCollection.length;i++) { if (window.frameElement) {formsCollection[i].target='_parent';} else { formsCollection[i].target=''; }}"
//            let jstest2 = "document.getElementsByTagName('a')[1].href = \"javascript:init()\";"
            
//            let jstest4 = "window.webkit.messageHandlers.heruHandler.postMessage(document.documentElement.outerHTML.toString());";
            
//            let jstest5 = "window.onload=function () {window.webkit.messageHandlers.heruHandler.postMessage('body onLoad');}"
            
            let wkuserScript = WKUserScript(source: jscript, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
            let wkuserScript2 = WKUserScript(source: jstest, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
            let wkuserScript3 = WKUserScript(source: jstest2, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
//            let wkuserScript3 = WKUserScript(source: jstest2, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
//            let wkuserScript5 = WKUserScript(source: jstest5, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
            
            
            userController.addUserScript(wkuserScript)
            userController.addUserScript(wkuserScript2)
            userController.addUserScript(wkuserScript3)
//            userController.addUserScript(wkuserScript4)
//            userController.addUserScript(wkuserScript5)
            
            self.webConfig?.userContentController = userController
            
        }
        return self.webConfig
    }
    
    
    private func getUserScript() -> String? {
        do {
            let script = try String(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "JSCallback",
                                                                                         ofType: "js")!,
                                    encoding: .utf8)
            return script
        } catch {
            print ("[DebitViewController]Error : \(error.localizedDescription)")
        }
        return nil

    }
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Navigation action
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        print ("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
        print ("[DebitViewController] WKNavigationActionPolicy  : \(#function)")
        print ("[DebitViewController] URL navigationAct : \(navigationAction.request.url!)")
        
        switch navigationAction.navigationType {
        case .linkActivated:
            print ("[DebitViewController] Navigation type : Link activated")
        case .formSubmitted :
            print ("[DebitViewController] Navigation type : Form Submitted")
        case .backForward :
            print ("[DebitViewController] Navigation type : Back forward")
        case .formResubmitted:
            print ("[DebitViewController] Navigation type : Form resubmitted")
        case .reload:
            print ("[DebitViewController] Navigation type : Reload")
        case .other:
            print ("[DebitViewController] Navigation type : Other")
            
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else { return completionHandler(.useCredential, nil) }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
    // Did policy decided
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        print ("[DebitViewController] WKNavigationResponsePolicy : \(#function)")
        print ("[DebitViewController] URL navigationResp : \(webView.url!)")
        
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print ("[DebitViewController] \(#function)")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print ("[DebitViewController] \(#function)")
        
        
        
    }
    
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print ("[DebitViewController] \(#function)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print ("[DebitViewController] \(#function) \(error)")
        
        
        let nsError = error as NSError
        print ("[DebitViewController] UserInfo : \(nsError.userInfo)")
        
        // handling for Standard Chartered, because they use Self Signed Cert
        //        if let errorMessage: String = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
        //            print ("[DebitViewController] error message = \(errorMessage)")
        //            if errorMessage.contains("SSL") {
        //                print ("[DebitViewController] YES")
        //                return
        //            }
        //        }
        
    }
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // intercept window.open
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print ("[DebitViewController] \(#function)")
        if navigationAction.targetFrame == nil {
            print("AllHTTP header fields = \(navigationAction.request.allHTTPHeaderFields)")
            print("URL = \(navigationAction.request.url?.absoluteString)")
            print("HTTP Method = \(navigationAction.request.httpMethod)")
            print("HTTP Body = \(navigationAction.request.httpBody)")
            
            
            guard let httpMethod = navigationAction.request.httpMethod else {
                return nil;
            }
            if httpMethod == "POST" {
                if stateMachineEventName != nil && stateMachineStateName != nil {
//                    let httpBody = "'statemachineEventName':'\(stateMachineEventName!)','statemachineStateName':'\(stateMachineStateName!)'"
//                    print("HTTP BODY = \(httpBody)")
//                    var naviAct = navigationAction.request
//                    naviAct.httpBody = httpBody.data(using: .utf8)
//                    print("URL = \(naviAct.url?.absoluteString)")
//                    print("HTTP Method = \(naviAct.httpMethod)")
//                    print("HTTP Headers = \(naviAct.allHTTPHeaderFields)")
//                    print("HTTP Body = \(naviAct.httpBody)")
//
//                    let path = Bundle.main.path(forResource: "postRequest", ofType: "html")
//                    do {
//                        let html = try String(contentsOfFile: path!, encoding: .utf8)
//                        webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
//
//                        additionalScript = "post('\(naviAct.url!.absoluteString)', {\(httpBody)});"
//                    } catch {
//
//                    }
                    webView.load(navigationAction.request)
                } else {
                    webView.load(navigationAction.request)
                }
            } else {
                webView.load(navigationAction.request)
            }
        }
        return nil
    }
    
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Page loading finish
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print ("[DebitViewController] \(#function)")
        
        
        if let url = webView.url {
            print ("[DebitViewController] URL : \(url.absoluteString)")
        }
        
       
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html, error) in
            if let error = error {
                print ("[DebitViewController] Error \(error)")
            } else if let html = html {
                print ("\(html)")
//                let abc = "\(html)"
                //self.test1(abc: abc)
            }
        }
        
        test();
        
        //perform(#selector(test), with: nil, afterDelay: 1)
        
        
        
//        webView.evaluateJavaScript("var win = window.open('http://google.com');") { (html, error) in
//            if let error = error {
//                print ("[DebitViewController] Error \(error)")
//            } else if let html = html {
//                print ("\(html)")
//
//            }
//        }
        // print HTML
        
    }
    
    @objc func test() {
        print("TEST CALLED")
        webView.evaluateJavaScript("document.body.onload()") { (ok, error) in
            if let error = error {
                print ("[DebitViewController] Error \(error)")
            } else if let ok = ok {
                print("\(ok)")
            }
        }
    }
    
    func test1 (abc: String)  {
        var functionWindowOpen = ""
        var myString = abc
        while myString.count > 0 {
            if myString.index(of: "window.open") == nil {
                break
            }
            if let index = myString.index(of: "window.open") {
                let strCompare = "\(myString[index...])"
                print("Strcompare = \(strCompare)")
                if strCompare.starts(with: "window.open(\"http://google.com\"") {
                    if let indexEnd = strCompare.index(of: ")") {
                        functionWindowOpen = "\(strCompare[...indexEnd])"
                        myString = "\(strCompare[indexEnd...])"
                        //                                print("functionWindowOpen = \(functionWindowOpen)")
                    }
                } else {
                    if let indexEnd = strCompare.index(of: ")") {
                        myString = "\(strCompare[indexEnd...])"
                    }
                }
            }
        }
        print("functionWindowOpen = \(functionWindowOpen)")
        if functionWindowOpen.count > 0 {
            let script = "function test() {\(functionWindowOpen)} test()"
            print("Script = \(script)")
            webView.evaluateJavaScript("function test() {\(functionWindowOpen)} test()") { (html, error) in
                if let error = error {
                    print ("[DebitViewController] Error \(error)")
                } else if let html = html {
                    print ("\(html)")
                    
                }
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print ("[DebitViewController] \(#function)")
        
        print ("[DebitViewController] Name : \(message.name)")
        print ("[DebitViewController] Body : \(message.body)")
        if message.name == "onReceiveStatemachineStateName" {
            stateMachineStateName = "\(message.body)"
        } else if message.name == "onReceiveStatemachineEventName" {
            stateMachineEventName = "\(message.body)"
        }
        
        if message.name == "onReceivedData" {
            
            
            if let jsonResult = message.body as? Dictionary<String, String> {
                
                // TODO need to verify with keyID
                let hmac        = jsonResult["hmac"]
                let txnResponse = jsonResult["txnResp"]
                let keyId       = jsonResult["KeyId"]
                
                let stageRespCode   = jsonResult["stageRespCode"]
                let actionCode      = jsonResult["actionCode"]
                
                print("[DebitViewController] hmac : \(hmac ?? "not_found")")
                print("[DebitViewController] txnResponse : \(txnResponse ?? "not_found")")
                print("[DebitViewController] keyId : \(keyId ?? "not_found" )")
                print("[DebitViewController] stageRespCode : \(stageRespCode ?? "not_found")")
                print("[DebitViewController] actionCode : \(actionCode ?? "not_found")")
                
                
            } else {
                
                print("Error")
            }
        }
        
    }
    
    // Page loading fail
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print ("[DebitViewController] \(#function) \(error)")
        
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print ("[DebitViewController] \(#function)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StringProtocol where Index == String.Index {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range.lowerBound)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: string, options: options) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
