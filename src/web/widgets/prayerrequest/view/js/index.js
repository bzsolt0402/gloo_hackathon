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
 * This file contains all the Prayer request widget specific JS used by the Prayer request widget.
 */

// Define delays in milliseconds
const delayOfStartShowingNextPrayerRequest = 200;
const delayOfShowingNextPrayerRequest = 100; 

// Define task names for different role types
const taskNames = { 
    'light' : {
        'add'    : "hackathon_addLightPrayerRequest",
        'delete' : "hackathon_deleteLightPrayerRequest",
        'edit'   : "hackathon_editLightPrayerRequest",
        'load'   : "hackathon_getLightPrayerRequests",
        'set'    : "hackathon_setIfLightPrayerRequestIsAnswered",
    },
    'church' : {
        'add'    : "hackathon_addOrgPrayerRequest",
        'delete' : "hackathon_deleteOrgPrayerRequest",
        'edit'   : "hackathon_editOrgPrayerRequest",
        'load'   : "hackathon_getOrgPrayerRequests",
        'set'    : "hackathon_setIfOrgPrayerRequestIsAnswered",
    },
};


// Wait for the page to fully load before executing the code
window.addEventListener('load', async function() {
    // Select all elements with the class 'prayerRequestWidget'
    const prayerRequestWidgets = document.querySelectorAll('.prayerRequestWidget');
    
    if (prayerRequestWidgets.length > 0) {
        // Fetch data asynchronously based on the 'pagetype'
        const res = await d.f(taskNames[d._GET['pagetype']].load, {}, true);
        
        if (res.s) {
            // Loop through each 'prayerRequestWidget' element
            for (let widget of prayerRequestWidgets) {                
                // Assign DOM elements within the widget to variables
                widget.container = widget.querySelector('.prayerRequestContainer');
                widget.placeHolder = widget.container.querySelector('.prayerRequestPlaceholder');
                widget.addPrayerRequest = widget.querySelector('.addPrayerRequestContainer');
                
                if (widget.container && widget.placeHolder) {                   
                    // Remove the placeholder and initialize variables
                    widget.container.removeChild(widget.placeHolder);
                    widget.container.totalHeight = 0;
                    widget.container.numberOfPrayerRequests = 0;

                    // Iterate through fetched data and display prayer requests
                    for (let i = 0; i < res.p.length; i++) {
                        setTimeout(() => {
                            // Display each prayer request with a delay
                            displayPrayerRequest(widget, res.p[i], 'after')
                        }, i * delayOfStartShowingNextPrayerRequest);
                    }
                    
                    if (widget.addPrayerRequest) {
                        // Handle the functionality to add a new prayer request
                        widget.addPrayerRequestForm = widget.addPrayerRequest.querySelector('form')
                        widget.addPrayerRequestTextarea = 
                            widget.addPrayerRequest.querySelector('textarea');
                        widget.addPrayerRequestButton = 
                            widget.addPrayerRequest.querySelector('.filledButton');
                        
                        // Add a click event listener to the 'Add' button
                        widget.addPrayerRequestButton.addEventListener('click', async function() {
                            if (widget.addPrayerRequestForm.checkValidity()) {
                                // Get the prayer request text and clear the input field
                                const prayerRequest = widget.addPrayerRequestTextarea.value;
                                widget.addPrayerRequestTextarea.value = '';

                                // Send a request to add the prayer request and handle the response
                                const res = await d.f(taskNames[d._GET['pagetype']].add,
                                    { prayerRequest: prayerRequest }, true);

                                if (res.s) {
                                    // Create an object with prayer request data and display it
                                    const result = {
                                        'id' : res.p.id,
                                        'added' : Math.floor(Date.now() / 1000),
                                        'answered' : 0,
                                        'prayer_request' : prayerRequest,
                                    }

                                    // Display the new prayer request before existing ones
                                    displayPrayerRequest(widget, result, 'before');
                                }
                            } else {
                                // Display form validation errors if the input is invalid
                                widget.addPrayerRequestForm.reportValidity();
                            }
                        });
                    }
                    
                    // Add a click event listener to the container for handling interactions
                    widget.container.addEventListener('click', prayerRequestClickHandler);
                }
            }
        } 
    }
});


