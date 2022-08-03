page 70659915 "ALV Cognitive Configuration"
{
    Caption = 'ALV Cognitive Configuration';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ALV Cognitive Configuration";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Endpoint"; "Endpoint")
                {
                    ApplicationArea = All;
                    Caption = 'Endpoint';
                }

                field("Apim_key"; "Apim_key")
                {
                    ApplicationArea = All;
                    Caption = 'Apim_key';
                }

            }
        }
    }
}

