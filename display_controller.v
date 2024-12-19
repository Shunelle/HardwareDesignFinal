module display_controller(
    input wire clk,
    input wire rst,
    input wire valid,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    input wire [1:0] game_state,
    input wire [8:0] fire_state,
    input wire [8:0] gold_state,
    input wire [8:0] warning_state,
    input wire [8:0] box,
    input wire [1:0] life,
    input wire [3:0] score,
    output reg [11:0] pixel_color
);

// Game states
localparam INIT = 2'b00;
localparam PLAY = 2'b01;
localparam FINISH = 2'b10;

// life & score
parameter LIFE_MAX = 3;
parameter SCORE_MAX = 5;

// VGA parameters
parameter H_DISPLAY = 640;
parameter V_DISPLAY = 480;

// Grid parameters
parameter GRID_SIZE = 420;
parameter BOX_SIZE = GRID_SIZE/3;
parameter BORDER_WIDTH = 2;

// Grid position (centered)
parameter GRID_START_X = (H_DISPLAY - GRID_SIZE)/2;
parameter GRID_START_Y = (V_DISPLAY - GRID_SIZE)/2;

// Fire image parameters
parameter IMG_SIZE = 60;

// Life display parameters
parameter LIFE_SIZE = 15;
parameter LIFE_START_X = 20;
parameter LIFE_START_Y = 30;
parameter LIFE_SPACING = 15;
parameter LIFE_BORDER = 1;  // 生命值格子的邊框寬度

// Score display parameters
parameter SCORE_SIZE = 15;  // 單個分數格子大小
parameter SCORE_START_X = 20;
parameter SCORE_START_Y = 60;
parameter SCORE_SPACING = 15;  // 分數格子間距
parameter SCORE_BORDER = 1;  // 分數格子的邊框寬度

parameter GOLD_SIZE = IMG_SIZE * 2;

// Animation signals
reg [3:0] fire_counter;
reg [19:0] frame_counter;

// Grid area check
wire is_in_grid = (h_cnt >= GRID_START_X && h_cnt < GRID_START_X + GRID_SIZE &&
                  v_cnt >= GRID_START_Y && v_cnt < GRID_START_Y + GRID_SIZE);

// Position calculations relative to grid
wire [9:0] rel_x = h_cnt - GRID_START_X;
wire [9:0] rel_y = v_cnt - GRID_START_Y;
wire [1:0] grid_x = rel_x / BOX_SIZE;
wire [1:0] grid_y = rel_y / BOX_SIZE;
wire [3:0] box_index = grid_y * 3 + grid_x;

// Local coordinates within each box
wire [9:0] local_x = rel_x % BOX_SIZE;
wire [9:0] local_y = rel_y % BOX_SIZE;

// Image position (centered in box)
wire [9:0] img_start_x = (BOX_SIZE - IMG_SIZE)/2;
wire [9:0] img_start_y = (BOX_SIZE - IMG_SIZE)/2;
wire [9:0] img_x = local_x - img_start_x;
wire [9:0] img_y = local_y - img_start_y;

// Life display calculations
wire [1:0] life_index = (h_cnt - LIFE_START_X) / LIFE_SPACING;
wire [9:0] life_local_x = (h_cnt - LIFE_START_X) % LIFE_SPACING;
wire [9:0] life_local_y = v_cnt - LIFE_START_Y;
wire is_life_border = (life_local_x < LIFE_BORDER) || 
                     (life_local_x >= LIFE_SIZE - LIFE_BORDER) ||
                     (life_local_y < LIFE_BORDER) ||
                     (life_local_y >= LIFE_SIZE - LIFE_BORDER);
wire is_in_life = (life_local_x < LIFE_SIZE && life_local_y < LIFE_SIZE &&
                  h_cnt >= LIFE_START_X && h_cnt < LIFE_START_X + LIFE_SPACING * LIFE_MAX &&
                  v_cnt >= LIFE_START_Y && v_cnt < LIFE_START_Y + LIFE_SIZE);
wire is_active_life = life_index < life;

// 分數顯示計算 (類似生命值)
wire [3:0] score_index = (h_cnt - SCORE_START_X) / SCORE_SPACING;
wire [9:0] score_local_x = (h_cnt - SCORE_START_X) % SCORE_SPACING;
wire [9:0] score_local_y = v_cnt - SCORE_START_Y;
wire is_in_score = (score_local_x < SCORE_SIZE && score_local_y < SCORE_SIZE &&
                   h_cnt >= SCORE_START_X && h_cnt < SCORE_START_X + SCORE_SPACING * SCORE_MAX &&
                   v_cnt >= SCORE_START_Y && v_cnt < SCORE_START_Y + SCORE_SIZE);
wire is_active_score = score_index < score;
wire is_score_border = (score_local_x < SCORE_BORDER) || 
                      (score_local_x >= SCORE_SIZE - SCORE_BORDER) ||
                      (score_local_y < SCORE_BORDER) ||
                      (score_local_y >= SCORE_SIZE - SCORE_BORDER);

// Memory signals
reg [11:0] addr;
wire [11:0] fire_data [0:5];
wire [11:0] gold_data [0:5];
wire [11:0] ct_data;

// fire 動畫
blk_mem_gen_0 fire0(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(fire_data[0]));
blk_mem_gen_1 fire1(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(fire_data[1]));
blk_mem_gen_2 fire2(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(fire_data[2]));
blk_mem_gen_3 fire3(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(fire_data[3]));
blk_mem_gen_4 fire4(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(fire_data[4]));
blk_mem_gen_5 fire5(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(fire_data[5]));

