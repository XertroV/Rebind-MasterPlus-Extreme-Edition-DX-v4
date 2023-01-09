string[] ExtendStringArrs(string[] &in a, const string[] &in b) {
    for (uint i = 0; i < b.Length; i++) {
        a.InsertLast(b[i]);
    }
    return a;
}

string[] ArrayUintToString(uint[] &in xs) {
    string[] ret = array<string>();
    for (uint i = 0; i < xs.Length; i++) {
        ret.InsertLast('' + xs[i]);
    }
    return ret;
}

string[] ArrayIntToString(int[] &in xs) {
    string[] ret = array<string>();
    for (uint i = 0; i < xs.Length; i++) {
        ret.InsertLast('' + xs[i]);
    }
    return ret;
}
