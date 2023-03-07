{$P512}
{
*
*   CS0400 DATA STRUCTURE AND ALGORITHMS
*            ASSIGNMENT TWO
*
* Date written : 25 March, 1987
}

program Sorting(output);
{ Program to compare the efficiencies of three sorting algorithms: Insertion, Quick and Heap Sort. }
const
    maxsize = 500;                    {maximum size of array}
type
    numarray =  array [1..maxsize] of integer;
    timearray = array [1..10] of real;
var
    rndnum :               numarray;  {array holding random numbers: }
                                      {the sorting algorithms use same set of random number to aid comparison}
    posinteger :           numarray;  {array holding integers}
    i,j,k :                integer;   {for loop indices}
    select :               integer;   {tag to select among the 3 sets of data}
    max :                  integer;   {length of input sequency}
    sorttime :             timearray; {array holding sorting time for the three sortine algorithms}
    ti :                   integer;   {array index for sorttime}
    starttime,finishtime : real;      {variables to store time}

procedure Instructions;
begin
    writeln('**  This program compares the efficiency of three sorting');
    writeln('**  algorithms in terms of time:');
    writeln('**       . Insertion Sort');
    writeln('**       . Quick Sort');
    writeln('**       . Heap Sort');
    writeln('**  The following 3 sets of data will be used:');
    writeln('**       . a set of positive integers which has been sorted');
    writeln('**         in increasing order');
    writeln('**       . a set of random positive integer');
    writeln('**       . a set of positive integers which has been sorted');
    writeln('**         in decreasing order');
    writeln('**  Two lengths of input sequency will be sorted:');
    writeln('**       . 64');
    writeln('**       . 256');
end;  {proc. Instructions}

procedure Timer(var nn : real);
{procedure to obtain system time}
type
    RegPack = record
                AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags : integer
              end;
var
    regs :              RegPack;
    hour,min,sec,frac : integer;
begin
    with regs do
    begin
        AX := $2C00;
        MsDos(Regs);
        hour := hi(CX);
        min  := lo(CX);
        sec  := hi(DX);
        frac := lo(DX);
        nn := (min * 60 + sec + frac / 100) * 1000;  {expressing time in milliseconds}
    end; {with..do}
end;  {proc. Timer}

procedure InsertionSort(b : integer);
{sorting numbers to its ascending order by insertion sort}
var
    key : integer;      {key for comparison}
    i,j : integer;      {counters}
begin
    Timer(starttime);
    for i := 2 to b do
    begin
        j := i-1;
        key := posinteger[i];                       {pick up the key}
        while (key < posinteger[j]) and (j > 0) do  {find final position for key}
        begin                                       {scaning from leftmost position}
            posinteger[j+1] := posinteger[j];
            j := j - 1;
        end; {while..do}
        posinteger[j + 1] := key;                   {insert the key}
    end;
    Timer(finishtime);
end;  {proc. InsertionSort}

procedure QuickSort(aaa : integer);
{sorting integers to its ascending order by quick sort}

    procedure Qsort(p,r : integer);
    var
        pivot : integer;    {pivot of partition}
        i,j :   integer;    {counters(scanning variables)}
        w :     integer;    {for exchanging two numbers}
    begin
        i := p;
        j := r;
        pivot := posinteger[((p + r) div 2)];{choosing pivot}
        repeat
            while posinteger[i] < pivot do   {scan from left end searching for item larger than pivot}
            i := i + 1;
            while pivot < posinteger[j] do   {scan from right end searching for item smaller than pivot}
            j := j - 1;
            if i <= j then                   {if found, exchange them}
            begin
                w := posinteger[i];
                posinteger[i] := posinteger[j];
                posinteger[j] := w;
                i := i + 1;
                j := j - 1;
            end; {if..then}
        until i > j;                  {the scanners meet around the middle}
        if p < j then
        Qsort(p,j);                   {sort left partition}
        if i < r then
        Qsort(i,r);                   {sort right partition}
    end; {proc. Qsort}

begin {proc. QuickSort}
    Timer(starttime);
    Qsort(1,aaa);
    Timer(finishtime)
end;  {proc. QuickSort}

