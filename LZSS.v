// last update: Jan. 12

module LZSS(	clk, 
				reset, 
				data, 
				data_valid, 
				drop_done,
				busy, 
				codeword, 
				enc_num, 
				out_valid, 
				finish		);
							
				
input			clk;
input			reset;
input	[31:0]	data;
input			data_valid;
input			drop_done;
output			busy;
output	[10:0]	codeword;
output	[11:0]	enc_num;
output			out_valid;
output			finish;
//=========parameter declaration================================
parameter       IDLE        = 3'd0;
parameter       INPUT       = 3'd1;
parameter       GENTABLE    = 3'd2;
parameter       INPUTDONE   = 3'd3;
parameter       OUTPUTDONE  = 3'd4;
integer         i,j;
//=========wire & reg declaration================================
reg             drop_done_r;
reg             busy,busy_w;
reg [10:0]      codeword,codeword_w;
reg [11:0]	    enc_num,enc_num_w;
reg             out_valid,out_valid_w;
reg             finish,finish_w;

reg [2:0]       state_r,state_w;
reg [3:0]       localcount_r,localcount_w;
reg [8:0]       globalcount_r,globalcount_w;
reg [7:0]       inBuffer_r[0:8],inBuffer_w[0:8];
reg [7:0]       dictionary_w[0:255],dictionary_r[0:255];
reg             table_r[0:3][0:255],table_w[0:3][0:255];
reg             tmp_transtable_r[0:3][0:15],tmp_transtable_w[0:3][0:15];
reg             tmp_transtable2_r[0:3][0:255],tmp_transtable2_w[0:3][0:255];
reg             transtable_r[0:3][0:255],transtable_w[0:3][0:255];
reg [8:0]       tableIdx_r[0:3];
reg [3:0]       tableIdx1_r[0:3];
reg [3:0]       tableIdx2_r[0:3];
reg [3:0]       tableIdx3_r[0:3];
reg [3:0]       tableIdx4_r[0:3];
reg [3:0]       tableIdx5_r[0:3];
reg [3:0]       tableIdx6_r[0:3];
reg [3:0]       tableIdx7_r[0:3];
reg [3:0]       tableIdx8_r[0:3];
reg [3:0]       tableIdx9_r[0:3];
reg [3:0]       tableIdx10_r[0:3];
reg [3:0]       tableIdx11_r[0:3];
reg [3:0]       tableIdx12_r[0:3];
reg [3:0]       tableIdx13_r[0:3];
reg [3:0]       tableIdx14_r[0:3];
reg [3:0]       tableIdx15_r[0:3];
reg [3:0]       tableIdx16_r[0:3];
reg [3:0]       tableIdx17_r[0:3];
reg [3:0]       tableIdx18_r[0:3];
reg [3:0]       tableIdx19_r[0:3];
reg [3:0]       tableIdx20_r[0:3];
reg [3:0]       tableIdx21_r[0:3];
reg [3:0]       tableIdx22_r[0:3];
reg [3:0]       tableIdx23_r[0:3];
reg [3:0]       tableIdx24_r[0:3];
reg [3:0]       tableIdx25_r[0:3];
reg [3:0]       tableIdx26_r[0:3];
reg [3:0]       tableIdx27_r[0:3];
reg [3:0]       tableIdx28_r[0:3];
reg [3:0]       tableIdx29_r[0:3];
reg [3:0]       tableIdx30_r[0:3];
reg [3:0]       tableIdx31_r[0:3];
reg [3:0]       tableIdx32_r[0:3];
reg [6:0]       temp9bit_1_r[0:3], temp9bit_2_r[0:3],temp9bit_3_r[0:3],temp9bit_4_r[0:3];

reg [8:0]       tableIdx_w[0:3];
reg [3:0]       tableIdx1_w[0:3];
reg [3:0]       tableIdx2_w[0:3];
reg [3:0]       tableIdx3_w[0:3];
reg [3:0]       tableIdx4_w[0:3];
reg [3:0]       tableIdx5_w[0:3];
reg [3:0]       tableIdx6_w[0:3];
reg [3:0]       tableIdx7_w[0:3];
reg [3:0]       tableIdx8_w[0:3];
reg [3:0]       tableIdx9_w[0:3];
reg [3:0]       tableIdx10_w[0:3];
reg [3:0]       tableIdx11_w[0:3];
reg [3:0]       tableIdx12_w[0:3];
reg [3:0]       tableIdx13_w[0:3];
reg [3:0]       tableIdx14_w[0:3];
reg [3:0]       tableIdx15_w[0:3];
reg [3:0]       tableIdx16_w[0:3];
reg [3:0]       tableIdx17_w[0:3];
reg [3:0]       tableIdx18_w[0:3];
reg [3:0]       tableIdx19_w[0:3];
reg [3:0]       tableIdx20_w[0:3];
reg [3:0]       tableIdx21_w[0:3];
reg [3:0]       tableIdx22_w[0:3];
reg [3:0]       tableIdx23_w[0:3];
reg [3:0]       tableIdx24_w[0:3];
reg [3:0]       tableIdx25_w[0:3];
reg [3:0]       tableIdx26_w[0:3];
reg [3:0]       tableIdx27_w[0:3];
reg [3:0]       tableIdx28_w[0:3];
reg [3:0]       tableIdx29_w[0:3];
reg [3:0]       tableIdx30_w[0:3];
reg [3:0]       tableIdx31_w[0:3];
reg [3:0]       tableIdx32_w[0:3];
reg [6:0]       temp9bit_1_w[0:3], temp9bit_2_w[0:3],temp9bit_3_w[0:3],temp9bit_4_w[0:3];
reg [2:0]       pause1_r,pause1_w;
reg [2:0]       pause2_r,pause2_w;
reg [10:0]      outputreg_r[0:7],outputreg_w[0:7];
reg [10:0]      newCode_r,newCode_w;
//========================combinational==========================
always@(*) begin
    enc_num_w = (globalcount_r>10'd6)? globalcount_r-10'd6 : 0 ;

    if(pause2_r!=0) begin
        codeword_w = 0;
        out_valid_w = 0;
    end   
    else begin
        out_valid_w = (globalcount_r<=10'd6)? 0:1;
        codeword_w = (pause1_r==5'd0)?outputreg_r[6] : newCode_r;
    end
end

always@(*)begin
    state_w         = state_r;
    localcount_w    = localcount_r;
    globalcount_w   = globalcount_r;
    pause1_w        = pause1_r;
    pause2_w        = pause2_r;
    newCode_w       = newCode_r; 
    busy_w          = 1;
    finish_w        = 0;
    for(i=0;i<=3;i=i+1) begin
        temp9bit_1_w[i]    = temp9bit_1_r[i];  
        temp9bit_2_w[i]    = temp9bit_2_r[i];
        temp9bit_3_w[i]    = temp9bit_3_r[i];
        temp9bit_4_w[i]    = temp9bit_4_r[i];
    end


    for(i=0;i<=7;i=i+1)
        outputreg_w[i] = outputreg_r[i];
    for(i=0;i<256;i=i+1)
        dictionary_w[i] = dictionary_r[i];
    for(i=0;i<9;i=i+1)
        inBuffer_w[i] = inBuffer_r[i];
    for(j=0;j<4;j=j+1) begin
        for(i=0;i<16;i=i+1) begin
            tmp_transtable_w[j][i] = tmp_transtable_r[j][i];
        end
    end

    for(j=0;j<4;j=j+1) begin
        for(i=0;i<256;i=i+1) begin
            table_w[j][i] = table_r[j][i];
            transtable_w[j][i] = transtable_r[j][i];
            tmp_transtable2_w[j][i] = tmp_transtable_r[j][i];
        end
    end
    for(j=0;j<4;j=j+1) begin
        tableIdx_w[j] = tableIdx_r[j] ;
        tableIdx1_w[j] = tableIdx1_r[j] ;
        tableIdx2_w[j] = tableIdx2_r[j] ;
        tableIdx3_w[j] = tableIdx3_r[j] ;
        tableIdx4_w[j] = tableIdx4_r[j] ;
        tableIdx5_w[j] = tableIdx5_r[j] ;
        tableIdx6_w[j] = tableIdx6_r[j] ;
        tableIdx7_w[j] = tableIdx7_r[j] ;
        tableIdx8_w[j] = tableIdx8_r[j] ;
        tableIdx9_w[j] = tableIdx9_r[j] ;
        tableIdx10_w[j] = tableIdx10_r[j] ;
        tableIdx11_w[j] = tableIdx11_r[j] ;
        tableIdx12_w[j] = tableIdx12_r[j] ;
        tableIdx13_w[j] = tableIdx13_r[j] ;
        tableIdx14_w[j] = tableIdx14_r[j] ;
        tableIdx15_w[j] = tableIdx15_r[j] ;
        tableIdx16_w[j] = tableIdx16_r[j] ;
        tableIdx17_w[j] = tableIdx17_r[j] ;
        tableIdx18_w[j] = tableIdx18_r[j] ;
        tableIdx19_w[j] = tableIdx19_r[j] ;
        tableIdx20_w[j] = tableIdx20_r[j] ;
        tableIdx21_w[j] = tableIdx21_r[j] ;
        tableIdx22_w[j] = tableIdx22_r[j] ;
        tableIdx23_w[j] = tableIdx23_r[j] ;
        tableIdx24_w[j] = tableIdx24_r[j] ;
        tableIdx25_w[j] = tableIdx25_r[j] ;
        tableIdx26_w[j] = tableIdx26_r[j] ;
        tableIdx27_w[j] = tableIdx27_r[j] ;
        tableIdx28_w[j] = tableIdx28_r[j] ;
        tableIdx29_w[j] = tableIdx29_r[j] ;
        tableIdx30_w[j] = tableIdx30_r[j] ;
        tableIdx31_w[j] = tableIdx31_r[j] ;
        tableIdx32_w[j] = tableIdx32_r[j] ;
    end

    case(state_r)
        IDLE: begin
            state_w = INPUT;
            busy_w = 0;
        end
        INPUT: begin
            busy_w = 0;
            localcount_w = localcount_r + 4;
            inBuffer_w[localcount_r  ] = data[31:24];
            inBuffer_w[localcount_r+1] = data[23:16];
            inBuffer_w[localcount_r+2] = data[15:8];
            inBuffer_w[localcount_r+3] = data[7:0];
            if(localcount_r != 0) begin
                state_w = GENTABLE;
                busy_w = 1;
            end
        end
        GENTABLE: begin
// GENERATE DICTIONARY
            dictionary_w[0] = inBuffer_r[0];
            for( i = 1 ; i < 256 ; i = i+1)
                dictionary_w[i] = dictionary_r[i-1];


// TABLE
            for(i=0;i<252;i=i+1)
                table_w[0][i] = ( inBuffer_r[0]==dictionary_r[i+4] &&
                                  inBuffer_r[1]==dictionary_r[i+3] &&
                                  inBuffer_r[2]==dictionary_r[i+2] &&
                                  inBuffer_r[3]==dictionary_r[i+1] &&
                                  inBuffer_r[4]==dictionary_r[i]);
            for(i=252;i<256;i=i+1)
                table_w[0][i] = 0;
            for(i=0;i<253;i=i+1)
                table_w[1][i] = ( inBuffer_r[0]==dictionary_r[i+3] &&
                                  inBuffer_r[1]==dictionary_r[i+2] &&
                                  inBuffer_r[2]==dictionary_r[i+1] &&
                                  inBuffer_r[3]==dictionary_r[i]);
            for(i=253;i<256;i=i+1)
                table_w[1][i] = 0;
            for(i=0;i<254;i=i+1)
                table_w[2][i] = ( inBuffer_r[0]==dictionary_r[i+2] && 
                                  inBuffer_r[1]==dictionary_r[i+1] &&
                                  inBuffer_r[2]==dictionary_r[i] );
            for(i=254;i<256;i=i+1)
                table_w[2][i] = 0;
            for(i=0;i<256;i=i+1)
                table_w[3][i] = ( inBuffer_r[0]==dictionary_r[i+1] && 
                                  inBuffer_r[1]==dictionary_r[i]);
            for(i=255;i<256;i=i+1)
                table_w[3][i] = 0;


// TMPTRANSTABLE
 

            for(j=0;j<4;j=j+1) begin
tmp_transtable_w[j][0] = table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7] || table_r[j][8] || table_r[j][9] || table_r[j][10] || table_r[j][11] || table_r[j][12] || table_r[j][13] || table_r[j][14] || table_r[j][15] ;
tmp_transtable_w[j][1] = table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23] || table_r[j][24] || table_r[j][25] || table_r[j][26] || table_r[j][27] || table_r[j][28] || table_r[j][29] || table_r[j][30] || table_r[j][31] ;
tmp_transtable_w[j][2] = table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39] || table_r[j][40] || table_r[j][41] || table_r[j][42] || table_r[j][43] || table_r[j][44] || table_r[j][45] || table_r[j][46] || table_r[j][47];
tmp_transtable_w[j][3] = table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55] || table_r[j][56] || table_r[j][57] || table_r[j][58] || table_r[j][59] || table_r[j][60] || table_r[j][61] || table_r[j][62] || table_r[j][63];
tmp_transtable_w[j][4] = table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71] || table_r[j][72] || table_r[j][73] || table_r[j][74] || table_r[j][75] || table_r[j][76] || table_r[j][77] || table_r[j][78] || table_r[j][79];
tmp_transtable_w[j][5] = table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87] || table_r[j][88] || table_r[j][89] || table_r[j][90] || table_r[j][91] || table_r[j][92] || table_r[j][93] || table_r[j][94] || table_r[j][95];
tmp_transtable_w[j][6] = table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103] || table_r[j][104] || table_r[j][105] || table_r[j][106] || table_r[j][107] || table_r[j][108] || table_r[j][109] || table_r[j][110] || table_r[j][111];
tmp_transtable_w[j][7] = table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119] || table_r[j][120] || table_r[j][121] || table_r[j][122] || table_r[j][123] || table_r[j][124] || table_r[j][125] || table_r[j][126] || table_r[j][127];
tmp_transtable_w[j][8] = table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135] || table_r[j][136] || table_r[j][137] || table_r[j][138] || table_r[j][139] || table_r[j][140] || table_r[j][141] || table_r[j][142] || table_r[j][143];
tmp_transtable_w[j][9] = table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151] || table_r[j][152] || table_r[j][153] || table_r[j][154] || table_r[j][155] || table_r[j][156] || table_r[j][157] || table_r[j][158] || table_r[j][159];
tmp_transtable_w[j][10] = table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167] || table_r[j][168] || table_r[j][169] || table_r[j][170] || table_r[j][171] || table_r[j][172] || table_r[j][173] || table_r[j][174] || table_r[j][175];
tmp_transtable_w[j][11] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183] || table_r[j][184] || table_r[j][185] || table_r[j][186] || table_r[j][187] || table_r[j][188] || table_r[j][189] || table_r[j][190] || table_r[j][191];
tmp_transtable_w[j][12] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199] || table_r[j][200] || table_r[j][201] || table_r[j][202] || table_r[j][203] || table_r[j][204] || table_r[j][205] || table_r[j][206] || table_r[j][207];
tmp_transtable_w[j][13] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215] || table_r[j][216] || table_r[j][217] || table_r[j][218] || table_r[j][219] || table_r[j][220] || table_r[j][221] || table_r[j][222] || table_r[j][223] ;
tmp_transtable_w[j][14] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231] || table_r[j][232] || table_r[j][233] || table_r[j][234] || table_r[j][235] || table_r[j][236] || table_r[j][237] || table_r[j][238] || table_r[j][239];
tmp_transtable_w[j][15] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247] || table_r[j][248] || table_r[j][249] || table_r[j][250] || table_r[j][251] || table_r[j][252] || table_r[j][253] || table_r[j][254] || table_r[j][255] ;

