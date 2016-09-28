//-----------------------------------------------------
// Tarea 4     : Descripción estructural del contador de 32 bits: síntesis manual
// Archivo     : Cont_Est_4.v
// Descripcion : Módulo completo que representa un contador de 4 bits estructural
// Estudiante  : Mario Castresana Avendaño | A41267
//-----------------------------------------------------

`timescale 1ns / 1ps
`include "Basics.v"


/*
Aquí se incluyen los componentes más avanzados del sistema:
1- Sumador de N bits con acarreo SUMADOR_NN
2- Contador estructural de N bits con 4 modos de operacion CONT_EST


*/

/*
SUMADOR DE N BITS:
entradas:
iD >> N bits; es el dato de entrada que se está sumando constantemente para que el contador
	cuente de forma ascendente o descendente.
iX >> N bits; corresponde al numero que se debe sumar o restar de acuerdo al modo
iCarry >> 1 bit; carry de entrada

salidas:
oRCO >> 1 bit; acarreo de salida
oS  >> N bits; suma de iD + iX

*/


module SUMADOR_N # ( parameter N = 32 )
(
	input wire [N-1:0] iD,
	input wire [N-1:0] iX,
	input wire iCarry,
	output wire [N-1:0] oS,
	output wire oRCO
);

/*se ocupan N sumadores para cada bit

 Co | oS_N oS_N-1 ... oS1 oS0
 
 el acarreo de salida de cada sumador individual de 1 bit, se 
 conecta al acarreo de entrada del sumador siguiente
 
 oRCO -- + -C[N]- ... + -C2- + -C1- + -iCarry
*/

//variables para generate y para interconectar módulos
genvar i;
wire [N-1:0] C;                     //wires para cablear los acarreos entre sumadores

assign C[0]=1'b0; 

generate
	for(i=0; i<N; i=i+1)
	begin:SUMADOR
	
		if(i==N-1)
		begin
			SUMADOR1 SumMSB
			(
				.iA(iD[i]),
				.iB(iX[i]),
				.iCi(C[i]),
				.oCo(oRCO),
				.oSum(oS[i])
			);
		end
	
		else
		begin
			SUMADOR1 Sum
			(
				.iA(iD[i]),
				.iB(iX[i]),
				.iCi(C[i]),
				.oCo(C[i+1]),
				.oSum(oS[i])
			);
		end
	
	end


endgenerate

endmodule


/*
Contador de N bits con MODOs de operación y acarreo de salida:
las entradas del sumador son:
iMODO >> 2 bits; define que número se suma o resta en el sumador +1, -1, -AUX ó +0
	normalmente, en lugar de -AUX se usa -3 para contar de 3 en 3 descendente,
	pero esto no es el caso para todos los contadores de 4 bits, en especial
	cuando todos se ponen en serie para armar el de 32 bits, es decir, solo el
	primero debe restar 3, los otros deben restar 1.
	
	
iAUX >> N bits; es una entrada que me permite definir que valor restar cuando el contador entra en modo 10 
	para contar descendente de 3 en 3. Con esta entrada se facilita cambiar el número -3 por cualquier otro
	en caso que se quiera restar de 2 en 2 o algo diferente.
	
iCarga >> N bits; define un valor de precarga para el MODO 11
inputCarry >> es un acarreo de entrada en caso de que se quiera pegar a otros módulos.

CLK >> señal de reloj.

salidas:
oNUM >> N bits; valor numérico actual del contador. 
oRCO >> 1 bit; Ripple-Carry-Out 

Parámetros:

N : tamaño del contador en bits
*/

module CONT_EST # ( parameter N = 32 )
(
	input wire CLK,
	input wire iENB,
	input wire inputCarry,
	input wire [1:0] iMODO,
	input wire [N-1:0] iAUX,
	input wire [N-1:0] iCarga,
	output wire [N-1:0] oNUM,
	output wire oRCO
);

//wire de uso interno
wire [N-1:0] inX, inD, outS, cont_act_val;
wire cont_carry, RCOactual, Mode;

assign inD = oNUM;


//esta AND me define el bit de Mode dependiendo de si estamos contando (Mode=0) o precargando (Mode=1)
MOD_AND Entrada_selector
(
	.iA(iMODO[0]),
	.iB(iMODO[1]),
	.oY(Mode)
);

/*
multiplexor que define qué número se suma o resta en el SUMADOR

la salida define el valor de inX (una de las entradas que irá al sumador) de acuerdo al MODO:

inX = 0001 (+1) para MODO 00
inX = 1111 (-1) para MODO 01
inX = valor AUX para MODO 10
inX = 0000 (+0) para MODO 11   se suma 0 porque en MODO 11 se precarga un valor, no se cuenta nada.
*/
MOD_MUX #(N) MODOS
(
	.iSel(iMODO),
	.iI0(1), 
	.iI1(-1), 
	.iI2(iAUX), 
	.iI3(0),
	.Output(inX)
);

// del sumador salen outS que es el valor actual del contador y su carry cont_carry
SUMADOR_N #(N) Sum
(
	.iD(inD),
	.iX(inX),
	.iCarry(inputCarry),
	.oS(outS),
	.oRCO(cont_carry)
);


//Este es el mux de 2:1 que elige entre el valor actual del contador (y su acarreo de salida) o 
//el valor de precarga con carry = 0.
MOD_LOAD_SEL #(N) SUM_OUT
(
	.iSelect(Mode),
	.CLK(CLK),
	.iCARGA(iCarga),
	.iS(outS),
	.iC(cont_carry),
	.oMS(cont_act_val),
	.MRCO(RCOactual)
);


//Estos N+1 bits (cont_act_val + RCOactual) van al Registro de salida FF_REG_OUT
FF_SALIDA_N #(N) FF_REG_OUT
(
	.iX(cont_act_val),
	.CLK(CLK),
	.iRCO(RCOactual),
	.iEN(iENB),
	.oSalida(oNUM),
	.oCarry(oRCO)
);

endmodule