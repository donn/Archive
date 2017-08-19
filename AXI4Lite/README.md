# AXI4-lite Bus
Templates for the ARM-standardized bus in Verilog.

    ACLK: Clock Source. [1]
    ARESETn: Reset signal (asynchronous). [1]

	//Write Address
    AWVALID: [Master -> Slave] Whether address provided by master is valid.
    AWADDR: [Master -> Slave] Address. [31: 0]
    AWPROT: [Master -> Slave] Write Protocol. { Instruction | ~Data, Insecure | ~Secure, Privileged | ~Unprivileged}. [2:0]
    AWREADY: [Slave -> Master] Whether the slave is ready to receive an address.

    //Write Data
    WVALID: [Master -> Slave] Whether data provided by master is valid.
    WDATA: [Master -> Slave] Data. [31: 0]
    WSTRB: [Master -> Slave] Strobes. { write bytes[3], write bytes[2], write bytes[1], write bytes[0]}. [3:0]
    WREADY: [Slave -> Master] Whether the slave is ready to receive data.

    //Write Response
    BREADY: [Master -> Slave] Whether the master is ready to receive the write response.
    BVALID: [Slave -> Master] Whether the write response provided by slave is valid.
    BRESP: [Slave -> Master] enum {okay = 2'b00, exokay = 2'b01, slverr = 2'b10, decerr = 2'b11}. [1:0] //Exclusive Access Okay "exokay" not available in AXI4-lite.

    //Read Address
    ARVALID: [Master -> Slave] Whether address provided by master is valid.
    ARADDR: [Master -> Slave] Address. [31: 0]
    ARPROT: [Master -> Slave] Read Protocol. { Instruction | ~Data, Insecure | ~Secure, Privileged | ~Unprivileged}. [2:0]
    ARREADY: [Slave -> Master] Whether the slave is ready to receive data.

    //Read Data
    RVALID: [Slave -> Master] Whether the data provided by slave is valid.
    RDATA: [Slave -> Master] Data. [31: 0]
    RRESP: [Slave -> Master] enum {okay = 2'b00, exokay = 2'b01, slverr = 2'b10, decerr = 2'b11}. [1:0] //Exclusive Access Okay "exokay" not available in AXI4-lite.
    RREADY: [Master -> Slave] Whether master is ready to receive data.
