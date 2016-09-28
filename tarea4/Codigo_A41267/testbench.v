//-----------------------------------------------------
// Tarea 4     : Descripción estructural del contador de 32 bits: síntesis manual
// Archivo     : testbench.v
// Descripcion : contador de 4 bits con 4 diferentes MODOs de operacion
// Estudiante  : Mario Castresana Avendaño - A41267
//-----------------------------------------------------

`timescale 1ns / 1ps

`include "Cont_Est_32.v"
`include "probador.v"




module testbench;


// Wires
wire wCLK;
wire wReset;
wire wENB;
wire [1:0] wMODO;
wire [31:0] wD;
wire wRCO;
wire [31:0] wQ;

      
// Instanciar Unit Under Test (UUT) para 32 bits
probador #(32) Test(
    .oCLK(wCLK),
    .oENB(wENB),
    .oMODO(wMODO),
    .oD(wD)
);


CONTADOR_ESTRUCTURAL Cont32
(
	.iENB(wENB),        //ENB para el contador de 32 bits completo
	.iMODO(wMODO),       // MODO de operación
	.iCLK(wCLK),        // CLK input
	.iD(wD),          // valor deseado de precarga
	.oRCO(wRCO),         // RCO del contador de 32 bits
	.oQ(wQ)           //Salida del contador de 32 bits
);

endmodule
