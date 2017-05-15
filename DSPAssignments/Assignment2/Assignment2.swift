#!/usr/bin/env swift
import Foundation

extension Array
{
    func csvPrint()
    {
        for i in self
        {
            print(i, terminator: ", ")
        }
        print("")
    }
}

public enum DefileModes
{
    case read
    case write
    case append
}

public enum DefileError: Error
{
    case modeMismatch
    case writeFailure
    case null
}

public class Defile
{
    private var file: UnsafeMutablePointer<FILE>
    private var mode: DefileModes
    var endOfFile: Bool
    {
       return feof(file) == 0
    }

    /*
     Initializes file.
     
     path: The give path (or filename) to open the file in.
     
     mode: .read, .write or .append.
        *.read opens file for reading. If the file does not exist, the initializer fails.
        *.write opens file for writing. If the file does not exist, it will be created.
        *.append opens the file for appending more information to the end of the file. If the file does not exist, it will be created.
     
     bufferSize: If you are going to be streaming particularly long strings (i.e. >1024 UTF8 characters), you might want to increase this value. Otherwise, the string will be truncated to a maximum length of 1024.
    */
    public init?(_ path: String, mode: DefileModes)
    {
        var modeStr: String
        
        switch(mode)
        {
            case .read:
                modeStr = "r"
            case .write:
                modeStr = "w"
            case .append:
                modeStr = "a"
        }
        
        guard let file = fopen(path, modeStr)
        else
        {
            return nil
        }

        self.file = file        
        self.mode = mode
    }

    deinit
    {
        fclose(file)
    }
    
    /*
     Loads the rest of the file into a string. Proceeds to remove entire file from stream.
     */
    public func dumpString() throws -> String
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var string = ""
            
        var character = fgetc(file)
        
        while character != EOF
        {
            string += "\(UnicodeScalar(UInt32(character))!)"
            character = fgetc(file)
        }        
        
        return string        
    }
    
    /*
     Reads one line from file, removes it from stream.
     */
    public func readLine() throws -> String? 
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var string = ""
        
        var character = fgetc(file)
        
        while character != EOF &&  UInt8(character) != UInt8(ascii:"\n") 
        {
            (UInt8(character) != UInt8(ascii:"\r")) ? string += "\(UnicodeScalar(UInt32(character))!)" : ()
            character = fgetc(file)
        }
        
        if (string == "")
        {
            return nil
        }
        
        return string
    }
    
    /*
     Reads one string from file, removes it (and any preceding whitespace) from stream.
     */
    public func readString() throws -> String?
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var string = ""
        
        var character = fgetc(file)

        while UInt8(character) == UInt8(ascii:"\n") || UInt8(character) == UInt8(ascii:"\r") || UInt8(character) == UInt8(ascii:" ") || UInt8(character) == UInt8(ascii:"\t")
        {
            character = fgetc(file)
        }
        
        while character != EOF && UInt8(character) != UInt8(ascii:"\n") && UInt8(character) != UInt8(ascii:"\r") && UInt8(character) != UInt8(ascii:" ")
        {
            string += "\(UnicodeScalar(UInt32(character))!)"
            character = fgetc(file)
        }
        
        if (string == "")
        {
            return nil
        }
        
        return string
    }

    /*
     Loads the rest of the file into a string. Proceeds to remove entire file from stream.
     */
    public func dumpBytes() throws -> [UInt8]
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var bytes = [UInt8]()
            
        var character = fgetc(file)
        
        while character != EOF
        {
            bytes.append(UInt8(character))
            character = fgetc(file)
        }

        return bytes        
    }

    /*
     Reads binary data from file, removes it from stream.
     */
    public func readBytes(count: Int) throws -> [UInt8]?
    {
        if mode != .read
        {
            throw DefileError.modeMismatch
        }

        var bytes = [UInt8]()
        var character: Int32 = 0
        for _ in 0..<count
        {
            fread(&character, 1, 1, file);
            if character == EOF
            {
                return nil
            }
            bytes.append(UInt8(character & 0xFF))
        }

        return bytes
    }
    
    /*
     Writes binary data to file.
    */
    public func write(bytes: [UInt8]) throws
    {
        if mode != .write
        {
            throw DefileError.modeMismatch
        }

        for byte in bytes
        {
            if (fputc(Int32(byte), file) == EOF)
            {
                throw DefileError.writeFailure
            }
        }
    }

    /*
     Appends binary data to file.
    */
    public func append(bytes: [UInt8]) throws
    {
        if mode != .append
        {
            throw DefileError.modeMismatch
        }

        for byte in bytes
        {
            if (fputc(Int32(byte), file) == EOF)
            {
                throw DefileError.writeFailure
            }
        }
    }
}

func concatenate(bytes: [UInt8], littleEndian: Bool = true) -> UInt
{
    var element: UInt = 0

    if littleEndian
    {
        for (i, byte) in bytes.enumerated()
        {
            element = element | (UInt(byte) << UInt(8 * i))
        }
    }
    else
    {
        let order = bytes.count - 1
        for (i, byte) in bytes.enumerated()
        {
            element = element | (UInt(byte) << UInt(8 * (order - i)))
        }
    }

    return element
}

