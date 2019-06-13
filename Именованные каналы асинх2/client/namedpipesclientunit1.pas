unit NamedPipesClientUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  PipeClient: THANDLE; {Описатель клиента именованных каналов}
Evnt: THANDLE;{Объект «событие» для организации работы
функции ConnectNamedPipe в неблокирующем режиме}
Evntclient: THANDLE;{Объект «событие» для организации работы
                                        функции WriteFile в неблокирующем режиме}
BytesRead: DWORD; {Переменная для хранения количества
                                      переданных серверу байт}
buffers: Array [0..80] of char; {Буфер, в который записываются
                                                   прочитанные сообщения}
Pipe_name: Array [0..80] of char {Буфер для хранения имени канала};
OvLap, OvLapClient: TOVERLAPPED; {Структуры OVERLAPPED для
работы клиента  в неблокирующем режиме}
ret: Boolean; {В эту переменную записывается результат операции}
BytesWritten: DWORD;{Количество передаваемых клиентом байт}
hThreadR, hThreadW, hThreadC: THANDLE; {Описатели
дополнительных программных потоков для чтения, записи
и установления соединения в неблокирующем режиме}
pFunc1, pFunc2, pFunc3: pointer; {Указатели функций, на основе
которых создаются вспомогательные потоки}
ThreadID1, ThreadID2, ThreadID3: CARDINAL; {Идентификаторы
вспомогательных потоков}

implementation

{$R *.lfm}

{ TForm1 }
procedure ThreadConnect;
Var
   flg: Boolean;
begin

  ZeroMemory(@Ovlap, sizeof(TOVERLAPPED));
     OvLap.hEvent := Evnt;
     While not flg do
       Begin
        ret := ConnectNamedPipe(PipeClient, @OvLap);
         if (ret<>False) or ((ret<>False) and (GetLastError<>ERROR_PIPE_CONNECTED)) then flg := True
         else  Sleep(1000);
       end;
end;

procedure ThreadRead;
begin
     ZeroMemory(@Ovlap, sizeof(TOVERLAPPED));
     OvLap.hEvent := Evntclient;
     ZeroMemory(@buffers, sizeof(buffers));
     ret := ReadFile(PipeClient, buffers, sizeof(buffers), BytesRead, @OvLap);
     WaitForSingleObject(Evntclient, Infinite);
     Form1.Edit2.Text := Buffers;
end;

procedure ThreadWrite;
Var
   retw: Boolean;
   Bf: Array [0..80] of Char;
begin
     ZeroMemory(@OvlapClient, sizeof(TOVERLAPPED));
     OvLapClient.hEvent := Evntclient;
     StrCopy(@Bf, PChar(Form1.Edit1.Text));
     retw := WriteFile(PipeClient, Bf, sizeof(bf), BytesWritten, @OvLapClient);
     WaitForSingleObject(evntclient, INFINITE);
end;


procedure TForm1.Button6Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  ShowMessage('Работа в неблокирующем режиме');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  strcat(@pipe_Name,'\\.\Pipe\Jim');
    if WaitNamedPipe(@PIPE_NAME, NMPWAIT_WAIT_FOREVER)=False then
       begin
        ShowMessageFmt('Функция WaitNamedPipe завершена с ошибкой %d', [GetLastError]);
        exit;
       end;
// Открытие экземпляра именованного канала
       PipeClient := CreateFile(@PIPE_NAME,
                                GENERIC_READ or GENERIC_WRITE,
                                0,
                                Nil,
                                OPEN_EXISTING,
                                FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED,
                                0);
       if PipeClient=INVALID_HANDLE_VALUE then
           begin
             ShowMessageFmt('Функция CreateFile завершена с ошибкой %d',[GetLastError]);
           end
       else ShowMessage('Клиент работает');

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   pFunc3 := @ThreadConnect;
   hThreadC := CreateThread(nil,0,pFunc3,nil,0,ThreadID1);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  pFunc1 := @ThreadRead;
hThreadR := CreateThread(nil, 0, pFunc1, nil, 0, ThreadID1);

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  pFunc2 := @ThreadWrite;
hThreadW := CreateThread(nil, 0, pFunc2, nil, 0, ThreadID2);

end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if not DisconnectNamedPipe(Pipeclient) then
     begin
       ShowMessageFmt('Ошибка %d при закрытии канала', [GetLastError]);
       exit;
     end;
CloseHandle(PipeClient);
CloseHandle(evnt);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Evnt := CreateEvent(Nil, FALSE, FALSE, Nil);
       if Evnt=0 then
          begin
               ShowMessageFmt('Ошибка %d при создании объекта событие',[GetLastError]);
               exit;
          end;
//Создание события на клиенте
  Evntclient := CreateEvent(Nil, FALSE, FALSE, Nil);
       if Evntclient=0 then
          begin
               ShowMessageFmt('Ошибка %d при создании объекта событие',  [GetLastError]);
               exit;
          end;
end;



end.

