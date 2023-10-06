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
 * This file contains all the Youversion widget specific JS used by the Youversion widget.
 */

// Wait for the page to fully load before executing the code
window.addEventListener('load', async function() {
    // Select all elements with class "youVersionContainer"
    const youversionContainers = document.querySelectorAll('.youVersionContainer');

    // Check if there are any elements with the class "youVersionContainer"
    if (youversionContainers.length > 0) {
        // Make an asynchronous request to fetch YouVersion plan data
        const res = await d.f("hackathon_getYouVersionPlan", {}, true);
        
        // Check if the response was successful
        if (res.s) {
            // Iterate through each "youVersionContainer" element
            for (let container of youversionContainers) {
                // Find the element with class "youVersionImage" within the container
                const youVersionImage = container.querySelector('.youVersionImage');
                
                // Check if the "youVersionImage" element exists
                if (youVersionImage) {
                    // Set the source and opacity of the "youVersionImage" element
                    youVersionImage.src = res.p.image;
                    youVersionImage.style.opacity = 1;
                }

                // Find the element with class "youVersionTitle" within the container
                const youVersionTitle = container.querySelector('.youVersionTitle');
                
                // Check if the "youVersionTitle" element exists
                if (youVersionTitle) {
                    // Set the inner HTML of the "youVersionTitle" element to the fetched title
                    youVersionTitle.innerHTML = res.p.title + ' - ';
                }

                // Find the element with class "youVersionIntro" within the container
                const youVersionIntro = container.querySelector('.youVersionIntro');
                
                // Check if the "youVersionIntro" element exists
                if (youVersionIntro) {
                    // Set the inner HTML of the "youVersionIntro" element to the fetched intro
                    youVersionIntro.innerHTML = res.p.intro;
                }

                // Find the element with class "youVersionLinkToPlan" within the container
                const youVersionLinkToPlan = container.querySelector('.youVersionLinkToPlan');
                
                // Check if the "youVersionLinkToPlan" element exists
                if (youVersionLinkToPlan) {
                    // Set the href and pointer events of the "youVersionLinkToPlan" element
                    youVersionLinkToPlan.href = res.p.url;
                    youVersionLinkToPlan.style.pointerEvents = 'auto';
                }
            }
        }
    }
});