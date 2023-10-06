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
 * This file includes all the code required to communicate with GlooX. It has been greatly improved,
 * complemented with new functionality and completely refactored for the Hackathon. Some of its
 * core processes did already exist before the Hackathon in some basic form.
 */
declare(strict_types=1);
namespace BCW\DATAX;


// SETTINGS ----------------------------------------------------------------------------------------


// These little bad boys here define the IDs of various entities. Depending on the settings in the
// server definitions file, either the sandbox or the production versions will be applied. You
// shouldn't ever need to change these. If you do decide to fiddle around with these, make sure you
// know what you are doing.
// constant                       sandbox                     production
const APP_CONTEXT              = ["64790e83c8528415129d568f", "64790f570cb4d25ce7d2b84b"];
const PRIMITIVE_PERSON         = ["64e7cc1d73bf25ce1be73c1f", NULL];
const PRIMITIVE_GROUP          = ["64e7cc1d8204283fcfd8fbd1", NULL];
const PRIMITIVE_ORGANIZATION   = ["64e7cc1d73bf25ce1be73c20", "645abdd899786dc43299ed8c"];
const PRIMITIVE_SCHOOL         = ["64e7cc1d8204283fcfd8fbd2", NULL];
const PRIMITIVE_PRAYER_REQUEST = ["64e7cc1e73bf25ce1be73c21", "6487179dd87cc037fc619997"];
const SIGNAL_PRAYER            = ["64e7cc1e40de67f8bb1507e9", "6487179dfe492097c75300b8"];


// Below constants are for optimizing dataflow to GlooX. The goal was to make dataflow as fast as
// possible without getting dropped by any rate limiters along the way, or by GlooX servers
// themselves. A lot of testing went into arriving at these exact values. If you are going to change
// them, test the new settings thoroughly. If GlooX changes stuff on their end, these numbers might
// need to be adjusted. Also, if you see a lot of dropped or unanswered connections in the error log
// file, these numbers might need to be tweaked.
// The number of GraphQL calls to pack into one multi curl call.
const MULTI_CURL_CHUNK_SIZE = 50;
// The amount of time in milliseconds to sleep between multi curl calls.
const MULTI_CURL_SLEEP_BETWEEN_CHUNKS = 100;
// Wrapper for CURLOPT_CONNECTTIMEOUT. The number of seconds to wait while trying to connect. Use 0 
// to wait indefinitely. (Setting this to exactly 1 made a considerable improvement in performance.
// This could always be replicated, but makes no sense to me. Better check this more.) I was getting
// some timeouts so I now set this to 2.
const MULTI_CURL_CONNECTTIMEOUT = 2;
// Wrapper for CURLOPT_TIMEOUT. The maximum number of seconds to allow cURL functions to execute.
const MULTI_CURL_TIMEOUT = 15;
// Wrapper for CURLMOPT_PIPELINING. See curl documentation because it is pretty complex.
const MULTI_CURL_PIPELINING = 2;
// Wrapper for CURLMOPT_MAX_HOST_CONNECTIONS. Maximum number of connections to a single host.
const MULTI_CURL_MAX_HOST_CONNECTIONS = 5;
// Wrapper for CURLMOPT_MAX_TOTAL_CONNECTIONS. Maximum number of simultaneously open connections.
const MULTI_CURL_MAX_TOTAL_CONNECTIONS = 5;


// Various other settings.
// This is a string that can be used to indicate something so far in the past that we don't even
// need to filter by time because all records would be included anyway.
const AGES_AGO = "1970-01-01 00:00:00";


// GRAPHQL CLASS -----------------------------------------------------------------------------------


/**
 * This class handles all the communication with GlooX. All the publicly callable methods are near
 * the top. The methods are static. You should not instantiate the class.
 */
class GraphQL {


  /**
   * Queries GlooX for the currently valid bearer token. It does not consult our database to see
   * what bearer token is saved there. It goes directly to GlooX and returns what it provides. This
   * method will run even if GlooX dataflow is turned off in the definitions file of the server.
   * @return string 
   */
  public static function getCurrentlyValidBearerToken(): string {
    // This function does not need to check if GlooX dataflow is enabled because this is not really
    // exchanging data. This is more like a utility function to enable subsequent dataflow.
    return self::query_getAppToken();
  }


