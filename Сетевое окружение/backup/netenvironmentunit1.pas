unit NetEnvironmentUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
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
   hNetEnum: THandle;
   NetContainerToOpen: NETRESOURCE;
   ResourceBuffer: array[1..2000] of TNetResource;
   i,ResourceBuf,EntriesToGet: DWORD;
begin

//Заполнение структуры NETRESOURCE
NetContainerToOpen.dwScope :=RESOURCE_GLOBALNET;
NetContainerToOpen.dwType :=RESOURCETYPE_ANY;
NetContainerToOpen.lpLocalName :=nil;
NetContainerToOpen.lpRemoteName:= PChar('\\'+Edit1.Text);
NetContainerToOpen.lpProvider:= nil;

//Открытие процесса сканирования
WNetOpenEnum (RESOURCE_GLOBALNET, RESOURCETYPE_ANY,
RESOURCEUSAGE_CONNECTABLE or RESOURCEUSAGE_CONTAINER,
@NetContainerToOpen, hNetEnum);
//сканирование сетевых ресурсов
ResourceBuf := sizeof(ResourceBuffer);
EntriesToGet := 2000;
if (NO_ERROR <> WNetEnumResource(hNetEnum, EntriesToGet,
@ResourceBuffer, ResourceBuf)) then exit;

//Вывод на экран найденных ресурсов
for i := 1 to EntriesToGet do
Memo1.Lines.Add(string(ResourceBuffer[i].lpRemoteName));
end;


end.

