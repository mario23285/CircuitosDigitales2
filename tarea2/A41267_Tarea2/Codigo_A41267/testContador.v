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
wire [3:0] wD;
wire wENB_Cont1;
wire [3:0] wQ_Cont0;

      
// Instanciar Unit Under Test (UUT)
probador Test(
    .oCLK(wCLK),
    .oReset(wReset),
    .oENB(wENB),
    .oMODO(wMODO),
    .oD(wD)
);


 contador Cont0
(
	.iCLK(wCLK),
	.iReset(wReset),
	.iMODO( wMODO ),
	.iENB( wENB ),
	.iD( wD ),
	.oRCO( wENB_Cont1 ),
	.oQ( wQ_Cont0 )
);

endmodule
