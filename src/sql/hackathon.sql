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
 *                                                      AI & the Chuch Hackathon
 * 
 * 
 * @license The judging committee of the 2023 AI & the Church Hackathon, organized by Gloo LLC,
 * has the permission to use, review, assess, test, and otherwise analyze this file in connection 
 * with said Hackathon.
 * 
 * This file includes all the MySQL statements that need to be run to create and modify tables
 * for the Hackathon project. See below for further comments on each query.
 */

-- Table to store the currently valid GlooX bearer token. Although the bearer token does not ever
-- expire, this will change in the future so we better prepare for it now.
CREATE TABLE datax (
  datax_key ENUM('bearer_token') PRIMARY KEY, 
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
  datax_value text);


-- Table to store when a certain type of extension was last upserted to GlooX. We only upsert
-- changes made since the last upsertion. We upsert everything once a day. We were already
-- upserting organizations before the Hackathon. For our Hackathon solution we will also be
-- upserting prayer journal notes, light prayer requests and church prayer requests.
ALTER TABLE datax_sync MODIFY COLUMN what ENUM('org', 'note', 'lipr', 'chpr');


-- Table that stores prayer journal notes of our Lights that they enter about the homes they
-- are praying for. This table already existed but for the Hackathon it is changing considerably.
-- Because our whole idea about handling daily prayer prompts changes, we won't be flagging notes
-- as prayer requests or current prayer requests. Instead we'll start flagging whether the prayer
-- request was answered.
ALTER TABLE member_household_notes 
  ADD COLUMN deleted BOOL DEFAULT FALSE, 
  ADD KEY(deleted), 
  ADD COLUMN deleted_at TIMESTAMP DEFAULT NULL, 
  ADD COLUMN answered BOOL DEFAULT FALSE, 
  ADD KEY(answered), 
  ADD COLUMN answered_at TIMESTAMP DEFAULT NULL;


-- This table holds the prayer requests that Lights enter about themselves.
CREATE TABLE prayer_requests_lights (
  id INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
  light BIGINT UNSIGNED, 
  KEY(light), 
  FOREIGN KEY(light) REFERENCES members(id) ON UPDATE CASCADE ON DELETE SET NULL, 
  added TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
  deleted BOOL DEFAULT FALSE, 
  KEY(deleted), deleted_at TIMESTAMP DEFAULT NULL, 
  answered BOOL DEFAULT FALSE, 
  KEY(answered), answered_at TIMESTAMP DEFAULT NULL, 
  prayer_request TEXT DEFAULT NULL);


-- This table holds the prayer requests that organizations enter about themselves.
CREATE TABLE prayer_requests_orgs (
  id INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
  org BIGINT UNSIGNED, 
  KEY(org), 
  FOREIGN KEY(org) REFERENCES churches(id) ON UPDATE CASCADE ON DELETE SET NULL, 
  added TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
  deleted BOOL DEFAULT FALSE, 
  KEY(deleted), 
  deleted_at TIMESTAMP DEFAULT NULL, 
  answered BOOL DEFAULT FALSE, 
  KEY(answered), 
  answered_at TIMESTAMP DEFAULT NULL, 
  prayer_request TEXT DEFAULT NULL);


-- This table holds the current prayer prompts for each Light.
CREATE TABLE prayer_prompts_ai (
  id INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
  light BIGINT UNSIGNED, 
  KEY(light), 
  FOREIGN KEY(light) REFERENCES members(id) ON UPDATE CASCADE ON DELETE SET NULL, 
  date DATE DEFAULT NULL, 
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
  prayer_prompt TEXT);


-- This table holds the current sermon notes for each church.
CREATE TABLE sermon_notes_ai (
  id INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
  org BIGINT UNSIGNED, 
  KEY(org), 
  FOREIGN KEY(org) REFERENCES churches(id) ON UPDATE CASCADE ON DELETE SET NULL, 
  date DATE DEFAULT NULL, 
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
  sermon_note TEXT);

-- This table records when each of the AI cron jobs ran to be able to determine
-- if we need to run it again.
CREATE TABLE ai_crons (
  `what` enum('light_prayer_prompts', 'church_sermon_notes', 'youversion_recommendations'),
  `when` timestamp NULL DEFAULT NULL, 
  PRIMARY KEY (`what`));


-- YouVersion Bible plans are stored here. The vector embeddings for each
-- play are also stored here.
CREATE TABLE `light_plans` (
  `id` mediumint unsigned NOT NULL,
  `url` varchar(255),
  `image` varchar(255),
  `title` text,
  `intro` text,
  `content` mediumtext,
  `vector` json DEFAULT NULL,
  PRIMARY KEY (`id`));


-- This table stores the recommended YouVersion Bible plan for each Light.
-- The hash helps us prevent recalculating the vector embeddings for Lights
-- if nothing has changed.
CREATE TABLE `light_relevant_plans` (
  `light` bigint unsigned NOT NULL,
  `plan` mediumint unsigned NOT NULL,
  `hash` binary(16) DEFAULT NULL,
  PRIMARY KEY (`light`)
);
