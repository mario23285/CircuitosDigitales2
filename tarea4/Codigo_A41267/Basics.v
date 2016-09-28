//-----------------------------------------------------
// Tarea 4     : Descripción estructural del contador de 4 bits: síntesis manual
// Archivo     : Basics.v
// Descripcion : Módulos más complejos hechos a base de la biblioteca estándar
//               Con este archivo se definen los módulos básicos que se usan para
//               construir el contador de 4 bits genérico.
// Estudiante  : Mario Castresana Avendaño | A41267
//-----------------------------------------------------

`timescale 1ns / 1ps
`include "Collaterals.v"


/*
A continuación se definen los módulos básicos:

1- Flip Flop de flanco positivo FFD_POSEDGE
2- Compuerta AND MOD_AND
3- Seleccionador de número de precarga MOD_LOAD_SEL
4- Registros de salida FF_SALIDA
5- Sumador básico de 1 bit con acarreo SUMADOR1
*/

/*FlipFlop de flanco positivo
Hecho con dos latches D y un inversor, se construyó un FlipFlop básico de 1 bit
para usarse en los registros de interés de nuestro contador sincrónico. Posee una entrada
Enable para dejar el valor anterior a la salida.
*/  
module FFD_POSEDGE
(
	input wire				CLK,
	input wire				Enable,
	input wire             	D,
	output wire 	        Q
);

wire salida_LD1;
wire CLK_NEG;
wire Qoutput;


NOT inversor
(
	.A(CLK),
	.Y(CLK_NEG)
);


DLATCH_P LD1 
(
	.E(CLK_NEG),
	.D(D),
	.Q(salida_LD1)
);

DLATCH_P LD2 
(
	.E(CLK),
	.D(salida_LD1),
	.Q(Qoutput)
);

//este Latch es controlado por la señal de Enable, haciendo que si esta Enable = 1,
//el Latch sea transparente y se vea la salida del FlipFlop y si no, se vea el estado anterior.
DLATCH_P Qexit 
(
	.E(Enable),
	.D(Qoutput),
	.Q(Q)
);


endmodule

/*Compuerta AND
Hecha con una NAND con un inversor a la salida
*/

module MOD_AND
(
	input wire iA,
	input wire iB,
	output wire oY
);

wire salida_nand;

NAND NoY
(
	.A(iA),
	.B(iB),
	.Y(salida_nand)

);

NOT inv
(
	.A(salida_nand),
	.Y(oY)
);

endmodule


/*Multiplexor de N bits de ancho MOD_MUX
Este dispositivo me permite elegir una de cuatro entradas, mediante el uso de dos bits de selección.
Cada entrada es de N bits de ancho [N-1:0] al igual que la salida y se construirá usando MUX de 4:1

Este MUX se usa para definir, según el modo de operación, que número entra en el sumador de 4 bits básico
MODO 00 >> +1
MODO 01 >> -1
MODO 10 >> -3
MODO 11 >> +0

También se reutiliza para seleccionar salida del sumador de 4 bits y elegir entre mostrar el resultado de la
suma para seguir sumando o escoger el valor de precarga.
*/

module MOD_MUX # ( parameter N = 32 )
(
	input wire [1:0] iSel,
	input wire [N-1:0] iI0, iI1, iI2, iI3,
	output wire [N-1:0] Output
);

/*
Mediante generate se crean N MUXES para seleccionar entre los valores que corresponden a cada MODO de operación;
cada valor es de N bits y la salida también.

se genera un MUX desde el LSB hasta el MSB
*/

genvar i;

generate
	for(i=0; i<N; i=i+1)
	begin:MUXES
		MUXFULLPARALELL_2SEL_GENERIC MUX1
		(
			.Sel(iSel),
			.I0(iI0[i]),
			.I1(iI1[i]),
			.I2(iI2[i]),
			.I3(iI3[i]),
			.O(Output[i])
		);
	end
endgenerate

endmodule


/*
Seleccionador de número de precarga 
MOD_LOAD_SEL

inputs:
iCARGA >> N bits; número de precarga definido por el usuario.
iS >> N bits; salida del sumador.
iC >> 1 bit; bit de acarreo del sumador.
iSelect >> 1 bit; selecciona entre la salida del sumador para seguir contando (iSelect=0) o el número de precarga (iSelect=1)
CLK >> clock del sistema para sincronizar la selección 

outputs:
la salida es de N+1 bits: N del numero + 1 bit del carry proveniente del sumador.
oMS >> N bits; salida del multiplexor
MRCO >> 1 bit; carry de salida del sumador

Este módulo en escencia es una multiplexor de 2 a 1, que elige entre la salida del sumador de N bits o el número de precarga (iCARGA) que se
le ponga al contador. En caso de elegir el número de precarga iCARGA, el carry a la salida del mux MRCO se pondrá a cero. 

*/

