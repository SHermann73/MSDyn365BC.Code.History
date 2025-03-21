report 5971 "Service Contract-Detail"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ServiceMgt/Contract/ServiceContractDetail.rdlc';
    Caption = 'Service Contract-Detail';

    dataset
    {
        dataitem("Service Contract Header"; "Service Contract Header")
        {
            CalcFields = "Bill-to Name";
            DataItemTableView = SORTING("Contract Type", "Contract No.") WHERE("Contract Type" = CONST(Contract));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Contract No.", "Customer No.";
            column(ContrType_ServeContrHdr; "Contract Type")
            {
            }
            column(ContrNo_ServeContrHdr; "Contract No.")
            {
                IncludeCaption = true;
            }
            dataitem(PageLoop; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Descending) WHERE(Number = CONST(1));
                column(CustAddr6; CustAddr[6])
                {
                }
                column(CustAddr5; CustAddr[5])
                {
                }
                column(CustAddr4; CustAddr[4])
                {
                }
                column(CustAddr2; CustAddr[2])
                {
                }
                column(CustAddr3; CustAddr[3])
                {
                }
                column(CustAddr1; CustAddr[1])
                {
                }
                column(BilltoName_ServeContrHdr; "Service Contract Header"."Bill-to Name")
                {
                }
                column(CompanyAddr7; CompanyAddr[7])
                {
                }
                column(CompanyAddr8; CompanyAddr[8])
                {
                }
                column(CompanyAddr6; CompanyAddr[6])
                {
                }
                column(CompanyAddr5; CompanyAddr[5])
                {
                }
                column(CompanyAddr4; CompanyAddr[4])
                {
                }
                column(CompanyAddr3; CompanyAddr[3])
                {
                }
                column(CompanyAddr2; CompanyAddr[2])
                {
                }
                column(CompanyAddr1; CompanyAddr[1])
                {
                }
                column(ContrNo2_ServeContrHdr; "Service Contract Header"."Contract No.")
                {
                }
                column(StartDate_ServeContrHdr; Format("Service Contract Header"."Starting Date"))
                {
                }
                column(InvPeriod_ServeContrHdr; Format("Service Contract Header"."Invoice Period"))
                {
                }
                column(InvoicePeriodCaption; InvoicePeriodCaptionLbl)
                {
                }
                column(NextInvDate_ServeContrHdr; Format("Service Contract Header"."Next Invoice Date"))
                {
                }
                column(AnnualAmt_ServeContrHdr; "Service Contract Header"."Annual Amount")
                {
                    IncludeCaption = true;
                }
                column(Prepaid_ServeContrHdr; "Service Contract Header".Prepaid)
                {
                    IncludeCaption = true;
                }
                column(Status_ServeContrHdr; Format("Service Contract Header".Status))
                {
                }
                column(CompanyInfoPhNo; CompanyInfo."Phone No.")
                {
                    IncludeCaption = false;
                }
                column(CompanyInfoFaxNo; CompanyInfo."Fax No.")
                {
                    IncludeCaption = false;
                }
                column(Email_ServeContrHdr; "Service Contract Header"."E-Mail")
                {
                    IncludeCaption = true;
                }
                column(PhNo_ServeContrHdr; "Service Contract Header"."Phone No.")
                {
                    IncludeCaption = true;
                }
                column(ShowComments; ShowComments)
                {
                }
                column(PrepaidFmt_ServeContrHdr; Format("Service Contract Header".Prepaid))
                {
                }
                column(StatusCaption; StatusCaptionLbl)
                {
                }
                column(InvoicetoCaption; InvoicetoCaptionLbl)
                {
                }
                column(ServiceContractCaption; ServiceContractCaptionLbl)
                {
                }
                column(ServeContrHdrStartDtCptn; ServeContrHdrStartDtCptnLbl)
                {
                }
                column(ServContrHdrNxtInvDtCptn; ServContrHdrNxtInvDtCptnLbl)
                {
                }
                dataitem("Contract/Service Discount"; "Contract/Service Discount")
                {
                    DataItemLink = "Contract Type" = FIELD("Contract Type"), "Contract No." = FIELD("Contract No.");
                    DataItemLinkReference = "Service Contract Header";
                    DataItemTableView = SORTING("Contract Type", "Contract No.", Type, "No.", "Starting Date");
                    column(Type_ContrServeDiscount; Type)
                    {
                        IncludeCaption = true;
                    }
                    column(No_ContrServeDiscount; "No.")
                    {
                        IncludeCaption = true;
                    }
                    column(StrtDt_ContrServeDiscount; Format("Starting Date"))
                    {
                    }
                    column(Discnt_ContrServeDiscount; "Discount %")
                    {
                        IncludeCaption = true;
                    }
                    column(ServiceDiscountsCaption; ServiceDiscountsCaptionLbl)
                    {
                    }
                }
                dataitem("Service Contract Line"; "Service Contract Line")
                {
                    DataItemLink = "Contract Type" = FIELD("Contract Type"), "Contract No." = FIELD("Contract No.");
                    DataItemLinkReference = "Service Contract Header";
                    DataItemTableView = SORTING("Contract Type", "Contract No.", "Line No.");
                    column(ServeItmNo_ServeContrLine; "Service Item No.")
                    {
                    }
                    column(ServeItmNo_ServeContrLineCaption; FieldCaption("Service Item No."))
                    {
                    }
                    column(Desc_ServeContrLine; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(ItmNo_ServeContrLine; "Item No.")
                    {
                        IncludeCaption = true;
                    }
                    column(SerialNo_ServeContrLine; "Serial No.")
                    {
                        IncludeCaption = true;
                    }
                    column(ServPeriod_ServeContrLine; "Service Period")
                    {
                        IncludeCaption = true;
                    }
                    column(LnDiscount_ServeContrLine; "Line Discount %")
                    {
                        IncludeCaption = true;
                    }
                    column(LineAmt_ServeContrLine; "Line Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(RspTimeHrs_ServeContrLine; "Response Time (Hours)")
                    {
                        IncludeCaption = true;
                    }
                    column(UOMCode_ServeContrLine; "Unit of Measure Code")
                    {
                        IncludeCaption = true;
                    }
                    column(LineValue_ServeContrLine; "Line Value")
                    {
                        IncludeCaption = true;
                    }
                    column(ContrType_ServeContrLine; "Contract Type")
                    {
                    }
                    column(ContrNo_ServeContrLine; "Contract No.")
                    {
                    }
                    column(LineNo_ServeContrLine; "Line No.")
                    {
                    }
                    dataitem("Service Comment Line"; "Service Comment Line")
                    {
                        DataItemLink = "Table Subtype" = FIELD("Contract Type"), "Table Line No." = FIELD("Line No."), "No." = FIELD("Contract No.");
                        DataItemTableView = SORTING("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.") ORDER(Ascending) WHERE("Table Name" = FILTER("Service Contract"));
                        column(Date_ServeCmntLine; Format(Date))
                        {
                        }
                        column(Cmnt_ServeCmntLine; Comment)
                        {
                            IncludeCaption = true;
                        }
                        column(ServeCmntLineDateCaption; ServeCmntLineDateCaptionLbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if not ShowComments then
                                CurrReport.Break();
                        end;
                    }
                }
            }
            dataitem(Shipto; "Integer")
            {
                DataItemLinkReference = "Service Contract Header";
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(ShipToAddr6; ShipToAddr[6])
                {
                }
                column(ShipToAddr5; ShipToAddr[5])
                {
                }
                column(ShipToAddr4; ShipToAddr[4])
                {
                }
                column(ShipToAddr3; ShipToAddr[3])
                {
                }
                column(ShipToAddr2; ShipToAddr[2])
                {
                }
                column(ShipToAddr1; ShipToAddr[1])
                {
                }
                column(ShiptoAddressCaption; ShiptoAddressCaptionLbl)
                {
                }

                trigger OnPreDataItem()
                begin
                    if not ShowShippingAddr then
                        CurrReport.Break();
                end;
            }
            dataitem(ServcommentLine2; "Service Comment Line")
            {
                DataItemLink = "Table Subtype" = FIELD("Contract Type"), "No." = FIELD("Contract No.");
                DataItemTableView = SORTING("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.") ORDER(Ascending) WHERE("Table Name" = FILTER("Service Contract"), "Table Line No." = FILTER(0));
                column(Date_ServcmntLine2; Format(Date))
                {
                }
                column(Cmnt_ServcmntLine2; Comment)
                {
                    IncludeCaption = true;
                }
                column(CommentsCaption; CommentsCaptionLbl)
                {
                }

                trigger OnPreDataItem()
                begin
                    if not ShowComments then
                        CurrReport.Break();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddr.GetCompanyAddr("Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
                FormatAddr.ServContractSellto(CustAddr, "Service Contract Header");
                ShowShippingAddr := "Ship-to Code" <> '';
                if ShowShippingAddr then
                    FormatAddr.ServContractShipto(ShipToAddr, "Service Contract Header");
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowComments; ShowComments)
                    {
                        ApplicationArea = Service;
                        Caption = 'Show Comments';
                        ToolTip = 'Specifies if you want the printed report to show any service comments.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        CompanyInfoPhNoCaption = 'Phone No.';
        CompanyInfoFaxNoCaption = 'Fax No.';
        ServcmntLine2DateCaption = 'Date';
        PageCaption = 'Page';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        RespCenter: Record "Responsibility Center";
        FormatAddr: Codeunit "Format Address";
        CustAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        ShowShippingAddr: Boolean;
        ShowComments: Boolean;
        InvoicetoCaptionLbl: Label 'Invoice to';
        ServiceContractCaptionLbl: Label 'Service Contract';
        ServeContrHdrStartDtCptnLbl: Label 'Starting Date';
        ServContrHdrNxtInvDtCptnLbl: Label 'Next Invoice Date';
        ServiceDiscountsCaptionLbl: Label 'Service Discounts';
        ServeCmntLineDateCaptionLbl: Label 'Date';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        CommentsCaptionLbl: Label 'Comments';
        StatusCaptionLbl: Label 'Status';
        InvoicePeriodCaptionLbl: Label 'Invoice Period';
}

