//-----------------------------------------------------
// Tarea 2     : Test para contador sincronico de 4 bits
// Archivo     : testContador.v
// Descripcion : contador de 4 bits con tres diferentes MODOs de operacion
// Estudiante  : Mario Castresana Avendaño - A41267
//-----------------------------------------------------

`timescale 1ns / 1ps


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
    .oReset(wReset),
    .oENB(wENB),
    .oMODO(wMODO),
    .oD(wD)
);


 contador32 Cont32
(
	.iCLK(wCLK),
	.iReset(wReset),
	.iMODO( wMODO ),
	.iENB( wENB ),
	.iD( wD ),
	.wRCO( wRCO ),
	.oQ( wQ )
);

endmodule
