typedef logic signed [31:0] analog_tb_type;
`define analog_tb_t analog_tb_type

module sinc_gen #(
    parameter int MAX_AMP = 10_000,   // Peak-to-peak amplitude scaling
    parameter int LENGTH_N = 5000
)(
    input  logic    rst_ni,
    input  logic    refresh_i,
    output `analog_tb_t out_o
);

    // Parameters for 10ns repetition @ 2ps clock
    // Total samples per period = 10,000ps / 2ps = 5,000
    localparam real PI = 3.14159265359;

    // To see 10 periods (lobes) across the 10ns window:
    // We want x to go from -5.0 to +5.0
    localparam real X_RANGE = 10.0;

    int  sample_cnt;
    real x;
    real sinc_val;

    always_ff @(posedge refresh_i or negedge rst_ni) begin
        if (!rst_ni) begin
            sample_cnt <= 0;
            out_o      <= `analog_tb_t'(0);
        end else begin
            // 1. Increment sample counter (0 to 4999)
            if (sample_cnt >= LENGTH_N - 1)
                sample_cnt <= 0;
            else
                sample_cnt <= sample_cnt + 1;

            // 2. Map sample_cnt to x coordinate (-5.0 to +5.0)
            // x = (normalized_index * range) - offset
            x <= (real'(sample_cnt) / LENGTH_N * X_RANGE) - (X_RANGE / 2.0);

            // 3. Calculate Sinc(x)
            // Note: In DSP, sinc is often sin(pi*x)/(pi*x).
            // If x=0, the limit is 1.0.
            if (x > -0.00001 && x < 0.00001) begin
                sinc_val <= 1.0;
            end else begin
                sinc_val <= $sin(PI * x) / (PI * x);
            end

            // 4. Scale to output
            // Centering: (sinc * MAX_AMP) produces values from ~ -0.2*MAX to 1.0*MAX
            // If you want it strictly positive, keep the offset.
            out_o <= `analog_tb_t'(sinc_val * real'(MAX_AMP)) + MAX_AMP/2;
        end
    end

endmodule