end
// TRANSTABLE2
            for(j=0;j<4;j=j+1) begin
tmp_transtable2_w[j][0] =  table_r[j][0];
tmp_transtable2_w[j][1] =  table_r[j][0] || table_r[j][1];
tmp_transtable2_w[j][2] =  table_r[j][0] || table_r[j][1] || table_r[j][2];
tmp_transtable2_w[j][3] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3];
tmp_transtable2_w[j][4] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4];
tmp_transtable2_w[j][5] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5];
tmp_transtable2_w[j][6] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6];
tmp_transtable2_w[j][7] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7];
tmp_transtable2_w[j][8] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7] || table_r[j][8];
tmp_transtable2_w[j][9] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7] || table_r[j][8] || table_r[j][9];
tmp_transtable2_w[j][10] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7] || table_r[j][8] || table_r[j][9] || table_r[j][10];
tmp_transtable2_w[j][11] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7] || table_r[j][8] || table_r[j][9] || table_r[j][10] || table_r[j][11];
tmp_transtable2_w[j][12] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7] || table_r[j][8] || table_r[j][9] || table_r[j][10] || table_r[j][11] || table_r[j][12];
tmp_transtable2_w[j][13] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7] || table_r[j][8] || table_r[j][9] || table_r[j][10] || table_r[j][11] || table_r[j][12] || table_r[j][13];
tmp_transtable2_w[j][14] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7] || table_r[j][8] || table_r[j][9] || table_r[j][10] || table_r[j][11] || table_r[j][12] || table_r[j][13] || table_r[j][14];
tmp_transtable2_w[j][15] =  table_r[j][0] || table_r[j][1] || table_r[j][2] || table_r[j][3] || table_r[j][4] || table_r[j][5] || table_r[j][6] || table_r[j][7] || table_r[j][8] || table_r[j][9] || table_r[j][10] || table_r[j][11] || table_r[j][12] || table_r[j][13] || table_r[j][14] || table_r[j][15];
tmp_transtable2_w[j][16] =  table_r[j][16];
tmp_transtable2_w[j][17] =  table_r[j][16] || table_r[j][17];
tmp_transtable2_w[j][18] =  table_r[j][16] || table_r[j][17] || table_r[j][18];
tmp_transtable2_w[j][19] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19];
tmp_transtable2_w[j][20] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20];
tmp_transtable2_w[j][21] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21];
tmp_transtable2_w[j][22] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22];
tmp_transtable2_w[j][23] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23];
tmp_transtable2_w[j][24] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23] || table_r[j][24];
tmp_transtable2_w[j][25] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23] || table_r[j][24] || table_r[j][25];
tmp_transtable2_w[j][26] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23] || table_r[j][24] || table_r[j][25] || table_r[j][26];
tmp_transtable2_w[j][27] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23] || table_r[j][24] || table_r[j][25] || table_r[j][26] || table_r[j][27];
tmp_transtable2_w[j][28] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23] || table_r[j][24] || table_r[j][25] || table_r[j][26] || table_r[j][27] || table_r[j][28];
tmp_transtable2_w[j][29] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23] || table_r[j][24] || table_r[j][25] || table_r[j][26] || table_r[j][27] || table_r[j][28] || table_r[j][29];
tmp_transtable2_w[j][30] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23] || table_r[j][24] || table_r[j][25] || table_r[j][26] || table_r[j][27] || table_r[j][28] || table_r[j][29] || table_r[j][30];
tmp_transtable2_w[j][31] =  table_r[j][16] || table_r[j][17] || table_r[j][18] || table_r[j][19] || table_r[j][20] || table_r[j][21] || table_r[j][22] || table_r[j][23] || table_r[j][24] || table_r[j][25] || table_r[j][26] || table_r[j][27] || table_r[j][28] || table_r[j][29] || table_r[j][30] || table_r[j][31];
tmp_transtable2_w[j][32] =  table_r[j][32];
tmp_transtable2_w[j][33] =  table_r[j][32] || table_r[j][33];
tmp_transtable2_w[j][34] =  table_r[j][32] || table_r[j][33] || table_r[j][34];
tmp_transtable2_w[j][35] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35];
tmp_transtable2_w[j][36] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36];
tmp_transtable2_w[j][37] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37];
tmp_transtable2_w[j][38] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38];
tmp_transtable2_w[j][39] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39];
tmp_transtable2_w[j][40] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39] || table_r[j][40];
tmp_transtable2_w[j][41] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39] || table_r[j][40] || table_r[j][41];
tmp_transtable2_w[j][42] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39] || table_r[j][40] || table_r[j][41] || table_r[j][42];
tmp_transtable2_w[j][43] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39] || table_r[j][40] || table_r[j][41] || table_r[j][42] || table_r[j][43];
tmp_transtable2_w[j][44] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39] || table_r[j][40] || table_r[j][41] || table_r[j][42] || table_r[j][43] || table_r[j][44];
tmp_transtable2_w[j][45] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39] || table_r[j][40] || table_r[j][41] || table_r[j][42] || table_r[j][43] || table_r[j][44] || table_r[j][45];
tmp_transtable2_w[j][46] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39] || table_r[j][40] || table_r[j][41] || table_r[j][42] || table_r[j][43] || table_r[j][44] || table_r[j][45] || table_r[j][46];
tmp_transtable2_w[j][47] =  table_r[j][32] || table_r[j][33] || table_r[j][34] || table_r[j][35] || table_r[j][36] || table_r[j][37] || table_r[j][38] || table_r[j][39] || table_r[j][40] || table_r[j][41] || table_r[j][42] || table_r[j][43] || table_r[j][44] || table_r[j][45] || table_r[j][46] || table_r[j][47];
tmp_transtable2_w[j][48] =  table_r[j][48];
tmp_transtable2_w[j][49] =  table_r[j][48] || table_r[j][49];
tmp_transtable2_w[j][50] =  table_r[j][48] || table_r[j][49] || table_r[j][50];
tmp_transtable2_w[j][51] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51];
tmp_transtable2_w[j][52] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52];
tmp_transtable2_w[j][53] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53];
tmp_transtable2_w[j][54] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54];
tmp_transtable2_w[j][55] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55];
tmp_transtable2_w[j][56] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55] || table_r[j][56];
tmp_transtable2_w[j][57] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55] || table_r[j][56] || table_r[j][57];
tmp_transtable2_w[j][58] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55] || table_r[j][56] || table_r[j][57] || table_r[j][58];
tmp_transtable2_w[j][59] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55] || table_r[j][56] || table_r[j][57] || table_r[j][58] || table_r[j][59];
tmp_transtable2_w[j][60] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55] || table_r[j][56] || table_r[j][57] || table_r[j][58] || table_r[j][59] || table_r[j][60];
tmp_transtable2_w[j][61] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55] || table_r[j][56] || table_r[j][57] || table_r[j][58] || table_r[j][59] || table_r[j][60] || table_r[j][61];
tmp_transtable2_w[j][62] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55] || table_r[j][56] || table_r[j][57] || table_r[j][58] || table_r[j][59] || table_r[j][60] || table_r[j][61] || table_r[j][62];
tmp_transtable2_w[j][63] =  table_r[j][48] || table_r[j][49] || table_r[j][50] || table_r[j][51] || table_r[j][52] || table_r[j][53] || table_r[j][54] || table_r[j][55] || table_r[j][56] || table_r[j][57] || table_r[j][58] || table_r[j][59] || table_r[j][60] || table_r[j][61] || table_r[j][62] || table_r[j][63];
tmp_transtable2_w[j][64] =  table_r[j][64];
tmp_transtable2_w[j][65] =  table_r[j][64] || table_r[j][65];
tmp_transtable2_w[j][66] =  table_r[j][64] || table_r[j][65] || table_r[j][66];
tmp_transtable2_w[j][67] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67];
tmp_transtable2_w[j][68] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68];
tmp_transtable2_w[j][69] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69];
tmp_transtable2_w[j][70] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70];
tmp_transtable2_w[j][71] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71];
tmp_transtable2_w[j][72] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71] || table_r[j][72];
tmp_transtable2_w[j][73] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71] || table_r[j][72] || table_r[j][73];
tmp_transtable2_w[j][74] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71] || table_r[j][72] || table_r[j][73] || table_r[j][74];
tmp_transtable2_w[j][75] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71] || table_r[j][72] || table_r[j][73] || table_r[j][74] || table_r[j][75];
tmp_transtable2_w[j][76] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71] || table_r[j][72] || table_r[j][73] || table_r[j][74] || table_r[j][75] || table_r[j][76];
tmp_transtable2_w[j][77] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71] || table_r[j][72] || table_r[j][73] || table_r[j][74] || table_r[j][75] || table_r[j][76] || table_r[j][77];
tmp_transtable2_w[j][78] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71] || table_r[j][72] || table_r[j][73] || table_r[j][74] || table_r[j][75] || table_r[j][76] || table_r[j][77] || table_r[j][78];
tmp_transtable2_w[j][79] =  table_r[j][64] || table_r[j][65] || table_r[j][66] || table_r[j][67] || table_r[j][68] || table_r[j][69] || table_r[j][70] || table_r[j][71] || table_r[j][72] || table_r[j][73] || table_r[j][74] || table_r[j][75] || table_r[j][76] || table_r[j][77] || table_r[j][78] || table_r[j][79];
tmp_transtable2_w[j][80] =  table_r[j][80];
tmp_transtable2_w[j][81] =  table_r[j][80] || table_r[j][81];
tmp_transtable2_w[j][82] =  table_r[j][80] || table_r[j][81] || table_r[j][82];
tmp_transtable2_w[j][83] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83];
tmp_transtable2_w[j][84] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84];
tmp_transtable2_w[j][85] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85];
tmp_transtable2_w[j][86] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86];
tmp_transtable2_w[j][87] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87];
tmp_transtable2_w[j][88] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87] || table_r[j][88];
tmp_transtable2_w[j][89] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87] || table_r[j][88] || table_r[j][89];
tmp_transtable2_w[j][90] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87] || table_r[j][88] || table_r[j][89] || table_r[j][90];
tmp_transtable2_w[j][91] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87] || table_r[j][88] || table_r[j][89] || table_r[j][90] || table_r[j][91];
tmp_transtable2_w[j][92] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87] || table_r[j][88] || table_r[j][89] || table_r[j][90] || table_r[j][91] || table_r[j][92];
tmp_transtable2_w[j][93] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87] || table_r[j][88] || table_r[j][89] || table_r[j][90] || table_r[j][91] || table_r[j][92] || table_r[j][93];
tmp_transtable2_w[j][94] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87] || table_r[j][88] || table_r[j][89] || table_r[j][90] || table_r[j][91] || table_r[j][92] || table_r[j][93] || table_r[j][94];
tmp_transtable2_w[j][95] =  table_r[j][80] || table_r[j][81] || table_r[j][82] || table_r[j][83] || table_r[j][84] || table_r[j][85] || table_r[j][86] || table_r[j][87] || table_r[j][88] || table_r[j][89] || table_r[j][90] || table_r[j][91] || table_r[j][92] || table_r[j][93] || table_r[j][94] || table_r[j][95];
tmp_transtable2_w[j][96] =  table_r[j][96];
tmp_transtable2_w[j][97] =  table_r[j][96] || table_r[j][97];
tmp_transtable2_w[j][98] =  table_r[j][96] || table_r[j][97] || table_r[j][98];
tmp_transtable2_w[j][99] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99];
tmp_transtable2_w[j][100] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100];
tmp_transtable2_w[j][101] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101];
tmp_transtable2_w[j][102] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102];
tmp_transtable2_w[j][103] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103];
tmp_transtable2_w[j][104] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103] || table_r[j][104];
tmp_transtable2_w[j][105] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103] || table_r[j][104] || table_r[j][105];
tmp_transtable2_w[j][106] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103] || table_r[j][104] || table_r[j][105] || table_r[j][106];
tmp_transtable2_w[j][107] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103] || table_r[j][104] || table_r[j][105] || table_r[j][106] || table_r[j][107];
tmp_transtable2_w[j][108] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103] || table_r[j][104] || table_r[j][105] || table_r[j][106] || table_r[j][107] || table_r[j][108];
tmp_transtable2_w[j][109] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103] || table_r[j][104] || table_r[j][105] || table_r[j][106] || table_r[j][107] || table_r[j][108] || table_r[j][109];
tmp_transtable2_w[j][110] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103] || table_r[j][104] || table_r[j][105] || table_r[j][106] || table_r[j][107] || table_r[j][108] || table_r[j][109] || table_r[j][110];
tmp_transtable2_w[j][111] =  table_r[j][96] || table_r[j][97] || table_r[j][98] || table_r[j][99] || table_r[j][100] || table_r[j][101] || table_r[j][102] || table_r[j][103] || table_r[j][104] || table_r[j][105] || table_r[j][106] || table_r[j][107] || table_r[j][108] || table_r[j][109] || table_r[j][110] || table_r[j][111];
tmp_transtable2_w[j][112] =  table_r[j][112];
tmp_transtable2_w[j][113] =  table_r[j][112] || table_r[j][113];
tmp_transtable2_w[j][114] =  table_r[j][112] || table_r[j][113] || table_r[j][114];
tmp_transtable2_w[j][115] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115];
tmp_transtable2_w[j][116] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116];
tmp_transtable2_w[j][117] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117];
tmp_transtable2_w[j][118] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118];
tmp_transtable2_w[j][119] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119];
tmp_transtable2_w[j][120] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119] || table_r[j][120];
tmp_transtable2_w[j][121] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119] || table_r[j][120] || table_r[j][121];
tmp_transtable2_w[j][122] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119] || table_r[j][120] || table_r[j][121] || table_r[j][122];
tmp_transtable2_w[j][123] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119] || table_r[j][120] || table_r[j][121] || table_r[j][122] || table_r[j][123];
tmp_transtable2_w[j][124] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119] || table_r[j][120] || table_r[j][121] || table_r[j][122] || table_r[j][123] || table_r[j][124];
tmp_transtable2_w[j][125] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119] || table_r[j][120] || table_r[j][121] || table_r[j][122] || table_r[j][123] || table_r[j][124] || table_r[j][125];
tmp_transtable2_w[j][126] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119] || table_r[j][120] || table_r[j][121] || table_r[j][122] || table_r[j][123] || table_r[j][124] || table_r[j][125] || table_r[j][126];
tmp_transtable2_w[j][127] =  table_r[j][112] || table_r[j][113] || table_r[j][114] || table_r[j][115] || table_r[j][116] || table_r[j][117] || table_r[j][118] || table_r[j][119] || table_r[j][120] || table_r[j][121] || table_r[j][122] || table_r[j][123] || table_r[j][124] || table_r[j][125] || table_r[j][126] || table_r[j][127];
tmp_transtable2_w[j][128] =  table_r[j][128];
tmp_transtable2_w[j][129] =  table_r[j][128] || table_r[j][129];
tmp_transtable2_w[j][130] =  table_r[j][128] || table_r[j][129] || table_r[j][130];
tmp_transtable2_w[j][131] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131];
tmp_transtable2_w[j][132] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132];
tmp_transtable2_w[j][133] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133];
tmp_transtable2_w[j][134] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134];
tmp_transtable2_w[j][135] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135];
tmp_transtable2_w[j][136] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135] || table_r[j][136];
tmp_transtable2_w[j][137] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135] || table_r[j][136] || table_r[j][137];
tmp_transtable2_w[j][138] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135] || table_r[j][136] || table_r[j][137] || table_r[j][138];
tmp_transtable2_w[j][139] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135] || table_r[j][136] || table_r[j][137] || table_r[j][138] || table_r[j][139];
tmp_transtable2_w[j][140] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135] || table_r[j][136] || table_r[j][137] || table_r[j][138] || table_r[j][139] || table_r[j][140];
tmp_transtable2_w[j][141] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135] || table_r[j][136] || table_r[j][137] || table_r[j][138] || table_r[j][139] || table_r[j][140] || table_r[j][141];
tmp_transtable2_w[j][142] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135] || table_r[j][136] || table_r[j][137] || table_r[j][138] || table_r[j][139] || table_r[j][140] || table_r[j][141] || table_r[j][142];
tmp_transtable2_w[j][143] =  table_r[j][128] || table_r[j][129] || table_r[j][130] || table_r[j][131] || table_r[j][132] || table_r[j][133] || table_r[j][134] || table_r[j][135] || table_r[j][136] || table_r[j][137] || table_r[j][138] || table_r[j][139] || table_r[j][140] || table_r[j][141] || table_r[j][142] || table_r[j][143];
tmp_transtable2_w[j][144] =  table_r[j][144];
tmp_transtable2_w[j][145] =  table_r[j][144] || table_r[j][145];
tmp_transtable2_w[j][146] =  table_r[j][144] || table_r[j][145] || table_r[j][146];
tmp_transtable2_w[j][147] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147];
tmp_transtable2_w[j][148] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148];
tmp_transtable2_w[j][149] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149];
tmp_transtable2_w[j][150] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150];
tmp_transtable2_w[j][151] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151];
tmp_transtable2_w[j][152] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151] || table_r[j][152];
tmp_transtable2_w[j][153] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151] || table_r[j][152] || table_r[j][153];
tmp_transtable2_w[j][154] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151] || table_r[j][152] || table_r[j][153] || table_r[j][154];
tmp_transtable2_w[j][155] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151] || table_r[j][152] || table_r[j][153] || table_r[j][154] || table_r[j][155];
tmp_transtable2_w[j][156] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151] || table_r[j][152] || table_r[j][153] || table_r[j][154] || table_r[j][155] || table_r[j][156];
tmp_transtable2_w[j][157] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151] || table_r[j][152] || table_r[j][153] || table_r[j][154] || table_r[j][155] || table_r[j][156] || table_r[j][157];
tmp_transtable2_w[j][158] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151] || table_r[j][152] || table_r[j][153] || table_r[j][154] || table_r[j][155] || table_r[j][156] || table_r[j][157] || table_r[j][158];
tmp_transtable2_w[j][159] =  table_r[j][144] || table_r[j][145] || table_r[j][146] || table_r[j][147] || table_r[j][148] || table_r[j][149] || table_r[j][150] || table_r[j][151] || table_r[j][152] || table_r[j][153] || table_r[j][154] || table_r[j][155] || table_r[j][156] || table_r[j][157] || table_r[j][158] || table_r[j][159];
tmp_transtable2_w[j][160] =  table_r[j][160];
tmp_transtable2_w[j][161] =  table_r[j][160] || table_r[j][161];
tmp_transtable2_w[j][162] =  table_r[j][160] || table_r[j][161] || table_r[j][162];
tmp_transtable2_w[j][163] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163];
tmp_transtable2_w[j][164] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164];
tmp_transtable2_w[j][165] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165];
tmp_transtable2_w[j][166] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166];
tmp_transtable2_w[j][167] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167];
tmp_transtable2_w[j][168] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167] || table_r[j][168];
tmp_transtable2_w[j][169] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167] || table_r[j][168] || table_r[j][169];
tmp_transtable2_w[j][170] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167] || table_r[j][168] || table_r[j][169] || table_r[j][170];
tmp_transtable2_w[j][171] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167] || table_r[j][168] || table_r[j][169] || table_r[j][170] || table_r[j][171];
tmp_transtable2_w[j][172] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167] || table_r[j][168] || table_r[j][169] || table_r[j][170] || table_r[j][171] || table_r[j][172];
tmp_transtable2_w[j][173] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167] || table_r[j][168] || table_r[j][169] || table_r[j][170] || table_r[j][171] || table_r[j][172] || table_r[j][173];
tmp_transtable2_w[j][174] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167] || table_r[j][168] || table_r[j][169] || table_r[j][170] || table_r[j][171] || table_r[j][172] || table_r[j][173] || table_r[j][174];
tmp_transtable2_w[j][175] =  table_r[j][160] || table_r[j][161] || table_r[j][162] || table_r[j][163] || table_r[j][164] || table_r[j][165] || table_r[j][166] || table_r[j][167] || table_r[j][168] || table_r[j][169] || table_r[j][170] || table_r[j][171] || table_r[j][172] || table_r[j][173] || table_r[j][174] || table_r[j][175];
tmp_transtable2_w[j][176] = table_r[j][176];
tmp_transtable2_w[j][177] = table_r[j][176] || table_r[j][177];
tmp_transtable2_w[j][178] = table_r[j][176] || table_r[j][177] || table_r[j][178];
tmp_transtable2_w[j][179] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179];
tmp_transtable2_w[j][180] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180];
tmp_transtable2_w[j][181] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181];
tmp_transtable2_w[j][182] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182];
tmp_transtable2_w[j][183] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183];
tmp_transtable2_w[j][184] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183] || table_r[j][184];
tmp_transtable2_w[j][185] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183] || table_r[j][184] || table_r[j][185];
tmp_transtable2_w[j][186] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183] || table_r[j][184] || table_r[j][185] || table_r[j][186];
tmp_transtable2_w[j][187] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183] || table_r[j][184] || table_r[j][185] || table_r[j][186] || table_r[j][187];
tmp_transtable2_w[j][188] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183] || table_r[j][184] || table_r[j][185] || table_r[j][186] || table_r[j][187] || table_r[j][188];
tmp_transtable2_w[j][189] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183] || table_r[j][184] || table_r[j][185] || table_r[j][186] || table_r[j][187] || table_r[j][188] || table_r[j][189];
tmp_transtable2_w[j][190] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183] || table_r[j][184] || table_r[j][185] || table_r[j][186] || table_r[j][187] || table_r[j][188] || table_r[j][189] || table_r[j][190];
tmp_transtable2_w[j][191] = table_r[j][176] || table_r[j][177] || table_r[j][178] || table_r[j][179] || table_r[j][180] || table_r[j][181] || table_r[j][182] || table_r[j][183] || table_r[j][184] || table_r[j][185] || table_r[j][186] || table_r[j][187] || table_r[j][188] || table_r[j][189] || table_r[j][190] || table_r[j][191];
tmp_transtable2_w[j][192] = table_r[j][192];
tmp_transtable2_w[j][193] = table_r[j][192] || table_r[j][193];
tmp_transtable2_w[j][194] = table_r[j][192] || table_r[j][193] || table_r[j][194];
tmp_transtable2_w[j][195] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195];
tmp_transtable2_w[j][196] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196];
tmp_transtable2_w[j][197] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197];
tmp_transtable2_w[j][198] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198];
tmp_transtable2_w[j][199] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199];
tmp_transtable2_w[j][200] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199] || table_r[j][200];
tmp_transtable2_w[j][201] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199] || table_r[j][200] || table_r[j][201];
tmp_transtable2_w[j][202] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199] || table_r[j][200] || table_r[j][201] || table_r[j][202];
tmp_transtable2_w[j][203] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199] || table_r[j][200] || table_r[j][201] || table_r[j][202] || table_r[j][203];
tmp_transtable2_w[j][204] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199] || table_r[j][200] || table_r[j][201] || table_r[j][202] || table_r[j][203] || table_r[j][204];
tmp_transtable2_w[j][205] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199] || table_r[j][200] || table_r[j][201] || table_r[j][202] || table_r[j][203] || table_r[j][204] || table_r[j][205];
tmp_transtable2_w[j][206] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199] || table_r[j][200] || table_r[j][201] || table_r[j][202] || table_r[j][203] || table_r[j][204] || table_r[j][205] || table_r[j][206];
tmp_transtable2_w[j][207] = table_r[j][192] || table_r[j][193] || table_r[j][194] || table_r[j][195] || table_r[j][196] || table_r[j][197] || table_r[j][198] || table_r[j][199] || table_r[j][200] || table_r[j][201] || table_r[j][202] || table_r[j][203] || table_r[j][204] || table_r[j][205] || table_r[j][206] || table_r[j][207];
tmp_transtable2_w[j][208] = table_r[j][208];
tmp_transtable2_w[j][209] = table_r[j][208] || table_r[j][209];
tmp_transtable2_w[j][210] = table_r[j][208] || table_r[j][209] || table_r[j][210];
tmp_transtable2_w[j][211] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211];
tmp_transtable2_w[j][212] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212];
tmp_transtable2_w[j][213] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213];
tmp_transtable2_w[j][214] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214];
tmp_transtable2_w[j][215] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215];
tmp_transtable2_w[j][216] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215] || table_r[j][216];
tmp_transtable2_w[j][217] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215] || table_r[j][216] || table_r[j][217];
tmp_transtable2_w[j][218] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215] || table_r[j][216] || table_r[j][217] || table_r[j][218];
tmp_transtable2_w[j][219] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215] || table_r[j][216] || table_r[j][217] || table_r[j][218] || table_r[j][219];
tmp_transtable2_w[j][220] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215] || table_r[j][216] || table_r[j][217] || table_r[j][218] || table_r[j][219] || table_r[j][220];
tmp_transtable2_w[j][221] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215] || table_r[j][216] || table_r[j][217] || table_r[j][218] || table_r[j][219] || table_r[j][220] || table_r[j][221];
tmp_transtable2_w[j][222] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215] || table_r[j][216] || table_r[j][217] || table_r[j][218] || table_r[j][219] || table_r[j][220] || table_r[j][221] || table_r[j][222];
tmp_transtable2_w[j][223] = table_r[j][208] || table_r[j][209] || table_r[j][210] || table_r[j][211] || table_r[j][212] || table_r[j][213] || table_r[j][214] || table_r[j][215] || table_r[j][216] || table_r[j][217] || table_r[j][218] || table_r[j][219] || table_r[j][220] || table_r[j][221] || table_r[j][222] || table_r[j][223];
tmp_transtable2_w[j][224] = table_r[j][224];
tmp_transtable2_w[j][225] = table_r[j][224] || table_r[j][225];
tmp_transtable2_w[j][226] = table_r[j][224] || table_r[j][225] || table_r[j][226];
tmp_transtable2_w[j][227] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227];
tmp_transtable2_w[j][228] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228];
tmp_transtable2_w[j][229] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229];
tmp_transtable2_w[j][230] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230];
tmp_transtable2_w[j][231] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231];
tmp_transtable2_w[j][232] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231] || table_r[j][232];
tmp_transtable2_w[j][233] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231] || table_r[j][232] || table_r[j][233];
tmp_transtable2_w[j][234] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231] || table_r[j][232] || table_r[j][233] || table_r[j][234];
tmp_transtable2_w[j][235] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231] || table_r[j][232] || table_r[j][233] || table_r[j][234] || table_r[j][235];
tmp_transtable2_w[j][236] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231] || table_r[j][232] || table_r[j][233] || table_r[j][234] || table_r[j][235] || table_r[j][236];
tmp_transtable2_w[j][237] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231] || table_r[j][232] || table_r[j][233] || table_r[j][234] || table_r[j][235] || table_r[j][236] || table_r[j][237];
tmp_transtable2_w[j][238] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231] || table_r[j][232] || table_r[j][233] || table_r[j][234] || table_r[j][235] || table_r[j][236] || table_r[j][237] || table_r[j][238];
tmp_transtable2_w[j][239] = table_r[j][224] || table_r[j][225] || table_r[j][226] || table_r[j][227] || table_r[j][228] || table_r[j][229] || table_r[j][230] || table_r[j][231] || table_r[j][232] || table_r[j][233] || table_r[j][234] || table_r[j][235] || table_r[j][236] || table_r[j][237] || table_r[j][238] || table_r[j][239];
tmp_transtable2_w[j][240] = table_r[j][240];
tmp_transtable2_w[j][241] = table_r[j][240] || table_r[j][241];
tmp_transtable2_w[j][242] = table_r[j][240] || table_r[j][241] || table_r[j][242];
tmp_transtable2_w[j][243] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243];
tmp_transtable2_w[j][244] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244];
tmp_transtable2_w[j][245] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245];
tmp_transtable2_w[j][246] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246];
tmp_transtable2_w[j][247] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247];
tmp_transtable2_w[j][248] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247] || table_r[j][248];
tmp_transtable2_w[j][249] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247] || table_r[j][248] || table_r[j][249];
tmp_transtable2_w[j][250] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247] || table_r[j][248] || table_r[j][249] || table_r[j][250];
tmp_transtable2_w[j][251] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247] || table_r[j][248] || table_r[j][249] || table_r[j][250] || table_r[j][251];
tmp_transtable2_w[j][252] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247] || table_r[j][248] || table_r[j][249] || table_r[j][250] || table_r[j][251] || table_r[j][252];
tmp_transtable2_w[j][253] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247] || table_r[j][248] || table_r[j][249] || table_r[j][250] || table_r[j][251] || table_r[j][252] || table_r[j][253];
tmp_transtable2_w[j][254] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247] || table_r[j][248] || table_r[j][249] || table_r[j][250] || table_r[j][251] || table_r[j][252] || table_r[j][253] || table_r[j][254];
tmp_transtable2_w[j][255] = table_r[j][240] || table_r[j][241] || table_r[j][242] || table_r[j][243] || table_r[j][244] || table_r[j][245] || table_r[j][246] || table_r[j][247] || table_r[j][248] || table_r[j][249] || table_r[j][250] || table_r[j][251] || table_r[j][252] || table_r[j][253] || table_r[j][254] || table_r[j][255];
end