func signExtend(_ value: UInt, bits: Int) -> UInt
{
    var mutableValue = value
    let uBits = UInt(bits)
    if (mutableValue & (1 << (uBits - 1))) != 0
    {
        mutableValue = ((~(0) >> uBits) << uBits) | value
    }

    return mutableValue
}

func discreteFourierTransform(samples: [Int]) -> (real: [Int], imaginary: [Int])
{
    var real = [Int]()
    var imaginary = [Int]()

    for (m, _) in samples.enumerated()
    {
        var realc: Double = 0
        var imaginaryc: Double = 0
        for (n, sample) in samples.enumerated()
        {
            realc += Double(sample) * cos((2 * Double.pi * Double(n) * Double(m)) / Double(samples.count))
            imaginaryc -= Double(sample) * sin((2 * Double.pi * Double(n) * Double(m)) / Double(samples.count))
        }
        real.append(Int(realc))
        imaginary.append(Int(imaginaryc))
    }

    return (real, imaginary)
}

func inverseDiscreteFourierTransform(real: [Int], imaginary: [Int]) -> (real: [Int], imaginary: [Int])
{
    var realTime = [Int]()
    var imaginaryTime = [Int]()

    for (n, _) in real.enumerated()
    {
        var realc: Double = 0
        var imaginaryc: Double = 0
        for (m, _) in imaginary.enumerated()
        {
            realc += Double(real[m]) * cos((2 * Double.pi * Double(n) * Double(m)) / Double(real.count))
            imaginaryc += Double(real[m]) * sin((2 * Double.pi * Double(n) * Double(m)) / Double(real.count))
            imaginaryc += Double(imaginary[m]) * cos((2 * Double.pi * Double(n) * Double(m)) / Double(imaginary.count))
            realc -= Double(imaginary[m]) * sin((2 * Double.pi * Double(n) * Double(m)) / Double(imaginary.count)) //j^2 == -1 
        }
        realTime.append(Int(realc / Double(real.count)))
        imaginaryTime.append(Int(imaginaryc / Double(imaginary.count)))
    }

    return (realTime, imaginaryTime)
}

func polarize(real: [Int], imaginary: [Int]) -> (magnitude: [Int], phase: [Int])
{
    var magnitude = [Int]()
    var phase = [Int]()
    for i in 0..<(real.count)
    {
        magnitude.append(Int(sqrt(pow(Double(real[i]), 2) + pow(Double(imaginary[i]), 2))))
        phase.append(Int(atan(Double(imaginary[i]) / Double(real[i])) * 180 / Double.pi))
    }

    return (magnitude, phase)
}

func function(_ n: Int) -> Int
{
    return Int((sin(2 * Double.pi * Double(n) / 40) + (2 * sin(2 * Double.pi * Double(n) / 16))) * exp(pow(-((Double(n) - 128) / 64), 2)))
}

var scalars = [Int]()
var samples = [Int]()
for i in 0..<256
{
    scalars.append(i)
    samples.append(function(i))
}

scalars.csvPrint()
samples.csvPrint()

print("")

var dft256 = discreteFourierTransform(samples: samples)
var dft256polar = polarize(real: dft256.real, imaginary: dft256.imaginary)
scalars.csvPrint()
dft256.real.csvPrint()
dft256.imaginary.csvPrint()
dft256polar.magnitude.csvPrint()
dft256polar.phase.csvPrint()

print("")

var dft128 = discreteFourierTransform(samples: Array(samples[0..<128]))
var dft128polar = polarize(real: dft128.real, imaginary: dft128.imaginary)
Array(scalars[0..<128]).csvPrint()
dft128.real.csvPrint()
dft128.imaginary.csvPrint()
dft128polar.magnitude.csvPrint()
dft128polar.phase.csvPrint()

print("")

var idft256 = inverseDiscreteFourierTransform(real: dft256.real, imaginary: dft256.imaginary)
scalars.csvPrint()
idft256.real.csvPrint() //Imaginary part disappears anyway

print("")

guard let waveform = Defile("Sample.wav", mode: .read)
else
{
    print("Failed to open sample file.")
    exit(66)
}
print("Loading waveform...")
var bytes = try! waveform.dumpBytes()
var size = Int(concatenate(bytes: Array(bytes[40..<44])))
samples = [Int]()
for i in 0..<(size - 1)
{
    if i % 2 == 0
    {
        samples.append(Int(bitPattern:signExtend(concatenate(bytes: Array(bytes[(44 + i)...(45 + i)])), bits: 16)))
    }
}
print("Starting discrete fourier transform...")
dft256 = discreteFourierTransform(samples: samples)
print("Starting inverse discrete fourier transform...")
idft256 = inverseDiscreteFourierTransform(real: dft256.real, imaginary: dft256.imaginary)
for i in 0..<(size - 1)
{
    if i % 2 == 0
    {
        bytes[44 + i] = UInt8(truncatingBitPattern: (idft256.real[i / 2]) & 0xFF)
        bytes[45 + i] = UInt8(truncatingBitPattern: (idft256.real[i / 2] >> 8) & 0xFF)
    }
}
guard let reclaimed = Defile("Reclaimed.wav", mode: .write)
else
{
    print("Failed to open output file for writing.")
    exit(73)
}
print("Writing reclaimed waveform...")
try! reclaimed.write(bytes: bytes)