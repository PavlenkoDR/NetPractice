unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
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
   PipeHandle: THANDLE;                         // дискриптор именованного канала
   BytesRead: DWORD;                            //число прочитанных байт
   buffer: Array [1..80]of char;                // Буфер куда читаем
   msg:string;
begin
PipeHandle := CreateNamedPipe('\\.\Pipe\Jim',
                              PIPE_ACCESS_DUPLEX,                        // данные можно слать в обе стороны
                              PIPE_TYPE_BYTE or PIPE_READMODE_BYTE,     // режим чтения-записи байтовый а не пакетами
                              1,                                        //кол-во каналов, которое может создать сервер
                              0,                                        //размер буфера на запись
                              0,                                        //размер буфера на чтение
                              1000,                                     // время ожидания соединения
                              Nil);                                     // даискриптор безоапсности nil-по умолчанию

if PipeHandle=INVALID_HANDLE_VALUE then
   begin
        ShowMessageFmt('Ошибка %d при создании именованного канала',[GetLastError]);
        exit;
   end;
ShowMessage('Сервер работает');

if not ConnectNamedPipe(PipeHandle, Nil) then
   begin
        ShowMessageFmt('Ошибка %d при соединении по именован. каналу',[GetLastError]);
        CloseHandle(PipeHandle);
        exit;
   end;

ZeroMemory(@buffer, sizeof(buffer));
if not ReadFile(PipeHandle, buffer, sizeof(buffer), BytesRead, nil) then                //nil - режим блокирующий
   begin
        ShowMessageFmt('Ошибка %d при чтении данных', [GetLastError]);
        CloseHandle(PipeHandle);
        exit;
   end;
 msg:=StrPas(@buffer);
ShowMessage(msg);
if not DisconnectNamedPipe(PipeHandle)then
   begin
     ShowMessageFmt('Ошибка %d при закрытии канала', [GetLastError]);
     exit;
   end;
CloseHandle(PipeHandle);
end;


end.