// TRANSBABLE
            for(j=0;j<4;j=j+1) begin
transtable_w[j][0] = tmp_transtable2_r[j][0] ;
transtable_w[j][1] = tmp_transtable2_r[j][1] ;
transtable_w[j][2] = tmp_transtable2_r[j][2] ;
transtable_w[j][3] = tmp_transtable2_r[j][3] ;
transtable_w[j][4] = tmp_transtable2_r[j][4] ;
transtable_w[j][5] = tmp_transtable2_r[j][5] ;
transtable_w[j][6] = tmp_transtable2_r[j][6] ;
transtable_w[j][7] = tmp_transtable2_r[j][7] ;
transtable_w[j][8] = tmp_transtable2_r[j][8] ;
transtable_w[j][9] = tmp_transtable2_r[j][9] ;
transtable_w[j][10] = tmp_transtable2_r[j][10] ;
transtable_w[j][11] = tmp_transtable2_r[j][11] ;
transtable_w[j][12] = tmp_transtable2_r[j][12] ;
transtable_w[j][13] = tmp_transtable2_r[j][13] ;
transtable_w[j][14] = tmp_transtable2_r[j][14] ;
transtable_w[j][15] = tmp_transtable2_r[j][15] ;
transtable_w[j][16] = tmp_transtable2_r[j][16]  || tmp_transtable_r[j][0];
transtable_w[j][17] = tmp_transtable2_r[j][17]  || tmp_transtable_r[j][0];
transtable_w[j][18] = tmp_transtable2_r[j][18]  || tmp_transtable_r[j][0];
transtable_w[j][19] = tmp_transtable2_r[j][19]  || tmp_transtable_r[j][0];
transtable_w[j][20] = tmp_transtable2_r[j][20]  || tmp_transtable_r[j][0];
transtable_w[j][21] = tmp_transtable2_r[j][21]  || tmp_transtable_r[j][0];
transtable_w[j][22] = tmp_transtable2_r[j][22]  || tmp_transtable_r[j][0];
transtable_w[j][23] = tmp_transtable2_r[j][23]  || tmp_transtable_r[j][0];
transtable_w[j][24] = tmp_transtable2_r[j][24]  || tmp_transtable_r[j][0];
transtable_w[j][25] = tmp_transtable2_r[j][25]  || tmp_transtable_r[j][0];
transtable_w[j][26] = tmp_transtable2_r[j][26]  || tmp_transtable_r[j][0];
transtable_w[j][27] = tmp_transtable2_r[j][27]  || tmp_transtable_r[j][0];
transtable_w[j][28] = tmp_transtable2_r[j][28]  || tmp_transtable_r[j][0];
transtable_w[j][29] = tmp_transtable2_r[j][29]  || tmp_transtable_r[j][0];
transtable_w[j][30] = tmp_transtable2_r[j][30]  || tmp_transtable_r[j][0];
transtable_w[j][31] = tmp_transtable2_r[j][31]  || tmp_transtable_r[j][0];
transtable_w[j][32] = tmp_transtable2_r[j][32]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][33] = tmp_transtable2_r[j][33]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][34] = tmp_transtable2_r[j][34]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][35] = tmp_transtable2_r[j][35]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][36] = tmp_transtable2_r[j][36]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][37] = tmp_transtable2_r[j][37]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][38] = tmp_transtable2_r[j][38]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][39] = tmp_transtable2_r[j][39]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][40] = tmp_transtable2_r[j][40]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][41] = tmp_transtable2_r[j][41]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][42] = tmp_transtable2_r[j][42]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][43] = tmp_transtable2_r[j][43]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][44] = tmp_transtable2_r[j][44]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][45] = tmp_transtable2_r[j][45]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][46] = tmp_transtable2_r[j][46]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][47] = tmp_transtable2_r[j][47]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1];
transtable_w[j][48] = tmp_transtable2_r[j][48]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][49] = tmp_transtable2_r[j][49]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][50] = tmp_transtable2_r[j][50]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][51] = tmp_transtable2_r[j][51]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][52] = tmp_transtable2_r[j][52]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][53] = tmp_transtable2_r[j][53]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][54] = tmp_transtable2_r[j][54]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][55] = tmp_transtable2_r[j][55]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][56] = tmp_transtable2_r[j][56]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][57] = tmp_transtable2_r[j][57]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][58] = tmp_transtable2_r[j][58]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][59] = tmp_transtable2_r[j][59]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][60] = tmp_transtable2_r[j][60]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][61] = tmp_transtable2_r[j][61]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][62] = tmp_transtable2_r[j][62]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][63] = tmp_transtable2_r[j][63]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2];
transtable_w[j][64] = tmp_transtable2_r[j][64]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][65] = tmp_transtable2_r[j][65]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][66] = tmp_transtable2_r[j][66]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][67] = tmp_transtable2_r[j][67]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][68] = tmp_transtable2_r[j][68]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][69] = tmp_transtable2_r[j][69]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][70] = tmp_transtable2_r[j][70]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][71] = tmp_transtable2_r[j][71]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][72] = tmp_transtable2_r[j][72]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][73] = tmp_transtable2_r[j][73]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][74] = tmp_transtable2_r[j][74]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][75] = tmp_transtable2_r[j][75]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][76] = tmp_transtable2_r[j][76]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][77] = tmp_transtable2_r[j][77]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][78] = tmp_transtable2_r[j][78]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][79] = tmp_transtable2_r[j][79]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3];
transtable_w[j][80] = tmp_transtable2_r[j][80]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][81] = tmp_transtable2_r[j][81]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][82] = tmp_transtable2_r[j][82]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][83] = tmp_transtable2_r[j][83]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][84] = tmp_transtable2_r[j][84]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][85] = tmp_transtable2_r[j][85]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][86] = tmp_transtable2_r[j][86]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][87] = tmp_transtable2_r[j][87]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][88] = tmp_transtable2_r[j][88]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][89] = tmp_transtable2_r[j][89]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][90] = tmp_transtable2_r[j][90]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][91] = tmp_transtable2_r[j][91]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][92] = tmp_transtable2_r[j][92]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][93] = tmp_transtable2_r[j][93]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][94] = tmp_transtable2_r[j][94]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][95] = tmp_transtable2_r[j][95]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4];
transtable_w[j][96] = tmp_transtable2_r[j][96]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][97] = tmp_transtable2_r[j][97]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][98] = tmp_transtable2_r[j][98]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][99] = tmp_transtable2_r[j][99]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][100] = tmp_transtable2_r[j][100]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][101] = tmp_transtable2_r[j][101]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][102] = tmp_transtable2_r[j][102]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][103] = tmp_transtable2_r[j][103]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][104] = tmp_transtable2_r[j][104]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][105] = tmp_transtable2_r[j][105]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][106] = tmp_transtable2_r[j][106]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][107] = tmp_transtable2_r[j][107]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][108] = tmp_transtable2_r[j][108]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][109] = tmp_transtable2_r[j][109]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][110] = tmp_transtable2_r[j][110]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][111] = tmp_transtable2_r[j][111]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5];
transtable_w[j][112] = tmp_transtable2_r[j][112]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][113] = tmp_transtable2_r[j][113]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][114] = tmp_transtable2_r[j][114]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][115] = tmp_transtable2_r[j][115]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][116] = tmp_transtable2_r[j][116]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][117] = tmp_transtable2_r[j][117]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][118] = tmp_transtable2_r[j][118]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][119] = tmp_transtable2_r[j][119]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][120] = tmp_transtable2_r[j][120]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][121] = tmp_transtable2_r[j][121]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][122] = tmp_transtable2_r[j][122]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][123] = tmp_transtable2_r[j][123]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][124] = tmp_transtable2_r[j][124]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][125] = tmp_transtable2_r[j][125]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][126] = tmp_transtable2_r[j][126]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][127] = tmp_transtable2_r[j][127]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6];
transtable_w[j][128] = tmp_transtable2_r[j][128]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][129] = tmp_transtable2_r[j][129]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][130] = tmp_transtable2_r[j][130]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][131] = tmp_transtable2_r[j][131]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][132] = tmp_transtable2_r[j][132]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][133] = tmp_transtable2_r[j][133]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][134] = tmp_transtable2_r[j][134]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][135] = tmp_transtable2_r[j][135]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][136] = tmp_transtable2_r[j][136]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][137] = tmp_transtable2_r[j][137]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][138] = tmp_transtable2_r[j][138]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][139] = tmp_transtable2_r[j][139]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][140] = tmp_transtable2_r[j][140]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][141] = tmp_transtable2_r[j][141]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][142] = tmp_transtable2_r[j][142]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][143] = tmp_transtable2_r[j][143]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7];
transtable_w[j][144] = tmp_transtable2_r[j][144]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][145] = tmp_transtable2_r[j][145]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][146] = tmp_transtable2_r[j][146]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][147] = tmp_transtable2_r[j][147]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][148] = tmp_transtable2_r[j][148]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][149] = tmp_transtable2_r[j][149]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][150] = tmp_transtable2_r[j][150]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][151] = tmp_transtable2_r[j][151]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][152] = tmp_transtable2_r[j][152]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][153] = tmp_transtable2_r[j][153]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][154] = tmp_transtable2_r[j][154]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][155] = tmp_transtable2_r[j][155]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][156] = tmp_transtable2_r[j][156]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][157] = tmp_transtable2_r[j][157]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][158] = tmp_transtable2_r[j][158]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][159] = tmp_transtable2_r[j][159]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8];
transtable_w[j][160] = tmp_transtable2_r[j][160]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][161] = tmp_transtable2_r[j][161]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][162] = tmp_transtable2_r[j][162]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][163] = tmp_transtable2_r[j][163]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][164] = tmp_transtable2_r[j][164]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][165] = tmp_transtable2_r[j][165]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][166] = tmp_transtable2_r[j][166]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][167] = tmp_transtable2_r[j][167]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][168] = tmp_transtable2_r[j][168]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][169] = tmp_transtable2_r[j][169]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][170] = tmp_transtable2_r[j][170]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][171] = tmp_transtable2_r[j][171]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][172] = tmp_transtable2_r[j][172]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][173] = tmp_transtable2_r[j][173]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][174] = tmp_transtable2_r[j][174]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][175] = tmp_transtable2_r[j][175]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9];
transtable_w[j][176] = tmp_transtable2_r[j][176]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][177] = tmp_transtable2_r[j][177]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][178] = tmp_transtable2_r[j][178]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][179] = tmp_transtable2_r[j][179]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][180] = tmp_transtable2_r[j][180]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][181] = tmp_transtable2_r[j][181]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][182] = tmp_transtable2_r[j][182]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][183] = tmp_transtable2_r[j][183]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][184] = tmp_transtable2_r[j][184]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][185] = tmp_transtable2_r[j][185]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][186] = tmp_transtable2_r[j][186]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][187] = tmp_transtable2_r[j][187]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][188] = tmp_transtable2_r[j][188]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][189] = tmp_transtable2_r[j][189]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][190] = tmp_transtable2_r[j][190]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][191] = tmp_transtable2_r[j][191]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10];
transtable_w[j][192] = tmp_transtable2_r[j][192]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][193] = tmp_transtable2_r[j][193]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][194] = tmp_transtable2_r[j][194]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][195] = tmp_transtable2_r[j][195]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][196] = tmp_transtable2_r[j][196]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][197] = tmp_transtable2_r[j][197]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][198] = tmp_transtable2_r[j][198]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][199] = tmp_transtable2_r[j][199]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][200] = tmp_transtable2_r[j][200]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][201] = tmp_transtable2_r[j][201]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][202] = tmp_transtable2_r[j][202]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][203] = tmp_transtable2_r[j][203]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][204] = tmp_transtable2_r[j][204]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][205] = tmp_transtable2_r[j][205]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][206] = tmp_transtable2_r[j][206]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][207] = tmp_transtable2_r[j][207]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11];
transtable_w[j][208] = tmp_transtable2_r[j][208]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][209] = tmp_transtable2_r[j][209]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][210] = tmp_transtable2_r[j][210]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][211] = tmp_transtable2_r[j][211]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][212] = tmp_transtable2_r[j][212]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][213] = tmp_transtable2_r[j][213]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][214] = tmp_transtable2_r[j][214]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][215] = tmp_transtable2_r[j][215]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][216] = tmp_transtable2_r[j][216]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][217] = tmp_transtable2_r[j][217]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][218] = tmp_transtable2_r[j][218]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][219] = tmp_transtable2_r[j][219]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][220] = tmp_transtable2_r[j][220]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][221] = tmp_transtable2_r[j][221]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][222] = tmp_transtable2_r[j][222]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][223] = tmp_transtable2_r[j][223]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12];
transtable_w[j][224] = tmp_transtable2_r[j][224]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][225] = tmp_transtable2_r[j][225]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][226] = tmp_transtable2_r[j][226]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][227] = tmp_transtable2_r[j][227]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][228] = tmp_transtable2_r[j][228]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][229] = tmp_transtable2_r[j][229]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][230] = tmp_transtable2_r[j][230]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][231] = tmp_transtable2_r[j][231]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][232] = tmp_transtable2_r[j][232]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][233] = tmp_transtable2_r[j][233]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][234] = tmp_transtable2_r[j][234]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][235] = tmp_transtable2_r[j][235]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][236] = tmp_transtable2_r[j][236]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][237] = tmp_transtable2_r[j][237]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][238] = tmp_transtable2_r[j][238]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][239] = tmp_transtable2_r[j][239]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13];
transtable_w[j][240] = tmp_transtable2_r[j][240]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][241] = tmp_transtable2_r[j][241]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][242] = tmp_transtable2_r[j][242]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][243] = tmp_transtable2_r[j][243]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][244] = tmp_transtable2_r[j][244]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][245] = tmp_transtable2_r[j][245]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][246] = tmp_transtable2_r[j][246]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][247] = tmp_transtable2_r[j][247]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][248] = tmp_transtable2_r[j][248]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][249] = tmp_transtable2_r[j][249]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][250] = tmp_transtable2_r[j][250]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][251] = tmp_transtable2_r[j][251]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][252] = tmp_transtable2_r[j][252]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][253] = tmp_transtable2_r[j][253]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][254] = tmp_transtable2_r[j][254]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];
transtable_w[j][255] = tmp_transtable2_r[j][255]  || tmp_transtable_r[j][0] || tmp_transtable_r[j][1] || tmp_transtable_r[j][2] || tmp_transtable_r[j][3] || tmp_transtable_r[j][4] || tmp_transtable_r[j][5] || tmp_transtable_r[j][6] || tmp_transtable_r[j][7] || tmp_transtable_r[j][8] || tmp_transtable_r[j][9] || tmp_transtable_r[j][10] || tmp_transtable_r[j][11] || tmp_transtable_r[j][12] || tmp_transtable_r[j][13] || tmp_transtable_r[j][14];

