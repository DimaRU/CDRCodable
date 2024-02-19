# CDRCodable

![Build](https://github.com/DimaRU/CDRCodable/workflows/Build/badge.svg) 

A [OMG Common Data Representation (CDR)](https://www.omg.org/cgi-bin/doc?formal/02-06-51) (PLAIN_CDR) encoder and decoder for Swift `Codable` types.

Now can be used with [FastRTPSSwift](https://github.com/DimaRU/FastRTPSSwift), a Swift wrapper for eProsima [FastDDS](https://github.com/eProsima/Fast-DDS) library.

Use [msg2swift](https://github.com/DimaRU/Msg2swift) to automatically generate Swift models from ROS `.msg` files.

## Requirements

- Swift 5.8+

## Usage

### Encoding Messages

```swift
import CDRCodable

let encoder = CDREncoder()
let value = try! encoder.encode("hello")
// Data([6, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0, 0, 0])
```

### Decoding Messages

```swift
import CDRCodable

let decoder = CDRDecoder()
let data = Data([3, 0, 0, 0, 1, 0, 2, 0, 3, 0])
let value = try! decoder.decode([Int16].self, from: data)
// [1, 2, 3]
```

## Installation

### Swift Package Manager

Add the CDRCodable package to your target dependencies in `Package.swift`:

```swift
.package(url: "https://github.com/DimaRU/CDRCodable", from: "1.0.0"),
```


## Supported IDL/ROS types

### 1. Primitive types

The following table shows the basic IDL types supported by CDRCodable and how they are mapped to Swift and C++11.

| Swift   | C++11       | ROS     | IDL                |
| ------- | ----------- | ------- | ------------------ |
| Int8    | char        | int8    | char               |
| UInt8   | uint8\_t    | uint8   | octet              |
| Int16   | int16\_t    | int16   | short              |
| UInt16  | uint16\_t   | uint16  | unsigned short     |
| Int32   | int32\_t    | int32   | long               |
| UInt32  | uint32\_t   | uint32  | unsigned long      |
| Int64   | int64\_t    | int64   | long long          |
| UInt64  | uint64\_t   | uint64  | unsigned long long |
| Float   | float       | float32 | float              |
| Double  | double      | float64 | double             |
| Bool    | bool        | bool    | boolean            |
| String  | std::string | string  | string             |

### 2. Arrays
Starting from version 1.1.1 CDRCodable supports fixed-size arrays. The high 16 bits of CodingKeys are used for this purpose. Declare CodingKeys as Int and write in the high 16 bits the required array size and property must be declared as Array. The lower 16 bits are not used.  Note: Be careful when numbering CodingKeys! Use [msg2swift](https://github.com/DimaRU/Msg2swift) to create CodingKeys automatically.
Sample CodingKeys declaration for [sensor_msgs/CameraInfo](https://docs.ros.org/en/noetic/api/sensor_msgs/html/msg/CameraInfo.html):

```swift
//
// CameraInfo.swift
//
// This file was generated from ROS message file using msg2swift.
//

struct CameraInfo: Codable {
    let header: Header
    let height: UInt32
    let width: UInt32
    let distortionModel: String
    let d: [Double]
    let k: [Double]
    let r: [Double]
    let p: [Double]
    let binningX: UInt32
    let binningY: UInt32
    let roi: RegionOfInterest

    enum CodingKeys: Int, CodingKey {
        case header = 1
        case height = 2
        case width = 3
        case distortionModel = 4
        case d = 5
        case k = 0x90006
        case r = 0x90007
        case p = 0xc0008
        case binningX = 9
        case binningY = 10
        case roi = 11
    }
}
```

### 3. Sequences
CDRCodable supports sequences, which map between Swift Array and C++ std::vector container. The following table represents how the map between Swift, C++11 and IDL and is handled.

| Swift            | C++11                     | IDL                           |
| ---------------- | ------------------------- | ----------------------------- |
| `Data`           | `std::vector<uint8_t>`    | `sequence<octet>`              |
| `Array<Int8>`    | `std::vector<char>`       | `sequence<char>`               |
| `Array<UInt8>`   | `std::vector<uint8_t>`    | `sequence<octet>`              |
| `Array<Int16>`   | `std::vector<int16_t>`    | `sequence<short>`              |
| `Array<UInt16>`  | `std::vector<uint16_t>`   | `sequence<unsigned short>`     |
| `Array<Int32>`   | `std::vector<int32_t>`    | `sequence<long>`               |
| `Array<UInt32>`  | `std::vector<uint32_t>`   | `sequence<unsigned long>`      |
| `Array<Int64>`   | `std::vector<int64_t>`    | `sequence<long long>`          |
| `Array<UInt64>`  | `std::vector<uint64_t>`   | `sequence<unsigned long long>` |
| `Array<Float>`   | `std::vector<float>`      | `sequence<float>`              |
| `Array<Double>`  | `std::vector<double>`     | `sequence<double>`             |
| `Array<Bool>`    | `std::vector<bool>`       | `sequence<boolean>`            |
| `Array<String>`  | `std::vector<std::string>`| `sequence<string>`             |



### 4. Enumerations

| Swift          | IDL    |
|:-------------- |:-------|
| enum e: Int32  | enum e |                       

Example:
IDL definition:

```IDL
enum ESubsystemState
{
    UNKNOWN         = 0,
    INITIALIZED     = 1,
    POSTING         = 2,
    ACTIVE          = 3,
    STANDBY         = 4,
    RECOVERY        = 5,
    DISABLED        = 6
};
```
Swift:

```Swift
enum ESubsystemState: Int32, Codable {
    case unknown         = 0
    case initialized     = 1
    case posting         = 2
    case active          = 3
    case standby         = 4
    case recovery        = 5
    case disabled        = 6
}
```

### 5. Union

Union type is not supported by CDRCodable directly and needed custom coding.
Example:

IDL definition:

```IDL
union ControlUnion switch (unsigned long)
{
    case CONTROL_TYPE_S8:
        char value_int8;
    case CONTROL_TYPE_S16:
        short value_int16;
    case CONTROL_TYPE_S32:
        long value_int32;
    case CONTROL_TYPE_S64:
        long long value_int64;
    case CONTROL_TYPE_U8:
        octet value_uint8;
    case CONTROL_TYPE_U16:
        unsigned short value_uint16;
    case CONTROL_TYPE_U32:
        unsigned long value_uint32;
    case CONTROL_TYPE_U64:
        unsigned long long value_uint64;
    case CONTROL_TYPE_BITMASK:
        unsigned long value_bitmask;
    case CONTROL_TYPE_BUTTON:
        boolean value_button;
    case CONTROL_TYPE_BOOLEAN:
        boolean value_boolean;
    case CONTROL_TYPE_STRING:
        string<128> value_string;
    case CONTROL_TYPE_STRING_MENU:
        unsigned long value_string_menu;
    case CONTROL_TYPE_INT_MENU:
        unsigned long value_int_menu;
};
```
Swift

```Swift
enum ControlUnion: UInt32, Codable {
    case S8(value: Int8) = 0
    case S16(value: Int16)
    case S32(value: Int32)
    case S64(value: Int64)
    case U8(value: UInt8)
    case U16(value: UInt16)
    case U32(value: UInt32)
    case U64(value: UInt64)
    case Bitmask(bitmask: UInt32)
    case Button(button: Bool)
    case Boolean(value: Bool)
    case StringValue(value: String)
    case StringMenu(stringMenu: UInt32)
    case IntMenu(intMenu: UInt32)
    
    init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
        let selector = try container.decode(UInt32.self)
        switch selector {
            case 0:
                let value = try container.decode(Int8.self)
                self = .S8(value: value)
            case 1:
                let value = try container.decode(Int16.self)
                self = .S16(value: value)
            case 2:
                let value = try container.decode(Int32.self)
                self = .S32(value: value)
            case 3:
                let value = try container.decode(Int64.self)
                self = .S64(value: value)
            case 4:
                let value = try container.decode(UInt8.self)
                self = .U8(value: value)
            case 5:
                let value = try container.decode(UInt16.self)
                self = .U16(value: value)
            case 6:
                let value = try container.decode(UInt32.self)
                self = .U32(value: value)
            case 7:
                let value = try container.decode(UInt64.self)
                self = .U64(value: value)
            case 8:
                let value = try container.decode(UInt32.self)
                self = .Bitmask(bitmask: value)
            case 9:
                let value = try container.decode(Bool.self)
                self = .Button(button: value)
            case 10:
                let value = try container.decode(Bool.self)
                self = .Boolean(value: value)
            case 11:
                let value = try container.decode(String.self)
                self = .StringValue(value: value)
            case 12:
                let value = try container.decode(UInt32.self)
                self = .StringMenu(stringMenu: value)
            case 13:
                let value = try container.decode(UInt32.self)
                self = .IntMenu(intMenu: value)
            default:
                let error = DecodingError.dataCorruptedError(in: container, debugDescription: "Illegal union selector \(selector)")
                throw error
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
        switch self {
        case .S8(value: let value): try container.encode(value)
        case .S16(value: let value): try container.encode(value)
        case .S32(value: let value): try container.encode(value)
        case .S64(value: let value): try container.encode(value)
        case .U8(value: let value): try container.encode(value)
        case .U16(value: let value): try container.encode(value)
        case .U32(value: let value): try container.encode(value)
        case .U64(value: let value): try container.encode(value)
        case .Bitmask(bitmask: let bitmask): try container.encode(bitmask)
        case .Button(button: let button): try container.encode(button)
        case .Boolean(value: let value): try container.encode(value)
        case .StringValue(value: let value): try container.encode(value)
        case .StringMenu(stringMenu: let stringMenu): try container.encode(stringMenu)
        case .IntMenu(intMenu: let intMenu): try container.encode(intMenu)
        }
    }
}

```

### 6. Struct
`struct` may be coded as Swift `struct` or `class`.
Example:

IDL definition:

```IDL
struct ControlTarget
{
    string id;
    
    float pitch;
    float yaw;
    float thrust;
    float lift;
};
```

```Swift
struct ControlTarget: Codable
{
    let id: String

    let pitch: Float
    let yaw: Float
    let thrust: Float
    let lift: Float
}
```

## License

MIT
