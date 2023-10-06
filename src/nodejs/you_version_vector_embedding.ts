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
 * It is a utility file that is only used for creating the data only once.
 * This file includes code for creating and saving vectors from a YouVersion plan's content.
 * The database table was populated manually with sample data, ideally the YouVersion reading 
 * plans and their vector embeddings would be available through GlooX.
 */

'use strict'

import { OPENAI } from "./hackathon/tasks.js";
import { OkPacket } from "mysql2";
import { pool } from "../db/database.js";

/**
 * Returns a YouVersion plan's content from database.
 * @returns
 */
async function getLightPlans(): Promise<{ id: number, content: string }[]> {
	const q = `SELECT id, content
      FROM light_plans`;
	const [result] = await pool.execute<any[]>(q);
	return result;
}

/**
 * Saves the vector for a given plan.
 */
async function saveLightPlanVector(
	id: number,
	vector: string
): Promise<void> {
	const q = `
		UPDATE light_plans 
		SET vector=?
		WHERE id=?`;
	await pool.execute<OkPacket>(q, [vector, id]);
}

/**
 * Gets all light plans from the database and creates vector embeddings for them. 
 * @returns 
 */
async function saveLightPlanVectors() {
	const lightPlans = await getLightPlans();
	// shotcut
	if (lightPlans.length === 0) return;

	for (let i = 0; i < lightPlans.length; i++) {
		const completion = await OPENAI.embeddings.create({
			model: "text-embedding-ada-002",
			input: lightPlans[i].content,
		});
		saveLightPlanVector(lightPlans[i].id, JSON.stringify(completion.data[0].embedding));
	}
}

saveLightPlanVectors();