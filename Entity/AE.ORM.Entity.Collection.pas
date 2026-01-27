{
  AEORM © 2026 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit AE.ORM.Entity.Collection;

Interface

Uses AE.ORM.Entity, AE.ORM.Entity.Common, System.Generics.Collections, AE.ORM.DBConnectionPool, ZVariant, ZDbcIntFs;

ResourceString
  EntityNotFound = 'Entity %s could not be found!';

Type
  TAEORMEntityCollection<T: TAEORMEntity> = Class;

  TAEORMEntityCollectionEnumerator<T: TAEORMEntity> = Class
  strict private
    _index: NativeInt;
    _object: TAEORMEntityCollection<T>;
  public
    Constructor Create(Const inObject: TAEORMEntityCollection<T>);
    Procedure Reset;
    Function GetCurrent: T;
    Function MoveNext: Boolean;
    Property Current: T Read GetCurrent;
  End;

  TAEORMEntityCollection<T: TAEORMEntity> = Class(TAEORMCommonEntity)
  strict private
    _items: TObjectList<T>;
    Function GetCount: NativeInt;
    Function GetItem(Const inIndex: NativeInt): T;
  strict protected
    Procedure InternalClear; Override;
    Procedure InternalLoad(Const inFilter: String = ''; Const inParameters: TZVariantDynArray = []; Const inOrderBy: String = ''); Overload; Override;
    Procedure InternalLoad(Const inResultSet: IZResultSet); Overload; Override;
    Procedure InternalSave; Override;
  public
    Constructor Create(Const inConnectionPool: TAEORMDBConnectionPool); Override;
    Destructor Destroy; Override;
    Function AddNew: T;
    Function GetEnumerator: TAEORMEntityCollectionEnumerator<T>;
    Property Count: NativeInt Read GetCount;
    Property Item[Const inIndex: NativeInt]: T Read GetItem; Default;
  End;

Implementation

Uses System.SysUtils, ZConnection, AE.ORM.Exceptions;

//
// TAEORMEntityCollectionEnumerator<T>
//

Constructor TAEORMEntityCollectionEnumerator<T>.Create(Const inObject: TAEORMEntityCollection<T>);
Begin
  inherited Create;

  _index := -1;
  _object := inObject;
End;

Function TAEORMEntityCollectionEnumerator<T>.GetCurrent: T;
Begin
  Result := _object[_index];
End;

Function TAEORMEntityCollectionEnumerator<T>.MoveNext: Boolean;
Begin
  Result := _index < _object.Count - 1;

  If Result Then
    Inc(_index);
End;

Procedure TAEORMEntityCollectionEnumerator<T>.Reset;
Begin
  _index := -1;
End;

//
// TAEORMEntityCollection<T>
//

Function TAEORMEntityCollection<T>.AddNew: T;
Begin
  Result := T.Create(Self.ConnectionPool);

  _items.Add(Result);
End;

Constructor TAEORMEntityCollection<T>.Create(Const inConnectionPool: TAEORMDBConnectionPool);
Begin
  inherited;

  _items := TObjectList<T>.Create;
End;

Destructor TAEORMEntityCollection<T>.Destroy;
Begin
  FreeAndNil(_items);

  inherited;
End;

Function TAEORMEntityCollection<T>.GetCount: NativeInt;
Begin
  Result := _items.Count;
End;

Function TAEORMEntityCollection<T>.GetEnumerator: TAEORMEntityCollectionEnumerator<T>;
Begin
  Result := TAEORMEntityCollectionEnumerator<T>.Create(Self)
End;

Function TAEORMEntityCollection<T>.GetItem(Const inIndex: NativeInt): T;
Begin
  Result := _items[inIndex];
End;

Procedure TAEORMEntityCollection<T>.InternalClear;
Begin
  inherited;

  _items.Clear;
End;

Procedure TAEORMEntityCollection<T>.InternalLoad(Const inResultSet: IZResultSet);
Var
  entity: T;
Begin
  Repeat
    entity := T.Create(Self.ConnectionPool);
    Try
      entity.Load(inResultSet);

      _items.Add(entity);
    Except
      On E:Exception Do
      Begin
        FreeAndNil(entity);

        Raise;
      End;
    End;
  Until Not inResultSet.Next;
End;

Procedure TAEORMEntityCollection<T>.InternalLoad(Const inFilter: String = ''; Const inParameters: TZVariantDynArray = []; Const inOrderBy: String = '');
Var
  conn: TZConnection;
  statement: IZPreparedStatement;
  resultset: IZResultSet;
  a: NativeInt;
  sql: String;
Begin
  conn := Self.ConnectionPool.WaitAcquireConnection;
  Try
    sql := 'SELECT ' + T.SelectFieldNames + ' FROM ' + T.TableName;

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
  Finally
    Self.ConnectionPool.ReleaseConnection(conn);
  End;
End;

Procedure TAEORMEntityCollection<T>.InternalSave;
Var
  entity: T;
Begin
  inherited;

  For entity In _items Do
    entity.Save;
End;

End.
