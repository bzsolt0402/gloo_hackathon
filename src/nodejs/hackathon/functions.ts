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
 * This file includes code for API tasks and data generation. Some of them are very simple, others
 * are more complex to produce the required data structure for the clients.
 */

'use strict'

import * as dao from "./dao.js";
import { OPENAI } from "./tasks.js";
import { createHash } from 'crypto';
import { ChatCompletionCreateParamsNonStreaming } from "openai/resources/chat/index.js";
import { getPrimaryChurchOfLight } from "../prayer_list/dao.js";
import { logIntoFile } from "../../utils.js";
import { ENVIRONMENT } from "../../api/config.js";

/**
 * Generates 3 sermon notes based on the prayer requests of the lights of the church.
 * If there are no requests, returns.
 * @returns
 */
async function generateSermonNote(orgId: number): Promise<void> {
	// Getting the data for generation.
	const requests = await dao.getOrgsLightsRequests(orgId, 0);
	if (requests.length === 0) {
		// Quick return if there is no data to generate sermon from.
		return;
	}
	// Generate the sermon themes.
	const sermonObj = await openAISermonGenerator(requests);
	if (sermonObj) {
		await dao.saveSermonNote(orgId, JSON.stringify(sermonObj));
	}
}

/**
 * This is a 2 part function. 
 * Firstly, it uses AI to sort the unanswered prayer requests into common themes, 
 * and selects the 3 most important themes.
 * Secondly, it loops on the themes, and generates a sermon note for each theme incorporating
 * the prayer requests relevant to that theme. After that, it returns the data in a usable form.
 * If any of the AI generation fails due to some error (e.g. The prompt contained too many tokens)
 * it returns with null.
 * @returns
 */
async function openAISermonGenerator(
	requests: Array<string>
): Promise<{ selectedThemes: Array<string>, sermonNotes: Array<string> } | null> {
	const requestsString = `"""${requests.join(" | ")}"""`;

	// Creating and saving the prompt into a variable for logging.
	const prompt =
		"Prayer requests from the Christian church's congregation follow in triple quotation marks. " +
		"Individual prayer requests are delimited with a | (pipe character)." + "\n" +
		requestsString + "\n" +
		"Follow these steps and only answer with one JSON string:\n" +
		"Step 1 - Create a JSON object with the following properties: \"themes\", \"selectedThemes\".\n" +
		"Step 2 - Identify individual prayer requests.\n" +
		"Step 3 - Group the prayer requests into common themes and place the themes in the \"themes\"" +
		"property of the JSON. " + "Each theme should be an array comprising of prayer requests.\n" +
		"Step 4 - Select the 3 most important themes and list them in an array." +
		"Put the array in the \"selectedThemes\" property.\n";

	// Creating the themes.
	const chatCompletionStepOne = await createChatCompletion({
		userPrompt: prompt,
		logFileName: "sermonLog"
	});

	if (!chatCompletionStepOne?.choices[0].message.content) {
		// Quick return if OpenAI respond with null content.
		return null;
	}

	// Since we told the AI to generate a JSON object, we can parse the answer to be a JSON object.
	const parsedStepOneContent = JSON.parse(chatCompletionStepOne.choices[0].message.content);
	const selectedThemes = [];
	const stepTwoContents = [];

	// Looping through the 3 selected themes and generating a sermon note for each.
	for (let i = 0; i < parsedStepOneContent.selectedThemes.length; i++) {
		const currentTheme = parsedStepOneContent.selectedThemes[i];
		const stepTwoPromptBegin = "Create sermon notes for a Christian evangelist pastor. " +
			"The topic is \"" + currentTheme + "\" such as these listed within triple quotation marks: \n" +
			'"""\n';
		const includeScriptureReference = "Include scripture references about \"" +
			currentTheme + "\".";
		const prompt = stepTwoPromptBegin +
			parsedStepOneContent.themes[currentTheme].join(',\n') +
			'"""\n' +
			"List talking points only.\n" +
			includeScriptureReference;

		// Creating the sermon note.
		const chatCompletionStepTwo = await createChatCompletion({
			userPrompt: prompt,
			logFileName: "sermonLog"
		});
		if (!chatCompletionStepTwo?.choices[0].message.content) {
			continue;
		}
		stepTwoContents.push(chatCompletionStepTwo.choices[0].message.content!);
		selectedThemes.push(parsedStepOneContent.selectedThemes[i]);
	}
	// If all 3 sermon note generation failed, we return with null.
	if (stepTwoContents.length === 0) {
		return null;
	}
	// Otherwise we return with the themes and the sermon notes for the themes.
	return {
		selectedThemes: selectedThemes,
		sermonNotes: stepTwoContents,
	};
}

