unit nick.toolsapi.shortcut.ShortCutList;

interface

uses
  nick.toolsapi.shortcut.IShortCutList,
  nick.toolsapi.shortcut.ShortCutItem,
  nick.toolsapi.shortcut.IRepositoryFactory,
  nick.toolsapi.shortcut.IIniFileRepository,
  nick.toolsapi.shortcut.IRegistryRepository,
  nick.toolsapi.shortcut.IXmlFileRepository,
  Generics.Collections;

type
  TShortCutListClass = class of TShortCutList;
  TShortCutList = class abstract(TInterfacedObject, IShortCutList)
  private
    FCacheRepositories : Boolean;
    FShortCutItemList : TList<IShortCutItem>;
    FRepositoryFactory : IRepositoryFactory;
    FIniFileRepository : IIniFileRepository;
    FRegistryRepository : IRegistryRepository;
    FXmlFileRepository : IXmlFileRepository;

    function GetShortCut(const AIndex : Integer) : IShortCutItem;
  protected
    function RepositoryFactory() : IRepositoryFactory;

    function GetName() : string; virtual; abstract;
    function GetDescription() : string; virtual;
    procedure PopulateShortCuts(); virtual; abstract;
  public
    constructor Create(const ARepositoryFactory : IRepositoryFactory); virtual;
    destructor Destroy; override;

    procedure Add(const AShortCutItem : IShortCutItem);

    function IniFileRepository() : IIniFileRepository;
    function XmlFileRepository() : IXmlFileRepository;
    function RegistryRepository() : IRegistryRepository;

    procedure RetrieveShortCuts();

    function IsUseable() : Boolean; virtual;

    function Count() : Integer;

    property Name : string read GetName;
    property ShortCut [const AIndex : Integer] : IShortCutItem read GetShortCut;
  end;

implementation

uses
  SysUtils,
  Classes;

constructor TShortCutList.Create(const ARepositoryFactory : IRepositoryFactory);
begin
  inherited Create;
  FShortCutItemList := TList<IShortCutItem>.Create;
  FRepositoryFactory := ARepositoryFactory;

  FCacheRepositories := True;
end;

destructor TShortCutList.Destroy;
begin
  FShortCutItemList.Free;
  inherited;
end;

function TShortCutList.GetDescription: string;
begin
  Result := '';
end;

procedure TShortCutList.Add(const AShortCutItem: IShortCutItem);
begin
  if (AShortCutItem.Primary <> scNone) or
     (AShortCutItem.Secondary <> scNone) then
  begin
    FShortCutItemList.Add(AShortCutItem);
  end;
end;

function TShortCutList.Count: Integer;
begin
  Result := FShortCutItemList.Count;
end;

function TShortCutList.GetShortCut(const AIndex: Integer): IShortCutItem;
begin
  Result := FShortCutItemList.Items[AIndex];
end;

function TShortCutList.IniFileRepository: IIniFileRepository;
begin
  if (not Assigned(FIniFileRepository)) or (not FCacheRepositories) then
    FIniFileRepository := FRepositoryFactory.IniFileRepository();
  Result := FIniFileRepository;
end;

function TShortCutList.IsUseable: Boolean;
begin
  Result := False;
end;

function TShortCutList.RegistryRepository: IRegistryRepository;
begin
  if (not Assigned(FRegistryRepository)) or (not FCacheRepositories) then
    FRegistryRepository := FRepositoryFactory.RegistryRepository();
  Result := FRegistryRepository;
end;

function TShortCutList.RepositoryFactory: IRepositoryFactory;
begin
  Result := FRepositoryFactory;
end;

procedure TShortCutList.RetrieveShortCuts;
begin
  try
    PopulateShortCuts();
  finally
    FRepositoryFactory := nil;
    FIniFileRepository := nil;
    FRegistryRepository := nil;
  end;
end;

function TShortCutList.XmlFileRepository: IXmlFileRepository;
begin
  if (not Assigned(FXmlFileRepository)) or (not FCacheRepositories) then
    FXmlFileRepository := FRepositoryFactory.XmlFileRepository();
  Result := FXmlFileRepository;
end;

end.

