# CDRCodable

![Build](https://github.com/DimaRU/CDRCodable/workflows/Build/badge.svg) 

A [OMG Common Data Representation (CDR)](https://msgpack.org/https://www.omg.org/spec/DDS-XTypes/) encoder and decoder for Swift `Codable` types.

Now can be used with [FastRTPSBridge](https://github.com/DimaRU/FastRTPSBridge), a Swift wrapper for eProsima [FastDDS](https://github.com/eProsima/Fast-DDS) library.

## Requirements

- Swift 4.2+

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

Add the MessagePack package to your target dependencies in `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(
        url: "https://github.com/DimaRU/CDRCodable",
        from: "1.0.0"
    ),
  ]
)
```

Then run the `swift build` command to build your project.

## Supported IDL types

### 1. Primitive types

The following table shows the basic IDL types supported by CDRCodable and how they are mapped to Swift and C++11.

| Swift   | C++11       | IDL                |
| ------- | ----------- | ------------------ |
| Int8    | char        | char               |
| UInt8   | uint8\_t    | octet              |
| Int16   | int16\_t    | short              |
| UInt16  | uint16\_t   | unsigned short     |
| Int32   | int32\_t    | long               |
| UInt32  | uint32\_t   | unsigned long      |
| Int64   | int64\_t    | long long          |
| UInt64  | uint64\_t   | unsigned long long |
| Float   | float       | float              |
| Double  | double      | double             |
| Float80 | long double | long double        |
| Bool    | bool        | boolean            |
| String  | std::string | string             |

### 2. Arrays
Static size arrays is not supported by CDRCodable directly, needed custom coding.

### 3. Sequences
CDRCodable supports sequences, which map between Swift Array and C++ std::vector container. The following table represents how the map between Swift, C++11 and IDL and is handled.

| Swift           | C++11                     | IDL                           |
| --------------- | ------------------------- | ----------------------------- |
| `Array<Int8>`    | `std::vector<char>`       | `sequence<char>`               |
| `Array<UInt8>` or `Data` | `std::vector<uint8_t>`    | `sequence<octet>`              |
| `Array<Int16>`   | `std::vector<int16_t>`    | `sequence<short>`              |
| `Array<UInt16>`  | `std::vector<uint16_t>`   | `sequence<unsigned short>`     |
| `Array<Int32>`   | `std::vector<int32_t>`    | `sequence<long>`               |
| `Array<UInt32>`  | `std::vector<uint32_t>`   | `sequence<unsigned long>`      |
| `Array<Int64>`   | `std::vector<int64_t>`    | `sequence<long long>`          |
| `Array<UInt64>`  | `std::vector<uint64_t>`   | `sequence<unsigned long long>` |
| `Array<Float>`   | `std::vector<float>`      | `sequence<float>`              |
| `Array<Double>`  | `std::vector<double>`     | `sequence<double>`             |
| `Array<Float80>` | `std::vector<long double>`| `sequence<long double>`        |
| `Array<Bool>`    | `std::vector<bool>`       | `sequence<boolean>`            |
| `Array<String>`  | `std::vector<std::string>`| `sequence<string>`             |


| Array\<Int8>    | std::vector\<char>        | sequence\<char>               |
| Array\<UInt8> or Data | std::vector\<uint8\_t>    | sequence\<octet>              |
| Array\<Int16>   | std::vector\<int16\_t>    | sequence\<short>              |
| Array\<UInt16>  | std::vector\<uint16\_t>   | sequence\<unsigned short>     |
| Array\<Int32>   | std::vector\<int32\_t>    | sequence\<long>               |
| Array\<UInt32>  | std::vector\<uint32\_t>   | sequence\<unsigned long>      |
| Array\<Int64>   | std::vector\<int64\_t>    | sequence\<long long>          |
| Array\<UInt64>  | std::vector\<uint64\_t>   | sequence\<unsigned long long> |
| Array\<Float>   | std::vector\<float>       | sequence\<float>              |
| Array\<Double>  | std::vector\<double>      | sequence\<double>             |
| Array\<Float80> | std::vector\<long double> | sequence\<long double>        |
| Array\<Bool>    | std::vector\<bool>        | sequence\<boolean>            |
| Array\<String>  | std::vector\<std::string> | sequence\<string>             |

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

Union type is not supported by CDRCodable directly, needed custom coding.
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
enum ControlUnion: Codable {
    case S8(value: Int8)
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
        var container = try decoder.unkeyedContainer()
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
        let selector: UInt32
        switch self {
        case .S8 : selector = 0
        case .S16 : selector = 1
        case .S32 : selector = 2
        case .S64 : selector = 3
        case .U8 : selector = 4
        case .U16 : selector = 5
        case .U32 : selector = 6
        case .U64 : selector = 7
        case .Bitmask : selector = 8
        case .Button : selector = 9
        case .Boolean : selector = 10
        case .StringValue : selector = 11
        case .StringMenu : selector = 12
        case .IntMenu : selector = 13
        }
        try container.encode(selector)
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
struct TridentControlTarget
{
    string id;
    
    float pitch;
    float yaw;
    float thrust;
    float lift;
};
```

```Swift
struct TridentControlTarget: Codable
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
