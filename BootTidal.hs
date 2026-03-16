:set -fno-warn-orphans -Wno-type-defaults -XMultiParamTypeClasses -XOverloadedStrings
:set prompt ""

import Sound.Tidal.Boot

default (Rational, Integer, Double, Pattern String)

-- TidalVST OSC target (SuperCollider listens on port 3337)
let vstTarget = superdirtTarget { oName = "vstplugin", oPort = 3337, oBusPort = Just 3338, oLatency = 0.1 }

-- Start Tidal with SuperDirt + TidalVST targets
tidalInst <- mkTidalWith [(superdirtTarget { oLatency = 0.1 }, [superdirtShape]), (vstTarget, [superdirtShape])] (defaultConfig {cFrameTimespan = 1/20})

instance Tidally where tidal = tidalInst

-- TidalVST parameter helpers (varg1..varg100 map to VST parameter indices)
:{
    vstName = pS "vstName"
    varg1 = pF "varg1"
    varg2 = pF "varg2"
    varg3 = pF "varg3"
    varg4 = pF "varg4"
    varg5 = pF "varg5"
    varg6 = pF "varg6"
    varg7 = pF "varg7"
    varg8 = pF "varg8"
    varg9 = pF "varg9"
    varg10 = pF "varg10"
    varg11 = pF "varg11"
    varg12 = pF "varg12"
    varg13 = pF "varg13"
    varg14 = pF "varg14"
    varg15 = pF "varg15"
    varg16 = pF "varg16"
    varg17 = pF "varg17"
    varg18 = pF "varg18"
    varg19 = pF "varg19"
    varg20 = pF "varg20"
    varg1bus busid pat = (pF "varg1" pat) # (pI "^varg1" busid)
    varg2bus busid pat = (pF "varg2" pat) # (pI "^varg2" busid)
    varg3bus busid pat = (pF "varg3" pat) # (pI "^varg3" busid)
    varg4bus busid pat = (pF "varg4" pat) # (pI "^varg4" busid)
    varg5bus busid pat = (pF "varg5" pat) # (pI "^varg5" busid)
:}

:set prompt "tidal> "
:set prompt-cont ""
