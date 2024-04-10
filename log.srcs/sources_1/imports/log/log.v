`timescale	1ns/1ns
module log #(
    parameter I_BW = 30,
    parameter O_BW = 14,
    // parameter SHIFT_BY_FFT = 10
    parameter SHIFT_BY_FFT = 0,
    parameter LSB_I = -24,
    parameter LSB_O = -5
)(
    input signed [I_BW*64-1:0] data_i,
    output signed [O_BW*64-1:0] data_o
);

    function integer logb2;
        input [I_BW-1:0] antilogarithm;
        integer value;
        integer i;
        integer j;
        begin
            logb2 = 0;
            value = antilogarithm;
            j = 0;
            for (i=0; i<I_BW; i= i+1) begin
                if (value>1 | value*(-1)>1) begin
                    value = value >>> 1;
                    j = j+1;
                end
                else begin
                    j = j;
                end
            end
            logb2 = j;
            // logE = (logb2+SHIFT_BY_FFT+LSB_I) * 5/7;
        end
    endfunction

    function signed [O_BW-1:0] logE;
        input integer logb2;
        integer logE_shifted;
        logE_shifted = (logb2+SHIFT_BY_FFT+LSB_I) * (5/7<<<(-1)*(LSB_O));
        logE = (logE_shifted >>> ((-1)*LSB_O))[O_BW-1:0];
    endfunction

    function signed [O_BW*64-1:0] format_output;
        input signed [I_BW*64-1:0] input_bundle;
        integer i;
        integer j;
        integer k;
        reg signed [I_BW-1:0] input_partial;
        reg signed [O_BW-1:0] output_partial;

        for (i=0; i<64; i=i+1) begin
            for (j=0; j<I_BW; j=j+1) begin
                input_partial[j] = input_bundle[i*I_BW+j];
            end
            // output_partial = logb2(input_partial)[O_BW-1:0];
            output_partial = logE(input_partial);
            for (k=0; k<O_BW; k=k+1) begin
                format_output[i*O_BW+k] = output_partial[k];
            end
        end
    endfunction

    assign data_o = format_output(data_i);

endmodule