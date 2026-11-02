`include "analog_defs.svh"
import analog_defs::analog_type;

module iDAC_wrapper #() (
    input   logic       en_i,                     // Enable signal (active high)
    input   logic       refresh_i,                // Updates value_i on rising edge
    input   logic [4:0] cal_i,                    // Calibration control (5-bit)
    input   logic [7:0] value_i,                      // Digital input code (8-bit)
    /* verilator lint_off UNUSED */
    input   `analog_t   iin,
    output  `analog_t   iout,                        // Needs to be set as an input, otherwise would shortcircuit outside
    input   `analog_t   bvdd

    /* verilator lint_on UNUSED */
);


`ifdef SYNTHESIS

    iDAC u_iDAC(
        .DAC_REFRESH(refresh_i),
        .DAC_EN(en_i),
        .DAC_IN(value_i),
        .DAC_IIN(iin),
        .DAC_IOUT(iout),
        .DAC_TRM_DEBUG(),
        .BVDD(bvdd)
    );

`else

    logic [7:0] in_r;
    logic reset_in_r;

    real iout_real;

    int signed   iin_int;
    int unsigned in_int;
    int unsigned cal_int;
    int unsigned denom_int;
    int signed   iout_int;

    always_ff @(posedge refresh_i, negedge reset_in_r) begin
        if (reset_in_r == 1'b0) begin
            in_r <= '0;
        end else begin
            in_r <= value_i;
        end
    end

    always_comb begin
        iin_int   = iin;
        in_int    = {24'd0, in_r};
        cal_int   = {27'd0, cal_i};
        denom_int = 32'd95 - cal_int;

        if (en_i) begin
            reset_in_r = 1'b1;

            // Linear model for DAC output current
            iout_real = (8.0 * $itor(iin_int) * $itor(in_int)) / $itor(denom_int);
            iout_int  = $rtoi(iout_real);
            iout    = iout_int;

        end else begin
            reset_in_r = 1'b0;
            iout_real  = 0.0;
            iout_int   = 0;
            iout     = '0;
        end
    end

`endif


endmodule

