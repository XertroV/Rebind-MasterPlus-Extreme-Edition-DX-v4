string GetMapId() {
#if TMNEXT || MP4
  if (GetApp().RootMap is null) {
    return "";
  }
  return GetApp().RootMap.IdName;
#elif TURBO
  auto map = GetApp().Challenge;
  if (map is null) {
    return "";
  }
  return map.MapInfo.MapUid;
#endif
}
