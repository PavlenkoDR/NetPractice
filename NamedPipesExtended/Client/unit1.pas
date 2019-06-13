unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
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
CONST
     PIPE_NAME='\\.\Pipe\Jim';
VAR
     PipeHandle: THANDLE;
     Buffer: array [1..80] of char;
     BytesWritten: DWORD;
     BytesRead:DWORD;
     str:string;
begin
if not WaitNamedPipe(PIPE_NAME, NMPWAIT_WAIT_FOREVER)  then
     begin
          ShowMessageFmt('Функция WaitNamedPipe завершена с ошибкой %d', [GetLastError]);
          exit;
     end;
     // Открытие экземпляра именованного канала
PipeHandle := CreateFile(PIPE_NAME,
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         Nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);

if PipeHandle=INVALID_HANDLE_VALUE then
     begin
          ShowMessageFmt('Функция CreateFile завершена с ошибкой %d', [GetLastError]);
          exit;
     end;
ZeroMemory(@buffer, sizeof(buffer)) ;
StrPCopy(@buffer, PChar(Edit1.Text));

if not WriteFile(PipeHandle, Buffer , length(Buffer), BytesWritten, Nil) then
     begin
          ShowMessageFmt('WriteFile failed with error %d', [GetLastError]);
          CloseHandle(PipeHandle);
          exit;
     end;

ZeroMemory(@buffer, sizeof(buffer)) ;

if not ReadFile(PipeHandle, buffer, sizeof(buffer), BytesRead, nil) then
   begin
        ShowMessageFmt('Ошибка %d при чтении данных', [GetLastError]);
        CloseHandle(PipeHandle);
        exit;
   end;
//ShowMessageFmt('Transmitted %d bytes ', [BytesRead]);
str:=StrPas(@buffer);
    Edit2.Text:=str;
CloseHandle(PipeHandle);
end;

end.

