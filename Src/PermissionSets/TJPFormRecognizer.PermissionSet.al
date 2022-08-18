permissionset 50700 "TJP Form Recognizer"
{
    Assignable = true;
    Caption = 'TJP - Form Recognizer', MaxLength = 30;
    Permissions =
                 tabledata "TJP Azure Container setup" = rmid,
                 tabledata "TJP Form Recognizer Setup" = rmid;
}