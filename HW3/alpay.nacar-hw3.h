#ifndef __AN_HW3_H
#define __AN_HW3_H

typedef struct IdentNode{
    char *value;
    int lineNum;
} IdentNode;

typedef struct StringNode{
    char *value;
    int lineNum;
} StringNode;

typedef struct VarNode{
    char *identifier;
    char *value;
    int scopeLevel;
} VarNode;

typedef struct OptionNode{
    char* value;
} OptionNode;

typedef struct RecipientNode{
    char* name;
    char* mail;
} RecipientNode;

typedef struct RecipientListNode{
    char** names;
    int size;
} RecipientListNode;

typedef struct MailNode{
    char* mail;
} MailNode;

typedef struct DateNode{
    char* date;
    int lineNum;
} DateNode;

typedef struct TimeNode{
    char* time;
    int lineNum;
} TimeNode;


#endif
