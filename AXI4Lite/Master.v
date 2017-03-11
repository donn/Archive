module Master
(
    ACLK,
    ARESETn,

    //Write Address
    //Output
    AWVALID,
    AWADDR,
    AWPROT,
    //Input
    AWREADY,

    //Write Data
    //Output
    WVALID,
    WDATA,
    WSTRB,
    //Input
    WREADY,

    //Write Response
    //Output
    BREADY,
    //Input
    BVALID,
    BRESP,

    //Read Address
    //Output
    AWVALID,
    AWADDR,
    AWPROT,
    //Input
    AWREADY,

    //Read Data
    //Output    
    RREADY,
    //Input
    RVALID,
    RDATA,
    RRESP
);

    localparam width = 32;
    localparam bytes = $clog(width);

    input ACLKn, ARESETn;
    
    //Write Address
    output AWVALID;
    input AWREADY;
    output [width - 1: 0] AWADDR;
    output [2: 0] AWPROT; //{ Instruction | ~Data, Insecure | ~Secure, Privileged | !Unprivileged }

    //Write Data
    output WVALID;
    input WREADY;
    output [width - 1: 0] WDATA;
    output [bytes - 1: 0] WSTRB;

    //Write Response
    input BVALID;
    output BREADY;
    input [1: 0] BRESP;

    //Read Address Channel
    output ARVALID;
    input ARREADY;
    output [width - 1] ARADDR;
    output ARPROT;

    //Read Data Channel
    input RVALID;
    output RREADY;
    input [witdh - 1] RDATA;
    input [1: 0] RRESP;

endmodule