end

// SUMTABLE
            for(j=0;j<4;j=j+1) begin
                tableIdx1_w[j] = transtable_r[j][0]
                + transtable_r[j][1]
                + transtable_r[j][2]
                + transtable_r[j][3]
                + transtable_r[j][4]
                + transtable_r[j][5]
                + transtable_r[j][6]
                + transtable_r[j][7];
                tableIdx2_w[j] = transtable_r[j][8]
                + transtable_r[j][9]
                + transtable_r[j][10]
                + transtable_r[j][11]
                + transtable_r[j][12]
                + transtable_r[j][13]
                + transtable_r[j][14]
                + transtable_r[j][15];
                
                tableIdx3_w[j] = transtable_r[j][16]
                + transtable_r[j][17]
                + transtable_r[j][18]
                + transtable_r[j][19]
                + transtable_r[j][20]
                + transtable_r[j][21]
                + transtable_r[j][22]
                + transtable_r[j][23];
                tableIdx4_w[j] = transtable_r[j][24]
                + transtable_r[j][25]
                + transtable_r[j][26]
                + transtable_r[j][27]
                + transtable_r[j][28]
                + transtable_r[j][29]
                + transtable_r[j][30]
                + transtable_r[j][31];

                tableIdx5_w[j] = transtable_r[j][32]
                + transtable_r[j][33]
                + transtable_r[j][34]
                + transtable_r[j][35]
                + transtable_r[j][36]
                + transtable_r[j][37]
                + transtable_r[j][38]
                + transtable_r[j][39];
                tableIdx6_w[j] = transtable_r[j][40]
                + transtable_r[j][41]
                + transtable_r[j][42]
                + transtable_r[j][43]
                + transtable_r[j][44]
                + transtable_r[j][45]
                + transtable_r[j][46]
                + transtable_r[j][47];

                tableIdx7_w[j] = transtable_r[j][48]
                + transtable_r[j][49]
                + transtable_r[j][50]
                + transtable_r[j][51]
                + transtable_r[j][52]
                + transtable_r[j][53]
                + transtable_r[j][54]
                + transtable_r[j][55];
                tableIdx8_w[j] = transtable_r[j][56]
                + transtable_r[j][57]
                + transtable_r[j][58]
                + transtable_r[j][59]
                + transtable_r[j][60]
                + transtable_r[j][61]
                + transtable_r[j][62]
                + transtable_r[j][63];

                tableIdx9_w[j] = transtable_r[j][64]
                + transtable_r[j][65]
                + transtable_r[j][66]
                + transtable_r[j][67]
                + transtable_r[j][68]
                + transtable_r[j][69]
                + transtable_r[j][70]
                + transtable_r[j][71];
                tableIdx10_w[j] = transtable_r[j][72]
                + transtable_r[j][73]
                + transtable_r[j][74]
                + transtable_r[j][75]
                + transtable_r[j][76]
                + transtable_r[j][77]
                + transtable_r[j][78]
                + transtable_r[j][79];

                tableIdx11_w[j] = transtable_r[j][80]
                + transtable_r[j][81]
                + transtable_r[j][82]
                + transtable_r[j][83]
                + transtable_r[j][84]
                + transtable_r[j][85]
                + transtable_r[j][86]
                + transtable_r[j][87];
                tableIdx12_w[j] = transtable_r[j][88]
                + transtable_r[j][89]
                + transtable_r[j][90]
                + transtable_r[j][91]
                + transtable_r[j][92]
                + transtable_r[j][93]
                + transtable_r[j][94]
                + transtable_r[j][95];

                tableIdx13_w[j] = transtable_r[j][96]
                + transtable_r[j][97]
                + transtable_r[j][98]
                + transtable_r[j][99]
                + transtable_r[j][100]
                + transtable_r[j][101]
                + transtable_r[j][102]
                + transtable_r[j][103];
                tableIdx14_w[j] = transtable_r[j][104]
                + transtable_r[j][105]
                + transtable_r[j][106]
                + transtable_r[j][107]
                + transtable_r[j][108]
                + transtable_r[j][109]
                + transtable_r[j][110]
                + transtable_r[j][111];


                tableIdx15_w[j] = transtable_r[j][112]
                + transtable_r[j][113]
                + transtable_r[j][114]
                + transtable_r[j][115]
                + transtable_r[j][116]
                + transtable_r[j][117]
                + transtable_r[j][118]
                + transtable_r[j][119];
                tableIdx16_w[j] = transtable_r[j][120]
                + transtable_r[j][121]
                + transtable_r[j][122]
                + transtable_r[j][123]
                + transtable_r[j][124]
                + transtable_r[j][125]
                + transtable_r[j][126]
                + transtable_r[j][127];

                tableIdx17_w[j] = transtable_r[j][128]
                + transtable_r[j][129]
                + transtable_r[j][130]
                + transtable_r[j][131]
                + transtable_r[j][132]
                + transtable_r[j][133]
                + transtable_r[j][134]
                + transtable_r[j][135];
                tableIdx18_w[j] = transtable_r[j][136]
                + transtable_r[j][137]
                + transtable_r[j][138]
                + transtable_r[j][139]
                + transtable_r[j][140]
                + transtable_r[j][141]
                + transtable_r[j][142]
                + transtable_r[j][143];

                tableIdx19_w[j] = transtable_r[j][144]
                + transtable_r[j][145]
                + transtable_r[j][146]
                + transtable_r[j][147]
                + transtable_r[j][148]
                + transtable_r[j][149]
                + transtable_r[j][150]
                + transtable_r[j][151];
                tableIdx20_w[j] = transtable_r[j][152]
                + transtable_r[j][153]
                + transtable_r[j][154]
                + transtable_r[j][155]
                + transtable_r[j][156]
                + transtable_r[j][157]
                + transtable_r[j][158]
                + transtable_r[j][159];

                tableIdx21_w[j] = transtable_r[j][160]
                + transtable_r[j][161]
                + transtable_r[j][162]
                + transtable_r[j][163]
                + transtable_r[j][164]
                + transtable_r[j][165]
                + transtable_r[j][166]
                + transtable_r[j][167];
                tableIdx22_w[j] = transtable_r[j][168]
                + transtable_r[j][169]
                + transtable_r[j][170]
                + transtable_r[j][171]
                + transtable_r[j][172]
                + transtable_r[j][173]
                + transtable_r[j][174]
                + transtable_r[j][175];

                tableIdx23_w[j] = transtable_r[j][176]
                + transtable_r[j][177]
                + transtable_r[j][178]
                + transtable_r[j][179]
                + transtable_r[j][180]
                + transtable_r[j][181]
                + transtable_r[j][182]
                + transtable_r[j][183];
                tableIdx24_w[j] = transtable_r[j][184]
                + transtable_r[j][185]
                + transtable_r[j][186]
                + transtable_r[j][187]
                + transtable_r[j][188]
                + transtable_r[j][189]
                + transtable_r[j][190]
                + transtable_r[j][191];

                tableIdx25_w[j] = transtable_r[j][192]
                + transtable_r[j][193]
                + transtable_r[j][194]
                + transtable_r[j][195]
                + transtable_r[j][196]
                + transtable_r[j][197]
                + transtable_r[j][198]
                + transtable_r[j][199];
                tableIdx26_w[j] = transtable_r[j][200]
                + transtable_r[j][201]
                + transtable_r[j][202]
                + transtable_r[j][203]
                + transtable_r[j][204]
                + transtable_r[j][205]
                + transtable_r[j][206]
                + transtable_r[j][207];

                tableIdx27_w[j] = transtable_r[j][208]
                + transtable_r[j][209]
                + transtable_r[j][210]
                + transtable_r[j][211]
                + transtable_r[j][212]
                + transtable_r[j][213]
                + transtable_r[j][214]
                + transtable_r[j][215];
                tableIdx28_w[j] = transtable_r[j][216]
                + transtable_r[j][217]
                + transtable_r[j][218]
                + transtable_r[j][219]
                + transtable_r[j][220]
                + transtable_r[j][221]
                + transtable_r[j][222]
                + transtable_r[j][223];

                tableIdx29_w[j] = transtable_r[j][224]
                + transtable_r[j][225]
                + transtable_r[j][226]
                + transtable_r[j][227]
                + transtable_r[j][228]
                + transtable_r[j][229]
                + transtable_r[j][230]
                + transtable_r[j][231];
                tableIdx30_w[j] = transtable_r[j][232]
                + transtable_r[j][233]
                + transtable_r[j][234]
                + transtable_r[j][235]
                + transtable_r[j][236]
                + transtable_r[j][237]
                + transtable_r[j][238]
                + transtable_r[j][239];

                tableIdx31_w[j] = transtable_r[j][240]
                + transtable_r[j][241]
                + transtable_r[j][242]
                + transtable_r[j][243]
                + transtable_r[j][244]
                + transtable_r[j][245]
                + transtable_r[j][246]
                + transtable_r[j][247];
                tableIdx32_w[j] = transtable_r[j][248]
                + transtable_r[j][249]
                + transtable_r[j][250]
                + transtable_r[j][251]
                + transtable_r[j][252]
                + transtable_r[j][253]
                + transtable_r[j][254]
                + transtable_r[j][255];
            end

