module TOP(
    input wire CLK_i;
    output SERIAL_o;
);

enum logic{
    A,
    B,
    C,
    D,
    E,
    F
}var state, next_state;

wire A;

genvar i;

for (i=0;i<NUM; i++)

    A out();

case (STATE) begin
  'ABL_IDLE:
    next_state <= 1'b001;

  default: 
    next_state <= 1'b000;
endcase

if (~RESET) begin
    BLOW_UP;
end