/**
 * This function generates an AI response based on the received system and user prompts.
 * @param options - Options for chat completion.
 * @param options.systemPrompt - A system-level prompt that sets the context or behavior for the AI's responses.
 * @param options.userPrompt - The user's input or query prompt that the AI will respond to.
 * @param options.logFileName - The name of the log file where the request and response data will be saved. (optional)
 * @returns A Promise that resolves to a chat completion response from the GPT-3.5 Turbo model.
 */
async function createChatCompletion({
	systemPrompt = "",
	userPrompt = "",
	logFileName,
}: {
	systemPrompt?: string,
	userPrompt?: string,
	logFileName?: string,
}) {

	// Prepare chat settings for AI completion
	const chatSettings: ChatCompletionCreateParamsNonStreaming = {
		messages: [
			{ // Pre-defined settings on how the AI should act when receiving a prompt.
				role: "system",
				content: systemPrompt,
			},
			{ // This is where the AI gets the prompt created from the data.
				role: "user",
				content: userPrompt,
			},
		],
		model: 'gpt-3.5-turbo',
		temperature: 0.0,
	};
	/** 
	 * There could be errors with the OpenAI API where we can't get a response.
	 * This try-catch allows us to not crash the server if that happens, and we
	 * can log the error so we can learn what prompt caused the error. 
	 */
	try {
		const chatCompletion = await OPENAI.chat.completions.create(chatSettings);
		// Log the request and response data to a file if a file name to log into is provided.
		if (logFileName) {
			logIntoFile(
				{ request: chatSettings, response: chatCompletion },
				`${ENVIRONMENT.commonPath}log/`,
				logFileName,
			);
		}
		// Return the chat completion response.
		return chatCompletion;
	} catch (error) {

		// Logging the prompt and the error.
		logIntoFile(
			{ request: chatSettings, error: error },
			`${ENVIRONMENT.commonPath}log/`,
			"errorlog",
		);
		return null;
	}
}

/**
 * Gets the data for the generation, formats it and calls the generator function.
 * After generation, it saves the generated prayer prompt into the database.
 * If there are no data to generate from, we short circuit before the generation starts.
 * @returns
 */
export async function generatePersonalPrayerPrompt(
	lightId: number,
): Promise<void> {
	// Getting the data for generation.
	const prayerPromptDataForGeneration = await getRequestsAndNotesForPrayerPromptGeneration(lightId);

	// If there are no requests from the church, and there are no journal notes, we return.
	if (prayerPromptDataForGeneration.orgRequests.answeredOrgRequests.length === 0
		&& prayerPromptDataForGeneration.orgRequests.unansweredOrgRequests.length === 0
		&& prayerPromptDataForGeneration.journalNotes.length === 0) {
		return;
	}

	// Generating the prayer prompt.
	const prayerPrompt = await openAIPrayerPromptGenerator(prayerPromptDataForGeneration);

	// Saving the generated prayer prompt.
	if (prayerPrompt) {
		dao.saveAIPrayerPrompt(lightId, prayerPrompt);
	}
}

/**
 * This function creates the prompt used for the generation including the lights' and organizations'
 * answered and unanswered prayer requests, then it calls the generator function.
 * If the generation failed, it returns with null.
 * @returns
 */
