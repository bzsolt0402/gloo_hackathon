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
 * This file includes code that are accessing the database. 
 * (Returning, saving, updating or deleting data).
 */

'use strict'

import { OkPacket } from "mysql2";
import { pool } from "../../db/database.js";


/**
 * Returns the prayer requests of an organization's lights with an option if
 * we want the already answered requests, or the ones that still need to be answered.
 * @param orgId
 * @param answered
 * @returns
 */
export async function getOrgsLightsRequests(
  orgId: number,
  answered: number,
): Promise<Array<string>> {
  const q = `
		SELECT prl.prayer_request 
		FROM lightRelationships lr
			INNER JOIN prayer_requests_lights prl ON prl.light=lr.light
		WHERE lr.organization=?
			AND prl.answered = ?
			AND prl.deleted=0`;
  const [result] = await pool.execute<any[]>(q, [orgId, answered]);
  return result.map((e) => e.prayer_request);
}

/**
 * Returns the prayer requests of an organization with an option if
 * we want the already answered requests, or the ones that still need to be answered.
 * @param orgId
 * @param answered
 * @returns
 */
export async function getOrgsRequests(
  orgId: number,
  answered: number,
): Promise<Array<string>> {
  const q = `
		SELECT prayer_request 
		FROM prayer_requests_orgs
		WHERE org=?
			AND answered=?
			AND deleted=0
		ORDER BY added DESC`;
  const [result] = await pool.execute<any[]>(q, [orgId, answered]);
  return result.map((e) => e.prayer_request);
}

/**
 * Saves the generated sermon note for future use, so we don't have to regenerate it.
 * @param orgId
 * @param sermonNote
 * @returns
 */
export async function saveSermonNote(
  orgId: number,
  sermonNote: string | null,
): Promise<void> {
  const q = `
		INSERT INTO sermon_notes_ai (org, date, sermon_note) 
			VALUES(?, NOW(), ?)`;
  await pool.execute<OkPacket>(q, [orgId, sermonNote]);
}

/**
 * Returns today's sermon note, or null if it has not been generated yet.
 * @returns
 */
export async function getSermonNote(
  orgId: number,
): Promise<string | null> {
  const q = `
		SELECT sermon_note FROM sermon_notes_ai
		WHERE date=DATE(NOW())
			AND org=?
		ORDER BY id desc
		LIMIT 1`;
  const [result] = await pool.execute<any[]>(q, [orgId]);
  return result.length !== 0 ? result[0].sermon_note : null;
}

/**
 * Returns the names, prayerListItemId, addressId of people living in households 
 * adopted by the given Light, also returns the Light's answered and not answered 
 * journal notes for each prayer list item.
 * @param lightId
 * @returns
 */
