trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            ContentDocumentLinkTriggerHandler.onAfterInsert(trigger.new);
        }
    }
}