export async function openAIPrayerPromptGenerator(
	requestsAndNotes: {
		orgRequests: {
			answeredOrgRequests: string[],
			unansweredOrgRequests: string[],
		},
		journalNotes: Array<{
			names: string,
			plId: number,
			addressId: number,
			answered_notes: string,
			not_answered_notes: string
		}> | null
	}
): Promise<string | null> {
	const names: string[] = [];
	let answeredNotes = "";
	let notAnsweredNotes = "";
	let myChurch = "";

	// If there are journalNotes, we format them for the AI to generate a beautiful prayer prompt.
	if (requestsAndNotes.journalNotes) {
		for (let i = 0; i < requestsAndNotes.journalNotes.length; i++) {
			names.push(requestsAndNotes.journalNotes[i].names);
			if (requestsAndNotes.journalNotes[i].answered_notes) {
				answeredNotes += requestsAndNotes.journalNotes[i].names
					+ "'s previous prayers that have been answered: "
					+ requestsAndNotes.journalNotes[i].answered_notes + "\n";
			}
			if (requestsAndNotes.journalNotes[i].not_answered_notes) {
				notAnsweredNotes += requestsAndNotes.journalNotes[i].names
					+ ": " + requestsAndNotes.journalNotes[i].not_answered_notes + " ";
			}
		}
	}

	// If there are organization prayer requests, we format them for the AI to generate a beautiful
	// prayer prompt.
	if (requestsAndNotes.orgRequests.answeredOrgRequests.length > 0) {
		myChurch += "My church's previous prayers that have been answered: ";
		for (let i = 0; i < requestsAndNotes.orgRequests.answeredOrgRequests.length; i++) {
			myChurch += requestsAndNotes.orgRequests.answeredOrgRequests[i] + "\n";
		}
	}
	if (requestsAndNotes.orgRequests.unansweredOrgRequests.length > 0) {
		myChurch += "My church's prayer requests: ";
		for (let i = 0; i < requestsAndNotes.orgRequests.unansweredOrgRequests.length; i++) {
			myChurch += requestsAndNotes.orgRequests.unansweredOrgRequests[i] + "\n";
		}
	}
	// The prompt that we give to the AI
	const userPrompt =
		"Please provide a prayer prompt for me about my neighbors: " + names.join(", ") +
		" and my church incorporating what I know about them." +
		" Use first person singular. Include a related scripture reference." +
		" Keep it shorter than 400 words.\n" +
		answeredNotes +
		notAnsweredNotes +
		myChurch;
	const chatCompletion = await createChatCompletion({
		systemPrompt: "You are a Christian evangelist.",
		userPrompt: userPrompt,
		logFileName: "prayerPromptLog",
	});
	return chatCompletion?.choices[0].message.content ?? null;
}

/**
 * Returns orgRequests and journalNotes in a usable form for the AI.
 * @returns
 */
export async function getRequestsAndNotesForPrayerPromptGeneration(
	lightId: number,
): Promise<{
	orgRequests: {
		answeredOrgRequests: string[],
		unansweredOrgRequests: string[],
	},
	journalNotes: Array<{
		names: string,
		plId: number,
		addressId: number,
		answered_notes: string,
		not_answered_notes: string,
	}>
}> {
	// We need the primary church of the light.
	const orgId = await getPrimaryChurchOfLight(lightId);

	const result: {
		orgRequests: {
			answeredOrgRequests: string[],
			unansweredOrgRequests: string[],
		},
		journalNotes: {
			names: string,
			plId: number,
			addressId: number,
			answered_notes: string,
			not_answered_notes: string,
		}[],
	} = {
		orgRequests: {
			answeredOrgRequests: [],
			unansweredOrgRequests: [],
		},
		journalNotes: [],
	};
	if (orgId) {
		[result.orgRequests.answeredOrgRequests,
		result.orgRequests.unansweredOrgRequests,
		result.journalNotes] = await Promise.all([
			dao.getOrgsRequests(orgId, 1),
			dao.getOrgsRequests(orgId, 0),
			dao.getPrayerJournalNotes(lightId),
		]);
	}
	return result;
}

/**
 * Connects the most relevant YouVersion plan to a Light based on prayer requests and journal notes.
 * @returns
 */
