Unit AE.ORM.Generator.Discovery;

Interface

Uses AE.ORM.Generator.Settings, ZConnection, AE.ORM.Generator.LogEvents;

Type
  TAEORMDBDiscovery = Class
  strict private
    _logevent: TAEORMEntityGeneratorLogEvent;
    _settings: TAEORMEntityGeneratorSettings;
    _sqlconnection: TZConnection;
    Procedure Log(Const inLogAction: TAEORMEntityGeneratorLogAction; Const inTableName, inFieldName, inRelationName: String);
    Function Connect: Boolean;
  public
    Constructor Create; ReIntroduce;
    Procedure DiscoverAll;
    Procedure DiscoverFields;
    Procedure DiscoverRelations;
    Procedure DiscoverTables;
    Property LogEvent: TAEORMEntityGeneratorLogEvent Read _logevent Write _logevent;
    Property Settings: TAEORMEntityGeneratorSettings Read _settings Write _settings;
    Property SQLConnection: TZConnection Read _sqlconnection Write _sqlconnection;
  End;

Implementation

Uses ZDbcIntFs, AE.ORM.Generator.Entities, System.SysUtils;

Function TAEORMDBDiscovery.Connect: Boolean;
Begin
  Result := Not _sqlconnection.Connected;

  If Not Result Then
    Exit;

  _sqlconnection.Connect;
End;

Constructor TAEORMDBDiscovery.Create;
Begin
  inherited;

  _logevent := nil;
  _settings := nil;
  _sqlconnection := nil;
End;

Procedure TAEORMDBDiscovery.DiscoverAll;
Var
  disconnectneeded: Boolean;
Begin
  disconnectneeded := Self.Connect;
  Try
    Self.DiscoverTables;
    Self.DiscoverFields;
    Self.DiscoverRelations;
  Finally
    If disconnectneeded Then
      _sqlconnection.Disconnect;
  End;
End;

Procedure TAEORMDBDiscovery.DiscoverFields;
Var
  disconnectneeded: Boolean;
  table, fname: String;
  metadata: IZDatabaseMetadata;
  resultset: IZResultSet;
  field: TAEORMEntityGeneratorField;
  ftype: TAEORMEntityGeneratorFieldType;
Begin
  disconnectneeded := Self.Connect;
  Try
    metadata := _sqlconnection.DbcConnection.GetMetadata;

    For table In _settings.Tables Do
    Begin
      // Catalog = Self.SQLConnection.Database
      // Schema = Self.SQLConnection.Catalog
      resultset := metadata.GetColumns(_sqlconnection.Database, _sqlconnection.Catalog, table, '');

      While resultset.Next Do
      Begin
        fname := resultset.GetString(3); // COLUMN_NAME

        Case TZSQLType(resultset.GetInt(4)) Of // DATA_TYPE
          stString, stUnicodeString:
            ftype := oftString;
          stBoolean:
            ftype := oftBoolean;
          stByte, stShort, stWord, stSmall, stInteger:
            ftype := oftInteger;
          stLongWord, stLong:
            ftype := oftInt64;
          stULong:
            ftype := oftUInt64;
          stFloat, stDouble, stCurrency, stBigDecimal:
            ftype := oftReal;
          stDate, stTime, stTimestamp:
            ftype := oftDateTime;
          Else
          Begin
            // Data type is unsupported, remove the field from detected ones
            _settings.Table[table].Field[fname] := nil;

            Continue;
          End;
        End;

        field := _settings.Table[table].Field[fname];

        field.ReadOnly := resultset.GetBoolean(23); // READONLY
        field.Required := resultset.GetBoolean(10); // NULLABLE
        field.PropertyType := ftype;
        field.VariableType := ftype;

        Log(eglaFieldDiscovered, table, fname, '');
      End;

      resultset := metadata.GetPrimaryKeys(_sqlconnection.Database, _sqlconnection.Catalog, table);

      While resultset.Next Do
      Begin
        _settings.Table[table].Field[resultset.GetString(3)].PrimaryKey := True; // COLUMN_NAME

        Log(eglaPrimaryKeyDiscovered, table, resultset.GetString(3), '');
      End;
    End;
  Finally
    If disconnectneeded Then
      _sqlconnection.Disconnect;
  End;
End;

Procedure TAEORMDBDiscovery.DiscoverRelations;
Var
  disconnectneeded: Boolean;
  tableenum, sourcefield, targetfield, fieldenum: String;
  table: TAEORMEntityGeneratorTable;
  metadata: IZDatabaseMetadata;
  resultset: IZResultSet;
