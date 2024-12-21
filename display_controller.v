module display_controller(
    input wire clk,
    input wire rst,
    input wire valid,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    input wire [1:0] game_state,
    input wire [8:0] fire_state,
    input wire [8:0] gold_state,
    input wire [8:0] next_fire_pattern,
    input wire [8:0] box,
    input wire [8:0] hit_bitmap,
    input wire [1:0] life,
    input wire [3:0] score,
    input wire win,
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

// Background parameters
parameter BG_ORIG_WIDTH = 320;
parameter BG_ORIG_HEIGHT = 240;

// Grid parameters
parameter GRID_SIZE = 420;
parameter BOX_SIZE = GRID_SIZE/3;
parameter BORDER_WIDTH = 2;

// Grid position (centered)
parameter GRID_START_X = (H_DISPLAY - GRID_SIZE)/2;
parameter GRID_START_Y = (V_DISPLAY - GRID_SIZE)/2;

// 小九宮格參數
parameter MINI_GRID_SIZE = 90;
parameter MINI_BOX_SIZE = MINI_GRID_SIZE/3;
parameter MINI_GRID_START_X = 10;  // 左下角位置
parameter MINI_GRID_START_Y = V_DISPLAY - MINI_GRID_SIZE - 30;  // 左下角位置

//CT image parameters
parameter CT_ORIG_WIDTH = 80;    // CT原始寬度
parameter CT_ORIG_HEIGHT = 60;   // CT原始高度 
parameter CT_WIDTH = 120;         // CT顯示寬度
parameter CT_HEIGHT = 90;       // CT顯示高度

parameter CT_CENTER_X = (H_DISPLAY - CT_WIDTH)/2;
parameter CT_CENTER_Y = (V_DISPLAY - CT_HEIGHT)/2;

// Fire image parameters
parameter IMG_SIZE = 60;
parameter GOLD_SIZE = 120;  // 2倍大的金幣

// Life display parameters
parameter LIFE_SIZE = 15;
parameter LIFE_START_X = 20;
parameter LIFE_START_Y = 30;
parameter LIFE_SPACING = 15;
parameter LIFE_BORDER = 1;

// Score display parameters
parameter SCORE_SIZE = 15;
parameter SCORE_START_X = 20;
parameter SCORE_START_Y = 60;
parameter SCORE_SPACING = 15;
parameter SCORE_BORDER = 1;

//results display parameters
parameter WIN_ORIG_HEIGHT = 40;
parameter WIN_ORIG_WIDTH = 80;
parameter LOSS_ORIG_HEIGHT = 40;
parameter LOSS_ORIG_WIDTH = 85;
parameter WIN_HEIGHT = WIN_ORIG_HEIGHT * 2;    // 放大後高度
parameter WIN_WIDTH = WIN_ORIG_WIDTH * 2;      // 放大後寬度
parameter LOSS_HEIGHT = LOSS_ORIG_HEIGHT * 2;  // 放大後高度
parameter LOSS_WIDTH = LOSS_ORIG_WIDTH * 2;    // 放大後寬度

// 定義透明色
parameter TRANSPARENT_BLACK = 12'h000;
parameter TRANSPARENT_WHITE = 12'hFFF;

// Animation signals
reg [3:0] fire_counter;
reg [19:0] frame_counter;

// Background memory signals
wire [11:0] bg_data;

// Memory signals
reg [11:0] addr;
reg [12:0] ct_addr;
reg [16:0] bg_addr;

wire [11:0] fire_data [0:5];
wire [11:0] gold_data [0:5];
wire [11:0] ct_data;
wire [11:0] win_data;
wire [11:0] loss_data;


// background img
blk_mem_gen_bg bg(.clka(clk), .wea(1'b0), .addra(bg_addr), .dina(12'b0), .douta(bg_data));

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

//CT img
blk_mem_gen_6 ct(.clka(clk), .wea(1'b0), .addra(ct_addr), .dina(12'b0), .douta(ct_data));

//win loss img
blk_mem_gen_win win(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(win_data));
blk_mem_gen_loss loss(.clka(clk), .wea(1'b0), .addra(addr), .dina(12'b0), .douta(loss_data));

// 背景地址計算
always @* begin
    bg_addr = (v_cnt >> 1) * BG_ORIG_WIDTH + (h_cnt >> 1);
end

// Position calculations
wire [9:0] rel_x = h_cnt - GRID_START_X;
wire [9:0] rel_y = v_cnt - GRID_START_Y;
wire [1:0] grid_x = rel_x / BOX_SIZE;
wire [1:0] grid_y = rel_y / BOX_SIZE;
wire [3:0] box_index = grid_y * 3 + grid_x;

// Mini grid position calculations
wire [9:0] mini_rel_x = h_cnt - MINI_GRID_START_X;
wire [9:0] mini_rel_y = v_cnt - MINI_GRID_START_Y;
wire [1:0] mini_grid_x = mini_rel_x / MINI_BOX_SIZE;
wire [1:0] mini_grid_y = mini_rel_y / MINI_BOX_SIZE;
wire [3:0] mini_box_index = mini_grid_y * 3 + mini_grid_x;
wire is_in_mini_grid = (h_cnt >= MINI_GRID_START_X && h_cnt < MINI_GRID_START_X + MINI_GRID_SIZE &&
                       v_cnt >= MINI_GRID_START_Y && v_cnt < MINI_GRID_START_Y + MINI_GRID_SIZE);

// Mini grid border check
wire is_mini_border = is_in_mini_grid && (
    (mini_rel_x < BORDER_WIDTH) || 
    (mini_rel_x >= (MINI_GRID_SIZE - BORDER_WIDTH)) ||
    (mini_rel_y < BORDER_WIDTH) || 
    (mini_rel_y >= (MINI_GRID_SIZE - BORDER_WIDTH)) ||
    (mini_rel_x % MINI_BOX_SIZE < BORDER_WIDTH) ||
    (mini_rel_y % MINI_BOX_SIZE < BORDER_WIDTH) ||
    ((mini_rel_x + 1) % MINI_BOX_SIZE == 0) ||
    ((mini_rel_y + 1) % MINI_BOX_SIZE == 0)
);

// 一般圖片位置計算
wire [9:0] img_start_x = (BOX_SIZE - IMG_SIZE)/2;
wire [9:0] img_start_y = (BOX_SIZE - IMG_SIZE)/2;
wire [9:0] img_x = (rel_x % BOX_SIZE) - img_start_x;
wire [9:0] img_y = (rel_y % BOX_SIZE) - img_start_y;
wire is_in_img = (img_x < IMG_SIZE && img_y < IMG_SIZE && 
                 rel_x % BOX_SIZE >= img_start_x && rel_y % BOX_SIZE >= img_start_y);

// Gold圖片位置計算
wire [9:0] gold_start_x = (BOX_SIZE - GOLD_SIZE)/2;
wire [9:0] gold_start_y = (BOX_SIZE - GOLD_SIZE)/2;
wire [9:0] gold_x = (rel_x % BOX_SIZE) - gold_start_x;
wire [9:0] gold_y = (rel_y % BOX_SIZE) - gold_start_y;
wire is_in_gold = (gold_x < GOLD_SIZE && gold_y < GOLD_SIZE && 
                  rel_x % BOX_SIZE >= gold_start_x && rel_y % BOX_SIZE >= gold_start_y);

//ct圖片位置計算
wire [9:0] ct_start_x = (BOX_SIZE - CT_WIDTH)/2;
wire [9:0] ct_start_y = (BOX_SIZE - CT_HEIGHT)/2;
wire [9:0] ct_x = (rel_x % BOX_SIZE) - ct_start_x;
wire [9:0] ct_y = (rel_y % BOX_SIZE) - ct_start_y;
wire is_in_ct = (ct_x < CT_WIDTH && ct_y < CT_HEIGHT && 
                rel_x % BOX_SIZE >= ct_start_x && rel_y % BOX_SIZE >= ct_start_y);
//init ct
wire [9:0] init_ct_x = h_cnt - CT_CENTER_X;
wire [9:0] init_ct_y = v_cnt - CT_CENTER_Y;
wire is_in_init_ct = (init_ct_x < CT_WIDTH && init_ct_y < CT_HEIGHT &&
                     h_cnt >= CT_CENTER_X && v_cnt >= CT_CENTER_Y);

// CT掃把火焰位置計算（在ct圖片位置計算後面加入）
wire [9:0] broom_fire_start_x = ct_start_x - 10;  // 從 CT 的左邊開始
wire [9:0] broom_fire_start_y = ct_start_y + CT_HEIGHT - IMG_SIZE - 15;  // 從 CT 底部往上 IMG_SIZE 的高度，再往上5個單位
wire [9:0] broom_fire_x = (rel_x % BOX_SIZE) - broom_fire_start_x;
wire [9:0] broom_fire_y = (rel_y % BOX_SIZE) - broom_fire_start_y;
wire is_in_broom_fire = (broom_fire_x < IMG_SIZE && 
                        broom_fire_y >= 0 && broom_fire_y < IMG_SIZE &&
                        rel_x % BOX_SIZE >= broom_fire_start_x && 
                        rel_y % BOX_SIZE >= broom_fire_start_y &&
                        box[box_index]);

//result圖片位置計算
wire [9:0] win_start_x = (H_DISPLAY - WIN_WIDTH)/2;
wire [9:0] win_start_y = (V_DISPLAY - WIN_HEIGHT)/2;
wire [9:0] loss_start_x = (H_DISPLAY - LOSS_WIDTH)/2;
wire [9:0] loss_start_y = (V_DISPLAY - LOSS_HEIGHT)/2;
wire [9:0] result_x = win ? (h_cnt - win_start_x) : (h_cnt - loss_start_x);
wire [9:0] result_y = win ? (v_cnt - win_start_y) : (v_cnt - loss_start_y);
wire is_in_result = win ? 
    (result_x < WIN_WIDTH && result_y < WIN_HEIGHT &&
     h_cnt >= win_start_x && v_cnt >= win_start_y) :
    (result_x < LOSS_WIDTH && result_y < LOSS_HEIGHT &&
     h_cnt >= loss_start_x && v_cnt >= loss_start_y);

// UI 元素檢查
wire is_in_grid = (h_cnt >= GRID_START_X && h_cnt < GRID_START_X + GRID_SIZE &&
                  v_cnt >= GRID_START_Y && v_cnt < GRID_START_Y + GRID_SIZE);
                  
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

// Life checks
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

// Score checks
wire [3:0] score_index = (h_cnt - SCORE_START_X) / SCORE_SPACING;
wire [9:0] score_local_x = (h_cnt - SCORE_START_X) % SCORE_SPACING;
wire [9:0] score_local_y = v_cnt - SCORE_START_Y;
wire is_score_border = (score_local_x < SCORE_BORDER) || 
                      (score_local_x >= SCORE_SIZE - SCORE_BORDER) ||
                      (score_local_y < SCORE_BORDER) ||
                      (score_local_y >= SCORE_SIZE - SCORE_BORDER);
wire is_in_score = (score_local_x < SCORE_SIZE && score_local_y < SCORE_SIZE &&
                   h_cnt >= SCORE_START_X && h_cnt < SCORE_START_X + SCORE_SPACING * SCORE_MAX &&
                   v_cnt >= SCORE_START_Y && v_cnt < SCORE_START_Y + SCORE_SIZE);
wire is_active_score = score_index < score;

// Fire animation counter
always @(posedge clk or posedge rst) begin
    if (rst) begin
        fire_counter <= 0;
        frame_counter <= 0;
    end else if (frame_counter == 20'hFFFFF) begin
        // 一般的火
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
    if (game_state == INIT && is_in_init_ct) begin
        ct_addr = ((init_ct_y * CT_ORIG_HEIGHT / CT_HEIGHT) * CT_ORIG_WIDTH) + 
                 (init_ct_x * CT_ORIG_WIDTH / CT_WIDTH);
        addr = 0;
    end else if (game_state == FINISH && is_in_result) begin
        ct_addr = 0;  
        if (win) begin
            addr = ((result_y >> 1) * WIN_ORIG_WIDTH) + (result_x >> 1);
        end else begin
            addr = ((result_y >> 1) * LOSS_ORIG_WIDTH) + (result_x >> 1);
        end
    end else if (box[box_index] && is_in_ct) begin
        if (is_in_broom_fire && hit_bitmap[box_index]) begin
            ct_addr = ((ct_y * CT_ORIG_HEIGHT / CT_HEIGHT) * CT_ORIG_WIDTH) + 
                     (ct_x * CT_ORIG_WIDTH / CT_WIDTH);   // 保持顯示 CT
            addr = broom_fire_y * IMG_SIZE + broom_fire_x;  // 同時計算火焰的地址
        end else begin
            ct_addr = ((ct_y * CT_ORIG_HEIGHT / CT_HEIGHT) * CT_ORIG_WIDTH) + 
                     (ct_x * CT_ORIG_WIDTH / CT_WIDTH);   
            addr = 0;
        end
    end else if (gold_state[box_index] && is_in_gold) begin
        ct_addr = 0;  
        addr = ((gold_y >> 1) * IMG_SIZE) + (gold_x >> 1); 
    end else if (fire_state[box_index] && is_in_img) begin
        ct_addr = 0;  
        addr = img_y * IMG_SIZE + img_x;  
    end else begin
        ct_addr = 0;  
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
                pixel_color = bg_data;
                if (is_in_init_ct) begin  // 顯示中間的 CT
                    if (ct_data != TRANSPARENT_WHITE)
                        pixel_color = ct_data;
                end
            end
            PLAY: begin
                // 預設顯示背景
                pixel_color = bg_data;
                
                // UI 元素
                if (is_in_mini_grid) begin  // 加入這段
                    if (is_mini_border)
                        pixel_color = 12'hFFF;  // 白色邊框
                    else if (next_fire_pattern[mini_box_index])
                        pixel_color = 12'hF40;  // 橘紅色
                    else
                        pixel_color = bg_data;
                end
                else if (is_in_life) begin
                    if (is_life_border)
                        pixel_color = 12'hFFF;
                    else if (is_active_life)
                        pixel_color = 12'hFF0;
                    else
                        pixel_color = bg_data;
                end
                else if (is_in_score) begin
                    if (is_score_border)
                        pixel_color = 12'hFFF;
                    else if (is_active_score)
                        pixel_color = 12'h8F8;
                    else
                        pixel_color = bg_data;
                end
                else if (is_border) begin
                    pixel_color = 12'hFFF;
                end
                else if (is_in_grid) begin
                    // 先顯示背景
                    pixel_color = bg_data;
                    
                    // 然後依序疊加其他圖層（如果不是透明的話）
                    if (box[box_index] && is_in_ct) begin
                        if (is_in_broom_fire && hit_bitmap[box_index]) begin  // 先檢查是否要顯示火焰
                            if (fire_data[fire_counter] != TRANSPARENT_BLACK)
                                pixel_color = fire_data[fire_counter];
                            else if (ct_data != TRANSPARENT_WHITE)  // 如果火焰是透明的，才顯示 CT
                                pixel_color = ct_data;
                        end else if (ct_data != TRANSPARENT_WHITE) begin  // 如果不是火焰區域，就正常顯示 CT
                            pixel_color = ct_data;
                        end
                    end
                    else if (gold_state[box_index] && is_in_gold && !box[box_index]) begin
                        if (gold_data[fire_counter] != TRANSPARENT_BLACK)
                            pixel_color = gold_data[fire_counter];
                    end
                    else if (fire_state[box_index] && is_in_img) begin
                        if (fire_data[fire_counter] != TRANSPARENT_BLACK)
                            pixel_color = fire_data[fire_counter];
                    end
                end
            end
            
            FINISH: begin
                pixel_color = bg_data;  // 先顯示背景
                if (is_in_result) begin
                    if (win) begin
                        if (win_data != TRANSPARENT_BLACK)
                            pixel_color = win_data;
                    end else begin
                        if (loss_data != TRANSPARENT_BLACK)
                            pixel_color = loss_data;
                    end
                end
            end
            
            default: pixel_color = bg_data;
        endcase
    end
end

endmodule