procedure HeapSort(size : integer);
{sorting integers to its ascending order by heap sort}
var
    lson,rson : integer;
    father :    integer;

    procedure sift;
    label   13;
    var
        i,j : integer;   {floating pointers to indicate current father and son}
        loop : boolean;
    begin
        i := lson;
        j := 2 * i;
        father := posinteger[i];
        loop := true;
        while (j <= rson) and loop do
        begin
            if j < rson then
            if posinteger[j] < posinteger[j+1] then  {compare left and right son}
            j := j + 1;
            if father >= posinteger[j] then          {if father >= larger son then save back value of father in the heap}
            loop := false
            else
            begin
            posinteger[i] := posinteger[j];          {if not, copy value of larger son to current father array}
            i := j;                                  {move father to point to that node}
            j := 2 * i                               {sort with the left son of that node}
            end
        end; {while..do}
        posinteger[i] := father;
    end; {proc. sift}

begin {proc. HeapSort}
    Timer(starttime);
    lson := (size div 2) + 1;               {setting up limit of sorting}
    rson := size;
    while lson > 1 do                       {build initial heap}
    begin                                   {with father equal to larger son at least}
        lson := lson - 1;
        sift;
    end; {while..do}
    while rson > 1 do                       {actual sorting routine}
    begin
        father := posinteger[1];            {pick up top of heap as father}
        posinteger[1] := posinteger[rson];  {move last son to top of heap}
        posinteger[rson] := father;         {move father (largest of current heap) to last son's position}
        rson := rson - 1;                   {sort with second last item}
        sift;
    end; {while..do}
    Timer(finishtime);
end;  {proc. HeapSort}

procedure GenRndNumbers(m : integer);
{procedure to generate an array of random numbers}
begin
    Randomize;
    for i := 1 to m do
    rndnum[i] := random(m);
end; {proc. GenRndNumbers}

procedure InitArray(dataset,maxi : integer);
{procedure to initialize the array to be sorted}
begin
    case dataset of
       1 : for i := 1 to maxi do       {set of numbers in increasing order}
           posinteger[i] := i;
       2 : for i := 1 to maxi do       {set of random numbers}
           posinteger[i] := rndnum[i];
       3 : for i:= maxi downto 1 do    {set of numbers in decreasing order}
           posinteger[maxi-i+1] := i;
    end; {case..of}
end;  {proc. InitArray}

procedure CalcSortTime(start,finish : real);
{procedure to obtain the time required by each sorting algorithm}
begin
    sorttime[ti] := finish - start;
    ti := ti + 1;
end; {proc. CalcSortTIme}

procedure SortArray(SortAlgo,aa:integer);
{procedure to call a sorting procedure to sort the 3 sets of arrays}
begin
    for select := 1 to 3 do
    begin
        InitArray(select,aa);
        case SortAlgo of
            1 : InsertionSort(aa);
            2 : QuickSort(aa);
            3 : HeapSort(aa)
        end; {case..of}
        CalcSortTime(starttime,finishtime);
    end; {for..do}
end; {proc. SortArray}

procedure Report(num : integer);
{procedure to generate the report on the efficiencies of the sorting algorithms}
type
    titlerec = record
                 title : array [1..14] of char;
               end;
var
    t :     array [1..3] of titlerec; {array holding name of sorting algorithm in table}
    index : integer;
begin
    ti := 1;
    GenRndNumbers(num);
    for k := 1 to 3 do
    SortArray(k,num);
    t[1].title := 'INSERTION SORT';
    t[2].title := 'QUICK SORT    ';
    t[3].title := 'HEAP SORT     ';
    writeln;
    writeln('________________________________ Array Size ':43,num:3,' _______________________________');
    writeln;
    writeln('Sorting Time in milliseconds':61);
    writeln('.............. for sorting set of numbers in ..............':77);
    writeln('Sorting  ');
    writeln('Algorithm','Increasing Order':25,'Random Order':20,'Decreasing Order':23);
    writeln;
    for i := 1 to 3 do
    begin
        write(t[i].title);
        for j := 1 to 3 do
        begin
            index := (i-1)*3+(j-1)+1;   {calculate the position of linear array sorttime[i] in the table}
            write(sorttime[index]:18:0);
        end; {inner for..do}
        writeln;
    end; {outer for..do}
    writeln;
end; {proc. Report}

begin {main}
    Instructions;
    Report(64);
    Report(256);
end.  {main}