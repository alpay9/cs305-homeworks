%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "alpay.nacar-hw3.h"

void yyerror (const char *msg) /* Called by yyparse on error */ {return; }
int error = 0;
char ** errors;
int errorTypes[100] = {0};
int ** errorsIdx;
int errorSize = 100;
int errorIndex = 0;

char** dateErrorsChar;
int** dateErrorsIdx;


VarNode ** vars;
int varsSize = 100;
int varsIndex = 0;

void addError(int lineNum, char* id, int type);
int checkVar(IdentNode* ident);
%}

%union {
  IdentNode* identNode;
  StringNode* stringNode;
  VarNode* varNode;
  OptionNode* optionNode;
  RecipientNode* recipientNode;
  RecipientListNode* recipientListNode;
  MailNode* mailNode;
  DateNode* dateNode;
  TimeNode* timeNode;
}

%token tMAIL tENDMAIL tSCHEDULE tENDSCHEDULE tSEND tTO tFROM tCOMMA tCOLON tLPR tRPR tLBR tRBR tAT tSET
%token <identNode> tIDENT
%token <stringNode> tSTRING
%token <mailNode> tADDRESS
%token <dateNode> tDATE
%token <timeNode> tTIME
%type <stringNode> setStatement
%type <optionNode> option
%type <recipientNode> recipient
%type <recipientListNode> recipientList
%start program
%%

program : statements
;

statements : 
            | setStatement statements
            | mailBlock statements
;

mailBlock : tMAIL tFROM tADDRESS tCOLON statementList tENDMAIL{
  // end of mailBlock, release variables that scopes ending
  for(; varsIndex>0;){
    if(vars[varsIndex-1]->scopeLevel > 0){
      //printf("scope ended %s\n", vars[varsIndex-1]->identifier);
      free(vars[--varsIndex]);
    } else {
      break;
    }
  }
}
;

statementList : 
                | setStatement statementList
                | sendStatement statementList
                | scheduleStatement statementList
;

sendStatements : sendStatement
                | sendStatement sendStatements 
;

sendStatement : tSEND tLBR option tRBR tTO tLBR recipientList tRBR{
  if($3->value != NULL){
    //printf("sendO %s\n", $3->value);
  } else{
    //printf("sendX skipped option not valid\n");
  }
}
;

option: tSTRING{
  $$->value = $1->value;
} | tIDENT{
  //char *result = (char *)malloc(strlen(yytext));
  //$$ = (struct StringNode*)malloc(sizeof(struct StringNode));
  int idx = checkVar($1);
  if(idx == -1){
    //printf("ERROR at line %d: %s is undefined\n", $1->lineNum, $1->value);
    addError($1->lineNum, $1->value, 1);
    $$->value = NULL;
  }
  //$$->value = strcpy(vars[idx]);
  //$$->lineNum = $1->lineNum;
}
;


recipientList : recipient{
  $$->size = 1;
  $$->names = (char**)malloc(sizeof(char*));
  $$->names[0] = (char*)malloc(strlen($1->name));
  $$->names[0] = $1->name;
}
            | recipient tCOMMA recipientList{
  $$->size = $3->size + 1;
  $$->names = realloc($3->names, $$->size);
}
;

recipient : tLPR tADDRESS tRPR{
  $$->mail = $2->mail;
  $$->name = $2->mail;
}
            | tLPR tSTRING tCOMMA tADDRESS tRPR{
  $$->mail = $4->mail;
  $$->name = $2->value;
}
            | tLPR tIDENT tCOMMA tADDRESS tRPR{
  //$$ = (struct recipientNode*)malloc(sizeof(struct recipientNode));
  int idx = checkVar($2);
  if(idx == -1){
    addError($2->lineNum, $2->value, 1);
    $$->mail = NULL;
    $$->name = NULL;
  } else{
    $$->mail = $4->mail;
    $$->name = vars[idx]->value;
  }
}
;

scheduleStatement : tSCHEDULE tAT tLBR date tCOMMA time tRBR tCOLON sendStatements tENDSCHEDULE
;

