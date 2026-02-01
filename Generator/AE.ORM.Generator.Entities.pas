{
  AEORM © 2026 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit AE.ORM.Generator.Entities;

Interface

Uses AE.Application.Setting, System.JSON, System.Generics.Collections;

Type
  TAEORMEntityBase = Class(TAEApplicationSetting)
  strict private
    _generatedclassname: String;
    _generatedproperyname: String;
    _generatedvariablename: String;
    Procedure SetGeneratedClassName(Const inGeneratedClassName: String);
    Procedure SetGeneratedPropertyName(Const inGeneratedPropertyName: String);
    Procedure SetGeneratedVariableName(Const inGeneratedVariableName: String);
  protected
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function GetAsJSON: TJSONObject; Override;
    Property GeneratedClassName: String Read _generatedclassname Write SetGeneratedClassName;
  public
    Property GeneratedPropertyName: String Read _generatedproperyname Write SetGeneratedPropertyName;
    Property GeneratedVariableName: String Read _generatedvariablename Write SetGeneratedVariableName;
  End;

  TAEORMEntityGeneratorFieldType = (oftString, oftInteger, oftInt64, oftUInt64, oftReal, oftBoolean, oftDateTime);

  TAEORMEntityGeneratorField = Class(TAEORMEntityBase)
  strict private
    _generatedisnullpropertyname: String;
    _generatedisnullvariablename: String;
    _generatedoriginalpropertyname: String;
    _generatedoriginalvariablename: String;
    _getterextracode: String;
    _originalgetterextracode: String;
    _propertytype: TAEORMEntityGeneratorFieldType;
    _readonly: Boolean;
    _required: Boolean;
    _setterextracode: String;
    _variabletype: TAEORMEntityGeneratorFieldType;
    Procedure SetPropertyType(Const inPropertyType: TAEORMEntityGeneratorFieldType);
    Procedure SetGeneratedIsNullPropertyName(Const inGeneratedIsNullPropertyName: String);
    Procedure SetGeneratedIsNullVariableName(Const inGeneratedIsNullVariableName: String);
    Procedure SetGeneratedOriginalPropertyName(Const inGeneratedOriginalPropertyName: String);
    Procedure SetGeneratedOriginalVariableName(Const inGeneratedOriginalVariableName: String);
    Procedure SetGetterExtraCode(Const inGetterExtraCode: String);
    Procedure SetOriginalGetterExtraCode(Const inOriginalGetterExtraCode: String);
    Procedure SetReadOnly(Const inReadOnly: Boolean);
    Procedure SetRequired(Const inRequired: Boolean);
    Procedure SetSetterExtraCode(Const inSetterExtraCode: String);
    Procedure SetVariableType(Const inVariableType: TAEORMEntityGeneratorFieldType);
  strict protected
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    Property GeneratedIsNullPropertyName: String Read _generatedisnullpropertyname Write SetGeneratedIsNullPropertyName;
    Property GeneratedIsNullVariableName: String Read _generatedisnullvariablename Write SetGeneratedIsNullVariableName;
    Property GeneratedOriginalPropertyName: String Read _generatedoriginalpropertyname Write SetGeneratedOriginalPropertyName;
    Property GeneratedOriginalVariableName: String Read _generatedoriginalvariablename Write SetGeneratedOriginalVariableName;
    Property GetterExtraCode: String Read _getterextracode Write SetGetterExtraCode;
    Property OriginalGetterExtraCode: String Read _originalgetterextracode Write SetOriginalGetterExtraCode;
    Property PropertyType: TAEORMEntityGeneratorFieldType Read _propertytype Write SetPropertyType;
    Property ReadOnly: Boolean Read _readonly Write SetReadOnly;
    Property Required: Boolean Read _required Write SetRequired;
    Property SetterExtraCode: String Read _setterextracode Write SetSetterExtraCode;
    Property VariableType: TAEORMEntityGeneratorFieldType Read _variabletype Write SetVariableType;
  End;

  TAEORMEntityGeneratorRelation = Class(TAEORMEntityBase)
  strict private
    _relationname: String;
    _sourcefields: TArray<String>;
    _sourcetablename: String;
    _targetfields: TArray<String>;
    _targettablename: String;
  strict protected
    Procedure InternalClear; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    Procedure AddConnectedFields(Const inSourceFieldName, inTargetFieldName: String);
    Property GeneratedClassName;
    Property SourceTableName: String Read _sourcetablename Write _sourcetablename;
    Property TargetTableName: String Read _targettablename Write _targettablename;
    Property RelationName: String Read _relationname Write _relationname;
    Property SourceFields: TArray<String> Read _sourcefields;
    Property TargetFields: TArray<String> Read _targetfields;
  End;

  TAEORMEntityGeneratorTable = Class(TAEORMEntityBase)
  strict private
    _fields: TObjectDictionary<String, TAEORMEntityGeneratorField>;
    _incomingrelations: TObjectList<TAEORMEntityGeneratorRelation>;
    _outgoingrelations: TObjectList<TAEORMEntityGeneratorRelation>;
    _primarykeys: TList<String>;
    Procedure AddRelation(Const inRelationStore: TObjectList<TAEORMEntityGeneratorRelation>; Const inSourceTableName, inTargetTableName, inRelationName, inSourceFieldName, inTargetFieldName: String);
    Procedure SetField(Const inFieldName: String; Const inField: TAEORMEntityGeneratorField);
    Function GetField(Const inFieldName: String): TAEORMEntityGeneratorField;
    Function GetFields: TArray<String>;
    Function GetIncomingRelations: TArray<TAEORMEntityGeneratorRelation>;
    Function GetOutgoingRelations: TArray<TAEORMEntityGeneratorRelation>;
  strict protected
    Procedure InternalClear; Override;
    Procedure InternalClearChanged; Override;
    Procedure SetAsJSON(Const inJSON: TJSONObject); Override;
    Function InternalGetChanged: Boolean; Override;
    Function GetAsJSON: TJSONObject; Override;
  public
    Constructor Create; Override;
    Destructor Destroy; Override;
    Procedure AddIncomingRelation(Const inSourceTableName, inTargetTableName, inRelationName, inSourceFieldName, inTargetFieldName: String);
    Procedure AddOutgoingRelation(Const inSourceTableName, inTargetTableName, inRelationName, inSourceFieldName, inTargetFieldName: String);
    Function ContainsField(Const inFieldName: String): Boolean;
    Function IncomingRelationField(Const inFieldName: String): Boolean;
    Function OutgoingRelationField(Const inFieldName: String): Boolean;
    Function RelationsExist: Boolean;
    Property Field[Const inFieldName: String]: TAEORMEntityGeneratorField Read GetField Write SetField;
    Property Fields: TArray<String> Read GetFields;
    Property GeneratedClassName;
    Property IncomingRelations: TArray<TAEORMEntityGeneratorRelation> Read GetIncomingRelations;
    Property OutgoingRelations: TArray<TAEORMEntityGeneratorRelation> Read GetOutgoingRelations;
    Property PrimaryKeys: TList<String> Read _primarykeys;
  End;

Implementation

Uses System.SysUtils;

Const
  BASE_GENERATEDCLASSNAME = 'generatedclassname';
  BASE_GENERATEDPROPERTYNAME = 'generatedpropertyname';
  BASE_GENERATEDVARIABLENAME = 'generatedvariablename';

  TABLE_FIELDS = 'fields';
  TABLE_PKEYS = 'primarykeys';
  TABLE_INCOMINGRELATIONS = 'incomingrelations';
  TABLE_OUTGOINGRELATIONS = 'outgoingrelations';

  FIELD_REQUIRED = 'required';
  FIELD_READONLY = 'readonly';
  FIELD_GENERATEDISNULLPROPERTYNAME = 'generatedisnullpropertyname';
  FIELD_GENERATEDISNULLVARIABLENAME = 'generatedisnullvariablename';
  FIELD_GENERATEDORIGINALPROPERTYNAME = 'generatedoriginalpropertyname';
  FIELD_GENERATEDORIGINALVARIABLENAME = 'generatedoriginalvariablename';
  FIELD_GETTEREXTRACODE = 'getterextracode';
  FIELD_ORIGINALGETTEREXTRACODE = 'originalgetterextracode';
  FIELD_PROPERTYTYPE = 'propertytype';
  FIELD_SETTEREXTRACODE = 'setterextracode';
  FIELD_VARIABLETYPE = 'variabletype';

  RELATION_SOURCETABLE = 'sourcetable';
  RELATION_TARGETTABLE = 'targettable';
  RELATION_RELATIONNAME = 'relationname';
  RELATION_SOURCEFIELDS = 'sourcefields';
  RELATION_TARGETFIELDS = 'targetfields';

//
// TAEORMEntityBase
//

Function TAEORMEntityBase.GetAsJSON: TJSONObject;
Begin
  Result := inherited;

  If Not _generatedclassname.IsEmpty Then
    Result.AddPair(BASE_GENERATEDCLASSNAME, _generatedclassname);

  If Not _generatedproperyname.IsEmpty Then
    Result.AddPair(BASE_GENERATEDPROPERTYNAME, _generatedproperyname);

  If Not _generatedvariablename.IsEmpty Then
    Result.AddPair(BASE_GENERATEDVARIABLENAME, _generatedvariablename);
End;

Procedure TAEORMEntityBase.InternalClear;
Begin
  inherited;

  _generatedclassname := '';
  _generatedproperyname := '';
  _generatedvariablename := '';
End;

Procedure TAEORMEntityBase.SetAsJSON(Const inJSON: TJSONObject);
Begin
  inherited;

  If inJSON.GetValue(BASE_GENERATEDCLASSNAME) <> nil Then
    _generatedclassname := inJSON.GetValue(BASE_GENERATEDCLASSNAME).Value;

  If inJSON.GetValue(BASE_GENERATEDPROPERTYNAME) <> nil Then
    _generatedproperyname := inJSON.GetValue(BASE_GENERATEDPROPERTYNAME).Value;

  If inJSON.GetValue(BASE_GENERATEDVARIABLENAME) <> nil Then
    _generatedvariablename := inJSON.GetValue(BASE_GENERATEDVARIABLENAME).Value;
End;

Procedure TAEORMEntityBase.SetGeneratedClassName(Const inGeneratedClassName: String);
Begin
  If _generatedclassname = inGeneratedClassName Then
    Exit;

  _generatedclassname := inGeneratedClassName;

  Self.SetChanged;
End;

Procedure TAEORMEntityBase.SetGeneratedPropertyName(Const inGeneratedPropertyName: String);
Begin
  If _generatedproperyname = inGeneratedPropertyName Then
    Exit;

  _generatedproperyname := inGeneratedPropertyName;

  Self.SetChanged;
End;

Procedure TAEORMEntityBase.SetGeneratedVariableName(Const inGeneratedVariableName: String);
Begin
  If _generatedvariablename = inGeneratedVariableName Then
    Exit;

  _generatedvariablename := inGeneratedVariableName;

  Self.SetChanged;
End;

//
// TAEORMEntityGeneratorField
//

Function TAEORMEntityGeneratorField.GetAsJSON: TJSONObject;
Begin
  Result := inherited;

  If Not _generatedisnullpropertyname.IsEmpty Then
    Result.AddPair(FIELD_GENERATEDISNULLPROPERTYNAME, _generatedisnullpropertyname);

  If Not _generatedisnullvariablename.IsEmpty Then
    Result.AddPair(FIELD_GENERATEDISNULLVARIABLENAME, _generatedisnullvariablename);

  If Not _generatedoriginalpropertyname.IsEmpty Then
    Result.AddPair(FIELD_GENERATEDORIGINALPROPERTYNAME, _generatedoriginalpropertyname);

  If Not _generatedoriginalvariablename.IsEmpty Then
    Result.AddPair(FIELD_GENERATEDORIGINALVARIABLENAME, _generatedoriginalvariablename);

  If Not _getterextracode.IsEmpty Then
    Result.AddPair(FIELD_GETTEREXTRACODE, _getterextracode);

  If Not _originalgetterextracode.IsEmpty Then
    Result.AddPair(FIELD_ORIGINALGETTEREXTRACODE, _originalgetterextracode);

  If _propertytype <> oftString Then
    Result.AddPair(FIELD_PROPERTYTYPE, Integer(_propertytype));

  If _readonly Then
    Result.AddPair(FIELD_READONLY, TJSONBool.Create(_readonly));

  If _required Then
    Result.AddPair(FIELD_REQUIRED, TJSONBool.Create(_required));

  If Not _setterextracode.IsEmpty Then
    Result.AddPair(FIELD_SETTEREXTRACODE, _setterextracode);

  If _variabletype <> oftString Then
    Result.AddPair(FIELD_VARIABLETYPE, Integer(_variabletype));
End;

Procedure TAEORMEntityGeneratorField.InternalClear;
Begin
  inherited;

  _generatedisnullpropertyname := '';
  _generatedisnullvariablename := '';
  _generatedoriginalpropertyname := '';
  _generatedoriginalvariablename := '';
  _getterextracode := '';
  _originalgetterextracode := '';
  _propertytype := oftString;
  _readonly := False;
  _required := False;
  _setterextracode := '';
  _variabletype := oftString;
End;

Procedure TAEORMEntityGeneratorField.SetAsJSON(Const inJSON: TJSONObject);
Begin
  inherited;

  If inJSON.GetValue(FIELD_GENERATEDISNULLPROPERTYNAME) <> nil Then
    _generatedisnullpropertyname := inJSON.GetValue(FIELD_GENERATEDISNULLPROPERTYNAME).Value;

  If inJSON.GetValue(FIELD_GENERATEDISNULLVARIABLENAME) <> nil Then
    _generatedisnullvariablename := inJSON.GetValue(FIELD_GENERATEDISNULLVARIABLENAME).Value;

  If inJSON.GetValue(FIELD_GENERATEDORIGINALPROPERTYNAME) <> nil Then
    _generatedoriginalpropertyname := inJSON.GetValue(FIELD_GENERATEDORIGINALPROPERTYNAME).Value;

  If inJSON.GetValue(FIELD_GENERATEDORIGINALVARIABLENAME) <> nil Then
    _generatedoriginalvariablename := inJSON.GetValue(FIELD_GENERATEDORIGINALVARIABLENAME).Value;

  If inJSON.GetValue(FIELD_GETTEREXTRACODE) <> nil Then
    _getterextracode := inJSON.GetValue(FIELD_GETTEREXTRACODE).Value;

  If inJSON.GetValue(FIELD_ORIGINALGETTEREXTRACODE) <> nil Then
    _originalgetterextracode := InJSON.GetValue(FIELD_ORIGINALGETTEREXTRACODE).Value;

  If inJSON.GetValue(FIELD_PROPERTYTYPE) <> nil Then
    _propertytype := TAEORMEntityGeneratorFieldType(TJSONNumber(inJSON.GetValue(FIELD_PROPERTYTYPE)).AsInt);

  If inJSON.GetValue(FIELD_READONLY) <> nil Then
    _readonly := TJSONBool(inJSON.GetValue(FIELD_READONLY)).AsBoolean;

  If inJSON.GetValue(FIELD_REQUIRED) <> nil Then
    _required := TJSONBool(inJSON.GetValue(FIELD_REQUIRED)).AsBoolean;

  If inJSON.GetValue(FIELD_SETTEREXTRACODE) <> nil Then
    _setterextracode := inJSON.GetValue(FIELD_SETTEREXTRACODE).Value;

  If inJSON.GetValue(FIELD_VARIABLETYPE) <> nil Then
    _variabletype := TAEORMEntityGeneratorFieldType(TJSONNumber(inJSON.GetValue(FIELD_VARIABLETYPE)).AsInt);
End;

Procedure TAEORMEntityGeneratorField.SetPropertyType(Const inPropertyType: TAEORMEntityGeneratorFieldType);
Begin
  If _propertytype = inPropertyType Then
    Exit;

  _propertytype := inPropertyType;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetGeneratedIsNullPropertyName(Const inGeneratedIsNullPropertyName: String);
Begin
  If _generatedisnullpropertyname = inGeneratedIsNullPropertyName Then
    Exit;

  _generatedisnullpropertyname := inGeneratedIsNullPropertyName;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetGeneratedIsNullVariableName(Const inGeneratedIsNullVariableName: String);
Begin
  If _generatedisnullvariablename = inGeneratedIsNullVariableName Then
    Exit;

  _generatedisnullvariablename := inGeneratedIsNullVariableName;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetGeneratedOriginalPropertyName(Const inGeneratedOriginalPropertyName: String);
Begin
  If _generatedoriginalpropertyname = inGeneratedOriginalPropertyName Then
    Exit;

  _generatedoriginalpropertyname := inGeneratedOriginalPropertyName;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetGeneratedOriginalVariableName(Const inGeneratedOriginalVariableName: String);
Begin
  if _generatedoriginalvariablename = inGeneratedOriginalVariableName Then
    Exit;

  _generatedoriginalvariablename := inGeneratedOriginalVariableName;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetGetterExtraCode(Const inGetterExtraCode: String);
Begin
  If _getterextracode = inGetterExtraCode Then
    Exit;

  _getterextracode := inGetterExtraCode;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetOriginalGetterExtraCode(Const inOriginalGetterExtraCode: String);
Begin
  If _originalgetterextracode = inOriginalGetterExtraCode Then
    Exit;

  _originalgetterextracode := inOriginalGetterExtraCode;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetReadOnly(Const inReadOnly: Boolean);
Begin
  If _readonly = inReadOnly Then
    Exit;

  _readonly := inReadOnly;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetRequired(Const inRequired: Boolean);
Begin
  If _required = inRequired Then
    Exit;

  _required := inRequired;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetSetterExtraCode(Const inSetterExtraCode: String);
Begin
  If _setterextracode = inSetterExtraCode Then
    Exit;

  _setterextracode := inSetterExtraCode;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorField.SetVariableType(Const inVariableType: TAEORMEntityGeneratorFieldType);
Begin
  If _variabletype = inVariableType Then
    Exit;

  _variabletype := inVariableType;

  Self.SetChanged;
End;

Procedure TAEORMEntityGeneratorRelation.AddConnectedFields(Const inSourceFieldName, inTargetFieldName: String);
Var
  a: NativeInt;
Begin
  For a := Low(_sourcefields) To High(_sourcefields) Do
    If (_sourcefields[a] = inSourceFieldName) And (_targetfields[a] = inTargetFieldName) Then
      Exit;

  SetLength(_sourcefields, Length(_sourcefields) + 1);
  _sourcefields[High(_sourcefields)] := inSourceFieldName;

  SetLength(_targetfields, Length(_targetfields) + 1);
  _targetfields[High(_targetfields)] := inTargetFieldName;
End;

//
// TAEORMEntityGeneratorRelation
//

Function TAEORMEntityGeneratorRelation.GetAsJSON: TJSONObject;
Var
  jarr: TJSONArray;
  s: String;
Begin
  Result := inherited;

  If Not _relationname.IsEmpty Then
    Result.AddPair(RELATION_RELATIONNAME, _relationname);

  If Length(_sourcefields) > 0 Then
  Begin
    jarr := TJSONArray.Create;
    Try
      For s In _sourcefields Do
        jarr.Add(s);
    Finally
      If jarr.Count = 0 Then
        FreeAndNil(jarr)
      Else
        Result.AddPair(RELATION_SOURCEFIELDS, jarr);
    End;
  End;

  If Not _sourcetablename.IsEmpty Then
    Result.AddPair(RELATION_SOURCETABLE, _sourcetablename);

  If Length(_targetfields) > 0 Then
  Begin
    jarr := TJSONArray.Create;
    Try
      For s In _targetfields Do
        jarr.Add(s);
    Finally
      If jarr.Count = 0 Then
        FreeAndNil(jarr)
      Else
        Result.AddPair(RELATION_TARGETFIELDS, jarr);
    End;
  End;

  If Not _targettablename.IsEmpty Then
    Result.AddPair(RELATION_TARGETTABLE, _targettablename);
End;

Procedure TAEORMEntityGeneratorRelation.InternalClear;
Begin
  inherited;

  SetLength(_sourcefields, 0);
  SetLength(_targetfields, 0);

  _relationname := '';
  _sourcetablename := '';
  _targettablename := '';
End;

Procedure TAEORMEntityGeneratorRelation.SetAsJSON(Const inJSON: TJSONObject);
Var
  jv: TJSONValue;
Begin
  inherited;

  If inJSON.GetValue(RELATION_RELATIONNAME) <> nil Then
    _relationname := inJSON.GetValue(RELATION_RELATIONNAME).Value;

  If inJSON.GetValue(RELATION_SOURCEFIELDS) <> nil Then
    For jv In TJSONArray(inJSON.GetValue(RELATION_SOURCEFIELDS)) Do
      Begin
        SetLength(_sourcefields, Length(_sourcefields) + 1);
        _sourcefields[High(_sourcefields)] := jv.Value;
      End;

  If inJSON.GetValue(RELATION_SOURCETABLE) <> nil Then
    _sourcetablename := inJSON.GetValue(RELATION_SOURCETABLE).Value;

  If inJSON.GetValue(RELATION_TARGETFIELDS) <> nil Then
    For jv In TJSONArray(inJSON.GetValue(RELATION_TARGETFIELDS)) Do
      Begin
        SetLength(_targetfields, Length(_targetfields) + 1);
        _targetfields[High(_targetfields)] := jv.Value;
      End;

  If inJSON.GetValue(RELATION_TARGETTABLE) <> nil Then
    _targettablename := inJSON.GetValue(RELATION_TARGETTABLE).Value;
End;

Procedure TAEORMEntityGeneratorTable.AddIncomingRelation(Const inSourceTableName, inTargetTableName, inRelationName, inSourceFieldName, inTargetFieldName: String);
Begin
  Self.AddRelation(_incomingrelations, inSourceTableName, inTargetTableName, inRelationName, inSourceFieldName, inTargetFieldName);
End;

Procedure TAEORMEntityGeneratorTable.AddOutgoingRelation(Const inSourceTableName, inTargetTableName, inRelationName, inSourceFieldName, inTargetFieldName: String);
Begin
  Self.AddRelation(_outgoingrelations, inSourceTableName, inTargetTableName, inRelationName, inSourceFieldName, inTargetFieldName);
End;

Procedure TAEORMEntityGeneratorTable.AddRelation(Const inRelationStore: TObjectList<TAEORMEntityGeneratorRelation>; Const inSourceTableName, inTargetTableName, inRelationName, inSourceFieldName, inTargetFieldName: String);
Var
  relation: TAEORMEntityGeneratorRelation;
  a: NativeInt;
Begin
  relation := nil;

  For a := 0 To inRelationStore.Count - 1 Do
    If (inRelationStore[a].SourceTableName = inSourceTableName) And (inRelationStore[a].TargetTableName = inTargetTableName) And
       (inRelationStore[a].RelationName = inRelationName) Then
    Begin
      relation := inRelationStore[a];

      Break;
    End;

  If Not Assigned(relation) Then
  Begin
    relation := TAEORMEntityGeneratorRelation.Create;
    relation.SourceTableName := inSourceTableName;
    relation.TargetTableName := inTargetTableName;
    relation.RelationName := inRelationName;

    inRelationStore.Add(relation);
  End;

  relation.AddConnectedFields(inSourceFieldName, inTargetFieldName);
End;

Function TAEORMEntityGeneratorTable.ContainsField(Const inFieldName: String): Boolean;
Begin
  Result := _fields.ContainsKey(inFieldName);
End;

//
// TAEORMEntityGeneratorTable
//

Constructor TAEORMEntityGeneratorTable.Create;
Begin
  inherited;

  _fields := TObjectDictionary<String, TAEORMEntityGeneratorField>.Create([doOwnsValues]);
  _incomingrelations := TObjectList<TAEORMEntityGeneratorRelation>.Create;
  _outgoingrelations := TObjectList<TAEORMEntityGeneratorRelation>.Create;
  _primarykeys := TList<String>.Create;
End;

Destructor TAEORMEntityGeneratorTable.Destroy;
Begin
  FreeAndNil(_fields);
  FreeAndNil(_incomingrelations);
  FreeAndNil(_outgoingrelations);
  FreeAndNil(_primarykeys);

  inherited;
End;

Function TAEORMEntityGeneratorTable.GetAsJSON: TJSONObject;
Var
  json, json2: TJSONObject;
  s: String;
  jarr: TJSONArray;
  relation: TAEORMEntityGeneratorRelation;
Begin
  Result := inherited;

  json := TJSONObject.Create;
  Try
    For s In _fields.Keys Do
    Begin
      json2 := _fields[s].AsJSON;

      If json2.Count = 0 Then
        FreeAndNil(json2)
      Else
        json.AddPair(s, json2);
    End;
  Finally
    Result.AddPair(TABLE_FIELDS, json);
  End;

  If _primarykeys.Count > 0 Then
  Begin
    jarr := TJSONArray.Create;

    For s In _primarykeys Do
      jarr.Add(s);

    Result.AddPair(TABLE_PKEYS, jarr);
  End;

  If _incomingrelations.Count > 0 Then
  Begin
    jarr := TJSONArray.Create;

    For relation In _incomingrelations Do
      jarr.Add(relation.AsJSON);

    Result.AddPair(TABLE_INCOMINGRELATIONS, jarr);
  End;

  If _outgoingrelations.Count > 0 Then
  Begin
    jarr := TJSONArray.Create;

    For relation In _outgoingrelations Do
      jarr.Add(relation.AsJSON);

    Result.AddPair(TABLE_OUTGOINGRELATIONS, jarr);
  End;
End;

Function TAEORMEntityGeneratorTable.GetField(Const inFieldName: String): TAEORMEntityGeneratorField;
Begin
  If Not _fields.ContainsKey(inFieldName) Then
    _fields.Add(inFieldName, TAEORMEntityGeneratorField.Create);

  Result := _fields[inFieldName];
End;

Function TAEORMEntityGeneratorTable.GetFields: TArray<String>;
Begin
  Result := _fields.Keys.ToArray;

  TArray.Sort<String>(Result);
end;

Function TAEORMEntityGeneratorTable.GetIncomingRelations: TArray<TAEORMEntityGeneratorRelation>;
Begin
  Result := _incomingrelations.ToArray;
End;

Function TAEORMEntityGeneratorTable.GetOutgoingRelations: TArray<TAEORMEntityGeneratorRelation>;
Begin
  Result := _outgoingrelations.ToArray;
End;

Procedure TAEORMEntityGeneratorTable.InternalClear;
Begin
  inherited;

  _fields.Clear;
  _incomingrelations.Clear;
  _primarykeys.Clear;
End;

Procedure TAEORMEntityGeneratorTable.InternalClearChanged;
Var
  field: TAEORMEntityGeneratorField;
  relation: TAEORMEntityGeneratorRelation;
Begin
  inherited;

  For field In _fields.Values Do
    field.ClearChanged;

  For relation In _incomingrelations Do
    relation.ClearChanged;
End;

Function TAEORMEntityGeneratorTable.InternalGetChanged: Boolean;
Var
  field: TAEORMEntityGeneratorField;
  relation: TAEORMEntityGeneratorRelation;
Begin
  Result := False;

  For field In _fields.Values Do
    Result := Result Or field.Changed;

  For relation In _incomingrelations Do
    Result := Result Or relation.Changed;
End;

Function TAEORMEntityGeneratorTable.OutgoingRelationField(Const inFieldName: String): Boolean;
Var
  relation: TAEORMEntityGeneratorRelation;
  field: String;
Begin
  Result := False;

  For relation In _outgoingrelations Do
   For field In relation.SourceFields Do
     If field = inFieldName Then
     Begin
       Result := True;

       Break;
     End;
End;

Function TAEORMEntityGeneratorTable.RelationsExist: Boolean;
Begin
  Result := Not _incomingrelations.IsEmpty Or Not _outgoingrelations.IsEmpty;
End;

Function TAEORMEntityGeneratorTable.IncomingRelationField(Const inFieldName: String): Boolean;
Var
  relation: TAEORMEntityGeneratorRelation;
  field: String;
Begin
  Result := False;

  For relation In _incomingrelations Do
   For field In relation.TargetFields Do
     If field = inFieldName Then
     Begin
       Result := True;

       Break;
     End;
End;

Procedure TAEORMEntityGeneratorTable.SetAsJSON(Const inJSON: TJSONObject);
Var
  jp: TJSONPair;
  jv: TJSONValue;
Begin
  inherited;

  If inJSON.GetValue(TABLE_FIELDS) <> nil Then
    For jp in TJSONObject(inJSON.GetValue(TABLE_FIELDS)) Do
      _fields.Add(jp.JsonString.Value, TAEORMEntityGeneratorField.NewFromJSON(jp.JsonValue) As TAEORMEntityGeneratorField);

  If inJSON.GetValue(TABLE_PKEYS) <> nil Then
    For jv In TJSONArray(inJSON.GetValue(TABLE_PKEYS)) Do
      _primarykeys.Add(jv.Value);

  If inJSON.GetValue(TABLE_INCOMINGRELATIONS) <> nil Then
    For jv In TJSONArray(inJSON.GetValue(TABLE_INCOMINGRELATIONS)) Do
      _incomingrelations.Add(TAEORMEntityGeneratorRelation.NewFromJSON(jv) As TAEORMEntityGeneratorRelation);

  If inJSON.GetValue(TABLE_OUTGOINGRELATIONS) <> nil Then
    For jv In TJSONArray(inJSON.GetValue(TABLE_OUTGOINGRELATIONS)) Do
      _outgoingrelations.Add(TAEORMEntityGeneratorRelation.NewFromJSON(jv) As TAEORMEntityGeneratorRelation);
End;

Procedure TAEORMEntityGeneratorTable.SetField(Const inFieldName: String; Const inField: TAEORMEntityGeneratorField);
Begin
  If Assigned(inField) Then
  Begin
    _fields.AddOrSetValue(inFieldName, inField);

    Self.SetChanged;
  End
  Else If _fields.ContainsKey(inFieldName) Then
  Begin
    _fields.Remove(inFieldName);

    Self.SetChanged;
  End;
End;

End.
