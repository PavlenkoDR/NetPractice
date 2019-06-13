unit Filesunit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin

If MessageDlg('Вы действительно хотите очистить окно?',mtWarning, mbYesNo, 0)=mrYes Then Memo1.Lines.Clear;
end;

procedure TForm1.Button2Click(Sender: TObject);
 Var
    FileHandle: THANDLE ;
    BytesWritten, BytesRead: Cardinal;
    BytesToWrite:Cardinal;
    buffer:Array[1..255] of char;
    ReadString:string;
    UNCFileName:string;
begin
    UNCFileName:=Edit1.Text;
    FileHandle:= CreateFile(PChar(UNCFileName),
                            GENERIC_WRITE or GENERIC_READ,
                            FILE_SHARE_READ or FILE_SHARE_WRITE, Nil,
                            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

    If FileHandle=INVALID_HANDLE_VALUE then
    begin
       ShowMessage(SysErrorMessage(GetLastError))
    end else begin
        ZeroMemory(@buffer, sizeof(buffer));
    end;

    if(ReadFile(FileHandle, buffer, sizeOf(Buffer), BytesRead, Nil) = False) then
    begin
        ShowMessage(SysErrorMessage(GetLastError))
    end else begin
        ReadString:=StrPas(@buffer);
        ShowMessage(readString);
        Memo1.Lines.Text:=ReadString;
        if (CloseHandle(FileHandle) = False) then
        begin
           ShowMessage(SysErrorMessage(GetLastError))
        end;
    end;

end;

procedure TForm1.Button3Click(Sender: TObject);
 Var
    FileHandle: THANDLE ;
    BytesWritten, BytesRead: Cardinal;
    BytesToWrite:Cardinal;
    buffer:Array[1..255] of char;
    stringToWrite:string;
    UNCFileName:string;
begin
    // Получить дескриптор \\.\C:\sample.txt
    UNCFileName:=Edit1.Text;
    FileHandle:= CreateFile(PChar(UNCFileName),
                            GENERIC_WRITE or GENERIC_READ,
                            FILE_SHARE_READ or FILE_SHARE_WRITE, Nil,
                            CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

    If FileHandle=INVALID_HANDLE_VALUE then
    begin
       ShowMessage(SysErrorMessage(GetLastError))
    end else begin
        stringToWrite:=Memo1.Lines.Text;
        ZeroMemory(@buffer, sizeof(buffer)) ;
        StrPCopy(@buffer, PChar(stringToWrite));
        BytesToWrite:=length(stringToWrite);

        if (WriteFile(FileHandle, buffer, BytesToWrite, BytesWritten, Nil)) then
        begin
             ShowMessage('Файл записан!!!');
             if not (CloseHandle(FileHandle)) then
             begin
                ShowMessage(SysErrorMessage(GetLastError));
             end;
        end else begin
            ShowMessage(SysErrorMessage(GetLastError));
        end;
    end;

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
    If MessageDlg('Вы действительно хотите удалить файл ?',mtWarning, mbYesNo, 0)=mrYes then
    begin
        if DeleteFile(PChar(Edit1.Text)) then
        begin
           ShowMessage('Файл удален!')
        end else begin
            ShowMessage(SysErrorMessage(GetLastError));
        end;
    end;
end;
end.

