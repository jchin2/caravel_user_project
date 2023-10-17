// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module wb_port_test_1st #(
    parameter   [31:0]  BASE_ADDRESS    = 32'h30000000,        // base address
    parameter   [31:0]  KEY_0_ADDRESS   = BASE_ADDRESS,
    parameter   [31:0]  KEY_1_ADDRESS   = BASE_ADDRESS + 4, // 0x...4, ...1
    parameter   [31:0]  PLAIN_0_ADDRESS  = BASE_ADDRESS + 8, // 0x...8, ...10
    parameter   [31:0]  PLAIN_1_ADDRESS  = BASE_ADDRESS + 12, // 0x...c, ...11
    parameter   [31:0]  CMOS_OUT_0_ADDRESS  = BASE_ADDRESS + 16,
    parameter   [31:0]  CMOS_OUT_1_ADDRESS  = BASE_ADDRESS + 20,
	parameter   [31:0]  AL_OUT_0_ADDRESS  = BASE_ADDRESS + 24,
    parameter   [31:0]  AL_OUT_1_ADDRESS  = BASE_ADDRESS + 28,
    parameter   [31:0]  CONTROL_0_ADDRESS  = BASE_ADDRESS + 32  // For 
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input dischar1_clk_i,  
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,
    output [15:0] wbs_dat_o,
    //output wire [63:0] key_out,
    //output wire [63:0] plain_out,

    // IOs
    input wire [15:0] io_in,
    //output wire [15:0] io_out,
    output wire [15:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;
	wire dischar1;

    /*wire [15:0] in; //io_in;
    wire [15:0] out; //io_out;
    wire [15:0] oeb;//io_oeb;*/

	
    wire valid;
    wire [3:0] wstrb;
    wire [31:0] la_write;
    wire control_encom;
    wire control_enout;
    wire [63:0] key_in;
    wire [63:0] plain_in;

    //wire [63:0] key_out;
    //wire [63:0] plain_out;
    // WB MI A

    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    //assign wdata = wbs_dat_i[15:0];

    assign wbs_ack_o = valid ? ack_internal : 1'b0;
    assign wbs_dat_o = valid ? rdata : {WIDTH{1'bz}};

    // IRQ
    assign irq = 3'b000;	// Unused
	
	assign dischar1 = dischar1_clk_i;
    assign clk = wb_clk_i;
   
    //assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;
    
	assign rst = wb_rst_i;
	assign control_encom = storage[CONTROL_0_ADDRESS][0];    // 1 - Enable Encryption
	assign control_enout = storage[CONTROL_0_ADDRESS][1];    // 1 - Enable EE-SPFAL to GPIO
	assign control_outreg = storage[CONTROL_0_ADDRESS][5:2];  // One-hot encoding - Select one set (16-bits) of the EE-SPFAL to GPIO
	assign key[31:0] = storage[KEY_0_ADDRESS];
	assign key[63:32] = storage[KEY_1_ADDRESS];
	assign key[31:0] = storage[PLAIN_0_ADDRESS];
	assign key[63:32] = storage[PLAIN_1_ADDRESS];
	
	// 0 = enable the encryption & store in the output reg.
	// 1 = enable EE-SPFAL output to the GPIO.  

    //assign key_out = {storage[KEY_0_ADDRESS >> $clog2(WIDTH/8)], storage[KEY_1_ADDRESS >> $clog2(WIDTH/8)]};
    //assign plain_out = {storage[PLAIN_0_ADDRESS >> $clog2(WIDTH/8)], storage[PLAIN_1_ADDRESS >> $clog2(WIDTH/8)]};
    localparam DEPTH_LOG2 = 5;
    localparam ELEMENTS = 2**DEPTH_LOG2;
    localparam WIDTH = 32;
    
    reg [WIDTH-1:0] storage [ELEMENTS-1:0];
    reg ack_internal;
	reg wbs_write_done;
	reg wbs_read_done;
	reg comp_done;
	reg outGPIO_done;
	reg compu_begin;
    reg [31:0] rdata;
 ////////////////////////////////////////////////////////////////////////////////////////////////   
        
    
    // Wishbone Slave WRITE - write from read and sent to wishbone
    genvar i ;
    generate
    for (i=0; i<ELEMENTS; i=i+1) begin
        always @(posedge clk) begin
            if(rst) begin
                storage[i] <= {WIDTH{1'b0}}; 
        	end    
        end
    end
    endgenerate
    
    // moving the address bits we are looking at by 2 to the left
    always @(posedge clk) begin
		if(rst) begin
		    wbs_write_done <= 1'b0;
			comp_begin <= 1'b0;
			// Avoid repeating writing(reset valid takes)
        end else if(valid && wbs_we_i && !wbs_write_done && !ack_internal ) begin // && !o_wb_stall) begin
            case(wbs_adr_i)
                KEY_0_ADDRESS, KEY_1_ADDRESS, 
                PLAIN_0_ADDRESS, PLAIN_1_ADDRESS, 
                CONTROL_0_ADDRESS: begin
                    if (wstrb[0]) storage[wbs_adr_i[DEPTH_LOG2-1+$clog2(WIDTH/8):$clog2(WIDTH/8)]][7:0] <= wbs_dat_i[7:0];
                    if (wstrb[1]) storage[wbs_adr_i[DEPTH_LOG2-1+$clog2(WIDTH/8):$clog2(WIDTH/8)]][15:8] <= wbs_dat_i[15:8];
                    if (wstrb[2]) storage[wbs_adr_i[DEPTH_LOG2-1+$clog2(WIDTH/8):$clog2(WIDTH/8)]][23:16] <= wbs_dat_i[23:16];
                    if (wstrb[3]) storage[wbs_adr_i[DEPTH_LOG2-1+$clog2(WIDTH/8):$clog2(WIDTH/8)]][31:24] <= wbs_dat_i[31:24];
                end
            endcase
			// Set Write DONE Flag ON
			wbs_write_done <= 1'b1;

			// Set Encryption Operation Flag ON
			if(wbs_adr_i == CONTROL_0_ADDRESS)
				 control_begin <= 1'b1;
            else begin
			     wbs_write_done <= 1'b0;
			     control_begin <= 1'b0;
			end
		end
    end
    
    // Wishbone Slave READ - read from read and sent to wishbone
    always @(posedge clk) begin
		if(rst) begin
		    wbs_read_done <= 1'b0;
        end else if( valid && !wbs_we_i && !wbs_read_done && !ack_internal ) begin 
            case(wbs_adr_i)
                KEY_0_ADDRESS, KEY_1_ADDRESS,
                PLAIN_0_ADDRESS, PLAIN_1_ADDRESS,
                CMOS_OUT_0_ADDRESS, CMOS_OUT_1_ADDRESS, 
				AL_OUT_0_ADDRESS, AL_OUT_1_ADDRESS,
                CONTROL_0_ADDRESS:
                    rdata <= storage[wbs_adr_i[DEPTH_LOG2-1+$clog2(WIDTH/8):$clog2(WIDTH/8)]];
                default:
                    rdata <= 32'b0;
            endcase

			// Set READ DONE Flag ON
			wbs_read_done <= 1'b1;
        end else
			wbs_read_done <= 1'b0;
    end
    
    // Acknowledgement
    always @(posedge clk) begin
        if(rst)
            ack_internal <= 1'b0;
        else
            ack_internal <= valid && (wbs_read_done || wbs_write_done || comp_done || outGPIO_done); 
    end
	
    

	// Encryption Moudle Handler - Inputs
    // DLatch : Only Latch the Data after all data done loading and sent to Eneryption module
     DLatch CMOS_key_0 ( .D (key_in[31:0]), . clk(clk), .load(clk), .rst(rst), .Q(clk ));
     DLatch CMOS_key_1 ( .D(key_in[31:0]), .clk(clk), .load(), .rst(rst), .Q( ));	     
 	 DLatch CMOS_plain_0 ( .D(key_in[31:0]), .clk(clk), .load(), .rst(rst), .Q( ));
     DLatch CMOS_plain_1 ( .D(key_in[31:0]), .clk(clk), .load(), .rst(rst), .Q( ));
     
     DLatch_Q EE_SPFAL_key_0 ( .D(key_in[31:0]), .clk(clk), .load(), .rst(rst), .Q( ), .Qb( ));
     DLatch_Q EE_SPFAL_key_1 ( .D(key_in[31:0]), .clk(clk), .load(), .rst(rst), .Q( ), .Qb( ));
     DLatch_Q EE_SPFAL_plain_0 ( .D(key_in[31:0]), .clk(clk), .load(), .rst(rst), .Q( ), .Qb( ));
     DLatch_Q EE_SPFAL_plain_1 ( .D(key_in[31:0]), .clk(clk), .load(), .rst(rst), .Q( ), .Qb( ));
	
	
	always @(posedge dischar1) begin
        if(rst) begin
            comp_done <= 1'b0;
			
		 // Start comp, control_encom = 1
        end else if(control_begin && control_encom) begin
		    comp_done <= 1'b1;   // Computation is done
		    
		// 4-stages EE-SPFAL that the computation will take a full cycle -> Enable the Computation at discharge_1 is HIGH, Disable the Computation at discharge_1 is HIGH
		// End Comp, storing to reg
		end else if(comp_done && control_encom) begin
			comp_done <= 1'b0;  // Reset 

			//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
			// Currently the output reg are taking the inputs reg data as input // 
			//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

			storage[CMOS_OUT_0_ADDRESS] <= storage[KEY_0_ADDRESS];
			storage[CMOS_OUT_1_ADDRESS] <= storage[KEY_1_ADDRESS];
			storage[AL_OUT_0_ADDRESS] <= storage[PLAIN_0_ADDRESS];
			storage[AL_OUT_1_ADDRESS] <= storage[PLAIN_1_ADDRESS];
		end else 
			comp_done <= 1'b0;  // Reset 
    end
    
    // Encryption Moudle Handler  - Output
	always @(posedge dischar1) begin			
		// Send EE-SPFAL to GPIO, control_com = 1 
		if(rst) 
            outGPIO_done <= 1'b0;
		else if(control_enout) begin
		    case(control_outreg)
				1: GPIO_out <= storage[KEY_0_ADDRESS];
				2: GPIO_out <= storage[KEY_1_ADDRESS];
				4: GPIO_out <= storage[PLAIN_0_ADDRESS];
				8: GPIO_out <= storage[PLAIN_1_ADDRESS];
                default:
                   GPIO_out <= 16'bz;
            endcase
            outGPIO_done <= 1'b1;
         end else 
            outGPIO_done <= 1'b0;
         
	end	


endmodule
`default_nettype wire

module DLatch(
    input [31:0] D, // Data input 
    input clk, // clock input 
    input load,
    input rst, // synchronous reset 
    output reg [31:0] Q // output Q 
);

reg [31:0] Qb;

always @(posedge clk) 
begin
 if(rst) begin 
    Q <= 1'b0;
    Qb <= 1'b1;     
 end else if(load) begin
    Q <= D; 
    Qb <= ~D; 
 end
end 
endmodule 

module DLatch_Q(
    input [31:0]D, // Data input 
    input clk, // clock input 
    input load,
    input rst, // synchronous reset 
    output reg [31:0] Q, // output Q 
    output reg [31:0] Qb // output Q 
);

always @(posedge clk) 
begin
 if(rst) begin 
    Q <= 1'b0;
    Qb <= 1'b1;    
 end else if(load) begin
    Q <= D; 
    Qb <= ~D; 
 end
end 
endmodule 

	
