{
*                 CS0400  DATA STRUCTURE AND ALGORITHM
*                           ASSIGNMENT ONE
*
*  Lecturer & Tutor: Miss Y.L.Wong
*  Course          : PDCS-1
*  Group           : 2
*  Student name    : Chang Man Wai
*  Student number  : 86xxxxxx
}
program InfixToPostfix(input,output);
{
   This program converts an arithmatic expression written in infix
   notation to its postfix notation equivalent.
}
type
    chararray=array [0..70] of char;
    nodeptr=^treerec;
    treerec=record
              data:char;           {information stored in node}
              rlink,llink:nodeptr; {pointers to left and right sons}
              father:nodeptr;      {pointer to this node's immediate father}
              processed:boolean    {flag indicating whether this node has been printed out}
            end;
var
    promax:integer;              {number of characters in infix expression}
    numofpos,numpos:integer;     {number of characters in postfix expression}
    infix:chararray;             {array holding infix expression}
    posfix:chararray;            {array holding postfix expression}
    operand,operator,delimiter,dataset:set of char;
    node:nodeptr;                {individual nodes of the binary tree}
    cur_father,fix_root:nodeptr; {external pointers}
    i:integer;                   {for-loop index}

procedure instructions;
begin
    writeln('**  Program converting an arithmatic expression written');
    writeln('**  in infix notation to its postfix notation equivalent.');
    writeln('**  Operands:   lower-case and upper-case alphabets.');
    writeln('**  Operators:  +,-,*,/ .');
    writeln('**  Delimiters: (,) .');
    writeln('**  Unary operation not allowed.');
    writeln('**  Input the infix form expression and press return.')
end;  {proc. instructions}

procedure readinfix;
var
    validdata:boolean;    {check if data is in the pre-defined data set}
    xcessbracket:integer; {check sequency and number of bracket check}
    check:integer;        {expression syntax check}
    indata:char;          {individual character inputed thru the keyboard}
procedure datavalidation(inf:chararray;w:integer);
begin
    case inf[w] of
     'A'..'Z','a'..'z':check:=check+1;
       '+','-','*','/':check:=check-1;
                   '(':xcessbracket:=xcessbracket+1;
                   ')':xcessbracket:=xcessbracket-1
    end; {case statement}
    if inf[w] in dataset then
    validdata:=true;                 {check if the input data is valid character}
    if ((inf[w] in operand)and(inf[w-1] in operand))or
       ((inf[w]='(')and(not((inf[w-1] in operator))and(inf[w-1]<>'('))) then
    validdata:=false;                {check if operands stick together or invalid sequency of brackets}
    if (not validdata)or(xcessbracket=-1) then
    check:=check+100;
    validdata:=false
end;  {proc. datavalidation}
begin {proc. readinfix}
    validdata:=false;
    check:=0;
    xcessbracket:=0;
    infix[0]:='[';                  {start-of-expression indicator}
    while check<>1 do
    begin
        promax:=0;
        write('? ');
        read(kbd,indata);           {reading the infix expression from keyboard}
        while (indata<>#13)and(promax<80) do
        begin
            promax:=promax+1;
            infix[promax]:=indata;
            write(infix[promax]);   {echo print the input}
            datavalidation(infix,promax);
            read(kbd,indata)
        end;
        writeln;
        if xcessbracket<>0 then     {number of open and close brackets does not match}
        check:=check+100;
        if check<>1 then      {error found. write out error message}
        begin
            check:=0;
            xcessbracket:=0;
            writeln('**  Invalid symbol(s)/expression. Retry!')
        end  {if-then loop}
    end; {while loop}
    infix[promax+1]:=']'       {end-of-expression indicator}
end;  {proc. readinfix}

procedure postfix;
{converting the infix form expression to its postfix form}
var
    k,m:integer;         {array indexes}
    stack:chararray;     {stack holding operators}
function priority(q:chararray;v:integer):integer;
{check the priority of the operator}
begin
    case q[v] of
        '+','-':priority:=1;
        '*','/':priority:=2;
        '[','(':priority:=0
    end
end;  {fct. priority}
procedure out(var po:chararray;inf:chararray;var c,e:integer);
{store the charcter in the postfix}
begin
    c:=c+1;
    po[c]:=inf[e]
end;  {proc. out}
procedure push(var st,inf:chararray;var sp,e:integer);
{push the operator into stack}
begin
    sp:=sp+1;
    st[sp]:=inf[e];
end;  {proc. push}
procedure pop_output(var po,st:chararray;var c,sp:integer);
{pop out top element of operator stack and store it in postfix}
begin
    c:=c+1;
    po[c]:=st[sp];
    sp:=sp-1
end;  {proc. pop_output}
begin {proc. postfix}
    numofpos:=0;
    m:=0;
    for k:=0 to promax+1 do
    case infix[k] of
        'A'..'Z','a'..'z':out(posfix,infix,numofpos,k);
                 '[', '(':push(stack,infix,m,k);
                      ')':begin
                              while stack[m]<>'(' do           {unstack untill '(' is met}
                              pop_output(posfix,stack,numofpos,m);
                              m:=m-1                           {pop out '('}
                          end;
                      ']':while stack[m]<>'[' do               {unstack the whole stack}
                          pop_output(posfix,stack,numofpos,m);
          '+','-','*','/':if priority(infix,k)<=priority(stack,m) then
                          begin
                              pop_output(posfix,stack,numofpos,m);
                              push(stack,infix,m,k)
                          end
                          else
                          push(stack,infix,m,k)
    end; {case statement}
    numpos:=numofpos         {saving a copy of the numofpos: the value numpos will be}
end;  {proc. postfix}        {used to determine the position of the root}

procedure buildtree(var node:nodeptr);
{building the tree from the postfix expression generated}
begin
    new(node);                     {creat a new node and set the necessary fields}
    with node^ do
    begin
        data:=posfix[numofpos];
        processed:=false;
        father:=cur_father          {this node's father is cur_father}
    end;
    if numofpos=numpos then         {saving a pointer to the root of the binary tree}
    fix_root:=node;
    if posfix[numofpos] in operator then
    begin                               {posfix is an operator,build sons}
        cur_father:=node;               {move current father to this node}
        numofpos:=numofpos-1;
        buildtree(node^.llink);         {build left son of current father}
        numofpos:=numofpos-1;
        buildtree(node^.rlink);         {build right son of current father}
        cur_father:=cur_father^.father  {both sons built: current father climbs up one level}
    end
    else{posfix is an operand, node has no son}
    begin
        node^.rlink:=nil;
        node^.llink:=nil;
    end
end;  {proc. buildtree}

procedure printtree;
{print out the binary tree representation of the postfix expression}
var
    level:integer;  {level cur_father currently in}
    p:nodeptr;      {pointer to rightmost son of root}
begin
    cur_father:=fix_root;
    p:=fix_root;
    level:=0;
    while p^.rlink<>nil do   {move p to rightmost son}
    p:=p^.rlink;
    repeat
        while (cur_father^.llink<>nil)and(not cur_father^.llink^.processed) do
        begin
            cur_father:=cur_father^.llink;    {processing left sons of cur_father}
            level:=level+1
        end;  {while loop}
        if not cur_father^.processed then
        begin
            if level>0 then                    {set spacing}
            for i:=1 to level*4 do
            write(' ');
            writeln(cur_father^.data:50);      {process  cur_father}
            cur_father^.processed:=true
        end;  {if..then}
        if (cur_father^.rlink<>nil)and(not cur_father^.rlink^.processed) then
        begin
            cur_father:=cur_father^.rlink;     {process right subtree}
            level:=level+1
        end
        else {left and right sons of cur_father are processed;climbs up one level}
        begin
            cur_father:=cur_father^.father;
            level:=level-1
        end  {if..then..else}
    until p^.processed              {rightmost son is processed}
end;  {proc. printtree}

procedure result;
{print out the infix and postfix expression}
begin
    writeln;
    writeln('INPUT EXPRESSION','OUTPUT EXPRESSION':27,'CORRESPONDING TREE':21);
    for i:=1 to promax do
    write(infix[i]);
    for i:=1 to 26-promax do
    write(' ');
    for i:=1 to numofpos do
    write(posfix[i]);
    writeln
end;  {proc. result}

begin {main}
    operand:=['a'..'z','A'..'Z'];
    operator:=['+','-','*','/'];
    delimiter:=[')','('];
    dataset:=operand+operator+delimiter;  {the valid set of characters}
    instructions;
    readinfix;
    postfix;
    result;
    buildtree(node);
    printtree
end.  {main}