// Function to handle clicks on prayer request buttons
function prayerRequestClickHandler(event) {    
    let button;
    
    // Check if the clicked element has the 'textButton' class
    if (event.target.classList.contains('textButton')) {
        button = event.target;
    } else {
        // If not, find the closest ancestor with the 'textButton' class
        button = event.target.closest('.textButton');
    }
    
    // If no appropriate button is found, exit the function
    if (!button) {
        return;
    }
    
    // If the found element has the 'textButton' class, assign container and card properties
    if (button.classList.contains('textButton')) {
        button.container = this;
        button.card = button.closest('.prayerRequestCard');
    }
    
    // Determine the action based on the class of the clicked button
    if (button.classList.contains('js-setPrayerRequestAsAnswered')) {
        // Handle setting the prayer request as answered
        setIfPrayerRequestIsAnswered(button);  
    } else if (button.classList.contains('js-setPrayerRequestAsDeleted')) {
        // Display a confirmation popup before deleting the prayer request
        popup = new d.Popup(d.popup.sizes.SMALL, true);
        popup.showHeader('Are you sure?');
        popup.okButton('Delete', deletePrayerRequest.bind(button));
        popup.open();
    } else if (button.classList.contains('js-editPrayerRequest')) {
        // Show the edit prayer request form
        showEditPrayerRequestForm(button);
    } else if (button.classList.contains('js-cancelEditingPrayerRequest')) {
        // Hide the edit prayer request form
        hideEditPrayerRequestForm(button);
    } else if (button.classList.contains('js-savePrayerRequest')) {
        // Save the edited prayer request
        savePrayerRequest(button);
    }
}


// Function to save an edited prayer request
function savePrayerRequest(button) {
    // Find the textarea within the card
    const editTextArea = button.card.querySelector('textarea');
    const editForm = button.card.querySelector('form');
    
    if (editForm.checkValidity()) {
        // Update the displayed prayer request text with the edited content
        button.card.querySelector('.prayerRequestText').textContent = editTextArea.value;

        // Save the edited prayer request to the database
        const res = d.f(taskNames[d._GET['pagetype']].edit, {
            id: parseInt(button.dataset.id, 10),
            newPrayerRequest: editTextArea.value,
        }, true);

        // Hide the edit prayer request form after saving
        hideEditPrayerRequestForm(button);
    } else {
        editForm.reportValidity();
    }
}


// Function to hide the edit prayer request form
function hideEditPrayerRequestForm(button) {
    // Adjust the container height by subtracting the card's height
    button.container.totalHeight -= button.card.offsetHeight;
    
    // Find the edit textarea and the text container within the card
    const editForm = button.card.querySelector('form');
    const textContainer = button.card.querySelector('.prayerRequestText');
    
    // Display the original prayer request text and remove the edit textarea
    textContainer.style.display = 'block';
    editForm.remove();
    
    // Show hidden buttons for interaction and hide edit buttons
    button.card.querySelectorAll('.hiddenButton').forEach(button => {
        button.style.display = 'flex';
    });
    
    button.card.querySelectorAll('.editButton').forEach(button => {
        button.style.display = 'none';
    });
    
    // Adjust the container height to reflect the changes
    button.container.totalHeight += button.card.offsetHeight;
    button.container.style.height = button.container.totalHeight + 'px';
}


// Function to show the edit prayer request form
function showEditPrayerRequestForm(button) {
    // Adjust the container height by subtracting the card's height
    button.container.totalHeight -= button.card.offsetHeight;
    
    // Find the text container and create an edit textarea with its content
    const textContainer = button.card.querySelector('.prayerRequestText');
    const editForm = document.createElement("form");
    editForm.classList.add('noMargin');
    
    const editTextArea = document.createElement("textarea");
    editTextArea.classList.add('prayerRequestFormTextarea', 'ninetyMinHeight');
    editTextArea.value = textContainer.textContent;
    editTextArea.required = true;
    editTextArea.setAttribute('minlength', '2');
    editTextArea.setAttribute('maxlength', '8096');
    editForm.appendChild(editTextArea);
    
    textContainer.style.display = 'none';
    
    // Insert the edit textarea before the text container
    textContainer.parentNode.prepend(editForm);
    
    // Hide hidden buttons and show edit buttons for interaction
    button.card.querySelectorAll('.hiddenButton').forEach(button => {
        button.style.display = 'none';
    });
    
    button.card.querySelectorAll('.editButton').forEach(button => {
        button.style.display = 'flex';
    });
    
    // Adjust the container height to reflect the changes
    button.container.totalHeight += button.card.offsetHeight;
    button.container.style.height = button.container.totalHeight + 'px';
}


