-- BootTidal.hs — TidalCycles boot file with TidalVST support
-- Place this file in your project dir and point your editor to it,
-- or merge it into your global ~/.config/tidal/BootTidal.hs

:set -XOverloadedStrings
import Sound.Tidal.Context

-- TidalVST OSC target (SuperCollider listens on port 3337)
let vstTarget = Target {
      oName      = "vstplugin",
      oAddress   = "127.0.0.1",
      oHandshake = True,
      oPort      = 3337,
      oBusPort   = Just 3338,
      oLatency   = 0.1,
      oSchedule  = Pre BundleStamp,
      oWindow    = Nothing,
      oTimestamp = BundleStamp
    }

-- Start Tidal with both SuperDirt and TidalVST targets
tidal <- startStream
    (defaultConfig {cFrameTimespan = 1/20})
    [ (superdirtTarget {oLatency = 0.1}, [superdirtShape])
    , (vstTarget,                        [superdirtShape])
    ]

-- Standard Tidal helpers
let p  = streamReplace tidal
    hush = streamHush tidal
    panic = do hush; mapM_ ($ silence) [d1,d2,d3,d4,d5,d6,d7,d8,d9]
    d1  = p 1  . (|< orbit 0)
    d2  = p 2  . (|< orbit 1)
    d3  = p 3  . (|< orbit 2)
    d4  = p 4  . (|< orbit 3)
    d5  = p 5  . (|< orbit 4)
    d6  = p 6  . (|< orbit 5)
    d7  = p 7  . (|< orbit 6)
    d8  = p 8  . (|< orbit 7)
    d9  = p 9  . (|< orbit 8)
    d10 = p 10 . (|< orbit 9)
    setcps = asap . cps
    bps x = setcps (x/2)
    bpm x = setcps (x/120)

-- TidalVST parameter helpers
-- Map varg1..varg100 to VST parameter indices 0..99
-- Usage: d1 $ n "0 3 7" # s "vst" # varg1 0.5
let varg n val = (nParam ("varg" ++ show n)) val
    varg1  = nParam "varg1"
    varg2  = nParam "varg2"
    varg3  = nParam "varg3"
    varg4  = nParam "varg4"
    varg5  = nParam "varg5"
    varg6  = nParam "varg6"
    varg7  = nParam "varg7"
    varg8  = nParam "varg8"
    -- Add more as needed, or use: varg N (pattern)
