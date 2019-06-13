unit NetEnvironmentUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ComCtrls, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    CheckGroup1: TCheckGroup;
    RadioGroup1: TRadioGroup;
    TreeTreeRes: TTreeView;
    procedure BitBtn1Click(Sender: TObject);
    procedure CheckGroup1Click(Sender: TObject);
  private
    procedure EnumNet(const ParentNode: TTreeNode; ResScope, ResType: DWORD;
      const NetContainerToOpen: PNetResource);
    function EnumResources(const ParentNode: TTreeNode; ResScope, ResType,
      ResUsage: DWORD; hNetEnum: THandle): UINT;
    function OpenEnum(const NetContainerToOpen: PNetResource; ResScope,
      ResType, ResUsage: DWORD): THandle;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.EnumNet(const ParentNode: TTreeNode; ResScope, ResType: DWORD; const NetContainerToOpen: PNetResource);
var
  hNetEnum: THandle;
begin
// Инициализировать операцию поиска ресурсов
 hNetEnum := OpenEnum(NetContainerToOpen, ResScope, ResType, RESOURCEUSAGE_CONNECTABLE or RESOURCEUSAGE_CONTAINER);
// Если поиск ресурсов невозможно запустить, то выход
 if (hNetEnum = 0) then exit;
// Функция поиска ресурсов
 EnumResources(ParentNode, ResScope, ResType, RESOURCEUSAGE_CONNECTABLE or RESOURCEUSAGE_CONTAINER, hNetEnum);
// Закрыть перечисление ресурсов
 if (NO_ERROR <> WNetCloseEnum(hNetEnum)) then ShowMessage('WNetCloseEnum Error');
end;

function TForm1.OpenEnum(const NetContainerToOpen: PNetResource;ResScope, ResType, ResUsage: DWORD): THandle;
var
   hNetEnum: THandle;
begin
     Result := 0;
     if (NO_ERROR <> WNetOpenEnum(ResScope, ResType, RESOURCEUSAGE_CONNECTABLE or RESOURCEUSAGE_CONTAINER,NetContainerToOpen, hNetEnum)) then
        showmessagefmt('Ошибка open enum %d',[getLastError]);
        SysErrorMessage(GetLastError)
     else
        Result := hNetEnum;
end;

function TForm1.EnumResources(const ParentNode: TTreeNode;
                              ResScope, ResType, ResUsage: DWORD;
                              hNetEnum: THandle): UINT;

function ShowResource(const ParentNode: TTreeNode; Res: TNetResource): TTreeNode;
var
   Str:String;
   index:Integer;
begin
   Result:=ParentNode;
   if Res.lpRemoteName=nil then exit;
   Str:=string(Res.lpRemoteName);
   index:=Pos('\',Str);
      While index>0 do
           begin
             Str:=Copy(Str,index+1,Length(Str));
             index:=Pos('\',Str);
           end;
Result := TreeTreeRes.Items.AddChild(ParentNode, Str);
end;

var
    ResourceBuffer: array[1..2000] of TNetResource;
    i,ResourceBuf,EntriesToGet: DWORD;
    NewNode: TTreeNode;
begin
     Result := 0;
       while TRUE do
            begin
              ResourceBuf := sizeof(ResourceBuffer);
              EntriesToGet := 2000;
// Системная функция поиска ресурсов
               if (NO_ERROR <> WNetEnumResource(hNetEnum,EntriesToGet,@ResourceBuffer,ResourceBuf)) then
                   begin
                     case GetLastError() of
                          NO_ERROR: break;
                          ERROR_NO_MORE_ITEMS: exit;
                     else
                          ShowMessage('Ошибка enum resources');
                          Result := 1;
                          exit;
                     end;
               end;  //if

// рекурсивный поиск нового ресурса.
           for i := 1 to EntriesToGet do
              begin
                NewNode := ShowResource(ParentNode, ResourceBuffer[i]);
                   if (ResourceBuffer[i].dwUsage and RESOURCEUSAGE_CONTAINER) <> 0 then
                      EnumNet(NewNode, ResScope, ResType, @ResourceBuffer[i]);
              end;   //for
      end;  //while
end;

procedure TForm1.CheckGroup1Click(Sender: TObject);
begin

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
ResScope,
ResType:DWORD;
Begin
// Очистка компонента TTreeView от текущих данных
TreeTreeRes.Items.Clear;
// Проверка, какой компонент RadioButton выбран


case RadioGroup1.itemIndex of
     0: ResScope := RESOURCE_GLOBALNET;
     1: ResScope := RESOURCE_CONNECTED ;
     2: ResScope := RESOURCE_REMEMBERED;
end;


// Проверка того, что нужно искать
ResType:=0;

if CheckGroup1.Checked[0] then
ResType := ResType or RESOURCETYPE_ANY;
if CheckGroup1.Checked[1] then
ResType := ResType or RESOURCETYPE_DISK;
if CheckGroup1.Checked[2] then
ResType := ResType or RESOURCETYPE_PRINT;
// Запуск  процедуры поиска
 EnumNet(TreeTreeRes.Items.Add(NIL, 'Сетевое окружение'), ResScope, ResType, NIL);
end;


end.