// PIPELINE OF SUMTABLE
            for(j=0;j<4;j=j+1) begin
                temp9bit_1_w[j] = tableIdx1_r[j] +
                    tableIdx2_r[j] +
                    tableIdx3_r[j] +
                    tableIdx4_r[j] +
                    tableIdx5_r[j] +
                    tableIdx6_r[j] +
                    tableIdx7_r[j] +
                    tableIdx8_r[j];

                temp9bit_2_w[j] = tableIdx9_r[j] +
                    tableIdx10_r[j] +
                    tableIdx11_r[j] +
                    tableIdx12_r[j] +
                    tableIdx13_r[j] +
                    tableIdx14_r[j] +
                    tableIdx15_r[j] +
                    tableIdx16_r[j] ;
                temp9bit_3_w[j] = tableIdx17_r[j] +
                    tableIdx18_r[j] +
                    tableIdx19_r[j] +
                    tableIdx20_r[j] +
                    tableIdx21_r[j] +
                    tableIdx22_r[j] +
                    tableIdx23_r[j] +
                    tableIdx24_r[j] ;
                temp9bit_4_w[j] = tableIdx25_r[j] +
                    tableIdx26_r[j] +
                    tableIdx27_r[j] +
                    tableIdx28_r[j] +
                    tableIdx29_r[j] +
                    tableIdx30_r[j] +
                    tableIdx31_r[j] +
                    tableIdx32_r[j] ;

                tableIdx_w[j] = temp9bit_1_r[j] + temp9bit_2_r[j] + temp9bit_3_r[j] + temp9bit_4_r[j];
            end

