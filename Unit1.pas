unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls, ComCtrls, Menus, Math, xmldom,
  Provider, Xmlxform, XMLIntf, msxmldom, XMLDoc;

type  rute = array of array of integer;
      matrik = array of array of real;
      Graph = record
        mtBobot, mtWaktu : matrik;
        size : integer;
      end;

type  Titik = record
        posisi : TPoint;
        warna : TColor;
      end;

type  Customer = record
        Cust, Permintaan : integer;
        Waktu : Real;
      end;

type
  TMTVRPTW = class(TForm)
    MainMenu1: TMainMenu;
    Menu1: TMenuItem;
    File1: TMenuItem;
    Buka1: TMenuItem;
    Simpan1: TMenuItem;
    Keluar1: TMenuItem;
    Proses1: TMenuItem;
    Reset1: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    sgMatriks: TStringGrid;
    sgCust: TStringGrid;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edBanyak: TEdit;
    edKapasitas: TEdit;
    edWaktu: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    imgTitik: TImage;
    PageControl2: TPageControl;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    mmOutput: TMemo;
    imgHasil: TImage;
    btProses: TButton;
    Timer1: TTimer;
    Label5: TLabel;
    edKecepatan: TEdit;
    Label6: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Label10: TLabel;
    Label1: TLabel;
    Label11: TLabel;
    edMax: TEdit;
    btdataset: TMenuItem;
    XMLDocument1: TXMLDocument;
    btShift10: TButton;
    btShift20: TButton;
    btSwap11: TButton;
    btSwap22: TButton;
    btCross: TButton;
    btOrOpt: TButton;
    bt2Opt: TButton;
    btExchange: TButton;
    btReinsertion: TButton;
    procedure FormCreate(Sender: TObject);
    procedure imgTitikMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgMatriksKeyPress(Sender: TObject; var Key: Char);
    procedure sgMatriksSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure sgMatriksDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgMatriksSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgCustKeyPress(Sender: TObject; var Key: Char);
    procedure sgCustSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure Timer1Timer(Sender: TObject);
    procedure btProsesClick(Sender: TObject);
    procedure Buka1Click(Sender: TObject);
    procedure Simpan1Click(Sender: TObject);
    procedure Reset1Click(Sender: TObject);
    procedure Keluar1Click(Sender: TObject);
    procedure Proses1Click(Sender: TObject);
    procedure btdatasetClick(Sender: TObject);
    procedure btCrossClick(Sender: TObject);
    procedure btShift10Click(Sender: TObject);
    procedure btShift20Click(Sender: TObject);
    procedure btSwap11Click(Sender: TObject);
    procedure btSwap22Click(Sender: TObject);
    procedure btExchangeClick(Sender: TObject);
    procedure bt2OptClick(Sender: TObject);
    procedure btOrOptClick(Sender: TObject);
    procedure btReinsertionClick(Sender: TObject);
  private
    { Private declarations }
    G : graph;
    arTitik : array of Titik;
    arCust : array of Customer;
    mtRute, copyrute, rutepilih : rute;
    Q : integer;
    T, W1, W2 : Real;
  public
    { Public declarations }
    procedure GambarTitik (const index : Integer; const repaint: Boolean);
    procedure GambarSisi(const v1, v2: byte);
    procedure GambarBobot(const v1, v2: byte);
    procedure HapusBobot(const v1, v2: byte);
    procedure HapusSisi(const v1, v2: byte);
    function cekbobot(s:matrik): string;
    function cekcust(s:array of Customer): string;
    procedure Simpan;
    procedure Hapus;
    procedure Buka;
    procedure Dataset;
    function HitungK(rute: array of integer): integer;
    function HitungW(rute: array of integer): real;
    function HitungJarak(rute: array of integer): real;
    function TotalJarak(s: rute): real;
    function TotalWaktu(s: rute): real;
    procedure SequentialInsertion;
    procedure Exchange(const s: rute);
    procedure Cross(const s: rute);
    procedure Swap11(const s: rute);
    procedure Swap22(const s: rute);
    procedure Shift10(const s: rute);
    procedure Shift20(const s: rute);
    procedure Opt2(const s: rute);
    procedure OrOpt(const s: rute);
    procedure Reinsertion(const s: rute);
    procedure Pertubasi(const s: rute);
    procedure Proses;
  end;

var
  MTVRPTW: TMTVRPTW;

implementation

uses dataset;

{$R *.dfm}

procedure TMTVRPTW.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;

  imgTitik.Canvas.Brush.Color := clWhite;
  imgTitik.Canvas.FillRect(Rect(0, 0, imgTitik.Width, imgTitik.Height));

  sgMatriks.Cells[0, 0] := 'Titik';
  sgMatriks.Cells[1, 0] := '0';
  sgMatriks.Cells[0, 1] := '0';

  sgCust.Cells[0, 0] := 'Customer';
  sgCust.Cells[1, 0] := 'Permintaan';
  sgCust.Cells[2, 0] := 'Service Time (Jam)';
  sgCust.ColWidths[0]:=80;
  sgCust.ColWidths[1]:=108;
  sgCust.ColWidths[2]:=150;
end;

procedure TMTVRPTW.imgTitikMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var P, i, b, a : Integer;
begin
  if (Button = mbLeft) then
  begin
    P := Length(arTitik);
    setLength(arTitik, P+1);
    arTitik[P].posisi := Point(X,Y);
    arTitik[P].warna := clYellow;
    G.size := P+1;
    setLength(G.mtBobot, G.size, G.size);
    setLength(G.mtWaktu, G.size, G.size);
    setLength(arcust, P);
    for i := 0 to G.size-2 do
    begin
      G.mtBobot[i, P] := 0;
      G.mtBobot[P, i] := 0;
      G.mtWaktu[i, P] := 0;
      G.mtWaktu[P, i] := 0;
    end;
    if G.size > 1 then
    begin
      sgMatriks.ColCount := sgMatriks.ColCount + 1;
      sgMatriks.RowCount := sgMatriks.RowCount + 1;
      sgMatriks.Col := 2;
      sgMatriks.Row := 1;
    end;
    b := sgMatriks.ColCount - 1;
    sgMatriks.Cells[0, b] := Format('%d', [b-1]);
    sgMatriks.Cells[b, 0] := Format('%d', [b-1]);
    GambarTitik(P, true);

    if P > 1 then
    begin
      sgCust.RowCount := sgCust.RowCount +1 ;
      sgCust.Row := 1;
    end;

    if P>0 then
      sgCust.Cells[0, P] := Format('%d', [P]);

    for a:=0 to length(arcust)-1 do
    begin
      arcust[a].Cust := a+1;
      arcust[a].Permintaan := 0;
      arcust[a].Waktu := 0;
    end;
  end ;
end;

