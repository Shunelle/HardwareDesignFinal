module game_controller(
    input wire clk,
    input wire clk_div28,
    input wire clk_div26,
    input wire rst,
    input wire start,
    input wire super,
    input wire [8:0] box,
    output reg [1:0] game_state,
    output reg [3:0] score,
    output reg [8:0] fire_state,
    output reg [8:0] gold_state,
    output reg [8:0] next_fire_pattern,
    output reg [1:0] life,
    output reg win
);

// Game states
localparam INIT = 2'b00;
localparam PLAY = 2'b01;
localparam FINISH = 2'b10;

// life & score
parameter LIFE_MAX = 3;
parameter SCORE_MAX = 5;

// 內部信號
reg [1:0] next_game_state;
reg [1:0] next_life;
reg [8:0] fire_pattern, prev_fire_pattern, prev_gold_state, gold_pattern;
reg [3:0] ones_count;

//warning
reg warning_active;  // 預警狀態是否啟用
reg warning_flag;
reg [1:0] warning_counter;

// Gold state update
reg [3:0] gold_counter;
reg [8:0] random_pos;
reg [3:0] available_index;  // 記錄空格的index
reg [3:0] random_select;    // 用於選擇空格
// reg win;

reg [3:0] hit_count;  // 用來計算踩到幾個火焰
integer i;

reg [8:0] prev_box, hit_bitmap;
reg check_collision, catch, fire_update;

// FSM - state register
always @(posedge clk or posedge rst) begin
    if (rst) begin
        game_state <= INIT;
    end else begin
        game_state <= next_game_state;
    end
end

// FSM - next state logic
always @(*) begin
    next_game_state = game_state;
    case (game_state)
        INIT: begin
            if (start) begin
                next_game_state = PLAY;
            end
        end
        PLAY: begin
            if (life == 0 || score >= SCORE_MAX) begin
                next_game_state = FINISH;
            end
        end
        FINISH: begin
            if (start) begin
                next_game_state = INIT;
            end
        end
    endcase
end

// Fire state update
always @(posedge clk_div28 or posedge rst) begin
    if(rst) begin
        fire_pattern <= 9'b100110110;
    end
    else begin
        fire_pattern <= next_fire_pattern;
    end
end

always @(*) begin
    case (game_state)
        INIT: begin
            next_fire_pattern = 9'b100110110;
        end
        PLAY: begin
            next_fire_pattern <= {
                fire_pattern[0],                                // [8]
                fire_pattern[8],                               // [7]
                fire_pattern[0] ^ fire_pattern[7],         // [6]
                fire_pattern[0] ^ fire_pattern[6],         // [5]
                fire_pattern[5],                               // [4]
                fire_pattern[0] ^ fire_pattern[4],         // [3]
                fire_pattern[3],                               // [2]
                fire_pattern[2],                               // [1]
                fire_pattern[1]                                // [0]
            };
        end
        default: begin
            next_fire_pattern = 9'b100110110;
        end
    endcase
end

// Fire state update
always @(*) begin
    if (game_state == INIT) begin
        fire_state = 9'b100110110;
    end else if (game_state == PLAY) begin
        fire_state = fire_pattern & ~hit_bitmap;
    end
end


// Gold state update
always @(*) begin
    if (game_state == INIT) begin
        gold_state = 9'b0;
    end else if (game_state == PLAY) begin
        gold_state = catch? 9'b0 : gold_pattern;
    end
end