// ENCODE
            outputreg_w[0] = {1'd0, inBuffer_r[0], 2'b0};
            outputreg_w[1] = outputreg_r[0];
            outputreg_w[2] = outputreg_r[1];
            outputreg_w[3] = outputreg_r[2];
            outputreg_w[4] = outputreg_r[3];
            outputreg_w[5] = outputreg_r[4];
            outputreg_w[6] = outputreg_r[5];
            outputreg_w[7] = outputreg_r[6];

            if(tableIdx_r[0]!=0) begin
                newCode_w[10] = 1'd1;
                newCode_w[9:2] = 9'd256-tableIdx_r[0];
                newCode_w[1:0] = 2'd3;
            end
            else if(tableIdx_r[1]!=0) begin
                newCode_w[10] = 1'd1;
                newCode_w[9:2] = 9'd256-tableIdx_r[1];
                newCode_w[1:0] = 2'd2;
            end
            else if(tableIdx_r[2]!=0) begin
                newCode_w[10] = 1'd1;
                newCode_w[9:2] = 9'd256-tableIdx_r[2];
                newCode_w[1:0] = 2'd1;
            end
            else if(tableIdx_r[3]!=0) begin
                newCode_w[10] = 1'd1;
                newCode_w[9:2] = 9'd256-tableIdx_r[3];
                newCode_w[1:0] = 2'd0;
            end
            else begin 
                newCode_w = 11'b0;
            end

