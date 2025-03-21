page 960 "Time Sheet Archive List"
{
    ApplicationArea = Jobs;
    Caption = 'Time Sheet Archives';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Time Sheet Header Archive";
    SourceTableView = SORTING("Resource No.", "Starting Date") order(descending);
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the start date for the archived time sheet.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the end date for an archived time sheet.';
                }
                field("Resource No."; Rec."Resource No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the list of resource numbers associated with an archived time sheet.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the description for a time sheet.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&View Time Sheet")
            {
                ApplicationArea = Jobs;
                Caption = '&View Time Sheet';
                Image = OpenJournal;
                ShortCutKey = 'Return';
                ToolTip = 'Open the time sheet.';

                trigger OnAction()
                begin
                    ViewTimeSheet();
                end;
            }
        }
        area(navigation)
        {
            group("&Time Sheet")
            {
                Caption = '&Time Sheet';
                Image = Timesheet;
                action(Comments)
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Time Sheet Arc. Comment Sheet";
                    RunPageLink = "No." = FIELD("No."),
                                  "Time Sheet Line No." = CONST(0);
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("&View Time Sheet_Promoted"; "&View Time Sheet")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if UserSetup.Get(UserId) then
            CurrPage.Editable := UserSetup."Time Sheet Admin.";
        TimeSheetMgt.FilterTimeSheetsArchive(Rec, FieldNo("Owner User ID"));
        OnAfterOnOpenPage(Rec);
    end;

    var
        UserSetup: Record "User Setup";
        TimeSheetMgt: Codeunit "Time Sheet Management";

    local procedure ViewTimeSheet()
#if not CLEAN22
    var
        TimeSheetLineArchive: Record "Time Sheet Line Archive";
#endif
    begin
#if not CLEAN22
        if not TimeSheetMgt.TimeSheetV2Enabled() then begin
            TimeSheetMgt.SetTimeSheetArchiveNo("No.", TimeSheetLineArchive);
            Page.Run(Page::"Time Sheet Archive", TimeSheetLineArchive);
            exit;
        end;
#endif
        Page.Run(Page::"Time Sheet Archive Card", Rec)
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterOnOpenPage(var TimeSheetHeaderArchive: Record "Time Sheet Header Archive")
    begin
    end;
}