export async function getPrayerJournalNotes(
  lightId: number,
): Promise<Array<{
  names: string,
  plId: number,
  addressId: number,
  answered_notes: string,
  not_answered_notes: string,
}>> {
  const q = `
		SELECT
			ANY_VALUE(t4.householdNames) names,
			ANY_VALUE(t4.prayer_list_item_id) plId,
			ANY_VALUE(t4.address_id) adressId,
			GROUP_CONCAT(IF(n.answered=1, n.note, NULL) SEPARATOR ', ') answered_notes,
			GROUP_CONCAT(IF(n.answered=0, n.note, NULL) SEPARATOR ', ') not_answered_notes
		FROM (
			SELECT 
				GROUP_CONCAT(householdGivenNames SEPARATOR ', ') householdNames,
				ANY_VALUE(t3.plid) prayer_list_item_id,
				ANY_VALUE(t3.address) address_id
			FROM (SELECT
							CONCAT_WS(' AND ', NULLIF(SUBSTRING_INDEX( GROUP_CONCAT(t1.householdName SEPARATOR ', '), ', ', length( GROUP_CONCAT(t1.householdName SEPARATOR ', ')) - length(replace( GROUP_CONCAT(t1.householdName SEPARATOR ', '),', ',' ')) ), ''), SUBSTRING_INDEX(GROUP_CONCAT(t1.householdName SEPARATOR ', '), ', ', -1)) AS householdGivenNames,
							t1.plid,
							ANY_VALUE(t1.aid) address,
							ANY_VALUE(t1.ordering) ordering
						FROM ((SELECT pl.address aid,
										 pl.id as plid,
										 pl.address,
										 pl.ordering,
										 IF (hp.status = 'Deactivate', null, NULLIF( CONCAT_WS(', ', TRIM(IFNULL(hp.primary_given_name, h.primary_given_name)), IF (TRIM(IFNULL(hp.secondary_given_name, h.secondary_given_name) = ''), NULL, TRIM(IFNULL(hp.secondary_given_name, h.secondary_given_name)) ) ) , '') ) householdName
									 FROM prayer_lists pl
									 LEFT JOIN households h ON h.address=pl.address
									 LEFT JOIN households_public hp ON hp.household=h.id WHERE pl.member_id=? AND pl.daily>0 )
									 UNION ALL (SELECT
																pl.address aid,
																pl.id as plid,
																pl.address,
																pl.ordering,
																NULLIF( CONCAT_WS(', ', TRIM(hp.primary_given_name), IF (TRIM(hp.secondary_given_name)='',NULL,TRIM(hp.secondary_given_name)) ) , '' ) householdName
															FROM prayer_lists pl
															INNER JOIN households_public hp ON hp.address=pl.address AND hp.household IS NULL AND (hp.status != 'Deactivate') WHERE pl.member_id=? AND pl.daily>0 )) t1
															GROUP BY t1.plid
														 ) t3
				LEFT JOIN addresses a ON t3.address=a.id
				LEFT JOIN prayer_list_item_labels pll ON pll.prayer_list_item=t3.plid
				WHERE householdGivenNames IS NOT NULL
					AND pll.label_1 IS NULL
				GROUP BY t3.plid) t4
		LEFT JOIN member_household_notes n ON t4.prayer_list_item_id=n.prayer_list_item_id AND n.deleted=0
		GROUP BY t4.prayer_list_item_id
	`;
  const [result] = await pool.execute<any[]>(q, [lightId, lightId]);
  return result;
}

/**
 * Returns AI generated prayer prompt for a Light for the current day if exists.
 * @returns
 */
export async function getPersonalPrayerPrompt(
  lightId: number,
): Promise<string | null> {
  const q = `
		SELECT prayer_prompt FROM prayer_prompts_ai
		WHERE date=DATE(NOW())
			AND light=?
		LIMIT 1`;
  const [result] = await pool.execute<any[]>(q, [lightId]);
  return result.length !== 0 ? result[0].prayer_prompt : null;
}

/**
 * Saves the generated prayer prompt for future use, so we don't have to 
 * regenerate it.
 * @param orgId
 * @param sermonNote
 * @returns
 */
export async function saveAIPrayerPrompt(
  lightId: number,
  prayerPrompt: string | null,
): Promise<void> {
  const q = `
		INSERT INTO prayer_prompts_ai (light, date, prayer_prompt) 
			VALUES(?, NOW(), ?)`;
  await pool.execute<OkPacket>(q, [lightId, prayerPrompt]);
}

/**
 * Adds a new entry to the prayer journal for a given prayer list item.
 * @param prayerListItemId
 * @param newEntry
 * @returns
 */
export async function addHouseholdJournalEntry(
  prayerListItemId: number,
  newEntry: string,
): Promise<number> {
  const q = `
		INSERT INTO member_household_notes (prayer_list_item_id, note, added) 
			VALUES (?, SUBSTRING(?,1,8096), NOW())`;
  const [result] = await pool.execute<OkPacket>(q, [prayerListItemId, newEntry]);
  return result.insertId;
}

