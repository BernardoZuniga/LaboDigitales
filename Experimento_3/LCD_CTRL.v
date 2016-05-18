`timescale 1ns / 1ps

`define STATE_RESET 0
`define STATE_POWERON_INIT_0 1
`define STATE_POWERON_INIT_1 2
`define STATE_POWERON_INIT_2 3
`define STATE_POWERON_INIT_3 4
`define STATE_POWERON_INIT_4 5
`define STATE_POWERON_INIT_5 6
`define STATE_POWERON_INIT_6 7
`define STATE_POWERON_INIT_7 8
`define STATE_POWERON_INIT_8 9



module Module_LCD_Control
(
input wire Clock,
input wire Reset,
output reg oLCD_Enabled,
output reg oLCD_RegisterSelect, //0=Command, 1=Data
output wire oLCD_StrataFlashControl,
output wire oLCD_ReadWrite,
output reg[3:0] oLCD_Data
);

//reg rWrite_Enabled;
assign oLCD_ReadWrite = 0; //I only Write to the LCD display, never Read from it
assign oLCD_StrataFlashControl = 1; //StrataFlash disabled. Full read/write access to LCD
reg [7:0] rCurrentState,rNextState;
reg [31:0] rTimeCount;
reg rTimeCountReset;
//wire wWriteDone;

//----------------------------------------------
//Next State and delay logic
always @ ( posedge Clock )
begin
		if (Reset)
			begin
				rCurrentState = `STATE_RESET;
				rTimeCount = 32'b0;
			end
		else
			begin
				if (rTimeCountReset)
				rTimeCount = 32'b0;
			else
				rTimeCount = rTimeCount + 32'b1;
		rCurrentState = rNextState;
		end
end
//----------------------------------------------
//Current state and output logic
always @ ( * )
	begin
		case (rCurrentState)
		//------------------------------------------
			`STATE_RESET:
			begin
				oLCD_Enabled = 1'b0;
				oLCD_Data = 4'h0;
				oLCD_RegisterSelect = 1'b0;
				rTimeCountReset = 1'b0;
				rNextState = `STATE_POWERON_INIT_0;
			end
		//------------------------------------------
		/*
		Wait 15 ms or longer.
		The 15 ms interval is 750,000 clock cycles at 50 MHz.
		*/
			`STATE_POWERON_INIT_0:
			begin
				oLCD_Enabled = 1'b0;
				oLCD_Data = 4'h3;
				oLCD_RegisterSelect = 1'b0; //these are commands
				if (rTimeCount > 32'd750000 )
					begin
					rTimeCountReset = 1'b1;
					rNextState = `STATE_POWERON_INIT_1;
					end
				else
					begin
					rTimeCountReset = 1'b0;
					rNextState = `STATE_POWERON_INIT_0;
					end
			end
//------------------------------------------
/*Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles
*/
			`STATE_POWERON_INIT_1:
			begin
				oLCD_Enabled = 1'b1;
				oLCD_Data = 4'h3;
				oLCD_RegisterSelect = 1'b0; //these are commands
				rTimeCountReset = 1'b1;
				if (rTimeCount > 32'd11 )
					begin
					rTimeCountReset = 1'b1;
					rNextState = `STATE_POWERON_INIT_2;
					end
				else
					begin
					rTimeCountReset = 1'b0;
					rNextState = `STATE_POWERON_INIT_1;
					end
			end
//------------------------------------------
/* Wait 4.1 ms or longer, which is 205,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_2:
		begin
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			if (rTimeCount > 32'd205000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_3;
			end
			else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_2;
			end
		end
//------------------------------------------
/*Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles
*/
		
		`STATE_POWERON_INIT_3:
		begin
		
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			rTimeCountReset = 1'b1;
			if (rTimeCount > 32'd11 )
				begin
				rTimeCountReset = 1'b1;
				rNextState = `STATE_POWERON_INIT_4;
				end
			else
				begin
				rTimeCountReset = 1'b0;
				rNextState = `STATE_POWERON_INIT_3;
				end
		end
//------------------------------------------
// Wait 100 us or longer, which is 5,000 clock cycles at 50 MHz.
		`STATE_POWERON_INIT_4:
		begin
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			if (rTimeCount > 32'd5000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_5;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_4;
			end
		end
//------------------------------------------
/*Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles
*/
		`STATE_POWERON_INIT_5:
		begin
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			rTimeCountReset = 1'b1;
			if (rTimeCount > 32'd11 )
				begin
				rTimeCountReset = 1'b1;
				rNextState = `STATE_POWERON_INIT_6;
				end
			else
				begin
				rTimeCountReset = 1'b0;
				rNextState = `STATE_POWERON_INIT_5;
				end
		end
//------------------------------------------
/* Wait 40 us or longer, which is 2,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_6:
		begin
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			if (rTimeCount > 32'd2000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_7;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_6;
			end
		end
//------------------------------------------
/*Write SF_D<11:8> = 0x2, pulse LCD_E High for 12 clock cycles
*/
		`STATE_POWERON_INIT_7:
		begin
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'h2;
			oLCD_RegisterSelect = 1'b0; //these are commands
			rTimeCountReset = 1'b1;
			if (rTimeCount > 32'd11 )
				begin
				rTimeCountReset = 1'b1;
				rNextState = `STATE_POWERON_INIT_8;
				end
			else
				begin
				rTimeCountReset = 1'b0;
				rNextState = `STATE_POWERON_INIT_7;
				end
		end
//------------------------------------------
/* Wait 40 us or longer, which is 2,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_8:
		begin
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd2000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_7;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			//rNextState = `STATE_POWERON_INIT_8;
			end
		end
//------------------------------------------
		default:
		begin
				oLCD_Enabled = 1'b0;
				oLCD_Data = 4'h0;
				oLCD_RegisterSelect = 1'b0;
				rTimeCountReset = 1'b0;
				rNextState = `STATE_RESET;
		end
//------------------------------------------
endcase
end
endmodule
