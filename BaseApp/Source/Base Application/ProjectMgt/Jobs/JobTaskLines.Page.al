page 1002 "Job Task Lines"
{
    Caption = 'Job Task Lines';
    DataCaptionFields = "Job No.";
    PageType = List;
    SaveValues = true;
    SourceTable = "Job Task";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = DescriptionIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field("Job No."; Rec."Job No.")
                {
                    ApplicationArea = Jobs;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related job.';
                    Visible = false;
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    ApplicationArea = Jobs;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related job task.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Jobs;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies a description of the job task. You can enter anything that is meaningful in describing the task. The description is copied and used in descriptions on the job planning line.';
                }
                field("Job Task Type"; Rec."Job Task Type")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the purpose of the account. Newly created accounts are automatically assigned the Posting account type, but you can change this. Choose the field to select one of the following five options:';
                }
                field(Totaling; Totaling)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies an interval or a list of job task numbers.';
                }
                field("Job Posting Group"; Rec."Job Posting Group")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the job posting group of the task.';
                }
                field("WIP-Total"; Rec."WIP-Total")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the job tasks you want to group together when calculating Work In Process (WIP) and Recognition.';
                }
                field("WIP Method"; Rec."WIP Method")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the name of the Work in Process calculation method that is associated with a job. The value in this field comes from the WIP method specified on the job card.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the start date for the job task. The date is based on the date on the related job planning line.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the end date for the job task. The date is based on the date on the related job planning line.';
                }
                field("Schedule (Total Cost)"; Rec."Schedule (Total Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total budgeted cost for the job task during the time period in the Planning Date Filter field.';
                }
                field("Schedule (Total Price)"; Rec."Schedule (Total Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in local currency, the total budgeted price for the job task during the time period in the Planning Date Filter field.';
                }
                field("Usage (Total Cost)"; Rec."Usage (Total Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in local currency, the total cost of the usage of items, resources and general ledger expenses posted on the job task during the time period in the Posting Date Filter field.';
                }
                field("Usage (Total Price)"; Rec."Usage (Total Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total price of the usage of items, resources and general ledger expenses posted on the job task during the time period in the Posting Date Filter field.';
                }
                field("Contract (Total Cost)"; Rec."Contract (Total Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in local currency, the total billable cost for the job task during the time period in the Planning Date Filter field.';
                }
                field("Contract (Total Price)"; Rec."Contract (Total Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the job task during the time period in the Planning Date Filter field.';
                }
                field("Contract (Invoiced Cost)"; Rec."Contract (Invoiced Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total billable cost for the job task that has been invoiced during the time period in the Posting Date Filter field.';
                }
                field("Contract (Invoiced Price)"; Rec."Contract (Invoiced Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the job task that has been invoiced during the time period in the Posting Date Filter field.';
                }
                field("Remaining (Total Cost)"; Rec."Remaining (Total Cost)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the remaining total cost (LCY) as the sum of costs from job planning lines associated with the job task. The calculation occurs when you have specified that there is a usage link between the job ledger and the job planning lines.';
                }
                field("Remaining (Total Price)"; Rec."Remaining (Total Price)")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the remaining total price (LCY) as the sum of prices from job planning lines associated with the job task. The calculation occurs when you have specified that there is a usage link between the job ledger and the job planning lines.';
                }
                field("EAC (Total Cost)"; CalcEACTotalCost())
                {
                    ApplicationArea = Jobs;
                    Caption = 'EAC (Total Cost)';
                    ToolTip = 'Specifies the estimate at completion (EAC) total cost for a job task line. If the Apply Usage Link check box on the job is selected, then the EAC (Total Cost) field is calculated as follows:  Usage (Total Cost) + Remaining (Total Cost).';
                }
                field("EAC (Total Price)"; CalcEACTotalPrice())
                {
                    ApplicationArea = Jobs;
                    Caption = 'EAC (Total Price)';
                    ToolTip = 'Specifies the estimate at completion (EAC) total price for a job task line. If the Apply Usage Link check box on the job is selected, then the EAC (Total Price) field is calculated as follows: Usage (Total Price) + Remaining (Total Price).';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field("Outstanding Orders"; Rec."Outstanding Orders")
                {
                    ApplicationArea = Jobs;
                    Editable = false;
                    ToolTip = 'Specifies the sum of outstanding orders, in local currency, for this job task. The value of the Outstanding Amount (LCY) field is used for entries in the Purchase Line table of document type Order to calculate and update the contents of this field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                    begin
                        SetPurchLineFilters(PurchLine, "Job No.", "Job Task No.");
                        PurchLine.SetFilter("Outstanding Amt. Ex. VAT (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
                }
                field("Amt. Rcd. Not Invoiced"; Rec."Amt. Rcd. Not Invoiced")
                {
                    ApplicationArea = Jobs;
                    Editable = false;
                    ToolTip = 'Specifies the sum for items that have been received but have not yet been invoiced. The value in the Amt. Rcd. Not Invoiced (LCY) field is used for entries in the Purchase Line table of document type Order to calculate and update the contents of this field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                    begin
                        SetPurchLineFilters(PurchLine, "Job No.", "Job Task No.");
                        PurchLine.SetFilter("Amt. Rcd. Not Invoiced (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
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
        area(navigation)
        {
            group("&Job Task")
            {
                Caption = '&Job Task';
                Image = Task;
                action(JobPlanningLines)
                {
                    ApplicationArea = Jobs;
                    Caption = 'Job &Planning Lines';
                    Image = JobLines;
                    ToolTip = 'View all planning lines for the job. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a job (budget) or you can specify what you actually agreed with your customer that they should pay for the job (billable).';

                    trigger OnAction()
                    var
                        JobPlanningLine: Record "Job Planning Line";
                        JobPlanningLines: Page "Job Planning Lines";
                    begin
                        TestField("Job Task Type", "Job Task Type"::Posting);
                        TestField("Job No.");
                        TestField("Job Task No.");
                        JobPlanningLine.FilterGroup(2);
                        JobPlanningLine.SetRange("Job No.", "Job No.");
                        JobPlanningLine.SetRange("Job Task No.", "Job Task No.");
                        JobPlanningLine.FilterGroup(0);
                        JobPlanningLines.SetJobTaskNoVisible(false);
                        JobPlanningLines.SetTableView(JobPlanningLine);
                        JobPlanningLines.Run();
                    end;
                }
                action(JobTaskStatistics)
                {
                    ApplicationArea = Jobs;
                    Caption = 'Job Task &Statistics';
                    Image = StatisticsDocument;
                    RunObject = Page "Job Task Statistics";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistics for the job task.';
                }
                action("Job &Task Card")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Job &Task Card';
                    Image = Task;
                    RunObject = Page "Job Task Card";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View detailed information about a job task, such as the description of the task and the type, which can be either a heading, a posting, a begin-total, an end-total, or a total.';
                }
                separator("-")
                {
                    Caption = '-';
                }
                group("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    action("Dimensions-&Single")
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Single';
                        Image = Dimensions;
                        RunObject = Page "Job Task Dimensions";
                        RunPageLink = "Job No." = FIELD("Job No."),
                                      "Job Task No." = FIELD("Job Task No.");
                        ShortCutKey = 'Alt+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            JobTask: Record "Job Task";
                            JobTaskDimensionsMultiple: Page "Job Task Dimensions Multiple";
                        begin
                            CurrPage.SetSelectionFilter(JobTask);
                            JobTaskDimensionsMultiple.SetMultiJobTask(JobTask);
                            JobTaskDimensionsMultiple.RunModal();
                        end;
                    }
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action("Sales &Invoices/Credit Memos")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Sales &Invoices/Credit Memos';
                    Image = GetSourceDoc;
                    ToolTip = 'View sales invoices or sales credit memos that are related to the selected job task.';

                    trigger OnAction()
                    var
                        JobInvoices: Page "Job Invoices";
                    begin
                        JobInvoices.SetPrJobTask(Rec);
                        JobInvoices.RunModal();
                    end;
                }
            }
            group("W&IP")
            {
                Caption = 'W&IP';
                Image = WIP;
                action("&WIP Entries")
                {
                    ApplicationArea = Jobs;
                    Caption = '&WIP Entries';
                    Image = WIPEntries;
                    RunObject = Page "Job WIP Entries";
                    RunPageLink = "Job No." = FIELD("Job No.");
                    RunPageView = SORTING("Job No.", "Job Posting Group", "WIP Posting Date");
                    ToolTip = 'View entries for the job that are posted as work in process.';
                }
                action("WIP &G/L Entries")
                {
                    ApplicationArea = Jobs;
                    Caption = 'WIP &G/L Entries';
                    Image = WIPLedger;
                    RunObject = Page "Job WIP G/L Entries";
                    RunPageLink = "Job No." = FIELD("Job No.");
                    RunPageView = SORTING("Job No.");
                    ToolTip = 'View the job''s WIP G/L entries.';
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Job Ledger E&ntries")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Job Ledger E&ntries';
                    Image = JobLedger;
                    RunObject = Page "Job Ledger Entries";
                    RunPageLink = "Job No." = FIELD("Job No."),
                                  "Job Task No." = FIELD("Job Task No.");
                    RunPageView = SORTING("Job No.", "Job Task No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the job ledger entries.';
                }
            }
        }
        area(processing)
        {
            group("New Documents")
            {
                Caption = 'New Documents';
                Image = Invoice;
                action("Create &Sales Invoice")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Create &Sales Invoice';
                    Ellipsis = true;
                    Image = JobSalesInvoice;
                    ToolTip = 'Use a batch job to help you create sales invoices for the involved job tasks.';

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobTask: Record "Job Task";
                    begin
                        TestField("Job No.");
                        Job.Get("Job No.");
                        if Job.Blocked = Job.Blocked::All then
                            Job.TestBlocked();

                        JobTask.SetRange("Job No.", Job."No.");
                        if "Job Task No." <> '' then
                            JobTask.SetRange("Job Task No.", "Job Task No.");

                        REPORT.RunModal(REPORT::"Job Create Sales Invoice", true, false, JobTask);
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Split &Planning Lines")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Split &Planning Lines';
                    Ellipsis = true;
                    Image = Splitlines;
                    ToolTip = 'Split planning lines of type Budget and Billable into two separate planning lines: Budget and Billable.';

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobTask: Record "Job Task";
                    begin
                        TestField("Job No.");
                        Job.Get("Job No.");
                        if Job.Blocked = Job.Blocked::All then
                            Job.TestBlocked();

                        TestField("Job Task No.");
                        JobTask.SetRange("Job No.", Job."No.");
                        JobTask.SetRange("Job Task No.", "Job Task No.");

                        REPORT.RunModal(REPORT::"Job Split Planning Line", true, false, JobTask);
                    end;
                }
                action("Change &Dates")
                {
                    ApplicationArea = Jobs;
                    Caption = 'Change &Dates';
                    Ellipsis = true;
                    Image = ChangeDate;
                    ToolTip = 'Use a batch job to help you move planning lines on a job from one date interval to another.';

                    trigger OnAction()
                    var
                        Job: Record Job;
                        JobTask: Record "Job Task";
                    begin
                        TestField("Job No.");
                        Job.Get("Job No.");
                        if Job.Blocked = Job.Blocked::All then
                            Job.TestBlocked();

                        JobTask.SetRange("Job No.", Job."No.");
                        if "Job Task No." <> '' then
                            JobTask.SetRange("Job Task No.", "Job Task No.");

                        REPORT.RunModal(REPORT::"Change Job Dates", true, false, JobTask);
                    end;
                }
                action("<Action7>")
                {
                    ApplicationArea = Jobs;
                    Caption = 'I&ndent Job Tasks';
                    Image = Indent;
                    RunObject = Codeunit "Job Task-Indent";
                    ToolTip = 'Move the selected lines in one position to show that the tasks are subcategories of other tasks. Job tasks that are totaled are the ones that lie between one pair of corresponding Begin-Total and End-Total job tasks.';
                }
                group("&Copy")
                {
                    Caption = '&Copy';
                    Image = Copy;
                    action("Copy Job Planning Lines &from...")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Copy Job Planning Lines &from...';
                        Ellipsis = true;
                        Image = CopyToTask;
                        ToolTip = 'Use a batch job to help you copy planning lines from one job task to another. You can copy from a job task within the job you are working with or from a job task linked to a different job.';

                        trigger OnAction()
                        var
                            CopyJobPlanningLines: Page "Copy Job Planning Lines";
                        begin
                            TestField("Job Task Type", "Job Task Type"::Posting);
                            CopyJobPlanningLines.SetToJobTask(Rec);
                            CopyJobPlanningLines.RunModal();
                        end;
                    }
                    action("Copy Job Planning Lines &to...")
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Copy Job Planning Lines &to...';
                        Ellipsis = true;
                        Image = CopyFromTask;
                        ToolTip = 'Use a batch job to help you copy planning lines from one job task to another. You can copy from a job task within the job you are working with or from a job task linked to a different job.';

                        trigger OnAction()
                        var
                            CopyJobPlanningLines: Page "Copy Job Planning Lines";
                        begin
                            TestField("Job Task Type", "Job Task Type"::Posting);
                            CopyJobPlanningLines.SetFromJobTask(Rec);
                            CopyJobPlanningLines.RunModal();
                        end;
                    }
                }
                group("<Action13>")
                {
                    Caption = 'W&IP';
                    Image = WIP;
                    action("<Action48>")
                    {
                        ApplicationArea = Jobs;
                        Caption = '&Calculate WIP';
                        Ellipsis = true;
                        Image = CalculateWIP;
                        ToolTip = 'Run the Job Calculate WIP batch job.';

                        trigger OnAction()
                        var
                            Job: Record Job;
                        begin
                            TestField("Job No.");
                            Job.Get("Job No.");
                            Job.SetRange("No.", Job."No.");
                            REPORT.RunModal(REPORT::"Job Calculate WIP", true, false, Job);
                        end;
                    }
                    action("<Action49>")
                    {
                        ApplicationArea = Jobs;
                        Caption = '&Post WIP to G/L';
                        Ellipsis = true;
                        Image = PostOrder;
                        ShortCutKey = 'F9';
                        ToolTip = 'Run the Job Post WIP to G/L batch job.';

                        trigger OnAction()
                        var
                            Job: Record Job;
                        begin
                            TestField("Job No.");
                            Job.Get("Job No.");
                            Job.SetRange("No.", Job."No.");
                            REPORT.RunModal(REPORT::"Job Post WIP to G/L", true, false, Job);
                        end;
                    }
                }
            }
        }
        area(reporting)
        {
            action("Job Actual to Budget")
            {
                ApplicationArea = Jobs;
                Caption = 'Job Actual to Budget';
                Image = "Report";
                RunObject = Report "Job Actual To Budget";
                ToolTip = 'Compare budgeted and usage amounts for selected jobs. All lines of the selected job show quantity, total cost, and line amount.';
            }
            action("Job Analysis")
            {
                ApplicationArea = Jobs;
                Caption = 'Job Analysis';
                Image = "Report";
                RunObject = Report "Job Analysis";
                ToolTip = 'Analyze the job, such as the budgeted prices, usage prices, and billable prices, and then compares the three sets of prices.';
            }
            action("Job - Planning Lines")
            {
                ApplicationArea = Jobs;
                Caption = 'Job - Planning Lines';
                Image = "Report";
                RunObject = Report "Job - Planning Lines";
                ToolTip = 'View all planning lines for the job. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a job (budget) or you can specify what you actually agreed with your customer that he should pay for the job (billable).';
            }
            action("Job - Suggested Billing")
            {
                ApplicationArea = Jobs;
                Caption = 'Job - Suggested Billing';
                Image = "Report";
                RunObject = Report "Job Suggested Billing";
                ToolTip = 'View a list of all jobs, grouped by customer, how much the customer has already been invoiced, and how much remains to be invoiced, that is, the suggested billing.';
            }
            action("Jobs - Transaction Detail")
            {
                ApplicationArea = Jobs;
                Caption = 'Jobs - Transaction Detail';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Job - Transaction Detail";
                ToolTip = 'View all postings with entries for a selected job for a selected period, which have been charged to a certain job. At the end of each job list, the amounts are totaled separately for the Sales and Usage entry types.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                group("Category_Copy Lines")
                {
                    Caption = 'Copy Lines';

                    actionref("Copy Job Planning Lines &from..._Promoted"; "Copy Job Planning Lines &from...")
                    {
                    }
                    actionref("Copy Job Planning Lines &to..._Promoted"; "Copy Job Planning Lines &to...")
                    {
                    }
                }
                actionref("Create &Sales Invoice_Promoted"; "Create &Sales Invoice")
                {
                }
                actionref("Split &Planning Lines_Promoted"; "Split &Planning Lines")
                {
                }
            }
            group("Category_Job Task")
            {
                Caption = 'Job Task';

                actionref(JobPlanningLines_Promoted; JobPlanningLines)
                {
                }
                actionref("Sales &Invoices/Credit Memos_Promoted"; "Sales &Invoices/Credit Memos")
                {
                }
                group(Category_Dimensions)
                {
                    Caption = 'Dimensions';
                    ShowAs = SplitButton;

                    actionref("Dimensions-&Multiple_Promoted"; "Dimensions-&Multiple")
                    {
                    }
                    actionref("Dimensions-&Single_Promoted"; "Dimensions-&Single")
                    {
                    }
                }
                actionref(JobTaskStatistics_Promoted; JobTaskStatistics)
                {
                }
                actionref("Job &Task Card_Promoted"; "Job &Task Card")
                {
                }
            }
            group(Category_WIP)
            {
                Caption = 'WIP';

                actionref("<Action48>_Promoted"; "<Action48>")
                {
                }
                actionref("<Action49>_Promoted"; "<Action49>")
                {
                }
                actionref("&WIP Entries_Promoted"; "&WIP Entries")
                {
                }
                actionref("WIP &G/L Entries_Promoted"; "WIP &G/L Entries")
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Reports';

                actionref("Job - Planning Lines_Promoted"; "Job - Planning Lines")
                {
                }
                actionref("Job Actual to Budget_Promoted"; "Job Actual to Budget")
                {
                }
                actionref("Job Analysis_Promoted"; "Job Analysis")
                {
                }
                actionref("Job - Suggested Billing_Promoted"; "Job - Suggested Billing")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DescriptionIndent := Indentation;
        StyleIsStrong := "Job Task Type" <> "Job Task Type"::Posting;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearTempDim();
    end;

    var
        [InDataSet]
        DescriptionIndent: Integer;
        [InDataSet]
        StyleIsStrong: Boolean;

    procedure SetPurchLineFilters(var PurchLine: Record "Purchase Line"; JobNo: Code[20]; JobTaskNo: Code[20])
    begin
        ApplyPurchaseLineFilters(PurchLine, JobNo, JobTaskNo);
    end;
}