/**
 * Modifies an existing prayer journal entry.
 * @param noteId
 * @param newEntry
 */
export async function editHouseholdJournalEntry(
  noteId: number,
  newEntry: string,
): Promise<void> {
  const q = `UPDATE member_household_notes SET note=SUBSTRING(?,1,8096) WHERE id=?`;
  await pool.execute<OkPacket>(q, [newEntry, noteId]);
}

/**
 * Returns journal entries of a household.
 * @param prayerListItemId
 * @returns
 */
export async function getHouseholdJournalEntries(
  prayerListItemId: number,
): Promise<Array<{
  id: number,
  note: string,
  added: number,
  answered: number,
}>> {
  const q = `
    SELECT id, note, unix_timestamp(added) as added, answered 
		  FROM member_household_notes 
	  WHERE prayer_list_item_id=? AND deleted=0`;
  const [result] = await pool.execute<any[]>(q, [prayerListItemId]);
  return result;
}

/**
 * Changes a journal note's answered flag, updates the answered timestamp.
 * @param noteId
 * @param answeredState
 * @param lightId
 * @returns
 */
export async function setIfHouseholdJournalEntryIsAnswered(
  noteId: number,
  answeredState: boolean,
  lightId: number
): Promise<boolean> {
  const q = `
		UPDATE member_household_notes mn
		INNER JOIN prayer_lists pl ON mn.prayer_list_item_id=pl.id
			SET mn.answered=?, mn.answered_at=IF(?, NOW(), NULL)
		WHERE mn.id=?
			AND pl.member_id=?`;
  const [result] = await pool.execute<OkPacket>(
    q,
    [answeredState, answeredState, noteId, lightId]
  );
  return result.affectedRows !== 0;
}

/**
 * Changes a journal note's deleted flag, updates the deleted timestamp.
 * @param noteId
 * @param lightId
 * @returns
 */
export async function deleteHouseholdJournalEntry(
  noteId: number,
  lightId: number
): Promise<boolean> {
  const q = `
		UPDATE member_household_notes mn
		INNER JOIN prayer_lists pl ON mn.prayer_list_item_id=pl.id
			SET mn.deleted=1, mn.deleted_at=NOW() 
		WHERE mn.id=?
			AND pl.member_id=?`;
  const [result] = await pool.execute<OkPacket>(
    q,
    [noteId, lightId]
  );
  return result.affectedRows !== 0;
}

/**
 * Inserts a new light prayer request and returns its insertId.
 * @param lightId
 * @param prayerRequest
 * @returns
 */
export async function addLightPrayerRequest(
  lightId: number,
  prayerRequest: string
): Promise<number> {
  const q = `
		INSERT INTO prayer_requests_lights (light, prayer_request)
		  VALUES(?, SUBSTRING(?,1,8096))`;
  const [result] = await pool.execute<OkPacket>(q, [lightId, prayerRequest]);
  return result.insertId;
}

/**
 * Modifies an existing light prayer request.
 * @param noteId
 * @param newEntry
 */
export async function editLightPrayerRequest(
  noteId: number,
  newPrayerRequest: string,
): Promise<void> {
  const q = `
    UPDATE prayer_requests_lights 
	 	  SET prayer_request=SUBSTRING(?,1,8096) WHERE id=?`;
  await pool.execute<OkPacket>(q, [newPrayerRequest, noteId]);
}

/**
 * Changes a light's prayer request answered flag, updates the answered timestamp.
 * @param answeredState
 * @param noteId
 * @param lightId
 * @returns
 */
export async function setIfLightPrayerRequestIsAnswered(
  answeredState: boolean,
  noteId: number,
  lightId: number
): Promise<boolean> {
  const q = `
    UPDATE prayer_requests_lights
		  SET answered=?, answered_at=IF(?, NOW(), NULL)
	  WHERE id=?
		  AND light=?`;
  const [result] = await pool.execute<OkPacket>(
    q,
    [answeredState, answeredState, noteId, lightId]
  );
  return result.affectedRows !== 0;
}

