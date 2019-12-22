`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2019 04:43:21 PM
// Design Name: 
// Module Name: final_tb
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


module final_tb();
    reg clk, clrn;
    wire [31:0] pc; // program counter // and data mem
    wire [31:0] inst; // instruction in ID stage
    wire [31:0] ealu; // alu result in EXE stage
    wire [31:0] malu; // alu result in MEM stage
    wire [31:0] wdi; // data to be written into register file
    
    // signals in IF stage
    wire [31:0] pc_plus_4, ins, npc;
    // signals in ID stage
    wire [31:0] dpc_plus_4, bpc, jpc, d_a, d_b, d_imm;
    wire [4:0] d_rn; 
    wire [3:0] d_aluc;
    wire [1:0] pcsrc;
    wire wpcir, dwreg, dm2reg, dwmem, daluimm, dshift, djal;
    // signals in EXE stage
    wire [31:0] epc_plus_4, ea, eb, eimm;
    wire [4:0] ern0, ern1;
    wire [3:0] e_aluc;
    wire ewreg, em2reg, ewmem, ealuimm, eshift, ejal;
    // signals in MEM stage
    wire [31:0] m_b, m_mo; 
    wire [4:0] mrn;
    wire mwreg, mm2reg, mwmem;
    // signals in WB stage
    wire [31:0] w_mo, w_alu; 
    wire [4:0] wrn; 
    wire wwreg, wm2reg;
    
    pipelinedcpu tb(clk,clrn,pc,inst,ealu,malu,wdi);
    pipepc prog_cnt (npc,wpcir,clk,clrn,pc);
    pipeif if_stage (pcsrc,pc,bpc,d_a,jpc,npc,pc_plus_4,ins); // IF stage
    // IF/ID pipeline register
    pipeif_id if_id (pc_plus_4,ins,wpcir,clk,clrn,dpc_plus_4,inst);
    pipeid id_stage (mwreg,mrn,ern1,ewreg,em2reg,mm2reg,dpc_plus_4,inst,wrn,wdi,
    ealu,malu,m_mo,wwreg,clk,clrn,bpc,jpc,pcsrc,wpcir,
    dwreg,dm2reg,dwmem,d_aluc,daluimm,d_a,d_b,d_imm,d_rn,
    dshift,djal); // ID stage
    // ID/EXE pipeline register
    pipeid_exe id_exe (dwreg,dm2reg,dwmem,d_aluc,daluimm,d_a,d_b,d_imm,d_rn,
    dshift,djal,dpc_plus_4,clk,clrn,ewreg,em2reg,ewmem,
    e_aluc,ealuimm,ea,eb,eimm,ern0,eshift,ejal,epc_plus_4);
    
    pipeexe exe_stage (e_aluc,ealuimm,ea,eb,eimm,eshift,ern0,epc_plus_4,ejal,
    ern1,ealu); // EXE stage
    // EXE/MEM pipeline register
    pipeexe_mem exe_mem (ewreg,em2reg,ewmem,ealu,eb,ern1,clk,clrn,mwreg,
    mm2reg,mwmem,malu,m_b,mrn);
    pipemem mem_stage (mwmem,malu,m_b,clk,m_mo); // MEM stage
    // MEM/WB pipeline register
    pipemem_wb mem_wb (mwreg,mm2reg,m_mo,malu,mrn,clk,clrn,wwreg,wm2reg,
    w_mo,w_alu,wrn);
    pipewb wb_stage (w_alu,w_mo,wm2reg,wdi); // WB stage
    
    initial
    begin
        clk = 0;
        clrn = 0;
        #5 clrn = !clrn;
    end
    
    always 
       #5 clk = !clk;


endmodule
