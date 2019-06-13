unit TCPSocketServerUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, WinSock, windows;

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
  Form1.Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
    ServerSocket,ClientSocket: TSocket; {Сокет}
    Addr_server, addr_client: TSockAddr; {адреса сокета сервера и соке-та отправителя}
    ret: Integer; {результат работы функций}
    bufr: Array [1..90] of char; {буфер для получаемых от клиента дан-ных}
    msgstring: Array [1..90] of char; {буфер для вывода сообщения на экран}
    bufs: Array [1..80] of char; {буфер для передачи ответа клиенту}
    wsd: WSADATA; {Структура WSADATA, требуется для инициали-зации интерфейса сокетов}
    size_addr: Integer; {размер структуры TSockAddr}
    on: Integer;
begin
    //Инициализация интерфейса сокетов
    If WSAStartup(makeword(2,2),wsd)<>0 then
        ShowMessageFmt('Ошибка %d при инициализации интерфейса сокетов', [WSAGetLastError])
    else begin
        // Создание сокета сервера
        ServerSocket:=socket(AF_INET,SOCK_STREAM, 0);

        if ServerSocket=INVALID_SOCKET then
            ShowMessageFmt('Ошибка %d при создании сокета', [WSAGetLastError])
        else begin
            // Запись в поля переменной local адреса и номера порта сервера,
            // по которому сервер будет принимать датаграммы
            Addr_server.sin_family :=AF_INET;
            Addr_server.sin_port := htons(2000);
            Addr_server.sin_addr.S_addr:= htonl(INADDR_ANY);

            // настройка опций сокета
            on := 1;
            ret:=setsockopt(ServerSocket, SOL_SOCKET,SO_REUSEADDR, @on, sizeof(on));
            if ret=SOCKET_ERROR then
            begin
                ShowMessageFmt('Ошибка %d при настройке сокета', [WSAGetLastError]) ;
                CloseSocket(ServerSocket);
            end else begin
            // привязка адреса и номера порта к сокету сервера
            // т.е. сервер ожидает данные от любого клиента (INADDR_ANY)
            // если данные передаются на порт 2000
            ret:=bind(ServerSocket, addr_server, sizeof(addr_server));

            if ret=SOCKET_ERROR then
            begin
                ShowMessageFmt('Ошибка %d при объявлении сокета ',[WSAGetLastError]);
                CloseSocket(ServerSocket);
            end else begin
                ret:= listen(ServerSocket,5);

                if ret=SOCKET_ERROR then
                begin
                    ShowMessageFmt('Ошибка %d при вызове listen', [WSAGetLastError]);
                    CloseSocket (ServerSocket);
                end else begin
                    size_addr:=Sizeof(addr_client);
                    ClientSocket:= accept(ServerSocket, @addr_client, @size_addr);

                    if ClientSocket=SOCKET_ERROR then
                    begin
                        ShowMessageFmt('Ошибка %d при вызове accept', [WSAGetLastError]);
                        CloseSocket(ServerSocket);
                    end else begin
                        ZeroMemory(@bufr, sizeof(bufr));

                        // Получение данных от клиента
                        ret := recv(ClientSocket, bufr, sizeof(bufr), 0);

                        if ret=SOCKET_ERROR then
                        begin
                            ShowMessageFmt('Ошибка %d при получении данных',[WSAGetLastError]);
                            CloseSocket(ServerSocket);
                        end else begin
                            // Формирование сообщения msgstring для вывода на экран
                            StrCopy(@msgstring, 'Получено сообщение:');
                            StrCat(@msgstring, @bufr);
                            StrCat(@msgstring,' от');
                            StrCat(@msgstring, inet_ntoa(addr_client.sin_addr));
                            ShowMessage(msgstring);
                        end;

                        StrCopy(@bufs, @bufr);
                        // Пересылка эхоответа клиенту
                        Ret:=send(ClientSocket, bufs, sizeof(bufs), 0);

                        if ret=SOCKET_ERROR then
                        begin
                        ShowMessageFmt('Ошибка %d при передаче данных',[WSAGetLastError]);
                        CloseSocket(ServerSocket);
                        end;
                    end;
                    // закрытие сокета
                    CloseSocket(ServerSocket);
                end;
            end;
            end;
        end;
        WSACleanup;
    end;
end;

end.