module MOD_LOAD_SEL # ( parameter N = 32 )
(
	input wire iSelect,
	input wire CLK,
	input wire [N-1:0] iCARGA,
	input wire [N-1:0] iS,
	input wire iC,
	output wire [N-1:0] oMS,
	output wire MRCO
);

wire bitSelector;
wire [1:0] iSel;
assign iSel = {bitSelector, bitSelector};


//La entrada de selección debe sincronizarse con el resto del circuito, por eso usamos un FlipFlop
FFD_POSEDGE FF_SEL
(
	.CLK(CLK),
	.Enable(1'b1),
	.D(iSelect),
	.Q(bitSelector)
);

genvar i;

generate
	for(i=0; i<N; i=i+1)
	begin:ME
		MUXFULLPARALELL_2SEL_GENERIC MExit
		(
			.Sel(iSel),
			.I0(iS[i]),
			.I1(iS[i]),
			.I2(iS[i]),
			.I3(iCARGA[i]),
			.O(oMS[i])
		);
	end
endgenerate

//Bit del acarreo proveniente del sumador

MUXFULLPARALELL_2SEL_GENERIC MUX_RCO
(
	.Sel(iSel),
	.I0(iC),
	.I1(iC),
	.I2(iC),
	.I3(1'b0),
	.O(MRCO)
);

endmodule


/*
Registros de salida FF_SALIDA_N
Esta es la parte más importante para asegurarnos que el contador tiene caracter sincrónico 
ya que al guardar los resultados en este registro, todo el circuito del contador se 
sincroniza.


El modulo recibe los N bits de salida del sumador de N bits o los N bits de CARGA, más
el carry (iRCO) del sumador, Enable (iEN) y el Clock.

 FF_SALIDA_N 

 ENTRADAS:
 
	input wire [N:0] iX,
	input wire CLK,
	input wire iRCO,
	input wire iEN,
	
SALIDAS:
	output wire [N:0] oSalida,
	output wire oCarry

PARÁMETROS:

	N: define el número de bits con el que se trabaja; lo usa el comando generate interno

*/

module FF_SALIDA_N # ( parameter N = 32 )
(
	input wire [N-1:0] iX,
	input wire CLK,
	input wire iRCO,
	input wire iEN,
	output wire [N-1:0] oSalida,
	output wire oCarry
);

//FlipFlop que recibe el resultado de la suma
//LSB X0 -------------------- MSB X_N

//variables para generate y para interconectar módulos
genvar i;

generate
	for(i=0; i<N; i=i+1)
	begin:REGS
		FFD_POSEDGE FFD0
		(
			.CLK(CLK),
			.Enable(iEN),
			.D(iX[i]),
			.Q(oSalida[i])
		);		
	end
endgenerate


FFD_POSEDGE FFD_RCO
(
	.CLK(CLK),
	.Enable(iEN),
	.D(iRCO),
	.Q(oCarry)
);

endmodule

/* Módulo sumador de 1 bit
Este módulo es un sumador básico de 1 bit hecho a base de multiplexores de 4:1
Las funciones lógicas para calcular el resultdo de la suma y el acarreo con fáciles
de implementar con multiplexores de 4:1
	
	entradas:
	input wire iA,        sumando 1
	input wire iB,        sumando 2
	input wire iCi,       acarreo de entrada
	
	salidas:
	output reg oCo,       acarreo de salida
	output reg oSum       iA+iB=oSum
*/

module SUMADOR1
(
	input wire iA,
	input wire iB,
	input wire iCi,
	output wire oCo,
	output wire oSum
);

/*Se usarán dos muxes: uno para la lógica de Suma
y otro para la lógica del acarreo de salida oCo

La variable S es para unir los sumandos A y B en una variable de 2 bits que funcionará como selector de ambos muxes
notCi es Ci negado (se ocupa en dos ocasiones)

*/
wire [1:0] S;
wire notCi;

assign S = {iA, iB};

NOT negCi
(
	.A(iCi),
	.Y(notCi)
); 

MUXFULLPARALELL_2SEL_GENERIC SUM
(
	.Sel(S),
	.I0(iCi),
	.I1(notCi),
	.I2(notCi),
	.I3(iCi),
	.O(oSum)
);

MUXFULLPARALELL_2SEL_GENERIC Co
(
	.Sel(S),
	.I0(1'b0),
	.I1(iCi),
	.I2(iCi),
	.I3(1'b1),
	.O(oCo)
);

endmodule
