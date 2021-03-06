//Mauricio Jos� Valverde Monge A76674
//Francisco Andr�s Vargas Piedra A76821
//Collaterals.v Modificado para Laboratorio de Circuitos Digitales I

`timescale 1ns / 1ps

//------------------------------------------------
// M�dulo del contador que se incrementa en 1 para 
// llevar el orden de las instrucciones a ejecutar.
module UPCOUNTER_POSEDGE # (parameter SIZE=16)
(
input wire Clock, Reset,
input wire [SIZE-1:0] Initial,
input wire Enable,
output reg [SIZE-1:0] Q
);


  always @(posedge Clock )
  begin
      if (Reset)
        Q = Initial;
      else
		begin
		if (Enable)
			Q = Q + 1;
			
		end			
  end

endmodule
//----------------------------------------------------
// M�dulo de un flip-flop D de flanco positivo 
module FFD_POSEDGE_SYNCRONOUS_RESET # ( parameter SIZE=8 )
(
	input wire				Clock,
	input wire				Reset,
	input wire				Enable,
	input wire [SIZE-1:0]	D,
	output reg [SIZE-1:0]	Q
);
	
always @ (posedge Clock) 
begin
	if ( Reset )
		Q <= 0;
	else
	begin	
		if (Enable) 
			Q <= D; 
	end	
 
end//always

endmodule
//----------------------------------------------------------------------
// M�dulo VGA controller
module VGA_controller
(
	input wire				Clock_lento,
	input wire 				Reset,
	input wire	[2:0]		iVGA_RGB,
	input wire  [2:0]		iColorCuadro,
	input wire  [9:0]		iXRedCounter,
	input wire  [9:0]		iYRedCounter,
	output wire	[2:0]		oVGA_RGB,
	output wire				oHsync,
	output wire				oVsync,
	output wire [9:0]		oVcounter,
	output wire [9:0]		oHcounter
);
wire iVGA_R, iVGA_G, iVGA_B;
wire oVGA_R, oVGA_G, oVGA_B;
wire wEndline;
wire [3:0] wMarco; //, wCuadro;
wire [2:0] wVGAOutputSelection;
reg [9:0] puntero1, puntero2;
reg [23:0] contador1, contador2;
assign wMarco = 3'b0;
//assign wCuadro = 3'b100;

initial begin
	puntero1 <= 10'b0;
	puntero2 <= 10'd96;
	contador1 <= 24'b0;
	contador2 <= 24'b0;
end

always @ (posedge Clock_lento ) begin
	if (contador1 >= 23'd45000000) begin
		puntero1 <= puntero1 + 10'd32;
		puntero2 <= puntero2;
		contador1 <= 24'b0;
		contador2 <= contador2;
		end
	else if (contador2 >= 23'd40000000) begin
		puntero2 <= puntero2 + 10'd32;
		puntero1 <= puntero1;
		contador1 <= contador1;
		contador2 <= 24'b0;
		end 
	else begin
		puntero1 <= puntero1;
		puntero2 <= puntero2;
		contador1 <= contador1 + 24'b1;
		contador2 <= contador2 + 24'b1;
		end
end


assign wVGAOutputSelection = ( 
										 (((oHcounter >= iXRedCounter + 10'd272) && (oHcounter <= iXRedCounter + 10'd272 + 10'd31)) &&
										 ((oVcounter >= iYRedCounter + 10'd333) && (oVcounter <= iYRedCounter + 10'd333 + 10'd31))) ||	
										 (((oHcounter >= iXRedCounter + 10'd272) && (oHcounter <= iXRedCounter + 10'd272 + 10'd31)) &&
										 ((oVcounter >= iYRedCounter + 10'd397) && (oVcounter <= iYRedCounter + 10'd397 + 10'd31))) ||
										 (((oHcounter >= iXRedCounter + 10'd240) && (oHcounter <= iXRedCounter + 10'd240 + 10'd31)) &&
										 ((oVcounter >= iYRedCounter + 10'd429) && (oVcounter <= iYRedCounter + 10'd429 + 10'd31))) ||
										 (((oHcounter >= iXRedCounter + 10'd240) && (oHcounter <= iXRedCounter + 10'd240 + 10'd31)) &&
										 ((oVcounter >= iYRedCounter + 10'd365) && (oVcounter <= iYRedCounter + 10'd365 + 10'd31)))||
										 (((oHcounter >= iXRedCounter + 10'd304) && (oHcounter <= iXRedCounter + 10'd304 + 10'd31)) &&
										 ((oVcounter >= iYRedCounter + 10'd365) && (oVcounter <= iYRedCounter + 10'd365 + 10'd31))) ||
										 (((oHcounter >= iXRedCounter + 10'd304) && (oHcounter <= iXRedCounter + 10'd304 + 10'd31)) &&
										 ((oVcounter >= iYRedCounter + 10'd429) && (oVcounter <= iYRedCounter + 10'd429 + 10'd31))) ||
										 (((oHcounter >= 10'd272) && (oHcounter <= 10'd272 + 10'd31)) &&
										 ((oVcounter >= 10'd77 + puntero1) && (oVcounter <= 10'd77 + puntero1 + 10'd31))) ||
										 (((oHcounter >= 10'd368) && (oHcounter <= 10'd368 + 10'd31)) &&
										 ((oVcounter >= 10'd77 + puntero2) && (oVcounter <= 10'd77 + puntero2 + 10'd31))) 
										 ) ?	iColorCuadro : {iVGA_R, iVGA_G, iVGA_B}; //Cuadro central
																			

assign iVGA_R = iVGA_RGB[2];
assign iVGA_G = iVGA_RGB[1];
assign iVGA_B = iVGA_RGB[0];
assign oVGA_RGB = {oVGA_R, oVGA_G, oVGA_B};

assign oHsync = (oHcounter < 704) ? 1'b1 : 1'b0;
assign wEndline = (oHcounter == 799);
assign oVsync = (oVcounter < 528) ? 1'b1 : 1'b0;

// Marco negro e imagen de 320*384
assign {oVGA_R, oVGA_G, oVGA_B} = (oVcounter < 77 || oVcounter >= 461 || 
					  oHcounter < 208 || oHcounter > 464) ? 
					  wMarco : wVGAOutputSelection;

UPCOUNTER_POSEDGE # (10) HORIZONTAL_COUNTER
(
.Clock	(   Clock_lento   ), 
.Reset	( (oHcounter > 799) || Reset 		),
.Initial	( 10'b0  			),
.Enable	(  1'b1				),
.Q			(	oHcounter      )
);

UPCOUNTER_POSEDGE # (10) VERTICAL_COUNTER
(
.Clock	( Clock_lento    ), 
.Reset	( (oVcounter > 528) || Reset ),
.Initial	( 10'b0  			),	
.Enable	( wEndline            ),
.Q			( oVcounter      )
);

endmodule
//----------------------------------------------------------------------
// M�dulo PS2 controller
module PS2_Controller 
(
	input wire Reset,
	input wire PS2_CLK,
	input wire PS2_DATA,
	output reg [9:0] XRedCounter,
	output reg [9:0] YRedCounter,
	output reg [2:0] ColorReg
);

`include "Defintions.v"

