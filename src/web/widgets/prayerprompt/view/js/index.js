/**
 * Code written for:
 *
 * 
 *                              ████
 *                              ████
 *                              ████
 *                              ████
 *                              ████
 *             ███████  ████    ████         ████████              ████████
 *           ███████████████    ████      ██████████████        ██████████████
 *         ████        █████    ████     ████        ████      ████        ████
 *        ████          ████    ████    ████          ████    ████          ████
 *         ████        █████    ████     ████        ████      ████        ████
 *          ████████████████    ████      ██████████████        ██████████████
 *             ███████  ████    ████         ████████              ████████
 *                      ████ 
 *                    █████ 
 *                 ██████    
 * 
 *                                                     AI & the Church Hackathon
 * 
 * 
 * @license The judging committee of the 2023 AI & the Church Hackathon, organized by Gloo LLC,
 * has the permission to use, review, assess, test, and otherwise analyze this file in connection 
 * with said Hackathon.
 * 
 * This file contains all the Prayer prompt widget specific JS used by the Prayer prompt widget.
 */

// Wait for the page to fully load before executing the code
window.addEventListener('load', async function() {
    // Select all elements with class "prayerPromptContainer"
    const prayerPromptContainers = document.querySelectorAll('.prayerPromptContainer');
        
    // Check if there are any elements with the class "prayerPromptContainer"
    if (prayerPromptContainers.length > 0) {
        // Make an asynchronous request to fetch prayer prompt data
        const res = await d.f("hackathon_getPrayerPrompt", {}, true);
        
        // Check if the response was successful
        if (res.s) {
            // Iterate through each "prayerPromptContainer" element
            for (let container of prayerPromptContainers) {
                // Find the element with class "prayerPromptText" within the container
                const prayerPromptText = container.querySelector('.prayerPromptText');
                
                // Check if the "prayerPromptText" element exists
                if (prayerPromptText) {
                    // Set the inner HTML of the "prayerPromptText" element to the fetched prayer prompt
                    prayerPromptText.innerHTML = res.p.prayerPrompt;
                }
            }
        }
    }
});
