page 70659914 "ALV Cognitive ImageFiles"
{
    Caption = 'ALV Cognitive ImageFiles';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ALV Cognitive ImageFiles";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("ImageURL"; "ImageURL")
                {
                    ApplicationArea = All;
                    Caption = 'ImageURL';
                }

                field("CognitiveResult"; "CognitiveResult")
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                }



            }
        }
    }

    actions
    {
        area(Processing)
        {

            action("Process Cognitive")
            {
                Caption = 'Process Cognitive';
                Promoted = true;
                PromotedCategory = Process;
                Image = Process;
                ApplicationArea = All;

                trigger OnAction();
                var
                    fileService: Codeunit "ALV Cognitive Service API";
                begin
                    fileService.GetCognitive(Rec);
                end;
            }


        }

    }
}

