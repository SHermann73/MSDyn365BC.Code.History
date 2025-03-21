permissionset 5951 "Payables Documents - View"
{
    Access = Public;
    Assignable = false;
    Caption = 'Read posted receipts etc.';

    Permissions = tabledata "General Posting Setup" = r,
                  tabledata "Item Reference" = R,
                  tabledata "Item Tracking Code" = R,
                  tabledata "Purch. Comment Line" = RIMD,
                  tabledata "Purch. Cr. Memo Hdr." = Rm,
                  tabledata "Purch. Cr. Memo Line" = R,
                  tabledata "Purch. Inv. Header" = Rm,
                  tabledata "Purch. Inv. Line" = R,
                  tabledata "Purch. Rcpt. Header" = Rm,
                  tabledata "Purch. Rcpt. Line" = R,
                  tabledata "Report Selections" = R,
                  tabledata "Return Shipment Header" = Rm,
                  tabledata "Return Shipment Line" = R,
                  tabledata "Tax Area" = R,
                  tabledata "Tax Area Line" = R,
                  tabledata "Tax Detail" = R,
                  tabledata "Tax Group" = R,
                  tabledata "Tax Jurisdiction" = R,
                  tabledata "User Setup" = r,
                  tabledata "VAT Assisted Setup Bus. Grp." = R,
                  tabledata "VAT Assisted Setup Templates" = R,
                  tabledata "VAT Posting Setup" = R,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Setup Posting Groups" = R;
}
