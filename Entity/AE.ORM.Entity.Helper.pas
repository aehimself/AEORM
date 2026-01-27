{
  AEORM © 2026 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit AE.ORM.Entity.Helper;

Interface

Uses ZDbcIntFs, AE.ORM.Entity;

Type
  TAEORMEntityHelper = Class Helper For TAEORMEntity
  public
    Class Procedure ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: Integer; Var outIsNull: Boolean); Overload;
    Class Procedure ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: Int64; Var outIsNull: Boolean); Overload;
    Class Procedure ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: UInt64; Var outIsNull: Boolean); Overload;
    Class Procedure ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: TDateTime; Var outIsNull: Boolean); Overload;
    Class Procedure ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: String; Var outIsNull: Boolean); Overload;
    Class Procedure ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: Boolean; Var outIsNull: Boolean; Const inIsNumberField: Boolean = True); Overload;
    Class Procedure ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: Double; Var outIsNull: Boolean); Overload;
  End;

Implementation

Class Procedure TAEORMEntityHelper.ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: String; Var outIsNull: Boolean);
Begin
  outIsNull := inResultSet.IsNull(inFieldIndex);

  If Not outIsNull Then
    outValue := inResultSet.GetString(inFieldIndex);
End;

Class Procedure TAEORMEntityHelper.ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: TDateTime; Var outIsNull: Boolean);
Begin
  outIsNull := inResultSet.IsNull(inFieldIndex);

  If Not outIsNull Then
    outValue := inResultSet.GetDate(inFieldIndex);
End;

Class Procedure TAEORMEntityHelper.ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: Integer; Var outIsNull: Boolean);
Begin
  outIsNull := inResultSet.IsNull(inFieldIndex);

  If Not outIsNull Then
    outValue := inResultSet.GetInt(inFieldIndex);
End;

Class Procedure TAEORMEntityHelper.ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: Int64; Var outIsNull: Boolean);
Begin
  outIsNull := inResultSet.IsNull(inFieldIndex);

  If Not outIsNull Then
    outValue := inResultSet.GetLong(inFieldIndex);
End;

Class Procedure TAEORMEntityHelper.ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: UInt64; Var outIsNull: Boolean);
Begin
  outIsNull := inResultSet.IsNull(inFieldIndex);

  If Not outIsNull Then
    outValue := inResultSet.GetULong(inFieldIndex);
End;

Class Procedure TAEORMEntityHelper.ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: Boolean; Var outIsNull: Boolean; Const inIsNumberField: Boolean = True);
Begin
  outIsNull := inResultSet.IsNull(inFieldIndex);

  If Not outIsNull Then
    If inIsNumberField Then
      outValue := inResultSet.GetInt(inFieldIndex) = 1
    Else
      outValue := inResultSet.GetBoolean(inFieldIndex);
End;

Class Procedure TAEORMEntityHelper.ReadValue(Const inResultSet: IZResultSet; Const inFieldIndex: Integer; Var outValue: Double; Var outIsNull: Boolean);
Begin
  outIsNull := inResultSet.IsNull(inFieldIndex);

  If Not outIsNull Then
    outValue := inResultSet.GetDouble(inFieldIndex);
End;

End.