/**
 * Changes a light's prayer request deleted flag, add a timestamp when it was deleted.
 * @param answeredState
 * @param noteId
 * @param lightId
 * @returns
 */
export async function deleteLightPrayerRequest(
  noteId: number,
  lightId: number
): Promise<boolean> {
  const q = `
    UPDATE prayer_requests_lights
			SET deleted=1, deleted_at=NOW()
		WHERE id=?
			AND light=?`;
  const [result] = await pool.execute<OkPacket>(
    q,
    [noteId, lightId]
  );
  return result.affectedRows !== 0;
}

/**
 * Inserts a new prayer request to a church and returns its insertId.
 * @param orgId
 * @param prayerRequest
 * @returns
 */
export async function addChurchPrayerRequest(
  orgId: number,
  prayerRequest: string
): Promise<number> {
  const q = `
    INSERT INTO prayer_requests_orgs (org, prayer_request)
			VALUES(?, SUBSTRING(?,1,8096))`;
  const [result] = await pool.execute<OkPacket>(q, [orgId, prayerRequest]);
  return result.insertId;
}

/**
 * Modifies an existing prayer request of a church.
 * @param noteId
 * @param newEntry
 */
export async function editChurchPrayerRequest(
  noteId: number,
  newPrayerRequest: string,
): Promise<void> {
  const q = `
    UPDATE prayer_requests_orgs 
			SET prayer_request=SUBSTRING(?,1,8096) WHERE id=?`;
  await pool.execute<OkPacket>(q, [newPrayerRequest, noteId]);
}

/**
 * Returns the prayer requests of a church.
 * @param orgId
 * @returns
 */
export async function getChurchPrayerRequests(
  orgId: number,
): Promise<Array<{
  id: number,
  prayer_request: string,
  added: number,
  answered: number,
}>> {
  const q = `
    SELECT id, prayer_request, unix_timestamp(added) as added, answered 
			FROM prayer_requests_orgs WHERE org=? AND deleted=0
    ORDER BY added DESC`;
  const [result] = await pool.execute<any[]>(q, [orgId]);
  return result;
}

/**
 * Changes a church's prayer request answered flag, updates the answered timestamp.
 * @param answeredState
 * @param noteId
 * @param orgId
 * @returns
 */
export async function setIfChurchPrayerRequestIsAnswered(
  answeredState: boolean,
  noteId: number,
  orgId: number
): Promise<boolean> {
  const q = `
    UPDATE prayer_requests_orgs
			SET answered=?, answered_at=IF(?, NOW(), NULL)
		WHERE id=?
			AND org=?`;
  const [result] = await pool.execute<OkPacket>(
    q,
    [answeredState, answeredState, noteId, orgId]
  );
  return result.affectedRows !== 0;
}

/**
 * Changes a church's prayer request deleted flag, updates the deleted timestamp.
 * @param answeredState
 * @param noteId
 * @param orgId
 * @returns
 */
export async function deleteChurchPrayerRequest(
  noteId: number,
  orgId: number
): Promise<boolean> {
  const q = `
    UPDATE prayer_requests_orgs
			SET deleted=1, deleted_at=NOW()
		WHERE id=?
			AND org=?`;
  const [result] = await pool.execute<OkPacket>(
    q,
    [noteId, orgId]
  );
  return result.affectedRows !== 0;
}

/**
 * It will be used to generate prayer prompts for ALL of the lights who meet these conditions:
 * It returns the ids of lights who have been active in the last 7 days, and their primary
 * church has an active BlessPartner subscription. These conditions can be modified later.
 * @returns
 */
