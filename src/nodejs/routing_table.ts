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
 * This file includes code for API tasks and their configurations.
 */

'use strict'

import * as hackathon from "../components/hackathon/tasks.js";
import { RoleType } from "../components/role/role.js";
import { ApiResponse } from "./api_response.js";
import { TaskRequirements } from "./task_requirements.js";

class SubscriptionRelation {
  constructor({
    or = Array<number>(),
    and = Array<number>(),
  }) {
    this.or = or;
    this.and = and;
  }

  or: Array<number>;
  and: Array<number>;
}

type TaskToRunFunction = (z: TaskRequirements) => Promise<ApiResponse>;

/**
 * This interface is required to use as a type for the RouteSettings contructor.
 * It ensures that the taskToRun function is defined, while any other properties are optional
 * and has a default value in the constructor of RouteSettings.
 */
interface IRouteSettings {
  createPerson?: boolean;
  isPersonRequired?: boolean;
  createRole?: boolean;
  allowedRoles?: RoleType[];
  roleReadOnlyAllowed?: boolean;
  createSubscriptions?: boolean;
  allowedSubscriptions?: SubscriptionRelation;
  taskToRun: TaskToRunFunction;
}

class RouteSettings {
  constructor({
    createPerson = false,
    isPersonRequired = false,
    createRole = false,
    allowedRoles = <RoleType[]>[],
    roleReadOnlyAllowed = false,
    createSubscriptions = false,
    allowedSubscriptions = new SubscriptionRelation({}),
    taskToRun,
  }: IRouteSettings) {
    this.createPerson = createPerson;
    this.isPersonRequired = isPersonRequired;
    this.createRole = createRole;
    this.allowedRoles = allowedRoles;
    this.roleReadOnlyAllowed = roleReadOnlyAllowed;
    this.createSubscriptions = createSubscriptions;
    this.allowedSubscriptions = allowedSubscriptions;
    this.taskToRun = taskToRun;
  }

  /** Indicates that a person should be created for the given task. */
  createPerson: boolean;

  /** 
   * Indicates that the person creation is required. 
   * If the person creation fails, then the task cannot be executed.
   */
  isPersonRequired: boolean;

  /** Indicates that if the person creation was successful, a role also should be created for it. */
  createRole: boolean;

  /** Defined roles that are allowed to execute the task with. */
  allowedRoles: RoleType[];

  /** Indicates that if the task can be executed even if the role doesn't belong to the person. */
  roleReadOnlyAllowed: boolean;

  /** 
   * Indicates that if the role creation was successful and the allowed roles met the requirements
   * subscriptions for the given role should be created.
   */
  createSubscriptions: boolean;

  /** Defined subscriptions with subscription relations that are required to execute the task. */
  allowedSubscriptions: SubscriptionRelation;

  /** The task to run if every requirements are met. */
  taskToRun: TaskToRunFunction;
}

/**
 * The RoutingTable with every task that can be executed with their preset configs that is required
 * to run the specific task.
 */
export const ROUTING_TABLE: {
  [task: string]: RouteSettings
} = {

  // ... Removed codes that existed before and are not required for the Hackathon.

  // payload: {}
  hackathon_getSermonSummary: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["church"],
    taskToRun: hackathon.getSermonSummary,
  }),
  // payload: {}
  hackathon_getPrayerPrompt: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.getPrayerPrompt,
  }),
  // payload: { prayerListItemId: number, newEntry: string }
  hackathon_addHouseholdJournalEntry: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.addHouseholdJournalEntry,
  }),
  // payload: { prayerListItemId: number }
  hackathon_getHouseholdJournalEntries: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.getHouseholdJournalEntries,
  }),
  // payload: { id: number }
  hackathon_deleteHouseholdJournalEntry: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.deleteHouseholdJournalEntry,
  }),
  // payload: { id: number, newEntry: string }
  hackathon_editHouseholdJournalEntry: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.editHouseholdJournalEntry,
  }),
  // payload: { id: number, answeredState: boolean }
  hackathon_setIfHouseholdJournalEntryIsAnswered: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.setIfHouseholdJournalEntryIsAnswered,
  }),
  // payload: { prayerRequest: string }
  hackathon_addLightPrayerRequest: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.addLightPrayerRequest,
  }),
  // payload: {}
  hackathon_getLightPrayerRequests: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.getLightPrayerRequests,
  }),
  // payload: { id: number }
  hackathon_deleteLightPrayerRequest: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.deleteLightPrayerRequest,
  }),
  // payload: { id: number, newPrayerRequest: string }
  hackathon_editLightPrayerRequest: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.editLightPrayerRequest,
  }),
  // payload: { id: number, answeredState: boolean }
  hackathon_setIfLightPrayerRequestIsAnswered: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.setIfLightPrayerRequestIsAnswered,
  }),
  // payload: { prayerRequest: string }
  hackathon_addOrgPrayerRequest: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["church"],
    taskToRun: hackathon.addChurchPrayerRequest,
  }),
  // payload: {}
  hackathon_getOrgPrayerRequests: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["church"],
    taskToRun: hackathon.getChurchPrayerRequests,
  }),
  // payload: { id: number }
  hackathon_deleteOrgPrayerRequest: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["church"],
    taskToRun: hackathon.deleteChurchPrayerRequest,
  }),
  // payload: { id: number, newPrayerRequest: string }
  hackathon_editOrgPrayerRequest: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["church"],
    taskToRun: hackathon.editChurchPrayerRequest,
  }),
  // payload: { id: number, answeredState: boolean }
  hackathon_setIfOrgPrayerRequestIsAnswered: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["church"],
    taskToRun: hackathon.setIfChurchPrayerRequestIsAnswered,
  }),
  // payload: {}
  hackathon_getYouVersionPlan: new RouteSettings({
    createPerson: true,
    isPersonRequired: true,
    createRole: true,
    allowedRoles: ["light"],
    taskToRun: hackathon.getYouVersionPlan,
  }),
}
