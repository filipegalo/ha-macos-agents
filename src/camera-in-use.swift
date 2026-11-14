// Prints "on" if any camera is in use by any process, otherwise "off".
// Uses CoreMediaIO's "device is running somewhere" property, so it needs no
// camera permission and never opens the camera itself.
import CoreMediaIO

func address(_ selector: Int) -> CMIOObjectPropertyAddress {
    CMIOObjectPropertyAddress(
        mSelector: CMIOObjectPropertySelector(selector),
        mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
        mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain))
}

let system = CMIOObjectID(kCMIOObjectSystemObject)
var devicesAddress = address(kCMIOHardwarePropertyDevices)
var size: UInt32 = 0
guard CMIOObjectGetPropertyDataSize(system, &devicesAddress, 0, nil, &size) == 0 else {
    FileHandle.standardError.write("cannot list cameras\n".data(using: .utf8)!)
    exit(1)
}

var devices = [CMIOObjectID](repeating: 0, count: Int(size) / MemoryLayout<CMIOObjectID>.size)
var used: UInt32 = 0
guard CMIOObjectGetPropertyData(system, &devicesAddress, 0, nil, size, &used, &devices) == 0 else {
    FileHandle.standardError.write("cannot list cameras\n".data(using: .utf8)!)
    exit(1)
}

var runningAddress = address(kCMIODevicePropertyDeviceIsRunningSomewhere)
let inUse = devices.contains { device in
    var running: UInt32 = 0
    var read: UInt32 = 0
    return CMIOObjectGetPropertyData(
        device, &runningAddress, 0, nil, UInt32(MemoryLayout<UInt32>.size), &read, &running) == 0
        && running != 0
}

print(inUse ? "on" : "off")