export async function openAILightPlanConnector(
	lightId: number,
	logFileName: string = "",
): Promise<void> {
	try {
		// Fetch journal notes and prayer requests for the Light
		const journalNotes = await dao.getOnlyPrayerJournalNotes(lightId);
		const lightPrayerRequests = await dao.getLightPrayerRequestsGrouped(lightId);

		// Initialize the prompt string
		let prompt = '';

		// Check if there are answered prayer requests or journal notes
		if (journalNotes?.answered_notes !== null ||
			lightPrayerRequests?.answered_prayer_requests !== null) {
			prompt += `Here are answered prayer requests: ${journalNotes?.answered_notes ?? ''}
			${lightPrayerRequests?.answered_prayer_requests ?? ''} `;
		}

		// Check if there are not answered prayer requests
		if (lightPrayerRequests?.not_answered_prayer_requests !== null) {
			prompt += `Here are not answered prayer requests: 
			${lightPrayerRequests!.not_answered_prayer_requests} `;
		}

		// Check if there are notes on neighbors
		if (journalNotes?.not_answered_notes !== null) {
			prompt += `Here are notes on neighbors: ${journalNotes!.not_answered_notes} `;
		}

		// Calculate the MD5 hash of the prompt
		const currentHash: Buffer = createHash('md5').update(prompt).digest();
		// Check if a relevant plan with the same hash exists in the database
		if (await dao.getLightRelevantPlanByHash(lightId, currentHash) === null) {
			// Creating embeddings from OpenAI
			const completion = await OPENAI.embeddings.create({
				model: "text-embedding-ada-002",
				input: prompt,
			});
			logIntoFile(
				{ request: prompt, response: completion },
				`${ENVIRONMENT.commonPath}log/`,
				logFileName,
			);
			// Fetch available plans
			const availablePlans = await dao.getLightPlans();

			// Initialize variables to store the most relevant plan
			let mostRelevantPlan: { plan: number | null; relevance: number } = {
				plan: null,
				relevance: 0,
			};

			// Iterate through available plans and calculate relevance
			for (let i = 0; i < availablePlans.length; i++) {
				const relevance = calculateRelevanceOfTwoVectors(
					completion.data[0].embedding,
					availablePlans[i].vector
				);

				// Update mostRelevantPlan if a more relevant plan is found
				if (relevance !== null &&
					(mostRelevantPlan.plan === 0 || mostRelevantPlan.relevance < relevance)) {
					mostRelevantPlan = { plan: availablePlans[i].id, relevance: relevance };
				}
			}

			// If a relevant plan is found, insert it into the database
			if (mostRelevantPlan.plan !== null) {
				await dao.upsertLightRelevantPlan(lightId, mostRelevantPlan.plan, currentHash);
			}
		}
	} catch (error) {
		// Logging the prompt and the error.
		logIntoFile(
			{ request: prompt, error: error },
			`${ENVIRONMENT.commonPath}log/`,
			"errorlog",
		);
	}
}

/**
 * Calculates the relevance between two vectors.
 * @param promptVector The vector representing the prompt.
 * @param planVector The vector representing the plan.
 * @returns The relevance score between the two vectors or null if they have different lengths.
 */
function calculateRelevanceOfTwoVectors(
	promptVector: number[],
	planVector: number[]
): number | null {
	// Check if the provided vectors have the same length
	if (promptVector.length !== planVector.length) {
		return null; // Vectors with different lengths cannot be compared
	}

	// Initialize the relevance score
	let relevance = 0;

	// Calculate the dot product of the two vectors
	for (let i = 0; i < promptVector.length; i++) {
		relevance += promptVector[i] * planVector[i];
	}

	return relevance; // Return the calculated relevance score
}

/**
 * Generates a prayer prompt for lights who have been active in the last 7 days, and their primary
 * church has an active BlessPartner subscription.
 * @returns
 */
export async function generatePersonalPrayerPromptForActiveLights(
): Promise<void> {
	const ids = await dao.getActiveLightIds();
	const promises = [];
	for (const id of ids) {
		promises.push(generatePersonalPrayerPrompt(id));
	}
	await Promise.all(promises);
}

/**
 * Generates a sermon note for all churches that have an active BlessPartner subscription.
 * @returns
 */
export async function generateDailySermonNoteForActiveChurches(
): Promise<void> {
	const ids = await dao.getActiveChurchIds();
	for (const id of ids) {
		generateSermonNote(id);
	}
}

/**
 * Generates a YouVersion plan for lights who have been active in the last 7 days, and their primary
 * church has an active BlessPartner subscription.
 * @returns
 */
export async function generateDailyYouVersionPlanForAllActiveLights(
): Promise<void> {
	const ids = await dao.getActiveLightIds();
	for (const id of ids) {
		openAILightPlanConnector(id, "youversionlog");
	}
}