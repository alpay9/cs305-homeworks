%{
#include <stdio.h>
void yyerror(const char *msg){
    return;
}
%}
%token tMAIL tENDMAIL tSCHEDULE tENDSCHEDULE tSEND tSET tTO tFROM tAT tCOMMA tCOLON tLPR tRPR tLBR tRBR tIDENT tSTRING tDATE tTIME tADDRESS
%start program
%%
program:        mail program
            |   set program
            |   ;
mail:           tMAIL tFROM tADDRESS tCOLON statements tENDMAIL
            |   tMAIL tFROM tADDRESS tCOLON tENDMAIL;
schedule:       tSCHEDULE tAT tLBR tDATE tCOMMA tTIME tRBR tCOLON statements tENDSCHEDULE;
statements:     statement
            |   statement statements;
statement:      set
            |   send
            |   schedule;
set:            tSET tIDENT tLPR tSTRING tRPR;
send:           tSEND tLBR tSTRING tRBR tTO tLBR recipient_list tRBR
            |   tSEND tLBR tIDENT tRBR tTO tLBR recipient_list tRBR;
recipient_list: recipient
            |   recipient tCOMMA recipient_list;
recipient:      tLPR tADDRESS tRPR
            |   tLPR tSTRING tCOMMA tADDRESS tRPR
            |   tLPR tIDENT tCOMMA tADDRESS tRPR;

%%

int main ()
{
    if (yyparse()){
        // parse error
        printf("ERROR\n");
        return 1;
    } else{
        // successful parsing
        printf("OK\n");
        return 0;
    }
}