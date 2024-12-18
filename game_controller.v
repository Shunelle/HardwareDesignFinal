module game_controller(
    input wire clk,
    input wire clk_div27,
    input wire rst,
    input wire start_op,
    input wire [8:0] box,
    output reg [1:0] game_state,
    output wire [7:0] score,
    output reg [8:0] fire_state,
    output reg [1:0] life
);

// Game states
localparam INIT = 2'b00;
localparam PLAY = 2'b01;
localparam FINISH = 2'b10;

// 內部信號
reg [1:0] next_game_state;
reg [1:0] next_life;
reg [3:0] damage;  // 用來計算一次踩到幾個火焰

assign score = 0;

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
            if (start_op) begin
                next_game_state = PLAY;
            end
        end
        PLAY: begin
            if (life == 0) begin
                next_game_state = FINISH;
            end
        end
        FINISH: begin
            if (start_op) begin
                next_game_state = INIT;
            end
        end
    endcase
end

// Fire state update
always @(posedge clk_div27 or posedge rst) begin
    if (rst) begin
        fire_state <= 9'b100100100;  // 初始值
    end else if (game_state == INIT) begin
        fire_state <= 9'b100100100;  // 遊戲開始時重置
    end else if (game_state == PLAY) begin
        fire_state <= {
            fire_state[7:0],
            fire_state[0] ^ fire_state[4] ^
            fire_state[5] ^ fire_state[8]
        };
    end
end

reg [3:0] hit_count;  // 用來計算踩到幾個火焰
integer i;

reg [8:0] prev_fire_state;
reg [8:0] prev_box;
reg check_collision;

// 偵測 fire_state 和 box 的變化
always @(posedge clk or posedge rst) begin
    if (rst) begin
        prev_fire_state <= 9'b0;
        prev_box <= 9'b0;
        check_collision <= 0;
    end else begin
        prev_fire_state <= fire_state;
        prev_box <= box;
        // 當 fire_state 或 box 改變時，設置檢查標誌
        if (fire_state != prev_fire_state || box != prev_box) begin
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
                if (check_collision) begin  // 只在需要時計算碰撞
                    hit_count <= 0;
                    for (i = 0; i < 9; i = i + 1) begin
                        if (box[i] & fire_state[i]) begin
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

endmodule