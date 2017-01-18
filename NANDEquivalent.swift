/*
	Illogical - NAND Equivalent
	
	That was my first Swift program. You can tell, really.

	This is a simple program that takes a logical proposition
	and outputs an (unoptimized) NAND equivalent. It was written
	as a project for a discrete mathematics course.

	It requires Swift 3.0 (I'd say or higher but that depends on whether
	they change something again), and is under the UNLICENSE.
*/
import Foundation

/*
 REPLACEMENT FUNCTIONS
 These functions take parameters then replace them with a NAND equivalent, encoded
 with replacements for (, ) and spaces as to not interfere with the operation of validate.
*/
func notToNand(_ rhs: String) -> String
{
    return "[\(rhs)$NAND$\(rhs)]"
}

func andToNand(lhs: String, rhs: String) -> String
{
    return "[[\(lhs)$NAND$\(rhs)]$NAND$[\(lhs)$NAND$\(rhs)]]"
}

func sealNand(lhs: String, rhs: String) -> String
{
    return "[\(lhs)$NAND$\(rhs)]"
}

func orToNand(lhs: String, rhs:String) -> String
{
    return "[[\(lhs)$NAND$\(lhs)]$NAND$[\(rhs)$NAND$\(rhs)]]"
}

func norToNand(lhs: String, rhs: String) -> String
{
    return validate(proposition: "NOT ( \(lhs) OR \(rhs) )").equivalent
}

func xorToNand(lhs: String, rhs: String) -> String
{
    return "[[\(rhs)$NAND$[\(rhs)$NAND$\(lhs)$]]$NAND$[\(lhs)$NAND$[$\(rhs)$NAND$\(lhs)]]]"
}

func thenToNand(lhs: String, rhs: String) -> String
{
    return validate(proposition: "NOT \(lhs) OR \(rhs)").equivalent
}

func iffToNand(lhs: String, rhs: String) -> String
{
    return validate(proposition: "NOT ( \(rhs) XOR \(lhs) )").equivalent
}

/*
 VALIDATE
 This function handles the more specific validation (as its name implies), priority management, parsing, and calling
 the replacement functions. If called with parentheses, it processes these parentheses first and replaces their contents via recursive
 calls.
 
 It uses the same encoding for spaces when reassembling the string for the final return as to not interfere with
 previous calls of itself.
 
 If this function fails at any point, the proposition is declared invalid.
*/
func validate(proposition: String) -> (valid: Bool, equivalent: String, reason: String)
{
    var components = proposition.components(separatedBy: " ") //Slices it into an array    
    
    //If a left parenthesis is found, this part finds its matching brace and then recursively calls this function with the contents of the parenthesis.
    if (proposition.range(of: "(") != nil)
    {
        var i = 0
        while (i < components.count)
        {
            if (components[i] == "(")
            {
                let startPos = i
                var parenthesesMatch = 1
                var c = startPos
                while ((components[c] != ")") || (parenthesesMatch != 0))
                {
                    c += 1
                    if (components[c] == "(")
                    {
                        parenthesesMatch += 1
                    }
                    else if (components[c] == ")")
                    {
                        parenthesesMatch -= 1
                    }
                    
                    if ((c == components.count - 1) && (parenthesesMatch != 0))
                    {
                        return (false, "", "Parenthesis mismatch (Excess left parenthesis(es).)")
                    }
                }
                let content = components[(startPos + 1)...(c - 1)] //
                let equivalent = validate(proposition: content.joined(separator: " "))
                if (!equivalent.valid)
                {
                    return (false, "", equivalent.reason)
                }
                components.replaceSubrange((startPos)...(c), with: (equivalent.equivalent).components(separatedBy: " "));
                
                i += equivalent.equivalent.components(separatedBy: " ").count;
            }
            else
            {
                i += 1
            }
        }        
        i = 0
    }

    /*
     At this point, there are no left parentheses left, it starts performing operations for NAND conversion.
     
     All parameters either start with p or encoded parentheses ([). The function is marked invalid otherwise.
     
     It is also marked invalid if parameters are not found or if a right brace is found at all, meaning some parentheses mismatched.
     
     It uses an exhaustive list to accomplish that. It also handles capitalization of operators by the user.
     
     First however it checks for NOTs as being a unary operator, the parameters need to be properly converted first
     as to not interfere with parsing arguments preceded by not.
    */

    //NOT
    var i = 0

    while (i < components.count)
    {
        if (components[i].lowercased() == "not")
        {
            if ((i + 2 > components.count) || (!(components[i + 1].hasPrefix("p") || components[i + 1].hasPrefix("["))))
            {
                return (false, "", "NOT parameter not found.")
            }
            let notEquivalent = [notToNand(components[i + 1])]
            components.replaceSubrange(i...(i + 1), with: notEquivalent)
        }
        else
        {
            i += 1
        }
    }

    //Other supported operators
    i = 0
    
    while (i < components.count)
    {
        if (components[i] == ")")
        {
            return (false, "", "Parenthesis mismatch (Excess right parenthesis(es).)")
        }
        else if (components[i].lowercased() == "and")
        {
            if ((i - 1 < 0) || (i + 2 > components.count) || (!(components[i + 1].hasPrefix("p") || components[i + 1].hasPrefix("["))))
            {
                return (false, "", "AND parameter not found.")
            }
            let andEquivalent = [andToNand(lhs: components[i - 1], rhs: components[i + 1])]
            components.replaceSubrange((i - 1)...(i + 1), with: andEquivalent)
        }
        else if (components[i].lowercased() == "nand")
        {
            if ((i - 1 < 0) || (i + 2 > components.count) || (!(components[i + 1].hasPrefix("p") || components[i + 1].hasPrefix("["))))
            {
                return (false, "", "NAND parameter not found.")
            }
            let sealedNand = [sealNand(lhs: components[i - 1], rhs: components[i + 1])]
            components.replaceSubrange((i - 1)...(i + 1), with: sealedNand)
        }
        else if (components[i].lowercased() == "or")
        {
            if ((i - 1 < 0) || (i + 2 > components.count) || (!(components[i + 1].hasPrefix("p") || components[i + 1].hasPrefix("["))))
            {
                return (false, "", "OR parameter not found.")
            }
            let orEquivalent = [orToNand(lhs: components[i - 1], rhs: components[i + 1])]
            components.replaceSubrange((i - 1)...(i + 1), with: orEquivalent)
        }
	else if (components[i].lowercased() == "nor")
        {
            if ((i - 1 < 0) || (i + 2 > components.count) || (!(components[i + 1].hasPrefix("p") || components[i + 1].hasPrefix("["))))
            {
                return (false, "", "NOR parameter not found.")
            }
            let norEquivalent = [norToNand(lhs: components[i - 1], rhs: components[i + 1])]
            components.replaceSubrange((i - 1)...(i + 1), with: norEquivalent)
        }
        else if (components[i].lowercased() == "xor")
        {
            if ((i - 1 < 0) || (i + 2 > components.count) || (!(components[i + 1].hasPrefix("p") || components[i + 1].hasPrefix("["))))
            {
                return (false, "", "XOR parameter not found.")
            }
            let xorEquivalent = [xorToNand(lhs: components[i - 1], rhs: components[i + 1])]
            components.replaceSubrange((i - 1)...(i + 1), with: xorEquivalent)
        }
        else if (components[i].lowercased() == "then")
        {
            if ((i - 1 < 0) || (i + 2 > components.count) || (!(components[i + 1].hasPrefix("p") || components[i + 1].hasPrefix("["))))
            {
                return (false, "", "THEN parameter not found.")
            }
            let thenEquivalent = [thenToNand(lhs: components[i - 1], rhs: components[i + 1])]
            components.replaceSubrange((i - 1)...(i + 1), with: thenEquivalent)
        }
        else if (components[i].lowercased() == "iff")
        {
            if ((i - 1 < 0) || (i + 2 > components.count) || (!(components[i + 1].hasPrefix("p") || components[i + 1].hasPrefix("["))))
            {
                return (false, "", "IFF parameter not found.")
            }
            let iffEquivalent = [iffToNand(lhs: components[i - 1], rhs: components[i + 1])]
            components.replaceSubrange((i - 1)...(i + 1), with: iffEquivalent)
        }
        else if (components[i].hasPrefix("p") || components[i].hasPrefix("["))
        {
            i += 1
        }
        else
        {
            return (false, "", "Invalid syntax (unsupported operator or proposition not started with p.)")
        }
        
    }
    return (true, components.joined(separator: "$"), "")
}

