{
*                 CS0400  DATA STRUCTURE AND ALGORITHM
*                           ASSIGNMENT ONE
*
* Date written : 25 Feburary, 1987
}
program InfixToPostfix(input,output);
{
   This program converts an arithmatic expression written in infix
   notation to its postfix notation equivalent.
}
type
    chararray = array [0..70] of char;
    nodeptr = ^treerec;
    treerec = record
                 data        : char;    {information stored in node}
                 rlink,llink : nodeptr; {pointers to left and right sons}
                 father      : nodeptr; {pointer to this node's immediate father}
                 processed   : boolean  {flag indicating whether this node has been printed out}
              end;
var
    operator             : set of char;
    promax, numofpos     : integer;     {number of characters in infix expression and postfix expression}
    infix, posfix        : chararray;   {array holding infix expression and postfix expression}
    node                 : nodeptr;     {individual nodes of the binary tree}
    cur_father, fix_root : nodeptr;     {external pointers}
    i                    : integer;     {for-loop index}

procedure readinfix;
var
    indata : char;                      {individual character inputed thru the keyboard}
begin {proc. readinfix}
    infix[0] := '[';                    {start-of-expression indicator}
        promax := 0;
        write('? ');
        read(kbd, indata);              {reading the infix expression from keyboard}
        while (indata <> #13) and (promax < 80) do
        begin
            promax := promax + 1;
            infix [ promax ] := indata;
            write( infix [ promax ] );  {echo print the input}
            read( kbd, indata)
        end;
        writeln;
    infix [ promax + 1 ] := ']'         {end-of-expression indicator}
end;  {proc. readinfix}

procedure postfix;
{converting the infix form expression to its postfix form}
var
    k, m  : integer;       {array indexes}
    stack : chararray;     {stack holding operators}
function priority ( q : chararray; v : integer ) : integer;
{check the priority of the operator}
begin
    case q [ v ] of
        '+', '-' : priority := 1;
        '*', '/' : priority := 2;
        '[', '(' : priority := 0
    end
end;  {fct. priority}
procedure push ( var st, inf : chararray; var sp, e : integer );
{push the operator into stack}
begin
    sp := sp + 1;
    st [sp] := inf [e];
end;  {proc. push}
procedure pop_output (var po, st : chararray; var c, sp : integer);
{pop out top element of operator stack and store it in postfix}
begin
    c := c + 1;
    po[c] := st[sp];
    sp := sp - 1
end;  {proc. pop_output}
begin {proc. postfix}
    numofpos := 0;
    m := 0;
    for k := 0 to promax+1 do
    case infix[k] of
        'A'..'Z','a'..'z':begin
                              numofpos := numofpos + 1;
                              posfix[numofpos] := infix[k]
                          end;
                 '[', '(':push(stack, infix, m, k);
                      ')':begin
                              while stack[m] <> '(' do            {unstack untill '(' is met}
                              pop_output (posfix, stack, numofpos, m);
                              m := m - 1                          {pop out '('}
                          end;
                      ']':while stack[m] <> '[' do                {unstack the whole stack}
                          pop_output (posfix, stack, numofpos, m);
          '+','-','*','/':if priority (infix, k) <= priority (stack, m) then
                          begin
                              pop_output (posfix, stack, numofpos, m);
                              push (stack, infix, m, k)
                          end
                          else
                          push (stack, infix, m, k)
    end; {case statement}
end;  {proc. postfix}

procedure buildtree(var node : nodeptr);
{building the tree from the postfix expression generated}
begin
    new(node);                           {creat a new node and set the necessary fields}
    with node^ do
    begin
        data := posfix[numofpos];
        processed := false;
        father := cur_father             {this node's father is cur_father}
    end;
    if posfix[numofpos] in operator then
    begin                                {posfi is an operator,build sons}
        cur_father := node;              {move current father to this node}
        numofpos := numofpos - 1;
        buildtree (node^.llink);         {build left son of current father}
        numofpos := numofpos - 1;
        buildtree (node^.rlink);         {build right son of current father}
        cur_father := cur_father^.father {both sons built: current father climbs up one level}
    end
    else                                 {posfix is an operand, node has no son}
    begin
        node^.rlink := nil;
        node^.llink := nil;
    end
end;  {proc. buildtree}

procedure printtree;
{print out the binary tree representation of the postfix expression}
var
    level : integer;      {level cur_father currently in}
    p     : nodeptr;      {pointer to rightmost son of root}
begin
    cur_father := fix_root;
    p := fix_root;
    level := 0;
    while p^.rlink <> nil do                    {move p to rightmost son}
    p := p^.rlink;
    repeat
        while (cur_father^.llink <> nil) and (not cur_father^.llink^.processed) do
        begin
            cur_father := cur_father^.llink;    {processing left sons of cur_father}
            level := level + 1
        end;  {while loop}
        if not cur_father^.processed then
        begin
            if level > 0 then                   {set spacing}
            for i := 1 to level*4 do
            write (' ');
            writeln (cur_father^.data : 50);    {process  cur_father}
            cur_father^.processed := true
        end;  {if..then}
        if (cur_father^.rlink <> nil) and (not cur_father^.rlink^.processed) then
        begin
            cur_father := cur_father^.rlink;    {process right subtree}
            level := level+1
        end
        else {left and right sons of cur_father are processed;climbs up one level}
        begin
            cur_father := cur_father^.father;
            level := level-1
        end  {if..then..else}
    until p^.processed                          {rightmost son is processed}
end;  {proc. printtree}

procedure intra2;
(* procedure to traverse the binary tree using 2 external pointers *)
var
    p, q  : nodeptr;
    level : integer;
begin
  q := nil;
  p := fix_root;
  level := 0;
  for i := 1 to 70 do
  write('=');
  writeln;
  repeat
      while p <> nil do
        begin
          q := p;
          p := p^.llink;
          level := level + 1;
        end; {while..do}
      if q <> nil then
      begin
        writeln(q^.data : 30 - level * 3);
        p := q^.rlink;
      end; {if..then}
      while (q <> nil) and (p = nil) do
      begin
        repeat
          p := q;
          q := q^.father;
          level := level - 1;
        until (q^.llink = p) or (q = nil);
        if q <> nil then
        begin
          writeln(q^.data : 30 - level * 3);
          p := q^.rlink;
        end; {inner if..then}
      end; {while..do}
   until q = nil;
end; {proc. intra2}


procedure result;
{print out the infix and postfix expression}
begin
    writeln;
    writeln ('INPUT EXPRESSION','OUTPUT EXPRESSION':27,'CORRESPONDING TREE':21);
    for i := 1 to promax do
    write (infix[i]);
    for i := 1 to 26-promax do
    write (' ');
    for i := 1 to numofpos do
    write (posfix[i]);
    writeln
end;  {proc. result}

procedure ptree (p : nodeptr);
(* procedure to reproduce tghe infix expression from the tree *)
begin
    if p<>nil then
    begin
        ptree (p^.llink);
        if (p^.father^.llink = p) and (not (p^.data in operator)) then
        write ('(');
        write (p^.data);
        ptree (p^.rlink);
        if (not (p^.data in operator)) and (p^.father^.rlink = p) then
        write (')');
    end;
end;  {proc. ptree}

procedure swaptree (var q : nodeptr);
(* procedure to rotate swap all left subtrees and right subtrees of the expression tree *)
procedure swap (var a, b : nodeptr);
var
    r : nodeptr;
begin
    r := a;
    a := b;
    b := r
end; {proc. swap}
begin {proc. swaptree}
    if q <> nil then
    begin
        swaptree (q^.llink);
        swap (q^.llink, q^.rlink);
        swaptree (q^.llink)
    end;
end; {proc. swaptree}

begin {main}
    operator := ['+','-','*','/'];
    writeln ('**  Input the infix form expression and press return.');
    readinfix;
    postfix;
    result;
    buildtree (fix_root);
    printtree;
    cur_father := fix_root;
    ptree (cur_father);
    writeln;
    cur_father := fix_root;
    swaptree (cur_father);
    cur_father := fix_root;
    ptree (cur_father);
    writeln;
    fix_root^.father := nil;
    intra2;
end.  {main}