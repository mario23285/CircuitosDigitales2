//-----------------------------------------------------
// Tarea 4     : Descripción estructural del contador de 32 bits: síntesis manual
// Archivo     : Cont_Est_32.v
// Descripcion : Módulo completo que representa un contador de 32 bits estructural
// Estudiante  : Mario Castresana Avendaño | A41267
//-----------------------------------------------------

`timescale 1ns / 1ps
`include "Cont_Est_4.v"



/*
DESCRIPCIÓN:
Este es un contador de 32 bits generado mediante el comando generate de Verilog.  Básicamente, se repite 32 veces un módulo sencillo
de 1 bit que contiene todos los módulos y la lógica necesaria para generar un solo contador de 32 bits sincrónico

CONTADOR_ESTRUCTURAL

	ENTRADAS:
	input wire         iENB,          // ENB para el contador de 32 bits completo
	input wire [1:0]   iMODO,         // MODO de operación
	input wire         iCLK,          // CLK input
	input wire [N-1:0]  iD,           // valor deseado de precarga
	
	SALIDAS:
	output wire         oRCO,         // RCO del contador de 32 bits
	output wire [N-1:0]  oQ           // Salida del contador de 32 bits


*/

module CONTADOR_ESTRUCTURAL # ( parameter N = 32 )
(
	input wire         iENB,          //ENB para el contador de 32 bits completo
	input wire [1:0]   iMODO,         // MODO de operación
	input wire         iCLK,          // CLK input
	input wire [N-1:0]  iD,           // valor deseado de precarga
	output wire         oRCO,         // RCO del contador de 32 bits
	output wire [N-1:0]  oQ           //Salida del contador de 32 bits
);
//--------

CONT_EST Cont32                //por default CONT_EST es de 32 bits, por eso se omite el parámetro N para instanciarlo
(
	.CLK(iCLK),
	.iENB(iENB),
	.inputCarry(1'b0),
	.iMODO(iMODO),
	.iAUX(-3),
	.iCarga(iD),
	.oNUM(oQ),
	.oRCO(oRCO)
);

/*------------------------------
Código para imprimir y debuggear

*****esto no es sintetizable*****

*/
always @(posedge iCLK)
begin	
    $display("%b --- %H --- %d  iMODO %b", oQ, oQ, oQ, iMODO);
end
//-----------------------------

endmodule