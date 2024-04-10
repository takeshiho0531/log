//----------------------------------------------------------------------
//	TB: FftTop Testbench
//----------------------------------------------------------------------
`timescale 1ns / 1ns
module TB;

  reg clk;
  reg rst;
  reg dio_en;

  reg [25:0] imem[0:63];
  reg [13:0] omem[0:63];
  // reg [31:0] omem[0:63];
  reg signed [25:0] data_i;
  wire signed [13:0] data_o;
  // integer data_o;

  //----------------------------------------------------------------------
  //	clk and rst
  //----------------------------------------------------------------------
  always begin
    clk = 0;
    #10;
    clk = 1;
    #10;
  end

  initial begin
    rst = 1;
    #20;
    rst = 0;
    #100;
    rst = 1;
  end

  //----------------------------------------------------------------------
  //	Functional Blocks
  //----------------------------------------------------------------------

  //	Input Control Initialize
  initial begin
    wait (rst == 0);
    dio_en = 0;
  end

  //	Output Data Capture
  initial begin : OCAP
    integer n;
    forever begin
      n = 0;
      while (dio_en !== 1) @(negedge clk);
      while ((dio_en == 1) && (n < 64)) begin
        omem[n] = data_o;
		    $display("dio_en=%d, data_i=%d, data_o=%d", dio_en, data_i, data_o/32);
        n = n + 1;
        @(negedge clk);
      end
    end
  end

  //----------------------------------------------------------------------
  //	Tasks
  //----------------------------------------------------------------------
  task LoadInputData;
    input [80*8:1] filename;
    begin
      $readmemb(filename, imem);
    end
  endtask

  task GenerateInputWave;
    integer n;
    begin
      for (n = 0; n < 64; n = n + 1) begin
        data_i <= imem[n];
        dio_en <= 1;
        @(posedge clk);
      end
    end
  endtask

  task SaveOutputData;
    input [80*8:1] filename;
    integer fp, n;
    begin
      fp = $fopen(filename);
      for (n = 0; n < 64; n = n + 1) begin
        $fdisplay(fp, "%b  // %d", omem[n], n[5:0]);
      end
      $fclose(fp);
    end
  endtask

  //----------------------------------------------------------------------
  //	Module Instances
  //----------------------------------------------------------------------
  log log (
      .data_i(data_i),
      .data_o(data_o)
  );

  //----------------------------------------------------------------------
  //	Test Stimuli
  //----------------------------------------------------------------------
  initial begin : STIM
    wait (rst == 0);
    wait (rst == 1);
    repeat (10) @(posedge clk);

    fork
      begin
        LoadInputData("input.txt");
        GenerateInputWave;
        @(posedge clk);
      end
      begin
        wait (dio_en == 1);
        repeat (64) @(posedge clk);
        SaveOutputData("output.txt");
        @(negedge clk);
      end
    join

    repeat (10) @(posedge clk);
    $finish;
  end
  initial begin : TIMEOUT
    repeat (1000) #20;  //  1000 clk Cycle Time
    $display("[FAILED] Simulation timed out.");
    $finish;
  end

endmodule
