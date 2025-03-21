#if not CLEAN21
page 2152 "O365 Country/Region List"
{
    Caption = 'Countries/Regions';
    CardPageID = "O365 Country/Region Card";
    DeleteAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "O365 Country/Region";
    SourceTableTemporary = true;
    ObsoleteReason = 'Microsoft Invoicing has been discontinued.';
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = Invoicing, Basic, Suite;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Invoicing, Basic, Suite;
                    ToolTip = 'Specifies the name.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        if CountryRegion.FindSet() then
            repeat
                Code := CountryRegion.Code;
                Name := CountryRegion.GetNameInCurrentLanguage();
                "VAT Scheme" := CountryRegion."VAT Scheme";
                if Insert() then;
            until CountryRegion.Next() = 0;

        exit(Find(Which));
    end;

    trigger OnOpenPage()
    begin
        DeleteAll();
    end;
}
#endif