  /**
   * Upserts all extensions of a certain type added or changed since the last upsertion, or since 
   * the datetime override if it is provided.
   * @param string $type 'org' | 'note' | 'lipr' | "chpr'
   * @param string|null $sinceDateTimeOverride
   * @return void
   */
  public static function extensionUpsertAllChanges(
      string $type,
      ?string $sinceDateTimeOverride = null
  ): void
  {
    if(!\D\DATA_X_ON) return; // if GlooX dataflow is disabled we are done
    $since = self::getSince($type, $sinceDateTimeOverride);
    $mysqlQuery = self::mysqlQueryForExtensionData($type, $since);
    $timeJustBeforeGettingData = new \DateTimeImmutable();
    $orgDataToUpsert = self::getAndPackExtensionDataToUpsert($type, $mysqlQuery);
    foreach($orgDataToUpsert as $chunk) {
      self::mutation_upsertExtension_multi($chunk);
      usleep(MULTI_CURL_SLEEP_BETWEEN_CHUNKS);
    }
    self::recordGlooXDataSync($type, $timeJustBeforeGettingData);    
  }


  /**
   * Deletes all the extensions from GlooX of a certain type. Depending on the amount of extensions
   * this can run for a very long time. You better only run it from a command line utility and by
   * turning out put monitoring on so you can follow its progress. Output monitoring will echo a 
   * dot for each chunk.
   * @param string $type 'org' | 'note'
   * @param bool $monitorOutput Echos a dot for each chunk.
   */
  public static function extensionDeleteAll(
      string $type,
      bool $monitorOutput = false
  ): void 
  {
    if(!\D\DATA_X_ON) return; // if GlooX dataflow is disabled we are done
    $i = 0;
    while($i < 10000) { // safety break for loop
      if ($monitorOutput) echo ".";
      $q = 'query findExtensions{findExtensions(input:'
         . '{primitiveTypeId:"'.self::$ids[$type][\D\DATA_X_PRODUCTION].'",'
         . 'options:{paging:{count:'.MULTI_CURL_CHUNK_SIZE.',offset:0}}})'
         . '{extensions{id},pagingInfo{totalCount}}}';
      $responses = self::curlMulti([json_encode(["query" => $q])]);
      $res = $responses[0];
      if(empty($res->data->findExtensions->extensions)) {
        return; // no more, we are done
      }
      $requests = []; // be sure to reset the array so nothing carries over from the previous loop
      foreach($res->data->findExtensions->extensions as $ext) {
        $requests[] = json_encode(["query" => 
            "mutation deleteExtension{deleteExtension(id:\"".$ext->id."\")}"]);
      }
      if($i > 0) usleep(MULTI_CURL_SLEEP_BETWEEN_CHUNKS);
      self::curlMulti($requests);
      $i++;
    };
  }
  
  
  /**
   * Send one prayer activity to GlooX. The function does not check whether the provided person
   * actually has access to the provided prayer list item. Those checks should be done before
   * calling this function. Even if the prayer list item does not belong to the person, it will be
   * sent to GlooX being tied to the person.
   * @param \BCW\PERSON\Existing $person
   * @param int $prayerListItemID
   * @return void
   */
  public static function prayedOne(
      \BCW\PERSON\Existing $person, 
      int $prayerListItemID
  ): void 
  {
    if(!\D\DATA_X_ON) return; // if GlooX dataflow is disabled we are done
    self::prayersReport($person, "WHERE pl.id=$prayerListItemID LIMIT 1");
  }

  
  /**
   * Sends daily prayer activities of a prayer list to GlooX. This is a convenience function to be 
   * able to easily report when somebody prays for all their daily assigned items without needing to
   * grab the actual prayer list item IDs. The function does not check whether the provided person
   * actually has access to the provided prayer list. That checks should be done before calling this
   * function. Even if the prayer list does not belong to the person, the prayers will be sent to 
   * GlooX being tied to the person.
   * @param \BCW\PERSON\Existing $person
   * @param int $prayerListId
   * @return void
   */
  public static function prayedForAllDailies(
      \BCW\PERSON\Existing $person, 
      int $prayerListId
  ): void 
  {
    if(!\D\DATA_X_ON) return; // if GlooX dataflow is disabled we are done
    // Daily is deliberately set to 2. Be careful! Don't change it. Think about it!
    self::prayersReport($person, "WHERE pl.member_id=$prayerListId AND pl.daily=2");
  }
  
  
  /**
   * Sends several prayers of a person to GlooX. This is a convenience function to be able to report
   * several prayers of the same person from a comma delimited string of prayer list items. We use
   * this format in URLs, usually base64 encoded, for example in the daily 5 emails. This format can
   * be plugged right into a query after sanitization, of course. The function does not check 
   * whether the provided person actually has access to the provided prayer list items. Those checks
   * should be done before calling this function. Even if the prayer list items do not belong to the
   * person, the prayers will be sent to GlooX being tied to the person.
   * @param \BCW\PERSON\Existing $person
   * @param string $commaSeperatedStringOfPrayerListItemIdsAlreadySanitized
   * @return void
   */
  public static function prayedForSeveralCommaSeperated(
      \BCW\PERSON\Existing $person, 
      string $commaSeperatedStringOfPrayerListItemIdsAlreadySanitized
  ): void
  {
    if(!\D\DATA_X_ON) return; // if GlooX dataflow is disabled we are done
    self::prayersReport($person, 
        "WHERE pl.id IN ($commaSeperatedStringOfPrayerListItemIdsAlreadySanitized)");
  }
  
  
  // PRIVATE ---------------------------------------------------------------------------------------
  
  
  /**
   * This little bad boy helps out in determining the primitive IDs for extension operations, which
   * are mostly all the same except for a string variable that determines what type of extension we
   * are working with.
   * @var array
   */
  private static $ids = [
    "org"  => PRIMITIVE_ORGANIZATION, 
    "note" => PRIMITIVE_PRAYER_REQUEST,
    "lipr" => PRIMITIVE_PRAYER_REQUEST,
    "chpr" => PRIMITIVE_PRAYER_REQUEST
  ];


