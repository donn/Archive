#!/usr/bin/env swift

// DSPKit
//
// Some Swift functions for Digital Signal Processing

import Foundation

extension Array
{
    var csv: String
    {
        var string = ""
        for i in self
        {
            string += "\(i), "
        }
        string += "\n"
        return string
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

func fastFourierTransform(samples: [Int]) -> (real: [Int], imaginary: [Int])
{
    var real = [Int]()
    var imaginary = [Int]()
    
    for (m, _) in samples.enumerated()
    {
        var realc: Double = 0
        var imaginaryc: Double = 0
        
        var reald: Double = 0
        var imaginaryd: Double = 0
        
        let oddExtractCosine = cos((2 * Double.pi * Double(m)) / Double(samples.count))
        let oddExtractSine = -sin((2 * Double.pi * Double(m)) / Double(samples.count))
        
        for n in 0...(samples.count / 2 - 1)
        {
            let even = samples[n << 1]
            let odd = samples[(n << 1) + 1]
            let cosineComponent = cos((4 * Double.pi * Double(n) * Double(m)) / Double(samples.count))
            let sineComponent = -sin((4 * Double.pi * Double(n) * Double(m)) / Double(samples.count))
            
            realc += Double(even) * cosineComponent
            imaginaryc += Double(even) * sineComponent
            
            reald += Double(odd) * cosineComponent
            imaginaryd += Double(odd) * sineComponent
        }
        
        real.append(Int(realc + (reald * oddExtractCosine) - (imaginaryd * oddExtractSine)))
        imaginary.append(Int(imaginaryc + (reald * oddExtractSine) + (imaginaryd * oddExtractCosine)))
    }
    
    return (real, imaginary)
}

//Duplication rationale: branch for windowing would otherwise affect timing of FFT, comparison would become unfair
func windowedFastFourierTransform(samples: [Int], window: (_ n: Int, _ N: Int) -> Double) -> (real: [Int], imaginary: [Int])
{
    var real = [Int]()
    var imaginary = [Int]()
    
    for (m, _) in samples.enumerated()
    {
        var realc: Double = 0
        var imaginaryc: Double = 0
        
        var reald: Double = 0
        var imaginaryd: Double = 0
        
        let oddExtractCosine = cos((2 * Double.pi * Double(m)) / Double(samples.count))
        let oddExtractSine = -sin((2 * Double.pi * Double(m)) / Double(samples.count))
        
        for n in 0...(samples.count / 2 - 1)
        {
            let even = samples[n << 1]
            let odd = samples[(n << 1) + 1]
            let cosineComponent = cos((4 * Double.pi * Double(n) * Double(m)) / Double(samples.count))
            let sineComponent = -sin((4 * Double.pi * Double(n) * Double(m)) / Double(samples.count))
            
            realc += Double(even) * cosineComponent * window(n, samples.count)
            imaginaryc += Double(even) * sineComponent * window(n, samples.count)
            
            reald += Double(odd) * cosineComponent * window(n + 1, samples.count)
            imaginaryd += Double(odd) * sineComponent * window(n + 1, samples.count)
        }
        
        real.append(Int(realc + (reald * oddExtractCosine) - (imaginaryd * oddExtractSine)))
        imaginary.append(Int(imaginaryc + (reald * oddExtractSine) + (imaginaryd * oddExtractCosine)))
    }
    
    return (real, imaginary)
}

func magnitude(real: [Int], imaginary: [Int]) -> [Int]
{
    var magnitude = [Int]()
    for i in 0..<(real.count)
    {
        magnitude.append(Int(sqrt(pow(Double(real[i]), 2) + pow(Double(imaginary[i]), 2))))
    }
    
    return magnitude
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