{
  AEORM © 2026 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit AE.ORM.Generator.Settings;

Interface

Uses AE.Application.Setting, System.JSON, System.Generics.Collections, AE.ORM.Generator.Entities;

Type
  TAEORMEntityGeneratorSettings = Class(TAEApplicationSetting)
  strict private
    _globalvarprefix: String;
    _lowercasevars: Boolean;
    _tables: TObjectDictionary<String, TAEORMEntityGeneratorTable>;
    Procedure SetAsString(Const inJSONString: String);
    Procedure SetGlobalVariablePrefix(Const inGlobalVariablePrefix: String);
    Procedure SetLowerCaseVariables(Const inLowerCaseVariables: Boolean);
    Procedure SetTable(Const inTableName: String; Const inTable: TAEORMEntityGeneratorTable);
    Function GetAsString: String;
    Function GetTable(Const inTableName: String): TAEORMEntityGeneratorTable;
    Function GetTables: TArray<String>;
  strict protected
    Procedure InternalClear; Override;
    Procedure InternalClearChanged; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function InternalGetChanged: Boolean; Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    Constructor Create; Override;
    Destructor Destroy; Override;
    Function ContainsTable(Const inTableName: String): Boolean;
    Property AsString: String Read GetAsString Write SetAsString;
    Property GlobalVariablePrefix: String Read _globalvarprefix Write SetGlobalVariablePrefix;
    Property LowerCaseVariables: Boolean Read _lowercasevars Write SetLowerCaseVariables;
    Property Table[Const inTableName: String]: TAEORMEntityGeneratorTable Read GetTable Write SetTable;
    Property Tables: TArray<String> Read GetTables;
  End;

Implementation

Uses System.SysUtils;

Const
  GENSET_TABLES = 'tables';
  GENSET_PREFIX = 'globalvariableprefix';
  GENSET_LOWERCASEVARS = 'lowercasevars';

//
// TAEORMEntityGeneratorSettings
//

Function TAEORMEntityGeneratorSettings.ContainsTable(Const inTableName: String): Boolean;
Begin
  Result := _tables.ContainsKey(inTableName);
End;

Constructor TAEORMEntityGeneratorSettings.Create;
Begin
  inherited;

  _tables := TObjectDictionary<String, TAEORMEntityGeneratorTable>.Create([doOwnsValues]);
End;

Destructor TAEORMEntityGeneratorSettings.Destroy;
Begin
  FreeAndNil(_tables);

  inherited;
End;

Function TAEORMEntityGeneratorSettings.GetAsJSON: TJSONObject;
Var
  json, tablejson: TJSONObject;
  table: String;
Begin
  Result := inherited;

  If _tables.Count > 0 Then
  Begin
    json := TJSONObject.Create;

    Try
      For table In _tables.Keys Do
      Begin
        tablejson := _tables[table].AsJSON;

        If tablejson.Count > 0 Then
          json.AddPair(table, tablejson)
        Else
          FreeAndNil(tablejson);
      End;
    Finally
      If json.Count = 0 Then
        FreeAndNil(json)
      Else
        Result.AddPair(GENSET_TABLES, json);
    End;
  End;

  If _globalvarprefix <> 'F' Then
    Result.AddPair(GENSET_PREFIX, _globalvarprefix);

  If _lowercasevars Then
    Result.AddPair(GENSET_LOWERCASEVARS, _lowercasevars);
End;

Function TAEORMEntityGeneratorSettings.GetAsString: String;
Var
  json: TJSONObject;
Begin
  json := Self.AsJSON;
  Try
    Result := json.Format;
  Finally
    FreeAndNil(json);
  End;
End;

Function TAEORMEntityGeneratorSettings.GetTable(Const inTableName: String): TAEORMEntityGeneratorTable;
Begin
  If Not _tables.ContainsKey(inTableName) Then
    _tables.Add(inTableName, TAEORMEntityGeneratorTable.Create);

  Result := _tables[inTableName];
End;

Function TAEORMEntityGeneratorSettings.GetTables: TArray<String>;
Begin
  Result := _tables.Keys.ToArray;

  TArray.Sort<String>(Result);
End;

Procedure TAEORMEntityGeneratorSettings.InternalClear;
Begin
  inherited;

  _tables.Clear;

  _globalvarprefix := 'F';
  _lowercasevars := False;
End;

Procedure TAEORMEntityGeneratorSettings.InternalClearChanged;
Var
  table: TAEORMEntityGeneratorTable;
Begin
  inherited;

  For table In _tables.Values Do
    table.ClearChanged;
End;

Function TAEORMEntityGeneratorSettings.InternalGetChanged: Boolean;
Var
  table: TAEORMEntityGeneratorTable;
Begin
  Result := False;

  For table In _tables.Values Do
    Result := Result Or table.Changed;
End;

Procedure TAEORMEntityGeneratorSettings.SetAsJSON(Const inJSON: TJSONObject);
Var
  jp: TJSONPair;
Begin
  inherited;

  If inJSON.GetValue(GENSET_TABLES) <> nil Then
    For jp In TJSONObject(inJSON.GetValue(GENSET_TABLES)) Do
      _tables.Add(jp.JsonString.Value, TAEORMEntityGeneratorTable.NewFromJSON(jp.JsonValue) As TAEORMEntityGeneratorTable);

  If inJSON.GetValue(GENSET_PREFIX) <> nil Then
    _globalvarprefix := inJSON.GetValue(GENSET_PREFIX).Value;

  If inJSON.GetValue(GENSET_LOWERCASEVARS) <> nil Then
    _lowercasevars := TJSONBool(inJSON.GetValue(GENSET_LOWERCASEVARS)).AsBoolean;
End;

Procedure TAEORMEntityGeneratorSettings.SetAsString(Const inJSONString: String);
Var
  json: TJSONObject;
Begin
  json := TJSONObject(TJSONObject.ParseJSONValue(inJSONString, True, True));
  Try
    Self.AsJSON := json;
  Finally
    FreeAndNil(json);
  End;
End;

Procedure TAEORMEntityGeneratorSettings.SetGlobalVariablePrefix(Const inGlobalVariablePrefix: String);
Begin
  If _globalvarprefix = inGlobalVariablePrefix Then
    Exit;

  _globalvarprefix := inGlobalVariablePrefix;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorSettings.SetLowerCaseVariables(Const inLowerCaseVariables: Boolean);
Begin
  If _lowercasevars = inLowerCaseVariables Then
    Exit;

  _lowercasevars := inLowerCaseVariables;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorSettings.SetTable(Const inTableName: String; Const inTable: TAEORMEntityGeneratorTable);
Begin
  If Assigned(inTable) Then
  Begin
    _tables.AddOrSetValue(inTableName, inTable);

    Self.SetChanged;
  End
  Else If _tables.ContainsKey(inTableName) Then
  Begin
    _tables.Remove(inTableName);

    Self.SetChanged;
  End;
End;

End.
