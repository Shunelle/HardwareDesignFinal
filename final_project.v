// File: final_project.v
module final_project(
    input wire clk,
    input wire rst,
    input wire start,
    input wire super,
    input wire [8:0] box,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    output wire hsync,
    output wire vsync,
    output wire [8:0] box_out,
    output reg [3:0] music //music[0]:INIT ; music[1]:PLAY ; music[2]:WIN ; music[3]:LOSS
);

localparam INIT = 2'b00;
localparam PLAY = 2'b01;
localparam FINISH = 2'b10;

// Internal signals
wire clk_25MHz, clk_95Hz, clk_div28;
wire start_db, start_op;
wire valid;
wire [9:0] h_cnt, v_cnt;
wire [1:0] game_state;
wire [3:0] score;
wire [8:0] fire_state, gold_state;
wire [8:0] next_fire_pattern, hit_bitmap;
wire [11:0] pixel_color;
wire [2:0] life;

wire win;

// Clock generation
clock_divider #(.n(2)) m2(
    .clk(clk),
    .clk_div(clk_25MHz)
);

clock_divider #(.n(20)) m20(
    .clk(clk),
    .clk_div(clk_95Hz)
);

clock_divider #(.n(28)) m28(
    .clk(clk),
    .clk_div(clk_div28)
);

// Button debounce & one pulse
debounce debounce_start(.clk(clk_95Hz), .pb(start), .pb_debounced(start_db));
one_pulse one_pulse_start(.clk(clk_95Hz), .pb_in(start_db), .pb_out(start_op));

// VGA controller
vga_controller vga_inst(
    .pclk(clk_25MHz),
    .reset(rst),
    .hsync(hsync),
    .vsync(vsync),
    .valid(valid),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt)
);

// Game controller

game_controller game_ctrl(
    .clk(clk_95Hz),
    .clk_div28(clk_div28),
    .rst(rst),
    .start(start_op),
    .super(super),
    .box(box),
    .game_state(game_state),
    .score(score),
    .fire_state(fire_state),
    .gold_state(gold_state),
    .next_fire_pattern(next_fire_pattern),
    .hit_bitmap(hit_bitmap),
    .life(life),
    .win(win)
);

// Display controller
display_controller display_ctrl(
    .clk(clk_25MHz),
    .rst(rst),
    .valid(valid),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt),
    .game_state(game_state),
    .fire_state(fire_state),
    .gold_state(gold_state),
    .next_fire_pattern(next_fire_pattern),
    .box(box),
    .hit_bitmap(hit_bitmap),
    .life(life),
    .score(score),
    .win(win),
    .pixel_color(pixel_color)
);

assign box_out = box; 

always @(*) begin
    case(game_state) 
        INIT: music = 4'b0001;
        PLAY: music = 4'b0010;
        FINISH: music = win? 4'b0100 : 4'b1000;
    endcase
end

// VGA output assignment
always @(*) begin
    if (!valid) begin
        {vgaRed, vgaGreen, vgaBlue} = 12'h000;
    end else begin
        {vgaRed, vgaGreen, vgaBlue} = pixel_color;
    end
end

endmodule