#!/usr/bin/env swift

let bits = 32 //Input bits

for i in 0..<bits
{
    print("wire [31:0] sum\(i);")
}
print("assign sum0 = A & {32{B[0]}};")
print("")

for i in 0..<bits
{
    print("wire [31:0] carry\(i);")
}
print("assign carry0 = 32'b0;")
print("")

for i in 1..<bits
{
    print("FA fa\(i)_0(.a(sum\(i-1)[1]), .b(A[0] & B[\(i)]), .ci(1'b0), .s(Z[\(i)]), .co(carry\(i)[0]));")
    for j in 1..<(bits - 1)
    {
        print("FA fa\(i)_\(j)(.a(sum\(i-1)[\(j + 1)]), .b(A[\(j)] & B[\(i)]), .ci(carry\(i)[\(j-1)]), .s(sum\(i)[\(j)]), .co(carry\(i)[\(j)]));")
    }
    print("FA fa\(i)_\(bits - 1)(.a(carry\(i - 1)[\(bits - 1)]), .b(A[\(bits - 1)] & B[\(i)]), .ci(carry\(i)[\(bits - 2)]), .s(sum\(i)[\(bits - 1)]), .co(carry\(i)[\(bits - 1)]));")
}

print("")

for i in 0..<(bits - 1)
{
    print("assign Z[\(i)] = sum\(i)[0];")
}

print("assign Z[62:31] = sum31;")
print("assign Z[63] = carry31[31];")