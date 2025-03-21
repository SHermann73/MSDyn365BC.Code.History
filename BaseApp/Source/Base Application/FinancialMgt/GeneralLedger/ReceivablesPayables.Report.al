report 5 "Receivables-Payables"
{
    DefaultLayout = RDLC;
    RDLCLayout = './FinancialMgt/GeneralLedger/ReceivablesPayables.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'Receivables-Payables';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("General Ledger Setup"; "General Ledger Setup")
        {
            DataItemTableView = SORTING("Primary Key") WHERE("Primary Key" = CONST(''));
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(GLSetupCustBalancesDue; GLSetup."Cust. Balances Due")
            {
                AutoFormatType = 1;
            }
            column(GLSetupVenBalancesDue; GLSetup."Vendor Balances Due")
            {
                AutoFormatType = 1;
            }
            column(NetBalancesDueLCY; NetBalancesDueLCY)
            {
                AutoFormatType = 1;
            }
            column(GLSetupCustVenBalancesDue; GLSetup."Cust. Balances Due" - GLSetup."Vendor Balances Due")
            {
                AutoFormatType = 1;
            }
            column(BeforeCustBalanceLCY; beforeCustBalanceLCY)
            {
            }
            column(BeforeVendorBalanceLCY; beforeVendorBalanceLCY)
            {
            }
            column(VenBalancesDue_GLSetup; "Vendor Balances Due")
            {
            }
            column(CustBalancesDue_GLSetup; "Cust. Balances Due")
            {
            }
            column(CustVenBalancesDue_GLSetup; "Cust. Balances Due" - "Vendor Balances Due")
            {
                AutoFormatType = 1;
            }
            column(PrimaryKey_GLSetup; "Primary Key")
            {
            }
            column(ReceivablesPayablesCaption; ReceivablesPayablesCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(DueDateCaption; DueDateCaptionLbl)
            {
            }
            column(CustBalDueCaption; CustBalDueCaptionLbl)
            {
            }
            column(VendBalDueCaption; VendBalDueCaptionLbl)
            {
            }
            column(BalDateLCYCaption; BalDateLCYCaptionLbl)
            {
            }
            column(NetChangeLCYCaption; NetChangeLCYCaptionLbl)
            {
            }
            column(BeforeCaption; BeforeCaptionLbl)
            {
            }
            column(AfterCaption; AfterCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            dataitem(PeriodLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(GLSetupDateFilter; GLSetup.GetFilter("Date Filter"))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    StartDate := EndDate + 1;
                    EndDate := CalcDate(PeriodLength, StartDate) - 1;
                    MultiplyAmounts();
                end;

                trigger OnPreDataItem()
                begin
                    if StartDate <> 0D then begin
                        EndDate := StartDate - 1;
                        StartDate := 0D;
                        MultiplyAmounts();
                        beforeCustBalanceLCY := GLSetup."Cust. Balances Due";
                        beforeVendorBalanceLCY := GLSetup."Vendor Balances Due";
                    end;
                    SetRange(Number, 1, NoOfPeriods);
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        NotBlank = true;
                        ToolTip = 'Specifies the date from which the report or batch job processes information.';
                    }
                    field(NoOfPeriods; NoOfPeriods)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Periods';
                        ToolTip = 'Specifies how many accounting periods to include in the report.';
                    }
                    field(PeriodLength; PeriodLength)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period Length';
                        ToolTip = 'Specifies the period for which data is shown in the report. For example, enter "1M" for one month, "30D" for thirty days, "3Q" for three quarters, or "5Y" for five years.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if StartDate = 0D then
                StartDate := WorkDate();
            if NoOfPeriods = 0 then
                NoOfPeriods := 1;
            if Format(PeriodLength) = '' then
                Evaluate(PeriodLength, '<1M>');
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        StartDate := WorkDate();
        NoOfPeriods := 1;
        Evaluate(PeriodLength, '<1M>');
    end;

    var
        GLSetup: Record "General Ledger Setup";
        StartDate: Date;
        EndDate: Date;
        NoOfPeriods: Integer;
        PeriodLength: DateFormula;
        NetBalancesDueLCY: Decimal;
        beforeCustBalanceLCY: Decimal;
        beforeVendorBalanceLCY: Decimal;
        ReceivablesPayablesCaptionLbl: Label 'Receivables-Payables';
        PageCaptionLbl: Label 'Page';
        DueDateCaptionLbl: Label 'Due Date';
        CustBalDueCaptionLbl: Label 'Cust. Balances Due (LCY)';
        VendBalDueCaptionLbl: Label 'Vendor Balances Due (LCY)';
        BalDateLCYCaptionLbl: Label 'Balance at Date (LCY)';
        NetChangeLCYCaptionLbl: Label 'Net Change (LCY)';
        BeforeCaptionLbl: Label '...Before';
        AfterCaptionLbl: Label 'After...';
        TotalCaptionLbl: Label 'Total';

    local procedure MultiplyAmounts()
    begin
        with GLSetup do begin
            SetRange("Date Filter", StartDate, EndDate);
            CalcFields("Cust. Balances Due", "Vendor Balances Due");
            NetBalancesDueLCY := NetBalancesDueLCY + "Cust. Balances Due" - "Vendor Balances Due";
        end;
    end;

    procedure InitializeRequest(NewStartDate: Date; NewNoOfPeriods: Integer; NewPeriodLength: DateFormula)
    begin
        StartDate := NewStartDate;
        NoOfPeriods := NewNoOfPeriods;
        PeriodLength := NewPeriodLength;
    end;
}

