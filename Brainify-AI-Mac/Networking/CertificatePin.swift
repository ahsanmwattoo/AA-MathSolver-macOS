//
//  PinnedCertificate.swift
//  AIChatbot
//
//  Created by Macbook Pro on 22/04/2025.
//

import Cocoa
import CryptoKit

class CertificatePin: NSObject, URLSessionDataDelegate {
    
    var requestStatus: Bool = false
    var onData: ((String) -> Void)?
    var onError: ((ResponseError) -> Void)?
    var onStreamEnd: (() -> Void)?
    var onUploadProgress: ((Double) -> Void)?
    
    private var receivedData = Data()
    var onBinaryData: ((Data) -> Void)?
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let certChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let leafCert = certChain.first else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let publicKey = SecCertificateCopyKey(leafCert),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        
        // Hash and compare
        let hash = sha256Base64SPKI(publicKeyData: publicKeyData)
        if hash == AppConstants.hash {
            requestStatus = true
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            
        } else {
            requestStatus = false
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didSendBodyData bytesSent: Int64,
                           totalBytesSent: Int64,
                           totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        onUploadProgress?(progress)
    }
    
    func sha256Base64SPKI(publicKeyData: Data) -> String {
        // Use EC header — OpenAI uses EC P-256
        let ecAsn1Header: [UInt8] = [
            0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2A, 0x86,
            0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x08, 0x2A,
            0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07, 0x03,
            0x42, 0x00
        ]
        let spkiData = Data(ecAsn1Header) + publicKeyData
        let hash = SHA256.hash(data: spkiData)
        return "sha256//" + Data(hash).base64EncodedString()
    }
    
    func sha256Base64(data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return "sha256//" + Data(hash).base64EncodedString()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            if error.localizedDescription.contains("Internet Connection") {
                onError?(.internet)
            } else if error.localizedDescription.contains("cancelled") {
                if requestStatus {
                    onError?(.cancelled)
                } else {
                    onError?(.proxy)
                }
            } else {
                onError?(.internet)
            }
        } else {
            if !receivedData.isEmpty {
                onBinaryData?(receivedData)
                receivedData = Data()
            }
            onStreamEnd?()
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            if json.keys.contains("error") {
                if let errorDict = json["error"] as? [String: Any],
                   let type = errorDict["type"] as? String {
                    if type == "invalid_request_error" {
                        onError?(.proxy)
                    }
                }else {
                    if let status = json["status"] as? String {
                        if status != "completed" {
                            onError?(.normal)
                        }
                    }else{
                        onError?(.normal)
                    }
                }
            } else {
                if let line = String(data: data, encoding: .utf8) {
                    onData?(line)
                }
            }
        }else{
            if let line = String(data: data, encoding: .utf8) {
                onData?(line)
            }
        }
    }
}

enum ResponseError: Error {
    case proxy
    case internet
    case normal
    case cancelled
}
