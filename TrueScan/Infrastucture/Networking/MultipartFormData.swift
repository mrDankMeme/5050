//  MultipartFormData.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation


struct MultipartFormData {
    struct FilePart {
        let name: String
        let filename: String
        let mimeType: String
        let data: Data
    }

    private let boundary: String = "----CB-\(UUID().uuidString)"
    var contentType: String { "multipart/form-data; boundary=\(boundary)" }

    func build(fields: [String: String?], files: [FilePart]) -> Data {
        var body = Data()

        for (k, v) in fields {
            guard let v = v else { continue }
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n")
            body.appendString("\(v)\r\n")
        }

        for f in files {
            body.appendString("--\(boundary)\r\n")
            body.appendString(
                "Content-Disposition: form-data; name=\"\(f.name)\"; filename=\"\(f.filename)\"\r\n"
            )
            body.appendString("Content-Type: \(f.mimeType)\r\n\r\n")
            body.append(f.data)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")
        return body
    }
}


private extension Data {
    mutating func appendString(_ s: String) {
        if let d = s.data(using: .utf8) {
            append(d)
        }
    }
}
