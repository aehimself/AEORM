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
    _relations: TObjectDictionary<String, TAEORMEntityGeneratorRelation>;
    _tables: TObjectDictionary<String, TAEORMEntityGeneratorTable>;
    Procedure SetAsString(Const inJSONString: String);
    Procedure SetGlobalVariablePrefix(Const inGlobalVariablePrefix: String);
    Procedure SetLowerCaseVariables(Const inLowerCaseVariables: Boolean);
    Procedure SetRelation(Const inRelationName: String; Const inRelation: TAEORMEntityGeneratorRelation);
    Procedure SetTable(Const inTableName: String; Const inTable: TAEORMEntityGeneratorTable);
    Function GetAsString: String;
    Function GetImplementationUnits: TArray<String>;
    Function GetInterfaceUnits: TArray<String>;
    Function GetRelation(Const inRelationName: String): TAEORMEntityGeneratorRelation;
    Function GetRelations: TArray<String>;
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
    Procedure AddRelation(Const inRelationName, inSourceTableName, inSourceFieldName, inTargetTableName, inTargetFieldName: String);
    Procedure RemoveImplementationUnit(Const inImplementationUnit: String);
    Function AnyRelationField(Const inTableName, inFieldName: String): Boolean;
    Function ContainsTable(Const inTableName: String): Boolean;
    Function EntityCollectionRelations(Const inTableName: String): TArray<String>;
    Function EntityCollectionRelationField(Const inTableName, inFieldName: String): Boolean;
    Function RelationsExistForTable(Const inTableName: String): Boolean;
    Function SingleEntityRelations(Const inTableName: String): TArray<String>;
    Function SingleEntityRelationField(Const inTableName, inFieldName: String): Boolean;
    Function TableHasAnyRelations(Const inTableName: String): Boolean;
    Property AsString: String Read GetAsString Write SetAsString;
    Property GlobalVariablePrefix: String Read _globalvarprefix Write SetGlobalVariablePrefix;
    Property ImplementationUnits: TArray<String> Read GetImplementationUnits;
    Property InterfaceUnits: TArray<String> Read GetInterfaceUnits;
    Property LowerCaseVariables: Boolean Read _lowercasevars Write SetLowerCaseVariables;
    Property Relation[Const inRelationName: String]: TAEORMEntityGeneratorRelation Read GetRelation Write SetRelation;
    Property Relations: TArray<String> Read GetRelations;
    Property Table[Const inTableName: String]: TAEORMEntityGeneratorTable Read GetTable Write SetTable;
    Property Tables: TArray<String> Read GetTables;
  End;

Implementation

Uses System.SysUtils;

Const
  GENSET_TABLES = 'tables';
  GENSET_RELATIONS = 'relations';
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

Procedure TAEORMEntityGeneratorSettings.AddRelation(Const inRelationName, inSourceTableName, inSourceFieldName, inTargetTableName, inTargetFieldName: String);
Var
  relation: TAEORMEntityGeneratorRelation;
Begin
  If Not _relations.ContainsKey(inRelationName) Then
  Begin
    relation := TAEORMEntityGeneratorRelation.Create;

    relation.SourceTableName := inSourceTableName;
    relation.TargetTableName := inTargetTableName;

    _relations.Add(inRelationName, relation);
  End
  Else
    relation := _relations[inRelationName];

  relation.AddConnectedFields(inSourceFieldName, inTargetFieldName);
End;

Function TAEORMEntityGeneratorSettings.AnyRelationField(Const inTableName, inFieldName: String): Boolean;
Begin
  Result := Self.SingleEntityRelationField(inTableName, inFieldName) Or Self.EntityCollectionRelationField(inTableName, inFieldName);
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
  _relations := TObjectDictionary<String, TAEORMEntityGeneratorRelation>.Create([doOwnsValues])
End;

Destructor TAEORMEntityGeneratorSettings.Destroy;
Begin
  FreeAndNil(_implementationunits);
  FreeAndNil(_interfaceunits);
  FreeAndNil(_tables);
  FreeAndNil(_relations);

  inherited;
End;

Function TAEORMEntityGeneratorSettings.GetAsJSON: TJSONObject;
Var
  json, subjson: TJSONObject;
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
        subjson := _tables[s].AsJSON;

        If subjson.Count > 0 Then
          json.AddPair(s, subjson)
        Else
          FreeAndNil(subjson);
      End;
    Finally
      If json.Count = 0 Then
        FreeAndNil(json)
      Else
        Result.AddPair(GENSET_TABLES, json);
    End;
  End;

  If _relations.Count > 0 Then
  Begin
    json := TJSONObject.Create;
    Try
      For s In _relations.Keys Do
      Begin
        subjson := _relations[s].AsJSON;

        If subjson.Count > 0 Then
          json.AddPair(s, subjson)
        Else
          FreeAndNil(subjson);
      End;
    Finally
      If json.Count = 0 Then
        FreeAndNil(json)
      Else
        Result.AddPair(GENSET_RELATIONS, json);
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
    Result := json.ToString;
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

