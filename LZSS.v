// last update: Jan. 7 by NC


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
reg             busy;
reg             finish;
reg [10:0]      codeword,codeword_w;
reg             out_valid,out_valid_w;

reg [2:0]       state_r,state_w;
reg [3:0]       localcount_r,localcount_w;
reg [9:0]       globalcount_r,globalcount_w;
reg [7:0]       inBuffer_r[0:8],inBuffer_w[0:8];
reg [7:0]       dictionary_w[0:255],dictionary_r[0:255];
reg             table_r[0:3][0:255],table_w[0:3][0:255];
reg             transtable_r[0:3][0:255],transtable_w[0:3][0:255];
reg             tmp_table_r[0:4][0:255],  tmp_table_w[0:4][0:255];
reg [8:0]       tableIdx_r[0:3];
reg [8:0]       tableIdx1_r[0:3];
reg [8:0]       tableIdx2_r[0:3];
reg [8:0]       tableIdx3_r[0:3];
reg [8:0]       tableIdx4_r[0:3];
reg [8:0]       tableIdx5_r[0:3];
reg [8:0]       tableIdx6_r[0:3];
reg [8:0]       tableIdx7_r[0:3];
reg [8:0]       tableIdx8_r[0:3];
reg [8:0]       tableIdx9_r[0:3];
reg [8:0]       tableIdx10_r[0:3];
reg [8:0]       tableIdx11_r[0:3];
reg [8:0]       tableIdx12_r[0:3];
reg [8:0]       tableIdx13_r[0:3];
reg [8:0]       tableIdx14_r[0:3];
reg [8:0]       tableIdx15_r[0:3];
reg [8:0]       tableIdx16_r[0:3];
reg [8:0]       temp9bit_1, temp9bit_2;

