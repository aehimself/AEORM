{
  AEORM © 2026 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit AE.ORM.DBConnectionPool;

Interface

Uses System.Generics.Collections, ZAbstractConnection, System.Classes, ZDbcIntfs, ZConnection;

Type
  TAEORMDBConnectionPool = Class
  strict private
    _acquired: TList<TZConnection>;
    _codepage: String;
    _connected: Boolean;
    _connections: TObjectList<TZConnection>;
    _database: String;
    _hostname: String;
    _librarylocation: String;
    _password: String;
    _pingsupported: Boolean;
    _port: Integer;
    _properties: TStringList;
    _protocol: String;
    _schema: String;
    _transactionisolation: TZTransactIsolationLevel;
    _username: String;
    Procedure OnPropertiesChange(Sender: TObject);
    Procedure SetCodePage(Const inCodePage: String);
    Procedure SetConnected(Const inConnected: Boolean);
    Procedure SetConnectionCount(Const inConnectionCount: NativeInt);
    Procedure SetDatabase(Const inDatabase: String);
    Procedure SetHostName(Const inHostName: String);
    Procedure SetLibraryLocation(Const inLibraryLocation: String);
    Procedure SetPassword(const inPassword: String);
    Procedure SetPort(Const inPort: Integer);
    Procedure SetProtocol(Const inProtocol: String);
    Procedure SetTransactionIsolation(Const inTransactionIsolation: TZTransactIsolationLevel);
    Procedure SetUserName(const inUserName: String);
    Procedure UpdateConnectionSettings;
    Procedure UpdateSingleConnectionSettings(Const inConnection: TZConnection);
    Function GetConnectionCount: NativeInt;
    Function PingConnection(Const inConnection: TZConnection; Const inReconnectIfDead: Boolean): Boolean;
  public
    Constructor Create; ReIntroduce; Virtual;
    Destructor Destroy; Override;
    Procedure PingAll;
    Procedure ReleaseConnection(Const inConnection: TZConnection);
    Function AcquireConnection: TZConnection;
    Function WaitAcquireConnection: TZConnection;
    Property CodePage: String Read _codepage Write SetCodePage;
    Property Connected: Boolean Read _connected Write SetConnected;
    Property ConnectionCount: NativeInt Read GetConnectionCount Write SetConnectionCount;
    Property Database: String Read _database Write SetDatabase;
    Property HostName: String Read _hostname Write SetHostName;
    Property LibraryLocation: String Read _librarylocation Write SetLibraryLocation;
    Property Password: String Read _password Write SetPassword;
    Property Port: Integer Read _port Write SetPort;
    Property Properties: TStringList Read _properties;
    Property Protocol: String Read _protocol Write SetProtocol;
    Property TransactionIsolation: TZTransactIsolationLevel Read _transactionisolation Write SetTransactionIsolation;
    Property UserName: String Read _username Write SetUserName;
  End;

Implementation

Uses AE.ORM.Exceptions, System.SysUtils, ZExceptions;

//
// TAEORMDBConnectionPool
//

Function TAEORMDBConnectionPool.AcquireConnection: TZConnection;
Var
  a: NativeInt;
Begin
  Result := nil;

  TMonitor.Enter(_connections);
  Try
    If _connections.Count = 0 Then
      Raise EAEORMDBConnectionPoolException.Create('Connection pool is empty!');

    For a := 0 To _connections.Count - 1 Do
      If Not _acquired.Contains(_connections[a]) And PingConnection(_connections[a], False) Then
      Begin
        _acquired.Add(_connections[a]);

        Result := _connections[a];

        Break;
      End;
  Finally
    TMonitor.Exit(_connections);
  End;
End;

Constructor TAEORMDBConnectionPool.Create;
Begin
  inherited;

  _acquired := TList<TZConnection>.Create;
  _connections := TObjectList<TZConnection>.Create;
  _properties := TStringList.Create;

  _properties.OnChange := Self.OnPropertiesChange;

  _codepage := '';
  _connected := False;
  _database := '';
  _hostname := '';
  _librarylocation := '';
  _password := '';
  _port := 0;
  _protocol := '';
  _schema := '';
  _username := '';
End;

Destructor TAEORMDBConnectionPool.Destroy;
Begin
  FreeAndNil(_acquired);
  FreeAndNil(_connections);
  FreeAndNil(_properties);

  inherited;
End;

Function TAEORMDBConnectionPool.GetConnectionCount: NativeInt;
Begin
  TMonitor.Enter(_connections);
  Try
    Result := _connections.Count;
  Finally
    TMonitor.Exit(_connections);
  End;
End;

Procedure TAEORMDBConnectionPool.OnPropertiesChange(Sender: TObject);
Begin
  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.PingAll;
Var
  conn: TZConnection;
Begin
  TMonitor.Enter(_connections);
  Try
    For conn In _connections Do
      If Not _acquired.Contains(conn) Then
        PingConnection(conn, True);
  Finally
    TMonitor.Exit(_connections);
  End;
End;

Function TAEORMDBConnectionPool.PingConnection(Const inConnection: TZConnection; Const inReconnectIfDead: Boolean): Boolean;
Begin
  Result := False;

  Try
    If Not _pingsupported Then
    Begin
      inConnection.Rollback;

      Result := True;
    End
    Else
    Begin
      Result := inConnection.Ping;

      If Not Result And inReconnectIfDead Then
      Begin
        inConnection.Reconnect;

        Result := True;
      End;
    End;
  Except
    On E:Exception Do
      If e Is EZUnsupportedException Then
      Begin
        _pingsupported := False;

        inConnection.Rollback;

        Result := True;
      End
      Else
        Raise;
  End;
End;

Procedure TAEORMDBConnectionPool.ReleaseConnection(Const inConnection: TZConnection);
Begin
  TMonitor.Enter(_connections);
  Try
    If Not _connections.Contains(inConnection) Then
      Raise EAEORMDBConnectionPoolException.Create('Connection does not belong to this pool!');

    If Not _acquired.Contains(inConnection) Then
      Raise EAEORMDBConnectionPoolException.Create('Connection is not acquired!');

    _acquired.Remove(inConnection);
  Finally
    TMonitor.Exit(_connections);
  End;
End;

Procedure TAEORMDBConnectionPool.SetCodePage(Const inCodePage: String);
Begin
  If _codepage = inCodePage Then
    Exit;

  _codepage := inCodePage;

  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.SetConnected(Const inConnected: Boolean);
Begin
  If _connected = inConnected Then
    Exit;

  _connected := inConnected;

  Self.UpdateConnectionSettings;

  _pingsupported := True;
End;

Procedure TAEORMDBConnectionPool.SetConnectionCount(Const inConnectionCount: NativeInt);
Var
  conn: TZConnection;
  a: NativeInt;
Begin
  TMonitor.Enter(_connections);
  Try
    If inConnectionCount = _connections.Count Then
      Exit;

    If inConnectionCount > _connections.Count Then
    {$REGION 'Expand connections list'}
      While inConnectionCount > _connections.Count Do
      Begin
        conn := TZConnection.Create(nil);

        _connections.Add(conn);

        UpdateSingleConnectionSettings(conn);
      End
    {$ENDREGION}
    Else
    {$REGION 'Shrink connections list'}
      For a := _connections.Count - 1 DownTo 0 Do
        If Not _acquired.Contains(_connections[a]) Then
        Begin
          _connections.Delete(a);

          If _connections.Count <= inConnectionCount Then
            Break;
        End;
    {$ENDREGION}
  Finally
    TMonitor.Exit(_connections);
  End;
End;

Procedure TAEORMDBConnectionPool.SetDatabase(Const inDatabase: String);
Begin
  If _database = inDatabase Then
    Exit;

  _database := inDatabase;

  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.SetHostName(Const inHostName: String);
Begin
  If _hostname = inHostName Then
    Exit;

  _hostname := inHostName;

  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.SetLibraryLocation(Const inLibraryLocation: String);
Begin
  If _librarylocation = inLibraryLocation Then
    Exit;

  _librarylocation := inLibraryLocation;

  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.SetPassword(Const inPassword: String);
Begin
  If _password = inPassword Then
    Exit;

  _password := inPassword;

  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.SetPort(Const inPort: Integer);
Begin
  If _port = inPort Then
    Exit;

  _port := inPort;

  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.SetProtocol(Const inProtocol: String);
Begin
  If _protocol = inProtocol Then
    Exit;

  _protocol := inProtocol;

  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.SetTransactionIsolation(Const inTransactionIsolation: TZTransactIsolationLevel);
Begin
  If _transactionisolation = inTransactionIsolation Then
    Exit;

  _transactionisolation := inTransactionIsolation;

  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.SetUserName(Const inUserName: String);
Begin
  If _username = inUserName Then
    Exit;

  _username := inUserName;

  Self.UpdateConnectionSettings;
End;

Procedure TAEORMDBConnectionPool.UpdateConnectionSettings;
Var
  conn: TZConnection;
Begin
  TMonitor.Enter(_connections);
  Try
    For conn In _connections Do
      UpdateSingleConnectionSettings(conn);
  Finally
    TMonitor.Exit(_connections);
  End;
End;

Procedure TAEORMDBConnectionPool.UpdateSingleConnectionSettings(Const inConnection: TZConnection);
Begin
  If Not _connections.Contains(inConnection) Then
    Raise EAEORMDBConnectionPoolException.Create('Connection does not belong to this pool!');

  If inConnection.Connected Then
  Begin
    inConnection.AbortOperation;

    inConnection.Disconnect;
  End;

  inConnection.Catalog := _schema;
  inConnection.ClientCodepage := _codepage;
  inConnection.Database := _database;
  inConnection.HostName := _hostname;
  inConnection.Password := _password;
  inConnection.Port := _port;
  inConnection.Properties.Assign(_properties);
  inConnection.Protocol := _protocol;
  inConnection.TransactIsolationLevel := _transactionisolation;
  inConnection.User := _username;
  inConnection.LibraryLocation := _librarylocation;

  If _connected Then
    inConnection.Connect;
End;

Function TAEORMDBConnectionPool.WaitAcquireConnection: TZConnection;
Begin
  Repeat
    Result := Self.AcquireConnection;

    If Not Assigned(Result) Then
      Sleep(1000);
  Until Assigned(Result);
End;

End.
