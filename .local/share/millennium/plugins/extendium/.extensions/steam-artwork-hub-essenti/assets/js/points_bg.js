const DFM_OBSERVER = new MutationObserver(mutation_list=>{
    mutation_list.forEach(mutation=>{
        mutation.addedNodes.forEach(added_node=>{
            if ($J(added_node).hasClass('ModalPosition'))
            {
                const grabbedEl = $J('.ModalPosition video[class]')[0] || $J('.ModalPosition div[class][style^="background-image: url(\""]')[0];

                if (grabbedEl && (grabbedEl?.offsetWidth != grabbedEl?.offsetHeight && grabbedEl.offsetWidth > 100))
                {
                    const link = grabbedEl.querySelector('source:last-child')?.src || /url\(\"(.*)\"\)/g.exec(grabbedEl.style.backgroundImage)[1];
                    console.info(link);
                    if (link?.length) $J(`
                    <div class="DFM_ButtonBGOuter Panel Focusable" onclick="window.open('https://steamartworkhub.com/bgcropper#${link};0')">
                        <div class="DFM_ButtonBGInner">
                            <span>Crop This Background</span>
                        </div>
                    </div>
                    `).insertBefore($J('.ModalPosition_Content button').last()[0]);
                    return;
                }
            }
        });
    });
});

DFM_OBSERVER.observe($J('body')[0], { subtree: true, childList: true });