Unit AE.ORM.Generator.LogEvents;

Interface

Type
  TAEORMEntityGeneratorLogAction = ( eglaGeneratingName, eglaTableDiscovered, eglaFieldDiscovered, eglaPrimaryKeyDiscovered,
    eglaRelationDiscovered, eglaGeneratingFileHeader, eglaGeneratingForwardDeclarations, eglaGeneratingInterfaceSection,
    eglaGeneratingImplementation, eglaGeneratingFileFooter );

  TAEORMEntityGeneratorLogEvent = Procedure(Sender: TObject; Const inLogAction: TAEORMEntityGeneratorLogAction; Const
    inTableName, inFieldName, inRelationName: String) Of Object;

Implementation

End.
