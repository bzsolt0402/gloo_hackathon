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
 * This file contains all the Sermon widget specific JS used by the Sermon widget.
 */

// Wait for the page to fully load before executing the code
window.addEventListener('load', async function() {
    // Query all elements with class "sermonContainer" and store them in an array-like NodeList
    const sermonContainers = document.querySelectorAll('.sermonContainer');

    // Check if there are any sermon containers on the page
    if (sermonContainers.length > 0) {
        // Make an asynchronous request to fetch sermon data
        const res = await d.f("hackathon_getSermonSummary", {}, true);

        // Check if the response was successful
        if (res.s) {
            // Get the number of sermon themes
            const numberOfThemes = res.p.sermon.selectedThemes.length;

            // Iterate through each sermon container
            for (let container of sermonContainers) {
                // Create a wrapper element for each container
                const wrapper = document.createElement("div");
                wrapper.className = "sermonWrapper";

                // Create a paragraph element for the sermon content
                const sermonContent = document.createElement("p");
                sermonContent.className = "sermonContent";

                // Create an array to hold the sermon buttons
                const sermonButtons = [];

                // Iterate through each theme
                for (let i = 0; i < numberOfThemes; i++) {
                    // Create a button element for each theme
                    const sermonButton = document.createElement("div");
                    sermonButton.className = "filledTonalButton";
                    sermonButton.textContent = res.p.sermon.selectedThemes[i];
                    sermonButton.sermonContent = res.p.sermon.sermonNotes[i];

                    // Add "active" class to the first button and set the initial sermon content
                    if (i === 0) {
                        sermonButton.classList.add("active");
                        sermonContent.innerHTML = sermonButton.sermonContent;
                    }

                    // Add a click event listener to each button
                    sermonButton.addEventListener('click', function() {
                        // Remove "active" class from all buttons
                        for (let btn of sermonButtons) {
                            btn.classList.remove("active");
                        }

                        // Add "active" class to the clicked button and update sermon content
                        this.classList.add("active");
                        sermonContent.innerHTML = this.sermonContent;
                    });

                    // Push the button to the sermonButtons array
                    sermonButtons.push(sermonButton);

                    // Append the button to the wrapper
                    wrapper.appendChild(sermonButton);
                }

                // Append the wrapper and sermon content to the current container
                container.appendChild(wrapper);
                container.appendChild(sermonContent);
            }
        }
    }
});