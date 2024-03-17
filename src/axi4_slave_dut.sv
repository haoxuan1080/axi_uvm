module axi4_slave #(
	parameter integer DATA_WIDTH = 32, //Data bus width
	parameter integer ADDR_WIDTH = 32, //Address bus width
) (
	// Global signals
	input wire aclk,
	input wire aresetn,
	//Write address channel signals
	input wire [ADDR_WIDTH-1:0] awaddr,
	input wire [2:0] awprot,
	input wire awvalid,
	output wire  awready,

	//wirte data channel signals
	input wire [DATA_WIDTH-1:0] wdata,
	input wire [(DATA_WIDTH/8)-1:0] wstrb,
	input wire wvalid,
	output wire  wready,

	//Write response channel
	output wire [1:0] bresp,
	output wire	  bvalid,
	input wire 	  bready,

	//Read address channel 
	input wire [ADDR_WIDTH-1:0] araddr,
	input wire [2:0] 	    arprot,
	input wire		    arvalid,
	output wire		    arready,

	//Read data channel
	output wire [DATA_WIDTH-1:0] rdata,
	output wire [1:0]	     rresp,
	output wire		     rvalid,
	input wire 		     rready
);

	//local parameters
	localparam integer RAM_SIZE = 1024; // Size of RAM in bytes
	localparam integer ADDR_LSB = $clog2(DATA_WIDTH/8); //LSBs to ignore in address 
	
	//Signals
	reg [DATA_WIDTH-1:0] ram [0:RAM_SIZE/(DATA_WIDTH/8) -1];//Memory array
	reg		     awready_reg, wready_reg, bvalid_reg, arredy_reg, rvalid_reg;
	reg [DATA_WIDTH-1:0] rdata_reg;
	reg [1:0] 	     bresp_reg, rresp_reg;

	//output signals assignment
	assign awready = awready_reg;
	assign wready = wready_reg;
	assign bresp = bresp_reg;
	assign bvalid = bvalid_reg;
	assign arready = arready_reg;
	assign rdata = rdata_reg;
	assign rresp = resp_reg;
	assign rvalid = rvalid_reg;

	always @(posedge aclk) begin
		if (!aresetn) begin
			awready_reg <= 1'b0;
			wready_reg <= 1'b0;
			bvalid_reg <= 1'b0;
			arready_reg <= 1'b0;
			rvalid_reg <= 1'b0;
		end
		else begin
			awready_reg <= !awready_reg && awvalid && !bvalid_reg; // accept address
			wready_reg <= !wready_reg && wvalid && !bvalid_reg; // Accept data
			if (awvalid && wvalid && !bvalid_reg) begin
				//Perform wirete operation
				ram[awaddr >> ADDR_LSB] <= wdata;
				bresp_reg <= 2'b00;
				bvalid_reg <=1'b1;
			end
			else if {bvalid_reg && bready) begin
				bvalid_reg <= 1'b0;
			end

			//Read logic
			aready_reg <= !arready_reg && arvalid && !rvalid_reg; //Accept read address
			if (arvalid && !rvalid_reg) begin
				rdata_reg <= ram[araddr >> ADDR_LSB]; //Perform read
				rresp_reg <= 2'b00;// OKAY
			end
			else if (rvalid_reg && rready) begin
				rvalid_reg <=1'b0;
			end
		end
	end


endmodule

