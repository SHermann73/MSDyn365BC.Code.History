page 431 "Reminder Terms"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Reminder Terms';
    PageType = List;
    SourceTable = "Reminder Terms";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code to identify this set of reminder terms.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the reminder terms.';
                }
                field("Max. No. of Reminders"; Rec."Max. No. of Reminders")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum number of reminders that can be created for an invoice.';
                }
                field("Post Interest"; Rec."Post Interest")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether or not any interest listed on the reminder should be posted to the general ledger and customer accounts.';
                }
                field("Post Additional Fee"; Rec."Post Additional Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether or not any additional fee listed on the reminder should be posted to the general ledger and customer accounts.';
                }
                field("Post Add. Fee per Line"; Rec."Post Add. Fee per Line")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether or not any additional fee listed on the finance charge memo should be posted to the general ledger and customer accounts when the memo is issued.';
                }
                field("Minimum Amount (LCY)"; Rec."Minimum Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the minimum amount for which a reminder will be created.';
                }
                field("Note About Line Fee on Report"; Rec."Note About Line Fee on Report")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that any notes about line fees will be added to the reminder.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Levels")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Levels';
                Image = ReminderTerms;
                RunObject = Page "Reminder Levels";
                RunPageLink = "Reminder Terms Code" = FIELD(Code);
                ToolTip = 'View the reminder levels that are used to define when reminders can be created and what charges and texts they must include.';
            }
            action(Translation)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Translation';
                Image = Translation;
                RunObject = Page "Reminder Terms Translation";
                RunPageLink = "Reminder Terms Code" = FIELD(Code);
                ToolTip = 'View the reminder text in any other languages that are set up for reminders.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("&Levels_Promoted"; "&Levels")
                {
                }
            }
        }
    }
}

