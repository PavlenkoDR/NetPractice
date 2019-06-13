unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,windows;

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
CONST
     PIPE_NAME='\\.\Pipe\Jim';     //имя канала
VAR
   PipeHandle: THANDLE;        //Дискриптор канала
   BytesWritten: DWORD;        // Число записанных байт
begin
     if not WaitNamedPipe(PIPE_NAME, NMPWAIT_WAIT_FOREVER) then        //проверка наличия свободного экземпляра канала
     begin                                                             // не смотря на WAIT_FOREVER если в системе нет такого канала функция сразу даст false
          ShowMessageFmt('Функция WaitNamedPipe завершена с ошибкой %d', [GetLastError]);
          exit;
     end;
// Открытие экземпляра именованного канала
PipeHandle := CreateFile(PIPE_NAME,                             //    имя канала
                         GENERIC_READ or GENERIC_WRITE,         //    открываем на чтение и запись
                         0,                                     //    только один клиент получает доступ к каналу
                         Nil,                                   //    аттрибуты безопасности как в системе NIL
                         OPEN_EXISTING,                         //
                         FILE_ATTRIBUTE_NORMAL,                 //
                         0);                                    //    дискриптор на файл - шаблон


if PipeHandle=INVALID_HANDLE_VALUE then
   begin
        ShowMessageFmt('Функция CreateFile завершена с ошибкой %d', [GetLastError]);
        exit;
   end;
if not WriteFile(PipeHandle, 'This is a test', 14, BytesWritten, Nil) then
   begin
       ShowMessageFmt('WriteFile failed with error %d', [GetLastError]);
       CloseHandle(PipeHandle);
       exit;
   end;
ShowMessageFmt('Передано %d байт', [BytesWritten]);
CloseHandle(PipeHandle);
end;

end.

