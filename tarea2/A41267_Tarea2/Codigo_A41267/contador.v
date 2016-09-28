//-----------------------------------------------------
// Tarea 2     : contador binario sincrónico
// Archivo     : contador.v
// Descripcion : contador de 4 bits con tres diferentes MODOs de operacion
// Estudiante  : Mario Castresana Avendaño A41267
//-----------------------------------------------------
`timescale 1ns / 1ps

module contador  # (parameter N = 4) 
 (
output reg [N-1:0] oQ=0,      // salida Q del contador, valor inicial 0
input wire         iENB,
input wire [1:0]   iMODO,         // MODO de operación
input wire         iCLK,          // CLK input
input wire         iReset,         // reset input
input wire [N-1:0] iD,         // valor deseado de precarga
output reg         oRCO

);

//-------------Aquí comienza el módulo------

wire [N-1:0] defVal = {N{1'b0}};

//siempre precargar un valor sin necesidad de esperar por el posedge

always@(iMODO==2'b11)
begin
    {oRCO,oQ} <= {1'b0,iD};
end //always combinacional



always @(posedge iCLK)
begin
	if (iReset) 
	begin                // resetear contador
	  oQ <= 0 ;
	end 
	else 
		if (iENB)
		begin
			case (iMODO)
				2'b00: {oRCO,oQ} <= oQ + 1;       // contar ascendente
		 		2'b01: {oRCO,oQ} <= oQ - 1;       // contar descendente
			        2'b10: {oRCO,oQ} <= oQ - 3;       // 3en3 descendente
				2'b11: {oRCO,oQ} <= {1'b0,iD};             // usar numero precargado
				default: {oRCO,oQ} <= {1'b0, defVal};
			endcase
		end
			
end// always
endmodule