// Gold state pattern update
always @(posedge clk_div28 or posedge rst) begin
    if (rst) begin
        gold_pattern <= 9'b0;
        gold_counter <= 0;
        random_pos <= 9'b100010000;
    end else if (game_state == INIT) begin
        gold_pattern <= 9'b0;
        gold_counter <= 0;
        random_pos <= 9'b100010000;
    end else if (game_state == PLAY) begin
        if (gold_pattern == 9'b0) begin  // 當前沒有 gold
            gold_counter <= gold_counter + 1;
            if (gold_counter >= 2) begin  // 調整這個值可以控制出現頻率
                gold_counter <= 0;
                // 更新隨機位置
                random_pos <= random_pos >> 1;
                random_pos[8] <= random_pos[0];
                random_pos[6] <= random_pos[0] ^ random_pos[7];
                random_pos[5] <= random_pos[0] ^ random_pos[6];
                random_pos[3] <= random_pos[0] ^ random_pos[4];
                             
                // 在沒有火的地方放置 gold
                if (random_pos[0] && !fire_state[0]) gold_pattern[0] <= 1;
                else if (random_pos[1] && !fire_state[1]) gold_pattern[1] <= 1;
                else if (random_pos[2] && !fire_state[2]) gold_pattern[2] <= 1;
                else if (random_pos[3] && !fire_state[3]) gold_pattern[3] <= 1;
                else if (random_pos[4] && !fire_state[4]) gold_pattern[4] <= 1;
                else if (random_pos[5] && !fire_state[5]) gold_pattern[5] <= 1;
                else if (random_pos[6] && !fire_state[6]) gold_pattern[6] <= 1;
                else if (random_pos[7] && !fire_state[7]) gold_pattern[7] <= 1;
                else if (random_pos[8] && !fire_state[8]) gold_pattern[8] <= 1;
            end
        end else begin  // 有 gold 時，跟著火焰更新的節奏一起更新
            gold_counter <= 0;
            gold_pattern <= 9'b0;  // gold 消失
        end
    end
end

// 偵測 fire_pattern 和 box 的變化
always @(posedge clk or posedge rst) begin
    if (rst) begin
        prev_fire_pattern <= 9'b0;
        prev_box <= 9'b0;
        check_collision <= 0;
        fire_update <= 0;
    end else begin
        prev_fire_pattern <= fire_pattern;
        prev_box <= box;
        if (fire_pattern != prev_fire_pattern) 
            fire_update <= 1;
        else fire_update <= 0;
        if (fire_pattern != prev_fire_pattern || 
            box != prev_box ) begin
            check_collision <= 1;
        end else begin
            check_collision <= 0;
        end
    end
end

// 生命值計算
always @(posedge clk or posedge rst) begin
    if (rst) begin
        life <= 3;
        hit_count <= 0;
        hit_bitmap <= 9'b0;
    end else begin
        case (game_state)
            INIT: begin
                life <= 3;
                hit_bitmap <= 9'b0;
            end
            PLAY: begin
                if(fire_update) hit_bitmap <= 9'b0;
                if (check_collision && !super) begin  // 只在需要時計算碰撞
                    hit_count <= 0;
                    for (i = 0; i < 9; i = i + 1) begin
                        if (box[i] & fire_state[i] & ~gold_state[i]) begin
                            hit_count <= hit_count + 1;
                            hit_bitmap[i] <= 1;
                        end
                    end
                    
                    if (hit_count > 0) begin
                        if (hit_count >= life) begin
                            life <= 0;

                        end else begin
                            life <= life - hit_count;
                        end
                    end
                end
            end
        endcase
    end
end

// Score control
always @(posedge clk or posedge rst) begin
    if (rst) begin
        score <= 0;
        win <= 0;
        catch <= 0;
    end else begin
        case (game_state)
            INIT: begin
                score <= 0;
                win <= 0;
                catch <= 0;
            end
            PLAY: begin
                if(fire_update) catch <= 0;
                if (check_collision) begin  // 只在需要時檢查
                    for (i = 0; i < 9; i = i + 1) begin
                        if (box[i] & gold_state[i]) begin
                            score <= score + 1;
                            catch <= 1;
                        end
                    end
                end
                
                if (score >= SCORE_MAX) begin
                    win <= 1;
                end
            end
            FINISH: begin
                if (score >= SCORE_MAX) win <= 1;
                else win <= 0;
            end
        endcase
    end
end

endmodule