{
  AEORM © 2026 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit AE.ORM.Entity;

Interface

Uses ZVariant, ZDbcIntFs, AE.ORM.Entity.FieldValueList, AE.ORM.Entity.Common;

Type
  TAEORMEntity = Class(TAEORMCommonEntity)
  strict protected
    Procedure InternalGetChangedFieldValues(Const outChangedFieldValues: TAEORMFieldValueList); Virtual; Abstract;
    Procedure InternalGetPrimaryKeyValues(Const outPrimaryKeyValues: TAEORMFieldValueList); Virtual; Abstract;
    Procedure InternalLoad(Const inFilter: String = ''; Const inParameters: TZVariantDynArray = []; Const inOrderBy: String = ''); Overload; Override;
    Procedure InternalSave; Override;
    Function GetInsertStatement(Const inConnection: IZConnection): IZPreparedStatement;
    Function GetUpdateStatement(Const inConnection: IZConnection): IZPreparedStatement;
  public
    Class Function TableName: String; Virtual; Abstract;
    Class Function SelectFieldNames: String; Virtual; Abstract;
  End;

Implementation

Uses AE.ORM.Exceptions, System.SysUtils, ZEncoding, ZConnection;

ResourceString
  EntityNotFound = 'Entity %s could not be found!';
  MultipleEntitiesFound = 'Multiple %s entities were found!';
  EntitySaveError = 'Error while saving entity %s. %d row(s) were updated instead of one.';

Function TAEORMEntity.GetInsertStatement(Const inConnection: IZConnection): IZPreparedStatement;
Var
  sql, field: String;
  fields: TArray<String>;
  changedfields: TAEORMFieldValueList;
  a: NativeInt;
Begin
  Result := nil;

  changedfields := TAEORMFieldValueList.Create;
  Try
    Self.InternalGetChangedFieldValues(changedfields);

    If changedfields.Count = 0 Then
      Exit;

    fields := changedfields.Keys.ToArray;

    sql := 'INSERT INTO ' + Self.TableName + ' (';

    For field In fields Do
      sql := sql + field + ',';

    sql := sql.Substring(0, sql.Length - 1) + ') VALUES (';

    For a := Low(fields) To High(fields) Do
      sql := sql + '?,';

    sql := sql.Substring(0, sql.Length - 1) + ')';

    Result := inConnection.PrepareStatement(sql);

    a := 0;

    For field In fields Do
    Begin
      Result.SetValue(a, changedfields[field]);

      Inc(a);
    End;
  Finally
    FreeAndNil(changedfields);
  End;
End;

Function TAEORMEntity.GetUpdateStatement(Const inConnection: IZConnection): IZPreparedStatement;
Var
  sql, field: String;
  fields, keys: TArray<String>;
  changedfields, keyfields: TAEORMFieldValueList;
  a: NativeInt;
Begin
  Result := nil;

  changedfields := TAEORMFieldValueList.Create;
  Try
    Self.InternalGetChangedFieldValues(changedfields);

    If changedfields.Count = 0 Then
      Exit;

    fields := changedfields.Keys.ToArray;

    keyfields := TAEORMFieldValueList.Create;
    Try
      Self.InternalGetPrimaryKeyValues(keyfields);

      If keyfields.Count = 0 Then
        Exit;

      keys := keyfields.Keys.ToArray;

      sql := 'UPDATE ' + Self.TableName + ' SET ';

      For field In fields Do
        sql := sql + field + '=?,';

      sql := sql.Substring(0, sql.Length - 1) + ' WHERE ';

      For field In keys Do
        sql := sql + field + '=? AND ';

      sql := sql.Substring(0, sql.Length - 5);

      Result := inConnection.PrepareStatement(sql);

      a := 0;

      For field In fields Do
      Begin
        Result.SetValue(a, changedfields[field]);

        Inc(a);
      End;

      For field In keys Do
      Begin
        Result.SetValue(a, keyfields[field]);

        Inc(a);
      End;
    Finally
      FreeAndNil(keyfields);
    End;
  Finally
    FreeAndNil(changedfields);
  End;
End;

Procedure TAEORMEntity.InternalLoad(Const inFilter: String = ''; Const inParameters: TZVariantDynArray = []; Const inOrderBy: String = '');
Var
  conn: TZConnection;
  statement: IZPreparedStatement;
  resultset: IZResultSet;
  a: NativeInt;
  sql: String;
Begin
  conn := Self.ConnectionPool.WaitAcquireConnection;
  Try
    sql := 'SELECT ' + Self.SelectFieldNames + ' FROM ' + Self.TableName;

    If Not inFilter.IsEmpty Then
      sql := sql + ' WHERE ' + inFilter;

    If Not inOrderBy.IsEmpty Then
      sql := sql + ' ORDER BY ' + inOrderBy;

    statement := conn.DbcConnection.PrepareStatement(sql);

    For a := Low(inParameters) To High(inParameters) Do
      statement.SetValue(a, inParameters[a]);

    resultset := statement.ExecuteQueryPrepared;

    If Not resultset.Next Then
      // TODO: Add SQL and parameters to additional information field
      Raise EAEORMEntityException.Create(Format(EntityNotFound, [Self.ClassName]), statement.GetSQL);

    Self.InternalLoad(resultset);

    If resultset.Next Then
      // TODO: Add SQL and parameters to additional information field
      Raise EAEORMEntityException.Create(Format(MultipleEntitiesFound, [Self.ClassName]), statement.GetSQL);
  Finally
    Self.ConnectionPool.ReleaseConnection(conn);
  End;
End;

Procedure TAEORMEntity.InternalSave;
Var
  conn: TZConnection;
  statement: IZPreparedStatement;
  res: NativeInt;
Begin
  conn := Self.ConnectionPool.WaitAcquireConnection;
  Try
    If Self.Loaded Then
      statement := Self.GetUpdateStatement(conn.DbcConnection)
    Else
      statement := Self.GetInsertStatement(conn.DbcConnection);

    If statement = nil Then
      Exit;

    conn.StartTransaction;
    Try
      res := statement.ExecuteUpdatePrepared;

      If res <> 1 Then
        Raise EAEORMEntityException.Create(Format(EntitySaveError, [Self.ClassName, res]), statement.GetSQL);

      conn.Commit;
    Except
      On E:Exception Do
      Begin
        conn.Rollback;

        Raise;
      End;
    End;
  Finally
    Self.ConnectionPool.ReleaseConnection(conn);
  End;
End;

End.
