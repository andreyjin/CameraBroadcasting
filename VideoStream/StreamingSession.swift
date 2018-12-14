
import Foundation
import CocoaAsyncSocket

class StreamingSession {

    fileprivate var client: GCDAsyncSocket
    fileprivate var headersSent = false
    fileprivate var dataStack = Queue<Data>(maxCapacity: 1)
    fileprivate var queue: DispatchQueue
    fileprivate let footersData = ["", ""].joined(separator: "\r\n").data(using: String.Encoding.utf8)

    var id: Int
    var connected = true
    var dataToSend: Data? {
        didSet {
            guard let dataToSend = self.dataToSend else { return }

            self.dataStack.enqueue(dataToSend)
        }
    }

    // MARK: - Lifecycle

    init (id: Int, client: GCDAsyncSocket, queue: DispatchQueue) {
        print("Creating client [#\(id)]")

        self.id = id
        self.client = client
        self.queue = queue
    }

    // MARK: - Methods

    func close() {
        print("Closing client [#\(self.id)]")

        self.connected = false
    }

    func startStreaming() {
        self.queue.async(execute: { [unowned self] in
            while self.connected {

                if !self.headersSent {
                    print("Sending headers [#\(self.id)]")
//                    let headers = [
//                        "HTTP/1.0 200 OK",
//                        "Max-age: 0",
//                        "Expires: 0",
//                        "Connection: keep-alive",
//                        "Access-Control-Allow-Headers:*",
//                        "Access-Control-Allow-Methods:GET, HEAD, OPTIONS",
//                        "Access-Control-Allow-Origin:*",
//                        "Access-Control-Expose-Headers:Cache-Control,Content-Encoding",
//                        "Cache-Control:no-store,must-revalidate",
//                        "Content-type: application/x-mpegURL",
//                        "Pragma: no-cache"
//                    ]
                    let headers = [
                        "HTTP/1.0 200 OK",
                        "Connection: keep-alive",
                        "Max-age: 0",
                        "Expires: 0",
                        "Cache-Control: max-age=0, no-cache, no-store",
                        "Access-Control-Allow-Origin: *",
                        "Access-Control-Allow-Headers: accept,content-type",
                        "Access-Control-Allow-Methods: GET, HEAD, OPTIONS",
                        "Access-Control-expose-headers: Cache-Control,Content-Encoding",
                        "Pragma: no-cache",
                        "Content-type: application/x-mpegurl",
                        ""
                    ]

                    guard let headersData = headers.joined(separator: "\r\n").data(using: String.Encoding.utf8) else {
                        print("Could not make headers data [#\(self.id)]")
                        return
                    }

                    self.headersSent = true
                    self.client.write(headersData, withTimeout: -1, tag: 0)
                } else {
//                    print("Using images...")
                    if self.client.connectedPort.hashValue == 0 {
                        self.close()
                        print("Dropping client [#\(self.id)]")
                    }

                    if let data = self.dataStack.dequeue() {
                        let frameHeaders = [
                            "",
                            "--0123456789876543210",
                            "Content-Type: image/jpeg",
                            "Content-Length: \(data.count)",
                            "Access-Control-Allow-Origin: *",
                            "Access-Control-Allow-Headers: accept,content-type",
                            "Access-Control-Allow-Methods: GET, HEAD, OPTIONS",
                            "Access-Control-expose-headers: *",
                            "",	
                            ""
                        ]

                        guard let frameHeadersData = frameHeaders.joined(separator: "\r\n").data(using: String.Encoding.utf8) else {
                            print("Could not make frame headers data [#\(self.id)]")
                            return
                        }

                        self.client.write(frameHeadersData, withTimeout: -1, tag: 0)
                        self.client.write(data, withTimeout: -1, tag: 0)
                        self.client.write(self.footersData!, withTimeout: -1, tag: self.id)
                    }
                }
            }
        })
    }
}
