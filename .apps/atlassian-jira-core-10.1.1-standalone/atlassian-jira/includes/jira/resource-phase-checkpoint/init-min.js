window.__resourcePhaseCheckpointResolvers={resolveDeferPhaseCheckpoint:null,resolveInteractionPhaseCheckpoint:null};if(window.performance&&window.performance.mark){window.DeferScripts||(window.DeferScripts={});window.DeferScripts.totalClicks=0;window.DeferScripts.totalKeydowns=0;window.DeferScripts.clickListener=function(){"use strict";window.DeferScripts.totalClicks+=1};window.addEventListener("click",window.DeferScripts.clickListener);window.DeferScripts.keydownListener=function(){"use strict";window.DeferScripts.totalKeydowns+=1};window.addEventListener("keydown",window.DeferScripts.keydownListener)}window.resourcePhaseCheckpoint=Object.freeze({defer:new Promise((function(e){"use strict";window.__resourcePhaseCheckpointResolvers.resolveDeferPhaseCheckpoint=e})),interaction:new Promise((function(e){"use strict";window.__resourcePhaseCheckpointResolvers.resolveInteractionPhaseCheckpoint=e}))});Object.freeze(window.__resourcePhaseCheckpointResolvers);