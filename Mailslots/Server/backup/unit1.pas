unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,Windows;

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
var
    Mailslot:THANDLE;
    buffer:Array[1..80] of char;//Объявляется одномерный массив символьных //данных  buffer размерности 80
    NumberOfBytesRead:DWORD;
    ret:Boolean;
begin
    // Создание mailslot
    Mailslot:=CreateMailslot('\\.\Mailslot\Myslot',0,
    MAILSLOT_WAIT_FOREVER, nil);

    if  MailSlot= INVALID_HANDLE_VALUE  then
    begin
        ShowMessageFmt('Ошибка создания mailslot %d ', [GetLastError]);
        exit;
    end;

    ShowMessage('MailSlot Created Ok.');
    // Чтение данных mailslot (блокирующий вызов)
    ret:=ReadFile(Mailslot, buffer, 256, NumberOfBytesRead,Nil); // 256 max length of message

    if ret then
    begin
        buffer[NumberOfBytesRead]:=#0;
        ShowMessage(buffer);
    end else begin
        ShowMessageFmt('Ошибка %d при чтении из mailslot', [GetLastError]);
        exit;
    end;
end;
end.

