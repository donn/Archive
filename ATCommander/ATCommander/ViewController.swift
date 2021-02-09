import Cocoa
import SwiftSerial

extension SerialPort {
    func readUntilEmpty() throws -> String {
        var data = [UInt8]()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        defer {
            buffer.deallocate()
        }
        var read = try readBytes(into: buffer, size: 1)
        print(read)
        while (read  > 0) {
            data.append(buffer[0])
            read = try readBytes(into: buffer, size: 1)
        }
        return String(data: Data(data), encoding: .utf8)!
    }
}

class ViewController: NSViewController {
    @IBOutlet weak var list: NSPopUpButton!
    
    @IBOutlet weak var command: NSTextField!
    @IBOutlet weak var send: NSButton!
    
    @IBOutlet weak var reply: NSTextField!
    
    @IBAction func selectionChanged(_ sender: NSPopUpButton) {
        send.isEnabled = list.indexOfSelectedItem > 0
    }
    
    @IBAction func onClick(_ sender: NSButtonCell) {
        let port = "/dev/\(list.itemTitles[list.indexOfSelectedItem])"
        
        let serialPort = SerialPort(path: port)
        defer {
            serialPort.closePort()
            NSLog("Closed port…")
        }
        
        do {
            NSLog("Opening…")
            try serialPort.openPort()
            
            serialPort.setSettings(
                receiveRate: .baud9600,
                transmitRate: .baud9600,
                minimumBytesToRead: 0,
                timeout: 1
            )
            
            NSLog("Sending…")
            let _ = try serialPort.writeString(command.stringValue)

            NSLog("Waiting on bytes…");
            reply.stringValue = try serialPort.readUntilEmpty()
            print(reply.stringValue)
            
        } catch {
            NSLog("Error: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager = FileManager.default
        send.isEnabled = false
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: "/dev").filter { $0.starts(with: "cu.")}
            list.addItems(withTitles: items)
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

