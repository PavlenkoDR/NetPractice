unit netbiosunit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,windows, nb30;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure GetAdapterinfo(Lana: Byte);
var
   Adapter: TAdapterStatus;
   NCB: TNCB;
   res: string;
begin
    FillChar(NCB, SizeOf(NCB), 0);

    {Обнуление  LANA.  В NetBIOS, прежде чем  использовать любой
    LANA, его надо обнулить. Для этого вызывается процедура NbReset, в
    которой  выполняется NetBIOS-команда NCBRESET}

    NCB.ncb_command := byte(NCBRESET);
    NCB.ncb_Lana_num := byte(Lana);

    If NetBios(@NCB)<>Byte(NRC_GOODRET) then
    begin
        Form1.Memo1.Lines.Add('MAC не найден');
        Exit;
    end;
    //Получеиие информации об адаптере
    FillChar(NCB, SizeOf(NCB), 0);
    NCB.ncb_command := byte(NCBASTAT);
    NCB.ncb_lana_num := byte(Lana);
    NCB.ncb_callname[0]:= byte('*');
    FillChar(Adapter, SizeOf( Adapter), 0);
    NCB.ncb_buffer:= @Adapter;
    NCB.ncb_length := SizeOf(Adapter);
    If NetBios(@NCB)<>byte(NRC_GOODRET) then
    begin
        Form1.Memo1.Lines.Add('MAC не найден.');
        Exit;
    end;

    // Формирование аппаратного адреса для вывода на экран

    res := IntToHex(Byte(Adapter.adapter_address[0]), 2) + '-' +
           IntToHex(Byte(Adapter.adapter_address[1]), 2) + '-' +
           IntToHex(Byte(Adapter.adapter_address[2]), 2) + '-' +
           IntToHex(Byte(Adapter.adapter_address[3]), 2) + '-' +
           IntToHex(Byte(Adapter.adapter_address[4]), 2) + '-' +
           IntToHex(Byte(Adapter.adapter_address[5]), 2) + '-';

    Form1.Memo1.Lines.Add('Обнаружен адаптер:' + res);
    Form1.Memo1.Lines.Add ('Макс. размер датаграмм: ' +  IntToStr(Adapter.max_dgram_size)+'байт');
    Form1.Memo1.Lines.Add ('Maкс. размер пакета сессии:'+ IntToStr ( Adapter.max_sess_pkt_size));
    Form1.Memo1.Lines.Add(' Число имен в локальной таблице: '+IntToStr(Adapter.name_count));
    Form1.Memo1.Lines.Add('Taйм-ayт:' + IntToStr(Adapter.ti_timeouts));
    Form1.Memo1.Lines.Add ('_________________________________');
end;

procedure GetMACAddress();
var
    AdapterList: TLanaEnum;
    NCB: TNCB;
    i: byte;
begin
    FillChar(NCB, SizeOf(NCB), 0);

    //Определение доступных сетевых устройств
    //Заполнение структура NCB
    NCB.ncb_command := byte(NCBENUM);
    NCB.ncb_buffer := @AdapterList;
    NCB.ncb_length := SizeOf(AdapterList);
    Netbios(@NCB);

    for i := 0 to Byte(AdapterList.length)-1 do
        GetAdapterInfo(AdapterList.lana[i]);

    If Byte(AdapterList.length)=0 then
       Form1.Memo1.Lines.Add('MAC адрес не найден.');
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
    Memo1.lines.Clear;
    GetMACAddress();
end;



end.