Function TAEORMEntityGeneratorSettings.GetRelation(Const inRelationName: String): TAEORMEntityGeneratorRelation;
Begin
  If Not _relations.ContainsKey(inRelationName) Then
    _relations.Add(inRelationName, TAEORMEntityGeneratorRelation.Create);

  Result := _relations[inRelationName];
End;

Function TAEORMEntityGeneratorSettings.GetRelations: TArray<String>;
Begin
  Result := _relations.Keys.ToArray;

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
  _relations.Clear;
  _tables.Clear;

  _globalvarprefix := 'F';
  _lowercasevars := False;
End;

Procedure TAEORMEntityGeneratorSettings.InternalClearChanged;
Var
  table: TAEORMEntityGeneratorTable;
  relation: TAEORMEntityGeneratorRelation;
Begin
  inherited;

  For table In _tables.Values Do
    table.ClearChanged;

  For relation In _relations.Values Do
    relation.ClearChanged;
End;

Function TAEORMEntityGeneratorSettings.InternalGetChanged: Boolean;
Var
  table: TAEORMEntityGeneratorTable;
  relation: TAEORMEntityGeneratorRelation;
Begin
  Result := False;

  For table In _tables.Values Do
    Result := Result Or table.Changed;

  For relation In _relations.Values Do
    Result := Result Or relation.Changed;
End;

Function TAEORMEntityGeneratorSettings.EntityCollectionRelationField(Const inTableName, inFieldName: String): Boolean;
Var
  relationenum, fieldenum: String;
Begin
  Result := False;

  For relationenum In Self.EntityCollectionRelations(inTableName) Do
    For fieldenum In _relations[relationenum].TargetFields Do
    Begin
      Result := fieldenum = inFieldName;

      If Result Then
        Exit;
    End;
End;

Function TAEORMEntityGeneratorSettings.EntityCollectionRelations(Const inTableName: String): TArray<String>;
Var
  res: TList<String>;
  relation: String;
Begin
  // Pointing in relation = 1-*, primary key is in this table, others are pointing to this one

  res := TList<String>.Create;
  Try
    For relation In _relations.Keys Do
      If _relations[relation].SourceTableName = inTableName Then
        res.Add(relation);

    Result := res.ToArray;
  Finally
    FreeAndNil(res);
  End;
End;

Function TAEORMEntityGeneratorSettings.SingleEntityRelationField(Const inTableName, inFieldName: String): Boolean;
Var
  relationenum, fieldenum: String;
Begin
  Result := False;

  For relationenum In Self.SingleEntityRelations(inTableName) Do
    For fieldenum In _relations[relationenum].SourceTableName Do
    Begin
      Result := fieldenum = inFieldName;

      If Result Then
        Exit;
    End;
End;

Function TAEORMEntityGeneratorSettings.SingleEntityRelations(Const inTableName: String): TArray<String>;
Var
  res: TList<String>;
  relation: String;
Begin
  // Pointing out relation = *-1, primary key is in the other table, this table points to the other one

  res := TList<String>.Create;
  Try
    For relation In _relations.Keys Do
      If _relations[relation].TargetTableName = inTableName Then
        res.Add(relation);

    Result := res.ToArray;
  Finally
    FreeAndNil(res);
  End;
End;

Function TAEORMEntityGeneratorSettings.TableHasAnyRelations(Const inTableName: String): Boolean;
Var
  relation: TAEORMEntityGeneratorRelation;
Begin
  Result := false;

  For relation In _relations.Values Do
  Begin
    Result := (relation.SourceTableName = inTableName) Or (relation.TargetTableName = inTableName);

    If Result Then
      Break;
  End;
End;

Function TAEORMEntityGeneratorSettings.RelationsExistForTable(Const inTableName: String): Boolean;
Var
  relation: TAEORMEntityGeneratorRelation;
Begin
  Result := False;

  For relation In _relations.Values Do
    If (relation.SourceTableName = inTableName) Or (relation.TargetTableName = inTableName) Then
    Begin
      Result := True;

      Break;
    End;
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

  If inJSON.GetValue(GENSET_RELATIONS) <> nil Then
    For jp In TJSONObject(inJSON.GetValue(GENSET_RELATIONS)) Do
      _relations.Add(jp.JsonString.Value, TAEORMEntityGeneratorRelation.NewFromJSON(jp.JsonValue) As TAEORMEntityGeneratorRelation);
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

Procedure TAEORMEntityGeneratorSettings.SetRelation(Const inRelationName: String; Const inRelation: TAEORMEntityGeneratorRelation);
Begin
  If Assigned(inRelation) Then
  Begin
    _relations.AddOrSetValue(inRelationName, inRelation);

    Self.SetChanged;
  End
  Else If _relations.ContainsKey(inRelationName) Then
  Begin
    _relations.Remove(inRelationName);

    Self.SetChanged;
  End;
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
