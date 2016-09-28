//-----------------------------------------------------
// Tarea 4     : Descripción estructural del contador de 32 bits: síntesis manual
// Archivo     : probador.v
// Descripcion : generador de estimulos para el contador
// Estudiante  : Mario Castresana Avendaño - A41267
//-----------------------------------------------------


module probador # (parameter N = 4)
(


output reg oCLK,         // outputs
output reg oENB,
output reg [1:0] oMODO,
output reg [N-1:0] oD

);

wire [N-1:0] loadVal = {{(N/2){1'b0}},{(N/2){1'b1}}};    //valor de precarga al contador

// Generar CLK
always
begin
    #5 oCLK= ! oCLK;
end

//Generar pruebas
 initial begin
		//dumps
		$dumpfile("testContador.vcd");
		$dumpvars(0,testbench);
                // Initialize Inputs
                oCLK = 0;            //prueba contar ascendente
                oENB = 1;

                #50
                oMODO = 2'b11;
                $display("precargar valor (modo %b) 0x0000FFFF", oMODO);
                oD = loadVal;     //prueba precargar un valor D y contar ascendente a partir de ahí
                #50
                oMODO = 2'b00;
                $display("contar ascendente (modo %b)", oMODO);

                #3000                    //prueba contar descendente
                oMODO = 2'b01;
                $display("contar descendente (modo %b)", oMODO);

                #2000                    //prueba contar 3en3 descendente
                oMODO = 2'b10;
                $display("contar descendente de 3 en 3 (modo %b)", oMODO);

                #2000                    
                oMODO = 2'b11;           //precargar y contar desde ahí
                oD = loadVal;
                $display("precargar valor (modo %b) 0x0000FFFF", oMODO);
                #50
                oMODO = 2'b00;
                #2000
                $display("-----FIN------");
		$finish(2);
        end
endmodule