// Gold 動畫
blk_mem_gen_gold0 gold0(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(gold_data[0]));
blk_mem_gen_gold1 gold1(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(gold_data[1]));
blk_mem_gen_gold2 gold2(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(gold_data[2]));
blk_mem_gen_gold3 gold3(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(gold_data[3]));
blk_mem_gen_gold4 gold4(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(gold_data[4]));
blk_mem_gen_gold5 gold5(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(gold_data[5]));

//CT 圖片
blk_mem_gen_CT ct(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(ct_data));

// Image area check
// wire is_in_img = (img_x < IMG_SIZE && img_y < IMG_SIZE && 
//                  local_x >= img_start_x && local_y >= img_start_y);
wire is_in_img = (img_x < IMG_SIZE && img_y < IMG_SIZE && 
                 local_x >= img_start_x && local_y >= img_start_y);

// Gold 的區域檢查（中心點對齊，但範圍更大）
wire [9:0] gold_start_x = (BOX_SIZE - GOLD_SIZE)/2;  // 仍然使用 IMG_SIZE 來計算起始位置
wire [9:0] gold_start_y = (BOX_SIZE - GOLD_SIZE)/2;
wire [9:0] gold_x = local_x - gold_start_x;
wire [9:0] gold_y = local_y - gold_start_y;
wire [9:0] scaled_gold_x = gold_x >> 1;  // 除以2
wire [9:0] scaled_gold_y = gold_y >> 1;  // 除以2
wire is_in_gold = (gold_x < GOLD_SIZE && gold_y < GOLD_SIZE && 
                  local_x >= gold_start_x && local_y >= gold_start_y);

// Border detection (grid lines)
wire is_border = is_in_grid && (
    (rel_x < BORDER_WIDTH) || 
    (rel_x >= (GRID_SIZE - BORDER_WIDTH)) ||
    (rel_y < BORDER_WIDTH) || 
    (rel_y >= (GRID_SIZE - BORDER_WIDTH)) ||
    (rel_x % BOX_SIZE < BORDER_WIDTH) ||
    (rel_y % BOX_SIZE < BORDER_WIDTH) ||
    ((rel_x + 1) % BOX_SIZE == 0) ||
    ((rel_y + 1) % BOX_SIZE == 0)
);

// Fire animation counter
always @(posedge clk or posedge rst) begin
    if (rst) begin
        fire_counter <= 0;
        frame_counter <= 0;
    end else if (frame_counter == 20'hFFFFF) begin
        if (fire_counter == 5)
            fire_counter <= 0;
        else
            fire_counter <= fire_counter + 1;
        frame_counter <= 0;
    end else
        frame_counter <= frame_counter + 1;
end

// Memory address calculation
always @* begin
    if (is_in_gold) begin
        if (gold_state[box_index]) begin
            // Gold圖片放大兩倍：通過將座標除以2來讀取原圖對應像素
            addr = (scaled_gold_y/2) * IMG_SIZE + (scaled_gold_x/2);
        end 
        else begin
            addr = 0;
        end
    end
    else begin
        addr = 0;
    end
    if (is_in_img) begin  // 使用原本的 is_in_img 判斷
        if (box[box_index]) begin
            addr = img_y * IMG_SIZE + img_x;  // CT圖片的地址
        end else if (fire_state[box_index]) begin
            addr = img_y * IMG_SIZE + img_x;
        end else begin
            addr = 0;
        end
    end 
    else begin
        addr = 0;
    end
end

// Display logic
always @* begin
    if (!valid)
        pixel_color = 12'h000;
    else begin
        case (game_state)
            INIT: begin
                if (is_border)
                    pixel_color = 12'hFFF;  // 白色邊框
                else if (is_in_grid)
                    pixel_color = 12'h000;  // 黑色格子
                else
                    pixel_color = 12'h222;  // 深灰色背景
            end
            
            PLAY: begin
                if (is_in_life) begin
                    if (is_life_border)
                        pixel_color = 12'hFFF;  // 白色邊框
                    else if (is_active_life)
                        pixel_color = 12'hFF0;  // 黃色生命值
                    else
                        pixel_color = 12'h000;  // 空格子為黑色
                end
                else if (is_in_score) begin
                    if (is_score_border)
                        pixel_color = 12'hFFF;  // 白色邊框
                    else if (is_active_score)
                        pixel_color = 12'h8F8;  // 淺綠色分數
                    else
                        pixel_color = 12'h000;  // 空格子為黑色
                end
                else if (is_border) begin
                    pixel_color = 12'hFFF; 
                    // if (warning_state[box_index])
                    //     pixel_color = (fire_counter[1]) ? 12'hFF0 : 12'hFFF;  // 黃色閃爍的邊框
                    // else
                    //     pixel_color = 12'hFFF;  // 普通白色邊框
                end
                else if (is_in_grid) begin
                    if (box[box_index] && is_in_img)
                        pixel_color = ct_data;  // CT圖片
                    else if (gold_state[box_index] && is_in_gold)
                        pixel_color = gold_data[fire_counter];  // Gold動畫（使用相同的計數器）
                    else if (fire_state[box_index] && is_in_img)
                        pixel_color = fire_data[fire_counter];  // 火焰動畫
                    else
                        pixel_color = 12'h000;  // 黑色格子
                end else
                    pixel_color = 12'h222;  // 深灰色背景
            end
            
            FINISH: begin
                if (is_border)
                    pixel_color = 12'h444;  // 暗色邊框
                else if (is_in_grid)
                    pixel_color = 12'h111;  // 暗色格子
                else
                    pixel_color = 12'h222;  // 深灰色背景
            end
            
            default: 
                pixel_color = 12'h222;  // 深灰色背景
        endcase
    end
end

endmodule