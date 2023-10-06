<?php

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
 * This file contains the static class of the Prayer request widget.
 */

namespace WIDGETS;

class PrayerrequestWidget {
    // Static variable to keep track of the widget instances
    static int $widgetInstance = 0;
    
    // Static method to generate and render the widget
    static function make(): void {
        // Check if this is the first instance of the widget
        if (self::$widgetInstance === 0) {
            // Include the CSS file for the widget
            echo '<link rel="stylesheet" type="text/css" '
                . 'href="include/widgets/prayerrequest/view/css/index.css">';
            // Include the JS file for the widget
            echo '<script src="include/widgets/prayerrequest/view/js/index.js"></script>';
        }

        // Load and output the HTML template for the widget
        echo file_get_contents(__DIR__ . '/view/index.html');

        // Increment the widget instance counter for the next widget
        self::$widgetInstance++;
    }
}