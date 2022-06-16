// AnyInputButMouse disabled b/c we need to choose a pad when instantiating the
// call to bind and we don't know which to call (and null doesn't work).

enum PadType {
    Keyboard = 0,
    Mouse = 1,
    GamePad = 2,
    // AnyInputButMouse = 6,
    AnyInputDevice = 7,
}

const PadType[] ALL_PAD_TYPES = {
   PadType::Keyboard,
   PadType::Mouse,
   PadType::GamePad
//    PadType::AnyInputButMouse,
//    PadType::AnyInputDevice  // remove from this list so we don't show it in wiz
};

string PadTypeToStr(PadType pt) {
   if (pt == PadType::Keyboard) return "Keyboard";
   if (pt == PadType::Mouse) return "Mouse";
   if (pt == PadType::GamePad) return "GamePad";
//    if (pt == PadType::AnyInputButMouse) return "AnyInputButMouse";
   if (pt == PadType::AnyInputDevice) return "AnyInputDevice";
   return "AnyInputDevice";
}

PadType PadTypeFromStr(const string &in  pt) {
   if (pt == "Keyboard") return PadType::Keyboard;
   if (pt == "Mouse") return PadType::Mouse;
   if (pt == "GamePad") return PadType::GamePad;
//    if (pt == "AnyInputButMouse") return PadType::AnyInputButMouse;
   if (pt == "AnyInputDevice") return PadType::AnyInputDevice;
   return PadType::AnyInputDevice;
}
