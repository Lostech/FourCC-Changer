unit mainunit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    BrowseButton: TSpeedButton;
    Label2: TLabel;
    AVIName: TEdit;
    FourCCLongDesc: TMemo;
    Panel1: TPanel;
    ApplyButton: TSpeedButton;
    QuitButton: TSpeedButton;
    OpenDialog: TOpenDialog;
    FourCCDesc: TComboBox;
    Label1: TLabel;
    FourCCCodec: TComboBox;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FourCCDescChange(Sender: TObject);
    procedure QuitButtonClick(Sender: TObject);
    procedure BrowseButtonClick(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  FourCCDescription: TStringList;

const
  FourCCDescCode: String = 'mp41|mp42|mp43|DIV4';
  FourCCUsedCode: String = 'MP41|MP42|MP43|DIV3';

implementation

{$R *.lfm}



procedure TMainForm.QuitButtonClick(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  FourCCList: TStringList;
  EntryText: TStringList;
  Entry: Integer;

begin
  MainForm.Icon:=Application.Icon;
  FourCCDesc.Clear;
  FourCCCodec.Clear;
  if FileExists('FourCC.dat')=false then
    begin
      FourCCDesc.Items.StrictDelimiter:=true;
      FourCCDesc.Items.Delimiter:='|';
      FourCCDesc.Items.DelimitedText:=FourCCDescCode;
      FourCCCodec.Items.StrictDelimiter:=true;
      FourCCCodec.Items.Delimiter:='|';
      FourCCCodec.Items.DelimitedText:=FourCCUsedCode;
    end
  else
    begin
      FourCCList:=TStringList.Create;
      EntryText:=TStringList.Create;
      FourCCDescription:=TStringList.Create;
      FourCCList.LoadFromFile('FourCC.dat');
      for Entry:=0 to FourCCList.Count-1 do
        begin
          if (LeftStr(Trim(FourCCList.Strings[Entry]),1))<>'#' then
            begin
              EntryText.Clear;
              EntryText.StrictDelimiter:=true;
              EntryText.Delimiter:=#9;
              EntryText.DelimitedText:=FourCCList.Strings[Entry];
              FourCCDesc.Items.Add(EntryText.Strings[1]);
              FourCCCodec.Items.Add(EntryText.Strings[0]);
              FourCCDescription.Add(EntryText.Strings[2]);
            end;
        end;
      if FourCCList<>NIL then FourCCList.Free;
      if EntryText<>NIL then EntryText.Free;
    end;
end;

procedure TMainForm.FourCCDescChange(Sender: TObject);
begin
  if FourCCDesc.ItemIndex<=FourCCDescription.Count then
    FourCCLongDesc.Text:=FourCCDescription.Strings[FourCCDesc.ItemIndex]
  else
    FourCCLongDesc.Text:='No description available';
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if FourCCDescription<>NIL then FourCCDescription.Free;
  CloseAction:=caFree;
end;

procedure TMainForm.BrowseButtonClick(Sender: TObject);
var
  F : File;
  S : String[4];
begin
  If OpenDialog.Execute = True then
  Begin
    SetLength(S,4);
    AssignFile(F,OpenDialog.FileName);
    {$I-}
    Reset(F,1);
    {$I+}
    If IOResult = 0 then
    Begin
      Seek(F,$70);
      BlockRead(F,S[1],4);
      FourCCDesc.Text := S;
      Seek(F,$BC);
      BlockRead(F,S[1],4);
      FourCCCodec.Text := S;
      AVIName.Text := ExtractFileName(OpenDialog.FileName);
      AVIName.Hint := OpenDialog.FileName;
      ApplyButton.Enabled := True;
      CloseFile(F);
    End
      else
    Begin
      MessageDLG('Unable to open file, might be read-only.',mtError,[mbok],0);
    End;
  End;
  FourCCDescChange(self);
end;

procedure TMainForm.ApplyButtonClick(Sender: TObject);
var
  F : File;
  S : String[4];
begin
  If (Length(FourCCDesc.Text) = 4) and (Length(FourCCCodec.Text) = 4) then
  Begin
    AssignFile(F,OpenDialog.FileName);
    Reset(F,1);
    Seek(F,$70);
    S := FourCCDesc.Text;
    BlockWrite(F,S[1],4);
    Seek(F,$BC);
    S := FourCCCodec.Text;
    BlockWrite(F,S[1],4);
    CloseFile(F);
    MessageDLG('FourCC code for ['+OpenDialog.Filename+'] has been set.',mtInformation,[mbok],0);
  End
    else
  Begin
    MessageDLG('FourCC code must be 4-Characters long, duh!',mtError,[mbok],0);
  End;
end;

end.
