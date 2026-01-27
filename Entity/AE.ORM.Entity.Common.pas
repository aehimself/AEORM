{
  AEORM © 2026 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit AE.ORM.Entity.Common;

Interface

Uses AE.ORM.DBConnectionPool, ZVariant, ZDbcIntFs;

Type
  TAEORMCommonEntity = Class
  strict private
    _connpool: TAEORMDBConnectionPool;
    _loaded: Boolean;
  strict protected
    Procedure InternalAfterLoad; Virtual;
    Procedure InternalBeforeSave; Virtual;
    Procedure InternalClear; Virtual;
    Procedure InternalLoad(Const inFilter: String = ''; Const inParameters: TZVariantDynArray = []; Const inOrderBy: String = ''); Overload; Virtual; Abstract;
    Procedure InternalLoad(Const inResultSet: IZResultSet); Overload; Virtual; Abstract;
    Procedure InternalSave; Virtual; Abstract;
    Property ConnectionPool: TAEORMDBConnectionPool Read _connpool;
  public
    Constructor Create(Const inConnectionPool: TAEORMDBConnectionPool); ReIntroduce; Virtual;
    Procedure AfterConstruction; Override;
    Procedure Clear;
    Procedure Load(Const inFilter: String = ''; Const inParameters: TZVariantDynArray = []; Const inOrderBy: String = ''); Overload;
    Procedure Load(Const inResultSet: IZResultSet); Overload;
    Procedure Save;
    Property Loaded: Boolean Read _loaded;
  End;

Implementation

Procedure TAEORMCommonEntity.AfterConstruction;
Begin
  inherited;

  Self.Clear;
End;

Procedure TAEORMCommonEntity.Clear;
Begin
  Self.InternalClear;

  _loaded := False;
End;

Constructor TAEORMCommonEntity.Create(Const inConnectionPool: TAEORMDBConnectionPool);
Begin
  inherited Create;

  _connpool := inConnectionPool;
End;

Procedure TAEORMCommonEntity.InternalAfterLoad;
Begin
  // Dummy
End;

Procedure TAEORMCommonEntity.InternalBeforeSave;
Begin
  // Dummy
End;

Procedure TAEORMCommonEntity.InternalClear;
Begin
  // Dummy
End;

Procedure TAEORMCommonEntity.Load(Const inResultSet: IZResultSet);
Begin
  Self.Clear;

  Self.InternalLoad(inResultSet);

  _loaded := True;

  Self.InternalAfterLoad;
End;

Procedure TAEORMCommonEntity.Load(Const inFilter: String = ''; Const inParameters: TZVariantDynArray = []; Const inOrderBy: String = '');
Begin
  Self.Clear;

  Self.InternalLoad(inFilter, inParameters, inOrderBy);

  _loaded := True;

  Self.InternalAfterLoad;
End;

Procedure TAEORMCommonEntity.Save;
Begin
  Self.InternalBeforeSave;

  Self.InternalSave;

  _loaded := True;
End;

End.