reg [7:0] ScanCode;
reg [8:0] rDataBuffer;
reg Done, Read;
reg [3:0] ClockCounter;
reg rFlagF0, rFlagNoError;

always @ (negedge PS2_CLK or posedge Reset) begin
	if (Reset) begin
		ClockCounter <= 0;
		Read <= 1;
		Done <= 0;
		end
	else begin
		if (Read == 1'b1 && PS2_DATA == 1'b0) begin
			Read <= 0;
			Done <= 0;
			end
		else if (Read == 1'b0) begin
			if (ClockCounter < 9) begin
				ClockCounter <= ClockCounter + 1;
				rDataBuffer <= {PS2_DATA, rDataBuffer[8:1]};
				Done <= 0;
				end
			else begin
				ClockCounter <= 1'b0;
				Done <= 1;
				ScanCode <= rDataBuffer[7:0];
				Read <= 1;
				if (^ScanCode == rDataBuffer[8])
					rFlagNoError <= 1'b0;
				else 
					rFlagNoError <= 1'b1;
				end
			
		end
	end
end

always @ (posedge Done or posedge Reset) begin
	if (Reset) begin
		XRedCounter <= 9'b0;
		YRedCounter <= 9'b0;
		rFlagF0 <= 1'b0;
		ColorReg <= 3'b1;
		end
	else begin
		if (rFlagF0) begin
			rFlagF0 <= 1'b0;
		end
		else
		case (ScanCode)
			`IZQ: begin
				YRedCounter <= YRedCounter;
				XRedCounter <= 10'd0;
				rFlagF0 <= rFlagF0;
				ColorReg <= ColorReg;
			end
			
			`DER: begin
				YRedCounter <= YRedCounter;
				XRedCounter <= 10'd96;
				rFlagF0 <= rFlagF0;
				ColorReg <= ColorReg;
			end
			
			
			
			8'hF0: begin	//Se�al de finalizacion del PS2
				YRedCounter <= YRedCounter;
				XRedCounter <= XRedCounter;			
				rFlagF0 <= 1'b1;
				ColorReg <= ColorReg;
			end
			
			8'h29: begin	//29 = Barra Espaciadora
				ColorReg <= ColorReg + 3'b1;
				YRedCounter <= YRedCounter;
				XRedCounter <= XRedCounter;				
				rFlagF0 <= rFlagF0;
			end
			
			default: begin
				YRedCounter <= YRedCounter;
				XRedCounter <= XRedCounter;
				rFlagF0 <= rFlagF0;
				ColorReg <= ColorReg;
			end
		endcase
	end
end

endmodule 