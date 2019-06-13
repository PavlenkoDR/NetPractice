unit TCPSocketClientUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, windows, WinSock;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button2Click(Sender: TObject);
begin
  Form1.Close();
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   s: TSocket; {Сокет}
   recipient, sender_socket: TSockAddr; {адреса сокета получателя и сокета отправителя}
   ret: Integer; {результат работы функций}
   wsd: WSADATA; {Структура WSADATA, требуется для инициали-зации интерфейса сокетов}
   bufr: array[0..90] of char; {буфер для передачи данных на сервер}
   msgstring: array[0..90] of char {буфер для вывода сообщения на экран};
   bufs: array [1..80] of char; {буфер для получения ответа от сервера}
   size_socket: Integer; {размер структуры TSockAddr}
begin
    // Инициализация интерфейса сокетов
    If WSAStartup(MAKEWORD(2,2),wsd)<>0   then ShowMessageFmt('Ошибка %d при инициализации интерфейса сокетов', [WSAGetLastError])
    else begin
        // Создание сокета клиента
        s :=socket(AF_INET, SOCK_STREAM,0);
        if s=INVALID_SOCKET then
            ShowMessageFmt('Ошибка %d при создании сокета', [WSAGetLastError])
        else begin
            // Формирование адреса сервера (получателя сообщения)
            ZeroMemory(@recipient, sizeof(recipient));
            recipient.sin_family :=AF_INET;
            recipient.sin_port:=htons(2000);
            recipient.sin_addr.S_addr := inet_addr('127.0.0.1');

            // Установление соединения
            ret:=connect(s, recipient, sizeof(recipient));
            If ret=SOCKET_ERROR then
                ShowMessageFmt('Ошибка %d при установлении соединения', [WSAGetLastError])
            else begin
                //Передаваемое сообщение
                strcopy(@bufs, 'Это мой тест');

                // Передача сообщения серверу
                ret := send(s, bufs, sizeof(bufs), 0);
                If ret=SOCKET_ERROR then ShowMessageFmt('Ошибка %d при передаче данных', [WSAGetLastError]);
                ZeroMemory(@bufr, sizeof(bufr));
                Size_socket := Sizeof(sender_socket);

                // Получение ответа от сервера
                ret:=recv(s, bufr, sizeof(bufr), 0);
                if ret=SOCKET_ERROR then ShowMessageFmt('Ошибка %d при получении ответа', [WSAGetLastError])
                else begin
                    //Формирование сообщения msgstring дня вывода на экран
                    StrCopy(@msgstring, 'Получен ответ:');
                    StrCat(@msgstring, @bufr);
                    StrCat(@msgstring,' от');
                    StrCat(@msgstring, inet_ntoa(recipient.sin_addr));
                    ShowMessage(msgstring);
                end;
            end;
            // закрытие сокета
            CloseSocket(s);
        end;
        WSACleanup;
    end;
end;


end.

