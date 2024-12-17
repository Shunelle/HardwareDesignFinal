`timescale 1ns / 1ps

module swichTesting(
    input wire clk,
    input wire data_in,  // data from master
    output reg led      // LEDs
);
initial begin
    led = 1'b0;
end
always @(posedge clk) begin
    if(data_in)begin
        led = 1'b1;
    end
    else begin
        led = 1'b0;
    end
end
endmodule
