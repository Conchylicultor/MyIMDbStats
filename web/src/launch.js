// On click
chrome.browserAction.onClicked.addListener(function(wtf) {
    // Gets all previous tab
    chrome.tabs.query({'url':chrome.extension.getURL('index.html')}, function(tabs) {
        // Remove doublons
        /*for(var i = 0 ; i < tabs.length ; ++i)
        {
            chrome.tabs.remove(tabs[i]['id']);
        }*/
        
        // Open the new tab
        chrome.tabs.create({'url': chrome.extension.getURL('index.html')}, function(tab) {
            // Tab opened
        });
    });
});
