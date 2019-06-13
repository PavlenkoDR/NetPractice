unit UDPClientUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, WinSock, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
VAR
   s: TSocket; {Сокет}
   recipient, sender_socket: TSockAddr; {адреса сокета получателя и сокета отправителя}
   ret: Integer; {результат работы функций}
   wsd: WSADATA; {Структура WSADATA, требуется для инициа-лизации интерфейса сокетов}
   bufr: Array[0..90] of char; {буфер для передачи данных на сервер}
   msgstring: Array[0..90] of char; {буфер для вывода сообщения на экран}
   bufs: Array [1..80] of char; {буфер для получения ответа от серве-ра}
   size_socket: Integer; {размер структуры TSockAddr}
begin
// Инициализация интерфейса сокетов
   If WSAStartup(MAKEWORD(2,2), wsd )<>0  Then ShowMessageFmt('Ошибка  %d  при   инициализации   ин-терфейса сокетов', [WSAGetLastError])
   else
    begin
         // Создание сокета клиента
      s := socket(AF_INET, SOCK_DGRAM,0);
      If s=INVALID_SOCKET then ShowMessageFmt('Ошибка %d при создании сокета', [WSAGetLastError])
      else
        begin
         // Формирование адреса сервера (получателя сообщения)
          ZeroMemory(@recipient, sizeof(recipient));
          recipient.sin_family:= AF_INET;
          recipient.sin_port:=htons(2000);
          recipient.sin_addr.S_addr := inet_addr(PChar(Edit2.Text));
          // Передаваемое сообщение
          strcopy(@bufs, PChar(Edit1.Text));
          // Передача сообщения серверу
          ret := sendto(s, bufs, sizeof(bufs), 0, recipient, sizeof(recipient));
          If ret=SOCKET_ERROR then ShowMessageFmt('Ошибка %d при передаче данных', [WSAGetLastError]);
             ZeroMemory(@bufr, sizeof(bufr));
             Size_socket := Sizeof(sender_socket);
               // Получение ответа от сервера
               ret := recvfrom(s, bufr, sizeof(bufr), 0, sender_socket, size_socket);
               If ret=SOCKET_ERROR then ShowMessageFmt('Ошибка %d при получении ответа', [WSAGetLastError])
               Else
                   begin
                      //Формирование сообщения msgstring для вывода на экран
                      StrCopy(@msgstring, 'Получен ответ:');
                      StrCat(@msgstring, @bufr);
                      StrCat(@msgstring,' от');
                      StrCat(@msgstring, inet_ntoa( sender_socket.sin_addr));
                      ShowMessage(msgstring);
                   End;
           // закрытие сокета
           CloseSocket(s);
        end;
WSACleanup;
End;
end;


end.

