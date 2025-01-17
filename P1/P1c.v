module ps2(req, en, gnt, req_up);
  input [1:0] req;
  input en;
  output [1:0] gnt;
  output req_up;

  reg [1:0] gnt;
  reg req_up;

  always @*
  begin
    if (en & req[1]) gnt = 2'b10;
    else if (en & req[0]) gnt = 2'b01;
    else gnt = 4'b00;
    req_up = req[0] | req[1];
  end
endmodule

module ps4(req, en, gnt, req_up);
  input [3:0] req;
  input en;
  output [3:0] gnt;
  output req_up;

  wire [1:0] tmp_req;
  wire [1:0] tmp_en;
  ps2 left(.req(req[3:2]), .en(tmp_en[1]), .gnt(gnt[3:2]), .req_up(tmp_req[1]) );
  ps2 right(.req(req[1:0]), .en(tmp_en[0]), .gnt(gnt[1:0]), .req_up(tmp_req[0]) );
  ps2 top(.req(tmp_req), .en(en), .gnt(tmp_en), .req_up(req_up) );

endmodule


module ps8(req, en, gnt, req_up);
  input [7:0] req;
  input en;
  output [7:0] gnt;
  output req_up;

  wire [1:0] tmp_req;
  wire [1:0] tmp_en;
  ps4 left(.req(req[7:4]), .en(tmp_en[1]), .gnt(gnt[7:4]), .req_up(tmp_req[1]) );
  ps4 right(.req(req[3:0]), .en(tmp_en[0]), .gnt(gnt[3:0]), .req_up(tmp_req[0]) );
  ps2 top(.req(tmp_req), .en(en), .gnt(tmp_en), .req_up(req_up) );

endmodule
