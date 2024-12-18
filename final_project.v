// File: final_project.v
module final_project(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [8:0] box,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    output wire hsync,
    output wire vsync
);

// Internal signals
wire clk_25MHz, clk_95Hz, clk_div26;
wire start_db, start_op;
wire valid;
wire [9:0] h_cnt, v_cnt;
wire [1:0] game_state;
wire [7:0] score;
wire [8:0] fire_state;
wire [11:0] pixel_color;
wire [1:0] life;

// Clock generation
clock_divider #(.n(2)) m2(
    .clk(clk),
    .clk_div(clk_25MHz)
);

clock_divider #(.n(20)) m20(
    .clk(clk),
    .clk_div(clk_95Hz)
);

clock_divider #(.n(26)) m26(
    .clk(clk),
    .clk_div(clk_div26)
);

// Button debounce & one pulse
debounce debounce_start(
    .clk(clk_95Hz),
    .pb(start),
    .pb_debounced(start_db)
);

one_pulse one_pulse_start(
    .clk(clk_95Hz),
    .pb_in(start_db),
    .pb_out(start_op)
);

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
    .clk(clk_25MHz),
    .clk_div26(clk_div26),
    .rst(rst),
    .start_op(start_op),
    .box(box),
    .game_state(game_state),
    .score(score),
    .fire_state(fire_state),
    .life(life)
);

// Display controller
display_controller display_ctrl(
    .clk(clk_25MHz),
    .rst(rst),
    .valid(valid),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt),
    .game_state(game_state),
    .score(score),
    .fire_state(fire_state),
    .life(life),
    .box(box),
    .pixel_color(pixel_color)
);


// VGA output assignment
always @(*) begin
    if (!valid) begin
        {vgaRed, vgaGreen, vgaBlue} = 12'h000;
    end else begin
        {vgaRed, vgaGreen, vgaBlue} = pixel_color;
    end
end

endmodule