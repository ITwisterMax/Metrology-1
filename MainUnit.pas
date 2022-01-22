unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids;

type
  TAnalizator = class(TForm)
    Load_: TButton;
    StartWork_: TButton;
    Exit_: TButton;
    Table_: TStringGrid;
    ProgramText_: TRichEdit;
    DlgOpen_: TOpenDialog;
    ResultText_: TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure Exit_Click(Sender: TObject);
    procedure Load_Click(Sender: TObject);
    procedure StartWork_Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Analizator: TAnalizator;

implementation

{$R *.dfm}

procedure TAnalizator.FormCreate(Sender: TObject);
begin
  Table_.Cells[0, 0] := '       i';
  Table_.Cells[1, 0] := '   Оператор';
  Table_.Cells[2, 0] := '      f1';
  Table_.Cells[3, 0] := '       j';
  Table_.Cells[4, 0] := '    Операнд';
  Table_.Cells[5, 0] := '      f2';
end;

procedure TAnalizator.Load_Click(Sender: TObject);
var
  i, j : integer;

begin
  if DlgOpen_.Execute(Handle) then
    begin
      ProgramText_.Lines.LoadFromFile(DlgOpen_.FileName);
      for j := 1 to Table_.RowCount do
        for i := 0 to Table_.ColCount do
          Table_.Cells[i, j] := '';

      Analizator.ResultText_.Lines[1] := '';
      Analizator.ResultText_.Lines[3] := '';
      Analizator.ResultText_.Lines[5] := '';
    end
  else
    exit;
end;

procedure Analyze;
const
  N_MAX = 145;

type
  TArrayType = record
    Name : string;
    Count : integer;
  end;

  TRecFunc = record
    Name : string;
    FuncCount : byte;
  end;

  TRecOperand = record
    Name : string;
    OperCount : integer;
  end;

  TArray = array [1..N_MAX] of TArrayType;
  TFuncArray = array [1..N_MAX] of TRecFunc;
  TOperArray = array [1..N_MAX] of TRecOperand;

var
  FuncArr : TFuncArray;
  OperArr : TOperArray;
  Counters : TArray;
  buf, TempStr, bufFunc : string;
  i, j, CurrNumFunc, CurrNumOper, N: integer;
  IsFound, IsOperatorOrFunc : boolean;
  F : TextFile;

procedure WriteResults(const N1 : integer; const N2 : integer; const N3 : integer);
var
  i, j, num1, num2, number1, number2, num, number : Integer;
  V : real;

begin
  num1 := 0;
  number1 := 0;

  j := 1;
  if Counters[48].Count = 1 then
    for j := 1 to N2 - 1 do
      begin
        Analizator.Table_.Cells[0, j] := IntToStr(j) + '.';
        Analizator.Table_.Cells[1, j] := FuncArr[j].Name + '()';
        Analizator.Table_.Cells[2, j] := IntToStr(FuncArr[j].FuncCount);
        number1 := number1 + FuncArr[j].FuncCount;
      end;

  for i := 1 to N1 do
    if Counters[i].Count <> 0 then
    begin
      if i = 48 then continue;
      Analizator.Table_.Cells[0, j] := IntToStr(j) + '.';
      Analizator.Table_.Cells[1, j] := Counters[i].Name;
      Analizator.Table_.Cells[2, j] := IntToStr(Counters[i].Count);
      inc(j);
      number1 := number1 + Counters[i].Count;
    end;

  num1 := j - 1;


  num2 := 0;
  number2 := 0;

  if N3 = 1 then exit;
  for i := 1 to N3 - 1 do
    begin
      Analizator.Table_.Cells[3, i] := IntToStr(i) + '.';
      Analizator.Table_.Cells[4, i] := OperArr[i].Name;
      Analizator.Table_.Cells[5, i] := IntToStr(OperArr[i].OperCount);
      number2 := number2 + OperArr[i].OperCount;
    end;

  num2 := i - 1;

  if num2 >= num1 then
    begin
      Analizator.Table_.Cells[0, num2 + 2] := 'n1 = ' + IntToStr(num1);
      Analizator.Table_.Cells[2, num2 + 2] := 'N1 = ' + IntToStr(number1);

      Analizator.Table_.Cells[3, num2 + 2] := 'n2 = ' + IntToStr(num2);
      Analizator.Table_.Cells[5, num2 + 2] := 'N2 = ' + IntToStr(number2);
    end
  else
    begin
      Analizator.Table_.Cells[0, num1 + 2] := 'n1 = ' + IntToStr(num1);
      Analizator.Table_.Cells[2, num1 + 2] := 'N1 = ' + IntToStr(number1);

      Analizator.Table_.Cells[3, num1 + 2] := 'n2 = ' + IntToStr(num2);
      Analizator.Table_.Cells[5, num1 + 2] := 'N2 = ' + IntToStr(number2);
    end;

  num := num1 + num2;
  number := number1 + number2;
  V := number * (ln(num)/ln(2));

  Analizator.ResultText_.Lines[1] := 'Словарь программы n = ' + IntToStr(num1) + ' + ' + IntToStr(num2) + ' = ' + IntToStr(num);
  Analizator.ResultText_.Lines[3] := 'Длина программы N = ' + IntToStr(number1) + ' + ' + IntToStr(number2) + ' = ' + IntToStr(number);
  Analizator.ResultText_.Lines[5] := 'Объем программы V = ' + IntToStr(number) + ' * log2(' + IntToStr(num) + ') = ' + IntToStr(Round(V));
end;

procedure CheckOperand;
var
  l : integer;
  IsOperandFound : boolean;

begin
  for l := 1 to CurrNumOper do
    begin
      if OperArr[l].Name = bufFunc then
        begin
          IsOperandFound := true;
          inc(OperArr[l].OperCount);
          break;
        end;
    end;
  if not IsOperandFound then
    begin
      OperArr[CurrNumOper].Name := bufFunc;
      OperArr[CurrNumOper].OperCount := 1;
      inc(CurrNumOper);
    end;

end;

procedure CheckOperatorsAndFuncs(var IsOperatorOrFunc : boolean);
var
  z, l : integer;
  IsFuncFound, IsOperFound : boolean;

