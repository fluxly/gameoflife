//
//  ViewController.swift
//  Fluxly2Looper2
//
//  Created by Shawn Wallace on 12/31/20.
//


import UIKit
import WebKit
import CoreBluetooth
import Foundation
import GCDWebServer

extension String {
   enum ExtendedEncoding {
       case hexadecimal
   }

   func data(using encoding:ExtendedEncoding) -> Data? {
       let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

       guard hexStr.count % 2 == 0 else { return nil }

       var newData = Data(capacity: hexStr.count/2)

       var indexIsEven = true
       for i in hexStr.indices {
           if indexIsEven {
               let byteRange = i...hexStr.index(after: i)
               guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
               newData.append(byte)
           }
           indexIsEven.toggle()
       }
       return newData
   }
}


class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler,
                      CBPeripheralDelegate, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    public var deviceServiceUUID = CBUUID.init(string: "0000fff0-0000-1000-8000-00805f9b34fb")
    public var writeCharacteristicUUID   = CBUUID.init(string: "0000fff3-0000-1000-8000-00805f9b34fb")
    public var readCharacteristicUUID   = CBUUID.init(string: "0000fff4-0000-1000-8000-00805f9b34fb")
    private var readCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?
    
    func setBluetoothConnectInfo(_ service : String, read : String, write : String) {
        deviceServiceUUID = CBUUID.init(string:service);
        writeCharacteristicUUID = CBUUID.init(string:write);
            readCharacteristicUUID = CBUUID.init(string:read);
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            startScan(0)
        }
        loadWebPage()
    }
    
    func startScan(_ n : Int) {
        print("Start scanning for slot ",  n)
        print("Central scanning for ", deviceServiceUUID);
        centralManager.scanForPeripherals(withServices: nil,
              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("Found it!")
        
        if ((peripheral.name?.contains("Splat")) != nil) {
            if (peripheral.name!.contains("Splat")) {
                // Splat == 010A020105060953706C6174
                // We've found it so stop scan
                self.centralManager.stopScan()

                // Copy the peripheral instance
                self.peripheral = peripheral
                self.peripheral.delegate = self

                // Connect!
                print("trying to connect!")
                self.centralManager.connect(self.peripheral, options: nil)
            }
        }
    }
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to a Splat")
            peripheral.discoverServices([deviceServiceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnect!")
        self.peripheral = nil
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == deviceServiceUUID {
                    print("splat service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics(
                        [writeCharacteristicUUID,
                         readCharacteristicUUID
                    ], for: service)
                    return
                }
            }
        }
    }
    
    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == writeCharacteristicUUID {
                    writeCharacteristic = characteristic
                    print("Write characteristic found")
                } else if characteristic.uuid == readCharacteristicUUID {
                    readCharacteristic = characteristic
                    print("Read characteristic found")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    }
    
    private func sendBytes( withCharacteristic characteristic: CBCharacteristic,
                            withValue hexString: String) {
        if peripheral != nil && characteristic.properties.contains(.writeWithoutResponse) {
            print(hexString.data(using: .utf8)!)
            peripheral.writeValue(hexString.data(using: .hexadecimal)!,
                                  for: characteristic, type: .withoutResponse)
        }
    }
    
    var webView: WKWebView!
    func webView(_ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void) {
        
        // Set the message as the UIAlertController message
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )

        // Add a confirmation action “OK”
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                // Call completionHandler
                completionHandler()
            }
        )
        alert.addAction(okAction)

        // Display the NSAlert
        present(alert, animated: true, completion: nil)
    }
    override func loadView() {
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true;
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        // inject JS to capture console.log output and send to iOS
        let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        // register the bridge script that listens for the output
        webView.configuration.userContentController.add(self, name: "logHandler")
        webView.configuration.userContentController.add(self, name: "bluetooth")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            print("LOG: \(message.body)")
        }
        if message.name == "bluetooth" {
            print("LOG: \(message.body)")
            if (peripheral != nil) {
                sendBytes(withCharacteristic: writeCharacteristic!,
                          withValue: "0020220F")
            }
           
            let script = "document.getElementById('hi-there').innerHTML = 'Hi there!';"
            webView.evaluateJavaScript(script) { (result, error) in
                if let result = result {
                    print("Label is updated with message: \(result)")
                } else if let error = error {
                    print("An error occurred: \(error)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        initWebServer()
        super.viewDidLoad()
        print("waiting for server")
        //while (webServer.serverURL == nil) {}
        
        print("Visit \(String(describing: webServer.serverURL)) in your web browser")
        

        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        
    }
    
    func loadWebPage() {
        print("Visit \(String(describing: webServer.serverURL)) in your web browser")
        //let url = URL(string:"http://10.0.1.5:8080/")!
        let url = webServer.serverURL!
        webView.load(URLRequest(url: url))
    }
    
    var webServer = GCDWebServer()
    
    func initWebServer() {

        let urlpath = Bundle.main.resourceURL!.appendingPathComponent("StreamingAssets/").path
   
        print(String(describing: urlpath))
        webServer.addGETHandler(forBasePath:"/", directoryPath:urlpath, indexFilename:"index.html", cacheAge:3600, allowRangeRequests:true);
        //
        webServer.start(withPort: 8080, bonjourName: nil)
        print("Starting server")
        print("Visit \(String(describing: webServer.serverURL)) in your web browser")
    }
}
