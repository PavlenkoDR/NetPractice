unit NamedPipesServerUnit1;

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
    procedure FormCreate(Sender: TObject);
    procedure ThreadRead;
     procedure ThreadWrite;
  private

  public

  end;

var
  Form1: TForm1;
  PipeHandle: THANDLE; {Описатель сервера именованных каналов}
  evntserver: THANDLE;{Объект «событие» для организации работы функции ReadFile и WriteFile в неблокирующем режиме}
  BytesRead: DWORD; {Переменная для хранения количества
                                      переданных серверу байт}
  buffers: Array [0..80] of char; {Буфер, в который записываются прочитанные сервером сообщения}
  Pipe_name: Array [0..80] of char {Буфер для хранения имени  канала};
  OvLap: TOVERLAPPED; {Структура OVERLAPPED  дляработы сервера в неблокирующем режиме}
  ret: Boolean; {В эту переменную записывается результат операции}
  BytesWritten: DWORD;{Количество передаваемых байт}
  hThreadR, hThreadW: THANDLE; {Описатели дополнительных программных потоков для чтения и записи в неблокирующем режиме}
  pFunc1, pFunc2: pointer; {Указатели функций, на основе  которых создаются вспомогательные потоки}
  ThreadID1, ThreadID2: CARDINAL; {Идентификаторы   вспомогательных потоков}


implementation

{$R *.lfm}

procedure TForm1.ThreadRead;
begin
     ZeroMemory(@Ovlap, sizeof(TOVERLAPPED));
     OvLap.hEvent := Evntserver;
     ZeroMemory(@buffers, sizeof(buffers));
     ret := ReadFile(PipeHandle, buffers, sizeof(buffers), BytesRead, @OvLap);
     WaitForSingleObject(Evntserver,Infinite);
     Form1.Edit2.Text := Buffers;
end;

procedure TForm1.ThreadWrite;
Var
   retw: Boolean;
   Bf: Array [0..80] of Char;
begin
     ZeroMemory(@Ovlap, sizeof(TOVERLAPPED));
     OvLap.hEvent := Evntserver;
     StrCopy(@Bf, PChar(Form1.Edit1.Text));
     retw := WriteFile(PipeHandle, Bf, sizeof(bf), BytesWritten, @OvLap);
     WaitForSingleObject(evntserver,INFINITE);
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  //Создание события на сервере
  Evntserver := CreateEvent(Nil, FALSE, FALSE, Nil);
  if EvntServer=0 then
     begin
       ShowMessageFmt('Ошибка %d при создании объекта событие',[GetLastError]);
       CloseHandle(PipeHandle);
       exit;
     end;

end;

procedure TForm1.Button1Click(Sender: TObject);           //кНОПКА СОЗДАТЬ КАНАЛ
begin
  PipeHandle := CreateNamedPipe('\\.\Pipe\Jim',
                                PIPE_ACCESS_DUPLEX or FILE_FLAG_OVERLAPPED,
                                PIPE_TYPE_BYTE or PIPE_READMODE_BYTE,
                                1,
                                0,
                                0,
                                1000,
                                Nil);
if PipeHandle=INVALID_HANDLE_VALUE then
   begin
        ShowMessageFmt('Ошибка %d при создании именованного канала',[GetLastError]);
        exit;
   end;
ShowMessage('Сервер работает. Создайте клиента');
end;

procedure TForm1.Button2Click(Sender: TObject);         //кНОПКА ПРОЧИТАТЬ СООБЩЕНИЕ
begin
  pFunc1 := @ThreadRead;
  hThreadR := CreateThread(nil,
                           0,
                           pFunc1,
                           nil,
                           0,
                           ThreadID1);

end;

procedure TForm1.Button3Click(Sender: TObject);         //кНОПКА ЗАПИСАТЬ СООБЩЕНИЕ
begin
  pFunc2 := @ThreadWrite;
  hThreadW := CreateThread(nil,0, pFunc2, nil, 0, ThreadID2);

end;

procedure TForm1.Button4Click(Sender: TObject);      // КНОПКА ЗАКРЫТЬ КАНАЛ
begin
  if NOT DisconnectNamedPipe(PipeHandle) then
     begin
       ShowMessageFmt('Ошибка %d при закрытии канала', [GetLastError]);
     end;
CloseHandle(PipeHandle);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  ShowMessage('Работа в неблокирующем режиме');
end;



end.

