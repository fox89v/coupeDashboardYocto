#include "GraphicsUtils.h"

int GraphicsUtils::clamp(int v, int a, int b) { return v < a ? a : (v > b ? b : v); }
