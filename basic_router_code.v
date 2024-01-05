`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineers: Adrin Santhosh , Delvin John ,  Ashbin Shiju , Rhythik Das Nambiar
//
// Create Date: 29/05/2023
// Last edited : 25/12/2023
// Design Name:
// Module Name: NOC Router
// Project Name: Implementation and Analysis of Security Wrapper Modules for NOC Router.
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
/////////////////////////           HEADER           /////////////////////////////
//
//                         ROUTER GENERAL INFORMATIONS
//
//    +     5 Port router of width 128 bit connecting to 4 directions (North, South, East, West) and the local chiplet , each ports are having a buffer of 4 VCs each with 5 slots.
//    +     Assuming this is for a 8X8 mesh so total 64 different router address
//    +     Along with the 5 128 bit line, hand shaking line are also there for the communication of buffer availability
//     
//                              ASSUMPTIONS

//    +     a single packet is given as input through a input port at a time
//    +     a single virtual channel is assumed in neighbour routers buffers and in the tile to which the current router is attached


//                     INPUT FLIT GENARAL INFORMATIONS
//
//      |  6- bit    |          reTab Entry            |         122 - bit            |         |
//      |destination |                                 |           DATA               |  VC ID  |
//      |    I D     |      SID       |      PID       |                              |         |
//     127--------122 121---------114 | 113---------106 105--------------------------2 1 -------0
//




//     +  Assuming destination I D is in the format
//                     
//                 127  - 125  --> X ID 
//                 124  - 122  --> Y ID 

//        ^
//        |
//        | 
//        |
//        |  111000  111001  111010  111011  111100  111101  111110  111111   
//        |
//        |  110000  110001  110010  110011  110100  110101  110110  110111   
//        |
//        |  100000  100001  100010  100011  100100  100101  100110  100111   
//        y                                                                                                         N
//        |  011000  011001  011010  011011  011100  011101  011110  011111                                         |                                                            |
//        |                                                                                                    W----|----E
//        |  010000  010001  010010  010011  010100  010101  010110  010111                                         |                                                           |
//        |                                                                                                         S
//        |  001000  001001  001010  001011  001100  001101  001110  001111
//        |     
//        |  000000  000001  000010  000011  000100  000101  000110  000111
//        |
//        |------------------------------x------------------------------------ >
//
////////////////////////////////////////////////////////////////////////////////////


                                                                                  
 //  buffer write is taking place in the positive edge of the clk 1 ( even though the always block of buffer write has only bf_in in the sensitivity list , it is in syn with the clk 1 because bf_in is given in sync with the clk1 while writting testbench (applied in the same period of the clk1))
 // route computation is taking place in the positive edge of the clk 2.
 // VC allocation is taking place in the positive edge of the clk 1.
 // switch allocationb is taking place in the positive edge of the clk 2
 
 
 
// we are applying the first input at the 25th time unit at that time itself the 1st buffer_write happens and headflit is copied to a temperory location. ( clk 1 posedge) 
// route computation output is obtained in the 35th time unit. 
// VC allocation ouutput and 2nd buffer_write is taking place place at 45 th time unit.( vc_grant signals are generated in this time unit)
// Switch allocation is taking place at 55th time unit ; crossbar logic is generated at this stage. (aknowledgement from the switch allocatio part goes to the poping part from the buffer)
// 3rd buffer_write is taking place at 65th time unit.
// 5th buffer_write ie 5th flit is written to the VC in the 105 th time unit. (And thus a write finished aknowledgement is generated at this time itself)
//poping starts at the 125 th time unit.( as we are following store and forward mechanism , even though the all the signals that are needed to start poping is generated the poping will be starting only after the 5th flit is written)



/*
VC allocation part is a dummy code , it's given only to invoke that function.
we considered that in each input port of the downstream buffer there is only one VC.
Based on the code the VCs of the downstream buffer will be showing as free all the time.
*/



/*
switch allocation is implemented based on the round_robin alorithm
north_taken , south_taken , east_taken , west_taken , local_taken are usefull when packets from the two or more ports of the current router needs
the same port in the downstream router , based on the round_robin algorithm priority will be given to one of the port and thus taken signal to the port of the downstream buffer will be active
when all the flits are poped , taken signal will again becomes low. 
*/






module router_new(

  input wire clk1,clk2,reset, 
  
  input wr_en_e  ,  rd_en_e,                                               // common for all 4 VCs of East Port
  input wire [127:0] bf_in_e,                                              // Input to the East Buffer
  output reg [127:0] bf_out_e ,                                            // Output of the West Buffer 
  output   reg [2:0] em_pl_e1,em_pl_e2,em_pl_e3,em_pl_e4 ,                     // Empty Slots of the VCs in West Port
  output   reg [2:0] add_wr_e ,                                                // read address register of the West Port
  output   reg [2:0] add_rd_e ,                                              // write address register of the West Port
  
  
  input wr_en_w  ,  rd_en_w,                                               // common for all 4 VCs of West Port
  input wire [127:0] bf_in_w,                                              // Input to the West Buffer
  output reg [127:0] bf_out_w ,                                            // Output of the West Buffer 
  output   reg [2:0] em_pl_w1,em_pl_w2,em_pl_w3,em_pl_w4 ,                     // Empty Slots of the VCs in West Port
  output   reg [2:0] add_wr_w ,                                                // read address register of the West Port
  output   reg [2:0] add_rd_w ,                                              // write address register of the West Port
                                         

  input wr_en_n  ,  rd_en_n,                                               // common for all 4 VCs of North Port
  input wire [127:0] bf_in_n,                                              // Input to the North Buffer
  output   reg [127:0] bf_out_n ,                                            // Output of the North Buffer 
  output reg [2:0] em_pl_n1,em_pl_n2,em_pl_n3,em_pl_n4 ,                    // Empty Slots of the VCs in North Port
  output  reg [2:0] add_wr_n ,                                              // read address register of the North Port
  output reg [2:0] add_rd_n ,                                              // write address register of the North Port
                                              
  
  input wr_en_s  ,  rd_en_s,                                               // common for all 4 VCs of South Port
  input wire [127:0] bf_in_s,                                              // Input to the South Buffer
   output reg [127:0] bf_out_s ,                                           // Output of the South Buffer 
   output reg [2:0] em_pl_s1,em_pl_s2,em_pl_s3,em_pl_s4 ,                    // Empty Slots of the VCs in South Port
   output reg [2:0] add_wr_s ,                                               // read address register of the South Port
   output reg [2:0] add_rd_s ,                                              // write address register of the South Port
 
  
  input wr_en_t  ,  rd_en_t,                                               // common for all 4 VCs of Local Port
  input wire [127:0] bf_in_t,                                              // Input to the Local Buffer
   output reg [127:0] bf_out_t ,                                             // Output of the Local Buffer 
   output reg [2:0] em_pl_t1,em_pl_t2,em_pl_t3,em_pl_t4 ,                     // Empty Slots of the VCs in Local Port
   output reg [2:0] add_wr_t ,                                               // read address register of the Local Port
   output reg [2:0] add_rd_t ,                                              // write address register of the Local Port

   
   output reg [3:0] north_route ,
  output reg [3:0] south_route ,
 output reg [3:0] east_route ,
  output reg [3:0] west_route ,
  output reg [3:0] local_route , 
  
  
  output reg vc_grant_d_E,
  output reg vc_grant_d_W,                                           /* from VC allocator to VC to pop flits*/
  output reg vc_grant_d_N,
  output  reg vc_grant_d_S,
  output reg vc_grant_d_T,
  
   output reg [2:0] east_out,
    output reg [2:0] west_out, 
     output reg [2:0] north_out,
      output reg [2:0] south_out,local_out, 
                                              
 output reg [127:0] OE,OW,ON,OS,Eject
);

  
    
  
  
  reg [127:0] bf_e1 [4:0];                                      /* 4 VCs assosiated with the East port */
  reg [127:0] bf_e2 [4:0];
  reg [127:0] bf_e3 [4:0];
  reg [127:0] bf_e4 [4:0];
  reg [127:0] temp_e=128'bx;                                    /* temporary register to store the head flit */
 
  reg [127:0] bf_w1 [4:0];                                      /* 4 VCs assosiated with the West port */
  reg [127:0] bf_w2 [4:0];
  reg [127:0] bf_w3 [4:0];
  reg [127:0] bf_w4 [4:0];
  reg [127:0] temp_w=128'bx;                                    /* temporary register to store the head flit */
 
  reg [127:0] bf_n1 [4:0];                                      /* 4 VCs assosiated with the North port */
  reg [127:0] bf_n2 [4:0];
  reg [127:0] bf_n3 [4:0];
  reg [127:0] bf_n4 [4:0];
  reg [127:0] temp_n=128'bx;                                    /* temporary register to store the head flit */
 
  reg [127:0] bf_s1 [4:0];                                      /* 4 VCs assosiated with the South port */
  reg [127:0] bf_s2 [4:0];
  reg [127:0] bf_s3 [4:0];
  reg [127:0] bf_s4 [4:0];
  reg [127:0] temp_s=128'bx;                                    /* temporary register to store the head flit */
  
  reg [127:0] bf_t1 [4:0];                                      /* 4 VCs assosiated with the Local port */
  reg [127:0] bf_t2 [4:0];
  reg [127:0] bf_t3 [4:0];
  reg [127:0] bf_t4 [4:0];
  reg [127:0] temp_t=128'bx;                                    /* temporary register to store the head flit */
 
 
 





                
                  
  reg [127:0] bf_d_E[0:4];
  reg [2:0] add_wr_d_E;
  reg [2:0] add_rd_d_E;                                             /*registers of the east downstream buffer*/  
  reg [2:0] em_pl_d_E;
  reg reset_d_E=1'b1;
  reg em_a_d_E=0;
  reg [127:0]bf_in_d_E,bf_out_d_E;
  reg buf_free_d_E;
  
  
  
  
                    
  reg [127:0] bf_d_W[0:4];
  reg [2:0] add_wr_d_W;                                               /*registers of the west downstream buffer*/  
  reg [2:0] add_rd_d_W;
  reg [2:0] em_pl_d_W;
  reg reset_d_W=1'b1;
  reg em_a_d_W=0;
  reg [127:0]bf_in_d_W,bf_out_d_W;
  reg buf_free_d_W;
  
 
  
  
                    
  reg [127:0] bf_d_N[0:4];
  reg [2:0] add_wr_d_N;                                                /*registers of the north downstream buffer*/ 
  reg [2:0] add_rd_d_N;
  reg [2:0] em_pl_d_N;
  reg reset_d_N=1'b1;
  reg em_a_d_N=0;
  reg [127:0]bf_in_d_N,bf_out_d_N;
  reg buf_free_d_N;
  
   
   
     
                    
  reg [127:0] bf_d_S[0:4];
  reg [2:0] add_wr_d_S;                                                /*registers of the south downstream buffer*/
  reg [2:0] add_rd_d_S;
  reg [2:0] em_pl_d_S;
  reg reset_d_S=1'b1;
  reg em_a_d_S=0;
  reg [127:0]bf_in_d_S,bf_out_d_S;
  reg buf_free_d_S;
  
  
  
  
                      
  reg [127:0] bf_d_T[0:4];
  reg [2:0] add_wr_d_T;                                                    /*registers of the local downstream buffer*/
  reg [2:0] add_rd_d_T;
  reg [2:0] em_pl_d_T;
  reg reset_d_T=1'b1;
  reg em_a_d_T=0;
  reg [127:0]bf_in_d_T,bf_out_d_T;
  reg buf_free_d_T;
  
  
  reg [4:0]count = 5'b0;                
             
 // reg [2:0]east_out , west_out , north_out , south_out , local_out;                    
   
  reg north_taken = 0;
  reg south_taken = 0;
  reg west_taken = 0;
  reg east_taken = 0;
  reg local_taken = 0;  
  
  
  reg pop_ak_to_n_b = 0;                   /*from switch allocator to buffer of each port*/
  reg pop_ak_to_s_b = 0;
  reg pop_ak_to_e_b = 0;
  reg pop_ak_to_w_b = 0;
  reg pop_ak_to_l_b = 0;
  
  
  reg w_ak_e = 0;
  reg w_ak_w = 0;                         /*write finished aknowledgement to start reading (pushing) */
  reg w_ak_n = 0;
  reg w_ak_s = 0;
  reg w_ak_t = 0;
 
         
        localparam LOC_X = 3'b011;                                                  //  Address of this router
        localparam LOC_Y = 3'b100;                                                  //  + can be changed accordingly
        
        localparam NORTH = 4'b0000;
        localparam SOUTH = 4'b0001;
        localparam WEST = 4'b0010;
        localparam EAST =  4'b0011;
        localparam LOCAL = 4'b0100;
  

  //-----------------------------------------------
                // Adwaith's changes

    reg [3:0] trust_N = 0;  // Trust level for North direction
    reg [3:0] trust_S = 0;  // Trust level for South direction
    reg [3:0] trust_E = 0;  // Trust level for East direction
    reg [3:0] trust_W = 0;  // Trust level for West direction
    parameter delta_x = 0.0001;  // Trust increment/decrement value

    wire is_ack_packet;

    reg [128-1:0] ack_packet;  // Declare ack_packet with the appropriate size

    wire [1:0] path_history;  // 2 bits for N, S, E, W



  //------------------------------------------------
 

 
 
 
 /*___________Buffer Write and Read for East Port________*/  
 
 
 
   always @(posedge clk1)
      begin
      
      if (reset) 
                  begin
                  
                     bf_e1[0] = 128'b0;
                     bf_e1[1] = 128'b0;
                     bf_e1[2] = 128'b0;
                     bf_e1[3] = 128'b0;
                     bf_e1[4] = 128'b0;
                     em_pl_e1 = 3'd5;

                     
                     bf_e2[0] = 128'b0;
                     bf_e2[1] = 128'b0;
                     bf_e2[2] = 128'b0;
                     bf_e2[3] = 128'b0;
                     bf_e2[4] = 128'b0;
                     em_pl_e2 = 3'd5;
                     
                     bf_e3[0] = 128'b0;
                     bf_e3[1] = 128'b0;
                     bf_e3[2] = 128'b0;
                     bf_e3[3] = 128'b0;
                     bf_e3[4] = 128'b0;
                     em_pl_e3 = 3'd5;
                     
                     bf_e4[0] = 128'b0;
                     bf_e4[1] = 128'b0;
                     bf_e4[2] = 128'b0;
                     bf_e4[3] = 128'b0;
                     bf_e4[4] = 128'b0;
                     em_pl_e4 = 3'd5;


                     add_wr_e = 3'd0;
                     add_rd_e = 3'd0;
                     
                  end
                  
                  
                  
        end          
                  
                  
    always @(bf_in_e)
      begin
         
       case (bf_in_e[1:0])
         2'b00: 
            begin
             
               if( ! reset && wr_en_e && !rd_en_e  )
                   begin
                     bf_e1[add_wr_e] = bf_in_e;
                       if(add_wr_e==3'b0)
                       begin
                         temp_e = bf_in_e;
                       end
                  
                     add_wr_e = add_wr_e + 1;
                     em_pl_e1 = em_pl_e1 - 1;
                       if (em_pl_e1 == 3'b0)
                           w_ak_e = 1;
                    end
  
            end
            
            
         2'b01: 
            begin
             
               if( ! reset && wr_en_e && !rd_en_e  )
                   begin
                     bf_e2[add_wr_e] = bf_in_e;
                     if(add_wr_e==3'b0)
                       begin
                         temp_e = bf_in_e;
                       end
                     add_wr_e = add_wr_e + 1;
                     em_pl_e2 = em_pl_e2 - 1;
                     if (em_pl_e2 == 3'b0)
                           w_ak_e = 1;
                  
                    end
  
            end
            
            
         2'b10: 
            begin
             
               if( ! reset && wr_en_e && !rd_en_e  )
                   begin
                     bf_e3[add_wr_e] = bf_in_e;
                     if(add_wr_e==3'b0)
                       begin
                         temp_e = bf_in_e;
                       end
                     add_wr_e = add_wr_e + 1;
                     em_pl_e3 = em_pl_e3 - 1;
                     if (em_pl_e3 == 3'b0)
                           w_ak_e = 1;
                  
                    end
  
            end            
            
         2'b11: 
            begin
             
               if( ! reset && wr_en_e && !rd_en_e  )
                   begin
                     bf_e4[add_wr_e] = bf_in_e;
                     if(add_wr_e==3'b0)
                       begin
                         temp_e = bf_in_e;
                       end
                     add_wr_e = add_wr_e + 1;
                     em_pl_e4 = em_pl_e4 - 1;
                     if (em_pl_e4 == 3'b0)
                           w_ak_e = 1;
                  
                    end
  
            end            
            
        endcase    
        
   end   
        
    always @(posedge clk1)
      begin
         
       case (temp_e [1:0])
         2'b00:   begin
                
                     if (! reset && !wr_en_e && rd_en_e && pop_ak_to_e_b && w_ak_e )
                   begin
                     bf_out_e = bf_e1[add_rd_e];
                     add_rd_e = add_rd_e + 1;
                     em_pl_e1 = em_pl_e1 + 1;
                        
                        if(em_pl_e1 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_e_b = 1'b0;
                             w_ak_e =1'b0;
                             
                             end
                             
                        
                        if(em_pl_e1 == 3'd5 && east_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_e1 == 3'd5 && east_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_e1 == 3'd5 && east_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_e1 == 3'd5 && east_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_e1 == 3'd5 && east_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                   end
                   
                 
                 end      
        
          2'b01:   begin
                
                     if (! reset && !wr_en_e && rd_en_e && pop_ak_to_e_b && w_ak_e)
                   begin
                     bf_out_e = bf_e2[add_rd_e];
                     add_rd_e = add_rd_e + 1;
                     em_pl_e2 = em_pl_e2 + 1;
                     
                     
                     if(em_pl_e2 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_e_b = 1'b0;
                             w_ak_e =1'b0;
                             
                             end
                             
                         
                        
                        if(em_pl_e2 == 3'd5 && east_route == EAST)
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_e2 == 3'd5 && east_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_e2 == 3'd5 && east_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_e2 == 3'd5 && east_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_e2 == 3'd5 && east_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                                                     
                   end
                   
                 
                 end     
                 
                 
          2'b10:   begin
                
                     if (! reset && !wr_en_e && rd_en_e && pop_ak_to_e_b && w_ak_e)
                   begin
                     bf_out_e = bf_e3[add_rd_e];
                     add_rd_e = add_rd_e + 1;
                     em_pl_e3 = em_pl_e3 + 1;
                     
                     
                     if(em_pl_e3 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_e_b = 1'b0;
                             w_ak_e =1'b0;
                             
                             end
                             
                                             
                        
                        if(em_pl_e3 == 3'd5 && east_route == EAST)
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_e3 == 3'd5 && east_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_e3 == 3'd5 && east_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_e3 == 3'd5 && east_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_e3 == 3'd5 && east_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                                 
                   end
                   
                 
                 end                      
 
           2'b11:   begin
                
                     if (! reset && !wr_en_e && rd_en_e && pop_ak_to_e_b && w_ak_e)
                   begin
                     bf_out_e = bf_e4[add_rd_e];
                     add_rd_e = add_rd_e + 1;
                     em_pl_e4 = em_pl_e4 + 1;
                     
                     
                     if(em_pl_e4 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_e_b = 1'b0;
                             w_ak_e =1'b0;
                             
                             end
                             
                   
                   
                                           
                        if(em_pl_e4 == 3'd5 && east_route == EAST)
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_e4 == 3'd5 && east_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_e4 == 3'd5 && east_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_e4 == 3'd5 && east_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_e4 == 3'd5 && east_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                   
                   end
                   
                 
                 end     
                         
        
        endcase
  
    end
   
   
   
 /*___________Buffer Write and Read for West Port________*/  

      
         always @(posedge clk1)
      begin
      
      if (reset) 
                  begin
                  
                     bf_w1[0] = 128'b0;
                     bf_w1[1] = 128'b0;
                     bf_w1[2] = 128'b0;
                     bf_w1[3] = 128'b0;
                     bf_w1[4] = 128'b0;
                     em_pl_w1 = 3'd5;

                     
                     bf_w2[0] = 128'b0;
                     bf_w2[1] = 128'b0;
                     bf_w2[2] = 128'b0;
                     bf_w2[3] = 128'b0;
                     bf_w2[4] = 128'b0;
                     em_pl_w2 = 3'd5;
                     
                     bf_w3[0] = 128'b0;
                     bf_w3[1] = 128'b0;
                     bf_w3[2] = 128'b0;
                     bf_w3[3] = 128'b0;
                     bf_w3[4] = 128'b0;
                     em_pl_w3 = 3'd5;
                     
                     bf_w4[0] = 128'b0;
                     bf_w4[1] = 128'b0;
                     bf_w4[2] = 128'b0;
                     bf_w4[3] = 128'b0;
                     bf_w4[4] = 128'b0;
                     em_pl_w4 = 3'd5;


                     add_wr_w = 3'd0;
                     add_rd_w = 3'd0;
                     
                  end
                  
                  
                  
        end          
                  
                  
    always @(bf_in_w)
      begin
         
       case (bf_in_w[1:0])
         2'b00: 
            begin
             
               if( ! reset && wr_en_w && !rd_en_w  )
                   begin
                     bf_w1[add_wr_w] = bf_in_w;
                       if(add_wr_w==3'b0)
                       begin
                         temp_w = bf_in_w;
                       end
                  
                     add_wr_w = add_wr_w + 1;
                     em_pl_w1 = em_pl_w1 - 1;
                     if (em_pl_w1 == 3'b0)
                           w_ak_w = 1;
                  
                    end
  
            end
            
            
         2'b01: 
            begin
             
               if( ! reset && wr_en_w && !rd_en_w  )
                   begin
                     bf_w2[add_wr_w] = bf_in_w;
                     if(add_wr_w==3'b0)
                       begin
                         temp_w = bf_in_w;
                       end
                     add_wr_w = add_wr_w + 1;
                     em_pl_w2 = em_pl_w2 - 1;
                     if (em_pl_w2 == 3'b0)
                           w_ak_w = 1;
                  
                    end
  
            end
            
            
         2'b10: 
            begin
             
               if( ! reset && wr_en_w && !rd_en_w  )
                   begin
                     bf_w3[add_wr_w] = bf_in_w;
                     if(add_wr_w==3'b0)
                       begin
                         temp_w = bf_in_w;
                       end
                     add_wr_w = add_wr_w + 1;
                     em_pl_w3 = em_pl_w3 - 1;
                     if (em_pl_w3 == 3'b0)
                           w_ak_w = 1;
                  
                    end
  
            end            
            
         2'b11: 
            begin
             
               if( ! reset && wr_en_w && !rd_en_w  )
                   begin
                     bf_w4[add_wr_w] = bf_in_w;
                     if(add_wr_w==3'b0)
                       begin
                         temp_w = bf_in_w;
                       end
                     add_wr_w = add_wr_w + 1;
                     em_pl_w4 = em_pl_w4 - 1;
                     if (em_pl_w4 == 3'b0)
                           w_ak_w = 1;
                  
                    end
  
            end            
            
        endcase    
        
   end   
        
    always @(posedge clk1)
      begin
         
       case (temp_w [1:0])
         2'b00:   begin
                
                     if (! reset && !wr_en_w && rd_en_w && pop_ak_to_w_b && w_ak_w)
                   begin
                     bf_out_w = bf_w1[add_rd_w];
                     add_rd_w = add_rd_w + 1;
                     em_pl_w1 = em_pl_w1 + 1;
                     
                     
                     if(em_pl_w1 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_w_b = 1'b0;
                             w_ak_w =1'b0;
                             
                             end
                             
                     
                                             
                        if(em_pl_w1 == 3'd5 && west_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_w1 == 3'd5 && west_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_w1 == 3'd5 && west_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_w1 == 3'd5 && west_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_w1 == 3'd5 && west_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                     
                   end
                   
                 
                 end      
        
          2'b01:   begin
                
                     if (! reset && !wr_en_w && rd_en_w && pop_ak_to_w_b && w_ak_w)
                   begin
                     bf_out_w = bf_w2[add_rd_w];
                     add_rd_w = add_rd_w + 1;
                     em_pl_w2 = em_pl_w2 + 1;
                     
                     
                     if(em_pl_w2 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_w_b = 1'b0;
                             w_ak_w =1'b0;
                             
                             end
                     
                                                                  
                        if(em_pl_w2 == 3'd5 && west_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_w2 == 3'd5 && west_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_w2 == 3'd5 && west_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_w2 == 3'd5 && west_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_w2 == 3'd5 && west_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                     
                   end
                   
                 
                 end     
                 
                 
          2'b10:   begin
                
                     if (! reset && !wr_en_w && rd_en_w && pop_ak_to_w_b && w_ak_w)
                   begin
                     bf_out_w = bf_w3[add_rd_w];
                     add_rd_w = add_rd_w + 1;
                     em_pl_w3 = em_pl_w3 + 1;
                     
                     
                     if(em_pl_w3 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_w_b = 1'b0;
                             w_ak_w =1'b0;
                             
                             end
                     
                                                                                       
                        if(em_pl_w3 == 3'd5 && west_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_w3 == 3'd5 && west_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_w3 == 3'd5 && west_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_w3 == 3'd5 && west_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_w3 == 3'd5 && west_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                     
                     
                   end
                   
                 
                 end                      
 
           2'b11:   begin
                
                     if (! reset && !wr_en_w && rd_en_w && pop_ak_to_w_b && w_ak_w)
                   begin
                     bf_out_w = bf_w4[add_rd_w];
                     add_rd_w = add_rd_w + 1;
                     em_pl_w4 = em_pl_w4 + 1;
                     
                     if(em_pl_w4 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_w_b = 1'b0;
                             w_ak_w =1'b0;
                             
                             end
                     
                                                                                              
                        if(em_pl_w4 == 3'd5 && west_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_w4 == 3'd5 && west_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_w4 == 3'd5 && west_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_w4 == 3'd5 && west_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_w4 == 3'd5 && west_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                   end
                   
                 
                 end     
                         
        
        endcase
  
    end
   
   
   /*___________Buffer Write and Read for north Port________*/  
   

            
         always @(posedge clk1)
      begin
      
      if (reset) 
                  begin
                  
                     bf_n1[0] = 128'b0;
                     bf_n1[1] = 128'b0;
                     bf_n1[2] = 128'b0;
                     bf_n1[3] = 128'b0;
                     bf_n1[4] = 128'b0;
                     em_pl_n1 = 3'd5;

                     
                     bf_n2[0] = 128'b0;
                     bf_n2[1] = 128'b0;
                     bf_n2[2] = 128'b0;
                     bf_n2[3] = 128'b0;
                     bf_n2[4] = 128'b0;
                     em_pl_n2 = 3'd5;
                     
                     bf_n3[0] = 128'b0;
                     bf_n3[1] = 128'b0;
                     bf_n3[2] = 128'b0;
                     bf_n3[3] = 128'b0;
                     bf_n3[4] = 128'b0;
                     em_pl_n3 = 3'd5;
                     
                     bf_n4[0] = 128'b0;
                     bf_n4[1] = 128'b0;
                     bf_n4[2] = 128'b0;
                     bf_n4[3] = 128'b0;
                     bf_n4[4] = 128'b0;
                     em_pl_n4 = 3'd5;


                     add_wr_n = 3'd0;
                     add_rd_n = 3'd0;
                     
                  end
                  
                  
                  
        end          
                  
                  
    always @(bf_in_n)
      begin
         
       case (bf_in_n[1:0])
         2'b00: 
            begin
             
               if( ! reset && wr_en_n && !rd_en_n  )
                   begin
                     bf_n1[add_wr_n] = bf_in_n;
                       if(add_wr_n==3'b0)
                       begin
                         temp_n = bf_in_n;
                       end
                  
                     add_wr_n = add_wr_n + 1;
                     em_pl_n1 = em_pl_n1 - 1;
                     if (em_pl_n1 == 3'b0)
                           w_ak_n = 1;
                  
                    end
  
            end
            
            
         2'b01: 
            begin
             
               if( ! reset && wr_en_n && !rd_en_n  )
                   begin
                     bf_n2[add_wr_n] = bf_in_n;
                     if(add_wr_n==3'b0)
                       begin
                         temp_n = bf_in_n;
                       end
                     add_wr_n = add_wr_n + 1;
                     em_pl_n2 = em_pl_n2 - 1;
                     if (em_pl_n2 == 3'b0)
                           w_ak_n = 1;
                  
                    end
  
            end
            
            
         2'b10: 
            begin
             
               if( ! reset && wr_en_n && !rd_en_n  )
                   begin
                     bf_n3[add_wr_n] = bf_in_n;
                     if(add_wr_n==3'b0)
                       begin
                         temp_n = bf_in_n;
                       end
                     add_wr_n = add_wr_n + 1;
                     em_pl_n3 = em_pl_n3 - 1;
                     if (em_pl_n3 == 3'b0)
                           w_ak_n = 1;
                  
                    end
  
            end            
            
         2'b11: 
            begin
             
               if( ! reset && wr_en_n && !rd_en_n  )
                   begin
                     bf_n4[add_wr_n] = bf_in_n;
                     if(add_wr_n==3'b0)
                       begin
                         temp_n = bf_in_n;
                       end
                     add_wr_n = add_wr_n + 1;
                     em_pl_n4 = em_pl_n4 - 1;
                     if (em_pl_n4 == 3'b0)
                           w_ak_n = 1;
                  
                    end
  
            end            
            
        endcase    
        
   end   
        
    always @(posedge clk1)
      begin
         
       case (temp_n [1:0])
         2'b00:   begin
                
                     if (! reset && !wr_en_n && rd_en_n && pop_ak_to_n_b &&  w_ak_n )
                   begin
                     bf_out_n = bf_n1[add_rd_n];
                     add_rd_n = add_rd_n + 1;
                     em_pl_n1 = em_pl_n1 + 1;
                     
                     if(em_pl_n1 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_n_b = 1'b0;
                             w_ak_n =1'b0;
                             
                             end
                     
                         if(em_pl_n1 == 3'd5 && north_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_n1 == 3'd5 && north_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_n1 == 3'd5 && north_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_n1 == 3'd5 && north_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_n1 == 3'd5 && north_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                   end
                   
                 
                 end      
        
          2'b01:   begin
                
                     if (! reset && !wr_en_n && rd_en_n && pop_ak_to_n_b &&  w_ak_n)
                   begin
                     bf_out_n = bf_n2[add_rd_n];
                     add_rd_n = add_rd_n + 1;
                     em_pl_n2 = em_pl_n2 + 1;
                     
                     
                     if(em_pl_n2 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_n_b = 1'b0;
                             w_ak_n =1'b0;
                             
                             end
                     
                      if(em_pl_n2 == 3'd5 && north_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_n2 == 3'd5 && north_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_n2 == 3'd5 && north_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_n2 == 3'd5 && north_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_n2 == 3'd5 && north_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                   end
                   
                 
                 end     
                 
                 
          2'b10:   begin
                
                     if (! reset && !wr_en_n && rd_en_n && pop_ak_to_n_b &&  w_ak_n)
                   begin
                     bf_out_n = bf_n3[add_rd_n];
                     add_rd_n = add_rd_n + 1;
                     em_pl_n3 = em_pl_n3 + 1;
                     
                     
                      if(em_pl_n3 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_n_b = 1'b0;
                             w_ak_n =1'b0;
                             
                             end
                     
                         if(em_pl_n3 == 3'd5 && north_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_n3 == 3'd5 && north_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_n3 == 3'd5 && north_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_n3 == 3'd5 && north_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_n3 == 3'd5 && north_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                   end
                   
                 
                 end                      
 
           2'b11:   begin
                
                     if (! reset && !wr_en_n && rd_en_n && pop_ak_to_n_b &&  w_ak_n)
                   begin
                     bf_out_n = bf_n4[add_rd_n];
                     add_rd_n = add_rd_n + 1;
                     em_pl_n4 = em_pl_n4 + 1;
                     
                      if(em_pl_n4 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_n_b = 1'b0;
                             w_ak_n =1'b0;
                             
                             end
                     
                         if(em_pl_n4 == 3'd5 && north_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_n4 == 3'd5 && north_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_n4 == 3'd5 && north_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_n4 == 3'd5 && north_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_n4 == 3'd5 && north_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                                 
                   end
                   
                 
                 end     
                         
        
        endcase
  
    end
      
      
      
      
   
   /*___________Buffer Write and Read for South Port________*/  
   

            
         always @(posedge clk1)
      begin
      
      if (reset) 
                  begin
                  
                     bf_s1[0] = 128'b0;
                     bf_s1[1] = 128'b0;
                     bf_s1[2] = 128'b0;
                     bf_s1[3] = 128'b0;
                     bf_s1[4] = 128'b0;
                     em_pl_s1 = 3'd5;

                     
                     bf_s2[0] = 128'b0;
                     bf_s2[1] = 128'b0;
                     bf_s2[2] = 128'b0;
                     bf_s2[3] = 128'b0;
                     bf_s2[4] = 128'b0;
                     em_pl_s2 = 3'd5;
                     
                     bf_s3[0] = 128'b0;
                     bf_s3[1] = 128'b0;
                     bf_s3[2] = 128'b0;
                     bf_s3[3] = 128'b0;
                     bf_s3[4] = 128'b0;
                     em_pl_s3 = 3'd5;
                     
                     bf_s4[0] = 128'b0;
                     bf_s4[1] = 128'b0;
                     bf_s4[2] = 128'b0;
                     bf_s4[3] = 128'b0;
                     bf_s4[4] = 128'b0;
                     em_pl_s4 = 3'd5;


                     add_wr_s = 3'd0;
                     add_rd_s = 3'd0;
                     
                  end
                  
                  
                  
        end          
                  
                  
    always @(bf_in_s)
      begin
         
       case (bf_in_s[1:0])
         2'b00: 
            begin
             
               if( ! reset && wr_en_s && !rd_en_s  )
                   begin
                     bf_s1[add_wr_s] = bf_in_s;
                       if(add_wr_s==3'b0)
                       begin
                         temp_s = bf_in_s;
                       end
                  
                     add_wr_s = add_wr_s + 1;
                     em_pl_s1 = em_pl_s1 - 1;
                     if (em_pl_s1 == 3'b0)
                           w_ak_s = 1;
                  
                    end
  
            end
            
            
         2'b01: 
            begin
             
               if( ! reset && wr_en_s && !rd_en_s  )
                   begin
                     bf_s2[add_wr_s] = bf_in_s;
                     if(add_wr_s==3'b0)
                       begin
                         temp_s = bf_in_s;
                       end
                     add_wr_s = add_wr_s + 1;
                     em_pl_s2 = em_pl_s2 - 1;
                     if (em_pl_s2 == 3'b0)
                           w_ak_s = 1;
                  
                    end
  
            end
            
            
         2'b10: 
            begin
             
               if( ! reset && wr_en_s && !rd_en_s  )
                   begin
                     bf_s3[add_wr_s] = bf_in_s;
                     if(add_wr_s==3'b0)
                       begin
                         temp_s = bf_in_s;
                       end
                     add_wr_s = add_wr_s + 1;
                     em_pl_s3 = em_pl_s3 - 1;
                     if (em_pl_s3 == 3'b0)
                           w_ak_s = 1;
                  
                    end
  
            end            
            
         2'b11: 
            begin
             
               if( ! reset && wr_en_s && !rd_en_s  )
                   begin
                     bf_s4[add_wr_s] = bf_in_s;
                     if(add_wr_s==3'b0)
                       begin
                         temp_s = bf_in_s;
                       end
                     add_wr_s = add_wr_s + 1;
                     em_pl_s4 = em_pl_s4 - 1;
                     if (em_pl_s4 == 3'b0)
                           w_ak_s = 1;
                  
                    end
  
            end            
            
        endcase    
        
   end   
        
    always @(posedge clk1)
      begin
         
       case (temp_s [1:0])
         2'b00:   begin
                
                     if (! reset && !wr_en_s && rd_en_s && pop_ak_to_s_b && w_ak_s )
                   begin
                     bf_out_s = bf_s1[add_rd_s];
                     add_rd_s = add_rd_s + 1;
                     em_pl_s1 = em_pl_s1 + 1;
                     
                      if(em_pl_s1 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_s_b = 1'b0;
                             w_ak_s =1'b0;
                             
                             end
                     
                              if(em_pl_s1 == 3'd5 && south_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_s1 == 3'd5 && south_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_s1 == 3'd5 && south_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_s1 == 3'd5 && south_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_s1 == 3'd5 && south_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                   end
                   
                 
                 end      
        
          2'b01:   begin
                
                     if (! reset && !wr_en_s && rd_en_s && pop_ak_to_s_b && w_ak_s )
                   begin
                     bf_out_s = bf_s2[add_rd_s];
                     add_rd_s = add_rd_s + 1;
                     em_pl_s2 = em_pl_s2 + 1;
                     
                     if(em_pl_s2 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_s_b = 1'b0;
                             w_ak_s =1'b0;
                             
                             end
                     
                        if(em_pl_s2 == 3'd5 && south_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_s2 == 3'd5 && south_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_s2 == 3'd5 && south_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_s2 == 3'd5 && south_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_s2 == 3'd5 && south_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                   end
                   
                 
                 end     
                 
                 
          2'b10:   begin
                
                     if (! reset && !wr_en_s && rd_en_s && pop_ak_to_s_b && w_ak_s )
                   begin
                     bf_out_s = bf_s3[add_rd_s];
                     add_rd_s = add_rd_s + 1;
                     em_pl_s3 = em_pl_s3 + 1;
                     
                     
                     if(em_pl_s3 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_s_b = 1'b0;
                             w_ak_s =1'b0;
                             
                             end
                     
                                 if(em_pl_s3 == 3'd5 && south_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_s3 == 3'd5 && south_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_s3 == 3'd5 && south_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_s3 == 3'd5 && south_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_s3 == 3'd5 && south_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                   end
                   
                 
                 end                      
 
           2'b11:   begin
                
                     if (! reset && !wr_en_s && rd_en_s && pop_ak_to_s_b && w_ak_s )
                   begin
                     bf_out_s = bf_s4[add_rd_s];
                     add_rd_s = add_rd_s + 1;
                     em_pl_s4 = em_pl_s4 + 1;
                     
                     
                     if(em_pl_s4 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_s_b = 1'b0;
                             w_ak_s =1'b0;
                             
                             end
                     
                      if(em_pl_s4 == 3'd5 && south_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_s4 == 3'd5 && south_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_s4 == 3'd5 && south_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_s4 == 3'd5 && south_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_s4 == 3'd5 && south_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;           
                   end
                   
                 
                 end     
                         
        
        endcase
  
    end
      
      
       
      
      
   
   /*___________Buffer Write and Read for Local Port________*/  
   

            
         always @(posedge clk1)
      begin
      
      if (reset) 
                  begin
                  
                     bf_t1[0] = 128'b0;
                     bf_t1[1] = 128'b0;
                     bf_t1[2] = 128'b0;
                     bf_t1[3] = 128'b0;
                     bf_t1[4] = 128'b0;
                     em_pl_t1 = 3'd5;

                     
                     bf_t2[0] = 128'b0;
                     bf_t2[1] = 128'b0;
                     bf_t2[2] = 128'b0;
                     bf_t2[3] = 128'b0;
                     bf_t2[4] = 128'b0;
                     em_pl_t2 = 3'd5;
                     
                     bf_t3[0] = 128'b0;
                     bf_t3[1] = 128'b0;
                     bf_t3[2] = 128'b0;
                     bf_t3[3] = 128'b0;
                     bf_t3[4] = 128'b0;
                     em_pl_t3 = 3'd5;
                     
                     bf_t4[0] = 128'b0;
                     bf_t4[1] = 128'b0;
                     bf_t4[2] = 128'b0;
                     bf_t4[3] = 128'b0;
                     bf_t4[4] = 128'b0;
                     em_pl_t4 = 3'd5;


                     add_wr_t = 3'd0;
                     add_rd_t = 3'd0;
                     
                  end
                  
                  
                  
        end          
                  
                  
    always @(bf_in_t)
      begin
         
       case (bf_in_t[1:0])
         2'b00: 
            begin
             
               if( ! reset && wr_en_t && !rd_en_t  )
                   begin
                     bf_t1[add_wr_t] = bf_in_t;
                       if(add_wr_t==3'b0)
                       begin
                         temp_t = bf_in_t;
                       end
                  
                     add_wr_t = add_wr_t + 1;
                     em_pl_t1 = em_pl_t1 - 1;
                     if (em_pl_t1 == 3'b0)
                           w_ak_t = 1;
                  
                    end
  
            end
            
            
         2'b01: 
            begin
             
               if( ! reset && wr_en_t && !rd_en_t  )
                   begin
                     bf_t2[add_wr_t] = bf_in_t;
                     if(add_wr_t==3'b0)
                       begin
                         temp_t = bf_in_t;
                       end
                     add_wr_t = add_wr_t + 1;
                     em_pl_t2 = em_pl_t2 - 1;
                     if (em_pl_t2 == 3'b0)
                           w_ak_t = 1;
                  
                    end
  
            end
            
            
         2'b10: 
            begin
             
               if( ! reset && wr_en_t && !rd_en_t  )
                   begin
                     bf_t3[add_wr_t] = bf_in_t;
                     if(add_wr_t==3'b0)
                       begin
                         temp_t = bf_in_t;
                       end
                     add_wr_t = add_wr_t + 1;
                     em_pl_t3 = em_pl_t3 - 1;
                     if (em_pl_t3 == 3'b0)
                           w_ak_t = 1;
                  
                    end
  
            end            
            
         2'b11: 
            begin
             
               if( ! reset && wr_en_t && !rd_en_t  )
                   begin
                     bf_t4[add_wr_t] = bf_in_t;
                     if(add_wr_t==3'b0)
                       begin
                         temp_t = bf_in_t;
                       end
                     add_wr_t = add_wr_t + 1;
                     em_pl_t4 = em_pl_t4 - 1;
                     if (em_pl_t4 == 3'b0)
                           w_ak_t = 1;
                  
                    end
  
            end            
            
        endcase    
        
   end   
        
    always @(posedge clk1)
      begin
         
       case (temp_t [1:0])
         2'b00:   begin
                
                     if (! reset && !wr_en_t && rd_en_t && pop_ak_to_l_b && w_ak_t)
                   begin
                     bf_out_t = bf_t1[add_rd_t];
                     add_rd_t = add_rd_t + 1;
                     em_pl_t1 = em_pl_t1 + 1;
                     
                     if(em_pl_t1 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_l_b = 1'b0;
                             w_ak_t =1'b0;
                             
                             end
                     
                                 if(em_pl_t1 == 3'd5 && local_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_t1 == 3'd5 && local_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_t1 == 3'd5 && local_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_t1 == 3'd5 && local_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_t1 == 3'd5 && local_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                   end
                   
                 
                 end      
        
          2'b01:   begin
                
                     if (! reset && !wr_en_t && rd_en_t && pop_ak_to_l_b && w_ak_t)
                   begin
                     bf_out_t = bf_t2[add_rd_t];
                     add_rd_t = add_rd_t + 1;
                     em_pl_t2 = em_pl_t2 + 1;
                     
                     if(em_pl_t2 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_l_b = 1'b0;
                             w_ak_t =1'b0;
                             
                             end
                     
                         if(em_pl_t2 == 3'd5 && local_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_t2 == 3'd5 && local_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_t2 == 3'd5 && local_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_t2 == 3'd5 && local_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_t2 == 3'd5 && local_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                   end
                   
                 
                 end     
                 
                 
          2'b10:   begin
                
                     if (! reset && !wr_en_t && rd_en_t && pop_ak_to_l_b && w_ak_t)
                   begin
                     bf_out_t = bf_t3[add_rd_t];
                     add_rd_t = add_rd_t + 1;
                     em_pl_t3 = em_pl_t3 + 1;
                     
                     if(em_pl_t3 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_l_b = 1'b0;
                             w_ak_t =1'b0;
                             
                             end
                     
                         if(em_pl_t3 == 3'd5 && local_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_t3 == 3'd5 && local_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_t3 == 3'd5 && local_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_t3 == 3'd5 && local_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_t3 == 3'd5 && local_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                   end
                   
                 
                 end                      
 
           2'b11:   begin
                
                     if (! reset && !wr_en_t && rd_en_t && pop_ak_to_l_b && w_ak_t)
                   begin
                     bf_out_t = bf_t4[add_rd_t];
                     add_rd_t = add_rd_t + 1;
                     em_pl_t4 = em_pl_t4 + 1;
                     
                     if(em_pl_t4 == 3'd5)
                             
                             begin
                            
                             pop_ak_to_l_b = 1'b0;
                             w_ak_t =1'b0;
                             
                             end
                     
                         if(em_pl_t4 == 3'd5 && local_route == EAST)                          /* switch alocation time lle ee buffer lle two ports lle ulla ethellum two or more VCs downstream buffer lle same port vennel evidenne oranam aghode pop cheythe kazhiyumbo taken signal 0 aakanam*/      
                            if(east_taken == 1)
                                 east_taken = 0;
                                 
                                 
                                                         
                        if(em_pl_t4 == 3'd5 && local_route == WEST)
                            if(west_taken == 1)
                                 west_taken = 0;
                                 
                                                 
                        if(em_pl_t4 == 3'd5 && local_route == NORTH)
                            if(north_taken == 1)
                                 north_taken = 0;
                                    
                                                
                        if(em_pl_t4 == 3'd5 && local_route == SOUTH)
                            if(south_taken == 1)
                                 east_taken = 0;
                                 
                                                
                        if(em_pl_t4 == 3'd5 && local_route == LOCAL)
                            if(local_taken == 1)
                                 local_taken = 0;
                   end
                   
                 
                 end     
                         
        
        endcase
  
    end
      
      
      
      
           
      
      
      
/*______________________________ ROUTE COMPUTATING_________________________________*/
   // adhyam ethe direction lle move cheyyanam nne maathram aane route computation unit cheyyane ; ie first step only
       
        always @ (posedge clk2)
        
        
            if (is_ack_packet) begin  // Assuming you have a way to identify ack packets
                path_history <= ack_packet[1:0];  // Extract the last 2 bits for path_history
                case (path_history)  // Check the last direction from the ack packet's path history
                    NORTH: begin
                        if (came_from_N) begin  // You'll need a way to identify where the ack came from
                            trust_N <= trust_N + delta_x;  // Increase trust for North
                        end
                    end
                    SOUTH: begin
                        if (came_from_S) begin
                            trust_S <= trust_S + delta_x;  // Increase trust for South
                        end
                    end
                    EAST: begin
                        if (came_from_E) begin
                            trust_E <= trust_E + delta_x;  // Increase trust for East
                        end
                    end
                    WEST: begin
                        if (came_from_W) begin
                            trust_W <= trust_W + delta_x;  // Increase trust for West
                        end
                    end
                    default: ; // Handle unexpected cases
                endcase
            end

            else
            begin
                if(temp_n[127:125] > LOC_X)                                           // route computation for input from north
                    begin
                        trust_E <= trust_E - delta_x;                                 // Decrease trust for East                                                             
                        north_route           =  EAST;                                //
                    end                                                               //
                else if(temp_n[127:125] < LOC_X)                                      
                    begin                  
                        trust_W <= trust_W - delta_x;                                 //
                        north_route           =  WEST;                                //
                    end                                                               //
                else                                                                  // found the X dimension movement 
                    begin                                                             //
                        if(temp_n[124:122] > LOC_Y)                                   //
                            begin        
                                trust_N <= trust_N - delta_x;                         //
                                north_route   = NORTH;                                //
                            end                                                       //
                         else if (temp_n[124:122] < LOC_X)                            //
                            begin         
                                trust_S <= trust_S - delta_x;                         //
                                north_route   = SOUTH;                                //
                            end                                                       //
                        else if (temp_n[127:122] == {LOC_X,LOC_Y})                    //
                            begin                                                     //
                                north_route   = LOCAL;                                // found the Y dimension movement
                            end
                        else    north_route   = 3'bz;                                 //
                    end 
                    
                
                
                    
                if(temp_s[127:125] > LOC_X)                                          // route computation for  input from south
                        begin                                                        //
                            trust_E <= trust_E - delta_x;
                            south_route           =  EAST;                           //
                        end                                                          //
                    else if(temp_s[127:125] < LOC_X)                                 //
                        begin                                                        //
                            trust_S <= trust_S - delta_x;
                            south_route           =  WEST;                           //
                        end                                                          //
                    else                                                             //  found the x dimension movement 
                        begin                                                        //
                            if(temp_s[124:122] > LOC_Y)                              //
                                begin                                                //
                                    trust_E <= trust_E - delta_x;
                                    south_route   = EAST;                            //
                                end                                                  //
                             else if (temp_s[124:122] < LOC_Y)                       //
                                begin                                                //
                                    trust_W <= trust_W - delta_x;
                                    south_route   = WEST;                            //
                                end                                                  //
                            else if(temp_s[127:122] == {LOC_X,LOC_Y})                //
                                begin                                                //
                                    south_route   = LOCAL;                           //found the Y dimension movement
                                end
                            else    south_route   = 3'bz;                            //
                        end                                                          //
                


                if(temp_e[127:125] > LOC_X)                                           // route computation of input from east
                        begin                                                         //
                            trust_E <= trust_E - delta_x;
                            east_route           =  EAST;                             //
                        end                                                           //
                    else if(temp_e[127:125] < LOC_X)                                  
                        begin                                                         //   
                            trust_W <= trust_W - delta_x;             
                            east_route           =  WEST;                             //
                        end                                                           //found the X dimension movement
                    else                                                              // 
                        begin                                                         //
                            if(temp_e[124:122] > LOC_Y)                               //
                                begin                                                 //
                                    trust_E <= trust_E - delta_x;
                                    east_route   = NORTH;                             //
                                end                                                   //
                             else if (temp_e[124:122] < LOC_Y)                        //
                                begin                                                 //
                                    trust_S <= trust_S - delta_x;
                                    east_route   = SOUTH;                             //
                                end                                                   //
                            else if(temp_e[127:122] == {LOC_X,LOC_Y})                 //
                               begin                                                  //
                                    east_route   = LOCAL;                             //found the Y dimension movement 
                                end
                            else    east_route   = 3'bz;                              //
                        end                                                           //


                if(temp_w[127:125] > LOC_X)                                           // route computing of input from weat
                        begin                                                         //
                            trust_E <= trust_E - delta_x; 
                            west_route           =  EAST;                             //
                        end                                                           //
                    else if(temp_w[127:125] < LOC_X)                                  //
                        begin      
                            trust_W <= trust_W - delta_x;                             //
                            west_route           =  WEST;                             //
                        end                                                           //
                    else                                                              //  found the X dimension movement 
                        begin                                                         //
                            if(temp_w[124:122] > LOC_Y)                               //
                                begin                                                 //
                                    trust_N <= trust_N - delta_x;
                                    west_route   = NORTH;                             //
                                end                                                   //
                             else if (temp_w[124:122] < LOC_Y)                        //
                                begin                                                 //
                                    trust_S <= trust_S - delta_x;
                                    west_route   = SOUTH;                             //
                                end                                                   //
                            else if(temp_w[127:122]== {LOC_X,LOC_Y})                  //
                                   begin                                              //
                                        west_route   = LOCAL;                         //found the Y dimension movement  
                                    end
                                else    west_route   = 3'bz;                          //

                        end                                                           //


                if(temp_t[127:125] > LOC_X)                                           // route computation for input from local
                        begin                                                         //
                            trust_E = trust_E - delta_x;
                            local_route           =  EAST;                            //
                        end                                                           //
                    else if(temp_t[127:125] < LOC_X)                                  //
                        begin                                                         //
                            trust_W = trust_W - delta_x;
                            local_route           =  WEST;                            //
                        end                                                           //
                    else                                                              //found the X dimension movement 
                        begin                                                         //
                            if(temp_t[124:122] > LOC_Y)                               //
                                begin                                                 //
                                    trust_N = trust_N - delta_x;
                                    local_route   = NORTH;                            //
                                end                                                   //
                             else if (temp_t[124:122] < LOC_Y)                        //
                                begin                                                 //
                                    trust_S = trust_S - delta_x;
                                    local_route   = SOUTH;                            //
                                end                                                   //
                             else if(temp_t[127:122] == {LOC_X,LOC_Y})                //
                                   begin                                              //
                                        local_route   = LOCAL;                        //found the Y dimension movement 
                                    end
                                else    local_route   = 3'bz;                         //

                        end                                                           //
               
                
         
           end
           
  
  
  
  
  
  
/*---------------------------------------------------VC Allocation Unit-------------------------------------------------------------*/
  
  
  

  
  
  

  /* buffer at the East port of downstream router.*/

      
          
            always @(posedge clk1 ) 
                    
                    if (em_pl_d_E==3'd5)
                          buf_free_d_E =1;    //buf_free_d_E signal goes to the vc allocator .if it is 1 ,permission will be granted to access that particular port                                      
                    else
                          buf_free_d_E=0;

                                                 //this is just for keeping the functionality of the virtual channel(store and forward model)
                                                  //these are  dummy codes
        always @(posedge clk1 ) 
                   
                begin
                      
                      if (reset)  
                           
                            begin
                               
                               bf_d_E[0] = 128'b0;
                               bf_d_E[1] = 128'b0;
                               bf_d_E[2] = 128'b0;
                               bf_d_E[3] = 128'b0;
                               bf_d_E[4] = 128'b0;
                               em_pl_d_E = 3'd5;
                               add_wr_d_E = 3'd0;
                               add_rd_d_E = 3'd0;
                               
                           end 
   
                      else  if(!reset_d_E && !em_a_d_E )
      
                           begin
       
                               bf_d_E[add_wr_d_E] = bf_in_d_E;
                               em_pl_d_E = em_pl_d_E - 1;
                               add_wr_d_E = add_wr_d_E + 1;
                                   if (add_wr_d_E==3'b101)

                                           em_a_d_E = 1;        //when the buffer is full this signal become high and will be exit from the given loop
                                                                //now thus this if condition will become false and next if condition will become true and reading will start
                                   else                       
                                          em_a_d_E=0;
                           end
       
                     else  if (!reset_d_E && em_a_d_E) 
        
                           begin
        
                               bf_out_d_E = bf_d_E[add_rd_d_E];
                               em_pl_d_E = em_pl_d_E + 1;
                               add_rd_d_E = add_rd_d_E + 1;
                               
                                     if (add_rd_d_E==3'b101)
                                          begin
                                             em_a_d_E = 0;   //when the buffer read ( ie when popping is ompleted)is completed the value in this register become zero and will be exit from the given loop.
                                             reset_d_E=1;     //now the next always block will be activated and next reading will start
                                          end
                                    else  
                            
                                      begin          
                                         em_a_d_E=1;
                                          //reset=0;
                                      end
                         end
       
                  end 
  



  /* buffer at the West port of downstream router. */
             

          
          
            always @(posedge clk1 ) 
                    
                    if (em_pl_d_W==3'd5)
                          buf_free_d_W =1;    //buf_free_d_E signal goes to the vc allocator .if it is 1 ,permission will be granted to access that particular port                                      
                    else
                          buf_free_d_W=0;

                                                 //this is just for keeping the functionality of the virtual channel(store and forward model)
                                                  //these are  dummy codes
        always @(posedge clk1 ) 
                   
                begin
                      
                      if (reset)  
                           
                            begin
                               
                               bf_d_W[0] = 128'b0;
                               bf_d_W[1] = 128'b0;
                               bf_d_W[2] = 128'b0;
                               bf_d_W[3] = 128'b0;
                               bf_d_W[4] = 128'b0;
                               em_pl_d_W = 3'd5;
                               add_wr_d_W = 3'd0;
                               add_rd_d_W = 3'd0;
                               
                           end 
   
                      else  if(!reset_d_W && !em_a_d_W )
      
                           begin
       
                               bf_d_E[add_wr_d_W] = bf_in_d_W;
                               em_pl_d_W = em_pl_d_W - 1;
                               add_wr_d_W = add_wr_d_W + 1;
                                   if (add_wr_d_W==3'b101)

                                           em_a_d_W = 1;        //when the buffer is full this signal become high and will be exit from the given loop
                                                                //now thus this if condition will become false and next if condition will become true and reading will start
                                   else                       
                                          em_a_d_W=0;
                           end
       
                     else  if (!reset_d_W && em_a_d_W) 
        
                           begin
        
                               bf_out_d_W = bf_d_W[add_rd_d_W];
                               em_pl_d_W = em_pl_d_W + 1;
                               add_rd_d_W = add_rd_d_W + 1;
                               
                                     if (add_rd_d_W==3'b101)
                                          begin
                                             em_a_d_W = 0;   //when the buffer read ( ie when popping is ompleted)is completed the value in this register become zero and will be exit from the given loop.
                                             reset_d_W=1;     //now the next always block will be activated and next reading will start
                                          end
                                    else  
                            
                                      begin          
                                         em_a_d_W=1;
                                          //reset=0;
                                      end
                         end
       
                  end 
  


  


  /* buffer at the North port of downstream router. */
             
     
          
            always @(posedge clk1 ) 
                    
                    if (em_pl_d_N==3'd5)
                          buf_free_d_N =1;    //buf_free_d_E signal goes to the vc allocator .if it is 1 ,permission will be granted to access that particular port                                      
                    else
                          buf_free_d_N=0;

                                                 //this is just for keeping the functionality of the virtual channel(store and forward model)
                                                  //these are  dummy codes
        always @(posedge clk1 ) 
                   
                begin
                      
                      if (reset_d_N)  
                           
                            begin
                               
                               bf_d_N[0] = 128'b0;
                               bf_d_N[1] = 128'b0;
                               bf_d_N[2] = 128'b0;
                               bf_d_N[3] = 128'b0;
                               bf_d_N[4] = 128'b0;
                               em_pl_d_N = 3'd5;
                               add_wr_d_N = 3'd0;
                               add_rd_d_N = 3'd0;
                               
                           end 
   
                      else  if(!reset_d_N && !em_a_d_N )
      
                           begin
       
                               bf_d_N[add_wr_d_N] = bf_in_d_N;
                               em_pl_d_N = em_pl_d_N - 1;
                               add_wr_d_N = add_wr_d_N + 1;
                                   if (add_wr_d_N==3'b101)

                                           em_a_d_N = 1;        //when the buffer is full this signal become high and will be exit from the given loop
                                                                //now thus this if condition will become false and next if condition will become true and reading will start
                                   else                       
                                          em_a_d_N=0;
                           end
       
                     else  if (!reset_d_N && em_a_d_N) 
        
                           begin
        
                               bf_out_d_N = bf_d_N[add_rd_d_N];
                               em_pl_d_N = em_pl_d_N + 1;
                               add_rd_d_N = add_rd_d_N + 1;
                               
                                     if (add_rd_d_N==3'b101)
                                          begin
                                             em_a_d_N = 0;   //when the buffer read ( ie when popping is ompleted)is completed the value in this register become zero and will be exit from the given loop.
                                             reset_d_N=1;     //now the next always block will be activated and next reading will start
                                          end
                                    else  
                            
                                      begin          
                                         em_a_d_N=1;
                                          //reset=0;
                                      end
                         end
       
                  end 
  
 /* buffer at the south port of downstream router. */

    
          
            always @(posedge clk1 ) 
                    
                    if (em_pl_d_S==3'd5)
                          buf_free_d_S =1;    //buf_free_d_E signal goes to the vc allocator .if it is 1 ,permission will be granted to access that particular port                                      
                    else
                          buf_free_d_S=0;

                                                 //this is just for keeping the functionality of the virtual channel(store and forward model)
                                                  //these are  dummy codes
        always @(posedge clk1 ) 
                   
                begin
                      
                      if (reset_d_S)  
                           
                            begin
                               
                               bf_d_S[0] = 128'b0;
                               bf_d_S[1] = 128'b0;
                               bf_d_S[2] = 128'b0;
                               bf_d_S[3] = 128'b0;
                               bf_d_S[4] = 128'b0;
                               em_pl_d_S = 3'd5;
                               add_wr_d_S = 3'd0;
                               add_rd_d_S = 3'd0;
                               
                           end 
   
                      else  if(!reset_d_S && !em_a_d_S )
      
                           begin
       
                               bf_d_S[add_wr_d_S] = bf_in_d_S;
                               em_pl_d_S = em_pl_d_S - 1;
                               add_wr_d_S = add_wr_d_S + 1;
                                   if (add_wr_d_S==3'b101)

                                           em_a_d_S = 1;        //when the buffer is full this signal become high and will be exit from the given loop
                                                                //now thus this if condition will become false and next if condition will become true and reading will start
                                   else                       
                                          em_a_d_S=0;
                           end
       
                     else  if (!reset_d_S && em_a_d_S) 
        
                           begin
        
                               bf_out_d_S = bf_d_S[add_rd_d_S];
                               em_pl_d_S = em_pl_d_S + 1;
                               add_rd_d_S = add_rd_d_S + 1;
                               
                                     if (add_rd_d_S==3'b101)
                                          begin
                                             em_a_d_S = 0;   //when the buffer read ( ie when popping is ompleted)is completed the value in this register become zero and will be exit from the given loop.
                                             reset_d_S=1;     //now the next always block will be activated and next reading will start
                                          end
                                    else  
                            
                                      begin          
                                         em_a_d_S=1;
                                          //reset=0;
                                      end
                         end
       
                  end 
  
  
  
   /* buffer at the local port of downstream router. */ 
  
    

          
          
            always @(posedge clk1 ) 
                    
                    if (em_pl_d_T==3'd5)
                          buf_free_d_T =1;    //buf_free_d_E signal goes to the vc allocator .if it is 1 ,permission will be granted to access that particular port                                      
                    else
                          buf_free_d_T=0;

                                                 //this is just for keeping the functionality of the virtual channel(store and forward model)
                                                  //these are  dummy codes
        always @(posedge clk1 ) 
                   
                begin
                      
                      if (reset_d_T)  
                           
                            begin
                               
                               bf_d_T[0] = 128'b0;
                               bf_d_T[1] = 128'b0;
                               bf_d_T[2] = 128'b0;
                               bf_d_T[3] = 128'b0;
                               bf_d_T[4] = 128'b0;
                               em_pl_d_T = 3'd5;
                               add_wr_d_T = 3'd0;
                               add_rd_d_T = 3'd0;
                               
                           end 
   
                      else  if(!reset_d_T && !em_a_d_T )
      
                           begin
       
                               bf_d_T[add_wr_d_T] = bf_in_d_T;
                               em_pl_d_T = em_pl_d_T - 1;
                               add_wr_d_T = add_wr_d_T + 1;
                                   if (add_wr_d_T==3'b101)

                                           em_a_d_T = 1;        //when the buffer is full this signal become high and will be exit from the given loop
                                                                //now thus this if condition will become false and next if condition will become true and reading will start
                                   else                       
                                          em_a_d_T=0;
                           end
       
                     else  if (!reset_d_T && em_a_d_T) 
        
                           begin
        
                               bf_out_d_T = bf_d_T[add_rd_d_T];
                               em_pl_d_T = em_pl_d_T + 1;
                               add_rd_d_T = add_rd_d_T + 1;
                               
                                     if (add_rd_d_T==3'b101)
                                          begin
                                             em_a_d_T = 0;   //when the buffer read ( ie when popping is ompleted)is completed the value in this register become zero and will be exit from the given loop.
                                             reset_d_T=1;     //now the next always block will be activated and next reading will start
                                          end
                                    else  
                            
                                      begin          
                                         em_a_d_T=1;
                                          //reset=0;
                                      end
                         end
       
                  end 
  
 
 
 
 /*VC ALLOCATOR  */




always @(posedge clk1)
  begin
    
     case(east_route) 
     
      EAST : 
         if (buf_free_d_E)
            vc_grant_d_E=1;
         else
            vc_grant_d_E=0;
            
       WEST : 
         if (buf_free_d_W)
            vc_grant_d_E=1;
         else
            vc_grant_d_E=0;
            
       NORTH : 
         if (buf_free_d_N)
            vc_grant_d_E=1;                // downstream buffers nnte VC free aano nne ulla aknowledgement
         else
            vc_grant_d_E=0;                // ee signal aane current VC nne flits pop cheyyan vende use cheyunathe..
            
       SOUTH : 
         if (buf_free_d_S)
            vc_grant_d_E=1;
         else
            vc_grant_d_E=0;
            
       LOCAL : 
         if (buf_free_d_T)
            vc_grant_d_E=1;
         else
            vc_grant_d_E=0;
            
     endcase
  
  
      
     case(west_route) 
     
      EAST : 
         if (buf_free_d_E)
            vc_grant_d_W=1;
         else
            vc_grant_d_W=0;
            
       WEST : 
         if (buf_free_d_W)
            vc_grant_d_W=1;
         else
            vc_grant_d_W=0;
            
       NORTH : 
         if (buf_free_d_N)
            vc_grant_d_W=1;                // downstream buffers nnte VC free aano nne ulla aknowledgement
         else
            vc_grant_d_W=0;                // ee signal aane current VC nne flits pop cheyyan vende use cheyunathe..
            
       SOUTH : 
         if (buf_free_d_S)
            vc_grant_d_W=1;
         else
            vc_grant_d_W=0;
            
       LOCAL : 
         if (buf_free_d_T)
            vc_grant_d_W=1;
         else
            vc_grant_d_W=0;
            
     endcase
  
  
        
     case(north_route) 
     
      EAST : 
         if (buf_free_d_E)
            vc_grant_d_N=1;
         else
            vc_grant_d_N=0;
            
       WEST : 
         if (buf_free_d_W)
            vc_grant_d_N=1;
         else
            vc_grant_d_N=0;
            
       NORTH : 
         if (buf_free_d_N)
            vc_grant_d_N=1;                // downstream buffers nnte VC free aano nne ulla aknowledgement
         else
            vc_grant_d_N=0;                // ee signal aane current VC nne flits pop cheyyan vende use cheyunathe..
            
       SOUTH : 
         if (buf_free_d_S)
            vc_grant_d_N=1;
         else
            vc_grant_d_N=0;
            
       LOCAL : 
         if (buf_free_d_T)
            vc_grant_d_N=1;
         else
            vc_grant_d_N=0;
            
     endcase
  
  
  
          
     case(south_route) 
     
      EAST : 
         if (buf_free_d_E)
            vc_grant_d_S=1;
         else
            vc_grant_d_S=0;
            
       WEST : 
         if (buf_free_d_W)
            vc_grant_d_S=1;
         else
            vc_grant_d_S=0;
            
       NORTH : 
         if (buf_free_d_N)
            vc_grant_d_S=1;                // downstream buffers nnte VC free aano nne ulla aknowledgement
         else                                    
            vc_grant_d_S=0;                // ee signal aane current VC nne flits pop cheyyan vende use cheyunathe..
            
       SOUTH : 
         if (buf_free_d_S)
            vc_grant_d_S=1;
         else
            vc_grant_d_S=0;
            
       LOCAL : 
         if (buf_free_d_T)
            vc_grant_d_S=1;
         else
            vc_grant_d_S=0;
            
     endcase
  
  
  
  
  
          
     case(local_route) 
     
      EAST : 
         if (buf_free_d_E)
            vc_grant_d_T=1;
         else
            vc_grant_d_T=0;
            
       WEST : 
         if (buf_free_d_W)
            vc_grant_d_T=1;
         else
            vc_grant_d_T=0;
            
       NORTH : 
         if (buf_free_d_N)
            vc_grant_d_T=1;                // downstream buffers nnte VC free aano nne ulla aknowledgement
         else
            vc_grant_d_T=0;                // ee signal aane current VC nne flits pop cheyyan vende use cheyunathe..
            
       SOUTH : 
         if (buf_free_d_S)
            vc_grant_d_T=1;
         else
            vc_grant_d_T=0;
            
       LOCAL : 
         if (buf_free_d_T)
            vc_grant_d_T=1;
         else
            vc_grant_d_T=0;
            
     endcase
  
  
  
 end


/*---------------------------Switch Allocator--------------------------*/
   // reg  [1:0]temp_c = 0 ;
    always @(posedge clk2)
          
         begin   
       
                                if (reset)                                                   // counter is for implementing round robin algorithm
                           begin                                                             //    a mod 5 counter to change the priority
                               count = 0;                                                    //
                           end                                                               //   
                       else if(count == 3'b100)                                              //    0 -> 1 -> 2-> 3-> 4 counter
                           begin                                                             //    ^                 |
                               count = 0;                                                    //    |                 |
                           end                                                               //    |_________________|
                       else                                                                  //
                           begin                                                             //
                               count = count + 1;  
                                                                 //    simply a counter to use in round robin algorithm
                           end                                                               //    at a particular time instance , assume that count = 0
                                                                                //    then first priority is given to the signal from north port 
      end


     
     /* pop_ak_to_e_b , pop_ak_to_w_b , pop_ak_to_n_b , pop_ak_to_s_b , pop_ak_to_l_b */
     
     always @(posedge clk2)
          
         begin  
       
           
  
           
               case (count)
               
                           0:begin
                                   case (north_route)                                                              // all the case statements are not executing in parallel ; ie case (north_route) is executed first and after that case(south_route) that does not means they are executing one by one in posedge of clk ; they get executed one by one in a single clk cycle itself.
                                        NORTH:  begin
                                                    if(!north_taken && vc_grant_d_N)
                                                        begin
                                                            north_out = 3'd2;
                                                            north_taken = 1'b1;
                                                            pop_ak_to_n_b = 1'b1;
                                                            //bf_op_north = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                 //           bf_op_north = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && vc_grant_d_N)
                                                        begin
                                                            north_out = 3'd3;
                                                            south_taken = 1'b1;
                                                            pop_ak_to_n_b = 1'b1;
                                                   //         bf_op_north = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                  //          bf_op_north = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && vc_grant_d_N)
                                                         begin
                                                             north_out = 3'd1;
                                                             west_taken = 1'b1;
                                                             pop_ak_to_n_b = 1'b1;
                                                      //       bf_op_north = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                     //        bf_op_north = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && vc_grant_d_N)
                                                         begin
                                                             north_out = 3'd0;
                                                             east_taken = 1'b1;
                                                             pop_ak_to_n_b = 1'b1;
                                                           //  bf_op_north = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                        //     bf_op_north = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && vc_grant_d_N)
                                                           begin
                                                               north_out = 3'd4;
                                                               local_taken = 1'b1;
                                                               pop_ak_to_n_b = 1'b1;
                                                              // bf_op_north = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                            //   bf_op_north = 1'b1;
                                                           end
                                                end                                                                                                                                        
                                   endcase
                                    
                                   case (south_route)
                                        NORTH:  begin
                                                    if(!north_taken && vc_grant_d_S)
                                                        begin
                                                            south_out = 3'd2;
                                                            north_taken = 1'b1;
                                                            pop_ak_to_s_b = 1'b1;
                                                        //    bf_op_south = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                      //      bf_op_south = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && vc_grant_d_S)
                                                        begin
                                                            south_out = 3'd3;
                                                            south_taken = 1'b1;
                                                            pop_ak_to_s_b = 1'b1;
                                                        //    bf_op_south = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                      //      bf_op_south = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && vc_grant_d_S)
                                                         begin
                                                             south_out = 3'd1;
                                                             west_taken = 1'b1;
                                                             pop_ak_to_s_b = 1'b1;
                                                        //     bf_op_south = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                      //       bf_op_south = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && vc_grant_d_S)
                                                         begin
                                                             south_out = 3'd0;
                                                             east_taken = 1'b1;
                                                             pop_ak_to_s_b = 1'b1;
                                                         //    bf_op_south = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                       //      bf_op_south = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && vc_grant_d_S)
                                                           begin
                                                               south_out = 3'd4;
                                                               local_taken = 1'b1;
                                                               pop_ak_to_s_b = 1'b1;
                                                           //    bf_op_south = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                        //       bf_op_south = 1'b1;
                                                           end
                                                   end 
                                   endcase
                                    
                                   case (east_route)                   
                                    
                                        NORTH:  begin
                                                    if(!north_taken && vc_grant_d_E)
                                                        begin
                                                            east_out = 3'd2;
                                                            north_taken = 1'b1;
                                                            pop_ak_to_e_b = 1'b1;
                                                        //    bf_op_east = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                     //       bf_op_east = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && vc_grant_d_E)
                                                        begin
                                                            east_out = 3'd3;
                                                            south_taken = 1'b1;
                                                            pop_ak_to_e_b = 1'b1;
                                                       //     bf_op_east = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                      //      bf_op_east = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && vc_grant_d_E)
                                                         begin
                                                             east_out = 3'd1;
                                                             west_taken = 1'b1;
                                                             pop_ak_to_e_b = 1'b1;
                                                       //      bf_op_east = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                      //       bf_op_east = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && vc_grant_d_E)
                                                         begin
                                                             east_out = 3'd0;
                                                             east_taken = 1'b1;
                                                             pop_ak_to_e_b = 1'b1;
                                                         //    bf_op_east = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                       //      bf_op_east = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && vc_grant_d_E)
                                                           begin
                                                               east_out = 3'd4;
                                                               local_taken = 1'b1;
                                                               pop_ak_to_e_b = 1'b1;
                                                          //     bf_op_east = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                       //        bf_op_east = 1'b1;
                                                           end
                                                   end                                                                                                                                        
                                   endcase
                                    
                                   case (west_route)                   
                                    
                                        NORTH:  begin
                                                    if(!north_taken && vc_grant_d_W)
                                                        begin
                                                            west_out = 3'd2;
                                                            north_taken = 1'b1;
                                                            pop_ak_to_w_b = 1'b1;
                                                         //   bf_op_west = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                      //      bf_op_west = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && vc_grant_d_W)
                                                        begin
                                                            west_out = 3'd3;
                                                            south_taken = 1'b1;
                                                            pop_ak_to_w_b = 1'b1;
                                                         //   bf_op_west = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                       //     bf_op_west = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && vc_grant_d_W)
                                                         begin
                                                             west_out = 3'd1;
                                                             west_taken = 1'b1;
                                                             pop_ak_to_w_b = 1'b1;
                                                         //    bf_op_west = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                       //      bf_op_west = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && vc_grant_d_W)
                                                         begin
                                                             west_out = 3'd0;
                                                             east_taken = 1'b1;
                                                             pop_ak_to_w_b = 1'b1;
                                                         //    bf_op_west = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                         //    bf_op_west = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && vc_grant_d_W)
                                                           begin
                                                               west_out = 3'd4;
                                                               local_taken = 1'b1;
                                                               pop_ak_to_w_b = 1'b1;
                                                         //      bf_op_west = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                         //      bf_op_west = 1'b1;
                                                           end
                                                   end                                                                                                                                        
                                   endcase
 
                                   case (local_route)                   
                                    
                                        NORTH:  begin
                                                    if(!north_taken && vc_grant_d_T)
                                                        begin
                                                            local_out = 3'd2;
                                                            north_taken = 1'b1;
                                                            pop_ak_to_l_b = 1'b1;
                                                       //     bf_op_local = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                     //       bf_op_local = 1'b1;
                                                        end
                                                end
                                        SOUTH:  begin
                                                    if(!south_taken && vc_grant_d_T)
                                                        begin
                                                            local_out = 3'd3;
                                                            south_taken = 1'b1;
                                                            pop_ak_to_l_b = 1'b1;
                                                       //     bf_op_local = 1'b0;
                                                        end
                                                    else
                                                        begin
                                                      //      bf_op_local = 1'b1;
                                                        end
                                                end
                                         WEST:  begin
                                                     if(!west_taken && vc_grant_d_T)
                                                         begin
                                                             local_out = 3'd1;
                                                             west_taken = 1'b1;
                                                             pop_ak_to_l_b = 1'b1;
                                                       //      bf_op_local = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                   //          bf_op_local = 1'b1;
                                                         end
                                                 end
                                         EAST:  begin
                                                     if(!east_taken && vc_grant_d_T)
                                                         begin
                                                             local_out = 3'd0;
                                                             east_taken = 1'b1;
                                                             pop_ak_to_l_b = 1'b1;
                                                       //      bf_op_local = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                     //        bf_op_local = 1'b1;
                                                         end
                                                 end
                                        LOCAL:  begin
                                                       if(!local_taken && vc_grant_d_T)
                                                           begin
                                                               local_out = 3'd4;
                                                               local_taken = 1'b1;
                                                               pop_ak_to_l_b = 1'b1;
                                                        //       bf_op_local = 1'b0;
                                                           end
                                                       else
                                                           begin
                                                       //        bf_op_local = 1'b1;
                                                           end
                                                   end                                                                                                                                        
                                    endcase
                                    
                                                                       
                              end
                              
                              
                           1:begin
                                     
                                     case (south_route)
                                         NORTH:  begin
                                                     if(!north_taken && vc_grant_d_S)
                                                         begin
                                                             south_out =3'd2;
                                                             north_taken = 1'b1;
                                                             pop_ak_to_s_b = 1'b1;
                                                            // bf_op_south = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             //bf_op_south = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && vc_grant_d_S)
                                                         begin
                                                             south_out = 3'd3;
                                                             south_taken = 1'b1;
                                                             pop_ak_to_s_b = 1'b1;
                                                             //bf_op_south = 1'b0;
                                                         end
                                                     else
                                                         begin
                                               //              bf_op_south = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && vc_grant_d_S)
                                                          begin
                                                              south_out = 3'd1;
                                                              west_taken = 1'b1;
                                                              pop_ak_to_s_b = 1'b1;
                                                              //bf_op_south = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_south = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && vc_grant_d_S)
                                                          begin
                                                              south_out = 3'd0;
                                                              east_taken = 1'b1;
                                                              pop_ak_to_s_b = 1'b1;
                                                              //bf_op_south = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_south = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && vc_grant_d_S)
                                                            begin
                                                                south_out =3'd4;
                                                                local_taken = 1'b1;
                                                                pop_ak_to_s_b = 1'b1;
                                                                //bf_op_south = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                //bf_op_south = 1'b1;
                                                            end
                                                    end 
                                     endcase
                                     
                                     case (east_route)                   
                                     
                                         NORTH:  begin
                                                     if(!north_taken && vc_grant_d_E)
                                                         begin
                                                             east_out = 3'd2;
                                                             north_taken = 1'b1;
                                                             pop_ak_to_e_b = 1'b1;
                                                             //bf_op_east = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             //bf_op_east = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && vc_grant_d_E)
                                                         begin
                                                             east_out =3'd3;
                                                             south_taken = 1'b1;
                                                             pop_ak_to_e_b = 1'b1;
                                                             //bf_op_east = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             //bf_op_east = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && vc_grant_d_E)
                                                          begin
                                                              east_out = 3'd1;
                                                              west_taken = 1'b1;
                                                              pop_ak_to_e_b = 1'b1;
                                                              //bf_op_east = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_east = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && vc_grant_d_E)
                                                          begin
                                                              east_out = 3'd0;
                                                              east_taken = 1'b1;
                                                              pop_ak_to_e_b = 1'b1;
                                                              //bf_op_east = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_east = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && vc_grant_d_E)
                                                            begin
                                                                east_out = 3'd4;
                                                                local_taken = 1'b1;
                                                                pop_ak_to_e_b = 1'b1;
                                                                //bf_op_east = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                //bf_op_east = 1'b1;
                                                            end
                                                    end                                                                                                                                        
                                     endcase
                                     
                                     case (west_route)                   
                                     
                                         NORTH:  begin
                                                     if(!north_taken && vc_grant_d_W)
                                                         begin
                                                             west_out = 3'd2;
                                                             north_taken = 1'b1;
                                                             pop_ak_to_w_b = 1'b1;
                                                             //bf_op_west = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             //bf_op_west = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && vc_grant_d_W)
                                                         begin
                                                             west_out =3'd3;
                                                             south_taken = 1'b1;
                                                             pop_ak_to_w_b = 1'b1;
                                                             //bf_op_west = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             //bf_op_west = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && vc_grant_d_W)
                                                          begin
                                                              west_out = 3'd1;
                                                              west_taken = 1'b1;
                                                              pop_ak_to_w_b = 1'b1;
                                                              //bf_op_west = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_west = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && vc_grant_d_W)
                                                          begin
                                                              west_out =3'd0;
                                                              east_taken = 1'b1;
                                                              pop_ak_to_w_b = 1'b1;
                                                              //bf_op_west = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_west = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && vc_grant_d_W)
                                                            begin
                                                                west_out = 3'd4;
                                                                local_taken = 1'b1;
                                                                pop_ak_to_w_b = 1'b1;
                                                                //bf_op_west = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                //bf_op_west = 1'b1;
                                                            end
                                                    end                                                                                                                                        
                                     endcase
        
                                     case (local_route)                   
                                     
                                         NORTH:  begin
                                                     if(!north_taken && vc_grant_d_T)
                                                         begin
                                                             local_out =3'd2;
                                                             north_taken = 1'b1;
                                                             pop_ak_to_l_b = 1'b1;
                                                            // bf_op_local = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                            // bf_op_local = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && vc_grant_d_T)
                                                         begin
                                                             local_out =3'd3;
                                                             south_taken = 1'b1;
                                                             pop_ak_to_l_b = 1'b1;
                                                             //bf_op_local = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             //bf_op_local = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && vc_grant_d_T)
                                                          begin
                                                              local_out = 3'd1;
                                                              west_taken = 1'b1;
                                                              pop_ak_to_l_b = 1'b1;
                                                              //bf_op_local = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_local = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && vc_grant_d_T)
                                                          begin
                                                              local_out =3'd0;
                                                              east_taken = 1'b1;
                                                              pop_ak_to_l_b = 1'b1;
                                                              //bf_op_local = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_local = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && vc_grant_d_T)
                                                            begin
                                                                local_out = 3'd4;
                                                                local_taken = 1'b1;
                                                                pop_ak_to_l_b = 1'b1;
                                                                //bf_op_local = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                //bf_op_local = 1'b1;
                                                            end
                                                    end                                                                                                                                        
                                     endcase
                                     
                                    case (north_route)
                                         NORTH:  begin
                                                     if(!north_taken && vc_grant_d_N)
                                                         begin
                                                             north_out = 3'd2;
                                                             north_taken = 1'b1;
                                                             pop_ak_to_n_b = 1'b1;
                                                            // bf_op_north = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             //bf_op_north = 1'b1;
                                                         end
                                                 end
                                         SOUTH:  begin
                                                     if(!south_taken && vc_grant_d_N)
                                                         begin
                                                             north_out =3'd3;
                                                             south_taken = 1'b1;
                                                             pop_ak_to_n_b = 1'b1;
                                                             //bf_op_north = 1'b0;
                                                         end
                                                     else
                                                         begin
                                                             //bf_op_north = 1'b1;
                                                         end
                                                 end
                                          WEST:  begin
                                                      if(!west_taken && vc_grant_d_N)
                                                          begin
                                                              north_out = 3'd1;
                                                              west_taken = 1'b1;
                                                              pop_ak_to_n_b = 1'b1;
                                                              //bf_op_north = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_north = 1'b1;
                                                          end
                                                  end
                                          EAST:  begin
                                                      if(!east_taken && vc_grant_d_N)
                                                          begin
                                                              north_out =3'd0;
                                                              east_taken = 1'b1;
                                                              pop_ak_to_n_b = 1'b1;
                                                              //bf_op_north = 1'b0;
                                                          end
                                                      else
                                                          begin
                                                              //bf_op_north = 1'b1;
                                                          end
                                                  end
                                         LOCAL:  begin
                                                        if(!local_taken && vc_grant_d_N)
                                                            begin
                                                                north_out = 3'd4;
                                                                local_taken = 1'b1;
                                                                pop_ak_to_n_b = 1'b1;
                                                                //bf_op_north = 1'b0;
                                                            end
                                                        else
                                                            begin
                                                                //bf_op_north = 1'b1;
                                                            end
                                                    end                                                                                                                                        
                                     endcase
                                     
                                                                        
                               end

                            2:begin
                                                                               
                                         case (east_route)                   
                                         
                                             NORTH:  begin
                                                         if(!north_taken && vc_grant_d_E)
                                                             begin
                                                                 east_out = 3'd2;
                                                                 north_taken = 1'b1;
                                                                 pop_ak_to_e_b = 1'b1;
                                                                 //bf_op_east = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                // bf_op_east = 1'b1;
                                                             end
                                                     end
                                             SOUTH:  begin
                                                         if(!south_taken && vc_grant_d_E)
                                                             begin
                                                                 east_out = 3'd3;
                                                                 south_taken = 1'b1;
                                                                 pop_ak_to_e_b = 1'b1;
                                                                 //bf_op_east = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 //bf_op_east = 1'b1;
                                                             end
                                                     end
                                              WEST:  begin
                                                          if(!west_taken && vc_grant_d_E)
                                                              begin
                                                                  east_out = 3'd1;
                                                                  west_taken = 1'b1;
                                                                  pop_ak_to_e_b = 1'b1;
                                                                  //bf_op_east = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_east = 1'b1;
                                                              end
                                                      end
                                              EAST:  begin
                                                          if(!east_taken && vc_grant_d_E)
                                                              begin
                                                                  east_out = 3'd0;
                                                                  east_taken = 1'b1;
                                                                  pop_ak_to_e_b = 1'b1;
                                                                  //bf_op_east = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_east = 1'b1;
                                                              end
                                                      end
                                             LOCAL:  begin
                                                            if(!local_taken && vc_grant_d_E)
                                                                begin
                                                                    east_out = 3'd4;
                                                                    local_taken = 1'b1;
                                                                    pop_ak_to_e_b = 1'b1;
                                                                    //bf_op_east = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                   // bf_op_east = 1'b1;
                                                                end
                                                        end                                                                                                                                        
                                         endcase
                                         
                                         case (west_route)                   
                                         
                                             NORTH:  begin
                                                         if(!north_taken && vc_grant_d_W)
                                                             begin
                                                                 west_out = 3'd2;
                                                                 north_taken = 1'b1;
                                                                 pop_ak_to_w_b = 1'b1;
                                                                 //bf_op_west = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 //bf_op_west = 1'b1;
                                                             end
                                                     end
                                             SOUTH:  begin  
                                                         if(!south_taken && vc_grant_d_W)
                                                             begin
                                                                 west_out = 3'd3;
                                                                 south_taken = 1'b1;
                                                                 pop_ak_to_w_b = 1'b1;
                                                                 //bf_op_west = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 //bf_op_west = 1'b1;
                                                             end
                                                     end
                                              WEST:  begin
                                                          if(!west_taken && vc_grant_d_W)
                                                              begin
                                                                  west_out = 3'd1;
                                                                  west_taken = 1'b1;
                                                                  pop_ak_to_w_b = 1'b1;
                                                                 // bf_op_west = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_west = 1'b1;
                                                              end
                                                      end
                                              EAST:  begin
                                                          if(!east_taken && vc_grant_d_W)
                                                              begin
                                                                  west_out = 3'd0;
                                                                  east_taken = 1'b1;
                                                                  pop_ak_to_w_b = 1'b1;
                                                                  //bf_op_west = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_west = 1'b1;
                                                              end
                                                      end
                                             LOCAL:  begin
                                                            if(!local_taken && vc_grant_d_W)
                                                                begin
                                                                    west_out =3'd4;
                                                                    local_taken = 1'b1;
                                                                    pop_ak_to_w_b = 1'b1;
                                                                    //bf_op_west = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    //bf_op_west = 1'b1;
                                                                end
                                                        end                                                                                                                                        
                                         endcase
            
                                         case (local_route)                   
                                         
                                             NORTH:  begin
                                                         if(!north_taken && vc_grant_d_T)
                                                             begin
                                                                 local_out = 3'd2;
                                                                 north_taken = 1'b1;
                                                                 pop_ak_to_l_b = 1'b1;
                                                                 //bf_op_local = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 //bf_op_local = 1'b1;
                                                             end
                                                     end
                                             SOUTH:  begin
                                                         if(!south_taken && vc_grant_d_T)
                                                             begin
                                                                 local_out = 3'd3;
                                                                 south_taken = 1'b1;
                                                                 pop_ak_to_l_b = 1'b1;
                                                                 //bf_op_local = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 //bf_op_local = 1'b1;
                                                             end
                                                     end
                                              WEST:  begin
                                                          if(!west_taken && vc_grant_d_T)
                                                              begin
                                                                  local_out = 3'd1;
                                                                  west_taken = 1'b1;
                                                                  pop_ak_to_l_b = 1'b1;
                                                                  //bf_op_local = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_local = 1'b1;
                                                              end
                                                      end
                                              EAST:  begin
                                                          if(!east_taken && vc_grant_d_T)
                                                              begin
                                                                  local_out = 3'd0;
                                                                  east_taken = 1'b1;
                                                                  pop_ak_to_l_b = 1'b1;
                                                                  //bf_op_local = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                 // bf_op_local = 1'b1;
                                                              end
                                                      end
                                             LOCAL:  begin
                                                            if(!local_taken && vc_grant_d_T)
                                                                begin
                                                                    local_out = 3'd4;
                                                                    local_taken = 1'b1;
                                                                    pop_ak_to_l_b = 1'b1;
                                                                   // bf_op_local = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    //bf_op_local = 1'b1;
                                                                end
                                                        end                                                                                                                                        
                                         endcase
                                         
                                        case (north_route)
                                             NORTH:  begin
                                                         if(!north_taken && vc_grant_d_N)
                                                             begin
                                                                 north_out =3'd2;
                                                                 north_taken = 1'b1;
                                                                 pop_ak_to_n_b = 1'b1;
                                                                 //bf_op_north = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 //bf_op_north = 1'b1;
                                                             end
                                                     end
                                             SOUTH:  begin
                                                         if(!south_taken && vc_grant_d_N)
                                                             begin
                                                                 north_out = 3'd3;
                                                                 south_taken = 1'b1;
                                                                 pop_ak_to_n_b = 1'b1;
                                                                // bf_op_north = 1'b0;
                                                             end
                                                         else
                                                             begin
                                                                 //bf_op_north = 1'b1;
                                                             end
                                                     end
                                              WEST:  begin
                                                          if(!west_taken && vc_grant_d_N)
                                                              begin
                                                                  north_out = 3'd1;
                                                                  west_taken = 1'b1;
                                                                  pop_ak_to_n_b = 1'b1;
                                                                 // bf_op_north = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_north = 1'b1;
                                                              end
                                                      end
                                              EAST:  begin
                                                          if(!east_taken && vc_grant_d_N)
                                                              begin
                                                                  north_out =3'd0;
                                                                  east_taken = 1'b1;
                                                                  pop_ak_to_n_b = 1'b1;
                                                                  //bf_op_north = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_north = 1'b1;
                                                              end
                                                      end
                                             LOCAL:  begin
                                                            if(!local_taken && vc_grant_d_N)
                                                                begin
                                                                    north_out = 3'd4;
                                                                    local_taken = 1'b1;
                                                                    pop_ak_to_n_b = 1'b1;
                                                                    //bf_op_north = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    //bf_op_north = 1'b1;
                                                                end
                                                        end                                                                                                                                        
                                         endcase
                                         
                                          case (south_route)
                                                NORTH:  begin
                                                            if(!north_taken && vc_grant_d_S)
                                                                begin
                                                                    south_out = 3'd2;
                                                                    north_taken = 1'b1;
                                                                    pop_ak_to_s_b = 1'b1;
                                                                    //bf_op_south = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    //bf_op_south = 1'b1;
                                                                end
                                                        end
                                                SOUTH:  begin
                                                            if(!south_taken && vc_grant_d_S)
                                                                begin
                                                                    south_out = 3'd3;
                                                                    south_taken = 1'b1;
                                                                    pop_ak_to_s_b = 1'b1;
                                                                    //bf_op_south = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    //bf_op_south = 1'b1;
                                                                end
                                                        end
                                                 WEST:  begin
                                                             if(!west_taken && vc_grant_d_S)
                                                                 begin
                                                                     south_out = 3'd1;
                                                                     west_taken = 1'b1;
                                                                     pop_ak_to_s_b = 1'b1;
                                                                     //bf_op_south = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     //bf_op_south = 1'b1;
                                                                 end
                                                         end
                                                 EAST:  begin
                                                             if(!east_taken && vc_grant_d_S)
                                                                 begin
                                                                     south_out = 3'd0;
                                                                     east_taken = 1'b1;
                                                                     pop_ak_to_s_b = 1'b1;
                                                                     //bf_op_south = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     //bf_op_south = 1'b1;
                                                                 end
                                                         end
                                                LOCAL:  begin
                                                            if(!local_taken && vc_grant_d_S)
                                                                begin
                                                                    south_out =3'd4;
                                                                    local_taken = 1'b1;
                                                                    pop_ak_to_s_b = 1'b1;
                                                                    //bf_op_south = 1'b0;
                                                                end
                                                            else
                                                                begin
                                                                    //bf_op_south = 1'b1;
                                                                end
                                                        end 
                                         endcase
                                                                                 
                                                                            
                                   end

                            3:begin
                                                                                      
                                          case (west_route)                   
                                          
                                              NORTH:  begin
                                                          if(!north_taken && vc_grant_d_W)
                                                              begin
                                                                  west_out =3'd2 ;
                                                                  north_taken = 1'b1;
                                                                  pop_ak_to_w_b = 1'b1;
                                                                  //bf_op_west = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_west = 1'b1;
                                                              end
                                                      end
                                              SOUTH:  begin
                                                          if(!south_taken && vc_grant_d_W)
                                                              begin
                                                                  west_out =3'd3;
                                                                  south_taken = 1'b1;
                                                                  pop_ak_to_w_b = 1'b1;
                                                                  //bf_op_west = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_west = 1'b1;
                                                              end
                                                      end
                                               WEST:  begin
                                                           if(!west_taken && vc_grant_d_W)
                                                               begin
                                                                   west_out = 3'd1;
                                                                   west_taken = 1'b1;
                                                                   pop_ak_to_w_b = 1'b1;
                                                                   //bf_op_west = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   //bf_op_west = 1'b1;
                                                               end
                                                       end
                                               EAST:  begin
                                                           if(!east_taken && vc_grant_d_W)
                                                               begin
                                                                   west_out = 3'd0;
                                                                   east_taken = 1'b1;
                                                                   pop_ak_to_w_b = 1'b1;
                                                                   //bf_op_west = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   //bf_op_west = 1'b1;
                                                               end
                                                       end
                                              LOCAL:  begin
                                                             if(!local_taken && vc_grant_d_W)
                                                                 begin
                                                                     west_out = 3'd4;
                                                                     local_taken = 1'b1;
                                                                     pop_ak_to_w_b = 1'b1;
                                                                    // bf_op_west = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     //bf_op_west = 1'b1;
                                                                 end
                                                         end                                                                                                                                        
                                          endcase
         
                                          case (local_route)                   
                                          
                                              NORTH:  begin
                                                          if(!north_taken && vc_grant_d_T)
                                                              begin
                                                                  local_out = 3'd2;
                                                                  north_taken = 1'b1;
                                                                  pop_ak_to_l_b = 1'b1;
                                                                  //bf_op_local = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_local = 1'b1;
                                                              end
                                                      end
                                              SOUTH:  begin
                                                          if(!south_taken && vc_grant_d_T)
                                                              begin
                                                                  local_out = 3'd3;
                                                                  south_taken = 1'b1;
                                                                  pop_ak_to_l_b = 1'b1;
                                                                  //bf_op_local = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_local = 1'b1;
                                                              end
                                                      end
                                               WEST:  begin
                                                           if(!west_taken && vc_grant_d_T)
                                                               begin
                                                                   local_out = 3'd1;
                                                                   west_taken = 1'b1;
                                                                   pop_ak_to_l_b = 1'b1;
                                                                   //bf_op_local = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   //bf_op_local = 1'b1;
                                                               end
                                                       end
                                               EAST:  begin
                                                           if(!east_taken && vc_grant_d_T)
                                                               begin
                                                                   local_out = 3'd0;
                                                                   east_taken = 1'b1;
                                                                   pop_ak_to_l_b = 1'b1;
                                                                   //bf_op_local = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   //bf_op_local = 1'b1;
                                                               end
                                                       end
                                              LOCAL:  begin
                                                             if(!local_taken && vc_grant_d_T)
                                                                 begin
                                                                     local_out = 3'd4;
                                                                     local_taken = 1'b1;
                                                                     pop_ak_to_l_b = 1'b1;
                                                                     //bf_op_local = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     //bf_op_local = 1'b1;
                                                                 end
                                                         end
                                          endcase
                                          
                                         case (north_route)
                                              NORTH:  begin
                                                          if(!north_taken && vc_grant_d_N)
                                                              begin
                                                                  north_out = 3'd2;
                                                                  north_taken = 1'b1;
                                                                  pop_ak_to_n_b = 1'b1;
                                                                  //bf_op_north = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_north = 1'b1;
                                                              end
                                                      end
                                              SOUTH:  begin
                                                          if(!south_taken && vc_grant_d_N)
                                                              begin
                                                                  north_out = 3'd3;
                                                                  south_taken = 1'b1;
                                                                  pop_ak_to_n_b = 1'b1;
                                                                  //bf_op_north = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_north = 1'b1;
                                                              end
                                                      end
                                               WEST:  begin
                                                           if(!west_taken && vc_grant_d_N)
                                                               begin
                                                                   north_out = 3'd1;
                                                                   west_taken = 1'b1;
                                                                   pop_ak_to_n_b = 1'b1;
                                                                  // bf_op_north = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   //bf_op_north = 1'b1;
                                                               end
                                                       end
                                               EAST:  begin
                                                           if(!east_taken && vc_grant_d_N)
                                                               begin
                                                                   north_out = 3'd0;
                                                                   east_taken = 1'b1;
                                                                   pop_ak_to_n_b = 1'b1;
                                                                   //bf_op_north = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   //bf_op_north = 1'b1;
                                                               end
                                                       end
                                              LOCAL:  begin
                                                             if(!local_taken && vc_grant_d_N)
                                                                 begin
                                                                     north_out = 3'd4;
                                                                     local_taken = 1'b1;
                                                                     pop_ak_to_n_b = 1'b1;
                                                                     //bf_op_north = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                    // bf_op_north = 1'b1;
                                                                 end
                                                         end
                                          endcase
                                          
                                           case (south_route)
                                                 NORTH:  begin
                                                             if(!north_taken && vc_grant_d_S)
                                                                 begin
                                                                     south_out = 3'd2;
                                                                     north_taken = 1'b1;
                                                                     pop_ak_to_s_b = 1'b1;
                                                                     //bf_op_south = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     //bf_op_south = 1'b1;
                                                                 end
                                                         end
                                                 SOUTH:  begin
                                                             if(!south_taken && vc_grant_d_S)
                                                                 begin
                                                                     south_out = 3'd3;
                                                                     south_taken = 1'b1;
                                                                     pop_ak_to_s_b = 1'b1;
                                                                    // bf_op_south = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     //bf_op_south = 1'b1;
                                                                 end
                                                         end
                                                  WEST:  begin
                                                              if(!west_taken && vc_grant_d_S)
                                                                  begin
                                                                      south_out = 3'd1;
                                                                      west_taken = 1'b1;
                                                                      pop_ak_to_s_b = 1'b1;
                                                                      //bf_op_south = 1'b0;
                                                                  end
                                                              else
                                                                  begin
                                                                      //bf_op_south = 1'b1;
                                                                  end
                                                          end
                                                  EAST:  begin
                                                              if(!east_taken && vc_grant_d_S)
                                                                  begin
                                                                      south_out = 3'd0;
                                                                      east_taken = 1'b1;
                                                                      pop_ak_to_s_b = 1'b1;
                                                                      //bf_op_south = 1'b0;
                                                                  end
                                                              else
                                                                  begin
                                                                      //bf_op_south = 1'b1;
                                                                  end
                                                          end
                                                 LOCAL:  begin
                                                               if(!local_taken && vc_grant_d_S)
                                                                   begin
                                                                       south_out = 3'd4;
                                                                       local_taken = 1'b1;
                                                                       pop_ak_to_s_b = 1'b1;
                                                                       //bf_op_south = 1'b0;
                                                                   end
                                                               else
                                                                   begin
                                                                       //bf_op_south = 1'b1;
                                                                   end
                                                           end 
                                   endcase
                                           
                                   case (east_route)                   
                                                
                                                NORTH:  begin
                                                          if(!north_taken && vc_grant_d_E)
                                                              begin
                                                                  east_out = 3'd2;
                                                                  north_taken = 1'b1;
                                                                  pop_ak_to_e_b = 1'b1;
                                                                 // bf_op_east = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_east = 1'b1;
                                                              end
                                                      end
                                              SOUTH:  begin
                                                          if(!south_taken && vc_grant_d_E)
                                                              begin
                                                                  east_out = 3'd3;
                                                                  south_taken = 1'b1;
                                                                  pop_ak_to_e_b = 1'b1;
                                                                  //bf_op_east = 1'b0;
                                                              end
                                                          else
                                                              begin
                                                                  //bf_op_east = 1'b1;
                                                              end
                                                      end
                                               WEST:  begin
                                                           if(!west_taken && vc_grant_d_E)
                                                               begin
                                                                   east_out = 3'd1;
                                                                   west_taken = 1'b1;
                                                                   pop_ak_to_e_b = 1'b1;
                                                                   //bf_op_east = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   //bf_op_east = 1'b1;
                                                               end
                                                       end
                                               EAST:  begin
                                                           if(!east_taken && vc_grant_d_E)
                                                               begin
                                                                   east_out =3'd0;
                                                                   east_taken = 1'b1;
                                                                   pop_ak_to_e_b = 1'b1;
                                                                   //bf_op_east = 1'b0;
                                                               end
                                                           else
                                                               begin
                                                                   //bf_op_east = 1'b1;
                                                               end
                                                       end
                                              LOCAL:  begin
                                                             if(!local_taken && vc_grant_d_E)
                                                                 begin
                                                                     east_out =3'd4;
                                                                     local_taken = 1'b1;
                                                                     pop_ak_to_e_b = 1'b1;
                                                                     //bf_op_east = 1'b0;
                                                                 end
                                                             else
                                                                 begin
                                                                     //bf_op_east = 1'b1;
                                                                 end
                                                         end                                                                                                                                        
                                          endcase
                                          end
                                          
                            4:begin
                                                                                                    
                       
                                                        case (local_route)                   
                                                        
                                                            NORTH:  begin
                                                                        if(!north_taken && vc_grant_d_T)
                                                                            begin
                                                                                local_out = 3'd2;
                                                                                north_taken = 1'b1;
                                                                                pop_ak_to_l_b = 1'b1;
                                                                               // bf_op_local = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                               // bf_op_local = 1'b1;
                                                                            end
                                                                    end
                                                            SOUTH:  begin
                                                                        if(!south_taken && vc_grant_d_T)
                                                                            begin
                                                                                local_out = 3'd3;
                                                                                south_taken = 1'b1;
                                                                                pop_ak_to_l_b = 1'b1;
                                                                               // bf_op_local = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                               // bf_op_local = 1'b1;
                                                                            end
                                                                    end
                                                             WEST:  begin
                                                                         if(!west_taken && vc_grant_d_T)
                                                                             begin
                                                                                 local_out = 3'd1;
                                                                                 west_taken = 1'b1;
                                                                                 pop_ak_to_l_b = 1'b1;
                                                                                 //bf_op_local = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                 //bf_op_local = 1'b1;
                                                                             end
                                                                     end
                                                             EAST:  begin
                                                                         if(!east_taken && vc_grant_d_T)
                                                                             begin
                                                                                 local_out = 3'd0;
                                                                                 east_taken = 1'b1;
                                                                                 pop_ak_to_l_b = 1'b1;
                                                                                 //bf_op_local = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                // bf_op_local = 1'b1;
                                                                             end
                                                                     end
                                                            LOCAL:  begin
                                                                           if(!local_taken && vc_grant_d_T)
                                                                               begin
                                                                                   local_out = 3'd4;
                                                                                   local_taken = 1'b1;
                                                                                   pop_ak_to_l_b = 1'b1;
                                                                                  // bf_op_local = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                  // bf_op_local = 1'b1;
                                                                               end
                                                                       end
                                                        endcase
                                                        
                                                       case (north_route)
                                                            NORTH:  begin
                                                                        if(!north_taken && vc_grant_d_N)
                                                                            begin
                                                                                north_out =3'd2;
                                                                                north_taken = 1'b1;
                                                                                pop_ak_to_n_b = 1'b1;
                                                                               // bf_op_north = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                               // bf_op_north = 1'b1;
                                                                            end
                                                                    end
                                                            SOUTH:  begin
                                                                        if(!south_taken && vc_grant_d_N)
                                                                            begin
                                                                                north_out = 3'd3;
                                                                                south_taken = 1'b1;
                                                                                pop_ak_to_n_b = 1'b1;
                                                                                //bf_op_north = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                               // bf_op_north = 1'b1;
                                                                            end
                                                                    end
                                                             WEST:  begin
                                                                         if(!west_taken && vc_grant_d_N)
                                                                             begin
                                                                                 north_out = 3'd1;
                                                                                 west_taken = 1'b1;
                                                                                 pop_ak_to_n_b = 1'b1;
                                                                                 //bf_op_north = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                // bf_op_north = 1'b1;
                                                                             end
                                                                     end
                                                             EAST:  begin
                                                                         if(!east_taken && vc_grant_d_N)
                                                                             begin
                                                                                 north_out = 3'd0;
                                                                                 east_taken = 1'b1;
                                                                                 pop_ak_to_n_b = 1'b1;
                                                                                // bf_op_north = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                                // bf_op_north = 1'b1;
                                                                             end
                                                                     end
                                                            LOCAL:  begin
                                                                           if(!local_taken && vc_grant_d_N)
                                                                               begin
                                                                                   north_out = 3'd4;
                                                                                   local_taken = 1'b1;
                                                                                   pop_ak_to_n_b = 1'b1;
                                                                                  // bf_op_north = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                  // bf_op_north = 1'b1;
                                                                               end
                                                                       end
                                                        endcase
                                                        
                                                         case (south_route)
                                                               NORTH:  begin
                                                                           if(!north_taken && vc_grant_d_S)
                                                                               begin
                                                                                   south_out =3'd2;
                                                                                   north_taken = 1'b1;
                                                                                   pop_ak_to_s_b = 1'b1;
                                                                                   //bf_op_south = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                   //bf_op_south = 1'b1;
                                                                               end
                                                                       end
                                                               SOUTH:  begin
                                                                           if(!south_taken && vc_grant_d_S)
                                                                               begin
                                                                                   south_out = 3'd3;
                                                                                   south_taken = 1'b1;
                                                                                   pop_ak_to_s_b = 1'b1;
                                                                                   //bf_op_south = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                                  // bf_op_south = 1'b1;
                                                                               end
                                                                       end
                                                                WEST:  begin
                                                                            if(!west_taken && vc_grant_d_S)
                                                                                begin
                                                                                    south_out =3'd1;
                                                                                    west_taken = 1'b1;
                                                                                    pop_ak_to_s_b = 1'b1;
                                                                                    //bf_op_south = 1'b0;
                                                                                end
                                                                            else
                                                                                begin
                                                                                   // bf_op_south = 1'b1;
                                                                                end
                                                                        end
                                                                EAST:  begin
                                                                            if(!east_taken && vc_grant_d_S)
                                                                                begin
                                                                                    south_out =3'd0;
                                                                                    east_taken = 1'b1;
                                                                                    pop_ak_to_s_b = 1'b1;
                                                                                 //   bf_op_south = 1'b0;
                                                                                end
                                                                            else
                                                                                begin
                                                                          //          bf_op_south = 1'b1;
                                                                                end
                                                                        end
                                                               LOCAL:  begin
                                                                             if(!local_taken && vc_grant_d_S)
                                                                                 begin
                                                                                     south_out = 3'd4;
                                                                                     local_taken = 1'b1;
                                                                                     pop_ak_to_s_b = 1'b1;
                                                                               //      bf_op_south = 1'b0;
                                                                                 end
                                                                             else
                                                                                 begin
                                                                            //         bf_op_south = 1'b1;
                                                                                 end
                                                                         end 
                                                 endcase
                                                         
                                                 case (east_route)                   
                                                              
                                                              NORTH:  begin
                                                                        if(!north_taken && vc_grant_d_E)
                                                                            begin
                                                                                east_out = 3'd2;
                                                                                north_taken = 1'b1;
                                                                                pop_ak_to_e_b = 1'b1;
                                                                             //   bf_op_east = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                         //       bf_op_east = 1'b1;
                                                                            end
                                                                    end
                                                            SOUTH:  begin
                                                                        if(!south_taken && vc_grant_d_E)
                                                                            begin
                                                                                east_out = 3'd3;
                                                                                south_taken = 1'b1;
                                                                                pop_ak_to_e_b = 1'b1;
                                                                        //        bf_op_east = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                        //        bf_op_east = 1'b1;
                                                                            end
                                                                    end
                                                             WEST:  begin
                                                                         if(!west_taken && vc_grant_d_E)
                                                                             begin
                                                                                 east_out = 3'd1;
                                                                                 west_taken = 1'b1;
                                                                                 pop_ak_to_e_b = 1'b1;
                                                                           //      bf_op_east = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                          //       bf_op_east = 1'b1;
                                                                             end
                                                                     end
                                                             EAST:  begin
                                                                         if(!east_taken && vc_grant_d_E)
                                                                             begin
                                                                                 east_out = 3'd0;
                                                                                 east_taken = 3'd1;
                                                                                 pop_ak_to_e_b = 1'b1;
                                                                              //   bf_op_east = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                          //       bf_op_east = 1'b1;
                                                                             end
                                                                     end
                                                            LOCAL:  begin
                                                                           if(!local_taken && vc_grant_d_E)
                                                                               begin
                                                                                   east_out = 3'd4;
                                                                                   local_taken = 1'b1;
                                                                                   pop_ak_to_e_b = 1'b1;
                                                                          //         bf_op_east = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                         //          bf_op_east = 1'b1;
                                                                               end
                                                                       end                                                                                                                                        
                                                        endcase
                                                        
                                                        case (west_route)                   
                                                        
                                                            NORTH:  begin
                                                                        if(!north_taken && vc_grant_d_W)
                                                                            begin
                                                                                west_out = 3'd2;
                                                                                north_taken = 1'b1;
                                                                                pop_ak_to_w_b = 1'b1;
                                                                           //     bf_op_west = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                       //         bf_op_west = 1'b1;
                                                                            end
                                                                    end
                                                            SOUTH:  begin
                                                                        if(!south_taken && vc_grant_d_W)
                                                                            begin
                                                                                west_out = 3'd3;
                                                                                south_taken = 1'b1;
                                                                                pop_ak_to_w_b = 1'b1;
                                                                           //     bf_op_west = 1'b0;
                                                                            end
                                                                        else
                                                                            begin
                                                                       //         bf_op_west = 1'b1;
                                                                            end
                                                                    end
                                                             WEST:  begin
                                                                         if(!west_taken && vc_grant_d_W)
                                                                             begin
                                                                                 west_out = 3'd1;
                                                                                 west_taken = 1'b1;
                                                                                 pop_ak_to_w_b = 1'b1;
                                                                           //      bf_op_west = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                        //         bf_op_west = 1'b1;
                                                                             end
                                                                     end
                                                             EAST:  begin
                                                                         if(!east_taken && vc_grant_d_W)
                                                                             begin
                                                                                 west_out = 3'd0;
                                                                                 east_taken = 1'b1;
                                                                                 pop_ak_to_w_b = 1'b1;
                                                                           //      bf_op_west = 1'b0;
                                                                             end
                                                                         else
                                                                             begin
                                                                        //         bf_op_west = 1'b1;
                                                                             end
                                                                     end
                                                            LOCAL:  begin
                                                                           if(!local_taken && vc_grant_d_W)
                                                                               begin
                                                                                   west_out = 3'd4;
                                                                                   local_taken = 1'b1;
                                                                                   pop_ak_to_w_b = 1'b1;
                                                                          //         bf_op_west = 1'b0;
                                                                               end
                                                                           else
                                                                               begin
                                                                            //       bf_op_west = 1'b1;
                                                                               end
                                                                       end                                                                                                                                        
                                                        endcase
                                                                                   
                                                        
       
       
       
       
       
       
                                end
    
                       endcase
    
               end
 
 /*----------------------Crossbar---------------------------*/
   
   
   
 //we have 5 select lines of 3 bits each
 //0=east
 //1=west
 //2=north
 //3=south
 //4=eject
 //example=when select line have a value of 0 input will be mapped to east port 
  
  always @(* ) 
  begin
    case (east_out)                     // east_out is the select line whose value determines to which output port the packet from the east side goes
      3'd0: OE = bf_out_e;
      3'd1: OW = bf_out_e;
      3'd2: ON = bf_out_e; 
      3'd3: OS = bf_out_e;
      3'd4: Eject = bf_out_e;
      default:
      begin

      end
    endcase
    //s_e is the select line associated with the east input port 
    //the east input port packet will be assigned to that output port specified by the select line
    //when the select line is out of the 5 values ,the cross bar output is set as 0
    case (west_out)
      3'd0: OE = bf_out_w;         // west_out is the select line whose value determines to which output port the packet from the east side goes
      3'd1: OW = bf_out_w;
      3'd2: ON = bf_out_w; 
      3'd3: OS = bf_out_w;
      3'd4: Eject = bf_out_w;
      default:
      begin

      end
    endcase
    
    case (north_out)
      3'd0: OE = bf_out_n;
      3'd1: OW = bf_out_n;
      3'd2: ON = bf_out_n;
      3'd3: OS = bf_out_n;
      3'd4: Eject = bf_out_n;
      default:
      begin

      end
    endcase
    
    case (south_out)
      3'd0: OE = bf_out_s;
      3'd1: OW = bf_out_s;
      3'd2: ON = bf_out_s;
      3'd3: OS = bf_out_s;
      3'd4: Eject = bf_out_s;
      default:
      begin
 
      end
    endcase
    
    case (local_out)
      3'd0: OE = bf_out_t;
      3'd1: OW = bf_out_t;
      3'd2: ON = bf_out_t;
      3'd3: OS = bf_out_t;
      3'd4: Eject = bf_out_t;
      default:
      begin

      end
    endcase
    
  end
  


    
 
    
    
    endmodule
  