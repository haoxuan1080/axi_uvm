class axi_lite_transaction extends uvm_sequence_item;
	typedef enum {READ, WRITE} transaction_type;

	public transaction_type type;
	public bit [31:0] addr;
	public bit [31:0] data;

	function new(string name = "");
		super.new(name);
	endfunction
endclass
