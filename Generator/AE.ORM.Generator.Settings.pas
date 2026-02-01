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
    _implementationunits: TList<String>;
    _interfaceunits: TList<String>;
    _lowercasevars: Boolean;
    _tables: TObjectDictionary<String, TAEORMEntityGeneratorTable>;
    Procedure SetAsString(Const inJSONString: String);
    Procedure SetGlobalVariablePrefix(Const inGlobalVariablePrefix: String);
    Procedure SetLowerCaseVariables(Const inLowerCaseVariables: Boolean);
    Procedure SetTable(Const inTableName: String; Const inTable: TAEORMEntityGeneratorTable);
    Function GetAsString: String;
    Function GetImplementationUnits: TArray<String>;
    Function GetInterfaceUnits: TArray<String>;
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
    Procedure AddImplementationUnit(Const inImplementationUnit: String);
    Procedure RemoveImplementationUnit(Const inImplementationUnit: String);
    Function ContainsTable(Const inTableName: String): Boolean;
    Property AsString: String Read GetAsString Write SetAsString;
    Property GlobalVariablePrefix: String Read _globalvarprefix Write SetGlobalVariablePrefix;
    Property ImplementationUnits: TArray<String> Read GetImplementationUnits;
    Property InterfaceUnits: TArray<String> Read GetInterfaceUnits;
    Property LowerCaseVariables: Boolean Read _lowercasevars Write SetLowerCaseVariables;
    Property Table[Const inTableName: String]: TAEORMEntityGeneratorTable Read GetTable Write SetTable;
    Property Tables: TArray<String> Read GetTables;
  End;

Implementation

Uses System.SysUtils;

Const
  GENSET_TABLES = 'tables';
  GENSET_PREFIX = 'globalvariableprefix';
  GENSET_IMPLEMENTATIONUNITS = 'implementationunits';
  GENSET_INTERFACEUNITS = 'interfaceunits';
  GENSET_LOWERCASEVARS = 'lowercasevars';

//
// TAEORMEntityGeneratorSettings
//

Procedure TAEORMEntityGeneratorSettings.AddImplementationUnit(Const inImplementationUnit: String);
Begin
  If _implementationunits.Contains(inImplementationUnit) Then
    Exit;

  _implementationunits.Add(inImplementationUnit);

  Self.SetChanged;
End;

Function TAEORMEntityGeneratorSettings.ContainsTable(Const inTableName: String): Boolean;
Begin
  Result := _tables.ContainsKey(inTableName);
End;

Constructor TAEORMEntityGeneratorSettings.Create;
Begin
  inherited;

  _implementationunits := TList<String>.Create;
  _interfaceunits := TList<String>.Create;
  _tables := TObjectDictionary<String, TAEORMEntityGeneratorTable>.Create([doOwnsValues]);
End;

Destructor TAEORMEntityGeneratorSettings.Destroy;
Begin
  FreeAndNil(_implementationunits);
  FreeAndNil(_interfaceunits);
  FreeAndNil(_tables);

  inherited;
End;

Function TAEORMEntityGeneratorSettings.GetAsJSON: TJSONObject;
Var
  json, tablejson: TJSONObject;
  jarr: TJSONArray;
  s: String;
Begin
  Result := inherited;

  If _implementationunits.Count > 0 Then
  Begin
    jarr := TJSONArray.Create;
    Try
      For s In _implementationunits Do
        jarr.Add(s);
    Finally
      If jarr.Count = 0 Then
        FreeAndNil(jarr)
      Else
        Result.AddPair(GENSET_IMPLEMENTATIONUNITS, jarr);
    End;
  End;

  If _interfaceunits.Count > 0 Then
  Begin
    jarr := TJSONArray.Create;
    Try
      For s In _interfaceunits Do
        jarr.Add(s);
    Finally
      If jarr.Count = 0 Then
        FreeAndNil(jarr)
      Else
        Result.AddPair(GENSET_INTERFACEUNITS, jarr);
    End;
  End;

  If _tables.Count > 0 Then
  Begin
    json := TJSONObject.Create;

    Try
      For s In _tables.Keys Do
      Begin
        tablejson := _tables[s].AsJSON;

        If tablejson.Count > 0 Then
          json.AddPair(s, tablejson)
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

Function TAEORMEntityGeneratorSettings.GetImplementationUnits: TArray<String>;
Begin
  Result := _implementationunits.ToArray;

  TArray.Sort<String>(Result);
End;

Function TAEORMEntityGeneratorSettings.GetInterfaceUnits: TArray<String>;
Begin
  Result := _interfaceunits.ToArray;

  TArray.Sort<String>(Result);
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

  _implementationunits.Clear;
  _interfaceunits.Clear;
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

Procedure TAEORMEntityGeneratorSettings.RemoveImplementationUnit(Const inImplementationUnit: String);
Begin
  _implementationunits.Remove(inImplementationUnit);

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorSettings.SetAsJSON(Const inJSON: TJSONObject);
Var
  jp: TJSONPair;
  jv: TJSONValue;
Begin
  inherited;

  If inJSON.GetValue(GENSET_IMPLEMENTATIONUNITS) <> nil Then
    For jv In TJSONArray(inJSON.GetValue(GENSET_IMPLEMENTATIONUNITS)) Do
      _implementationunits.Add(jv.Value);

  If inJSON.GetValue(GENSET_INTERFACEUNITS) <> nil Then
    For jv In TJSONArray(inJSON.GetValue(GENSET_INTERFACEUNITS)) Do
      _interfaceunits.Add(jv.Value);

  If inJSON.GetValue(GENSET_TABLES) <> nil Then
    For jp In TJSONObject(inJSON.GetValue(GENSET_TABLES)) Do
      _tables.Add(jp.JsonString.Value, TAEORMEntityGeneratorTable.NewFromJSON(jp.JsonValue) As TAEORMEntityGeneratorTable);

  If inJSON.GetValue(GENSET_LOWERCASEVARS) <> nil Then
    _lowercasevars := TJSONBool(inJSON.GetValue(GENSET_LOWERCASEVARS)).AsBoolean;

  If inJSON.GetValue(GENSET_PREFIX) <> nil Then
    _globalvarprefix := inJSON.GetValue(GENSET_PREFIX).Value;
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
