let dfoApi = window.parent.cxone.chat.call;
if (!dfoApi) {
    console.log("cxone is not loaded, falling back to legacy brandembassy");
    dfoApi = window.parent.brandembassy;
    if (!dfoApi) {
        throw new Error("Brandembassy is not loaded");
    }
}

if (!window.parent.Surfly) {
    throw new Error("Surfly is not loaded");
}

dfoApi("setAllowedExternalMessageTypes", ["MESSAGE_RECEIVED", "CHAT_SESSION_RECOVERED"]);

// Custom fields will break chat initialization if they are not configured in NICE settings
// We use query parameters as feature flags, so we can keep backward compatibility
const scriptSrc = new URL(document.currentScript.src);
const urlParams = new URLSearchParams(scriptSrc.search);
const customFields = urlParams.getAll("customField");

if (customFields.includes("_surfly_cc_language")) {
    try {
        // We change the language here, as we don't have access to widget's initialization
        const languageCode = navigator.language.slice(0, 2);
        if (window.parent.Surfly._fetchTranslation) {
            window.parent.Surfly._fetchTranslation(languageCode);
        } else {
            // We wait for the Surfly to be initialized
            const intervalID = setInterval(() => {
                if (window.parent.Surfly._fetchTranslation) {
                    clearInterval(intervalID);
                    window.parent.Surfly._fetchTranslation(languageCode);
                }
            }, 1000);
        }
    } catch (e) {
        console.error("Error while setting the language: ", e);
    }
}

function setCustomFields() {
    dfoApi("setCustomField", "_surfly_cc_url", window.top.location.href);

    if (customFields.includes("_surfly_cc_language")) {
        dfoApi("setCustomField", "_surfly_cc_language", navigator.language);
    }
}

// We need to set the custom fields on the first load. this is for the cases when
// no chat message is sent by the end user. by chat message, we mean a message sent by the end user or the agent
// not the system messages like "begin conversation"
// FYI when the end user sends a chat message, an `SendMessage` event is sent through websockets along with the custom fields
// FYI when custom field is set, starting a chat (by filling up the name and hitting "Begin Conversation")
// sends an `SendMessage` event. if the custom fields are not set, the `SendMessage` event will not be sent
setCustomFields();

window.parent.addEventListener("message", (message) => {
    if (message.origin === window.top.location.origin) {
        NICEventHandler(message);
    }
});

function NICEventHandler(message) {
  console.log(message);
    if (message.data.actionType !== "MESSAGE_RECEIVED") {
        return;
    }
    // Setting the custom fields on every sent/received chat message is necessary because:
    //   1. when the user ends the chat and starts a new one which a new thread is created on NIC so the custom fields are not set
    //   2. the real time value of the custom fields is available. for instance, when the website is an SPA and the user navigates to a new page
    setCustomFields();

    var payload = message.data.action?.payload;
    if (payload?.postback === undefined) {
        return;
    }

    try {
        var data = JSON.parse(payload.postback);
    } catch (e) {
        return;
    }

    var leaderLink = data.leaderLink;
    if (!leaderLink) {
        return;
    }

    // If widget_key is set, the JS API will try to find the session across the sessions of the company which owns that widget_key
    // so we unset the widget_key to prevent that
    window.parent.Surfly.settings.widget_key = "";
    // We don't want the user to be able to close the session by clicking outside of the iframe
    window.parent.Surfly._sessionStartModal._ignore_clickout = true;
    console.log("Starting the session");
    window.parent.Surfly.session(null, leaderLink, null)
        .on("error", function (reason) {
            console.error("Error while starting the session: ", reason);
            window.top.location.href = leaderLink;
        })
        .on("session_started", function (session, event) {
            const callback = (mutationsList, observer) => {
                for (const mutation of mutationsList) {
                    for (const node of mutation.addedNodes) {
                        if (node.dataset?.cy === "closed-session") {
                            window.parent.document.getElementById("surfly-iframe").remove();
                            observer.disconnect();
                            return;
                        }
                    }
                }
            };
            const observer = new MutationObserver(callback);
            observer.observe(document, { childList: true, subtree: true });

            var chat_iframe = window.parent.document.getElementById("be-frame");
            var chat_iframe_zIndex = getComputedStyle(chat_iframe).zIndex;
            var surfly_iframe = window.parent.document.getElementById("surfly-iframe");
            surfly_iframe.style.zIndex = chat_iframe_zIndex - 1;
        })
        .startLeader();
}