procedure TMTVRPTW.sgMatriksKeyPress(Sender: TObject; var Key: Char);
begin
if not(Key in ['0'..'9', ',']) and not (Key = #13) and not(Key = #8) then
    Key := #00
  else
  if (Key = #13) then
    if sgMatriks.Col > sgMatriks.Row then
      if sgMatriks.Col < (sgMatriks.ColCount - 1) then
        sgMatriks.Col := sgMatriks.Col + 1
      else
        if sgMatriks.Row < (sgMatriks.RowCount - 2) then
        begin
          sgMatriks.Row := sgMatriks.Row + 1;
          sgMatriks.Col := sgMatriks.Row + 1;
        end
    else
    begin
      if sgMatriks.Col = sgMatriks.RowCount then
        if sgMatriks.Row < (sgMatriks.RowCount - 1) then
        begin
          sgMatriks.Row := sgMatriks.Row + 1;
          sgMatriks.Col := 1;
        end
        else
          sgMatriks.Col := sgMatriks.Col + 1;
      Key := #00;
    end;
end;

procedure TMTVRPTW.sgMatriksSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var bobotLama, bobotBaru : real ;
begin
  bobotLama :=  G.mtBobot[ARow-1, ACol-1];
  if (Value='') and (bobotLama <> 0) then
  begin
    HapusSisi(ARow-1, ACol-1);
    sgMatriks.Cells[ARow, ACol] := value;
    G.mtBobot[ARow-1, ACol-1] := bobotBaru;
    G.mtBobot[ACol-1, ARow-1] := bobotBaru;
  end
  else
  if Value <> '' then
  begin
    bobotBaru := StrTofloat(Value);
    if (bobotLama=0) and (bobotBaru <> 0) then
    begin
      sgMatriks.Cells[ARow, ACol] := Value;
      G.mtBobot[ARow-1, ACol-1] := bobotBaru;
      G.mtBobot[ACol-1, ARow-1] := bobotBaru;
      GambarSisi(ARow-1, ACol-1);
    end
    else
    if (bobotLama <> 0) and (bobotBaru = 0) then
    begin
      HapusSisi(ARow-1, ACol-1);
      sgMatriks.Cells[ARow, ACol] := Value;
      G.mtBobot[ARow-1, ACol-1] := 0;
      G.mtBobot[ACol-1, ARow-1] := 0;
    end
    else
    if (bobotLama <> 0) and (bobotBaru <> 0) and (bobotLama <> bobotBaru) then
    begin
      HapusSisi(ARow-1, ACol-1);
      sgMatriks.Cells[ARow, ACol] := Value;
      G.mtBobot[ARow-1, ACol-1] := bobotBaru;
      G.mtBobot[ACol-1, ARow-1] := bobotBaru;
      GambarSisi(ARow-1, ACol-1);
    end
  end;
end;

procedure TMTVRPTW.sgMatriksDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if (ACol = ARow) then
    if not (gdFixed in State) then
    begin
      sgMatriks.Canvas.Brush.Color := clGray;
      sgMatriks.Canvas.FillRect(Rect);
      sgMatriks.Canvas.Brush.Color := clWhite;
    end
  else
  if not (gdSelected in State) and not (gdFixed in State) then
    if sgMatriks.Cells[ACol, ARow] = '' then
      sgMatriks.Cells[ACol, ARow] := '0';
end;

procedure TMTVRPTW.sgMatriksSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := ACol <> ARow;
end;

procedure TMTVRPTW.GambarBobot(const v1, v2: byte);
var P1, P2: TPoint; xC, yC: integer; bobot : real;
begin
  P1 := arTitik[v1].posisi;
  P2 := arTitik[v2].posisi;

  xC := Round((P1.X + P2.X)/2);
  yC := Round((P1.Y + P2.Y)/2);
  bobot := G.mtBobot[v1, v2];

  imgTitik.Canvas.Font.Color := clBlue;
  imgTitik.Canvas.TextOut(xC, yC+6, FloatToStr(bobot));
  imgTitik.Canvas.Font.Color := clBlack;
end;

procedure TMTVRPTW.GambarSisi(const v1, v2: byte);
var P1, P2: TPoint;
begin
  P1 := arTitik[v1].posisi;
  P2 := arTitik[v2].posisi;
  imgTitik.Canvas.Pen.Color := clBlack;
  imgTitik.Canvas.MoveTo(P1.X, P1.Y);
  imgTitik.Canvas.LineTo(P2.X, P2.Y);

  GambarBobot(v1, v2);
  GambarTitik(v1, true);
  GambarTitik(v2, true);
end;

procedure TMTVRPTW.GambarTitik(const index: Integer;
  const repaint: Boolean);
var X, Y : Integer;
begin
    X := arTitik[index].posisi.X;
    Y := arTitik[index].posisi.Y;

    imgTitik.Canvas.Pen.Color := clBlack;
    imgTitik.Canvas.Ellipse(X-6, Y-6, X+6, Y+6);
    imgtitik.Canvas.Brush.Color := arTitik[index].warna;

    imgTitik.Canvas.FloodFill(X, Y, clBlack, fsBorder);
    imgTitik.Canvas.Brush.Color := clWhite;
    imgTitik.Canvas.Font.Color := clRed;
    imgTitik.Canvas.Font.Style := [fsBold];

    imgTitik.Canvas.TextOut(X-5, Y+10, Format('%d', [index]));
    imgTitik.Canvas.Font.Color := clBlack;
    imgTitik.Canvas.Font.Style := [];

    imghasil.Canvas.Pen.Color := clBlack;
    imghasil.Canvas.Ellipse(X-6, Y-6, X+6, Y+6);
    imghasil.Canvas.Brush.Color := arTitik[index].warna;

    imghasil.Canvas.FloodFill(X, Y, clBlack, fsBorder);
    imghasil.Canvas.Brush.Color := clWhite;
    imghasil.Canvas.Font.Color := clRed;
    imghasil.Canvas.Font.Style := [fsBold];

    imghasil.Canvas.TextOut(X-5, Y+10, Format('%d', [index]));
    imghasil.Canvas.Font.Color := clBlack;
    imghasil.Canvas.Font.Style := [];

    if repaint then imgTitik.Repaint();
end;

procedure TMTVRPTW.HapusBobot(const v1, v2: byte);
var P1, P2: TPoint; xC, yC: integer; bobot : real;
begin
  P1 := arTitik[v1].posisi;
  P2 := arTitik[v2].posisi;

  xC := Round((P1.X + P2.X)/2);
  yC := Round((P1.Y + P2.Y)/2);
  bobot := G.mtBobot[v1, v2];

  imgTitik.Canvas.Font.Color := clwhite;
  imgTitik.Canvas.TextOut(xC, yC+6, FloatToStr(bobot));
  imgTitik.Canvas.Font.Color := clBlack;
end;

procedure TMTVRPTW.HapusSisi(const v1, v2: byte);
Var p1, p2: TPoint;
begin
  P1 := arTitik[v1].posisi;
  P2 := arTitik[v2].posisi;
  imgTitik.Canvas.Pen.Color := clWhite;
  imgTitik.Canvas.MoveTo(P1.X, P1.Y);
  imgTitik.Canvas.LineTo(P2.X, P2.Y);

  HapusBobot(v1, v2);
  GambarTitik(v1, true);
  GambarTitik(v2, true);
end;

procedure TMTVRPTW.sgCustKeyPress(Sender: TObject; var Key: Char);
begin
  if (sgCust.Col = 1) and not(Key in ['0'..'9']) and not (Key = #13) and not(Key = #8) then
  begin
    Application.MessageBox('Masukkan Bilangan Integer!','Information', MB_OK or MB_ICONEXCLAMATION);
    Key := #00;
  end
  else
  if not(Key in ['0'..'9', ',']) and not (Key = #13) and not(Key = #8) then
    Key := #00
  else
  if (Key = #13) then
  begin
    if sgCust.Col < sgCust.ColCount-1 then sgCust.Col := sgCust.Col + 1
    else if sgCust.Row < sgCust.RowCount-1 then
    begin
      sgCust.Row := sgCust.Row + 1;
      sgCust.Col := sgCust.Col - 1;
    end;
    Key := #00;
  end;
end;

procedure TMTVRPTW.sgCustSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: String);
var key: char;
begin
  if Value <> '' then
    if sgCust.Col = 1 then
      arcust[ARow-1].Permintaan:=strtoint(value)
    else
      arcust[ARow-1].Waktu:=strtofloat(value);
end;

function TMTVRPTW.cekbobot(s: matrik): string;
var total: real; a,b: integer;
begin
  total:=0;
  for a:=0 to length(s)-1 do
    for b:=0 to length(s)-1 do
      total:=total+g.mtbobot[a,b];
  if total=0 then result:=''
  else result:='ada';
end;

function TMTVRPTW.cekcust(s: array of Customer): string;
var a,p:integer; w:real;
begin
  p:=0;
  w:=0;
  for a:=0 to length(s)-1 do
  begin
    p:=p+s[a].Permintaan;
    w:=w+s[a].Waktu;
  end;
  if (p=0) or (w=0) then result:=''
  else result:='ada';
end;

procedure TMTVRPTW.Timer1Timer(Sender: TObject);
begin
  StatusBar2.Panels[0].Text:=DateToStr(date) + ' ' + TimeToStr(time);
end;

procedure TMTVRPTW.Buka;
var myfile: textfile;
    jenis, namafile : string;
    i, j, bykTitik, bykParameter: byte;
    X, Y, permintaan, banyak, kapasitas : integer;
    bobot, waktu, kecepatan : real;
begin
  if opendialog1.Execute then
  begin
    Hapus;
    namafile := opendialog1.FileName;
    assignfile(myfile, namafile);
    reset(myfile);
    readln(myfile, jenis);
    readln(myfile, bykTitik);
    setLength(G.mtBobot, bykTitik, bykTitik);
    setLength(G.mtWaktu, bykTitik, bykTitik);
    G.size := bykTitik;
    setlength(arTitik, bykTitik);
    sgMatriks.ColCount := bykTitik+1;
    SgMatriks.RowCount := bykTitik+1;
    readln(myfile, jenis);
    for i := 0 to bykTitik-1 do
      for j := 0 to bykTitik-1 do
        if j > i then
        begin
          readln(myfile, bobot);
          G.mtBobot[i, j] := bobot;
          G.mtBobot[j, i] := bobot;
          sgMatriks.Cells[j+1, i+1] := FloatToStr (bobot);
          sgMatriks.Cells[i+1, j+1] := FloatToStr (bobot);
        end;
    for i := 1 to bykTitik do
    begin
      sgMatriks.Cells[0, i] := Format('%d', [i-1]);
      sgMatriks.Cells[i, 0] := Format('%d', [i-1]);
    end;
    sgCust.ColWidths[0]:=80;
    sgCust.ColWidths[1]:=108;
    sgCust.ColWidths[2]:=150;
    readln(myfile, jenis);
    readln(myfile, bykParameter);
    setlength(arCust, bykParameter);
    sgCust.RowCount:=bykParameter+1;
    sgCust.Cells[0, 0] := 'Customer';
    sgCust.Cells[1, 0] := 'Permintaan';
    sgCust.Cells[2, 0] := 'Service Time (Jam)';
    for i:=0 to length(arCust)-1 do
    begin
      arCust[i].Cust := i+1;
      sgCust.Cells[0, i+1] := Format('%d', [i+1]);
    end;
    readln(myfile, jenis);
    for i:=0 to length(arCust)-1 do
    begin
      readln(myfile, permintaan);
      arCust[i].Permintaan:=permintaan;
      sgCust.Cells[1,i+1]:=inttostr(permintaan);
    end;
    readln(myfile, jenis);
    for i:=0 to length(arCust)-1 do
    begin
      readln(myfile, waktu);
      arCust[i].Waktu:=waktu;
      sgCust.Cells[2,i+1]:=floattostr(waktu);
    end;
    readln(myfile, jenis);
    readln(myfile, banyak);
    edBanyak.Text:=inttostr(banyak);
    readln(myfile, jenis);
    readln(myfile, kapasitas);
    edKapasitas.Text:=inttostr(kapasitas);
    readln(myfile, jenis);
    readln(myfile, waktu);
    edWaktu.Text:=floattostr(waktu);
    readln(myfile, jenis);
    readln(myfile, kecepatan);
    edKecepatan.Text:=floattostr(kecepatan);
    setLength(arTitik, bykTitik);
    readln(myfile, jenis);
    for i := 0 to bykTitik-1 do
    begin
      readln(myfile, X, Y);
      arTitik[i].posisi := Point(X, Y);
      arTitik[i].warna := clYellow;
    end;
    for i := 0 to bykTitik-1 do
      for j := 0 to bykTitik-1 do
        if j > i then
          if G.mtBobot[i, j] <> 0 then
            GambarSisi(i, j);
    closefile(myfile);
  end;
end;

procedure TMTVRPTW.Hapus;
var i, j, bykTitik: byte;
begin
  mmOutput.Lines.Clear;
  imgTitik.Canvas.Brush.Color := clWhite;
  imgTitik.Canvas.FillRect(Rect(0, 0, imgTitik.Width, imgTitik.Height));
  imghasil.Canvas.Brush.Color := clWhite;
  imghasil.Canvas.FillRect(Rect(0, 0, imghasil.Width, imghasil.Height));
  bykTitik := G.size;
  if bykTitik <> 0 then
  begin
    setLength(arTitik, 0);
    for i := 1 to bykTitik do
      for j := 1 to bykTitik do
        sgMatriks.Cells[i, j] := '';
    for i := 0 to bykTitik-1 do
      for j := 0 to bykTitik-1 do
        G.mtBobot[i,j] := 0;
    G.size := 0;
    setLength(G.mtBobot, 0, 0);
    sgMatriks.ColCount := 2;
    sgMatriks.RowCount := 2;
  end;
  edKapasitas.Text:='';
  edBanyak.Text:='';
  edWaktu.Text:='';
  edKecepatan.Text:='';
  edmax.Text:='';
  for i:=1 to 2 do
    for j:=1 to length(arCust) do
      sgCust.Cells[i,j]:='';
  sgCust.Cells[0,1]:='';
  sgCust.ColCount := 3;
  sgCust.RowCount := 2;
  setlength(arCust, 0);
  setlength(mtrute,0);
end;

procedure TMTVRPTW.Simpan;
var i, j, bykTitik, bykParameter : byte;
    namafile: string;
    myfile: textfile;
    X, Y, banyak, kapasitas : Integer;
begin
  if savedialog1.Execute then
  begin
    bykTitik := G.size;
    bykParameter := length(arCust);
    namafile := savedialog1.FileName;
    assignfile(myfile, namafile);
    rewrite(myfile);
    writeln(myfile, '[Banyak titik]');
    writeln(myfile, bykTitik);
    writeln(myfile, '[Bobot sisi]');
    for i := 0 to bykTitik-1 do
      for j := 0 to bykTitik-1 do
        if j > i then
          writeln(myfile, G.mtBobot[i, j]);
    writeln(myfile, '[Banyak arCust]');
    writeln(myfile, bykParameter);
    writeln(myfile, '[Parameter permintaan]');
    for i:=0 to bykParameter-1 do
    begin
      X:=arCust[i].Permintaan;
      writeln(myfile, X);
    end;
    writeln(myfile, '[Parameter service time]');
    for i:=0 to bykParameter-1 do
      writeln(myfile, arCust[i].Waktu);
    banyak:=strtoint(edBanyak.Text);
    kapasitas:=strtoint(edKapasitas.Text);
    writeln(myfile, '[Banyak Kendaraan]');
    writeln(myfile, banyak);
    writeln(myfile, '[Kapasitas Kendaraan]');
    writeln(myfile, kapasitas);
    writeln(myfile, '[Time Window]');
    writeln(myfile, strtofloat(edWaktu.Text));
    writeln(myfile, '[Kecepatan Kendaraan]');
    writeln(myfile, strtofloat(edKecepatan.Text));
    writeln(myfile, '[Posisi titik]');
    for i := 0 to bykTitik do
    begin
      X := arTitik[i].posisi.X;
      Y := arTitik[i].posisi.Y;
      writeln(myfile, X, ' ', Y);
    end;
    closefile(myfile);
  end;
end;

procedure TMTVRPTW.Buka1Click(Sender: TObject);
begin
 Buka;
end;

procedure TMTVRPTW.Simpan1Click(Sender: TObject);
begin
  Simpan;
end;

procedure TMTVRPTW.Reset1Click(Sender: TObject);
begin
  Hapus;
end;

procedure TMTVRPTW.Proses1Click(Sender: TObject);
begin
  Proses;
end;

procedure TMTVRPTW.btProsesClick(Sender: TObject);
begin
  bt2Opt.Visible:=true;
  btCross.Visible:=true;
  btExchange.Visible:=true;
  btOrOpt.Visible:=true;
  btReinsertion.Visible:=true;
  btShift10.Visible:=true;
  btShift20.Visible:=true;
  btSwap11.Visible:=true;
  btSwap22.Visible:=true;
  Proses;
end;

procedure TMTVRPTW.Keluar1Click(Sender: TObject);
begin
  MTVRPTW.Close;
end;

function TMTVRPTW.HitungK(rute: array of integer): integer;
var a, totalK: integer;
begin
  totalK:=0;
  for a:=1 to length(rute)-2 do
    totalK:=totalK+arCust[rute[a]-1].Permintaan;
  result:=totalK;
end;

function TMTVRPTW.HitungW(rute: array of integer): real;
var a: integer; TotalW: real;
begin
  TotalW:=0;
  for a:=0 to length(rute)-2 do
    totalW:=totalW+g.mtWaktu[rute[a], rute[a+1]];
  for a:=1 to length(rute)-2 do
    totalW:=totalW+arCust[rute[a]-1].Waktu;
  result:=totalW;
end;

function TMTVRPTW.TotalWaktu(s: rute): real;
var a : integer; total : real;
begin
  total := 0;
  for a:=0 to length(s)-1 do
    total := total + HitungW(s[a]);
  result := total;
end;

function TMTVRPTW.HitungJarak(rute: array of integer): real;
var i : integer;
    jumlah: real;
begin
  jumlah:=0;
  for i:=0 to length(rute)-2 do
    jumlah:= jumlah + g.mtbobot[rute[i], rute[i+1]];
  result:= jumlah;
end;

function TMTVRPTW.TotalJarak(s: rute): real;
var a : integer; total : real;
begin
  total := 0;
  for a:=0 to length(s)-1 do
    total := total + HitungJarak(s[a]);
  result := total;
end;

//algoritma
procedure TMTVRPTW.SequentialInsertion;
var a,b,c,d,v,custkecil,kendala : integer;
    bobotkecil,waktu,jumlahjarak,jumlahsem : real;
    himpU, himpV : set of byte;
    fixmtrute,copymtrute : array of integer;
    rute : array of string;
begin
  himpU:=[];
  for a:=1 to length(arCust) do
    himpU:=himpU+[a];

  himpV:=[];
  setlength(mtRute,1);

  Randomize;
  v:=1+random(g.size-1);

  {bobotkecil:=0;
  for a:=1 to g.size-1 do
    if g.mtBobot[0,a]>bobotkecil then
    begin
      bobotkecil:=g.mtBobot[0,a];
      v:=a;
    end;}

  setlength(mtrute[0], 3);
  mtrute[0, 0] := 0;
  mtrute[0, 1] := v;
  mtrute[0, 2] := 0;
  himpV:=himpV+[v];

  while himpV<>himpU do
  begin
    a:=mtRute[length(mtrute)-1, length(mtRute[length(mtrute)-1])-2];
    bobotkecil:=9999;
    b:=1;
    while b<g.size do
    begin
      if ((a<>b) and (b in himpU-himpV)) and (g.mtBobot[a,b]<bobotkecil) then
      begin
        bobotkecil:=g.mtBobot[a,b];
        custkecil:=b;
      end;
      b:=b+1;
    end;

    kendala:=HitungK(mtrute[length(mtRute)-1])+arCust[custkecil-1].Permintaan;
    waktu:=HitungW(mtrute[length(mtRute)-1])+arCust[custkecil-1].Waktu;

    if (kendala<Q) and (waktu<T) then
    begin
      setlength(fixmtRute, length(mtrute[length(mtrute)-1]));
      for c:=0 to length(mtrute[length(mtrute)-1])-1 do
        fixmtrute[c]:=mtRute[length(mtrute)-1, c];

      c:=1;
      jumlahjarak:=9999;
      while c<length(mtrute[length(mtrute)-1]) do
      begin
        setlength(copymtRute, length(mtrute[length(mtrute)-1])+1);
        for b:=0 to length(mtrute[length(mtrute)-1])-1 do
          copymtrute[b]:=mtRute[length(mtrute)-1, b];

        for d:=length(copymtrute)-2 downto c do
          copymtrute[d+1]:=copymtrute[d];
        copymtrute[c]:=custkecil;

        jumlahsem:=HitungJarak(copymtrute);
        if jumlahsem<jumlahjarak then
        begin
          setlength(fixmtrute, length(copymtrute));
          for d:=0 to length(copymtrute)-1 do
            fixmtRute[d]:=copymtrute[d];
          jumlahjarak:=jumlahsem;
        end;
        c:=c+1;
      end;
      setlength(mtrute[length(mtrute)-1], length(fixmtrute));
      for d:=0 to length(fixmtrute)-1 do
        mtRute[length(mtrute)-1, d]:=fixmtrute[d];
    end
    else
    begin
      setlength(mtrute, length(mtrute)+1);
      setlength(mtrute[length(mtrute)-1], 3);
      mtrute[length(mtrute)-1, 0] := 0;
      mtrute[length(mtrute)-1, 1] := custkecil;
      mtrute[length(mtrute)-1, 2] := 0;
    end;
    himpV:=himpV+[custkecil];
  end;


//---
  mmoutput.Lines.Add('Rute Sementara dengan Menggunakan Algoritma Sequential Insertion');
  setlength(rute, length(mtrute));
  for a:=0 to length(mtrute)-1 do
  begin
    for b:=0 to length(mtrute[a])-1 do
      if rute[a]='' then
        rute[a]:=rute[a] + inttostr(mtrute[a,b])
      else
        rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
    mmOutput.Lines.Add('PR ' + inttostr(a+1) + ' = [' + rute[a] + '], jarak ' +
                        formatfloat('0.##',HitungJarak(mtrute[a])) + ' km, waktu '+
                        formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
  end;

  mmOutput.Lines.Add('Dengan total jarak tempuh ' + formatfloat('0.##',TotalJarak(mtrute)) + ' km'+
                    ' dan total waktu ' + formatfloat('0.#',TotalWaktu(mtrute)) + ' jam.');
  {mmOutput.Lines.Add('---------------------------------------'+
                      '//'+
                      '---------------------------------------'); }
//---
end;

procedure TMTVRPTW.Cross(const s: rute);
var a, b, c, i, j, k, t1, K1, K2 : integer;
    totaljarak1, totaljarak2, totalwaktu1, totalwaktu2 : real;
    artampung, arsimpan, arfix : rute;
begin
  setlength(arfix, length(s));
  for j:=0 to length(s)-1 do
  begin
    setlength(arfix[j], length(s[j]));
    for k:=0 to length(s[j])-1 do
      arfix[j,k]:=s[j,k];
  end;

  totaljarak1:=totaljarak(arfix);
  totalwaktu1:=totalwaktu(arfix);

  setlength(artampung, 2);
  for i:=0 to length(s)-2 do
  begin
    a:=2;
    while a < length(s[i])-1 do
    begin
      t1:=s[i,a];
      if i=0 then b:=1 else b:=0;

      while b < length(s) do
      begin
        if i<>b then
        begin
          c:=2;
          while c < length(s[b])-1 do
          begin
            setlength(arsimpan, length(s));
            for j:=0 to length(s)-1 do
            begin
              setlength(arsimpan[j], length(s[j]));
              for k:=0 to length(s[j])-1 do
                arsimpan[j,k]:=s[j,k];
            end;

            setlength(artampung[0], length(s[i]));
            for j:=0 to length(s[i])-1 do
              artampung[0,j]:=s[i,j];
            setlength(artampung[1], length(s[b]));
            for j:=0 to length(s[b])-1 do
              artampung[1,j]:=s[b,j];

            artampung[0,a]:=artampung[1,c];
            artampung[1,c]:=t1;

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

            if (K1<Q) and (K2<Q) then
            begin
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              totalwaktu2:=totalwaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (totalwaktu2<totalwaktu1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;
              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(s)-1 do
  begin
    setlength(copyrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      copyrute[i,j]:=arfix[i,j];
  end;
end;

procedure TMTVRPTW.Shift10(const s: rute);
var a, b, c, i, j, k, l, t1, K1, K2 : integer;
    totaljarak1, totaljarak2 : real;
    artampung, arsimpan, arfix : rute;
begin
  setlength(arfix, length(s));
  for j:=0 to length(s)-1 do
  begin
    setlength(arfix[j], length(s[j]));
    for k:=0 to length(s[j])-1 do
      arfix[j,k]:=s[j,k];
  end;

  totaljarak1:=totaljarak(arfix);
  W1:=TotalWaktu(arfix);

  setlength(artampung, 2);
  for i:=0 to length(s)-1 do
  begin
    a:=1;
    while a < length(s[i])-1 do
    begin
      t1:=s[i,a];
      if i=0 then b:=1 else b:=0;

      while b < length(s) do
      begin
        if i<>b then
        begin
          c:=1;
          while c < length(s[b]) do
          begin
            setlength(arsimpan, length(s));
            for j:=0 to length(s)-1 do
            begin
              setlength(arsimpan[j], length(s[j]));
              for k:=0 to length(s[j])-1 do
                arsimpan[j,k]:=s[j,k];
            end;

            setlength(artampung[0], length(s[i]));
            for j:=0 to length(s[i])-1 do
              artampung[0,j]:=s[i,j];
            setlength(artampung[1], length(s[b]));
            for j:=0 to length(s[b])-1 do
              artampung[1,j]:=s[b,j];

            for j:=a to length(artampung[0])-2 do
              artampung[0,j]:=s[i,j+1];
            setlength(artampung[0], length(artampung[0])-1);

            setlength(artampung[1], length(artampung[1])+1);
            for j:=length(artampung[1])-2 downto c do
              artampung[1,j+1]:=s[b,j];
            artampung[1,c]:=t1;

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

            if ((K1<Q) and (K2<Q)) then
            begin
              setlength(arsimpan[i], length(artampung[0]));
              setlength(arsimpan[b], length(artampung[1]));
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              W2:=TotalWaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (W2<W1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;
              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(s)-1 do
  begin
    setlength(copyrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      copyrute[i,j]:=arfix[i,j];
  end;
end;

procedure TMTVRPTW.Shift20(const s: rute);
var a, b, c, i, j, k, l, Q, t1, t2, K1, K2 : integer;
    totaljarak1, totaljarak2 : real;
    artampung, arsimpan, arfix : rute;
begin
  Q:=strtoint(edkapasitas.Text);
  setlength(arfix, length(s));
  for j:=0 to length(s)-1 do
  begin
    setlength(arfix[j], length(s[j]));
    for k:=0 to length(s[j])-1 do
      arfix[j,k]:=s[j,k];
  end;

  totaljarak1:=totaljarak(arfix);
  W1:=TotalWaktu(arfix);

  setlength(artampung, 2);
  for i:=0 to length(s)-1 do
  begin
    a:=1;
    while a < length(s[i])-2 do
    begin
      t1:=s[i,a];
      t2:=s[i,a+1];
      if i=0 then b:=1 else b:=0;

      while b < length(s) do
      begin
        if i<>b then
        begin
          c:=1;
          while c < length(s[b]) do
          begin
            setlength(arsimpan, length(s));
            for j:=0 to length(s)-1 do
            begin
              setlength(arsimpan[j], length(s[j]));
              for k:=0 to length(s[j])-1 do
                arsimpan[j,k]:=s[j,k];
            end;

            setlength(artampung[0], length(s[i]));
            for j:=0 to length(s[i])-1 do
              artampung[0,j]:=s[i,j];
            setlength(artampung[1], length(s[b]));
            for j:=0 to length(s[b])-1 do
              artampung[1,j]:=s[b,j];

            for j:=a to length(artampung[0])-1 do
              artampung[0,j]:=s[i,j+2];
            setlength(artampung[0], length(artampung[0])-2);

            setlength(artampung[1], length(artampung[1])+2);
            for j:=length(artampung[1])-2 downto c do
              artampung[1,j+1]:=s[b,j-1];
            artampung[1,c]:=t1;
            artampung[1,c+1]:=t2;

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

            if ((K1<Q) and (K2<Q)) then
            begin
              setlength(arsimpan[i], length(artampung[0]));
              setlength(arsimpan[b], length(artampung[1]));
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              W2:=TotalWaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (W2<W1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;
              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(s)-1 do
  begin
    setlength(copyrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      copyrute[i,j]:=arfix[i,j];
  end;
end;

procedure TMTVRPTW.Swap11(const s: rute);
var a, b, c, i, j, k, l, Q, t1, K1, K2 : integer;
    totaljarak1, totaljarak2 : real;
    artampung, arsimpan, arfix : rute;
begin
  Q:=strtoint(edkapasitas.Text);
  setlength(arfix, length(s));
  for j:=0 to length(s)-1 do
  begin
    setlength(arfix[j], length(s[j]));
    for k:=0 to length(s[j])-1 do
      arfix[j,k]:=s[j,k];
  end;

  totaljarak1:=totaljarak(arfix);
  W1:=TotalWaktu(arfix);
  
  setlength(artampung, 2);
  for i:=0 to length(s)-1 do
  begin
    a:=1;
    while a < length(s[i])-1 do
    begin
      t1:=s[i,a];
      if i=0 then b:=1 else b:=0;

      while b < length(s) do
      begin
        if i<>b then
        begin
          c:=1;
          while c < length(s[b])-1 do
          begin
            setlength(arsimpan, length(s));
            for j:=0 to length(s)-1 do
            begin
              setlength(arsimpan[j], length(s[j]));
              for k:=0 to length(s[j])-1 do
                arsimpan[j,k]:=s[j,k];
            end;

            setlength(artampung[0], length(s[i]));
            for j:=0 to length(s[i])-1 do
              artampung[0,j]:=s[i,j];
            setlength(artampung[1], length(s[b]));
            for j:=0 to length(s[b])-1 do
              artampung[1,j]:=s[b,j];

            artampung[0,a]:=artampung[1,c];
            artampung[1,c]:=t1;

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

            if ((K1<Q) and (K2<Q)) then
            begin
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              W2:=TotalWaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (W2<W1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;
              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(s)-1 do
  begin
    setlength(copyrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      copyrute[i,j]:=arfix[i,j];
  end;
end;

procedure TMTVRPTW.Swap22(const s: rute);
var a, b, c, i, j, k, l, Q, t1, t2, K1, K2 : integer;
    totaljarak1, totaljarak2 : real;
    artampung, arsimpan, arfix : rute;
begin
  Q:=strtoint(edkapasitas.Text);
  setlength(arfix, length(s));
  for j:=0 to length(s)-1 do
  begin
    setlength(arfix[j], length(s[j]));
    for k:=0 to length(s[j])-1 do
      arfix[j,k]:=s[j,k];
  end;

  totaljarak1:=totaljarak(arfix);
  W1:=TotalWaktu(arfix);

  setlength(artampung, 2);
  for i:=0 to length(s)-1 do
  begin
    a:=1;
    while a < length(s[i])-2 do
    begin
      t1:=s[i,a];
      t2:=s[i,a+1];
      if i=0 then b:=1 else b:=0;

      while b < length(s) do
      begin
      if i<>b then
      begin
          c:=1;
          while c < length(s[b])-2 do
          begin
            setlength(arsimpan, length(s));
            for j:=0 to length(s)-1 do
            begin
              setlength(arsimpan[j], length(s[j]));
              for k:=0 to length(s[j])-1 do
                arsimpan[j,k]:=s[j,k];
            end;

            setlength(artampung[0], length(s[i]));
            for j:=0 to length(s[i])-1 do
              artampung[0,j]:=s[i,j];
            setlength(artampung[1], length(s[b]));
            for j:=0 to length(s[b])-1 do
              artampung[1,j]:=s[b,j];

            artampung[0,a]:=artampung[1,c];
            artampung[0,a+1]:=artampung[1,c+1];
            artampung[1,c]:=t1;
            artampung[1,c+1]:=t2;

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

            if ((K1<Q) and (K2<Q)) then
            begin
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              W2:=TotalWaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (W2<W1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;
              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(s)-1 do
  begin
    setlength(copyrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      copyrute[i,j]:=arfix[i,j];
  end;
end;

procedure TMTVRPTW.Exchange(const s: rute);
var a, b, i, j, k, t1: integer;
    jaraklama, jarakbaru : real;
    artampung, arsimpan : array of integer;
begin
  for i:=0 to length(s)-1 do
  begin
    jaraklama:=HitungJarak(s[i]);
    W1:=HitungW(s[i]);
    a := 1;

    setlength(arsimpan, length(s[i]));
    for k:=0 to length(s[i])-1 do
      arsimpan[k]:=s[i,k];

    while a < length(s[i])-2 do
    begin
      t1:=s[i,a];
      b := a+1;
      while b < length(s[i])-1 do
      begin
        setlength(artampung, length(s[i]));
        for j:=0 to length(s[i])-1 do
          artampung[j]:=s[i,j];

        artampung[a]:=artampung[b];
        artampung[b]:=t1;

        jarakbaru:=HitungJarak(artampung);
        W2:=HitungW(arTampung);

        if (jarakbaru<jaraklama) and (W2<W1) then
        begin
          for j:=0 to length(artampung)-1 do
            arsimpan[j]:=artampung[j];
          jaraklama:=jarakbaru;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;

    for k:=0 to length(s[i])-1 do
      copyrute[i,k]:=arsimpan[k];
  end;
end;

procedure TMTVRPTW.Opt2(const s: rute);
var a,b,c,d,t1,t2 : integer;
    jaraklama,jarakbaru : real;
    artampung : array of integer;
    arsimpan : rute;
begin
  setlength(arsimpan, length(s));
  for a:=0 to length(s)-1 do
  begin
    setlength(arsimpan[a], length(s[a]));
    for b:=0 to length(s[a])-1 do
      arsimpan[a,b]:=s[a,b];
  end;

  for a:=0 to length(s)-1 do
  begin
    jaraklama:=HitungJarak(arsimpan[a]);
    w1:=HitungW(arsimpan[a]);
    c:=length(arsimpan[a]);

    if (c>=7) then
    begin
      b:=2;
      while b<length(s[a])-4 do
      begin
        t1:=s[a,b];
        t2:=s[a,b+2];

        setlength(artampung, length(s[a]));
        for d:=0 to length(s[a])-1 do
          artampung[d]:=s[a,d];

        artampung[b+2]:=t1;
        artampung[b]:=t2;

        jarakbaru:=HitungJarak(artampung);
        w2:=HitungW(artampung);

        if (jarakbaru<jaraklama) and (w2<w1) then
          for d:=1 to length(s[a])-2 do
            arsimpan[a,d]:=artampung[d];

        b:=b+1;
      end;
    end;
  end;

  for a:=0 to length(arsimpan)-1 do
    for b:=0 to length(arsimpan[a])-1 do
      copyrute[a,b]:=arsimpan[a,b];
end;

procedure TMTVRPTW.OrOpt(const s: rute);
var a,b,c,d,t1,t2 : integer;
    jaraklama,jarakbaru : real;
    artampung : array of integer;
    arsimpan : rute;
begin
  setlength(arsimpan, length(s));
  for a:=0 to length(s)-1 do
  begin
    setlength(arsimpan[a], length(s[a]));
    for b:=0 to length(s[a])-1 do
      arsimpan[a,b]:=s[a,b];
  end;

  for a:=0 to length(s)-1 do
  begin
    jaraklama:=HitungJarak(arsimpan[a]);
    w1:=HitungW(arsimpan[a]);

    b:=1;
    while b<length(s[a])-2 do
    begin
      t1:=s[a,b];
      t2:=s[a,b+1];

      c:=1;
      while c<length(s[a])-2 do
      begin
        setlength(artampung, length(s[a]));
        for d:=0 to length(s[a])-1 do
          artampung[d]:=s[a,d];

        if c<>b then
        begin
          for d:=b to length(artampung)-2 do
              artampung[d]:=s[a,d+2];

          for d:=length(artampung)-3 downto c do
            artampung[d+1]:=artampung[d-1];

          artampung[c]:=t1;
          artampung[c+1]:=t2;

          jarakbaru:=HitungJarak(artampung);
          w2:=HitungW(artampung);

          if (jarakbaru<jaraklama) and (w2<w1) then
            for d:=1 to length(s[a])-2 do
              arsimpan[a,d]:=artampung[d];
        end;
        c:=c+1;
      end;
      b:=b+1;
    end;
  end;

  for a:=0 to length(arsimpan)-1 do
    for b:=0 to length(arsimpan[a])-1 do
      copyrute[a,b]:=arsimpan[a,b];
end;

procedure TMTVRPTW.Reinsertion(const s: rute);
var a,b,c,d,t1 : integer;
    jaraklama,jarakbaru : real;
    artampung : array of integer;
    arsimpan : rute;
begin
  setlength(arsimpan, length(s));
  for a:=0 to length(s)-1 do
  begin
    setlength(arsimpan[a], length(s[a]));
    for b:=0 to length(s[a])-1 do
      arsimpan[a,b]:=s[a,b];
  end;

  for a:=0 to length(s)-1 do
  begin
    jaraklama:=HitungJarak(arsimpan[a]);
    w1:=HitungW(arsimpan[a]);

    b:=1;
    while b<length(s[a])-1 do
    begin
      t1:=s[a,b];

      c:=1;
      while c<length(s[a])-1 do
      begin
        setlength(artampung, length(s[a]));
        for d:=0 to length(s[a])-1 do
          artampung[d]:=s[a,d];

        if c<>b then
        begin
          for d:=b to length(artampung)-2 do
              artampung[d]:=s[a,d+1];

          for d:=length(artampung)-3 downto c do
            artampung[d+1]:=artampung[d];

          artampung[c]:=t1;

          jarakbaru:=HitungJarak(artampung);
          w2:=HitungW(artampung);

          if (jarakbaru<jaraklama) and (w2<w1) then
            for d:=1 to length(s[a])-2 do
              arsimpan[a,d]:=artampung[d];
        end;
        c:=c+1;
      end;
      b:=b+1;
    end;
  end;

  for a:=0 to length(arsimpan)-1 do
    for b:=0 to length(arsimpan[a])-1 do
      copyrute[a,b]:=arsimpan[a,b];
end;

procedure TMTVRPTW.Pertubasi(const s: rute);
var a, p: integer;
begin
  Randomize;
  p:=1+random(2);

  a:=1;
  while a<=p do
  begin
    Swap11(s);
    a:=a+1;
  end;
end;

procedure TMTVRPTW.Proses;
var a,b,i,j,k,n,u,v,xC,yC,banyak,iter,itermax,pilihiter,hitungkendaraan,kendaraan : integer;
    P1,P2 : TPoint;
    bobot,kecepatan,waktu,totaljaraklama,totaljarakbaru,totalakhir : real;
    rute: array of string;
    NL,NL1 : array of integer;
    hapusNL, hapusNL1 : set of byte;
begin
  if  (cekbobot(g.mtBobot)='') or (cekcust(arCust)='') or (edkapasitas.Text='') or
      (edwaktu.Text='') or (edkecepatan.Text='') or (edbanyak.Text='') then
      Application.MessageBox('Masukkan Data','Information', MB_OK or MB_ICONEXCLAMATION)
  else
  begin
    PageControl1.ActivePageIndex := 3;
    PageControl2.ActivePageIndex := 0;

    Q:=strtoint(edKapasitas.Text);
    T:=strtofloat(edWaktu.Text);
    kecepatan:=strtofloat(edKecepatan.Text);
    banyak:=strtoint(edBanyak.Text);

    for i:=0 to g.size-1 do
      for j:=0 to g.size-1 do
        if i<>j then
        begin
          waktu:=g.mtBobot[i,j]/kecepatan;
          g.mtWaktu[i,j]:=waktu;
          g.mtWaktu[j,i]:=waktu;
        end
        else g.mtWaktu[i,j]:=0;

//---
    mmOutput.Clear;
    for i:= 0 to Length(mtrute)-1 do
      for j:=0 to length(mtrute[i])-2 do
      begin
        u:= mtrute[i, j];
        v:= mtrute[i, j+1];
        P1 := arTitik[u].posisi;
        P2 := arTitik[v].posisi;
        imghasil.Canvas.Pen.Width := 2;
        imghasil.Canvas.Pen.Color := clwhite;
        imghasil.Canvas.MoveTo(P1.X, P1.Y);
        imghasil.Canvas.LineTo(P2.X, P2.Y);

        xC := Round((P1.X + P2.X)/2);
        yC := Round((P1.Y + P2.Y)/2);
        bobot := G.mtBobot[u,v];
        imghasil.Canvas.Font.Color := clwhite;
        imghasil.Canvas.TextOut(xC, yC+6, FloatToStr(bobot));
      end;
//---
    iter:= 0;
    itermax:=strtoint(edmax.Text);
    totalakhir:=99999;

  while iter<itermax do
  begin
    mmOutput.Lines.Add('Iterasi '+inttostr(iter+1)+' :');//}
    SequentialInsertion;

    setlength(copyrute, length(mtrute));
    for a:=0 to length(mtrute)-1 do
    begin
      setlength(copyrute[a], length(mtrute[a]));
      for b:=0 to length(mtrute[a])-1 do
        copyrute[a,b]:=mtrute[a,b];
    end;

    {iter:= 0;
    itermax:=strtoint(edmax.Text);

  while iter<itermax do
  begin
    mmOutput.Lines.Add('Iterasi '+inttostr(iter+1)+' :');//}
    Randomize;
    setlength(NL,5);
    hapusNL:=[];
    n:=0;
    while length(NL)>0 do
    begin
      totaljaraklama:=TotalJarak(copyrute);

      repeat
        b:=1+random(5);
      until not(b in hapusNL);
      for a:=0 to length(NL)-1 do
        NL[a]:=b;

      if NL[n]=1 then shift10(copyrute)
      else
      if NL[n]=2 then Swap11(copyrute)
      else
      if NL[n]=3 then Shift20(copyrute)
      else
      if NL[n]=4 then Swap22(copyrute)
      else
      if NL[n]=5 then Cross(copyrute);

      totaljarakbaru:=TotalJarak(copyrute);
      if totaljarakbaru<totaljaraklama then
      begin
        setlength(NL1, 4);

        hapusNL1:=[];
        while length(NL1)>0 do
        begin
          totaljaraklama:=TotalJarak(copyrute);

          repeat
            b:=1+random(4);
          until not(b in hapusNL1);
          for a:=0 to length(NL1)-1 do
            NL1[a]:=b;

          if NL1[n]=1 then Opt2(copyrute)
          else
          if NL1[n]=2 then OrOpt(copyrute)
          else
          if NL1[n]=3 then Reinsertion(copyrute)
          else
          if NL1[n]=4 then Exchange(copyrute);

          totaljarakbaru:=TotalJarak(copyrute);
          if totaljarakbaru>=totaljaraklama then
          begin
            setlength(NL1, length(NL1)-1);
            hapusNL1:=hapusNL1+[b];
          end;
        end;
      end
      else
      begin
        setlength(NL, length(NL)-1);
        hapusNL:=hapusNL+[b];
      end;
    end;

    Pertubasi(copyrute);

    if TotalJarak(copyrute)<TotalJarak(mtrute) then
    begin
      setlength(mtrute, length(copyrute));
      for a:=0 to length(copyrute)-1 do
      begin
        setlength(mtrute[a], length(copyrute[a]));
        for b:=0 to length(copyrute[a])-1 do
          mtrute[a,b]:=copyrute[a,b];
      end;
    end;
//
mmOutput.Lines.Add('');
mmOutput.Lines.Add('Rute yang Terbentuk dengan Menggunakan Algoritma ILS-RVND');
setlength(rute, 0);
    setlength(rute, length(mtrute));
    i:=0;
    k:=0;
    while i<=length(mtrute)-1 do
    begin
      if length(mtrute[i])=2 then
      begin
        i:=i+1;
        k:=k;
      end
      else
      begin
        k:=k+1;
        for j:=0 to length(mtrute[i])-1 do
          if rute[i]='' then
            rute[i]:=rute[i] + inttostr(mtrute[i,j])
          else
            rute[i]:=rute[i] + '-' + inttostr(mtrute[i,j]);
        mmOutput.Lines.Add('PR ' + inttostr(k) + ' = [' + rute[i] + '], jarak ' +
                          formatfloat('0.##',HitungJarak(mtrute[i])) + ' km, waktu '+
                          formatfloat('0.#',HitungW(mtrute[i]))+' jam.');
        i:=i+1;
      end;
    end;
{setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;//}
hitungkendaraan:=ceil(TotalWaktu(mtrute)/T); //banyak kendaraan
mmOutput.Lines.Add('Total jarak tempuh '+formatfloat('0.##',TotalJarak(mtrute))+' km, total waktu tempuh yang dibutuhkan '+formatfloat('0.#',TotalWaktu(mtrute))+' jam, dan menggunakan '+inttostr(hitungkendaraan)+' kendaraan.');
if iter+1<>itermax then begin mmOutput.Lines.Add(''); mmOutput.Lines.Add(''); end
else mmOutput.Lines.Add('---------------------------------------'+
                      '//'+
                      '---------------------------------------');
//}
    if TotalJarak(mtrute)<=totalakhir then
    begin
      setlength(rutepilih, length(mtrute));
      for a:=0 to length(mtrute)-1 do
      begin
        setlength(rutepilih[a], length(mtrute[a]));
        for b:=0 to length(mtrute[a])-1 do
          rutepilih[a,b]:=mtrute[a,b];
      end;
      pilihiter:=iter+1;
      kendaraan:=hitungkendaraan;
      totalakhir:=TotalJarak(mtrute);
    end;
    iter:= iter+1;
  end;

mmOutput.Lines.Add('');
mmOutput.Lines.Add('Dari hasil iterasi diatas, diperoleh rute optimal pada iterasi ke-'+inttostr(pilihiter)+', yaitu dengan jarak tempuh '+formatfloat('0.##',TotalJarak(rutepilih))+' km, total waktu tempuh yang dibutuhkan '+formatfloat('0.#',TotalWaktu(rutepilih))+' jam, dan menggunakan '+inttostr(kendaraan)+' kendaraan.');
mmOutput.Lines.Add('Rute yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(rutepilih));
i:=0;
k:=0;
while i<=length(rutepilih)-1 do
begin
  if length(rutepilih[i])=2 then
  begin
    i:=i+1;
    k:=k;
  end
  else
  begin
    k:=k+1;
    for j:=0 to length(rutepilih[i])-1 do
      if rute[i]='' then
        rute[i]:=rute[i] + inttostr(rutepilih[i,j])
      else
        rute[i]:=rute[i] + '-' + inttostr(rutepilih[i,j]);
    mmOutput.Lines.Add('Rute '+inttostr(i+1)+' = ['+rute[i]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(rutepilih[i]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(rutepilih[i]))+' jam.');
    i:=i+1;
  end;
end;
{//---
    mmoutput.Lines.Add('Rute Akhir dengan Menggunakan Algoritma ILS-RVND');
    setlength(rute, length(mtrute));
    i:=0;
    k:=0;
    while i<=length(mtrute)-1 do
    begin
      if length(mtrute[i])=2 then
      begin
        i:=i+1;
        k:=k;
      end
      else
      begin
        k:=k+1;
        for j:=0 to length(mtrute[i])-1 do
          if rute[i]='' then
            rute[i]:=rute[i] + inttostr(mtrute[i,j])
          else
            rute[i]:=rute[i] + '-' + inttostr(mtrute[i,j]);
        mmOutput.Lines.Add('PR ' + inttostr(k) + ' = [' + rute[i] + '], jarak ' +
                          formatfloat('0.##',HitungJarak(mtrute[i])) + ' km, waktu '+
                          formatfloat('0.#',HitungW(mtrute[i]))+' jam.');
        i:=i+1;
      end;
    end;

    mmOutput.Lines.Add('Dengan total jarak  ' + formatfloat('0.##',TotalJarak(mtrute)) +
                     ' km dan total waktu ' + formatfloat('0.#',TotalWaktu(mtrute)) + ' jam.');

    if TotalWaktu(mtrute)>T then //total>seharusnya
    begin
      a:=ceil(TotalWaktu(mtrute)/T); //banyak kendaraan
      if a<=banyak then
        mmOutput.Lines.Add('Berdasarkan total waktu tempuh semua rute, maka menggunakan '+inttostr(a)+' kendaraan.')
      else
      begin
        Application.MessageBox('Banyak Kendaraan Tidak Memenuhi!','Information', MB_OK or MB_ICONEXCLAMATION);
        mmOutput.Lines.Add('Banyak kendaraan tidak memenuhi, memerlukan '+inttostr(a)+' kendaraan.');
      end;
    end
    else
      mmOutput.Lines.Add('Berdasarkan total waktu tempuh semua rute, maka menggunakan 1 kendaraan');
//---}
    for i:= 0 to Length(mtrute)-1 do
      for j:=0 to length(mtrute[i])-2 do
      begin
        u:= mtrute[i, j];
        v:= mtrute[i, j+1];
        P1 := arTitik[u].posisi;
        P2 := arTitik[v].posisi;
        imghasil.Canvas.Pen.Width := 2;
        imghasil.Canvas.Pen.Color := clFuchsia;
        imghasil.Canvas.MoveTo(P1.X, P1.Y);
        imghasil.Canvas.LineTo(P2.X, P2.Y);

        xC := Round((P1.X + P2.X)/2);
        yC := Round((P1.Y + P2.Y)/2);
        bobot := G.mtBobot[u,v];
        imghasil.Canvas.Font.Color := clBlue;
        imghasil.Canvas.TextOut(xC, yC+6, FloatToStr(bobot));
        imghasil.Canvas.Font.Color := clBlack;
      end;
//---
  end;
end;

procedure TMTVRPTW.Dataset;
var Instance: IXMLInstanceType;
    i, j, byktitik, bykparameter : byte;
    tw, st, bobot : real;
    permintaan, kapasitas, x, y, Xmin, Xmax, Ymin, Ymax, width, height, Tx, Ty : integer;
    pos : array of array of integer;
begin
  if opendialog1.Execute then
  begin
    Hapus;
    Instance := Loadinstance(opendialog1.FileName);
    mmoutput.Clear;

    byktitik := instance.Network.Nodes.Count; //baca banyak titik
    G.size := bykTitik;
    setLength(G.mtBobot, G.size, G.size);
    setLength(G.mtWaktu, G.size, G.size);
    setlength(arTitik, bykTitik);
    sgMatriks.ColCount := bykTitik+1;
    SgMatriks.RowCount := bykTitik+1;
    for i := 1 to bykTitik do
    begin
      sgMatriks.Cells[0, i] := Format('%d', [i-1]);
      sgMatriks.Cells[i, 0] := Format('%d', [i-1]);
    end;
    sgCust.ColWidths[0]:=80;
    sgCust.ColWidths[1]:=108;
    sgCust.ColWidths[2]:=150;

    //baca permintaan+waktu cust
    bykparameter:=instance.Requests.Count;
    setlength(arCust, bykParameter);
    sgCust.RowCount:=bykParameter+1;
    sgCust.Cells[0, 0] := 'Customer';
    sgCust.Cells[1, 0] := 'Permintaan';
    sgCust.Cells[2, 0] := 'Service Time (Jam)';
    for i:=0 to length(arCust)-1 do
    begin
      arCust[i].Cust := i+1;
      sgCust.Cells[0, i+1] := Format('%d', [i+1]);
    end;
    for i:=0 to instance.Requests.Count-1 do
    begin
      permintaan:=round(instance.Requests.Request[i].Quantity/10); //baca permintaan
      arCust[i].Permintaan:=permintaan;
      sgCust.Cells[1,i+1]:=inttostr(permintaan);

      st:=instance.Requests.Request[i].Service_time/10;
      arCust[i].Waktu:=st/60;
      sgCust.Cells[2,i+1]:=floattostr(st/60);
    end;

    kapasitas:=round(instance.Fleet.Vehicle_profile.Capacity/10); //baca kapasitas
    edKapasitas.Text:=inttostr(kapasitas);
    tw:=instance.Fleet.Vehicle_profile.Max_travel_time/10; //baca max travel time
    edWaktu.Text:=floattostr(tw/60);

      x:=round(instance.Network.Nodes[0].Cx/10); //baca cx
      y:=round(instance.Network.Nodes[0].Cy/10); //baca cy

      setLength(arTitik, bykTitik); //set array posisi
      setLength(pos, bykTitik, 2);

      Xmin := X;
      Xmax := X;
      Ymin := Y;
      Ymax := Y;
      pos[0,0] := X;
      pos[0,1] := Y;
      arTitik[0].warna:=clyellow;

    for i:=1 to instance.Network.Nodes.Count-1 do
    begin
      x:=round(instance.Network.Nodes[i].Cx/10); //baca cx
      y:=round(instance.Network.Nodes[i].Cy/10); //baca cy

      if X < Xmin then Xmin := X;
      if X > Xmax then Xmax := X;
      if Y < Ymin then Ymin := Y;
      if Y > Ymax then Ymax := Y;
      pos[i,0] := X;
      pos[i,1] := Y;
      arTitik[i].warna:=clyellow;
    end;

    width := imghasil.Width-40;
    height := imghasil.Height-50;

    for i := 0 to bykTitik-1 do
    begin
      tX := pos[i,0];
      tY := pos[i,1];
      if Xmin < 0 then
      begin
        if tX < 0 then tX := tX-Xmin
          else tX := tX + abs(Xmin);
      end else
        tX := tX - Xmin;

      if Ymin < 0 then
      begin
        if tY < 0 then tY := tY-Ymin
          else tY := tY + abs(Ymin);
      end else
        tY := tY - Ymin;

      arTitik[i].posisi.X := Round(tX/(Xmax-Xmin)*Width)+20;
      arTitik[i].posisi.Y := Round(tY/(Ymax-Ymin)*Height)+20;
    end;

    setLength(G.mtBobot, bykTitik, bykTitik); //set matriks bobot
    for i := 0 to bykTitik-1 do
    begin
      for j := 0 to bykTitik-1 do
      begin
        if j > i then
        begin
          bobot := sqrt((sqr(pos[i,0]-pos[j,0])) + (sqr(pos[i,1]-pos[j,1])));;
          bobot := round(bobot*1000)/1000;
          G.mtBobot[i, j] := bobot; //masukkan kelemen [i,j]
          G.mtBobot[j, i] := bobot; //masukkan keelemen [j,i]
          sgMatriks.Cells[j+1, i+1] := FloatToStr (bobot);
          sgMatriks.Cells[i+1, j+1] := FloatToStr (bobot);
        end;
      end;
    end;

    for i := 0 to bykTitik-1 do
      for j := 0 to bykTitik-1 do
        if j > i then
          if G.mtBobot[i, j] <> 0 then  //bila ada sisinya
            GambarSisi(i, j); //gambar sisi
  end;
end;

procedure TMTVRPTW.btdatasetClick(Sender: TObject);
begin
 dataset;
end;

procedure TMTVRPTW.btCrossClick(Sender: TObject);
var a, b, c, i, j, k, t1, K1, K2, x, y : integer;
    totaljarak1, totaljarak2, totalwaktu1, totalwaktu2 : real;
    artampung, arsimpan, arfix : rute;
    rute: array of string;
begin
  setlength(arfix, length(mtrute));
  for j:=0 to length(mtrute)-1 do
  begin
    setlength(arfix[j], length(mtrute[j]));
    for k:=0 to length(mtrute[j])-1 do
      arfix[j,k]:=mtrute[j,k];
  end;

//
mmoutput.Lines.Add('Cross :'); //}

  totaljarak1:=totaljarak(arfix);
  totalwaktu1:=totalwaktu(arfix);

  setlength(artampung, 2);
  for i:=0 to length(mtrute)-2 do
  begin
    a:=2;
    while a < length(mtrute[i])-1 do
    begin
      t1:=mtrute[i,a];

//
mmoutput.Lines.Add('* Pilih titik= ['+inttostr(mtrute[i,a-1])+','+inttostr(t1)+']'); //}

      if i=0 then b:=1 else b:=0;

      while b < length(mtrute) do
      begin
        if i<>b then
        begin
          c:=2;
          while c < length(mtrute[b])-1 do
          begin
            setlength(arsimpan, length(mtrute));
            for j:=0 to length(mtrute)-1 do
            begin
              setlength(arsimpan[j], length(mtrute[j]));
              for k:=0 to length(mtrute[j])-1 do
                arsimpan[j,k]:=mtrute[j,k];
            end;

            setlength(artampung[0], length(mtrute[i]));
            for j:=0 to length(mtrute[i])-1 do
              artampung[0,j]:=mtrute[i,j];
            setlength(artampung[1], length(mtrute[b]));
            for j:=0 to length(mtrute[b])-1 do
              artampung[1,j]:=mtrute[b,j];

            artampung[0,a]:=artampung[1,c];

//
mmOutput.Lines.Add('~ Ganti dengan titik= ['+inttostr(artampung[1,c-1])+','+inttostr(artampung[1,c])+']'); //}

            artampung[1,c]:=t1;

//
setlength(rute, 0);
setlength(rute, 2);
for x:=0 to length(rute)-1 do
begin
for y:=0 to length(artampung[x])-1 do
if rute[x]='' then
rute[x]:=rute[x] + inttostr(artampung[x,y])
else
rute[x]:=rute[x] + '-' + inttostr(artampung[x,y]);
if x=0 then mmOutput.Lines.Add('  rute 1 sementara: '+rute[x])
else mmOutput.Lines.Add('  rute 2 sementara: '+rute[x]);
end;  //}

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

//
mmOutput.Lines.Add('  K1= '+inttostr(k1));
mmOutput.Lines.Add('  K2= '+inttostr(k2)); //}

            if (K1<Q) and (K2<Q) then
            begin
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              totalwaktu2:=totalwaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (totalwaktu2<totalwaktu1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;
//
mmOutput.Lines.Add('->Ganti rute karena memenuhi k1,k2<q dan total jarak baru<total jarak lama serta total waktu baru<total waktu lama'); //}
              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(arfix)-1 do
  begin
    setlength(mtrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      mtrute[i,j]:=arfix[i,j];
  end;

//
mmOutput.Lines.Add('Rute baru yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;
mmOutput.Lines.Add('Total jarak tempuh = '+formatfloat('0.##',TotalJarak(mtrute))+' km dan total waktu yang dibutuhkan = '+formatfloat('0.#',TotalWaktu(mtrute))+' jam.');
mmOutput.Lines.Add('');//}
end;

procedure TMTVRPTW.btShift10Click(Sender: TObject);
var a, b, c, i, j, k, l, t1, K1, K2, x, y : integer;
    totaljarak1, totaljarak2 : real;
    artampung, arsimpan, arfix : rute;
    rute: array of string;
begin
  setlength(arfix, length(mtrute));
  for j:=0 to length(mtrute)-1 do
  begin
    setlength(arfix[j], length(mtrute[j]));
    for k:=0 to length(mtrute[j])-1 do
      arfix[j,k]:=mtrute[j,k];
  end;

//
mmoutput.Lines.Add('Shift(1,0) :'); //}

  totaljarak1:=totaljarak(arfix);
  W1:=TotalWaktu(arfix);

  setlength(artampung, 2);
  for i:=0 to length(mtrute)-1 do
  begin
    a:=1;
    while a < length(mtrute[i])-1 do
    begin
      t1:=mtrute[i,a];

//
mmoutput.Lines.Add('* Ambil titik= '+inttostr(t1)); //}

      if i=0 then b:=1 else b:=0;

      while b < length(mtrute) do
      begin
        if i<>b then
        begin
          c:=1;
          while c < length(mtrute[b]) do
          begin
            setlength(arsimpan, length(mtrute));
            for j:=0 to length(mtrute)-1 do
            begin
              setlength(arsimpan[j], length(mtrute[j]));
              for k:=0 to length(mtrute[j])-1 do
                arsimpan[j,k]:=mtrute[j,k];
            end;

            setlength(artampung[0], length(mtrute[i]));
            for j:=0 to length(mtrute[i])-1 do
              artampung[0,j]:=mtrute[i,j];
            setlength(artampung[1], length(mtrute[b]));
            for j:=0 to length(mtrute[b])-1 do
              artampung[1,j]:=mtrute[b,j];

            for j:=a to length(artampung[0])-2 do
              artampung[0,j]:=mtrute[i,j+1];
            setlength(artampung[0], length(artampung[0])-1);

            setlength(artampung[1], length(artampung[1])+1);
            for j:=length(artampung[1])-2 downto c do
              artampung[1,j+1]:=mtrute[b,j];
            artampung[1,c]:=t1;

//
setlength(rute, 0);
setlength(rute, 2);
for x:=0 to length(rute)-1 do
begin
for y:=0 to length(artampung[x])-1 do
if rute[x]='' then
rute[x]:=rute[x] + inttostr(artampung[x,y])
else
rute[x]:=rute[x] + '-' + inttostr(artampung[x,y]);
if x=0 then mmOutput.Lines.Add('  rute 1 sementara: '+rute[x])
else mmOutput.Lines.Add('  rute 2 sementara: '+rute[x]);
end;  //}

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

//
mmOutput.Lines.Add('  K1= '+inttostr(k1));
mmOutput.Lines.Add('  K2= '+inttostr(k2)); //}

            if ((K1<Q) and (K2<Q)) then
            begin
              setlength(arsimpan[i], length(artampung[0]));
              setlength(arsimpan[b], length(artampung[1]));
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              W2:=TotalWaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (W2<W1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;

//
mmOutput.Lines.Add('->Ganti rute karena memenuhi k1,k2<q dan total jarak baru<total jarak lama serta total waktu baru<total waktu lama'); //}

              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(arfix)-1 do
  begin
    setlength(mtrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      mtrute[i,j]:=arfix[i,j];
  end;

//
mmOutput.Lines.Add('Rute baru yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;
mmOutput.Lines.Add('Total jarak tempuh = '+formatfloat('0.##',TotalJarak(mtrute))+' km dan total waktu yang dibutuhkan = '+formatfloat('0.#',TotalWaktu(mtrute))+' jam.');
mmOutput.Lines.Add('');//}
end;

procedure TMTVRPTW.btShift20Click(Sender: TObject);
var a, b, c, i, j, k, l, Q, t1, t2, K1, K2, x, y : integer;
    totaljarak1, totaljarak2 : real;
    artampung, arsimpan, arfix : rute;
    rute : array of string;
begin
  Q:=strtoint(edkapasitas.Text);
  setlength(arfix, length(mtrute));
  for j:=0 to length(mtrute)-1 do
  begin
    setlength(arfix[j], length(mtrute[j]));
    for k:=0 to length(mtrute[j])-1 do
      arfix[j,k]:=mtrute[j,k];
  end;

//
mmoutput.Lines.Add('Shift(2,0) :'); //}

  totaljarak1:=totaljarak(arfix);
  W1:=TotalWaktu(arfix);

  setlength(artampung, 2);
  for i:=0 to length(mtrute)-1 do
  begin
    a:=1;
    while a < length(mtrute[i])-2 do
    begin
      t1:=mtrute[i,a];
      t2:=mtrute[i,a+1];

//
mmoutput.Lines.Add('* Ambil titik= '+inttostr(t1)+' dan '+inttostr(t2)); //}

      if i=0 then b:=1 else b:=0;

      while b < length(mtrute) do
      begin
        if i<>b then
        begin
          c:=1;
          while c < length(mtrute[b]) do
          begin
            setlength(arsimpan, length(mtrute));
            for j:=0 to length(mtrute)-1 do
            begin
              setlength(arsimpan[j], length(mtrute[j]));
              for k:=0 to length(mtrute[j])-1 do
                arsimpan[j,k]:=mtrute[j,k];
            end;

            setlength(artampung[0], length(mtrute[i]));
            for j:=0 to length(mtrute[i])-1 do
              artampung[0,j]:=mtrute[i,j];
            setlength(artampung[1], length(mtrute[b]));
            for j:=0 to length(mtrute[b])-1 do
              artampung[1,j]:=mtrute[b,j];

            for j:=a to length(artampung[0])-1 do
              artampung[0,j]:=mtrute[i,j+2];
            setlength(artampung[0], length(artampung[0])-2);

            setlength(artampung[1], length(artampung[1])+2);
            for j:=length(artampung[1])-2 downto c do
              artampung[1,j+1]:=mtrute[b,j-1];
            artampung[1,c]:=t1;
            artampung[1,c+1]:=t2;

//
setlength(rute, 0);
setlength(rute, 2);
for x:=0 to length(rute)-1 do
begin
for y:=0 to length(artampung[x])-1 do
if rute[x]='' then
rute[x]:=rute[x] + inttostr(artampung[x,y])
else
rute[x]:=rute[x] + '-' + inttostr(artampung[x,y]);
if x=0 then mmOutput.Lines.Add('  rute 1 sementara: '+rute[x])
else mmOutput.Lines.Add('  rute 2 sementara: '+rute[x]);
end;  //}

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

//
mmOutput.Lines.Add('  K1= '+inttostr(k1));
mmOutput.Lines.Add('  K2= '+inttostr(k2)); //}

            if ((K1<Q) and (K2<Q)) then
            begin
              setlength(arsimpan[i], length(artampung[0]));
              setlength(arsimpan[b], length(artampung[1]));
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              W2:=TotalWaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (W2<W1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;

//
mmOutput.Lines.Add('->Ganti rute karena memenuhi k1,k2<q dan total jarak baru<total jarak lama serta total waktu baru<total waktu lama'); //}

              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(arfix)-1 do
  begin
    setlength(mtrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      mtrute[i,j]:=arfix[i,j];
  end;

//
mmOutput.Lines.Add('Rute baru yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;
mmOutput.Lines.Add('Total jarak tempuh = '+formatfloat('0.##',TotalJarak(mtrute))+' km dan total waktu yang dibutuhkan = '+formatfloat('0.#',TotalWaktu(mtrute))+' jam.');
mmOutput.Lines.Add('');//}
end;

procedure TMTVRPTW.btSwap11Click(Sender: TObject);
var a, b, c, i, j, k, l, Q, t1, K1, K2, x, y : integer;
    totaljarak1, totaljarak2 : real;
    artampung, arsimpan, arfix : rute;
    rute : array of string;
begin
  Q:=strtoint(edkapasitas.Text);
  setlength(arfix, length(mtrute));
  for j:=0 to length(mtrute)-1 do
  begin
    setlength(arfix[j], length(mtrute[j]));
    for k:=0 to length(mtrute[j])-1 do
      arfix[j,k]:=mtrute[j,k];
  end;

//
mmoutput.Lines.Add('Swap(1,1) :'); //}

  totaljarak1:=totaljarak(arfix);
  W1:=TotalWaktu(arfix);
  
  setlength(artampung, 2);
  for i:=0 to length(mtrute)-1 do
  begin
    a:=1;
    while a < length(mtrute[i])-1 do
    begin
      t1:=mtrute[i,a];
//
mmoutput.Lines.Add('* Pilih titik= '+inttostr(t1)); //}

      if i=0 then b:=1 else b:=0;

      while b < length(mtrute) do
      begin
        if i<>b then
        begin
          c:=1;
          while c < length(mtrute[b])-1 do
          begin
            setlength(arsimpan, length(mtrute));
            for j:=0 to length(mtrute)-1 do
            begin
              setlength(arsimpan[j], length(mtrute[j]));
              for k:=0 to length(mtrute[j])-1 do
                arsimpan[j,k]:=mtrute[j,k];
            end;

            setlength(artampung[0], length(mtrute[i]));
            for j:=0 to length(mtrute[i])-1 do
              artampung[0,j]:=mtrute[i,j];
            setlength(artampung[1], length(mtrute[b]));
            for j:=0 to length(mtrute[b])-1 do
              artampung[1,j]:=mtrute[b,j];

            artampung[0,a]:=artampung[1,c];

//
mmOutput.Lines.Add('~ Ganti dengan titik= '+inttostr(artampung[1,c])); //}

            artampung[1,c]:=t1;

//
setlength(rute, 0);
setlength(rute, 2);
for x:=0 to length(rute)-1 do
begin
for y:=0 to length(artampung[x])-1 do
if rute[x]='' then
rute[x]:=rute[x] + inttostr(artampung[x,y])
else
rute[x]:=rute[x] + '-' + inttostr(artampung[x,y]);
if x=0 then mmOutput.Lines.Add('  rute 1 sementara: '+rute[x])
else mmOutput.Lines.Add('  rute 2 sementara: '+rute[x]);
end;  //}

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

//
mmOutput.Lines.Add('  K1= '+inttostr(k1));
mmOutput.Lines.Add('  K2= '+inttostr(k2)); //}

            if ((K1<Q) and (K2<Q)) then
            begin
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              W2:=TotalWaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (W2<W1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;

//
mmOutput.Lines.Add('->Ganti rute karena memenuhi k1,k2<q dan total jarak baru<total jarak lama serta total waktu baru<total waktu lama'); //}

              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(arfix)-1 do
  begin
    setlength(mtrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      mtrute[i,j]:=arfix[i,j];
  end;
  
//
mmOutput.Lines.Add('Rute baru yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;
mmOutput.Lines.Add('Total jarak tempuh = '+formatfloat('0.##',TotalJarak(mtrute))+' km dan total waktu yang dibutuhkan = '+formatfloat('0.#',TotalWaktu(mtrute))+' jam.');
mmOutput.Lines.Add('');//}
end;

procedure TMTVRPTW.btSwap22Click(Sender: TObject);
var a, b, c, i, j, k, l, Q, t1, t2, K1, K2, x, y : integer;
    totaljarak1, totaljarak2 : real;
    artampung, arsimpan, arfix : rute;
    rute : array of string;
begin
  Q:=strtoint(edkapasitas.Text);
  setlength(arfix, length(mtrute));
  for j:=0 to length(mtrute)-1 do
  begin
    setlength(arfix[j], length(mtrute[j]));
    for k:=0 to length(mtrute[j])-1 do
      arfix[j,k]:=mtrute[j,k];
  end;

//
mmoutput.Lines.Add('Swap(2,2) :'); //}

  totaljarak1:=totaljarak(arfix);
  W1:=TotalWaktu(arfix);

  setlength(artampung, 2);
  for i:=0 to length(mtrute)-1 do
  begin
    a:=1;
    while a < length(mtrute[i])-2 do
    begin
      t1:=mtrute[i,a];
      t2:=mtrute[i,a+1];

//
mmoutput.Lines.Add('* Ambil titik= '+inttostr(t1)+' dan '+inttostr(t2)); //}

      if i=0 then b:=1 else b:=0;

      while b < length(mtrute) do
      begin
      if i<>b then
      begin
          c:=1;
          while c < length(mtrute[b])-2 do
          begin
            setlength(arsimpan, length(mtrute));
            for j:=0 to length(mtrute)-1 do
            begin
              setlength(arsimpan[j], length(mtrute[j]));
              for k:=0 to length(mtrute[j])-1 do
                arsimpan[j,k]:=mtrute[j,k];
            end;

            setlength(artampung[0], length(mtrute[i]));
            for j:=0 to length(mtrute[i])-1 do
              artampung[0,j]:=mtrute[i,j];
            setlength(artampung[1], length(mtrute[b]));
            for j:=0 to length(mtrute[b])-1 do
              artampung[1,j]:=mtrute[b,j];

            artampung[0,a]:=artampung[1,c];
            artampung[0,a+1]:=artampung[1,c+1];
//
mmOutput.Lines.Add('~ Ganti dengan titik= '+inttostr(artampung[1,c])+' dan '+inttostr(artampung[1,c+1])); //}

            artampung[1,c]:=t1;
            artampung[1,c+1]:=t2;

//
setlength(rute, 0);
setlength(rute, 2);
for x:=0 to length(rute)-1 do
begin
for y:=0 to length(artampung[x])-1 do
if rute[x]='' then
rute[x]:=rute[x] + inttostr(artampung[x,y])
else
rute[x]:=rute[x] + '-' + inttostr(artampung[x,y]);
if x=0 then mmOutput.Lines.Add('  rute 1 sementara: '+rute[x])
else mmOutput.Lines.Add('  rute 2 sementara: '+rute[x]);
end;  //}

            K1:=HitungK(artampung[0]);
            K2:=HitungK(artampung[1]);

//
mmOutput.Lines.Add('  K1= '+inttostr(k1));
mmOutput.Lines.Add('  K2= '+inttostr(k2)); //}

            if ((K1<Q) and (K2<Q)) then
            begin
              for j:=0 to length(artampung[0])-1 do
                arsimpan[i,j]:=artampung[0,j];
              for j:=0 to length(artampung[1])-1 do
                arsimpan[b,j]:=artampung[1,j];

              totaljarak2:=TotalJarak(arsimpan);
              W2:=TotalWaktu(arsimpan);
              if (totaljarak2<totaljarak1) and (W2<W1) then
              begin
                for j:=0 to length(arsimpan)-1 do
                begin
                  setlength(arfix[j], length(arsimpan[j]));
                  for k:=0 to length(arsimpan[j])-1 do
                    arfix[j,k]:=arsimpan[j,k];
                end;
                totaljarak1:=totaljarak2;

//
mmOutput.Lines.Add('->Ganti rute karena memenuhi k1,k2<q dan total jarak baru<total jarak lama serta total waktu baru<total waktu lama'); //}

              end;
            end;
            c:=c+1;
          end;
        end;
        b:=b+1;
      end;
      a:=a+1;
    end;
  end;

  for i:=0 to length(arfix)-1 do
  begin
    setlength(mtrute[i], length(arfix[i]));
    for j:=0 to length(arfix[i])-1 do
      mtrute[i,j]:=arfix[i,j];
  end;
  
//
mmOutput.Lines.Add('Rute baru yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;
mmOutput.Lines.Add('Total jarak tempuh = '+formatfloat('0.##',TotalJarak(mtrute))+' km dan total waktu yang dibutuhkan = '+formatfloat('0.#',TotalWaktu(mtrute))+' jam.');
mmOutput.Lines.Add('');//}
end;

procedure TMTVRPTW.btExchangeClick(Sender: TObject);
var a, b, i, j, k, t1, x, y : integer;
    jaraklama, jarakbaru : real;
    artampung, arsimpan : array of integer;
    ruteb : string;
    rute : array of string;
begin

//
mmoutput.Lines.Add('Exchange :'); //}

  for i:=0 to length(mtrute)-1 do
  begin
    jaraklama:=HitungJarak(mtrute[i]);
    W1:=HitungW(mtrute[i]);
    a := 1;

    setlength(arsimpan, length(mtrute[i]));
    for k:=0 to length(mtrute[i])-1 do
      arsimpan[k]:=mtrute[i,k];

    while a < length(mtrute[i])-2 do
    begin
      t1:=mtrute[i,a];
      
//
mmoutput.Lines.Add('* Pilih titik= '+inttostr(t1)); //}

      b := a+1;
      while b < length(mtrute[i])-1 do
      begin
        setlength(artampung, length(mtrute[i]));
        for j:=0 to length(mtrute[i])-1 do
          artampung[j]:=mtrute[i,j];

        artampung[a]:=artampung[b];

//
mmOutput.Lines.Add('~ Ganti dengan titik= '+inttostr(artampung[b])); //}

        artampung[b]:=t1;

//
ruteb:='';
for y:=0 to length(artampung)-1 do
if ruteb='' then
ruteb:=ruteb + inttostr(artampung[y])
else
ruteb:=ruteb + '-' + inttostr(artampung[y]);
mmOutput.Lines.Add('  rute sementara: '+ruteb); //}

        jarakbaru:=HitungJarak(artampung);
        W2:=HitungW(arTampung);
        
//
mmOutput.Lines.Add(' Jarak Baru= '+formatfloat('0.##',jarakbaru));
mmOutput.Lines.Add(' Waktu Baru= '+formatfloat('0.#',w2)); //}


        if (jarakbaru<jaraklama) and (W2<W1) then
        begin
          for j:=0 to length(artampung)-1 do
            arsimpan[j]:=artampung[j];
          jaraklama:=jarakbaru;
//
mmOutput.Lines.Add('->Ganti rute karena memenuhi jarak baru<jarak lama serta waktu baru<waktu lama'); //}

        end;
        b:=b+1;
      end;
      a:=a+1;
    end;

    for k:=0 to length(mtrute[i])-1 do
      mtrute[i,k]:=arsimpan[k];
  end;

//
mmOutput.Lines.Add('Rute baru yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;
mmOutput.Lines.Add('Total jarak tempuh = '+formatfloat('0.##',TotalJarak(mtrute))+' km dan total waktu yang dibutuhkan = '+formatfloat('0.#',TotalWaktu(mtrute))+' jam.');
mmOutput.Lines.Add('');//}
end;

procedure TMTVRPTW.bt2OptClick(Sender: TObject);
var a,b,c,d,t1,t2, x, y : integer;
    jaraklama,jarakbaru : real;
    artampung : array of integer;
    arsimpan : rute;
    ruteb : string;
    rute : array of string;
begin
  setlength(arsimpan, length(mtrute));
  for a:=0 to length(mtrute)-1 do
  begin
    setlength(arsimpan[a], length(mtrute[a]));
    for b:=0 to length(mtrute[a])-1 do
      arsimpan[a,b]:=mtrute[a,b];
  end;

//
mmoutput.Lines.Add('Opt2 :'); //}

  for a:=0 to length(mtrute)-1 do
  begin
    jaraklama:=HitungJarak(arsimpan[a]);
    w1:=HitungW(arsimpan[a]);
    c:=length(arsimpan[a]);

    if (c>=7) then
    begin
      b:=2;
      while b<length(mtrute[a])-4 do
      begin
        t1:=mtrute[a,b];
        t2:=mtrute[a,b+2];

//
mmoutput.Lines.Add('* Tukar titik= '+inttostr(t1)+' dan '+inttostr(t2)); //}

        setlength(artampung, length(mtrute[a]));
        for d:=0 to length(mtrute[a])-1 do
          artampung[d]:=mtrute[a,d];

        artampung[b+2]:=t1;
        artampung[b]:=t2;

//
ruteb:='';
for y:=0 to length(artampung)-1 do
if ruteb='' then
ruteb:=ruteb + inttostr(artampung[y])
else
ruteb:=ruteb + '-' + inttostr(artampung[y]);
mmOutput.Lines.Add('  rute sementara: '+ruteb); //}

        jarakbaru:=HitungJarak(artampung);
        w2:=HitungW(artampung);

//
mmOutput.Lines.Add('  Jarak Baru= '+formatfloat('0.##',jarakbaru));
mmOutput.Lines.Add('  Waktu Baru= '+formatfloat('0.#',w2)); //}


        if (jarakbaru<jaraklama) and (w2<w1) then
        begin
          for d:=1 to length(mtrute[a])-2 do
            arsimpan[a,d]:=artampung[d];

//
mmOutput.Lines.Add('->Ganti rute karena memenuhi jarak baru<jarak lama serta waktu baru<waktu lama'); //}

        end;
        b:=b+1;
      end;
    end;
  end;

  for a:=0 to length(arsimpan)-1 do
    for b:=0 to length(arsimpan[a])-1 do
      mtrute[a,b]:=arsimpan[a,b];

//
mmOutput.Lines.Add('Rute baru yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;
mmOutput.Lines.Add('Total jarak tempuh = '+formatfloat('0.##',TotalJarak(mtrute))+' km dan total waktu yang dibutuhkan = '+formatfloat('0.#',TotalWaktu(mtrute))+' jam.');
mmOutput.Lines.Add('');//}
end;

procedure TMTVRPTW.btOrOptClick(Sender: TObject);
var a,b,c,d,t1,t2, y : integer;
    jaraklama,jarakbaru : real;
    artampung : array of integer;
    arsimpan : rute;
    ruteb : string;
    rute : array of string;
begin
  setlength(arsimpan, length(mtrute));
  for a:=0 to length(mtrute)-1 do
  begin
    setlength(arsimpan[a], length(mtrute[a]));
    for b:=0 to length(mtrute[a])-1 do
      arsimpan[a,b]:=mtrute[a,b];
  end;

//
mmoutput.Lines.Add('OrOpt :'); //}

  for a:=0 to length(mtrute)-1 do
  begin
    jaraklama:=HitungJarak(arsimpan[a]);
    w1:=HitungW(arsimpan[a]);

    b:=1;
    while b<length(mtrute[a])-2 do
    begin
      t1:=mtrute[a,b];
      t2:=mtrute[a,b+1];

//
mmoutput.Lines.Add('* Tukar titik= '+inttostr(t1)+' dan '+inttostr(t2)); //}

      c:=1;
      while c<length(mtrute[a])-2 do
      begin
        setlength(artampung, length(mtrute[a]));
        for d:=0 to length(mtrute[a])-1 do
          artampung[d]:=mtrute[a,d];

        if c<>b then
        begin
          for d:=b to length(artampung)-2 do
              artampung[d]:=mtrute[a,d+2];

          for d:=length(artampung)-3 downto c do
            artampung[d+1]:=artampung[d-1];

          artampung[c]:=t1;
          artampung[c+1]:=t2;

//
ruteb:='';
for y:=0 to length(artampung)-1 do
if ruteb='' then
ruteb:=ruteb + inttostr(artampung[y])
else
ruteb:=ruteb + '-' + inttostr(artampung[y]);
mmOutput.Lines.Add('  rute sementara: '+ruteb); //}

          jarakbaru:=HitungJarak(artampung);
          w2:=HitungW(artampung);

//
mmOutput.Lines.Add(' Jarak Baru= '+formatfloat('0.##',jarakbaru));
mmOutput.Lines.Add(' Waktu Baru= '+formatfloat('0.#',w2)); //}

          if (jarakbaru<jaraklama) and (w2<w1) then
          begin
            for d:=1 to length(mtrute[a])-2 do
              arsimpan[a,d]:=artampung[d];
              
//
mmOutput.Lines.Add('->Ganti rute karena memenuhi jarak baru<jarak lama serta waktu baru<waktu lama'); //}

          end;
        end;
        c:=c+1;
      end;
      b:=b+1;
    end;
  end;

  for a:=0 to length(arsimpan)-1 do
    for b:=0 to length(arsimpan[a])-1 do
      mtrute[a,b]:=arsimpan[a,b];

//
mmOutput.Lines.Add('Rute baru yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;
mmOutput.Lines.Add('Total jarak tempuh = '+formatfloat('0.##',TotalJarak(mtrute))+' km dan total waktu yang dibutuhkan = '+formatfloat('0.#',TotalWaktu(mtrute))+' jam.');
mmOutput.Lines.Add('');//}
end;

procedure TMTVRPTW.btReinsertionClick(Sender: TObject);
var a,b,c,d,t1, y : integer;
    jaraklama,jarakbaru : real;
    artampung : array of integer;
    arsimpan : rute;
    ruteb : string;
    rute : array of string;
begin
  setlength(arsimpan, length(mtrute));
  for a:=0 to length(mtrute)-1 do
  begin
    setlength(arsimpan[a], length(mtrute[a]));
    for b:=0 to length(mtrute[a])-1 do
      arsimpan[a,b]:=mtrute[a,b];
  end;

//
mmoutput.Lines.Add('Reinsertion :'); //}

  for a:=0 to length(mtrute)-1 do
  begin
    jaraklama:=HitungJarak(arsimpan[a]);
    w1:=HitungW(arsimpan[a]);

    b:=1;
    while b<length(mtrute[a])-1 do
    begin
      t1:=mtrute[a,b];

//
mmoutput.Lines.Add('* Geser titik= '+inttostr(t1)); //}

      c:=1;
      while c<length(mtrute[a])-1 do
      begin
        setlength(artampung, length(mtrute[a]));
        for d:=0 to length(mtrute[a])-1 do
          artampung[d]:=mtrute[a,d];

        if c<>b then
        begin
          for d:=b to length(artampung)-2 do
              artampung[d]:=mtrute[a,d+1];

          for d:=length(artampung)-3 downto c do
            artampung[d+1]:=artampung[d];

          artampung[c]:=t1;

//
ruteb:='';
for y:=0 to length(artampung)-1 do
if ruteb='' then
ruteb:=ruteb + inttostr(artampung[y])
else
ruteb:=ruteb + '-' + inttostr(artampung[y]);
mmOutput.Lines.Add('  rute sementara: '+ruteb); //}

          jarakbaru:=HitungJarak(artampung);
          w2:=HitungW(artampung);

//
mmOutput.Lines.Add('  Jarak Baru= '+formatfloat('0.##',jarakbaru));
mmOutput.Lines.Add('  Waktu Baru= '+formatfloat('0.#',w2)); //}

          if (jarakbaru<jaraklama) and (w2<w1) then
          begin
            for d:=1 to length(mtrute[a])-2 do
              arsimpan[a,d]:=artampung[d];

//
mmOutput.Lines.Add('->Ganti rute karena memenuhi jarak baru<jarak lama serta waktu baru<waktu lama'); //}

          end;
        end;
        c:=c+1;
      end;
      b:=b+1;
    end;
  end;

  for a:=0 to length(arsimpan)-1 do
    for b:=0 to length(arsimpan[a])-1 do
      mtrute[a,b]:=arsimpan[a,b];

//
mmOutput.Lines.Add('Rute baru yang terbentuk:');
setlength(rute, 0);
setlength(rute, length(mtrute));
for a:=0 to length(mtrute)-1 do
begin
for b:=0 to length(mtrute[a])-1 do
if rute[a]='' then
rute[a]:=rute[a] + inttostr(mtrute[a,b])
else
rute[a]:=rute[a] + '-' + inttostr(mtrute[a,b]);
mmOutput.Lines.Add('Rute '+inttostr(a+1)+' = ['+rute[a]+'], dengan panjang rute = '+formatfloat('0.##',HitungJarak(mtrute[a]))+' km dan waktu tempuh = '+formatfloat('0.#',HitungW(mtrute[a]))+' jam.');
end;
mmOutput.Lines.Add('Total jarak tempuh = '+formatfloat('0.##',TotalJarak(mtrute))+' km dan total waktu yang dibutuhkan = '+formatfloat('0.#',TotalWaktu(mtrute))+' jam.');
mmOutput.Lines.Add('');//}
end;

end.
