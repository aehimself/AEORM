{
  AEORM © 2026 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit AE.ORM.Exceptions;

Interface

Uses System.SysUtils, ZVariant;

Type
  EAEORMException = Class(Exception)
  strict private
    _additionalinfo: String;
  public
    Constructor Create(Const inMessage: String; Const inAdditionalInformation: String = ''); ReIntroduce;
    Property AdditionalInformation: String Read _additionalinfo;
  End;

  EAEORMDBConnectionPoolException = Class(EAEORMException);

  EAEORMEntityException = Class(EAEORMException);

Implementation

//
// EAEORMException
//

Constructor EAEORMException.Create(Const inMessage: String; Const inAdditionalInformation: String = '');
Begin
  inherited Create(inMessage);

  _additionalinfo := inAdditionalInformation;
End;

End.
