codeunit 5915 "Customer-Notify by Email"
{
    TableNo = "Service Header";

    trigger OnRun()
    begin
        ServHeader := Rec;
        NotifyByEMailWhenServiceIsDone();
        Rec := ServHeader;
    end;

    var
        ServHeader: Record "Service Header";

        Text000: Label 'We have finished carrying out service order %1.';
        Text001: Label 'You can collect your serviced items when it is convenient for you.';
        Text002: Label 'The customer will be notified as requested because service order %1 is now %2.';

    local procedure NotifyByEMailWhenServiceIsDone()
    var
        ServEmailQueue: Record "Service Email Queue";
    begin
        if ServHeader."Notify Customer" <> ServHeader."Notify Customer"::"By Email" then
            exit;

        ServEmailQueue.Init();
        if ServHeader."Ship-to Code" <> '' then
            ServEmailQueue."To Address" := ServHeader."Ship-to E-Mail";
        if ServEmailQueue."To Address" = '' then
            ServEmailQueue."To Address" := ServHeader."E-Mail";

        OnGetEmailForNotifyByEMailWhenServiceIsDone(ServHeader, ServEmailQueue."To Address");

        if ServEmailQueue."To Address" = '' then
            exit;

        ServEmailQueue."Copy-to Address" := '';
        ServEmailQueue."Subject Line" := StrSubstNo(Text000, ServHeader."No.");
        ServEmailQueue."Body Line" := Text001;
        ServEmailQueue."Attachment Filename" := '';
        ServEmailQueue."Document Type" := ServEmailQueue."Document Type"::"Service Order";
        ServEmailQueue."Document No." := ServHeader."No.";
        ServEmailQueue.Status := ServEmailQueue.Status::" ";
        ServEmailQueue.Insert(true);
        ServEmailQueue.ScheduleInJobQueue();
        Message(
          Text002,
          ServHeader."No.", ServHeader.Status);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnGetEmailForNotifyByEMailWhenServiceIsDone(ServiceHeader: Record "Service Header"; var EmailAddress: Text[80])
    begin
    end;
}

