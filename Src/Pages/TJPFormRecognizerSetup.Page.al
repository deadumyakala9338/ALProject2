page 50701 "TJP Form Recognizer Setup"
{
    Caption = 'TJP - Form Recognizer Setup';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TJP Form Recognizer Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint"; Rec."Endpoint")
                {
                    ApplicationArea = All;
                    Caption = 'Endpoint';
                }

                field("Apim_key"; Rec."Apim_key")
                {
                    ApplicationArea = All;
                    Caption = 'Apim_key';
                }

            }
        }
    }
}

