`include "../hdl/glitch_defs.v"

module glitch_wb(
    input wire          clk_i,
    input wire          rst_i,
    output reg          ack_o,
    input wire [7:0]    dat_i,
    input wire [3:0]    adr_i,
    output reg [7:0]    dat_o,
    input wire          stb_i,
    input wire          we_i,
    input wire          clk_in,
    output wire [5:0]	ch_out
);

wire clk_out;
assign ch_out[0] = clk_out;
reg en;
assign ch_out[1] = en;
wire ready;
assign ch_out[2] = ready;

assign ch_out[3] = clk_in;

wire glitch_en;
assign ch_out[4] = glitch_en;

wire delay_en;
assign delay_en = (!ready && !glitch_en);
assign ch_out[5] = delay_en;

reg [7:0] width;
reg [15:0] delay;

glitch glitchi(
    .clk(clk_i),
    .rst(rst_i),
    .width(width),
    .delay(delay),
    .en(en),
    .ready(ready),
    .clk_in(clk_in),
    .clk_out(clk_out),
    .glitch_en(glitch_en)
);

always @ (posedge clk_i)
begin
    if(rst_i)
    begin
        en <= 1'b0;
        width <= 8'b0;
        delay <= 16'b0;
    end
    else
    begin
        en <= 1'b0;
        width <= width;
        delay <= delay;
        delay <= delay;
        ack_o <= 1'b0;
        dat_o <= 8'b0;

        if (stb_i)
        begin
            case(adr_i)
                `GLITCH_STATUS:
                begin
                    if (we_i)
                    begin
                        // Write the status
                        en <= dat_i[0];
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the status
                        dat_o[0] <= ready;
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_WIDTH:
                begin
                    if (we_i)
                    begin
                        // Write the width
                        width <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the status
                        dat_o <= width;
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_DELAY_0:
                begin
                    if (we_i)
                    begin
                        // Write the delay[7:0]
                        delay[7:0] <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the delay[7:0]
                        dat_o <= delay[7:0];
                        ack_o <= 1'b1;
                    end
                end

                `GLITCH_DELAY_1:
                begin
                    if (we_i)
                    begin
                        // Write the delay[15:8]
                        delay[15:8] <= dat_i;
                        ack_o <= 1'b1;
                    end
                    else
                    begin
                        // Read the delay[15:8]
                        dat_o <= delay[15:8];
                        ack_o <= 1'b1;
                    end
                end
            endcase
        end
    end
end

endmodule