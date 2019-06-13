unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
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
var
    PipeHandle: THANDLE;
    BytesRead: DWORD;
    BytesWritten: DWORD;
    i: integer;
    buffer: Array [1..80]of char;
    str: string;
begin
    PipeHandle := CreateNamedPipe('\\.\Pipe\Jim', PIPE_ACCESS_DUPLEX,
                                  PIPE_TYPE_BYTE or PIPE_READMODE_BYTE, 1, 0, 0, 1000, Nil);

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

    if not ReadFile(PipeHandle, buffer, sizeof(buffer), BytesRead, nil) then
    begin
        ShowMessageFmt('Ошибка %d при чтении данных', [GetLastError]);
        exit;
    end;


    str:=StrPas(@buffer);

    //SetString(str, PChar(@buffer[0]), Length(buffer)); //array of char to string

    //for i := 1 to Length(Buffer) do showMessage(buffer[i]);//str:=str+buffer[i];

    Edit1.Text:=str;
    //ShowMessageFmt('Transmitted %d bytes', [BytesRead]);
    //ShowMessage('str='+str);

    if not WriteFile(PipeHandle, 'Transmittion OK', 15, BytesWritten, Nil) then
    begin
        ShowMessageFmt('WriteFile while confirming, failed with error %d', [GetLastError]);
        exit;
    end;


    if not DisconnectNamedPipe(PipeHandle) then
    begin
        ShowMessageFmt('Ошибка %d при закрытии канала', [GetLastError]);
        exit;
    end;

    CloseHandle(PipeHandle);
end;
end.