export async function getActiveLightIds(
): Promise<Array<number>> {
  const q = `
    SELECT m.id FROM members m 
			INNER JOIN lightRelationships lr 
				ON m.id=lr.light AND lr.primaryChurch=1
			INNER JOIN churchSubscriptions cs 
				ON lr.organization=cs.church 
					AND cs.subscription=6 AND cs.from < NOW() AND cs.to > NOW()
		WHERE m.last_activity >= date_sub(NOW(), interval 7 day) 
			GROUP BY m.id`;
  const [result] = await pool.execute<any[]>(q);
  return result.map((e) => e.id);
}

/**
 * Returns the ids of active churches. 
 * (A church is considered active if it has an active Bless Partner subscription).
 * @returns
 */
export async function getActiveChurchIds(
): Promise<Array<number>> {
  const q = `
    SELECT church FROM churchsubscriptions cs
		WHERE subscription=6
			AND cs.from < NOW() AND cs.to > NOW()`;
  const [result] = await pool.execute<any[]>(q);
  return result.map((e) => e.church);
}

/**
 * Returns if a job has been already run today.
 * @param job
 * @returns
 */
export async function didCronJobAlreadyRunToday(
  job: string,
): Promise<boolean> {
  const q = `
		SELECT * FROM ai_crons
		WHERE \`when\`=DATE(NOW())
			AND what=? LIMIT 1`;
  const [result] = await pool.execute<any[]>(q, [job]);
  return result.length !== 0;
}

/**
 * Saves the time when the cronjob has been run.
 * @param job
 * @returns
 */
export async function saveCronJobDone(
  job: string,
): Promise<void> {
  const q = `
    INSERT INTO ai_crons (what, \`when\`) VALUES(?, DATE(NOW())) 
	    ON DUPLICATE KEY UPDATE \`when\`=DATE(NOW())`;
  await pool.execute<OkPacket>(q, [job]);
}

/**
 * Checks if the given light is allowed to modify the given prayer request.
 * @param noteId
 * @param lightId
 * @returns
 */
export async function doesLightPrayerRequestBelongToLight(
  noteId: number,
  lightId: number,
): Promise<boolean> {
  const q = `
    SELECT * FROM prayer_requests_lights
		WHERE id=?
			AND light=? LIMIT 1`;
  const [result] = await pool.execute<any[]>(q, [noteId, lightId]);
  return result.length !== 0;
}

/**
 * Checks if the given church is allowed to modify the given prayer request.
 * @param noteId
 * @param orgId
 * @returns
 */
export async function doesPrayerRequestBelongsToTheChurch(
  noteId: number,
  orgId: number,
): Promise<boolean> {
  const q = `
		SELECT * FROM prayer_requests_orgs
		WHERE id=?
			AND org=? LIMIT 1`;
  const [result] = await pool.execute<any[]>(q, [noteId, orgId]);
  return result.length !== 0;
}

/**
 * Retrieves answered and not answered prayer journal notes for a given Light.
 * @param lightId The ID of the Light.
 * @returns An object containing answered and not answered prayer journal notes,
 *          or null if no notes are found.
 */
export async function getOnlyPrayerJournalNotes(
  lightId: number
):Promise<{ answered_notes: string, not_answered_notes: string } | null> {
  // SQL query to retrieve answered and not answered prayer journal notes
  const q = `
		SELECT 
			GROUP_CONCAT(IF(n.answered = 1, n.note, NULL) SEPARATOR ' ') answered_notes,
			GROUP_CONCAT(IF(n.answered = 0, n.note, NULL) SEPARATOR ' ') not_answered_notes
		FROM prayer_lists pl
		LEFT JOIN member_household_notes n ON pl.id=n.prayer_list_item_id AND n.deleted=0
		WHERE pl.member_id=?`;
  try {
    // Execute the SQL query using the database connection pool
    const [result] = await pool.execute<any[]>(q, [lightId]);

    // Return the answered and not answered notes or null there are no requests for the Light.
    return result[0] ?? null;
  } catch (error) {
    console.error('Error fetching prayer journal notes:', error);
    throw error; // Rethrow the error to handle it elsewhere
  }
}

