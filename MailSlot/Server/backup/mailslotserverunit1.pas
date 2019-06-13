unit MailSlotServerUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
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
var
    Mailslot:THANDLE;
    buffer:Array[1..80] of char;//Объявляется одномерный массив символьных //данных  buffer размерности 80
    NumberOfBytesRead:DWORD;
    ret:Boolean;
begin
    // Создание mailslot
    Mailslot:=CreateMailslot('\\.\Mailslot\Myslot',          // Адрес
                              0,                             // макс размер сообщения. 0 - безразмерно
                              MAILSLOT_WAIT_FOREVER,         // время ожидания чтения
                              nil);                          // аттрибуты безопасности

    if  MailSlot= INVALID_HANDLE_VALUE then
    begin
        ShowMessageFmt('Ошибка создания mailslot %d ', [GetLastError]);
        exit;
    end else begin
        Label1.Caption:='Состояние сервера: Сервер запущен.';
        Application.ProcessMessages;
    end;

    // Чтение данных mailslot (блокирующий вызов)
    ret:=ReadFile(Mailslot,                   // читаем из постового ящика
                  buffer,                     // буффер куда читаем
                  256,                        // сколько данных может быть считано из буфера
                  NumberOfBytesRead,          // сколько байт реально считано по завершении функции
                  Nil);                       // параметр overlapped. nil - блокирующий режим.
    If ret then
    begin
        buffer[NumberOfBytesRead]:=#0;
        ShowMessage(buffer);
    end else begin
        ShowMessageFmt('Ошибка %d при чтении из mailslot', [GetLastError]);
        exit;
    end;
    Label1.Caption:='Состояние сервера: Не запущен.';
end;


end.

