//-----------------------------------------------------
// Tarea 4     : Biblioteca de componentes para descripcion estructural (no incluye retardos ni tiempos de contaminacion)
// Archivo     : Collaterals.v
// Descripcion : Latch D, inversor, NAND2 y MUX 4 a 1 genérico
// Estudiante  : Mario Castresana Avendaño A41267
//-----------------------------------------------------
`timescale 1ns / 1ps
`define WIDTH 1

//Latch D Texas Instruments sn74lvc1g373
module DLATCH_P (E, D, Q);
input E, D;
output reg Q;

always @* 
begin
	if (E == 1)
		Q <= D;
end

endmodule



//inversor Texas Instruments 
module NOT (A, Y);
input A;
output Y;
assign Y = ~A;    //delay
endmodule

//NAND de 2 entradas Texas Instruments 
module NAND (A, B, Y);
input A, B;
output Y;
assign Y = ~(A & B);
endmodule


//Mux generico de 4 a 1 Texas Instruments OPA4872-EP
module MUXFULLPARALELL_2SEL_GENERIC # ( parameter SIZE=`WIDTH )
 (
 input wire [1:0] Sel,
 input wire [SIZE-1:0]I0, I1, I2,I3,
 output reg [SIZE-1:0] O
 );

always @( * )

  begin

    case (Sel)

      2'b00:  O = I0;
      2'b01:  O = I1;
      2'b10:  O = I2;
      2'b11:  O = I3;
      default: O = SIZE;

    endcase

  end
endmodule