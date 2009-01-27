
#import modules required by application
import objc
import Foundation
import AppKit

from PyObjCTools import AppHelper

# import modules containing classes required to start application and load MainMenu.nib
import VelocitoolAppDelegate

# pass control to AppKit
AppHelper.runEventLoop()
