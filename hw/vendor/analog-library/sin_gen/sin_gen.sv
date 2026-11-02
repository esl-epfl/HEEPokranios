`include "analog_defs.svh"
import analog_defs::analog_type;

module sin_gen #(
    parameter int AMP       = 2_000,   // Single-ended peak amplitude: 0.2 V
    parameter int VCM       = 5_000,   // Common-mode voltage: 0.5 V
    parameter int FREQ_HZ   = 1000,
    parameter int FS_HZ     = 1_000_000
)(
    input  logic       rst_ni,
    input  logic       refresh_i,
    output `analog_t out_p_o,
    output `analog_t out_n_o
);

    localparam real PI = 3.141592653589793;

    int  sample_cnt;

always_ff @(posedge refresh_i or negedge rst_ni) begin
    if (!rst_ni) begin
        sample_cnt <= 0;
        out_p_o    <= `analog_t'(VCM);
        out_n_o    <= `analog_t'(VCM);
    end else begin
        out_p_o <= `analog_t'(VCM + AMP * $sin(2.0 * PI * FREQ_HZ * real'(sample_cnt) / FS_HZ));
        out_n_o <= `analog_t'(VCM - AMP * $sin(2.0 * PI * FREQ_HZ * real'(sample_cnt) / FS_HZ));
        sample_cnt <= (sample_cnt >= FS_HZ/FREQ_HZ - 1) ? 0 : sample_cnt + 1;
    end
end

endmodule
