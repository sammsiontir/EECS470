module testbench;
	reg [3:0] req;
	reg  en;
	wire [3:0] gnt;
	wire [3:0] tb_gnt;
	wire correct;

    ps4 pe4(req, en, gnt);

	assign tb_gnt[3]=en&req[3];
	assign tb_gnt[2]=en&req[2]&~req[3];
	assign tb_gnt[1]=en&req[1]&~req[2]&~req[3];
	assign tb_gnt[0]=en&req[0]&~req[1]&~req[2]&~req[3];
	assign correct=(tb_gnt==gnt);

	always @(correct)
	begin
		#2
		if(!correct)
		begin
			$display("@@@ Incorrect at time %4.0f", $time);
			$display("@@@ gnt=%b, en=%b, req=%b",gnt,en,req);
			$display("@@@ expected result=%b", tb_gnt);
			$finish;
		end
	end

	initial 
	begin
		$monitor("Time:%4.0f req:%b en:%b gnt:%b", $time, req, en, gnt);
		req=4'b0000;
		en=1;
		#5	
		req=4'b1000;
		#5
		req=4'b0100;
		#5
		req=4'b0010;
		#5
		req=4'b0001;
		#5
		req=4'b0101;
		#5
		req=4'b0110;
		#5
		req=4'b1110;
		#5
		req=4'b1111;
                #5
                en=0;
                #5
		req=4'b0110;
                #5
		$finish;
 	end // initial
endmodule
