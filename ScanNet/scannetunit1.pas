unit ScanNETunit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,windows, winsock;

type

  { TForm1 }

  TForm1 = class(TForm)

    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
    Form1: TForm1;
    i:integer;
implementation

{$R *.lfm}

procedure scan ;
var
    s: TSocket; {Сокет}
    recipient: TSockAddr; {адрес сокета получателя}
    ret: Integer; {результат работы функций}
    j: Integer;
    addr: Array[1..20] of char;
begin
    j:=i;
    StrPCopy(@addr, Form1.Edit1.text);
    // Создание сокета клиента
    s := socket(AF_INET,SOCK_STREAM, 0);
    If s=INVALID_SOCKET then
       ShowMessageFmt('Ошибка %d при создании сокета', [WSAGetLastError])
    else begin
        // Формирование адреса сервера (получателя сообщения)
        ZeroMemory(@recipient,sizeof(recipient));
        recipient.sin_family := AF_INET;
        recipient.sin_port := htons(j);
        recipient.sin_addr.S_addr := inet_addr(@addr);

        // Установление соединения
        ret := connect(s, recipient, sizeof(recipient));

         If ret=SOCKET_ERROR then
            Form1.Memo1.Lines.Add('Порт '+IntToStr(j)+' не отвечает')
        else
            Form1.Memo1.Lines.Add('Порт '+IntToStr(j)+' соединение установ-лено');

        // закрытие сокета
        CloseSocket(s);
    end;
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
   var
      hThread: Array [1..100] of THandle;
      pFunc: Array [1..100] of pointer;
      ThreadID: Array [1..100] of CARDINAL;
      wsd: WSADATA; {Структура WSADATA, требуется для инициа-лизации интерфейса сокетов}
      k, n,ii: Integer;

begin
   // Инициализация интерфейса сокетов
    if WSAStartup(MAKEWORD(2,2), wsd)<>0 then
        ShowMessageFmt('Ошибка %d при инициализации интерфей-са сокетов', [WSAGetLastError])
    else begin
        ii:=1;
        k := StrToInt(Edit2.Text); n := StrToInt(Edit3.Text);
        for i := k to n do
        begin
            ii:=ii+1;
            pFunc[ii] := @scan;

            // создание очередного потока для сканирования сети
            hThread[ii] := CreateThread(nil, 0, pFunc[ii], nil, 0, ThreadID[ii]);
            sleep(30);
        end;
        //WSACleanup;
    end;
end;
end.

