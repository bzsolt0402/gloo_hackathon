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
 * This file includes code for automatic data generation using cronjobs.
 * It runs every hour to ensure that before 1:00AM all the required data will be generated. 
 * When the callback is called, it generates AI based prayer prompts, sermon notes
 * and YouVersion Plans for every role that meets the criteria.
 */

'use strict'

import { didCronJobAlreadyRunToday, saveCronJobDone } from "./dao.js";
import * as functions from "./functions.js"

/**
 * Starts a cronjob for generating prayer prompts, sermon notes, youversion recommendations
 * at the approximate start of every day.
 * It is necessary to generate them because generations take a long time, and we don't want users
 * to wait 30-40 seconds for their prayer prompt when opening the dashboard.
 * @param job
 */
export async function initCronJobs(): Promise<void> {
	setInterval((): void => {
		generatePersonalPrayerPrompt("light_prayer_prompts");
		generateSermonNotes("church_sermon_notes");
		generateDailyYouVersionPlan("youversion_recommendations");
	}, 1000 * 60 * 60);
}

/**
 *  
 * It is the cronjob for generating prayer prompts.
 * @returns
 */
async function generatePersonalPrayerPrompt(
	job: string
): Promise<void> {
	const didTheCronRunToday = await didCronJobAlreadyRunToday(job);
	if (!didTheCronRunToday) {
		await functions.generatePersonalPrayerPromptForActiveLights();
	}
	saveCronJobDone(job);
}

/**
 *  
 * It is the cronjob for generating sermon notes.
 * @returns
 */
async function generateSermonNotes(
	job: string
): Promise<void> {
	const didTheCronRunToday = await didCronJobAlreadyRunToday(job);
	if (!didTheCronRunToday) {
		await functions.generateDailySermonNoteForActiveChurches();
	}
	saveCronJobDone(job);
}

/**
 *  
 * It is the cronjob for generating youversion recommendations.
 * @returns
 */
async function generateDailyYouVersionPlan(
	job: string
): Promise<void> {
	const didTheCronRunToday = await didCronJobAlreadyRunToday(job);
	if (!didTheCronRunToday) {
		await functions.generateDailyYouVersionPlanForAllActiveLights();
	}
	saveCronJobDone(job);
}