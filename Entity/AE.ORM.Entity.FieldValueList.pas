{
  AEORM © 2026 by Akos Eigler is licensed under CC BY 4.0.
  To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

  This license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt,
  and build upon the material in any medium or format, even for commercial purposes.
}

Unit AE.ORM.Entity.FieldValueList;

Interface

Uses System.Generics.Collections, ZVariant;

Type
  TAEORMFieldValueList = Class(TDictionary<String, TZVariant>)
  public
    Procedure AddField(Const inFieldName: String; Const inValue: Int64; Const inIsNull: Boolean); Overload;
    Procedure AddField(Const inFieldName: String; Const inValue: UInt64; Const inIsNull: Boolean); Overload;
    Procedure AddField(Const inFieldName: String; Const inValue: TDateTime; Const inIsNull: Boolean); Overload;
    Procedure AddField(Const inFieldName: String; Const inValue: String; Const inIsNull: Boolean); Overload;
    Procedure AddField(Const inFieldName: String; Const inValue: Boolean; Const inIsNull: Boolean; Const inIsNumberField: Boolean = True); Overload;
    Procedure AddField(Const inFieldName: String; Const inValue: Double; Const inIsNull: Boolean); Overload;
    Procedure AddField(Const inFieldName: String; Const inValue: TZVariant); Overload;
  End;

Implementation

Procedure TAEORMFieldValueList.AddField(Const inFieldName: String; Const inValue: TDateTime; Const inIsNull: Boolean);
Begin
  If inIsNull Then
    Self.Add(inFieldName, EncodeNull)
  Else
    Self.Add(inFieldName, EncodeDateTime(inValue));
End;

Procedure TAEORMFieldValueList.AddField(Const inFieldName: String; Const inValue: Int64; Const inIsNull: Boolean);
Begin
  If inIsNull Then
    Self.Add(inFieldName, EncodeNull)
  Else
    Self.Add(inFieldName, EncodeInteger(inValue));
End;

Procedure TAEORMFieldValueList.AddField(Const inFieldName: String; Const inValue: UInt64; Const inIsNull: Boolean);
Begin
  If inIsNull Then
    Self.Add(inFieldName, EncodeNull)
  Else
    Self.Add(inFieldName, EncodeUInteger(inValue));
End;

Procedure TAEORMFieldValueList.AddField(Const inFieldName: String; Const inValue: Double; Const inIsNull: Boolean);
Begin
  If inIsNull Then
    Self.Add(inFieldName, EncodeNull)
  Else
    Self.Add(inFieldName, EncodeDouble(inValue));
End;

Procedure TAEORMFieldValueList.AddField(Const inFieldName: String; Const inValue: Boolean; Const inIsNull: Boolean; Const inIsNumberField: Boolean = True);
Begin
  If inIsNull Then
    Self.Add(inFieldName, EncodeNull)
  Else
  If inIsNumberField Then
    If inValue Then
      Self.Add(inFieldName, EncodeInteger(1))
    Else
      Self.Add(inFieldName, EncodeInteger(0))
  Else
    Self.Add(inFieldName, EncodeBoolean(inValue));
End;

Procedure TAEORMFieldValueList.AddField(Const inFieldName, inValue: String; Const inIsNull: Boolean);
Begin
  If inIsNull Then
    Self.Add(inFieldName, EncodeNull)
  Else
    Self.Add(inFieldName, EncodeUnicodeString(inValue));
End;

Procedure TAEORMFieldValueList.AddField(Const inFieldName: String; Const inValue: TZVariant);
Begin
  Self.Add(inFieldName, inValue);
End;

End.
