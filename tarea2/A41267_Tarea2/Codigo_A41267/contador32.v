`timescale 1ns / 1ps

module contador32
(
input wire         iENB,        //ENB para el contador de 32 bits completo
input wire [1:0]   iMODO,       // MODO de operación
input wire         iCLK,        // CLK input
input wire         iReset,      // reset input
input wire [31:0]  iD,          // valor deseado de precarga
output wire        wRCO,         // RCO del contador de 32 bits
output reg [31:0]  oQ           //Salida del contador de 32 bits
);


wire [3:0] wQ_Cont0;       // salidas Qs de cada contador (8 salidas, porque son modulos de 4 bits c/u)
wire [3:0] wQ_Cont1;       // que se concatenan en una sola salida de 32 bits.       
wire [3:0] wQ_Cont2;
wire [3:0] wQ_Cont3;
wire [3:0] wQ_Cont4;
wire [3:0] wQ_Cont5;
wire [3:0] wQ_Cont6;
wire [3:0] wQ_Cont7;

wire         wCLK_Cont1;       // Los RCOs de cada contador se usan para 
wire         wCLK_Cont2;       // habilitar el siguiente contador de 4 bits
wire         wCLK_Cont3;
wire         wCLK_Cont4;
wire         wCLK_Cont5;
wire         wCLK_Cont6;
wire         wCLK_Cont7;      

reg [1:0]   wMod;            //modo temporal para el caso de MODO descendente 3 en 3            


 contador Cont0
(
	.iCLK(iCLK),
	.iReset(iReset),
	.iMODO( iMODO ),
	.iENB( iENB ),
	.iD( iD[3:0] ),
	.oRCO( wCLK_Cont1 ),
	.oQ( wQ_Cont0 )
);

 contador Cont1
(
	.iCLK(wCLK_Cont1),
	.iReset(iReset),
	.iMODO( wMod ),
	.iENB( iENB ),
	.iD( iD[7:4] ),
	.oRCO( wCLK_Cont2 ),
	.oQ( wQ_Cont1 )
);

 contador Cont2
(
	.iCLK(wCLK_Cont2),
	.iReset(iReset),
	.iMODO( wMod ),
	.iENB( iENB ),
	.iD( iD[11:8] ),
	.oRCO( wCLK_Cont3 ),
	.oQ( wQ_Cont2 )
);

 contador Cont3
(
	.iCLK(wCLK_Cont3),
	.iReset(iReset),
	.iMODO( wMod ),
	.iENB( iENB ),
	.iD( iD[15:12] ),
	.oRCO( wCLK_Cont4 ),
	.oQ( wQ_Cont3 )
);

 contador Cont4
(
	.iCLK(wCLK_Cont4),
	.iReset(iReset),
	.iMODO( wMod ),
	.iENB( iENB ),
	.iD( iD[19:16] ),
	.oRCO( wCLK_Cont5 ),
	.oQ( wQ_Cont4 )
);

 contador Cont5
(
	.iCLK(wCLK_Cont5),
	.iReset(iReset),
	.iMODO( wMod ),
	.iENB( iENB ),
	.iD( iD[23:20] ),
	.oRCO( wCLK_Cont6 ),
	.oQ( wQ_Cont5 )
);

 contador Cont6
(
	.iCLK(wCLK_Cont6),
	.iReset(iReset),
	.iMODO( wMod ),
	.iENB( iENB ),
	.iD( iD[27:24] ),
	.oRCO( wCLK_Cont7 ),
	.oQ( wQ_Cont6 )
);

 contador Cont7
(
	.iCLK(wCLK_Cont7),
	.iReset(iReset),
	.iMODO( wMod ),
	.iENB( iENB ),
	.iD( iD[31:28] ),
	.oRCO( wRCO),
	.oQ( wQ_Cont7 )
);

always@(iMODO)
begin
	case (iMODO)
		2'b00: wMod <= 00;       // contar ascendente
 		2'b01: wMod <= 01;       // contar descendente
	        2'b10: wMod <= 01;       // 3en3 descendente
		2'b11: wMod <= iMODO;    // usar numero precargado
		default: wMod <= iMODO;
	endcase
end //always combinacional



always @(posedge iCLK)
begin

     
        oQ = {wQ_Cont7, wQ_Cont6, wQ_Cont5, wQ_Cont4, wQ_Cont3, wQ_Cont2, wQ_Cont1, wQ_Cont0};
        $display("%b --- %H --- %d  iMODO %b wMod %b", oQ, oQ, oQ, iMODO, wMod);
end

endmodule
