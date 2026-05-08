const serverUrl = 'https://steam-achievement-guide.onrender.com';
// const serverUrl = 'http://localhost:3000';

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'fetchGuide') {
        const { appId, extensionVersion } = message;
        (async () => {
            try {
                const response = await fetch(`${serverUrl}/guide?appId=${appId}&extensionVersion=${extensionVersion}`);
                const result = await response.json();
                if (response.status !== 200) {
                    sendResponse({ success: false, error: result });
                } else {
                    const data = Array.isArray(result.data) ? result.data : [];
                    sendResponse({ success: true, data });
                }
            } catch (error) {
                sendResponse({ success: false, error: error.message });
            }
        })();
        return true;
    } else if (message.type === 'submitGuide') {
        const { appId, content } = message;
        (async () => {
            try {
                const response = await fetch(`${serverUrl}/submit-guide`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ appId, content }),
                });
                if (response.ok) {
                    sendResponse({ success: true });
                } else {
                    sendResponse({ success: false, error: 'Failed to submit guide' });
                }
            } catch (error) {
                sendResponse({ success: false, error: error.message });
            }
        })();
        return true;
    } else if (message.type === 'checkSubscription') {
        const { token } = message;
        (async () => {
            try {
                const response = await fetch(`${serverUrl}/check-subscription?token=${token}`);
                const result = await response.json();
                if (response.status !== 200) {
                    sendResponse({ success: false, error: result });
                } else {
                    sendResponse({ success: true, data: result.data });
                }
            } catch (error) {
                sendResponse({ success: false, error: error.message });
            }
        })();
        return true;
    }
});