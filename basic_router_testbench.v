
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.05.2023 16:39:54
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench ;


   reg clk1,clk2,reset; 
  
  reg wr_en_e  ,  rd_en_e;                                               // common for all 4 VCs of East Port
  reg [127:0] bf_in_e;                                              // Input to the East Buffer
  wire [127:0] bf_out_e;                                             // Output of the East Buffer 
  wire [2:0] em_pl_e1,em_pl_e2,em_pl_e3,em_pl_e4;                    // Empty Slots of the VCs in East Port
  wire [2:0] add_wr_e;                                               // read address register of the East Port
  wire [2:0] add_rd_e ;                                               // write address register of the East Port
  
  reg wr_en_w  ,  rd_en_w;                                               // common for all 4 VCs of West Port
  reg [127:0] bf_in_w;                                              // Input to the West Buffer
  wire [127:0] bf_out_w;                                             // Output of the West Buffer 
  wire [2:0] em_pl_w1,em_pl_w2,em_pl_w3,em_pl_w4;                    // Empty Slots of the VCs in West Port
  wire [2:0] add_wr_w;                                               // read address register of the West Port
  wire [2:0] add_rd_w;                                             // write address register of the West Port

  reg wr_en_n  ,  rd_en_n;                                               // common for all 4 VCs of North Port
  reg [127:0] bf_in_n;                                              // Input to the North Buffer
  wire [127:0] bf_out_n;                                             // Output of the North Buffer 
  wire [2:0] em_pl_n1,em_pl_n2,em_pl_n3,em_pl_n4;                    // Empty Slots of the VCs in North Port
  wire [2:0] add_wr_n;                                               // read address register of the North Port
  wire  [2:0] add_rd_n;                                               // write address register of the North Port
  
  reg wr_en_s  ,  rd_en_s;                                               // common for all 4 VCs of South Port
  reg [127:0] bf_in_s;                                              // Input to the South Buffer
  wire [127:0] bf_out_s;                                             // Output of the South Buffer 
  wire [2:0] em_pl_s1,em_pl_s2,em_pl_s3,em_pl_s4;                    // Empty Slots of the VCs in South Port
  wire [2:0] add_wr_s;                                               // read address register of the South Port
  wire [2:0] add_rd_s ;   
  
  reg wr_en_t  ,  rd_en_t;                                               // common for all 4 VCs of Local Port
  reg [127:0] bf_in_t;                                              // Input to the Local Buffer
  wire [127:0] bf_out_t;                                             // Output of the Local Buffer 
  wire [2:0] em_pl_t1,em_pl_t2,em_pl_t3,em_pl_t4;                    // Empty Slots of the VCs in Local Port
  wire [2:0] add_wr_t;                                               // read address register of the Local Port
  wire [2:0] add_rd_t;       
  
  wire [3:0] north_route;
  wire [3:0] south_route;
  wire [3:0] east_route;
  wire [3:0] west_route;
  wire [3:0] local_route;     
  wire [127:0] OE,OW,ON,OS,Eject;
  wire [2:0] east_out,west_out, north_out,south_out,local_out;

  
 

router_new dut ( clk1,clk2,reset,
                 wr_en_e,rd_en_e,bf_in_e,bf_out_e,em_pl_e1,em_pl_e2,em_pl_e3,em_pl_e4,add_wr_e,add_rd_e,
                 wr_en_w,rd_en_w,bf_in_w,bf_out_w,em_pl_w1,em_pl_w2,em_pl_w3,em_pl_w4,add_wr_w,add_rd_w,
                 wr_en_n,rd_en_n,bf_in_n,bf_out_n,em_pl_n1,em_pl_n2,em_pl_n3,em_pl_n4,add_wr_n,add_rd_n,
                 wr_en_s,rd_en_s,bf_in_s,bf_out_s,em_pl_s1,em_pl_s2,em_pl_s3,em_pl_s4,add_wr_s,add_rd_s,
                 wr_en_t,rd_en_t,bf_in_t,bf_out_t,em_pl_t1,em_pl_t2,em_pl_t3,em_pl_t4,add_wr_t,add_rd_t,
                 north_route,south_route,east_route,west_route,local_route,
                 vc_grant_d_E,vc_grant_d_W,vc_grant_d_N,vc_grant_d_S,vc_grant_d_T ,
                 east_out,west_out, north_out,south_out,local_out, 
                 OE,OW,ON,OS,Eject
                                 
                                 
                                 
                                 
                                 
                                 );
                                                                                                     