// DECIDE IF MATCH & DELAY
            pause2_w = pause1_r;

            if(pause1_r!=0) begin 
                pause1_w = pause1_r - 1;
            end
            else begin
                globalcount_w = globalcount_r + 1;
                if(tableIdx_r[0]!=0) begin
                    pause1_w = 4;
                end
                else if(tableIdx_r[1]!=0) begin
                    pause1_w = 3;
                end
                else if(tableIdx_r[2]!=0) begin
                    pause1_w = 2;
                end
                else if(tableIdx_r[3]!=0) begin
                    pause1_w = 1;
                end
                else begin 
                    pause1_w = 0;
                end
            end


// ENCODEDONE  and  INPUT ANOTHER DATA
            if(drop_done_r) begin
                busy_w = 1;
                if (localcount_r==4'hb)
                    state_w = INPUTDONE;
            end
            else begin
                if(localcount_r==4'd6 )
                    busy_w = 0;
                else
                    busy_w = 1;
            end

            if (localcount_r<4'd6 && ((data_valid&data_valid)|(~drop_done_r)) ) begin
                localcount_w = localcount_r + 3;
                inBuffer_w[localcount_r-1] = data[31:24];
                inBuffer_w[localcount_r  ] = data[23:16];
                inBuffer_w[localcount_r+1] = data[15:8];
                inBuffer_w[localcount_r+2] = data[7:0];
                for( i = 0 ; i < 4 ; i=i+1)
                    inBuffer_w[i] = inBuffer_r[i+1];
            end
            else begin
                localcount_w = localcount_r - 1;
                for( i = 0 ; i < 8 ; i=i+1)
                    inBuffer_w[i] = inBuffer_r[i+1];
                inBuffer_w[8] = 8'b0;
            end

        end
        INPUTDONE: begin
            state_w = OUTPUTDONE;
            finish_w = 1;
        end
        OUTPUTDONE: begin
            finish_w = 1;
        end
    endcase
end



//========================sequential============================
always@(posedge clk or posedge reset)begin
	if(reset)begin
        out_valid       <= 0;
        codeword        <= 0;
		state_r         <= IDLE;
        localcount_r    <= 0;
        globalcount_r   <=0;
        pause1_r         <= 0;
        pause2_r         <= 0;
        newCode_r       <= 0;
        busy            <= 1;
        drop_done_r     <= 0;

        for(i=0;i<4;i=i+1) begin
            temp9bit_1_r[i]    <= 0;    
            temp9bit_2_r[i]    <= 0;
            temp9bit_3_r[i]    <= 0;
            temp9bit_4_r[i]    <= 0;
        end
        for(i=0;i<256;i=i+1)
            dictionary_r[i] <= 8'b0;
        for(i=0;i<9;i=i+1)
            inBuffer_r[i] <= 8'b0;
        for(j=0;j<4;j=j+1) begin
            for(i=0;i<16;i=i+1) begin
                tmp_transtable_r[j][i] <= 0;
            end
        end
        for(j=0;j<4;j=j+1) begin
            for(i=0;i<256;i=i+1) begin
                table_r[j][i] <= 0;
                transtable_r[j][i] <= 0;
                tmp_transtable2_r[j][i] <= 0;
            end
        end
        for(i=0;i<4;i=i+1) begin

            tableIdx_r[i] <= 0;
            tableIdx1_r[i] <= 0;
            tableIdx2_r[i] <= 0;
            tableIdx3_r[i] <= 0;
            tableIdx4_r[i] <= 0;
            tableIdx5_r[i] <= 0;
            tableIdx6_r[i] <= 0;
            tableIdx7_r[i] <= 0;
            tableIdx8_r[i] <= 0;
            tableIdx9_r[i] <= 0;
            tableIdx10_r[i] <= 0;
            tableIdx11_r[i] <= 0;
            tableIdx12_r[i] <= 0;
            tableIdx13_r[i] <= 0;
            tableIdx14_r[i] <= 0;
            tableIdx15_r[i] <= 0;
            tableIdx16_r[i] <= 0;
            tableIdx17_r[i] <= 0;
            tableIdx18_r[i] <= 0;
            tableIdx19_r[i] <= 0;
            tableIdx20_r[i] <= 0;
            tableIdx21_r[i] <= 0;
            tableIdx22_r[i] <= 0;
            tableIdx23_r[i] <= 0;
            tableIdx24_r[i] <= 0;
            tableIdx25_r[i] <= 0;
            tableIdx26_r[i] <= 0;
            tableIdx27_r[i] <= 0;
            tableIdx28_r[i] <= 0;
            tableIdx29_r[i] <= 0;
            tableIdx30_r[i] <= 0;
            tableIdx31_r[i] <= 0;
            tableIdx32_r[i] <= 0;

        end

        for(i=0;i<=7;i=i+1)
            outputreg_r[i] <= 0;
	end
	else begin
        drop_done_r     <= drop_done;
        busy            <= busy_w;
	    enc_num         <= enc_num_w;
        finish          <= finish_w;


        out_valid       <= out_valid_w;
        codeword        <= codeword_w;
		state_r         <= state_w;
        localcount_r    <= localcount_w;
        globalcount_r   <= globalcount_w;
        pause1_r        <= pause1_w;
        pause2_r        <= pause2_w;
        newCode_r       <= newCode_w;
        for(j=0;j<4;j=j+1) begin
            temp9bit_1_r[j]    <= temp9bit_1_w[j];    
            temp9bit_2_r[j]    <= temp9bit_2_w[j];
            temp9bit_3_r[j]    <= temp9bit_3_w[j];
            temp9bit_4_r[j]    <= temp9bit_4_w[j];
        end
        for(i=0;i<256;i=i+1)
            dictionary_r[i] <= dictionary_w[i];
        for(i=0;i<9;i=i+1)
            inBuffer_r[i] <= inBuffer_w[i];

        for(j=0;j<4;j=j+1) begin
            for(i=0;i<16;i=i+1) begin
                tmp_transtable_r[j][i] <= tmp_transtable_w[j][i];
            end
        end
        for(j=0;j<4;j=j+1) begin
            for(i=0;i<256;i=i+1) begin
                table_r[j][i] <= table_w[j][i];
                transtable_r[j][i] <= transtable_w[j][i];
                tmp_transtable2_r[j][i] <= tmp_transtable2_w[j][i];
            end
        end
        for(i=0;i<4;i=i+1) begin
            tableIdx_r[i] <= tableIdx_w[i];
            tableIdx1_r[i] <= tableIdx1_w[i];
            tableIdx2_r[i] <= tableIdx2_w[i];
            tableIdx3_r[i] <= tableIdx3_w[i];
            tableIdx4_r[i] <= tableIdx4_w[i];
            tableIdx5_r[i] <= tableIdx5_w[i];
            tableIdx6_r[i] <= tableIdx6_w[i];
            tableIdx7_r[i] <= tableIdx7_w[i];
            tableIdx8_r[i] <= tableIdx8_w[i];
            tableIdx9_r[i] <= tableIdx9_w[i];
            tableIdx10_r[i] <= tableIdx10_w[i];
            tableIdx11_r[i] <= tableIdx11_w[i];
            tableIdx12_r[i] <= tableIdx12_w[i];
            tableIdx13_r[i] <= tableIdx13_w[i];
            tableIdx14_r[i] <= tableIdx14_w[i];
            tableIdx15_r[i] <= tableIdx15_w[i];
            tableIdx16_r[i] <= tableIdx16_w[i];
            tableIdx17_r[i] <= tableIdx17_w[i];
            tableIdx18_r[i] <= tableIdx18_w[i];
            tableIdx19_r[i] <= tableIdx19_w[i];
            tableIdx20_r[i] <= tableIdx20_w[i];
            tableIdx21_r[i] <= tableIdx21_w[i];
            tableIdx22_r[i] <= tableIdx22_w[i];
            tableIdx23_r[i] <= tableIdx23_w[i];
            tableIdx24_r[i] <= tableIdx24_w[i];
            tableIdx25_r[i] <= tableIdx25_w[i];
            tableIdx26_r[i] <= tableIdx26_w[i];
            tableIdx27_r[i] <= tableIdx27_w[i];
            tableIdx28_r[i] <= tableIdx28_w[i];
            tableIdx29_r[i] <= tableIdx29_w[i];
            tableIdx30_r[i] <= tableIdx30_w[i];
            tableIdx31_r[i] <= tableIdx31_w[i];
            tableIdx32_r[i] <= tableIdx32_w[i];
        end

        for(i=0;i<=7;i=i+1)
            outputreg_r[i] <= outputreg_w[i];

	end
end


endmodule

