table 50701 "TJP Form Recognizer Setup"
{
    fields
    {
        field(1; "Endpoint"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Apim_key"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Endpoint)
        {
            Clustered = true;
        }
    }

}

