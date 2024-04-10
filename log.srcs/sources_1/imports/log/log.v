`timescale 1ns / 1ns
module log #(
    parameter I_BW = 26,
    parameter O_BW = 14,
    // parameter SHIFT_BY_FFT = 10
    parameter SHIFT_BY_FFT = 0,
    parameter LSB_I = -24,
    parameter LSB_O = -5
) (
    input  signed [I_BW-1:0] data_i,
    output signed [O_BW-1:0] data_o
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
      for (i = 0; i < I_BW; i = i + 1) begin
        // if (value>1 | value*(-1)>1) begin
        if (value > 0) begin
          value = value >>> 1;
          j = j + 1;
        end else begin
          j = j;
        end
      end
      logb2 = j + SHIFT_BY_FFT + LSB_I;
      // logE = (logb2+SHIFT_BY_FFT+LSB_I) * 5/7;
    end
  endfunction

  function signed [O_BW-1:0] logE;
    input integer logb2;
    reg signed [O_BW-1:0] logb2_shifted;
    reg signed [O_BW-1:0] logb2E_shifted;
    begin
      logb2_shifted = logb2[O_BW-1:0] <<<((-1)*(LSB_O)); // logb2はintegerだけど、出力は2**7~2**(-5)にしたい
    //   logb2E_shifted = (5 / 7) <<< ((-1) * (LSB_O));
      logE = logb2_shifted * 5/7;
    end
  endfunction

  assign data_o = logE(logb2(data_i));

endmodule