reg [8:0]       tableIdx_w[0:3];
reg [8:0]       tableIdx1_w[0:3];
reg [8:0]       tableIdx2_w[0:3];
reg [8:0]       tableIdx3_w[0:3];
reg [8:0]       tableIdx4_w[0:3];
reg [8:0]       tableIdx5_w[0:3];
reg [8:0]       tableIdx6_w[0:3];
reg [8:0]       tableIdx7_w[0:3];
reg [8:0]       tableIdx8_w[0:3];
reg [8:0]       tableIdx9_w[0:3];
reg [8:0]       tableIdx10_w[0:3];
reg [8:0]       tableIdx11_w[0:3];
reg [8:0]       tableIdx12_w[0:3];
reg [8:0]       tableIdx13_w[0:3];
reg [8:0]       tableIdx14_w[0:3];
reg [8:0]       tableIdx15_w[0:3];
reg [8:0]       tableIdx16_w[0:3];
reg [4:0]       pause1_r,pause1_w;
reg [4:0]       pause2_r,pause2_w;
reg [10:0]      outputreg_r[0:5],outputreg_w[0:5];
reg [10:0]      newCode_r,newCode_w;
//========================combinational==========================
assign enc_num = (globalcount_r>6)? globalcount_r-6 : 0 ;
always@(*) begin

    if(pause2_r!=0) begin
        codeword_w = 0;
        out_valid_w = 0;
    end   
    else begin
        out_valid_w = (globalcount_r<=10'd5)? 0:1;
        codeword_w = (pause1_r==5'd0)?outputreg_r[5] : newCode_r;
    end
end

always@(*)begin
    state_w         = state_r;
    localcount_w    = localcount_r;
    globalcount_w   = globalcount_r;
    pause1_w        = pause1_r;
    pause2_w        = pause2_r;
    newCode_w       = newCode_r; 
    busy            = 1;
    finish          = 0;
    for(i=0;i<=5;i=i+1)
        outputreg_w[i] = outputreg_r[i];
    for(i=0;i<256;i=i+1)
        dictionary_w[i] = dictionary_r[i];
    for(i=0;i<9;i=i+1)
        inBuffer_w[i] = inBuffer_r[i];
    for(j=0;j<5;j=j+1) begin
        for(i=0;i<256;i=i+1) begin
            tmp_table_w[j][i] = tmp_table_r[j][i];
        end
    end

    for(j=0;j<4;j=j+1) begin
        for(i=0;i<256;i=i+1) begin
            table_w[j][i] = table_r[j][i];
            transtable_w[j][i] = table_r[j][i];
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
    end

    case(state_r)
        IDLE: begin
            state_w = INPUT;
        end
        INPUT: begin
            localcount_w = localcount_r + 4;
            inBuffer_w[localcount_r  ] = data[31:24];
            inBuffer_w[localcount_r+1] = data[23:16];
            inBuffer_w[localcount_r+2] = data[15:8];
            inBuffer_w[localcount_r+3] = data[7:0];
            if(localcount_r != 0) begin
                state_w = GENTABLE;
            end
            busy = 0;
        end
        GENTABLE: begin
//          GENERATE DICTIONARY
            dictionary_w[0] = inBuffer_r[0];
            for( i = 1 ; i < 256 ; i = i+1)
                dictionary_w[i] = dictionary_r[i-1];


//      GENTABLE
            for(j=0;j<5;j=j+1) begin
                for(i=0;i<256;i=i+1) begin
                    if(inBuffer_r[4-j]==dictionary_r[i])
                        tmp_table_w[j][i] = 1;
                    else 
                        tmp_table_w[j][i] = 0;
                end
            end

            for(i=0;i<255;i=i+1) begin
                if(tmp_table_r[4][i+1] & tmp_table_r[3][i])
                    table_w[3][i] = 1;
                else
                    table_w[3][i] = 0;
            end
            table_w[3][255] = 0;
            for(i=0;i<254;i=i+1) begin
                if(tmp_table_r[4][i+2] & tmp_table_r[3][i+1] & tmp_table_r[2][i])
                    table_w[2][i] = 1;
                else
                    table_w[2][i] = 0;
            end
            table_w[2][255] = 0;
            table_w[2][254] = 0;
            for(i=0;i<253;i=i+1) begin
                if(tmp_table_r[4][i+3] & tmp_table_r[3][i+2] & tmp_table_r[2][i+1] & tmp_table_r[1][i])
                    table_w[1][i] = 1;
                else
                    table_w[1][i] = 0;
            end
            table_w[2][255] = 0;
            table_w[2][254] = 0;
            table_w[2][253] = 0;

            for(i=0;i<252;i=i+1) begin
                if(tmp_table_r[4][i+3] & tmp_table_r[3][i+2] & tmp_table_r[2][i+1] & tmp_table_r[1][i])
                    table_w[1][i] = 1;
                else
                    table_w[1][i] = 0;
            end
            table_w[1][255] = 0;
            table_w[1][254] = 0;
            table_w[1][253] = 0;
            table_w[1][252] = 0;

            for(i=0;i<251;i=i+1) begin
                if(tmp_table_r[4][i+4] & tmp_table_r[3][i+3] & tmp_table_r[2][i+2] & tmp_table_r[1][i+1] & tmp_table_r[0][i])
                    table_w[0][i] = 1;
                else
                    table_w[0][i] = 0;
            end
            table_w[0][255] = 0;
            table_w[0][254] = 0;
            table_w[0][253] = 0;
            table_w[0][252] = 0;
            table_w[0][251] = 0;
            
            for(j=0;j<4;j=j+1) begin
                for(i=0;i<252;i=i+1) begin
                    case(j)
                        3:begin
                            if(tmp_table_r[4][i+1] & tmp_table_r[3][i])
                                table_w[3][i] = 1;
                            else
                                table_w[3][i] = 0;
                        end
                        2:begin
                            if(tmp_table_r[4][i+2] & tmp_table_r[3][i+1] & tmp_table_r[2][i])
                                table_w[2][i] = 1;
                            else
                                table_w[2][i] = 0;
                        end
                        1:begin
                            if(tmp_table_r[4][i+3] & tmp_table_r[3][i+2] & tmp_table_r[2][i+1] & tmp_table_r[1][i])
                                table_w[1][i] = 1;
                            else
                                table_w[1][i] = 0;
                        end
                        0:begin
                            if(tmp_table_r[4][i+4] & tmp_table_r[3][i+3] & tmp_table_r[2][i+2] & tmp_table_r[1][i+1] & tmp_table_r[0][i])
                                table_w[0][i] = 1;
                            else
                                table_w[0][i] = 0;
                        end
                    endcase
                end
            end


//          TRANSTABLE
            for(j=0;j<4;j=j+1) begin
                transtable_w[j][0] = table_r[j][0];
                transtable_w[j][1] = table_r[j][1] || table_r[j][0];
                for(i=2;i<256;i=i+1) begin
                    // NLINT-W
                    transtable_w[j][i] = table_r[j][i] || transtable_w[j][i-1];
                end
            end

//          SUMTABLE
            for(j=0;j<4;j=j+1) begin
                tableIdx1_w[j] = transtable_r[j][0]
                + transtable_r[j][1]
                + transtable_r[j][2]
                + transtable_r[j][3]
                + transtable_r[j][4]
                + transtable_r[j][5]
                + transtable_r[j][6]
                + transtable_r[j][7]
                + transtable_r[j][8]
                + transtable_r[j][9]
                + transtable_r[j][10]
                + transtable_r[j][11]
                + transtable_r[j][12]
                + transtable_r[j][13]
                + transtable_r[j][14]
                + transtable_r[j][15];
                
                tableIdx2_w[j] = transtable_r[j][16]
                + transtable_r[j][17]
                + transtable_r[j][18]
                + transtable_r[j][19]
                + transtable_r[j][20]
                + transtable_r[j][21]
                + transtable_r[j][22]
                + transtable_r[j][23]
                + transtable_r[j][24]
                + transtable_r[j][25]
                + transtable_r[j][26]
                + transtable_r[j][27]
                + transtable_r[j][28]
                + transtable_r[j][29]
                + transtable_r[j][30]
                + transtable_r[j][31];

                tableIdx3_w[j] = transtable_r[j][32]
                + transtable_r[j][33]
                + transtable_r[j][34]
                + transtable_r[j][35]
                + transtable_r[j][36]
                + transtable_r[j][37]
                + transtable_r[j][38]
                + transtable_r[j][39]
                + transtable_r[j][40]
                + transtable_r[j][41]
                + transtable_r[j][42]
                + transtable_r[j][43]
                + transtable_r[j][44]
                + transtable_r[j][45]
                + transtable_r[j][46]
                + transtable_r[j][47];

                tableIdx4_w[j] = transtable_r[j][48]
                + transtable_r[j][49]
                + transtable_r[j][50]
                + transtable_r[j][51]
                + transtable_r[j][52]
                + transtable_r[j][53]
                + transtable_r[j][54]
                + transtable_r[j][55]
                + transtable_r[j][56]
                + transtable_r[j][57]
                + transtable_r[j][58]
                + transtable_r[j][59]
                + transtable_r[j][60]
                + transtable_r[j][61]
                + transtable_r[j][62]
                + transtable_r[j][63];

                tableIdx5_w[j] = transtable_r[j][64]
                + transtable_r[j][65]
                + transtable_r[j][66]
                + transtable_r[j][67]
                + transtable_r[j][68]
                + transtable_r[j][69]
                + transtable_r[j][70]
                + transtable_r[j][71]
                + transtable_r[j][72]
                + transtable_r[j][73]
                + transtable_r[j][74]
                + transtable_r[j][75]
                + transtable_r[j][76]
                + transtable_r[j][77]
                + transtable_r[j][78]
                + transtable_r[j][79];

                tableIdx6_w[j] = transtable_r[j][80]
                + transtable_r[j][81]
                + transtable_r[j][82]
                + transtable_r[j][83]
                + transtable_r[j][84]
                + transtable_r[j][85]
                + transtable_r[j][86]
                + transtable_r[j][87]
                + transtable_r[j][88]
                + transtable_r[j][89]
                + transtable_r[j][90]
                + transtable_r[j][91]
                + transtable_r[j][92]
                + transtable_r[j][93]
                + transtable_r[j][94]
                + transtable_r[j][95];

                tableIdx7_w[j] = transtable_r[j][96]
                + transtable_r[j][97]
                + transtable_r[j][98]
                + transtable_r[j][99]
                + transtable_r[j][100]
                + transtable_r[j][101]
                + transtable_r[j][102]
                + transtable_r[j][103]
                + transtable_r[j][104]
                + transtable_r[j][105]
                + transtable_r[j][106]
                + transtable_r[j][107]
                + transtable_r[j][108]
                + transtable_r[j][109]
                + transtable_r[j][110]
                + transtable_r[j][111];


                tableIdx8_w[j] = transtable_r[j][112]
                + transtable_r[j][113]
                + transtable_r[j][114]
                + transtable_r[j][115]
                + transtable_r[j][116]
                + transtable_r[j][117]
                + transtable_r[j][118]
                + transtable_r[j][119]
                + transtable_r[j][120]
                + transtable_r[j][121]
                + transtable_r[j][122]
                + transtable_r[j][123]
                + transtable_r[j][124]
                + transtable_r[j][125]
                + transtable_r[j][126]
                + transtable_r[j][127];

                tableIdx9_w[j] = transtable_r[j][128]
                + transtable_r[j][129]
                + transtable_r[j][130]
                + transtable_r[j][131]
                + transtable_r[j][132]
                + transtable_r[j][133]
                + transtable_r[j][134]
                + transtable_r[j][135]
                + transtable_r[j][136]
                + transtable_r[j][137]
                + transtable_r[j][138]
                + transtable_r[j][139]
                + transtable_r[j][140]
                + transtable_r[j][141]
                + transtable_r[j][142]
                + transtable_r[j][143];

                tableIdx10_w[j] = transtable_r[j][144]
                + transtable_r[j][145]
                + transtable_r[j][146]
                + transtable_r[j][147]
                + transtable_r[j][148]
                + transtable_r[j][149]
                + transtable_r[j][150]
                + transtable_r[j][151]
                + transtable_r[j][152]
                + transtable_r[j][153]
                + transtable_r[j][154]
                + transtable_r[j][155]
                + transtable_r[j][156]
                + transtable_r[j][157]
                + transtable_r[j][158]
                + transtable_r[j][159];

                tableIdx11_w[j] = transtable_r[j][160]
                + transtable_r[j][161]
                + transtable_r[j][162]
                + transtable_r[j][163]
                + transtable_r[j][164]
                + transtable_r[j][165]
                + transtable_r[j][166]
                + transtable_r[j][167]
                + transtable_r[j][168]
                + transtable_r[j][169]
                + transtable_r[j][170]
                + transtable_r[j][171]
                + transtable_r[j][172]
                + transtable_r[j][173]
                + transtable_r[j][174]
                + transtable_r[j][175];

                tableIdx12_w[j] = transtable_r[j][176]
                + transtable_r[j][177]
                + transtable_r[j][178]
                + transtable_r[j][179]
                + transtable_r[j][180]
                + transtable_r[j][181]
                + transtable_r[j][182]
                + transtable_r[j][183]
                + transtable_r[j][184]
                + transtable_r[j][185]
                + transtable_r[j][186]
                + transtable_r[j][187]
                + transtable_r[j][188]
                + transtable_r[j][189]
                + transtable_r[j][190]
                + transtable_r[j][191];

                tableIdx13_w[j] = transtable_r[j][192]
                + transtable_r[j][193]
                + transtable_r[j][194]
                + transtable_r[j][195]
                + transtable_r[j][196]
                + transtable_r[j][197]
                + transtable_r[j][198]
                + transtable_r[j][199]
                + transtable_r[j][200]
                + transtable_r[j][201]
                + transtable_r[j][202]
                + transtable_r[j][203]
                + transtable_r[j][204]
                + transtable_r[j][205]
                + transtable_r[j][206]
                + transtable_r[j][207];

                tableIdx14_w[j] = transtable_r[j][208]
                + transtable_r[j][209]
                + transtable_r[j][210]
                + transtable_r[j][211]
                + transtable_r[j][212]
                + transtable_r[j][213]
                + transtable_r[j][214]
                + transtable_r[j][215]
                + transtable_r[j][216]
                + transtable_r[j][217]
                + transtable_r[j][218]
                + transtable_r[j][219]
                + transtable_r[j][220]
                + transtable_r[j][221]
                + transtable_r[j][222]
                + transtable_r[j][223];

                tableIdx15_w[j] = transtable_r[j][224]
                + transtable_r[j][225]
                + transtable_r[j][226]
                + transtable_r[j][227]
                + transtable_r[j][228]
                + transtable_r[j][229]
                + transtable_r[j][230]
                + transtable_r[j][231]
                + transtable_r[j][232]
                + transtable_r[j][233]
                + transtable_r[j][234]
                + transtable_r[j][235]
                + transtable_r[j][236]
                + transtable_r[j][237]
                + transtable_r[j][238]
                + transtable_r[j][239];

                tableIdx16_w[j] = transtable_r[j][240]
                + transtable_r[j][241]
                + transtable_r[j][242]
                + transtable_r[j][243]
                + transtable_r[j][244]
                + transtable_r[j][245]
                + transtable_r[j][246]
                + transtable_r[j][247]
                + transtable_r[j][248]
                + transtable_r[j][249]
                + transtable_r[j][250]
                + transtable_r[j][251]
                + transtable_r[j][252]
                + transtable_r[j][253]
                + transtable_r[j][254]
                + transtable_r[j][255];
            end

//          PIPELINE OF SUMTABLE
            for(j=0;j<4;j=j+1) begin
                temp9bit_1 = tableIdx1_r[j] +
                    tableIdx2_r[j] +
                    tableIdx3_r[j] +
                    tableIdx4_r[j] +
                    tableIdx5_r[j] +
                    tableIdx6_r[j] +
                    tableIdx7_r[j] +
                    tableIdx8_r[j];

                temp9bit_2 = tableIdx9_r[j] +
                    tableIdx10_r[j] +
                    tableIdx11_r[j] +
                    tableIdx12_r[j] +
                    tableIdx13_r[j] +
                    tableIdx14_r[j] +
                    tableIdx15_r[j] +
                    tableIdx16_r[j] ;

                tableIdx_w[j] = temp9bit_1 + temp9bit_2;
            end
            

//          ENCODE
            outputreg_w[0] = {1'd0, inBuffer_r[0], 2'b0};
            outputreg_w[1] = outputreg_r[0];
            outputreg_w[2] = outputreg_r[1];
            outputreg_w[3] = outputreg_r[2];
            outputreg_w[4] = outputreg_r[3];
            outputreg_w[5] = outputreg_r[4];


            if(tableIdx_r[0]!=0) begin
                newCode_w[10] = 1'd1;
                newCode_w[9:2] = 9'd256-tableIdx_r[0];
                newCode_w[1:0] = 2'd3;
//                newCode_w = {1'd1, 8'd256-tableIdx_r[0], 2'd3};
            end
            else if(tableIdx_r[1]!=0) begin
                newCode_w[10] = 1'd1;
                newCode_w[9:2] = 9'd256-tableIdx_r[1];
                newCode_w[1:0] = 2'd2;
//                newCode_w = {1'd1, 8'd256-tableIdx_r[1], 2'd2};
            end
            else if(tableIdx_r[2]!=0) begin
                newCode_w[10] = 1'd1;
                newCode_w[9:2] = 9'd256-tableIdx_r[2];
                newCode_w[1:0] = 2'd1;
//                newCode_w = {1'd1, 8'd256-tableIdx_r[2], 2'd1};
            end
            else if(tableIdx_r[3]!=0) begin
                newCode_w[10] = 1'd1;
                newCode_w[9:2] = 9'd256-tableIdx_r[3];
                newCode_w[1:0] = 2'd0;
//                newCode_w = {1'd1, 8'd256-tableIdx_r[3], 2'd0};
            end
            else begin 
                newCode_w = 11'b0;
            end

//          DECIDE IF MATCH & DELAY
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


//          ENCODEDONE  and  INPUT ANOTHER DATA
            if(drop_done) begin
                busy = 1;
                if(localcount_r<=5) begin
                    if (data_valid) begin // read last set of data
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
                else begin
                    localcount_w = localcount_r - 1;
                    for( i = 0 ; i < 8 ; i=i+1)
                        inBuffer_w[i] = inBuffer_r[i+1];
                    inBuffer_w[8] = 8'b0;
                end
                if (localcount_r==4'hc)
                    state_w = INPUTDONE;
            end
            else begin
                if(localcount_r<=5) begin
                    localcount_w = localcount_r + 3;
                    inBuffer_w[localcount_r-1] = data[31:24];
                    inBuffer_w[localcount_r  ] = data[23:16];
                    inBuffer_w[localcount_r+1] = data[15:8];
                    inBuffer_w[localcount_r+2] = data[7:0];
                    for( i = 0 ; i < 4 ; i=i+1)
                        inBuffer_w[i] = inBuffer_r[i+1];
                    busy = 0;
                end
                else begin
                    localcount_w = localcount_r - 1;
                    for( i = 0 ; i < 8 ; i=i+1)
                        inBuffer_w[i] = inBuffer_r[i+1];
                    inBuffer_w[8] = 8'b0;
                end
            end
        end
        INPUTDONE: begin
            state_w = OUTPUTDONE;
        end
        OUTPUTDONE: begin
            finish = 1;
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
        for(i=0;i<256;i=i+1)
            dictionary_r[i] <= 8'b0;
        for(i=0;i<9;i=i+1)
            inBuffer_r[i] <= 8'b0;
        for(j=0;j<5;j=j+1) begin
            for(i=0;i<256;i=i+1) begin
                tmp_table_r[j][i] <= 0;
            end
        end
        for(j=0;j<4;j=j+1) begin
            for(i=0;i<256;i=i+1) begin
                table_r[j][i] <= 0;
                transtable_r[j][i] <= 0;
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

        end

        for(i=0;i<=5;i=i+1)
            outputreg_r[i] <= 0;
	end
	else begin
        out_valid       <= out_valid_w;
        codeword        <= codeword_w;
		state_r         <= state_w;
        localcount_r    <= localcount_w;
        globalcount_r   <= globalcount_w;
        pause1_r        <= pause1_w;
        pause2_r        <= pause2_w;
        newCode_r       <= newCode_w;
        for(i=0;i<256;i=i+1)
            dictionary_r[i] <= dictionary_w[i];
        for(i=0;i<9;i=i+1)
            inBuffer_r[i] <= inBuffer_w[i];
        for(j=0;j<5;j=j+1) begin
            for(i=0;i<256;i=i+1) begin
                tmp_table_r[j][i] <= tmp_table_w[j][i];
            end
        end

        for(j=0;j<4;j=j+1) begin
            for(i=0;i<256;i=i+1) begin
                table_r[j][i] <= table_w[j][i];
                transtable_r[j][i] <= transtable_w[j][i];
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
        end

        for(i=0;i<=5;i=i+1)
            outputreg_r[i] <= outputreg_w[i];

	end
end


endmodule

