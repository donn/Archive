module Slave
(
    ACLK,
    ARESETn,

    //Write Address
    //Input
    AWVALID,
    AWADDR,
    AWPROT,
    //Output
    AWREADY,

    //Write Data
    //Input
    WVALID,
    WDATA,
    WSTRB,
    //Output
    WREADY,

    //Write Response
    //Input
    BREADY,
    //Output
    BVALID,
    BRESP,

    //Read Address
    //Input
    AWVALID,
    AWADDR,
    AWPROT,
    //Output
    AWREADY,

    //Read Data
    //Input    
    RREADY,
    //Output
    RVALID,
    RDATA,
    RRESP
);

    localparam width = 32;
    localparam bytes = $clog(width);

    output ACLKn, ARESETn;
    
    //Write Address
    input AWVALID;
    output AWREADY;
    input [width - 1: 0] AWADDR;
    input [2: 0] AWPROT; //{ Instruction | ~Data, Insecure | ~Secure, Privileged | !Unprivileged }

    //Write Data
    input WVALID;
    output WREADY;
    input [width - 1: 0] WDATA;
    input [bytes - 1: 0] WSTRB;

    //Write Response
    output BVALID;
    input BREADY;
    output [1: 0] BRESP;

    //Read Address Channel
    input ARVALID;
    output ARREADY;
    input [width - 1] ARADDR;
    input ARPROT;

    //Read Data Channel
    output RVALID;
    input RREADY;
    output [witdh - 1] RDATA;
    output [1: 0] RRESP;

endmodule