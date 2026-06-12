`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/01/02 14:45:14
// Design Name: 
// Module Name: bit_flipper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bit_flipper (
    input wire clk,
    input wire rst_n,
    input wire dme_in,
    input wire enable,
    output reg flip_end,
    output reg flip_out
);

    reg [2:0] state;
    reg [2:0] jam_cnt;      // 妨害回数を数える
    reg [2:0] jam_time;     // 5クロック妨害
    reg [2:0] wait_time;    // 5クロック待機
    reg       dme_prev;

    localparam IDLE     = 2'd0;
    localparam WAIT     = 2'd1;
    localparam PULSE    = 2'd2;
    localparam FINISH   = 2'd3;

    localparam JAM_TOTAL    = 3'd6; // 妨害する回数

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin // 非同期リセット
            state       <= IDLE;
            jam_cnt     <= 3'b0;
            jam_time    <= 2'b0;
            wait_time   <= 2'b0;
            flip_out    <= 1'b0;
            flip_end    <= 1'b0;
            dme_prev    <= dme_in;
        end else begin
            if(!enable)begin
                state       <= IDLE;
                jam_cnt     <= 3'b0;
                jam_time    <= 2'b0;
                wait_time   <= 2'b0;
                flip_out    <= 1'b0;
                flip_end    <= 1'b0;
            end else begin
                case(state)
                    IDLE: begin
                        if(dme_in != dme_prev) begin
                            state <= WAIT;
                        end
                    end

                    WAIT: begin
                        if(wait_time == 3'd4) begin
                            state <= PULSE;
                            flip_out <= 1'b1;
                        end else begin
                            wait_time <= wait_time + 3'd1;
                        end
                    end

                    PULSE: begin
                        if(jam_time == 3'd4) begin
                            jam_cnt <= jam_cnt + 3'd1;

                            if(jam_cnt + 3'd1 == JAM_TOTAL)begin
                                state <= FINISH;
                                jam_cnt         <= 1'b0;
                                jam_time        <= 2'b0;
                                wait_time       <= 2'b0;
                                flip_out    <= 1'b0;
                            end else begin
                                state <= IDLE;
                                jam_time        <= 2'b0;
                                wait_time       <= 2'b0;
                                flip_out    <= 1'b0;
                            end
                        end else begin
                            jam_time <= jam_time + 3'd1;
                        end
                    end

                    FINISH: begin
                        flip_end    <= 1'b1;
                    end

                endcase
            end
            dme_prev <= dme_in;
        end
    end

endmodule