// Function to delete a prayer request
function deletePrayerRequest() {
    // Adjust the total height of the container by subtracting the card's height
    this.container.totalHeight -= this.card.offsetHeight;
    
    // Set the card's maximum height to its scroll height to initiate the collapse animation
    this.card.style.maxHeight = this.card.scrollHeight + "px"; 
    
    // After a slight delay, remove the 'showClone' class and collapse the card
    setTimeout(() => {
        this.card.classList.remove('showClone');
        this.card.style.maxHeight = 0;
        this.card.style.overflow = 'hidden';
        
        // If there are more than one prayer requests, adjust the margin and container height
        if (this.container.numberOfPrayerRequests !== 1) { 
            const gap = parseInt(window.getComputedStyle(this.container).getPropertyValue('gap'), 
                            10);
            this.card.style.marginTop = -gap + "px";
            this.container.totalHeight -= gap;
        }
        
        // Update the container's height and decrease the number of prayer requests
        this.container.style.height = this.container.totalHeight + 'px';
        this.container.numberOfPrayerRequests--;
    }, 10);
    
    // Close any open popup dialog
    popup.close();
    
    // Save the deletion action to the database
    const res = d.f(taskNames[d._GET['pagetype']].delete, {
        id: parseInt(this.dataset.id, 10) 
    }, true);
}


// Function to mark a prayer request as answered or unanswered
function setIfPrayerRequestIsAnswered(button) {
    // Toggle card and button styles based on the current state
    if (button.card.classList.contains('filledCard-green')) {
        // Set the card and button to 'grey' (unanswered) style
        button.card.classList.add('filledCard-grey');
        button.card.classList.remove('filledCard-green');
        button.classList.add('textButton-grey', 'textButton-greyAlphaText');
        button.classList.remove('textButton-green');
    } else {
        // Set the card and button to 'green' (answered) style
        button.card.classList.add('filledCard-green');
        button.card.classList.remove('filledCard-grey');
        button.classList.add('textButton-green');
        button.classList.remove('textButton-greyAlphaText', 'textButton-grey');
    }
    
    // Save the updated answered state to the database
    const res = d.f(taskNames[d._GET['pagetype']].set, {
        answeredState: button.card.classList.contains('filledCard-green'), 
        id: parseInt(button.dataset.id, 10),
    }, true);
}


// Function to display a prayer request within a widget
function displayPrayerRequest(widget, result, placement = 'after') {
    // Clone the placeholder element within the widget
    const clone = widget.placeHolder.cloneNode(true);
    
    // Set the prayer request text and date based on the provided 'result'
    const textContainer = clone.querySelector('.prayerRequestText');
    textContainer.classList.add('breakSpaces');
    textContainer.innerHTML = result.prayer_request;    
    clone.querySelector('.prayerRequestDate').textContent = 
            (new Date(result.added * 1000)).toLocaleString('en-US', d.DATE_FORMAT);
    
    // Apply styles based on whether the prayer request is answered
    if (result.answered) {
        clone.classList.add('filledCard-green');
        clone.classList.remove('filledCard-grey');
    }
    
    // Remove any shown buttons from the clone
    clone.querySelectorAll('.shownButton').forEach(button => {
        button.remove();
    });
    
    // Configure hidden buttons, update styles, and set data attributes
    clone.querySelectorAll('.hiddenButton').forEach(button => {
        if (result.answered && button.classList.contains('js-setPrayerRequestAsAnswered')) {
            // If answered, set the button to green style
            button.classList.add('textButton-green');
            button.classList.remove('textButton-grey', 'textButton-greyAlphaText');
        }
        button.style.display = 'flex';
        button.dataset.id = result.id;
    });    
    
    // Set data attributes for edit buttons
    clone.querySelectorAll('.editButton').forEach(button => {
        button.dataset.id = result.id;
    });
    
    // Add the 'hiddenClone' class to the clone element
    clone.classList.add('hiddenClone');

    // Determine where to place the clone based on 'placement' parameter
    if (placement === 'before') {
        widget.container.prepend(clone);        
    } else { // after
        widget.container.appendChild(clone);           
    }
     
    // Update the total height of the widget container
    widget.container.totalHeight += clone.offsetHeight;
    
    // Include gap if there are multiple prayer requests
    if (widget.container.numberOfPrayerRequests > 0) {
        widget.container.totalHeight += 
            parseInt(window.getComputedStyle(clone.parentElement).getPropertyValue('gap'), 10);
    }
    
    // Set the container's height to match the updated total height
    widget.container.style.height = widget.container.totalHeight + 'px';
    
    // Increment the number of prayer requests within the widget
    widget.container.numberOfPrayerRequests++;

    // Add a delay to show the clone element for a smoother effect
    setTimeout(() => {
        clone.classList.add('showClone');
    }, delayOfShowingNextPrayerRequest);
}