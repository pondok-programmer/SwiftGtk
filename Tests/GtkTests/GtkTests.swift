import XCTest
import CGtk
import Dispatch
@testable import Gtk
import Gdk

var cstring = strdup("Test")
var args = [cstring]
var numArgs: Int32 = args.withUnsafeMutableBufferPointer {
    var n = Int32(args.count)
    var argv = $0.baseAddress
    gtk_init(&n, &argv)
    return n
}

class GtkTests: XCTestCase {
    override class func setUp() {
        usleep(100000) // FIXME: ensure gtk is initialised
    }
    func testMajorVersion() { XCTAssertEqual(getMajorVersion(), gtk_get_major_version()) }
    func testMinorVersion() { XCTAssertEqual(getMinorVersion(), gtk_get_minor_version()) }
    func testMicroVersion() { XCTAssertEqual(getMicroVersion(), gtk_get_micro_version()) }
    func testInterfaceAge() { XCTAssertEqual(getInterfaceAge(), gtk_get_interface_age()) }
    func testBinaryAge()    { XCTAssertEqual(getBinaryAge(),    gtk_get_binary_age())    }

    /// test that we can run and quit an app
    func testApp() {
        let application: Application! = Application()
        XCTAssertNotNil(application)
        var appWasRunning = false
        var appDidStart = false
        let status = application.run(startupHandler: { _ in
            XCTAssertFalse(appDidStart)
            appDidStart = true
            XCTAssertFalse(appWasRunning)
        }, activationHandler: { app in
            appWasRunning = true
            app.quit()
        })
        XCTAssertEqual(status, 0)
        XCTAssertTrue(appWasRunning)
    }

    // test file chooser
    func testFileChooser() {
        XCTAssertNotNil(FileChooserDialog(firstText: "Cancel", secondText: "Okay").ptr)
    }

    // test native file chooser
    func testFileChooserNative() {
        XCTAssertNotNil(FileChooserNative(title: "Native", acceptLabel: "OK", cancelLabel: "Nope").ptr)
    }

    // test dialog convenience constructors
    func testDialog() {
        XCTAssertNotNil(Dialog(text: "Test").ptr)
        XCTAssertNotNil(Dialog(firstText: "OK", secondText: "Cancel").ptr)
        XCTAssertNotNil(Dialog(firstText: "OK", secondText: "Cancel", thirdText: "Review Windows").ptr)
    }

    // test message dialog convenience methods
    func testMessageDialog() {
        let dialog1 = MessageDialog(text: "A simple message dialog")
        dialog1.set(secondaryText: "Change secondary text")
        XCTAssertNotNil(dialog1.ptr)
        let dialog2 = MessageDialog(markup: "Dialog <b>with markup</b>", secondaryMarkup: "and secondary markup")
        dialog2.set(secondaryText: "Change secondary text")
        XCTAssertNotNil(dialog2.ptr)
    }

    // test Scrolled Window convenience methods
    func testScrolledWindow() {
        let vadj = Adjustment(value: 0, lower: 0, upper: 1, stepIncrement: 1, pageIncrement: 1, pageSize: 1)
        let window1 = ScrolledWindow(vAdjustment: nil)
        let window2 = ScrolledWindow(vAdjustment: vadj)
        XCTAssertNotNil(window1.ptr)
        XCTAssertNotNil(window2.ptr)
        XCTAssertEqual(window1.allocatedHeight, 1)
        XCTAssertEqual(window2.allocatedHeight, 1)
    }

    func testWidget() {
        let widget = Widget(UnsafeMutablePointer.allocate(capacity: 1))
        widget.onKey {
            let event = EventKeyRef($1)
            debugPrint(event._ptr.pointee.keyval)
        }
    }

    /// text text buffers
    func testTextBuffer() {
        guard let buffer = TextBuffer() else { XCTFail() ; return }
        let text = "Hello, world!\n"
        buffer.text = text
        XCTAssertEqual(buffer.text, text)
    }
}

extension GtkTests {
    static var allTests : [(String, (GtkTests) -> () throws -> Void)] {
        return [
            ("testApp",                 testApp),
            ("testDialog",              testDialog),
            ("testFileChooser",         testFileChooser),
            ("testFileChooserNative",   testFileChooserNative),
            ("testMessageDialog",       testMessageDialog),
            ("testTextBuffer",          testTextBuffer),
            ("testScrolledWindow",      testScrolledWindow),
            ("testMajorVersion",        testMajorVersion),
            ("testMinorVersion",        testMinorVersion),
            ("testMicroVersion",        testMicroVersion),
            ("testInterfaceAge",        testInterfaceAge),
            ("testBinaryAge",           testBinaryAge),
        ]
    }
}
