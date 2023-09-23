uint lastNow = 0, timeInGame = 0, prevUiSequence = 0, lastUiSequence = 0;
bool uiDialogSafe = false;

void AsyncLoop_AbortBindingDialogsWhenDangerous() {
    while (true) {
        prevUiSequence = lastUiSequence;
        lastUiSequence = GI::GetPlaygroundFstUISequence();
        if (lastNow > 0)
            timeInGame += Time::Now - lastNow;
        if (prevUiSequence != lastUiSequence) {
            trace("UISequence: " + lastUiSequence + " (previously: " + prevUiSequence + ")");
            if (GI::GetApp().Operation_InProgress) {
                warn("Running Operation_Abort");
                GI::GetApp().Operation_Abort();
            }
        }
        if (GI::GetApp().Operation_InProgress) {
            uiDialogSafe = false;
        } else if (GI::InMainMenu()) {
            uiDialogSafe = true;
        } else if (GI::InEditor()) {
            uiDialogSafe = true;
        } else if (!(GI::InGame()) || GI::IsLoadingScreen()) {
            timeInGame = lastNow = 0;
            uiDialogSafe = false;
        } else {
            if ((lastUiSequence == 1 || lastUiSequence == 2) && prevUiSequence > 1) {
                // I think the dialog is always safe after this point, mb?
                uiDialogSafe = true;
            } else if (lastUiSequence > 2 || lastUiSequence == 0) {
                uiDialogSafe = false;
            } else if (lastUiSequence == 1 && timeInGame > 5000) {
                // if no other conditions have triggered and we're playing, set to true after a few seconds.
                //
                // why wait? b/c sometimes the UI sequence is set to 1 during 'synchronization' and during
                // that time you can break stuff if you open a dialog (even with the abort loop)
                uiDialogSafe = true;
            }
        }
        lastNow = Time::Now;
        yield();
    }
}

bool IsUiDialogSafe() {
    return uiDialogSafe;
}