begin
  IsOperatorOrFunc := true;

  if buf[j] = '(' then
    begin
      inc(Counters[1].Count);
      inc(j);
    end else
  if (buf[j] = '+') and (buf[j+1] <> '=') then
    begin
      inc(Counters[2].Count);
      inc(j);
    end else
  if (buf[j] = '-') and (buf[j+1] <> '=') and (buf[j-1] <> '|') and (buf[j-1] <> '{') and (buf[j-1] <> '(') and (buf[j-1] <> '[') and (buf[j-1] <> '.') and (buf[j-1] <> ',') then
    begin
      inc(Counters[3].Count);
      inc(j);
    end else
  if (buf[j] = '*') and (buf[j+1] <> '=') and (buf[j+1] <> '*') then
    begin
      inc(Counters[4].Count);
      inc(j);
    end else
  if (buf[j] = '/') and (buf[j+1] <> '=') then
    begin
      inc(Counters[5].Count);
      inc(j);
    end else
  if (buf[j] = '%') and (buf[j+1] <> '=') then
    begin
      inc(Counters[6].Count);
      inc(j);
    end else
  if (buf[j] = '>') and (buf[j+1] <> '=') and (buf[j+1] <> '>') then
    begin
      inc(Counters[7].Count);
      inc(j);
    end else
  if (buf[j] = '<') and (buf[j+1] <> '=') and (buf[j+1] <> '<') then
    begin
      inc(Counters[8].Count);
      inc(j);
    end else
  if (buf[j] = '=') and (buf[j+1] <> '=') then
    begin
      inc(Counters[9].Count);
      inc(j);
    end else
  if (buf[j] = '&') and (buf[j+1] <> '&') then
    begin
      inc(Counters[10].Count);
      inc(j);
    end else
  if (buf[j] = '|') and (buf[j+1] <> '|') then
    begin
      inc(Counters[11].Count);
      inc(j);
    end else
  if (buf[j] = '^') then
    begin
      inc(Counters[12].Count);
      inc(j);
    end else
  if (buf[j] = '~') then
    begin
      inc(Counters[13].Count);
      inc(j);
    end else
  if ((buf[j-1] = ' ') or (buf[j-1] = '(')) and (buf[j] = '!') and (buf[j+1] <> '=') then
    begin
      inc(Counters[14].Count);
      inc(j);
    end else
  if (buf[j] = '.') and (buf[j+1] <> '.') and (buf[j+1] <> 'e') then
    begin
      inc(Counters[15].Count);
      inc(j);
    end else
  if ((buf[j-1] = ' ') or (buf[j-1] = '(')) and (buf[j] = '?') then
    begin
      inc(Counters[16].Count);
      inc(j);
    end else
  if (buf[j] = ',') then
    begin
      inc(Counters[17].Count);
      inc(j);
    end else
  if (buf[j] = ';') then
    begin
      inc(Counters[18].Count);
      inc(j);
    end else
  if (buf[j] = 'y') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+1] = ' ') or (buf[j+1] = '(') or (buf[j+1] = '.') or (buf[j+1] = ';') or (buf[j+1] = '|') or (buf[j+1] = '[') or (buf[j+1] = ']') or (buf[j+1] = '{') or (buf[j+1] = '}') or (buf[j+1] = ')')) then
    begin
      inc(Counters[19].Count);
      inc(j);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'p') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+1] = ' ') or (buf[j+1] = '(') or (buf[j+1] = '.') or (buf[j+1] = ';') or (buf[j+1] = '|') or (buf[j+1] = '[') or (buf[j+1] = ']') or (buf[j+1] = '{') or (buf[j+1] = '}') or (buf[j+1] = ')')) then
    begin
      inc(Counters[20].Count);
      inc(j);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = '`') and (buf[j-1] = ' ') and (buf[j+1] = ' ') then
    begin
      inc(Counters[21].Count);
      inc(j);
    end else


  if (buf[j] = '*') and (buf[j+1] = '*') and (buf[j+2] <> '=') then
    begin
      inc(Counters[22].Count);
      inc(j, 2);
    end else
  if (buf[j] = '=') and (buf[j+1] = '=') and (buf[j+2] <> '=') then
    begin
      inc(Counters[23].Count);
      inc(j, 2);
    end else
  if (buf[j] = '!') and (buf[j+1] = '=') then
    begin
      inc(Counters[24].Count);
      inc(j, 2);
    end else
  if (buf[j] = '>') and (buf[j+1] = '=') then
    begin
      inc(Counters[25].Count);
      inc(j, 2);
    end else
  if (buf[j] = '<') and (buf[j+1] = '=') and (buf[j+2] <> '>') then
    begin
      inc(Counters[26].Count);
      inc(j, 2);
    end else
  if (buf[j] = '+') and (buf[j+1] = '=') then
    begin
      inc(Counters[27].Count);
      inc(j, 2);
    end else
  if (buf[j] = '-') and (buf[j+1] = '=') then
    begin
      inc(Counters[28].Count);
      inc(j, 2);
    end else
  if (buf[j] = '*') and (buf[j+1] = '=') then
    begin
      inc(Counters[29].Count);
      inc(j, 2);
    end else
  if (buf[j] = '/') and (buf[j+1] = '=') then
    begin
      inc(Counters[30].Count);
      inc(j, 2);
    end else
  if (buf[j] = '%') and (buf[j+1] = '=') then
    begin
      inc(Counters[31].Count);
      inc(j, 2);
    end else
  if (buf[j] = '>') and (buf[j+1] = '>') then
    begin
      inc(Counters[32].Count);
      inc(j, 2);
    end else
  if (buf[j] = '<') and (buf[j+1] = '<') then
    begin
      inc(Counters[33].Count);
      inc(j, 2);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'o') and (buf[j+1] = 'r') and (buf[j+2] = ' ') then
    begin
      inc(Counters[34].Count);
      inc(j, 2);
    end else
  if (buf[j] = '&') and (buf[j+1] = '&') then
    begin
      inc(Counters[35].Count);
      inc(j, 2);
    end else
  if (buf[j] = '|') and (buf[j+1] = '|') then
    begin
      inc(Counters[36].Count);
      inc(j, 2);
    end else
  if (buf[j] = '.') and (buf[j+1] = '.') and (buf[j+2] <> '.') then
    begin
      inc(Counters[37].Count);
      inc(j, 2);
    end else
  if (buf[j] = ':') and (buf[j+1] = ':') then
    begin
      inc(Counters[38].Count);
      inc(j, 2);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'i') and (buf[j+1] = 'n') and (buf[j+2] = ' ') then
    begin
      inc(Counters[39].Count);
      inc(j, 2);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'i') and (buf[j+1] = 'f') and (buf[j+2] = ' ') then
    begin
      inc(Counters[40].Count);
      inc(j, 2);
    end else
   if (buf[j] = 'p') and (buf[j+1] = 'p') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+2] = ' ') or (buf[j+2] = '(') or (buf[j+2] = '.') or (buf[j+2] = ';') or (buf[j+2] = '|') or (buf[j+2] = '[') or (buf[j+2] = ']') or (buf[j+2] = '{') or (buf[j+2] = '}') or (buf[j+2] = ')')) then
    begin
      inc(Counters[41].Count);
      inc(j, 2);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j] = '<') and (buf[j+1] = '=') and (buf[j+2] = '>') then
    begin
      inc(Counters[42].Count);
      inc(j, 3);
    end else
  if (buf[j] = '=') and (buf[j+1] = '=') and (buf[j+2] = '=') then
    begin
      inc(Counters[43].Count);
      inc(j, 3);
    end else
  if (buf[j] = '*') and (buf[j+1] = '*') and (buf[j+2] = '=') then
    begin
      inc(Counters[44].Count);
      inc(j, 3);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'a') and (buf[j+1] = 'n') and (buf[j+2] = 'd') and (buf[j+3] = ' ') then
    begin
      inc(Counters[45].Count);
      inc(j, 3);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'n') and (buf[j+1] = 'o') and (buf[j+2] = 't') and (buf[j+3] = ' ') then
    begin
      inc(Counters[46].Count);
      inc(j, 3);
    end else
  if (buf[j] = '.') and (buf[j+1] = '.') and (buf[j+2] = '.') then
    begin
      inc(Counters[47].Count);
      inc(j, 3);
    end else

  if (buf[j-1] = ' ') and (buf[j] = 'd') and (buf[j+1] = 'e') and (buf[j+2] = 'f') and (buf[j+3] = ' ') then
    begin
      IsFound := false;
      TempStr := '';
      Counters[48].Count := 1;
      inc(j, 3);

      while buf[j] = ' ' do
        inc(j);

      while (buf[j] <> ' ') and (buf[j] <> '(') do
        begin
          TempStr := TempStr + buf[j];
          inc(j);
        end;
      inc(j);

      for z := 1 to CurrNumFunc do
        if TempStr = FuncArr[z].Name then
          begin
            IsFound := true;
            break;
          end;

      if not IsFound then
        begin
          FuncArr[CurrNumFunc].Name := TempStr;
          inc(CurrNumFunc);
        end;

    end else

  if (buf[j-1] = ' ') and (buf[j] = 'f') and (buf[j+1] = 'o') and (buf[j+2] = 'r') and (buf[j+3] = ' ') then
    begin
      inc(Counters[49].Count);
      inc(j, 3);
    end else
  if (buf[j] = 'U') and (buf[j+1] = 'R') and (buf[j+2] = 'I') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+3] = ' ') or (buf[j+3] = '(') or (buf[j+3] = '.') or (buf[j+3] = ';') or (buf[j+3] = '|') or (buf[j+3] = '[') or (buf[j+3] = ']') or (buf[j+3] = '{') or (buf[j+3] = '}') or (buf[j+3] = ')')) then
    begin
      inc(Counters[50].Count);
      inc(j, 3);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'g') and (buf[j+1] = 'e') and (buf[j+2] = 'm') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+3] = ' ') or (buf[j+3] = '(') or (buf[j+3] = '.') or (buf[j+3] = ';') or (buf[j+3] = '|') or (buf[j+3] = '[') or (buf[j+3] = ']') or (buf[j+3] = '{') or (buf[j+3] = '}') or (buf[j+3] = ')')) then
    begin
      inc(Counters[51].Count);
      inc(j, 3);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'u') and (buf[j+2] = 'b') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+3] = ' ') or (buf[j+3] = '(') or (buf[j+3] = '.') or (buf[j+3] = ';') or (buf[j+3] = '|') or (buf[j+3] = '[') or (buf[j+3] = ']') or (buf[j+3] = '{') or (buf[j+3] = '}') or (buf[j+3] = ')')) then
    begin
      inc(Counters[52].Count);
      inc(j, 3);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'a') and (buf[j+1] = 'b') and (buf[j+2] = 's') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+3] = ' ') or (buf[j+3] = '(') or (buf[j+3] = '.') or (buf[j+3] = ';') or (buf[j+3] = '|') or (buf[j+3] = '[') or (buf[j+3] = ']') or (buf[j+3] = '{') or (buf[j+3] = '}') or (buf[j+3] = ')')) then
    begin
      inc(Counters[53].Count);
      inc(j, 3);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j-1] = ' ') and (buf[j] = 'n') and (buf[j+1] = 'e') and (buf[j+2] = 'x') and (buf[j+3] = 't') and (buf[j+4] = ' ') then
    begin
      inc(Counters[54].Count);
      inc(j, 4);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'r') and (buf[j+1] = 'e') and (buf[j+2] = 'd') and (buf[j+3] = 'o') and (buf[j+4] = ' ') then
    begin
      inc(Counters[55].Count);
      inc(j, 4);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'c') and (buf[j+1] = 'a') and (buf[j+2] = 's') and (buf[j+3] = 'e') and (buf[j+4] = ' ') then
    begin
      inc(Counters[56].Count);
      inc(j, 4);
    end else
  if (buf[j] = 'c') and (buf[j+1] = 'h') and (buf[j+2] = 'o') and (buf[j+3] = 'p') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[57].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'e') and (buf[j+1] = 'v') and (buf[j+2] = 'a') and (buf[j+3] = 'l') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[58].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'e') and (buf[j+1] = 'x') and (buf[j+2] = 'e') and (buf[j+3] = 'c') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[59].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'e') and (buf[j+1] = 'x') and (buf[j+2] = 'i') and (buf[j+3] = 't') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[60].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'f') and (buf[j+1] = 'a') and (buf[j+2] = 'i') and (buf[j+3] = 'l') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[61].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'g') and (buf[j+1] = 'e') and (buf[j+2] = 't') and (buf[j+3] = 'c') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[62].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'g') and (buf[j+1] = 'e') and (buf[j+2] = 't') and (buf[j+3] = 's') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[63].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'g') and (buf[j+1] = 's') and (buf[j+2] = 'u') and (buf[j+3] = 'b') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[64].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'l') and (buf[j+1] = 'o') and (buf[j+2] = 'a') and (buf[j+3] = 'd') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[65].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'l') and (buf[j+1] = 'o') and (buf[j+2] = 'o') and (buf[j+3] = 'p') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[66].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'p') and (buf[j+1] = 'r') and (buf[j+2] = 'o') and (buf[j+3] = 'c') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[67].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'p') and (buf[j+1] = 'u') and (buf[j+2] = 't') and (buf[j+3] = 'c') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[68].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'p') and (buf[j+1] = 'u') and (buf[j+2] = 't') and (buf[j+3] = 's') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[69].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'r') and (buf[j+1] = 'a') and (buf[j+2] = 'n') and (buf[j+3] = 'd') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[70].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'c') and (buf[j+2] = 'a') and (buf[j+3] = 'n') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[71].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'u') and (buf[j+2] = 'b') and (buf[j+3] = '!') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[72].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 't') and (buf[j+1] = 'e') and (buf[j+2] = 's') and (buf[j+3] = 't') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[73].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 't') and (buf[j+1] = 'r') and (buf[j+2] = 'a') and (buf[j+3] = 'p') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[74].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'w') and (buf[j+1] = 'a') and (buf[j+2] = 'r') and (buf[j+3] = 'n') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[75].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'j') and (buf[j+1] = 'o') and (buf[j+2] = 'i') and (buf[j+3] = 'n') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[76].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'm') and (buf[j+1] = 'a') and (buf[j+2] = 'p') and (buf[j+3] = '!') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[77].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'e') and (buf[j+1] = 'a') and (buf[j+2] = 'c') and (buf[j+3] = 'h') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[78].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 't') and (buf[j+1] = 'o') and (buf[j+2] = '_') and (buf[j+3] = 'i') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+4] = ' ') or (buf[j+4] = '(') or (buf[j+4] = '.') or (buf[j+4] = ';') or (buf[j+4] = '|') or (buf[j+4] = '[') or (buf[j+4] = ']') or (buf[j+4] = '{') or (buf[j+4] = '}') or (buf[j+4] = ')')) then
    begin
      inc(Counters[79].Count);
      inc(j, 4);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j-1] = ' ') and (buf[j] = '.') and (buf[j+1] = 'e') and (buf[j+2] = 'q') and (buf[j+3] = 'l') and
     (buf[j+4] = '?') and (buf[j+5] = ' ') then
    begin
      inc(Counters[80].Count);
      inc(j, 5);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'w') and (buf[j+1] = 'h') and (buf[j+2] = 'i') and (buf[j+3] = 'l') and
     (buf[j+4] = 'e') and (buf[j+5] = ' ') then
    begin
      inc(Counters[81].Count);
      inc(j, 5);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'u') and (buf[j+1] = 'n') and (buf[j+2] = 't') and (buf[j+3] = 'i') and
     (buf[j+4] = 'l') and (buf[j+5] = ' ') then
    begin
      inc(Counters[82].Count);
      inc(j, 5);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'b') and (buf[j+1] = 'r') and (buf[j+2] = 'e') and (buf[j+3] = 'a') and
     (buf[j+4] = 'k') and (buf[j+5] = ' ') then
    begin
      inc(Counters[83].Count);
      inc(j, 5);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'r') and (buf[j+1] = 'e') and (buf[j+2] = 't') and (buf[j+3] = 'r') and
     (buf[j+4] = 'y') and (buf[j+5] = ' ') then
    begin
      inc(Counters[84].Count);
      inc(j, 5);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'b') and (buf[j+1] = 'e') and (buf[j+2] = 'g') and (buf[j+3] = 'i') and
     (buf[j+4] = 'n') and (buf[j+5] = ' ') then
    begin
      inc(Counters[85].Count);
      inc(j, 5);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'e') and (buf[j+1] = 'l') and (buf[j+2] = 's') and (buf[j+3] = 'i') and
     (buf[j+4] = 'f') and (buf[j+5] = ' ') then
    begin
      inc(Counters[86].Count);
      inc(j, 5);
    end else
  if (buf[j] = 'A') and (buf[j+1] = 'r') and (buf[j+2] = 'r') and (buf[j+3] = 'a') and (buf[j+4] = 'y') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[87].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'F') and (buf[j+1] = 'l') and (buf[j+2] = 'o') and (buf[j+3] = 'a') and (buf[j+4] = 't') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[88].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'a') and (buf[j+1] = 'b') and (buf[j+2] = 'o') and (buf[j+3] = 'r') and (buf[j+4] = 't') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[89].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'c') and (buf[j+1] = 'a') and (buf[j+2] = 't') and (buf[j+3] = 'c') and (buf[j+4] = 'h') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[90].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'c') and (buf[j+1] = 'h') and (buf[j+2] = 'o') and (buf[j+3] = 'm') and (buf[j+4] = 'p') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[91].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'c') and (buf[j+1] = 'h') and (buf[j+2] = 'o') and (buf[j+3] = 'p') and (buf[j+4] = '!') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[92].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'e') and (buf[j+1] = 'x') and (buf[j+2] = 'i') and (buf[j+3] = 't') and (buf[j+4] = '!') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[93].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'g') and (buf[j+1] = 's') and (buf[j+2] = 'u') and (buf[j+3] = 'b') and (buf[j+4] = '!') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[94].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'p') and (buf[j+1] = 'r') and (buf[j+2] = 'i') and (buf[j+3] = 'n') and (buf[j+4] = 't') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[95].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'r') and (buf[j+1] = 'a') and (buf[j+2] = 'i') and (buf[j+3] = 's') and (buf[j+4] = 'e') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[96].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'c') and (buf[j+2] = 'a') and (buf[j+3] = 'n') and (buf[j+4] = 'f') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[97].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'l') and (buf[j+2] = 'e') and (buf[j+3] = 'e') and (buf[j+4] = 'p') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[98].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'p') and (buf[j+2] = 'l') and (buf[j+3] = 'i') and (buf[j+4] = 't') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[99].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'r') and (buf[j+2] = 'a') and (buf[j+3] = 'n') and (buf[j+4] = 'd') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[100].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 't') and (buf[j+1] = 'h') and (buf[j+2] = 'r') and (buf[j+3] = 'o') and (buf[j+4] = 'w') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[101].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 't') and (buf[j+1] = 'i') and (buf[j+2] = 'm') and (buf[j+3] = 'e') and (buf[j+4] = 's') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[102].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'h') and (buf[j+2] = 'i') and (buf[j+3] = 'f') and (buf[j+4] = 't') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+5] = ' ') or (buf[j+5] = '(') or (buf[j+5] = '.') or (buf[j+5] = ';') or (buf[j+5] = '|') or (buf[j+5] = '[') or (buf[j+5] = ']') or (buf[j+5] = '{') or (buf[j+5] = '}') or (buf[j+5] = ')')) then
    begin
      inc(Counters[103].Count);
      inc(j, 5);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j-1] = ' ') and (buf[j] = 'e') and (buf[j+1] = 'q') and (buf[j+2] = 'u') and (buf[j+3] = 'a') and (buf[j+4] = 'l') and
     (buf[j+5] = '?') and (buf[j+6] = ' ') then
    begin
      inc(Counters[104].Count);
      inc(j, 6);
    end else
  if (buf[j-1] = ' ') and (buf[j] = 'u') and (buf[j+1] = 'n') and (buf[j+2] = 'l') and (buf[j+3] = 'e') and (buf[j+4] = 's') and
     (buf[j+5] = 's') and (buf[j+6] = ' ') then
    begin
      inc(Counters[105].Count);
      inc(j, 6);
    end else
  if (buf[j] = 'S') and (buf[j+1] = 't') and (buf[j+2] = 'r') and (buf[j+3] = 'i') and (buf[j+4] = 'n') and
     (buf[j+5] = 'g') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[106].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'c') and (buf[j+1] = 'a') and (buf[j+2] = 'l') and (buf[j+3] = 'l') and (buf[j+4] = 'c') and
     (buf[j+5] = 'c') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[107].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'c') and (buf[j+1] = 'a') and (buf[j+2] = 'l') and (buf[j+3] = 'l') and (buf[j+4] = 'e') and
     (buf[j+5] = 'r') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[108].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'c') and (buf[j+1] = 'h') and (buf[j+2] = 'o') and (buf[j+3] = 'm') and (buf[j+4] = 'p') and
     (buf[j+5] = '!') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[109].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'l') and (buf[j+1] = 'a') and (buf[j+2] = 'm') and (buf[j+3] = 'b') and (buf[j+4] = 'd') and
     (buf[j+5] = 'a') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[110].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'p') and (buf[j+1] = 'r') and (buf[j+2] = 'i') and (buf[j+3] = 'n') and (buf[j+4] = 't') and
     (buf[j+5] = 'f') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[111].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'e') and (buf[j+2] = 'l') and (buf[j+3] = 'e') and (buf[j+4] = 'c') and
     (buf[j+5] = 't') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[112].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'y') and (buf[j+2] = 's') and (buf[j+3] = 't') and (buf[j+4] = 'e') and
     (buf[j+5] = 'm') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[113].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 't') and (buf[j+1] = 'o') and (buf[j+2] = '_') and (buf[j+3] = 'p') and (buf[j+4] = 't') and
     (buf[j+5] = 'r') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[114].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'l') and (buf[j+1] = 'e') and (buf[j+2] = 'n') and (buf[j+3] = 'g') and (buf[j+4] = 't') and
     (buf[j+5] = 'h') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[115].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'u') and (buf[j+1] = 'p') and (buf[j+2] = 'c') and (buf[j+3] = 'a') and (buf[j+4] = 's') and
     (buf[j+5] = 'e') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[116].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'r') and (buf[j+1] = 'e') and (buf[j+2] = 'm') and (buf[j+3] = 'o') and (buf[j+4] = 'v') and
     (buf[j+5] = 'e') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[117].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'a') and (buf[j+2] = 'm') and (buf[j+3] = 'p') and (buf[j+4] = 'l') and
     (buf[j+5] = 'e') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+6] = ' ') or (buf[j+6] = '(') or (buf[j+6] = '.') or (buf[j+6] = ';') or (buf[j+6] = '|') or (buf[j+6] = '[') or (buf[j+6] = ']') or (buf[j+6] = '{') or (buf[j+6] = '}') or (buf[j+6] = ')')) then
    begin
      inc(Counters[118].Count);
      inc(j, 6);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j] = 'I') and (buf[j+1] = 'n') and (buf[j+2] = 't') and (buf[j+3] = 'e') and (buf[j+4] = 'g') and
     (buf[j+5] = 'e') and (buf[j+6] = 'r') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+7] = ' ') or (buf[j+7] = '(') or (buf[j+7] = '.') or (buf[j+7] = ';') or (buf[j+7] = '|') or (buf[j+7] = '[') or (buf[j+7] = ']') or (buf[j+7] = '{') or (buf[j+7] = '}') or (buf[j+7] = ')')) then
    begin
      inc(Counters[119].Count);
      inc(j, 7);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'a') and (buf[j+1] = 't') and (buf[j+2] = '_') and (buf[j+3] = 'e') and (buf[j+4] = 'x') and
     (buf[j+5] = 'i') and (buf[j+6] = 't') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+7] = ' ') or (buf[j+7] = '(') or (buf[j+7] = '.') or (buf[j+7] = ';') or (buf[j+7] = '|') or (buf[j+7] = '[') or (buf[j+7] = ']') or (buf[j+7] = '{') or (buf[j+7] = '}') or (buf[j+7] = ')')) then
    begin
      inc(Counters[120].Count);
      inc(j, 7);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'b') and (buf[j+1] = 'i') and (buf[j+2] = 'n') and (buf[j+3] = 'd') and (buf[j+4] = 'i') and
     (buf[j+5] = 'n') and (buf[j+6] = 'g') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+7] = ' ') or (buf[j+7] = '(') or (buf[j+7] = '.') or (buf[j+7] = ';') or (buf[j+7] = '|') or (buf[j+7] = '[') or (buf[j+7] = ']') or (buf[j+7] = '{') or (buf[j+7] = '}') or (buf[j+7] = ')')) then
    begin
      inc(Counters[121].Count);
      inc(j, 7);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'r') and (buf[j+1] = 'e') and (buf[j+2] = 'q') and (buf[j+3] = 'u') and (buf[j+4] = 'i') and
     (buf[j+5] = 'r') and (buf[j+6] = 'e') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+7] = ' ') or (buf[j+7] = '(') or (buf[j+7] = '.') or (buf[j+7] = ';') or (buf[j+7] = '|') or (buf[j+7] = '[') or (buf[j+7] = ']') or (buf[j+7] = '{') or (buf[j+7] = '}') or (buf[j+7] = ')')) then
    begin
      inc(Counters[122].Count);
      inc(j, 7);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'p') and (buf[j+2] = 'r') and (buf[j+3] = 'i') and (buf[j+4] = 'n') and
     (buf[j+5] = 't') and (buf[j+6] = 'f') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+7] = ' ') or (buf[j+7] = '(') or (buf[j+7] = '.') or (buf[j+7] = ';') or (buf[j+7] = '|') or (buf[j+7] = '[') or (buf[j+7] = ']') or (buf[j+7] = '{') or (buf[j+7] = '}') or (buf[j+7] = ')')) then
    begin
      inc(Counters[123].Count);
      inc(j, 7);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 's') and (buf[j+1] = 'y') and (buf[j+2] = 's') and (buf[j+3] = 'c') and (buf[j+4] = 'a') and
     (buf[j+5] = 'l') and (buf[j+6] = 'l') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+7] = ' ') or (buf[j+7] = '(') or (buf[j+7] = '.') or (buf[j+7] = ';') or (buf[j+7] = '|') or (buf[j+7] = '[') or (buf[j+7] = ']') or (buf[j+7] = '{') or (buf[j+7] = '}') or (buf[j+7] = ')')) then
    begin
      inc(Counters[124].Count);
      inc(j, 7);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j-1] = ' ') and (buf[j] = 'd') and (buf[j+1] = 'e') and (buf[j+2] = 'f') and (buf[j+3] = 'i') and (buf[j+4] = 'n') and
     (buf[j+5] = 'e') and (buf[j+6] = 'd') and (buf[j+7] = '?') and (buf[j+8] = ' ') then
    begin
      inc(Counters[125].Count);
      inc(j, 8);
    end else
  if (buf[j] = 'P') and (buf[j+1] = 'a') and (buf[j+2] = 't') and (buf[j+3] = 'h') and (buf[j+4] = 'n') and
     (buf[j+5] = 'a') and (buf[j+6] = 'm') and (buf[j+7] = 'e') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+8] = ' ') or (buf[j+8] = '(') or (buf[j+8] = '.') or (buf[j+8] = ';') or (buf[j+8] = '|') or (buf[j+8] = '[') or (buf[j+8] = ']') or (buf[j+8] = '{') or (buf[j+8] = '}') or (buf[j+8] = ')')) then
    begin
      inc(Counters[126].Count);
      inc(j, 8);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'a') and (buf[j+1] = 'u') and (buf[j+2] = 't') and (buf[j+3] = 'o') and (buf[j+4] = 'l') and
     (buf[j+5] = 'o') and (buf[j+6] = 'a') and (buf[j+7] = 'd') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+8] = ' ') or (buf[j+8] = '(') or (buf[j+8] = '.') or (buf[j+8] = ';') or (buf[j+8] = '|') or (buf[j+8] = '[') or (buf[j+8] = ']') or (buf[j+8] = '{') or (buf[j+8] = '}') or (buf[j+8] = ')')) then
    begin
      inc(Counters[127].Count);
      inc(j, 8);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'r') and (buf[j+1] = 'a') and (buf[j+2] = 'k') and (buf[j+3] = 'e') and (buf[j+4] = '_') and
     (buf[j+5] = 'd') and (buf[j+6] = 'u') and (buf[j+7] = 'p') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+8] = ' ') or (buf[j+8] = '(') or (buf[j+8] = '.') or (buf[j+8] = ';') or (buf[j+8] = '|') or (buf[j+8] = '[') or (buf[j+8] = ']') or (buf[j+8] = '{') or (buf[j+8] = '}') or (buf[j+8] = ')')) then
    begin
      inc(Counters[128].Count);
      inc(j, 8);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'r') and (buf[j+1] = 'e') and (buf[j+2] = 'a') and (buf[j+3] = 'd') and (buf[j+4] = 'l') and
     (buf[j+5] = 'i') and (buf[j+6] = 'n') and (buf[j+7] = 'e') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+8] = ' ') or (buf[j+8] = '(') or (buf[j+8] = '.') or (buf[j+8] = ';') or (buf[j+8] = '|') or (buf[j+8] = '[') or (buf[j+8] = ']') or (buf[j+8] = '{') or (buf[j+8] = '}') or (buf[j+8] = ')')) then
    begin
      inc(Counters[129].Count);
      inc(j, 8);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'r') and (buf[j+1] = 'e') and (buf[j+2] = 'v') and (buf[j+3] = 'e') and (buf[j+4] = 'r') and
     (buf[j+5] = 's') and (buf[j+6] = 'e') and (buf[j+7] = '!') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+8] = ' ') or (buf[j+8] = '(') or (buf[j+8] = '.') or (buf[j+8] = ';') or (buf[j+8] = '|') or (buf[j+8] = '[') or (buf[j+8] = ']') or (buf[j+8] = '{') or (buf[j+8] = '}') or (buf[j+8] = ')')) then
    begin
      inc(Counters[130].Count);
      inc(j, 8);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'i') and (buf[j+1] = 'n') and (buf[j+2] = 'c') and (buf[j+3] = 'l') and (buf[j+4] = 'u') and
     (buf[j+5] = 'd') and (buf[j+6] = 'e') and (buf[j+7] = '?') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+8] = ' ') or (buf[j+8] = '(') or (buf[j+8] = '.') or (buf[j+8] = ';') or (buf[j+8] = '|') or (buf[j+8] = '[') or (buf[j+8] = ']') or (buf[j+8] = '{') or (buf[j+8] = '}') or (buf[j+8] = ')')) then
    begin
      inc(Counters[131].Count);
      inc(j, 8);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j] = 'a') and (buf[j+1] = 'u') and (buf[j+2] = 't') and (buf[j+3] = 'o') and (buf[j+4] = 'l') and
     (buf[j+5] = 'o') and (buf[j+6] = 'a') and (buf[j+7] = 'd') and (buf[j+8] = '?') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+9] = ' ') or (buf[j+9] = '(') or (buf[j+9] = '.') or (buf[j+9] = ';') or (buf[j+9] = '|') or (buf[j+9] = '[') or (buf[j+9] = ']') or (buf[j+9] = '{') or (buf[j+9] = '}') or (buf[j+9] = ')')) then
    begin
      inc(Counters[132].Count);
      inc(j, 9);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'i') and (buf[j+1] = 't') and (buf[j+2] = 'e') and (buf[j+3] = 'r') and (buf[j+4] = 'a') and
     (buf[j+5] = 't') and (buf[j+6] = 'o') and (buf[j+7] = 'r') and (buf[j+8] = '?') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+9] = ' ') or (buf[j+9] = '(') or (buf[j+9] = '.') or (buf[j+9] = ';') or (buf[j+9] = '|') or (buf[j+9] = '[') or (buf[j+9] = ']') or (buf[j+9] = '{') or (buf[j+9] = '}') or (buf[j+9] = ')')) then
    begin
      inc(Counters[133].Count);
      inc(j, 9);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'r') and (buf[j+1] = 'e') and (buf[j+2] = 'a') and (buf[j+3] = 'd') and (buf[j+4] = 'l') and
     (buf[j+5] = 'i') and (buf[j+6] = 'n') and (buf[j+7] = 'e') and (buf[j+8] = 's') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+9] = ' ') or (buf[j+9] = '(') or (buf[j+9] = '.') or (buf[j+9] = ';') or (buf[j+9] = '|') or (buf[j+9] = '[') or (buf[j+9] = ']') or (buf[j+9] = '{') or (buf[j+9] = '}') or (buf[j+9] = ')')) then
    begin
      inc(Counters[134].Count);
      inc(j, 9);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 't') and (buf[j+1] = 'r') and (buf[j+2] = 'a') and (buf[j+3] = 'c') and (buf[j+4] = 'e') and
     (buf[j+5] = '_') and (buf[j+6] = 'v') and (buf[j+7] = 'a') and (buf[j+8] = 'r') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+9] = ' ') or (buf[j+9] = '(') or (buf[j+9] = '.') or (buf[j+9] = ';') or (buf[j+9] = '|') or (buf[j+9] = '[') or (buf[j+9] = ']') or (buf[j+9] = '{') or (buf[j+9] = '}') or (buf[j+9] = ')')) then
    begin
      inc(Counters[135].Count);
      inc(j, 9);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'e') and (buf[j+1] = 'a') and (buf[j+2] = 'c') and (buf[j+3] = 'h') and (buf[j+4] = '_') and
     (buf[j+5] = 'c') and (buf[j+6] = 'h') and (buf[j+7] = 'a') and (buf[j+8] = 'r') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+9] = ' ') or (buf[j+9] = '(') or (buf[j+9] = '.') or (buf[j+9] = ';') or (buf[j+9] = '|') or (buf[j+9] = '[') or (buf[j+9] = ']') or (buf[j+9] = '{') or (buf[j+9] = '}') or (buf[j+9] = ')')) then
    begin
      inc(Counters[136].Count);
      inc(j, 9);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j] = 'e') and (buf[j+1] = 'a') and (buf[j+2] = 'c') and (buf[j+3] = 'h') and (buf[j+4] = '_') and
     (buf[j+5] = 'i') and (buf[j+6] = 'n') and (buf[j+7] = 'd') and (buf[j+8] = 'e') and (buf[j+9] = 'x') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+10] = ' ') or (buf[j+10] = '(') or (buf[j+10] = '.') or (buf[j+10] = ';') or (buf[j+10] = '|') or (buf[j+10] = '[') or (buf[j+10] = ']') or (buf[j+10] = '{') or (buf[j+10] = '}') or (buf[j+10] = ')')) then
    begin
      inc(Counters[137].Count);
      inc(j, 10);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j] = 'r') and (buf[j+1] = 'e') and (buf[j+2] = 'q') and (buf[j+3] = 'u') and (buf[j+4] = 'i') and
     (buf[j+5] = 'r') and (buf[j+6] = 'e') and (buf[j+7] = '_') and (buf[j+8] = 'g') and (buf[j+9] = 'e') and
     (buf[j+10] = 'm') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+11] = ' ') or (buf[j+11] = '(') or (buf[j+11] = '.') or (buf[j+11] = ';') or (buf[j+11] = '|') or (buf[j+11] = '[') or (buf[j+11] = ']') or (buf[j+11] = '{') or (buf[j+11] = '}') or (buf[j+11] = ')')) then
    begin
      inc(Counters[138].Count);
      inc(j, 11);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'u') and (buf[j+1] = 'n') and (buf[j+2] = 't') and (buf[j+3] = 'r') and (buf[j+4] = 'a') and
     (buf[j+5] = 'c') and (buf[j+6] = 'e') and (buf[j+7] = '_') and (buf[j+8] = 'v') and (buf[j+9] = 'a') and
     (buf[j+10] = 'r') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+11] = ' ') or (buf[j+11] = '(') or (buf[j+11] = '.') or (buf[j+11] = ';') or (buf[j+11] = '|') or (buf[j+11] = '[') or (buf[j+11] = ']') or (buf[j+11] = '{') or (buf[j+11] = '}') or (buf[j+11] = ')')) then
    begin
      inc(Counters[139].Count);
      inc(j, 11);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j] = 'b') and (buf[j+1] = 'l') and (buf[j+2] = 'o') and (buf[j+3] = 'c') and (buf[j+4] = 'k') and
     (buf[j+5] = '_') and (buf[j+6] = 'g') and (buf[j+7] = 'i') and (buf[j+8] = 'v') and (buf[j+9] = 'e') and
     (buf[j+10] = 'n') and (buf[j+11] = '?') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+12] = ' ') or (buf[j+12] = '(') or (buf[j+12] = '.') or (buf[j+12] = ';') or (buf[j+12] = '|') or (buf[j+12] = '[') or (buf[j+12] = ']') or (buf[j+12] = '{') or (buf[j+12] = '}') or (buf[j+12] = ')')) then
    begin
      inc(Counters[140].Count);
      inc(j, 12);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j] = 's') and (buf[j+1] = 'e') and (buf[j+2] = 't') and (buf[j+3] = '_') and (buf[j+4] = 't') and
     (buf[j+5] = 'r') and (buf[j+6] = 'a') and (buf[j+7] = 'c') and (buf[j+8] = 'e') and (buf[j+9] = '_') and
     (buf[j+10] = 'f') and (buf[j+11] = 'u') and (buf[j+12] = 'n') and (buf[j+13] = 'c') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+14] = ' ') or (buf[j+14] = '(') or (buf[j+14] = '.') or (buf[j+14] = ';') or (buf[j+14] = '|') or (buf[j+14] = '[') or (buf[j+14] = ']') or (buf[j+14] = '{') or (buf[j+14] = '}') or (buf[j+14] = ')')) then
    begin
      inc(Counters[141].Count);
      inc(j, 14);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'p') and (buf[j+1] = 'r') and (buf[j+2] = 'e') and (buf[j+3] = 't') and (buf[j+4] = 't') and
     (buf[j+5] = 'y') and (buf[j+6] = '_') and (buf[j+7] = 'i') and (buf[j+8] = 'n') and (buf[j+9] = 's') and
     (buf[j+10] = 'p') and (buf[j+11] = 'e') and (buf[j+12] = 'c') and (buf[j+13] = 't') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+14] = ' ') or (buf[j+14] = '(') or (buf[j+14] = '.') or (buf[j+14] = ';') or (buf[j+14] = '|') or (buf[j+14] = '[') or (buf[j+14] = ']') or (buf[j+14] = '{') or (buf[j+14] = '}') or (buf[j+14] = ')')) then
    begin
      inc(Counters[142].Count);
      inc(j, 14);
      if buf[j] = '(' then inc(j);
    end else
  if (buf[j] = 'm') and (buf[j+1] = 'e') and (buf[j+2] = 't') and (buf[j+3] = 'h') and (buf[j+4] = 'o') and
     (buf[j+5] = 'd') and (buf[j+6] = '_') and (buf[j+7] = 'm') and (buf[j+8] = 'i') and (buf[j+9] = 's') and
     (buf[j+10] = 's') and (buf[j+11] = 'i') and (buf[j+12] = 'n') and (buf[j+13] = 'g') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and
     ((buf[j+14] = ' ') or (buf[j+14] = '(') or (buf[j+14] = '.') or (buf[j+14] = ';') or (buf[j+14] = '|') or (buf[j+14] = '[') or (buf[j+14] = ']') or (buf[j+14] = '{') or (buf[j+14] = '}') or (buf[j+14] = ')')) then
    begin
      inc(Counters[143].Count);
      inc(j, 14);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j] = 'l') and (buf[j+1] = 'o') and (buf[j+2] = 'c') and (buf[j+3] = 'a') and (buf[j+4] = 'l') and
     (buf[j+5] = '_') and (buf[j+6] = 'v') and (buf[j+7] = 'a') and (buf[j+8] = 'r') and (buf[j+9] = 'i') and
     (buf[j+10] = 'a') and (buf[j+11] = 'b') and (buf[j+12] = 'l') and (buf[j+13] = 'e') and (buf[j+14] = 's') and
     ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+15] = ' ') or (buf[j+15] = '(') or (buf[j+15] = '.') or (buf[j+15] = ';') or (buf[j+15] = '|') or (buf[j+15] = '[') or (buf[j+15] = ']') or (buf[j+15] = '{') or (buf[j+15] = '}') or (buf[j+15] = ')')) then
    begin
      inc(Counters[144].Count);
      inc(j, 15);
      if buf[j] = '(' then inc(j);
    end else


  if (buf[j] = 'g') and (buf[j+1] = 'l') and (buf[j+2] = 'o') and (buf[j+3] = 'b') and (buf[j+4] = 'a') and
     (buf[j+5] = 'l') and (buf[j+6] = '_') and (buf[j+7] = 'v') and (buf[j+8] = 'a') and (buf[j+9] = 'r') and
     (buf[j+10] = 'i') and (buf[j+11] = 'a') and (buf[j+12] = 'b') and (buf[j+13] = 'l') and (buf[j+14] = 'e') and
     (buf[j+15] = 's') and ((buf[j-1] = ' ') or (buf[j-1] = '.') or (buf[j-1] = '(')) and ((buf[j+16] = ' ') or (buf[j+16] = '(') or (buf[j+16] = '.') or (buf[j+16] = ';') or (buf[j+16] = '|') or (buf[j+16] = '[') or (buf[j+16] = ']') or (buf[j+16] = '{') or (buf[j+16] = '}') or (buf[j+16] = ')')) then
    begin
      inc(Counters[145].Count);
      inc(j, 16);
      if buf[j] = '(' then inc(j);
    end else
  if ((buf[j] = '_') or (buf[j] in ['a'..'z']) or (buf[j] in ['A'..'Z'])) and ((buf[j-1] = '.') or (buf[j-1] = ' ') or (buf[j-1] = '|') or (buf[j-1] = '[') or (buf[j-1] = '(') or (buf[j-1] = '{')) then
    begin
      bufFunc := '';
      IsFuncFound := false;
      while ((buf[j] in ['a'..'z']) or (buf[j] in ['A'..'Z']) or (buf[j] in ['0'..'9']) or (buf[j] = '_')) do
        begin
          bufFunc := bufFunc + buf[j];
          inc(j);
        end;
      for l := 1 to CurrNumFunc do
        if bufFunc = FuncArr[l].Name then
          begin
            inc(FuncArr[l].FuncCount);
            IsFuncFound := true;
            break;
          end;
      if (bufFunc = 'return') or (bufFunc = 'end') or (bufFunc = 'do') or (bufFunc = 'else') then
        exit;
      if not IsFuncFound then
        CheckOperand;

      if buf[j] = '(' then inc(j);
    end else
  if ((buf[j] in ['0'..'9']) or (buf[j] = '-')) and (not ((buf[j] in ['a'..'z']) or (buf[j] in ['A'..'Z']))) then
    begin
      bufFunc := '';
      if buf[j] = '-' then
        begin
          bufFunc := bufFunc + '-';
          inc(j);
        end;

      while (buf[j] in ['0'..'9']) or (buf[j] = '.') do
        begin
          if (buf[j] = '.') and (not (buf[j+1] in ['0'..'9'])) then
            break;
          bufFunc := bufFunc + buf[j];
          inc(j);
        end;

      CheckOperand;
    end else
  if (buf[j] = '''') or (buf[j] = '"') then
    begin
      bufFunc := '"';
      inc(j);
      while (buf[j] <> '"') and (buf[j] <> '''') do
        begin
          bufFunc := bufFunc + buf[j];
          inc(j);
        end;
      inc(j);
      bufFunc := bufFunc + '"';

      CheckOperand;
    end
  else IsOperatorOrFunc := false;
end;

begin
  CurrNumFunc := 1;
  CurrNumOper := 1;

  Assign(F, 'Dictionary.txt');
  Reset(F);
  for i := 1 to N_MAX do
    begin
      ReadLn(F, Counters[i].Name);
      Counters[i].Count := 0;
    end;
  Close(F);

  for i := 1 to N_MAX do
    begin
      FuncArr[i].Name := '';
      FuncArr[i].FuncCount := 0;
    end;

  for i := 1 to N_MAX do
    begin
      OperArr[i].Name := '';
      OperArr[i].OperCount := 0;
    end;

  N := Analizator.ProgramText_.Lines.Count;
  for i := 0 to N - 1 do
    begin
      buf := ' ' + Analizator.ProgramText_.Lines[i] + ' ';
      j := 2;
      while j <= length(buf) do
        begin
          if buf[j] = '#' then
            break;
          CheckOperatorsAndFuncs(IsOperatorOrFunc);
          if not IsOperatorOrFunc then
            inc(j);
        end;
    end;
  WriteResults(N_MAX, CurrNumFunc, CurrNumOper);
end;

procedure TAnalizator.StartWork_Click(Sender: TObject);
var
  i, j : integer;

begin
  for j := 1 to Table_.RowCount do
        for i := 0 to Table_.ColCount do
          Table_.Cells[i, j] := '';
  Analyze;
end;

procedure TAnalizator.Exit_Click(Sender: TObject);
begin
  Analizator.Close;
end;

end.