Begin
  disconnectneeded := Self.Connect;
  Try
    metadata := _sqlconnection.DbcConnection.GetMetadata;

    For tableenum In _settings.Tables Do
    Begin
      table := _settings.Table[tableenum];

      resultset := metadata.GetImportedKeys(_sqlconnection.Database, _sqlconnection.Catalog, tableenum);

      While resultset.Next Do
        // We are only interested in relations where the connected table is also in our discovery
        If _settings.ContainsTable(resultset.GetString(2)) Then // PKTABLE_NAME
        Begin
          sourcefield := resultset.GetString(3); // PKCOLUMN_NAME
          targetfield := resultset.GetString(7); // FKCOLUMN_NAME

          If Not table.ContainsField(targetfield) Then
          Begin
            targetfield := '';

            For fieldenum In table.Fields Do
              If fieldenum.ToLower = resultset.GetString(7) Then
              Begin
                targetfield := fieldenum;

                Break;
              End;

            If targetfield.IsEmpty Then
              Continue;
          End;

          If Not _settings.Table[resultset.GetString(2)].ContainsField(sourcefield) Then
          Begin
            sourcefield := '';

            For fieldenum In _settings.Table[resultset.GetString(2)].Fields Do
              If fieldenum.ToLower = resultset.GetString(3).ToLower Then
              Begin
                sourcefield := fieldenum;

                Break;
              End;

            If sourcefield.IsEmpty Then
              Continue;
          End;

          _settings.AddRelation(
            resultset.GetString(11), // inRelationName, FK_NAME
            resultset.GetString(2), // inSourceTableName, PKTABLE_NAME
            sourcefield, // inSourceFieldName
            resultset.GetString(6), // inTargetTableName, FKTABLE_NAME
            targetfield // inTargetFieldName
          );

          Log(eglaRelationDiscovered, '', '', resultset.GetString(11)); // FK_NAME
        End;

      resultset := metadata.GetExportedKeys(_sqlconnection.Database, _sqlconnection.Catalog, tableenum);

      While resultset.Next Do
        // We are only interested in relations where the connected table is also in our discovery
        If _settings.ContainsTable(resultset.GetString(6)) Then // FKTABLE_NAME
        Begin
          sourcefield := resultset.GetString(3); // PKCOLUMN_NAME
          targetfield := resultset.GetString(7); // FKCOLUMN_NAME

          If Not table.ContainsField(sourcefield) Then
          Begin
            sourcefield := '';

            For fieldenum In table.Fields Do
              If fieldenum.ToLower = resultset.GetString(3).ToLower Then
              Begin
                sourcefield := fieldenum;

                Break;
              End;

            If sourcefield.IsEmpty Then
              Continue;
          End;

          If Not _settings.Table[resultset.GetString(2)].ContainsField(targetfield) Then
          Begin
            targetfield := '';

            For fieldenum In _settings.Table[resultset.GetString(2)].Fields Do
              If fieldenum.ToLower = resultset.GetString(7).ToLower Then
              Begin
                targetfield := fieldenum;

                Break;
              End;

            If targetfield.IsEmpty Then
              Continue;
          End;

          _settings.AddRelation(
            resultset.GetString(11), // inRelationName, FK_NAME
            resultset.GetString(2), // inSourceTableName, PKTABLE_NAME
            sourcefield, // inSourceFieldName
            resultset.GetString(6), // inTargetTableName, FKTABLE_NAME
            targetfield // inTargetFieldName
          );

          Log(eglaRelationDiscovered, '', '', resultset.GetString(11)); // FK_NAME
        End;
    End;
  Finally
    If disconnectneeded Then
      _sqlconnection.Disconnect;
  End;
End;

Procedure TAEORMDBDiscovery.DiscoverTables;
Var
  disconnectneeded: Boolean;
  table: String;
  metadata: IZDatabaseMetadata;
  resultset: IZResultSet;
Begin
  disconnectneeded := Self.Connect;
  Try
    metadata := _sqlconnection.DbcConnection.GetMetadata;

    // Catalog = Self.SQLConnection.Database
    // Schema = Self.SQLConnection.Catalog
    resultset := metadata.GetTables(_sqlconnection.Database, _sqlconnection.Catalog, '', []);

    While resultset.Next Do
    Begin
      table := resultset.GetString(2); // TABLE_NAME

      _settings.Table[table];

      Log(eglaTableDiscovered, table, '', '');
    End;
  Finally
    If disconnectneeded Then
      _sqlconnection.Disconnect;
  End;
End;

Procedure TAEORMDBDiscovery.Log(Const inLogAction: TAEORMEntityGeneratorLogAction; Const inTableName, inFieldName, inRelationName: String);
Begin
  If Assigned(_logevent) Then
    _logevent(Self, inLogAction, inTableName, inFieldName, inRelationName);
End;

End.
