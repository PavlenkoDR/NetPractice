unit MailSlotClientUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Label1Click(Sender: TObject);
begin

end;

procedure TForm1.Button1Click(Sender: TObject);
VAR
Mailslot:THANDLE;
BytesWritten:DWORD;
ServerName:Array[1..256] of char;
i:Integer;
begin
For i:=1 to 256 do ServerName[i]:=#0;
StrPCopy(@ServerName,'\\'+Edit1.Text+'\Mailslot\Myslot');
Mailslot:= CreateFile(@ServerName,
GENERIC_WRITE, FILE_SHARE_READ,
Nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,0);
if Mailslot= INVALID_HANDLE_VALUE then
begin
ShowMessageFmt('Ошибка  %d при создании файла', [GetLastError]);
exit;
end;
if (WriteFile(Mailslot, 'This is a test', 14, BytesWritten, nil) = False) then
begin
ShowMessageFmt('Ошибка %d при записи в файл', [GetLastError]);
exit; end;
ShowMessageFmt('Передано %d байт', [BytesWritten]);
CloseHandle(Mailslot);
end;

end.

