(async function () {
    const cache = {};
    const options = await chrome.storage.sync.get() || {};
    const hideOptionsMap = {
        DIFFICULTY: 'hideDifficulty',
        PLAYTHROUGHS: 'hidePlaythroughs',
        HOURS: 'hideHours',
        MISSABLES: 'hideMissables',
        ONLINE: 'hideOnline',
        'POST LAUNCH ACHVS': 'hidePostLaunchAchvs',
        'PAID DLC REQUIRED': 'hidePaidDlcRequired',
        'DIFFICULTY SPECIFIC': 'hideDifficultySpecific',
        UNOBTAINABLES: 'hideUnobtainables',
        'COND. OBTAINABLES': 'hideCondObtainables',
        BROKEN: 'hideBroken',
    };
    const token = options.token || '';
    let subscriptionActive = false;
    if (token) {
        // console.log(token);
        try {
            const response = await new Promise((resolve) => {
                chrome.runtime.sendMessage({ type: 'checkSubscription', token }, (response) => {
                    // console.log(response);
                    // if (response.success && response.data) {
                    //     subscriptionActive = true;
                    // }
                    resolve(response);
                });
            });
            subscriptionActive = response.success;
        } catch (error) { }
    }

    const getColorFromDistance = (distance) => {
        if (distance === -1) {
            return '#666';
        }
        distance = Math.min(1, Math.max(0, distance));
        let hue = (1 - distance) * 118;
        return `hsl(${hue}, 40%, 50%)`;
    };

    const fetchGuide = async (appId) => {
        if (cache[appId]) {
            return cache[appId];
        }

        return new Promise((resolve) => {
            chrome.runtime.sendMessage(
                { type: 'fetchGuide', appId, extensionVersion: chrome.runtime.getManifest().version },
                (response) => {
                    if (chrome.runtime.lastError) {
                        cache[appId] = { success: false, error: chrome.runtime.lastError.message };
                        resolve(cache[appId]);
                    } else {
                        cache[appId] = response;
                        resolve(response);
                    }
                }
            );
        });
    };

    const createInfoBoxHtml = (data) => {
        const { guideLinks, infoBoxes, hideHeader, hideFooter } = data;

        // Header links
        let header = '';
        if (!hideHeader) {
            for (const { name, link } of guideLinks) {
                if (link) {
                    header += `<a href="${link}" target="_blank" class="guide-link-title">${name}</a>`;
                }
            }
            header = `<div class="guide-links-container">${header}</div>`;
        }

        // Info boxes
        const filteredInfoBoxes = infoBoxes
            .filter(({ label }) => {
                const optionKey = hideOptionsMap[label.toUpperCase()];
                return !options[optionKey];
            })
            .filter(({ value, label }) => !options.hideNaValues || value !== 'N/A' || label === 'Loading...')
            .map(({ label, value, distance, link }) => {
                const boxContent = `
                    <div class="stat-box" style="background: ${getColorFromDistance(distance)}">
                        <div class="stat-value">${value}</div>
                        <div class="stat-label">${label.toUpperCase()}</div>
                    </div>
                `;
                if (link) {
                    return `
                        <a href="${link}" class="stat-box-link" target="_blank" rel="noopener noreferrer">
                        ${boxContent}
                        </a>
                    `;
                } else {
                    return boxContent;
                }
            });
        let boxesHtml = filteredInfoBoxes.join("");
        // if (filteredInfoBoxes.length === 0) {
        //     boxesHtml = `
        //         <div class="stat-box" style="background: ${getColorFromDistance(-1)}">
        //             <div class="stat-value">No data</div>
        //         </div>
        //     `;
        // }

        let footer = '';
        if (!hideFooter) {
            footer = `
                <a href="https://steam-achievement-guide.onrender.com" target="_blank" class="guide-link-title">Website</a>
                <a href="https://patreon.com/jansivans" target="_blank" class="guide-link-title">Patreon</a>
                <a href="https://buymeacoffee.com/jansivans" target="_blank" class="guide-link-title">Coffee</a>
                <a href="https://discord.gg/t8cBtPAczE" target="_blank" class="guide-link-title">Discord</a>
            `;
            footer = ` <div class="links-container">${footer}</div>`;
        }
        if (hideFooter && hideHeader && filteredInfoBoxes.length === 0) {
            return '';
        }
        if (boxesHtml) {
            boxesHtml = `<div class="stats-grid">${boxesHtml}</div>`;
        }

        return `
            <div class="achievement-guide">
                ${header}
                ${boxesHtml}
                ${footer}
            </div>
        `;
    };

    const createLoadingPlaceholderHtml = (data = {}) => {

        return createInfoBoxHtml({
            ...data,
            // hideFooter: true,
            // hideHeader: true,
            guideLinks: [],
            infoBoxes: Array(12).fill({ label: 'Loading...', value: 'N/A', distance: -1 }),
        });
    };

    const wishlistMatch = window.location.pathname.match(/\/wishlist\//);
    if (wishlistMatch && !options.disableOnWishlistPage) {
        const processedGames = {};
        const subscriptionLimit = 20;
        const processedPanels = new Map(); // Map<panelElement, { appId: string, isProcessed: boolean }>
        const extractIdFromUrl = (url) => {
            const match = url.match(/\/app\/(\d+)\//);
            return match ? match[1] : null;
        };
        const removeDraggableElements = (root = document) => {
            const draggable = root.querySelectorAll('[data-rfd-drag-handle-draggable-id]');
            const parents = Array.from(draggable).map((el) => el.parentElement);
            parents.forEach((el) => el.remove());
        };
        const adjustPanelStyles = (panel) => {
            const firstChild = panel.children[0];
            if (firstChild && firstChild.classList.contains("Panel")) {
                firstChild.style.marginBottom = "0px";
                firstChild.style.boxShadow = 'unset';
                firstChild.style.transition = 'unset';
            } else if (firstChild && firstChild.children[0]) {
                firstChild.children[0].style.marginBottom = "0px";
                firstChild.children[0].style.boxShadow = 'unset';
                firstChild.children[0].style.transition = 'unset';
            }
        };
        const insertInfoBox = async (panel) => {
            const link = panel.querySelector("a[href*='/app/']");
            if (!link) return;

            const id = extractIdFromUrl(link.href);
            if (!id) return;

            const panelData = processedPanels.get(panel);

            // If panel is already processed for this appId, do nothing
            if (panelData && panelData.appId === id && panelData.isProcessed) {
                return;
            }

            // If panel's appId has changed, reset its processed state and remove old info box
            if (panelData && panelData.appId !== id) {
                processedPanels.set(panel, { appId: id, isProcessed: false });

                // Remove existing info box immediately
                const existingInfoBox = panel.querySelector(".achievement-guide");
                if (existingInfoBox) {
                    existingInfoBox.remove();
                }

                // Adjust panel styles
                adjustPanelStyles(panel);

                // Add a loading placeholder
                const loadingContainer = document.createElement('div');
                loadingContainer.innerHTML = createLoadingPlaceholderHtml();
                if (panel.children[0].classList.contains("Panel")) {
                    panel.appendChild(loadingContainer);
                } else {
                    panel.children[0].appendChild(loadingContainer);
                }
            } else if (!panelData) {
                // New panel
                processedPanels.set(panel, { appId: id, isProcessed: false });

                // Ensure no existing info box is present
                const existingInfoBox = panel.querySelector(".achievement-guide");
                if (existingInfoBox) {
                    existingInfoBox.remove();
                }

                // Adjust panel styles
                adjustPanelStyles(panel);

                // Add a loading placeholder
                const loadingContainer = document.createElement('div');
                loadingContainer.innerHTML = createLoadingPlaceholderHtml();
                if (panel.children[0].classList.contains("Panel")) {
                    panel.appendChild(loadingContainer);
                } else {
                    panel.children[0].appendChild(loadingContainer);
                }
            }

            // Remove draggable elements within this panel
            removeDraggableElements(panel);

            // Observe this panel for visibility
            intersectionObserver.observe(panel);
        };
        const intersectionObserver = new IntersectionObserver(
            async (entries) => {
                for (const entry of entries) {
                    if (entry.isIntersecting) {
                        const panel = entry.target;
                        const panelData = processedPanels.get(panel);
                        if (!panelData || panelData.isProcessed) {
                            intersectionObserver.unobserve(panel);
                            continue;
                        }

                        const appId = panelData.appId;
                        if (Object.keys(processedGames).length < subscriptionLimit) {
                            processedGames[appId] = true;
                        }
                        let response;
                        if (Object.keys(processedGames).length >= subscriptionLimit && !processedGames[appId] && !subscriptionActive) {
                            response = { success: false, error: 'Unauthorized' };
                        } else {
                            response = await fetchGuide(appId, true);
                        }

                        // Remove existing info box or loading placeholder
                        const existingInfoBox = panel.querySelector(".achievement-guide");
                        if (existingInfoBox) existingInfoBox.remove(); // Remove old info box or loading

                        if (response && response.success && Array.isArray(response.data) && response.data.length > 0) {
                            // Adjust panel styles (optional, if not already done)
                            adjustPanelStyles(panel);

                            const infoBoxHtml = createInfoBoxHtml(response.data[0]); // Use the first guide as an example
                            const container = document.createElement('div');
                            container.innerHTML = infoBoxHtml;

                            if (panel.children[0].classList.contains("Panel")) {
                                panel.appendChild(container);
                            } else {
                                panel.children[0].appendChild(container);
                            }

                            // Mark panel as processed
                            processedPanels.set(panel, { appId, isProcessed: true });
                        } else {
                            // Show error message
                            const errorContainer = document.createElement('div');
                            let infoBox = {
                                label: 'Please update the extension or contact us on <a href="https://discord.gg/t8cBtPAczE" target="_blank" style="color: #fff;">Discord</a>',
                                value: 'STEAM ACHIEVEMENT GUIDE ERROR',
                                distance: -1,
                            };
                            if (response.error?.toLowerCase().includes('unauthorized')) {
                                infoBox = {
                                    label: 'Subscribe to <a href="https://patreon.com/jansivans" target="_blank" style="color: #fff;">Patreon</a> or <a href="https://buymeacoffee.com/jansivans" target="_blank" style="color: #fff;">Buy Me a Coffee</a> to access guides for all wishlist games',
                                    value: 'STEAM ACHIEVEMENT GUIDE SUBSCRIPTION REQUIRED',
                                    distance: -1,
                                };
                            }
                            errorContainer.innerHTML = createInfoBoxHtml({
                                guideLinks: [],
                                infoBoxes: [infoBox],
                            });
                            if (panel.children[0].classList.contains("Panel")) {
                                panel.appendChild(errorContainer);
                            } else {
                                panel.children[0].appendChild(errorContainer);
                            }
                            processedPanels.set(panel, { appId, isProcessed: true });
                        }

                        // Unobserve the panel since it's processed
                        intersectionObserver.unobserve(panel);
                    }
                }
            },
            {
                root: null, // viewport
                rootMargin: "0px",
                threshold: 0.1, // Adjust as needed
            }
        );
        const mutationObserver = new MutationObserver((mutations) => {
            for (const mutation of mutations) {
                // Handle added nodes
                mutation.addedNodes.forEach((node) => {
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        if (node.matches("div[data-index]")) {
                            insertInfoBox(node);
                        } else {
                            const panels = node.querySelectorAll("div[data-index]");
                            panels.forEach((panel) => insertInfoBox(panel));
                        }
                    }
                });

                // Handle attribute changes that might indicate content changes
                if (mutation.type === 'attributes' && (mutation.attributeName === 'href' || mutation.attributeName === 'src')) {
                    const panel = mutation.target.closest("div[data-index]");
                    if (panel) {
                        insertInfoBox(panel);
                    }
                }

                // Handle removed nodes to clean up
                mutation.removedNodes.forEach((node) => {
                    if (node.nodeType === Node.ELEMENT_NODE && node.matches("div[data-index]")) {
                        processedPanels.delete(node);
                        intersectionObserver.unobserve(node);
                    }
                });
            }
        });
        mutationObserver.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['href', 'src'],
        });
        removeDraggableElements();
        const existingPanels = document.querySelectorAll("div[data-index]");
        existingPanels.forEach((panel) => insertInfoBox(panel));
    }

    const gamesPageMatch = window.location.pathname.match(/\/(id|profiles)\/[^/]+\/games/);
    if (gamesPageMatch) {
        // Relax virtualized absolute positioning so injected guides don't overlap rows
        const styleId = 'stg-games-page-overrides';
        if (!document.getElementById(styleId)) {
            const styleEl = document.createElement('style');
            styleEl.id = styleId;
            styleEl.textContent = `
                .FbG-gxCxUQw- {
                    height: auto !important;
                }
                .FbG-gxCxUQw- > .JeLbcWPaZDg- {
                    position: static !important;
                    top: auto !important;
                    left: auto !important;
                    right: auto !important;
                    width: 100% !important;
                }
                .mtoll770TDI-.Panel {
                    height: auto !important;
                }
            `;
            document.head.appendChild(styleEl);
        }

        const processedGamesOnProfile = {};
        const subscriptionLimit = 20;
        const processedPanels = new Map();
        const extractIdFromUrl = (url) => {
            const match = url.match(/\/app\/(\d+)(?:\/|$)/);
            return match ? match[1] : null;
        };
        const clearGuide = (panel) => {
            panel.querySelectorAll(".stg-games-guide").forEach((el) => el.remove());
            panel.querySelectorAll(".achievement-guide").forEach((el) => el.remove());
        };
        const addPlaceholder = (panel) => {
            clearGuide(panel);
            const loadingContainer = document.createElement('div');
            loadingContainer.className = 'stg-games-guide';
            loadingContainer.style.gridColumn = '1 / -1';
            loadingContainer.style.flexBasis = '100%';
            loadingContainer.style.order = '99';
            loadingContainer.innerHTML = createLoadingPlaceholderHtml({
                hideHeader: true,
            });
            panel.appendChild(loadingContainer);
        };
        const collectGamePanels = (root = document) => {
            const panels = [];
            if (root.nodeType === Node.ELEMENT_NODE) {
                if (root.getAttribute('role') === 'button' && root.querySelector("a[href*='/app/']")) {
                    panels.push(root);
                }
                root.querySelectorAll("div[role='button']").forEach((panel) => {
                    if (panel.querySelector("a[href*='/app/']")) {
                        panels.push(panel);
                    }
                });
            }
            return panels;
        };
        const insertInfoBox = (panel) => {
            const link = panel.querySelector("a[href*='/app/']");
            if (!link) return;

            const id = extractIdFromUrl(link.href);
            if (!id) return;

            const panelData = processedPanels.get(panel);
            if (panelData && panelData.appId === id && panelData.isProcessed) {
                return;
            }

            if (!panelData || panelData.appId !== id) {
                processedPanels.set(panel, { appId: id, isProcessed: false });
                addPlaceholder(panel);
            } else if (!panel.querySelector(".achievement-guide")) {
                addPlaceholder(panel);
            }

            intersectionObserver.observe(panel);
        };
        const intersectionObserver = new IntersectionObserver(
            async (entries) => {
                for (const entry of entries) {
                    if (!entry.isIntersecting) {
                        continue;
                    }

                    const panel = entry.target;
                    const panelData = processedPanels.get(panel);
                    if (!panelData || panelData.isProcessed) {
                        intersectionObserver.unobserve(panel);
                        continue;
                    }

                    const appId = panelData.appId;
                    if (Object.keys(processedGamesOnProfile).length < subscriptionLimit) {
                        processedGamesOnProfile[appId] = true;
                    }
                    let response;
                    if (Object.keys(processedGamesOnProfile).length >= subscriptionLimit && !processedGamesOnProfile[appId] && !subscriptionActive) {
                        response = { success: false, error: 'Unauthorized' };
                    } else {
                        response = await fetchGuide(appId, true);
                    }

                    clearGuide(panel);

                    if (response && response.success && Array.isArray(response.data) && response.data.length > 0) {
                        const infoBoxHtml = createInfoBoxHtml({
                            ...response.data[0],
                        });
                        const container = document.createElement('div');
                        container.className = 'stg-games-guide';
                        container.style.gridColumn = '1 / -1';
                        container.style.flexBasis = '100%';
                        container.style.order = '99';
                        container.innerHTML = infoBoxHtml;
                        panel.appendChild(container);
                        processedPanels.set(panel, { appId, isProcessed: true });
                    } else {
                        const errorContainer = document.createElement('div');
                        errorContainer.className = 'stg-games-guide';
                        errorContainer.style.gridColumn = '1 / -1';
                        errorContainer.style.flexBasis = '100%';
                        errorContainer.style.order = '99';
                        const unauthorized = typeof response?.error === 'string' && response.error.toLowerCase().includes('unauthorized');
                        let infoBox = {
                            label: 'Please update the extension or contact us on <a href="https://discord.gg/t8cBtPAczE" target="_blank" style="color: #fff;">Discord</a>',
                            value: 'STEAM ACHIEVEMENT GUIDE ERROR',
                            distance: -1,
                        };
                        if (unauthorized) {
                            infoBox = {
                                label: 'Subscribe to <a href="https://patreon.com/jansivans" target="_blank" style="color: #fff;">Patreon</a> or <a href="https://buymeacoffee.com/jansivans" target="_blank" style="color: #fff;">Buy Me a Coffee</a> to access guides for all games',
                                value: 'STEAM ACHIEVEMENT GUIDE SUBSCRIPTION REQUIRED',
                                distance: -1,
                            };
                        }
                        errorContainer.innerHTML = createInfoBoxHtml({
                            guideLinks: [],
                            infoBoxes: [infoBox],
                        });
                        panel.appendChild(errorContainer);
                        processedPanels.set(panel, { appId, isProcessed: true });
                    }

                    intersectionObserver.unobserve(panel);
                }
            },
            {
                root: null,
                rootMargin: "0px 0px 200px 0px",
                threshold: 0.1,
            }
        );
        const mutationObserver = new MutationObserver((mutations) => {
            for (const mutation of mutations) {
                mutation.addedNodes.forEach((node) => {
                    collectGamePanels(node).forEach((panel) => insertInfoBox(panel));
                });

                if (mutation.type === 'attributes' && (mutation.attributeName === 'href' || mutation.attributeName === 'src')) {
                    const panel = mutation.target.closest("div[role='button']");
                    if (panel && panel.querySelector("a[href*='/app/']")) {
                        insertInfoBox(panel);
                    }
                }

                mutation.removedNodes.forEach((node) => {
                    if (processedPanels.has(node)) {
                        processedPanels.delete(node);
                        intersectionObserver.unobserve(node);
                    }
                    if (node.nodeType === Node.ELEMENT_NODE) {
                        node.querySelectorAll("div[role='button']").forEach((panel) => {
                            if (processedPanels.has(panel)) {
                                processedPanels.delete(panel);
                                intersectionObserver.unobserve(panel);
                            }
                        });
                    }
                });
            }
        });
        mutationObserver.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['href', 'src'],
        });
        collectGamePanels(document.body).forEach((panel) => insertInfoBox(panel));
    }

    const appIdMatch = window.location.pathname.match(/\/app\/(\d+)/);
    const appId = appIdMatch ? appIdMatch[1] : null;

    if (appId) {
        // Create a container for the achievement guide with a loading placeholder
        const rightBlocks = document.querySelectorAll('.responsive_apppage_details_right');
        if (rightBlocks.length > 0) {
            const existingGuide = rightBlocks[0].querySelector('.achievement-guide');
            if (existingGuide) {
                existingGuide.remove(); // Remove existing guide if present
            }

            const achievementGuideBlock = document.createElement('div');
            achievementGuideBlock.classList.add('block', 'responsive_apppage_details_right');
            achievementGuideBlock.style.order = '-1';
            achievementGuideBlock.style.padding = '0';
            // Remove or adjust the background style to match the first part
            // achievementGuideBlock.style.background = 'none'; // Removed to preserve styles

            achievementGuideBlock.innerHTML = createLoadingPlaceholderHtml(); // Show loading

            rightBlocks[0].parentNode.insertBefore(achievementGuideBlock, rightBlocks[0]);

            // Fetch the guide data
            fetchGuide(appId).then((response) => {
                if (response && response.success && Array.isArray(response.data)) {
                    const { data } = response;
                    if (data?.length) {
                        let customText = '';
                        customText = createInfoBoxHtml(data[0]);
                        achievementGuideBlock.innerHTML = customText;
                    } else {
                        throw new Error('No guide data available.');
                    }
                } else {
                    throw new Error(response?.error || 'Invalid data format');
                }
            }).catch((error) => {
                // Show error message
                achievementGuideBlock.innerHTML = createInfoBoxHtml({
                    hideHeader: true,
                    guideLinks: [],
                    infoBoxes: [
                        {
                            label: 'Please update the extension or contact us on <a href="https://discord.gg/t8cBtPAczE" target="_blank" style="color: #fff;">Discord</a>',
                            value: 'STEAM ACHIEVEMENT GUIDE ERROR',
                            distance: -1,
                        },
                    ],
                });
            });
        }
    }

    const extractAppIdFromStoreUrl = (url) => {
        try {
            const parsed = new URL(url);
            if (!/(\.|^)store\.steampowered\.com$/i.test(parsed.hostname)) {
                return null;
            }
            const match = parsed.pathname.match(/\/app\/(\d+)(?:\/|$)/);
            return match ? match[1] : null;
        } catch (error) {
            return null;
        }
    };

    const hoverState = {
        anchor: null,
        appId: null,
        requestId: 0,
        showTimer: null,
        hideTimer: null,
        popup: null,
    };

    const clearHoverTimer = (timerKey) => {
        if (hoverState[timerKey]) {
            clearTimeout(hoverState[timerKey]);
            hoverState[timerKey] = null;
        }
    };

    const hideHoverPopup = () => {
        clearHoverTimer('showTimer');
        clearHoverTimer('hideTimer');
        hoverState.requestId += 1;
        hoverState.anchor = null;
        hoverState.appId = null;
        if (hoverState.popup) {
            hoverState.popup.classList.remove('is-visible');
            hoverState.popup.setAttribute('aria-hidden', 'true');
        }
    };

    const scheduleHidePopup = () => {
        clearHoverTimer('hideTimer');
        hoverState.hideTimer = setTimeout(() => {
            hideHoverPopup();
        }, 140);
    };

    const ensureHoverPopup = () => {
        if (hoverState.popup) {
            return hoverState.popup;
        }
        const popup = document.createElement('div');
        popup.className = 'stg-hover-popup';
        popup.setAttribute('data-stg-hover', 'true');
        popup.setAttribute('aria-hidden', 'true');
        popup.addEventListener('mouseenter', () => {
            clearHoverTimer('hideTimer');
        });
        popup.addEventListener('mouseleave', () => {
            scheduleHidePopup();
        });
        document.body.appendChild(popup);
        hoverState.popup = popup;
        return popup;
    };

    const positionHoverPopup = (popup, anchor) => {
        if (!anchor || !anchor.isConnected) {
            hideHoverPopup();
            return;
        }
        const rect = anchor.getBoundingClientRect();
        const scrollX = window.scrollX || window.pageXOffset || 0;
        const scrollY = window.scrollY || window.pageYOffset || 0;
        const offset = 10;

        popup.style.visibility = 'hidden';
        popup.style.display = 'block';
        popup.style.left = '0px';
        popup.style.top = '0px';

        const popupRect = popup.getBoundingClientRect();
        let left = rect.left + scrollX;
        let top = rect.bottom + offset + scrollY;

        const viewportRight = scrollX + document.documentElement.clientWidth;
        const viewportBottom = scrollY + document.documentElement.clientHeight;

        if (left + popupRect.width + 8 > viewportRight) {
            left = Math.max(scrollX + 8, viewportRight - popupRect.width - 8);
        }
        if (top + popupRect.height + 8 > viewportBottom) {
            top = rect.top - popupRect.height - offset + scrollY;
        }
        if (top < scrollY + 8) {
            top = scrollY + 8;
        }

        popup.style.left = `${Math.max(scrollX + 8, left)}px`;
        popup.style.top = `${top}px`;
        popup.style.visibility = 'visible';
    };

    const showHoverPopup = async (anchor, appId) => {
        if (!subscriptionActive) {
            return;
        }
        const popup = ensureHoverPopup();
        hoverState.anchor = anchor;
        hoverState.appId = appId;
        const requestId = ++hoverState.requestId;

        popup.innerHTML = createLoadingPlaceholderHtml();
        positionHoverPopup(popup, anchor);
        popup.classList.add('is-visible');
        popup.setAttribute('aria-hidden', 'false');

        let response;
        try {
            response = await fetchGuide(appId);
        } catch (error) {
            response = { success: false, error: error?.message || 'Unknown error' };
        }

        if (requestId !== hoverState.requestId || hoverState.anchor !== anchor) {
            return;
        }

        if (response && response.success && Array.isArray(response.data) && response.data.length > 0) {
            popup.innerHTML = createInfoBoxHtml(response.data[0]);
        } else {
            const unauthorized = typeof response?.error === 'string' && response.error.toLowerCase().includes('unauthorized');
            let infoBox = {
                label: 'Please update the extension or contact us on <a href="https://discord.gg/t8cBtPAczE" target="_blank" style="color: #fff;">Discord</a>',
                value: 'STEAM ACHIEVEMENT GUIDE ERROR',
                distance: -1,
            };
            if (unauthorized) {
                infoBox = {
                    label: 'Subscribe to <a href="https://patreon.com/jansivans" target="_blank" style="color: #fff;">Patreon</a> or <a href="https://buymeacoffee.com/jansivans" target="_blank" style="color: #fff;">Buy Me a Coffee</a> to access the guide for this game on hover',
                    value: 'STEAM ACHIEVEMENT GUIDE SUBSCRIPTION REQUIRED',
                    distance: -1,
                };
            }
            popup.innerHTML = createInfoBoxHtml({
                guideLinks: [],
                infoBoxes: [infoBox],
            });
        }

        positionHoverPopup(popup, anchor);
        popup.classList.add('is-visible');
        popup.setAttribute('aria-hidden', 'false');
    };

    const scheduleShowPopup = (anchor, appId) => {
        clearHoverTimer('showTimer');
        hoverState.showTimer = setTimeout(() => {
            showHoverPopup(anchor, appId);
        }, 140);
    };

    const hoverDisabledByPage = Boolean(wishlistMatch || gamesPageMatch);

    if (!options.disableOnHover && !hoverDisabledByPage) {
        const shouldIgnoreTarget = (target) => !!(hoverState.popup && hoverState.popup.contains(target));

        const handlePointerOver = (event) => {
            if (!subscriptionActive) {
                return;
            }
            const target = event.target;
            if (!(target instanceof Element) || shouldIgnoreTarget(target)) {
                return;
            }
            const link = target.closest('a[href]');
            if (!link) {
                return;
            }
            const hoveredAppId = extractAppIdFromStoreUrl(link.href);
            if (!hoveredAppId) {
                return;
            }
            if (appId && hoveredAppId === appId) {
                return;
            }
            if (hoverState.anchor === link && hoverState.popup && hoverState.popup.classList.contains('is-visible')) {
                return;
            }
            clearHoverTimer('hideTimer');
            scheduleShowPopup(link, hoveredAppId);
        };

        const handlePointerOut = (event) => {
            const target = event.target;
            if (!(target instanceof Element) || shouldIgnoreTarget(target)) {
                return;
            }
            const link = target.closest('a[href]');
            if (!link || hoverState.anchor !== link) {
                clearHoverTimer('showTimer');
                return;
            }
            const related = event.relatedTarget;
            if (related && (link.contains(related) || (hoverState.popup && hoverState.popup.contains(related)))) {
                return;
            }
            clearHoverTimer('showTimer');
            scheduleHidePopup();
        };

        document.addEventListener('mouseover', handlePointerOver);
        document.addEventListener('mouseout', handlePointerOut);
        window.addEventListener('blur', hideHoverPopup);
        window.addEventListener('resize', () => {
            if (hoverState.popup && hoverState.popup.classList.contains('is-visible') && hoverState.anchor) {
                positionHoverPopup(hoverState.popup, hoverState.anchor);
            }
        });
    }
})();
