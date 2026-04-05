# AEORM

AE ORM is a static, generative ORM framework. It uses no iterfaces, no RTTI, no compiler m﻿agic, no assembly; only the good old and battle-tested Pascal code.
Hard to read through, easy to understand.
This is a very first attempt at a poor-mans-ORM. It might not generate objects correctly or straight up produce uncompilable code. It worked on my machine, though.

It comes with a class to generate the Pascal code for your objects and a connection pool to make sure those objects will be able to talk to your RDBMS.

The ORM system is using [Zeos database access components](https://zeoslib.sourceforge.io/), the Generator (it's settings to be precise) is using [AEFramework](https://github.com/aehimself/AEFramework).

DB discovery usage:
```
Var
  conn: TZConnection;
  discovery: TAEORMDBDiscovery;
  settings: TAEORMEntityGeneratorSettings;
Begin
  [...]

  settings := TAEORMEntityGeneratorSettings.Create;
  Try
    discovery := TAEORMDBDiscovery.Create;
    Try
      discovery.SQLConnection := conn;
      discovery.Settings := settings;
      
      // Automatically discover all tables, fields and relations in the database:
      discovery.DiscoverAll;

      // Discover tables, fields or relations only:
      // discovery.DiscoverTables; discovery.DiscoverFields; discovery.DiscoverRelations;
    Finally
      FreeAndNil(discovery);
    End;

    [...]

  Finally
    FreeAndNil(settings);
  End;
```

Generator usage:
```
Var
  gen: TAEORMEntityGenerator;
  settings: TAEORMEntityGeneratorSettings;
Begin
  [...]

  settings := TAEORMEntityGeneratorSettings.Create;
  Try
    // Load by settings.AsString or use TAEORMDBDiscovery to have some values
    // You also can manually define the structure with
    // settings.Table['MyTable'].Field['MyField'].PropertyType := oftInteger;

    gen := TAEORMEntityGenerator.Create;
    Try
      TFile.WriteAllText('.\AE.ORM.CustomEntities.pas', gen.Generate('AE.ORM.CustomEntities'));
    Finally
      FreeAndNil(gen);
    End;
  Finally
    FreeAndNil(settings);
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

#### AE.ORM.Generator.Discovery.pas
TAEORMEntityGenerator is responsible for crawling through a database, discovering and importing tables, their fields and relations to the TAEORMEntityGeneratorSettings structure. If the settings are filled manually or loaded via the .AsString property it's not always needed.

#### Generator\AE.ORM.Generator.Entities.pas
TAEORMEntityBase, TAEORMEntityGeneratorField, TAEORMEntityGeneratorRelation and TAEORMEntityGeneratorTable are all used by the settings of the generator class. They contain the information from which the source
file will be generated, take care of JSON (de)serialization and contain some helper methods to make lookup or data insertation easier.

#### Generator\AE.ORM.Generator.pas
TAEORMEntityGenerator is the brains of the operation. It's role is to create the Pascal source for the tables, fields and relations currently in the provided TAEORMEntityGeneratorSettings structure.

#### Generator\AE.ORM.Generator.Settings.pas
TAEORMEntityGeneratorSettings is the full datastore for the generator object. State can be imported or exported via JSON.
