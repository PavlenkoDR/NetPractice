unit UDPServerUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, windows, winSock;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
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

procedure TForm1.Button1Click(Sender: TObject);
type
pu_long = ^u_long;

  var
      s: TSocket; {Сокет}
      local_socket, sender_socket: TSockAddr; {адреса сокета сервера и сокета отправителя}
      ret: Integer; {результат работы функций}
      bufr: Array [1..90] of char; {буфер для получаемых от клиента данных}
      msgstring: Array [1..90] of char; {буфер для вывода сообщения на экран}
      bufs: Array [1..80] of char; {буфер для передачи ответа клиенту}
      wsd: WSADATA;{Структура WSADATA, требуется для инициализа-ции интерфейса сокетов}
      size_socket: Integer; {размер структуры TSockAddr}


  varTWSAData : TWSAData;
  varPHostEnt : PHostEnt;
  varTInAddr : TInAddr;
  namebuf : Array[0..255] of AnsiChar;
  Str:STRING;

  begin
// Определяем Ip  адрес сервера
    If WSAStartup($101,varTWSAData) <> 0 Then
  str := 'No. IP Address'
  Else Begin
    gethostname(namebuf,sizeof(namebuf));
    varPHostEnt := gethostbyname(namebuf);
    varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
    str := inet_ntoa(varTInAddr);
  End;
  WSACleanup;

Label1.Caption:='IP:'+str;

    //Инициализация интерфейса сокетов
      If WSAStartup(MAKEWORD(2,2),wsd)<>0 then ShowMessageFmt('Ошибка %d   при  инициализации интерфейса сокетов', [WSAGetLastError])
      else
          begin
            // Создание сокета сервера
              s:=socket(AF_INET,SOCK_DGRAM,0);
                If s=INVALID_SOCKET Then ShowMessageFmt('Ошибка  %d при создании Сокета',[WSAGetLastError])
                else
                  Begin
                    // Запись в поля переменной local адреса и номера порта сервера,
                      // по которому сервер будет принимать датаграммы
                        Local_socket.sin_family :=AF_INET;
                        Local_socket.sin_port := htons(2000);
                        Local_socket.sin_addr.S_addr:=htonl(INADDR_ANY);
                          // привязка адреса и номера порта к сокету сервера
                            // т. е. сервер ожидает данные от любого клиента (INADDR_ANY)
                              // если данные передаются на порт 2000
                        ret := bind(s,local_socket, sizeof(local_socket));
                           If ret=SOCKET_ERROR then
                              begin
                                ShowMessageFmt('Ошибка %d при объявлении сокета',[WSAGetLastError]);
                                CloseSocket(s);
                              end
                           else
                              begin
                                ret:=0;
                                size_socket:= Sizeof(sender_socket);
                                ZeroMemory(@bufr, sizeof(bufr));
                                // Получение данных от клиента
                                ret := recvfrom(s, bufr, sizeof(bufr), 0, sender_socket, size_socket);
                                   If ret=SOCKET_ERROR then ShowMessageFmt('Ошибка %d при получении данных ',[WSAGetLastError])
                                   else
                                     begin
                                       // Формирование сообщения msgstring для вывода на экран
                                         StrCopy(@msgstring, 'Получено сообщение:');
                                         StrCat(@msgstring, @bufr);
                                         StrCat(@msgstring,' от');
                                         StrCat(@msgstring,inet_ntoa(sender_socket.sin_addr));
                                         ShowMessage(msgstring);
                                     end;
                                StrCopy(@bufs, @bufr);
                                // Пересылка эхоответа клиенту
                                ret :=sendto(s, bufs, sizeof(bufs), 0, sender_socket, sizeof(sender_socket));
                                If ret=SOCKET_ERROR then
                                   begin
                                      ShowMessageFmt('Ошибка %d при передаче данных ',[WSAGetLastError]);
                                      CloseSocket(s);
                                   end;
                                   // закрытие сокета
                                CloseSocket(s);
                              end;
                  end;
  WSACleanup;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);

begin


end;






end.

