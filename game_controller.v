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
    output reg [8:0] warning_state,
    output reg [1:0] life
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
reg [8:0] next_fire_state, prev_fire_state, prev_gold_state;
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
reg win;

reg [3:0] hit_count;  // 用來計算踩到幾個火焰
integer i;

reg [8:0] prev_box;
reg check_collision;

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
always @(*) begin
    // 預設值
    next_fire_state = fire_state;
    ones_count = 0;
    
    case (game_state)
        INIT: begin
            next_fire_state = 9'b100110110;
        end
        
        PLAY: begin
            // 基本的LFSR移位
            next_fire_state = {
                next_fire_state[0],                                // [8]
                next_fire_state[8],                               // [7]
                next_fire_state[0] ^ next_fire_state[7],         // [6]
                next_fire_state[0] ^ next_fire_state[6],         // [5]
                next_fire_state[5],                               // [4]
                next_fire_state[0] ^ next_fire_state[4],         // [3]
                next_fire_state[3],                               // [2]
                next_fire_state[2],                               // [1]
                next_fire_state[1]                                // [0]
            };
                             
            // 計算1的數量
            for(i = 0; i < 9; i = i + 1) begin
                if(next_fire_state[i]) ones_count = ones_count + 1;
            end
            
            if(ones_count > 6) begin
                // 如果超過6個1，移除多餘的1
                for(i = 8; i >= 0; i = i - 1) begin
                    if(next_fire_state[i] && ones_count > 6) begin
                        next_fire_state[i] = 1'b0;
                        ones_count = ones_count - 1;
                    end 
                end
            end else if(ones_count < 3) begin
                // 如果少於3個1，添加到3個
                for(i = 0; i < 9; i = i + 1) begin
                    if(!next_fire_state[i] && ones_count < 3) begin
                        next_fire_state[i] = 1'b1;
                        ones_count = ones_count + 1;
                    end 
                end
            end
        end
        
        default: begin
            next_fire_state = 9'b100110110;
        end
    endcase
end

// Fire update timing control
always @(posedge clk_div26 or posedge rst) begin
    if (rst) begin
        warning_flag <= 0;
        warning_counter <= 0;
    end else if (game_state == INIT) begin
        warning_flag <= 0;
        warning_counter <= 0;
    end else if (game_state == PLAY) begin
        if (warning_counter < 3) warning_counter <= warning_counter + 1;
        else warning_counter <= 0;
        if(warning_counter < 2) begin
            warning_flag <= 0;
        end
        else begin
            warning_flag <= 1;  // 開始預警
        end 
    end
end

// Warning state control
always @(*) begin
    if (warning_flag && game_state == PLAY) begin
        warning_state = next_fire_state;  // 只在預警時間顯示
    end else begin
        warning_state = 9'b0;
    end
end

// Fire state update
always @(posedge clk_div28 or posedge rst) begin
    if (rst) begin
        fire_state <= 9'b100110110;
    end else if (game_state == INIT) begin
        fire_state <= 9'b100110110;
    end else if (game_state == PLAY) begin
        fire_state <= next_fire_state;
    end
end

// Gold state update
always @(posedge clk_div28 or posedge rst) begin
    if (rst) begin
        gold_state <= 9'b0;
        gold_counter <= 0;
        random_pos <= 9'b100000000;
    end else if (game_state == INIT) begin
        gold_state <= 9'b0;
        gold_counter <= 0;
    end else if (game_state == PLAY) begin
        if (gold_state == 9'b0) begin  // 當前沒有 gold
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
                if (random_pos[0] && !fire_state[0]) gold_state[0] <= 1;
                else if (random_pos[1] && !fire_state[1]) gold_state[1] <= 1;
                else if (random_pos[2] && !fire_state[2]) gold_state[2] <= 1;
                else if (random_pos[3] && !fire_state[3]) gold_state[3] <= 1;
                else if (random_pos[4] && !fire_state[4]) gold_state[4] <= 1;
                else if (random_pos[5] && !fire_state[5]) gold_state[5] <= 1;
                else if (random_pos[6] && !fire_state[6]) gold_state[6] <= 1;
                else if (random_pos[7] && !fire_state[7]) gold_state[7] <= 1;
                else if (random_pos[8] && !fire_state[8]) gold_state[8] <= 1;
            end
        end else begin  // 有 gold 時，跟著火焰更新的節奏一起更新
            gold_counter <= 0;
            gold_state <= 9'b0;  // gold 消失
        end
    end
end

// 偵測 fire_state 和 box 的變化
always @(posedge clk or posedge rst) begin
    if (rst) begin
        prev_fire_state <= 9'b0;
        prev_box <= 9'b0;
        prev_gold_state <= 9'b0;
        check_collision <= 0;
    end else begin
        prev_fire_state <= fire_state;
        prev_box <= box;
        prev_gold_state <= gold_state;
        // 當任何狀態改變時，設置檢查標誌
        if (fire_state != prev_fire_state || 
            box != prev_box || 
            gold_state != prev_gold_state) begin
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
    end else begin
        case (game_state)
            INIT: begin
                life <= 3;
            end
            PLAY: begin
                if (check_collision && !super) begin  // 只在需要時計算碰撞
                    hit_count <= 0;
                    for (i = 0; i < 9; i = i + 1) begin
                        if (box[i] & fire_state[i] & ~gold_state[i]) begin
                            hit_count <= hit_count + 1;
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
    end else begin
        case (game_state)
            INIT: begin
                score <= 0;
            end
            PLAY: begin
                if (check_collision) begin  // 只在需要時檢查
                    for (i = 0; i < 9; i = i + 1) begin
                        if (box[i] & gold_state[i]) begin
                            score <= score + 1;
                        end
                    end
                end
                
                if (score >= SCORE_MAX) begin
                    win <= 1;
                end
            end
            FINISH: begin
                if (score >= SCORE_MAX) begin
                    win <= 1;
                end
            end
        endcase
    end
end

endmodule