// Clock generation
 // always #5 clk = ~clk;
          initial 
            begin 
               forever 
                    begin
                       clk1 = 0;
                       clk2 = 0;
                       #5 clk1 = 1;
                       #5 clk1 = 0;
                       #5 clk2 = 1;
                       #5;
                   end
            end
  // Initial values
  initial begin
   //  clk = 0; 
    reset = 1;
    #10 reset = 0; 
         wr_en_e = 0 ;  rd_en_e=0;
         wr_en_w = 1 ;  rd_en_w=0;
         wr_en_s = 0 ;  rd_en_s=0;
         wr_en_n = 0 ;  rd_en_n=0;
         wr_en_t = 0 ;  rd_en_t=0;
         
    #15 bf_in_w = {3'b111,3'b111,8'b0,8'b10011111,100'b11110 , 6'b0};
       // bf_in_e ={3'b011,3'b111,120'b101,2'b11};
       // bf_in_s ={3'b101,3'b010,120'b101,2'b01};
       // bf_in_n = 128'bx;
       // bf_in_t = 128'bx;
 
    
    // Deassert reset
    
    // Test case 1: Writing and reading from the buffer
    #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b01110 , 6'b0};
        //bf_in_e = {120'b111,6'b000001,2'b11};
        //bf_in_s = {120'b111,6'b000001,2'b01};
        
    #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b1111 , 6'b0};
        //bf_in_e = {126'b011,2'b11};
        //bf_in_s = {126'b011,2'b01};
        
    
    // Test case 2: Buffer full scenario
    #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b0 , 6'b0};
        //bf_in_e ={120'b100,6'b1,2'b11};
        //bf_in_s ={120'b100,6'b1,2'b01};
    #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b010101 , 6'b0};
        //bf_in_e = {115'b11,10'b01,3'b011};
        //bf_in_s = {115'b11,10'b01,3'b001};
   // #10 bf_in=128'bx;
    #20 wr_en_w = 0 ;  rd_en_w=1; bf_in_w=128'bx;
      //  wr_en_e = 0 ;  rd_en_e=1; bf_in_e=128'bx;
      //  wr_en_s = 0 ;  rd_en_s=1; bf_in_s=128'bx;
     #100  wr_en_w = 1 ;  rd_en_w=0;
            reset = 1;
           #10 reset = 0;
           wr_en_e = 0 ;  rd_en_e=0;
           wr_en_s = 0 ;  rd_en_s=0;
           
      #10 bf_in_w = {3'b111,3'b111,8'b0,8'b10011111,100'b11110 , 6'b0}; 
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b01110 , 6'b0}; 
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b1111 , 6'b0};  
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b0 , 6'b0};
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b010101 , 6'b0};
      
       #20 wr_en_w = 0 ;  rd_en_w=1; bf_in_w=128'bx;
       
        #100  wr_en_w = 1 ;  rd_en_w=0;
            reset =1;
            #10 reset =0;
           wr_en_e = 0 ;  rd_en_e=0;
           wr_en_s = 0 ;  rd_en_s=0;
           
      #10 bf_in_w = {3'b111,3'b111,8'b0,8'b10011111,106'b0}; 
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b01110 , 6'b0}; 
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b1111 , 6'b0};                 // new packet different PID same destination
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b0 , 6'b0};
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b010101 , 6'b0};
      
       #20 wr_en_w = 0 ;  rd_en_w=1; bf_in_w=128'bx;
       
        #100  wr_en_w = 1 ;  rd_en_w=0;
       reset=1;
       #10 reset=0;
           wr_en_e = 0 ;  rd_en_e=0;
           wr_en_s = 0 ;  rd_en_s=0;     
           
                
      #10 bf_in_w = {3'b000,3'b000,8'b0,8'b10001111,106'b0}; 
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b01110 , 6'b0}; 
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b1111 , 6'b0};                        // new packet
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b0 , 6'b0};
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b010101 , 6'b0};
      
       #20 wr_en_w = 0 ;  rd_en_w=1; bf_in_w=128'bx;
       
        #100  wr_en_w = 1 ;  rd_en_w=0;
        reset=1;
        #10 reset=0;
           wr_en_e = 0 ;  rd_en_e=0;
           wr_en_s = 0 ;  rd_en_s=0;     
           
                    
      #10 bf_in_w = {3'b000,3'b000,8'b0,8'b10001111,106'b0}; 
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b01110 , 6'b0}; 
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b1111 , 6'b0};  
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b0 , 6'b0};                      // 3rd retrasmission
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b010101 , 6'b0};
      
       #20 wr_en_w = 0 ;  rd_en_w=1; bf_in_w=128'bx;
       
        #100  wr_en_w = 1 ;  rd_en_w=0;
        reset=1;
        #10 reset=0;
           wr_en_e = 0 ;  rd_en_e=0;
           wr_en_s = 0 ;  rd_en_s=0;     
           
           
      #10 bf_in_w = {3'b000,3'b000,8'b0,8'b10001111,106'b0}; 
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b01110 , 6'b0};               // 4th retrasmission
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b1111 , 6'b0};  
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b0 , 6'b0};
      #20 bf_in_w = {3'b000,3'b000,8'b0,8'b10011111,100'b010101 , 6'b0};
      
       #20 wr_en_w = 0 ;  rd_en_w=1; bf_in_w=128'bx;
       
        #100  wr_en_w = 1 ;  rd_en_w=0;
      reset=1;
           wr_en_e = 0 ;  rd_en_e=0;
           wr_en_s = 0 ;  rd_en_s=0;        
               //#10 bf_in = 128'hCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC;
  //  #10 bf_in = 128'hDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD;
   //10 bf_in = 128'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE;
    
    // Test case 3: Reading from the buffer
   //10 bf_in = 128'b0;
    
    // Test case 4: Resetting the buffer
 // #10 reset = 1;
   //10 reset = 0;
    
    
    
    
    
    
    
   
    #1500 $finish;
  end
  

  
endmodule