//This function adds spaces between parentheses and whatever is next to them. This is to aid with the "slicing" later on.
func spaceOut(_ stringToSpace: String) -> String
{
    let leftParenthesesSpaced = stringToSpace.replacingOccurrences(of: "(", with: "( ")
    let rightParenthesesSpaced = leftParenthesesSpaced.replacingOccurrences(of: ")", with: " )")
    let leftParenthesesFixed = rightParenthesesSpaced.replacingOccurrences(of: "(  ", with: "( ")
    return leftParenthesesFixed.replacingOccurrences(of: "  )", with: " )")
}

//This function unencodes the output, as well as remove spaces between parentheses, for easier human readability.
func cleanOutput(_ stringToClean: String) -> String
{
    let dollarSignsSpaced = stringToClean.replacingOccurrences(of: "$", with: " ")
    let leftParenthesesFixed = dollarSignsSpaced.replacingOccurrences(of: "[", with: "(")
    let rightParenthesesFixed = leftParenthesesFixed.replacingOccurrences(of: "]", with: ")")
    let leftParenthesesUnspaced = rightParenthesesFixed.replacingOccurrences(of: "( ", with: "(")
    return leftParenthesesUnspaced.replacingOccurrences(of: " )", with: ")")
}

/*
 ENTRY POINT
 This is where it starts executing the program.
*/
var open = true
while (open)
{
    print("Please input a valid proposition (Type Q to Quit, I for Instructions):");
    
    var input: String! = readLine()
    if ((input.range(of: "[") == nil) && (input.range(of: "]") == nil) && (input.range(of: "$") == nil))
    {
        input = spaceOut(input)
        var propositionStatus = validate(proposition: input)
        if (propositionStatus.valid)
        {
            propositionStatus.equivalent = cleanOutput(propositionStatus.equivalent)
            print("Equivalent NAND proposition:")
            print(propositionStatus.equivalent)
            print("Successfully converted proposition.\n")
        }
        else if (input.lowercased() == "q")
        {
            open = false
        }
        else if (input.lowercased() == "i")
        {
            print("(Not, And, Nand, Or, Nor, Xor, Then, Iff, px (where x is an unspaced string of any length), ( or ). Please do not use $, [ or ] as they are used in processing.)")
        }
        else
        {
            print("Invalid proposition. \(propositionStatus.reason) Retry.")
        }
    }
    else
    {
        print("Character $, [, ] or any combination of them detected. Retry.")
    }
}