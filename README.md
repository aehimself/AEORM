# AEORM

AE ORM is a static, generative ORM framework. It uses no iterfaces, no RTTI, no compiler m﻿agic, no assembly; only the good old and battle-tested Pascal code.
Hard to read through, easy to understand.
This is a very first attempt at a poor-mans-ORM. It might not generate objects correctly or straight up produce uncompilable code. It worked on my machine, though.

It comes with a class to generate the Pascal code for your objects and a connection pool to make sure those objects will be able to talk to your RDBMS.

The ORM system is using [Zeos database access components](https://zeoslib.sourceforge.io/), the Generator (it's settings to be precise) is using [AEFramework](https://github.com/aehimself/AEFramework).

Generator usage:
```
Var
  gen: TAEORMEntityGenerator;
  conn: TZSQLConnection;
Begin
  [...]

  gen := TAEORMEntityGenerator.Create;
  Try
    gen.Settings.LowerCaseVariables := True;
    gen.Settings.GlobalVariablePrefix := '_';
    gen.SQLConnection := conn;
    gen.Connect;

//    Automatically discover all tables, fields and relations in the database:
//    gen.DiscoverAll;

//    Discover only tables:
//    gen.DiscoverTables;

//    Add tables, fields, relations, change their generated names:
//    gen.Settings.Table['mytable1'].GeneratedClassName := 'TMyTable1';
//    gen.Settings.Table['mytable1'].Field['MyField'].Required := False;

//    Discover all fields and relations for tables in the settings:
//    gen.DiscoverFields;
//    gen.DiscoverRelations;

    // Load back previously saved settings
    gen.Settings.AsString := TFile.ReadAllText('.\gensettings.json');

    TFile.WriteAllText('.\AE.ORM.CustomEntities.pas', gen.Generate('AE.ORM.CustomEntities'));

    // Save discovered things, names and properties
    TFile.WriteAllText('.\gensettings.json', gen.Settings.AsString);

    gen.Disconnect;
  Finally
    FreeAndNil(gen);
  End;
```

Ad-hoc entity collection:
```
Var
  table: TMyTable1;
  collection: TAEORMEntityCollection<TMyTable1>;
Begin
  collection := TAEORMEntityCollection<TMyTable1>.Create(connpool);
  Try
    collection.Load('1=1');

    For table In collection Do
      // Do something...
  Finally
    FreeAndNil(collection);
  End;
End;
```

Single entity:
```
Var
  table: TMyTable1;
Begin
  table := TMyTable1.Create;
  Try
    table.LoadByID(999); // Might need multiple parameters with different types depending on the primary ID
    table.MyField := 'Hello, world!';
    table.Save;
  Finally
    FreeAndNil(table);
  End;
End;
```

#### AE.ORM.DBConnectionPool.pas
Contains TAEORMDBConnectionPool, which just collects and hands out TZConnection objects to anyone who asks for one. These connections are always active and can be used with no delay after acquiring one.

#### AE.ORM.Exceptions.pas
Contains EAEORMException, EAEORMDBConnectionPoolException and EAEORMEntityException.

## Entity folder
Normally you won't need to touch anything in here. These files are the skeletons of the ORM objects the generator will generate.

#### Entity\AE.ORM.Entity.Collection.pas
This file implements TAEORMEntityCollection<T: TAEORMEntity> and it's TAEORMEntityCollectionEnumerator enumerator class. An entity collection is a collection of entities (who would have thought, right?)
which can be ad-hoc or a one-to-more relation.

#### Entity\AE.ORM.Entity.Common.pas
TAEORMCommonEntity is the base which is used by entity and entity collection objects alike.

#### Entity\AE.ORM.Entity.FieldValueList.pas
TAEORMFieldValueList is a helper object, created only to extend a TDictionary<String, TZVariant> with encoding a simple type to a TZVariant.
It is being used by generated entities to collect primary key and modified field names and their values.

#### Entity\AE.ORM.Entity.Helper.pas
TAEORMEntityHelper does basically the opposite of TAEORMFieldValueList. It reads out a specific value from a resultset to a simple type. Used by generated entities.

#### Entity\AE.ORM.Entity
TAEORMEntity is the skeleton of a single ORM object, a record in the database.

## Generator folder
This folder contains the classes needed to generate the ORM objects based on your input or discovery.

#### Generator\AE.ORM.Generator.Entities.pas
TAEORMEntityBase, TAEORMEntityGeneratorField, TAEORMEntityGeneratorRelation and TAEORMEntityGeneratorTable are all used by the settings of the generator class. They contain the information from which the source
file will be generated, take care of JSON (de)serialization and contain some helper methods to make lookup or data insertation easier.

#### Generator\AE.ORM.Generator.pas
TAEORMEntityGenerator is the brains of the operation. It's main role is to create the Pascal source for the tables, fields and relations currently in it's settings. As an extra, with a database connection it is
capable of discovering all these for you.

#### Generator\AE.ORM.Generator.Settings.pas
TAEORMEntityGeneratorSettings is the full datastore for the generator object. State can be imported or exported via JSON.