  /**
   * Gets an application token (bearer token) from GlooX. It doesn't save it to the database or do
   * anything else with it, it just returns it.
   * @return string Bearer token.
   */
  private static function query_getAppToken(): string {
    $q = 'query getAppToken{getAppToken(input:'
        .'{apiKeyId:"'.\D\DATA_X_API_KEY.'",apiKeySecret:"'.\D\DATA_X_SECRET.'"})}';
    $req = json_encode(["query" => $q]);

    // This operation fetches a bearer token which does not require authentication. Do not even try
    // to authenticate with a bearer token. If we send an invalid bearer token here, instead of 
    // getting a bearer token back, we'll receive an unauthorized message. So keep the second
    // parameter false in the below curl function call.
    $responses = self::curlMulti([$req], false); // keep this on false
    $res = json_decode($responses[0]);
    return $res->data->getAppToken;
  }


  /**
   * Sends prayer activity to GlooX. Just supply the where-orderby-limit part of the MySQL query
   * that will be appended to the prayer_lists query. Everything else will be taken care of. All
   * prayers sent will be connected to the person regardless of whether that person actually has
   * access to the prayer list items the query returns. Make sure the person and the prayer list
   * items belong to each other before calling this function.
   */
  private static function prayersReport(
    \BCW\PERSON\Existing $person,
    string $mysqlQueryWhereOrderLimit
  ): void
  {
    global $db;
    $stmt = $db->prepare("SELECT FLOOR(ST_X(a.location)*1000)/1000 lat, 
                                 FLOOR(ST_Y(a.location)*1000)/1000 lng
                          FROM prayer_lists pl
                            LEFT JOIN addresses a ON pl.address=a.id
                          $mysqlQueryWhereOrderLimit");
    $stmt->execute();
    $r = $stmt->get_result();
    if($r->num_rows===0) return; // nothing to do, we are done
    while($d = $r->fetch_assoc()) {
      $dd[] = [
        SIGNAL_PRAYER[\D\DATA_X_PRODUCTION],
        "person",
        $person->getId(),
        null,
        $d,
        "id"
      ];
    }
    self::mutation_reportActorSignal_multi($dd);
  }


  /**
   * Returns the MySQL datetime string representing the time from which inserts and changes will be
   * upserted to GlooX for a certain extension type. If the optional datetime override is provided, 
   * it will be returned regardless of everything else.
   * @global \mysqli $db
   * @param string $extensionType 'org' | 'note' | 'lipr' | "chpr'
   * @param string|null $sinceDateTimeOverride
   * @return string
   */
  private static function getSince(
      string $extensionType,
      ?string $sinceDateTimeOverride = null
  ): string
  {
    global $db;

    // If a datetime override was provided that's the one we need to use, and so our work in
    // this function is done. We can shourt circuit it.
    if($sinceDateTimeOverride!==null) return $sinceDateTimeOverride;

    // If a datetime override was not provided we check the database to see when the last full
    // upsert happened. If we find something, we return with that.
    $stmt = $db->prepare("SELECT synced_upto FROM datax_sync WHERE what='$extensionType'");
    $stmt->execute();
    $r = $stmt->get_result();
    if($r->num_rows === 1)
    {
      $d = $r->fetch_assoc();
      if($d["synced_upto"] !== null) return $d["synced_upto"];
    }

    // If we still don't have a datetime to work with, we return with a time that is surely before
    // all inserts and modifications done in our database in order to capture all data.
    return AGES_AGO;
  }
  

  /**
   * Retrieves the data that needs to be upserted based on the supplied MySQL query. It packs the 
   * data into appropriately sized chunks for multi curl, and formats it so that it is easily 
   * digestable by the multi upsert extension function. The type parameter is used to work out which
   * primitive id to use in the upsertion.
   * @global \mysqli $db
   * @param string $type 'org' | 'note' | 'lipr' | "chpr'
   * @param string $mysqlQuery
   * @return array
   */
  private static function getAndPackExtensionDataToUpsert(
      string $type,
      string $mysqlQuery
  ): array
  {
    global $db;
    $stmt = $db->prepare($mysqlQuery);
    $stmt->execute();
    $r = $stmt->get_result();
    if($r->num_rows === 0) return []; // if there is no data to upsert we are done

    $i = 0;
    while($d = $r->fetch_assoc())
    {
      foreach($d as $property => $value) {
        if($value === null || (is_string($value) && trim($value) === '')) {
          unset($d[$property]);
        } elseif(str_starts_with($property, "asBoolean_")) {
          $d[str_replace("asBoolean_", "", $property)] = (bool)$value;
          unset($d[$property]);
        }
      }
      if(isset($d["lat"]) && isset($d["lng"])) {
        $d["coordinates"] = ["lat" => $d["lat"], "lng" => $d["lng"]];
        unset($d["lat"]);
        unset($d["lng"]);
      }
      $dd[(floor($i/MULTI_CURL_CHUNK_SIZE))][] = [
        self::$ids[$type][\D\DATA_X_PRODUCTION], 
        ["id"],
        $d
      ];
      $i++;
    }
    return $dd;
  }


  /**
   * Records when a certain type of data was synced with GlooX. The recorded datetime is useful to
   * tell when the last time a certain data type was synced. The next syncing only needs to 
   * consider changes that happened since then.
   * @param string $syncType 'org' | 'note' | 'lipr' | "chpr'
   * @param \DateTimeImmutable $syncTime
   * @return bool
   */
  private static function recordGlooXDataSync(
      string $syncType, 
      \DateTimeImmutable $syncTime
  ): bool
  {
    global $db;
    return $db->query("INSERT INTO datax_sync (what, synced_upto) 
                       VALUES ('$syncType', '".$syncTime->format("Y-m-d H:i:s")."')
                       ON DUPLICATE KEY UPDATE
                       synced_upto='".$syncTime->format("Y-m-d H:i:s")."'");
  }


  /**
   * Return the requested properties of an ActorSignal.
   * @param string $id GlooX ID of the required actor signal
   * @param string $requestedKeysCommaSeperated 
   *               ActorSignal properties, one or more of: 
   *               id, signalId, actorType, actorId, metadata, payload, app_context, owner,
   *               opContext, createdAt, updatedAt
   * @return \stdClass object with properties listed in $responseKeysCommaSeperated
   */
  public static function query_getActorSignal(
      string $id,
      string $requestedKeysCommaSeperated
  ): \stdClass 
  {
    $q = 'query getActorSignal{getActorSignal(id:"'.$id.'"){'.$requestedKeysCommaSeperated.'}}';
    $res = self::curlMulti([json_encode(["query" => $q])]);
    return $res[0]->data;
  }


  /**
   * Sends an array of actor signals with multi curl.
   * @param $chunk
   * @return $array
   */
  private static function mutation_reportActorSignal_multi(
      array $chunk
  ): array
  {
    if(empty($chunk)) return []; // nothing to do, short circuit
    
    foreach($chunk as $actorSignalData) {
      list($signalId, $actorType, $actorId, $metadata, $payload, 
           $requestedKeysCommaSeperated) = $actorSignalData;
      $q = 'mutation reportActorSignal{reportActorSignal(input:'
         . '{signalId:"'.$signalId.'",actorType:"'.$actorType.'",actorId:"'.$actorId.'"';
      if($metadata!==null) {
        $q .= ',metadata:[';
        foreach($metadata as $key => $value) {
          $key = (string)$key;
          $value = (string)$value;
          $value = str_replace('"', '\\"', $value);
          $q .= '{key:"'.$key.'",value:"'.$value.'"}';
        }
        $q .= ']';
      }
      if(!empty($payload)) {
        $q .= ',payload:'.json_encode(json_encode($payload));
      }
      $q .= '}){'.$requestedKeysCommaSeperated.'}}';
      $requests[] = json_encode(["query" => $q]);
    }

    return self::curlMulti($requests);
  }
    
  
  /**
   * Upserts a chunk of extensions with multi curl.
   * @param array $chunk
   * @return array
   */
  private static function mutation_upsertExtension_multi(array $chunk): array {
    if(empty($chunk)) return []; // nothing to do, short circuit
        
    foreach($chunk as $extensionData) {
      list($primitiveTypeId, $idFields, $data) = $extensionData;
      $q = 'mutation upsertExtension{upsertExtension(input:{primitiveTypeId:"'.$primitiveTypeId.'"'
         . ',idFields:'.json_encode($idFields)
         . ',data:'.json_encode(json_encode($data)).'})}';
      $requests[] = json_encode(["query" => $q]);
    }

    return self::curlMulti($requests);
  }


  /**
   * This little bad boy provides the MySQL query strings for upsert extension operations, which are
   * mostly all the same except for a string variable that determines what type of extension we are
   * working with.
   * @param string $type 'org' | 'note' | 'lipr' | "chpr'
   * @param string $since MySQL datetime string
   * @return string
   */
  private static function mysqlQueryForExtensionData(
    string $type,
    string $since
  ): string
  {
    $q = [
    // organization
      "org"     => "SELECT
                      CONCAT('org', id) AS id,
                      placeID AS placeId,
                      DATE_FORMAT(reg, '%Y-%m-%dT%TZ') AS createdAt,
                      DATE_FORMAT(timestamp, '%Y-%m-%dT%TZ') AS updatedAt,
                      name,
                      address,
                      city,
                      state,
                      zip,
                      phone,
                      url,
                      url_privacy_policy AS urlOfPrivacyPolicy,
                      ST_X(location) AS lat,
                      ST_Y(location) AS lng,
                        CASE
                          WHEN can_be_parent THEN NULL
                          WHEN weekend_attendance < 1 THEN '0'
                          WHEN weekend_attendance <= 199 THEN '1 - 199'
                          WHEN weekend_attendance <= 999 THEN '200 - 999'
                          WHEN weekend_attendance <= 2999 THEN '1000 - 2999'
                          WHEN weekend_attendance <= 4999 THEN '3000 - 4999'
                          WHEN weekend_attendance > 4999 THEN '5000 or more'
                          ELSE NULL
                      END as weekendAttendance,
                        CASE
                          WHEN !can_be_parent THEN NULL
                          WHEN number_of_churches < 1 THEN '0'
                          WHEN number_of_churches <= 199 THEN '1 - 199'
                          WHEN number_of_churches <= 799 THEN '200 - 799'
                          WHEN number_of_churches <= 1999 THEN '800 - 1999'
                          WHEN number_of_churches <= 3999 THEN '2000 - 3999'
                          WHEN number_of_churches > 3999 THEN '4000 or more'
                          ELSE NULL
                      END as numberOfChurches,
                      IF(can_be_parent, 'network', 'single') type
                    FROM churches "
                    . (($since !== AGES_AGO) ? "WHERE timestamp>='$since' " : ""),
      // prayer journal note
        "note"  => "SELECT
                      CONCAT('note', id) AS id,
                      note AS txt,
                      DATE_FORMAT(added, '%Y-%m-%dT%TZ') AS createdAt,
                      DATE_FORMAT(timestamp, '%Y-%m-%dT%TZ') AS updatedAt,
                      prayer_request AS asBoolean_isPrayerRequest,
                      current_prayer_request AS asBoolean_isCurrentPrayerRequest
                    FROM member_household_notes "
                    . (($since !== AGES_AGO) ? "WHERE timestamp>='$since' " : ""),
      // light prayer request
      "lipr"  => "SELECT
                    CONCAT('lipr', id) AS id,
                    light,
                    prayer_request AS txt,
                    DATE_FORMAT(added, '%Y-%m-%dT%TZ') AS createdAt,
                    DATE_FORMAT(timestamp, '%Y-%m-%dT%TZ') AS updatedAt,
                    DATE_FORMAT(deleted_at, '%Y-%m-%dT%TZ') AS deletedAt,
                    DATE_FORMAT(answered_at, '%Y-%m-%dT%TZ') AS answeredAt
                  FROM prayer_requests_lights "
                  . (($since !== AGES_AGO) ? "WHERE timestamp>='$since' " : ""),
      // church prayer request
      "chpr"  => "SELECT
                    CONCAT('chpr', id) AS id,
                    org,
                    prayer_request AS txt,
                    DATE_FORMAT(added, '%Y-%m-%dT%TZ') AS createdAt,
                    DATE_FORMAT(timestamp, '%Y-%m-%dT%TZ') AS updatedAt,
                    DATE_FORMAT(deleted_at, '%Y-%m-%dT%TZ') AS deletedAt,
                    DATE_FORMAT(answered_at, '%Y-%m-%dT%TZ') AS answeredAt
                  FROM prayer_requests_orgs "
                  . (($since !== AGES_AGO) ? "WHERE timestamp>='$since' " : ""),
    ];
    return $q[$type];
  }
  
  
  // CURL ------------------------------------------------------------------------------------------


  /**
   * Sends the array of requests with multi curl. Each request needs to be in JSON format. Set the 
   * auth parameter to false if you don't want to send the bearer token.
   * @param array $requests Array of json encoded graphql queries.
   * @param bool $auth Whether to send bearer token. True by default.
   * @return array Array of json decoded objects.
   * @throws \Exception
   */
  private static function curlMulti(array $requests, bool $auth = true): array
  {
    if(empty($requests)) return []; // nothing to do, short circuit

    foreach($requests as $req) {
      $curlHandles[] = self::curlPrepareHandle($req, $auth);
    }
    $mh = curl_multi_init();
    foreach($curlHandles as $ch) {
      curl_multi_add_handle($mh, $ch);
    }
    curl_multi_setopt($mh, CURLMOPT_PIPELINING, MULTI_CURL_PIPELINING);
    curl_multi_setopt($mh, CURLMOPT_MAX_HOST_CONNECTIONS, MULTI_CURL_MAX_HOST_CONNECTIONS);
    curl_multi_setopt($mh, CURLMOPT_MAX_TOTAL_CONNECTIONS, MULTI_CURL_MAX_TOTAL_CONNECTIONS);
    
    do {
        curl_multi_exec($mh, $running);
        curl_multi_select($mh);
        
        while (false !== ($info = curl_multi_info_read($mh))) {
          if($info["result"]!==0) {
            self::logError(curl_strerror($info["result"]));
            throw new \Exception("Curl error. Check DataX error log.");
          }
        }
        
    } while ($running > 0);
    
    $responses = [];
    $i = 0;
    foreach($curlHandles as $ch) 
    {
      self::log($requests[$i]);
      $res = curl_multi_getcontent($ch);
      $decodedResponse = json_decode($res);
      if($decodedResponse===null) 
      {
        self::LogErrorThrow($requests[$i], "Curl response is not in json format. ".$res);
      }
      if(!($decodedResponse instanceof \stdClass)) {
        self::LogErrorThrow($requests[$i], "Decoded curl response is not a standard object.".$res);
      }
      $responses[] = $decodedResponse;
      $time = curl_getinfo($ch, CURLINFO_TOTAL_TIME_T);
      $ip = curl_getinfo($ch, CURLINFO_PRIMARY_IP);
      self::log("[CURLINFO_TOTAL_TIME_T: ".$time." ms] [CURLINFO_PRIMARY_IP: ".$ip."] ".$res);
      curl_multi_remove_handle($mh, $ch);
      $i++;
    }
    
    return $responses;
  }
  
  
  /**
   * Prepares a curl handle, setting the URL and options, and adding the request itself. Set the
   * auth parameter to false if you don't want to send the bearer token.
   * @param string $req
   * @param bool $auth
   * @return \CurlHandle
   */
  private static function curlPrepareHandle(string $req, bool $auth = true): \CurlHandle {
    $ch = curl_init(\D\DATA_X_ENDPOINT);
    curl_setopt($ch, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $req);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, MULTI_CURL_CONNECTTIMEOUT); 
    curl_setopt($ch, CURLOPT_TIMEOUT, MULTI_CURL_TIMEOUT);
    $extraHeaders = ["Content-Type: application/json"];
    if($auth) {
      // The option CURLOPT_XOAUTH2_BEARER does not seem to be working so we are adding it to the
      // header manually. curl_setopt($ch, CURLOPT_XOAUTH2_BEARER, \D\DATA_X_BEARERTOKEN);
      $extraHeaders[] = "Authorization: Bearer " . \D\DATA_X_BEARERTOKEN;
    }
    curl_setopt($ch, CURLOPT_HTTPHEADER, $extraHeaders);
    return $ch;
  }


  // LOGGING ---------------------------------------------------------------------------------------
  

  /**
   * Logs the string to the general log.
   * @param string $str The string to log.
   * @return void
   */
  private static function log(string $str): void
  {
    if(\D\DATA_X_DO_GENERAL_LOG) 
    {
      \D\ETC\log(4, $str);
    }
  }
  

  /**
   * Logs the string to the error log.
   * @param string $str The string to log.
   * @return void
   */
  private static function logError(string $str): void
  {
    if(\D\DATA_X_DO_ERROR_LOG) 
    {
      \D\ETC\log(5, $str);
    }
  }


  /**
   * Logs the request and the error to the error log.
   * @param string $req The request being sent.
   * @param string $err The error string to log.
   * @return void
   */
  private static function logRequestAndError(string $req, string $err): void
  {
    self::logError($req . " - " . $err);
  }


  /**
   * Logs the request and the error to the error log, and throws the error.
   * @param string $req The request being sent.
   * @param string $err The error string to log and to throw.
   * @return void
   * @throws \Exception
   */
  private static function LogErrorThrow(string $req, string $err): void
  {
    self::logRequestAndError($req, $err);
    throw new \Exception($err);
  }


}
