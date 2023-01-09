// FROM COTD_HUD


/* loop colors */
Color@ loopColorStart = Color(vec3(0, 73, 53), ColorTy::HSL);
Color@ loopColorMid = Color(vec3(120, 73, 53), ColorTy::HSL);
Color@ loopColorEnd = Color(vec3(240, 73, 53), ColorTy::HSL);
Color@ loopColorStart2 = Color(vec3(360, 73, 53), ColorTy::HSL);
// Color@ loopColorMid = Color(vec3(3., 0xc, 0xe) / 16.).ToHSL();  // h=190

string[] loopColors = ExtendStringArrs(
    ExtendStringArrs(
        maniaColorForColors(gradientColors(loopColorStart, 30, loopColorMid)),
        maniaColorForColors(gradientColors(loopColorMid, 30, loopColorEnd))
    ), maniaColorForColors(gradientColors(loopColorEnd, 30, loopColorStart2))
);
// string[] loopColors = maniaColorForColors(gradientColors(loopColorStart, 60, loopColorEnd));
uint nLoopColors = loopColors.Length;

string rainbowLoopColorCycle(const string &in text, bool escape = false, float loopSecDuration = 1.5, bool fwds = true, float startIx = -1) {
    float msPerC = 1000. * loopSecDuration / float(nLoopColors);
    if (startIx < 0)
        startIx = uint(Time::Now / msPerC) % nLoopColors;
    string ret = "";
    string c;
    for (int i = 0; i < text.Length; i++) {
        c = loopColors[int(fwds ? nLoopColors + startIx - i : startIx + i) % nLoopColors];
        if (escape) ret += "\\";
        ret += c + text.SubStr(i, 1);
    }
    return ret;
}