time : tTIME{
  if(isValidTime($1->time) == 0){
    addError($1->lineNum, $1->time, 2);
  } else {
    
  }
}

date : tDATE{
  if(isValidDate($1->date) == 0){
    addError($1->lineNum, $1->date, 0);
  } else {
    
  }
}


setStatement : tSET tIDENT tLPR tSTRING tRPR {
  // set var
  if(varsIndex >= varsSize){
    varsSize = varsSize + varsSize;
    vars = realloc(vars, varsSize);
  }
  vars[varsIndex] = (struct VarNode*) malloc(sizeof(struct VarNode));
  vars[varsIndex]->identifier = $2->value;
  vars[varsIndex]->value = $4->value;
  varsIndex++;
  //printf("set %s to %s\n", $2->value, $4->value);
}
;


%%

void addError(int lineNum, char* id, int errorType){
  if(errorType == 1){
    errors[errorIndex] = (char*)malloc(strlen("ERROR at line :  is undefined\n")+strlen(id)+3);
    sprintf(errors[errorIndex++], "ERROR at line %d: %s is undefined\n", lineNum, id);
    error++;
  } else if(errorType == 0){ // date
    errors[errorIndex] = (char*)malloc(strlen("ERROR at line : date object is not correct ()\n")+strlen(id)+3);
    sprintf(errors[errorIndex++], "ERROR at line %d: date object is not correct (%s)\n", lineNum, id);
    error++;
  } else if(errorType == 2) { // time
    errors[errorIndex] = (char*)malloc(strlen("ERROR at line : date object is not correct ()\n")+strlen(id)+3);
    sprintf(errors[errorIndex++], "ERROR at line %d: time object is not correct (%s)\n", lineNum, id);
    error++;
  }
  
}

int checkVar(IdentNode* ident){
  // -1 -> not found
  // index from 0 to n -> found
  int i = varsIndex-1;
  //printf("inside check var %d\n", i);
  for(i=varsIndex-1; i>=0; i--){
    //printf("va");
    if(strcmp(ident->value, vars[i]->identifier) == 0 ){
      //printf("rs\n");
      return i;
    }
    //printf("rs\n");
  }
  return -1;
}

int isValidDate(const char *date) {
    int day, month, year;
    if (sscanf(date, "%d/%d/%d", &day, &month, &year) == 3 ||
        sscanf(date, "%d.%d.%d", &day, &month, &year) == 3 ||
        sscanf(date, "%d-%d-%d", &day, &month, &year) == 3) {
        if (year >= 1000 && year <= 9999 && month >= 1 && month <= 12) {
            int daysInMonth;
            switch (month) {
            case 1: case 3: case 5: case 7: case 8: case 10: case 12:
                daysInMonth = 31;
                break;
            case 4: case 6: case 9: case 11:
                daysInMonth = 30;
                break;
            case 2:
                if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                    daysInMonth = 29;
                } else {
                    daysInMonth = 28;
                }
                break;
            default:
                return 0;
            }
            return (day >= 1 && day <= daysInMonth);
        }
    }
    return 0;
}

int isValidTime(const char *timeString) {
    if (timeString == NULL) {
        return 0;
    }
    int hours, minutes;
    if (sscanf(timeString, "%d:%d", &hours, &minutes) != 2) {
        return 0;
    }
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
        return 0;
    }
    return 1;
}

int main () 
{
  vars = (struct VarNode**)malloc(varsSize * sizeof(struct VarNode*));
  errors = (char**)malloc(errorSize * sizeof(char*));

  if (yyparse()) {
    printf("ERROR\n");
    return 1;
  }

  if(error > 0){
    int i;
    for(i=0; i<errorIndex; i++){
      printf(errors[i]);
    }

    return 0;
  }
  //sort mails

  /*int i = 0;
  for(;i<mailsIdx;i++){
    //printf("Expression first defined at line %d with identifier %s with value %d\n", expressions[i]->lineNum, expressions[i]->identifier, expressions[i]->value );
    //printf("mail sent\n");
  }*/

  return 0;
}