/**
 * Retrieves answered and not answered prayer requests for a given Light.
 * @param lightId The ID of the Light.
 * @returns An object containing answered and not answered prayer requests,
 *          or null if no requests are found.
 */
export async function getLightPrayerRequestsGrouped(
  lightId: number,
): Promise<{
  answered_prayer_requests: string,
  not_answered_prayer_requests: string,
} | null> {
  const q = `
		SELECT 
			GROUP_CONCAT(IF(answered=1, prayer_request, NULL) SEPARATOR ' ')
				answered_prayer_requests,
			GROUP_CONCAT(IF(answered=0, prayer_request, NULL) SEPARATOR ' ')
				not_answered_prayer_requests
		FROM prayer_requests_lights
		WHERE light=? 
			AND deleted=0`;
  try {
    // Execute the SQL query using the database connection pool
    const [result] = await pool.execute<any[]>(q, [lightId]);

    // Return the answered and not answered prayer requests or null there are no requests for the Light.
    return result[0] ?? null;
  } catch (error) {
    console.error('Error fetching prayer requests:', error);
    throw error; // Rethrow the error to handle it elsewhere
  }
}

/**
 * Retrieves all non-deleted answered and not answered prayer requests for a given Light.
 * @param lightId The ID of the Light.
 * @returns An array of prayer request objects.
 */
export async function getLightPrayerRequests(
  lightId: number,
): Promise<{
  id: number,
  added: number,
  answered: number,
  prayer_request: string,
}[]> {
  const q = `
    SELECT id, unix_timestamp(added) as added, answered, prayer_request 
			FROM prayer_requests_lights WHERE light=? AND deleted=0 ORDER BY added DESC`;
  const [result] = await pool.execute<any[]>(q, [lightId]);
  return result;
}

/**
 * Retrieves a relevant plan for a Light by its hash.
 * @param id The ID of the Light.
 * @param hash The hash value.
 * @returns The plan ID or null if not found.
 */
export async function getLightRelevantPlanByHash(
  id: number,
  hash: Buffer,
): Promise<number | null> {
  const q = `
		SELECT plan
		  FROM light_relevant_plans
		  WHERE light=? AND hash=?`;
  const [result] = await pool.execute<any[]>(q, [id, hash]);
  return result.length !== 0 ? result[0].plan : null;
}

/**
 * Inserts or updates a relevant plan for a Light.
 * @param lightId The ID of the Light.
 * @param planId The ID of the plan.
 * @param hash The hash value.
 */
export async function upsertLightRelevantPlan(
  lightId: number,
  planId: number,
  hash: Buffer,
): Promise<void> {
  const q = `
		INSERT INTO light_relevant_plans (light, plan, hash) 
		  VALUES (?, ?, ?)
		  ON DUPLICATE KEY UPDATE plan=?, hash=?`;
  await pool.execute<OkPacket>(q, [lightId, planId, hash, planId, hash]);
}


/**
 * Retrieves a list of light plans with their IDs and vectors.
 * @returns An array of objects containing plan ID and vector.
 */
export async function getLightPlans(
): Promise<Array<{ id: number, vector: number[] }>> {
  const q = `
		SELECT id, vector
		  FROM light_plans`;
  const [result] = await pool.execute<any[]>(q, []);
  return result;
}

/**
 * Returns the recommended YouVersion plan for a Light.
 * @param lightId
 * @returns
 */
export async function getYouVersionPlan(
  lightId: number,
): Promise<{ title: string, intro: string, url: string, image: string } | null> {
  const q = `
    SELECT lp.title, lp.intro, lp.url, lp.image  
			FROM light_relevant_plans lpr
		INNER JOIN light_plans lp ON lpr.plan=lp.id
		WHERE lpr.light=?`;
  const [result] = await pool.execute<any[]>(q, [lightId]);
  return result.length != null ? result[0] : null;
}