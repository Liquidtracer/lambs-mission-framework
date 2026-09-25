# Lambs Mission Framework – agentoversikt

LMF 2.0.0 i `LMF_DEV.Altis`. Dokumentet er agentens tekniske kart og varige prosjektkontekst. Kode/config beskriver implementasjonen; brukerkrav og avklarte designvalg beskriver hensikten. Arbeidsregler står i `AGENTS.md`, praktiske kall i `LMF_MM_FUNCTIONS.md`.

Les **Felles prosjektkontekst** før teknisk arbeid, deretter relevante modulavsnitt og avhengighetene i indeksen. Les hele dokumentet ved bred gjennomgang eller uklart omfang. Oversikten erstatter ikke undersøkelse av berørt kode.

**Avklart avgrensning – Forward Deploy:** Systemet beholdes kun for bakoverkompatibilitet for mission makers som ønsker å bruke det. Det skal ikke vurderes, gjennomgås eller endres med mindre brukeren uttrykkelig ber om arbeid med Forward Deploy. Dette gjelder også generelle LMF-kartlegginger, feilgjennomganger og forbedringsforslag. Eksisterende beskrivelse beholdes som referanse, ikke som en liste over oppfølgingsarbeid. Avgrensningen gjelder Forward Deploy, ikke den delte Paradrop-modulen.

**Avklart avgrensning – Vehicle Service:** Komponenten beholdes, men er ifølge mission maker praktisk talt ikke i bruk. Den skal ikke vurderes, gjennomgås eller endres med mindre brukeren uttrykkelig ber om arbeid med Vehicle Service. Dette gjelder også generelle LMF-kartlegginger, feilgjennomganger og forbedringsforslag. Eksisterende beskrivelse beholdes som referanse, ikke som en liste over oppfølgingsarbeid. Avgrensningen gjelder `framework/vehicleService/`, ikke øvrig kjøretøyinitialisering eller asset spawnere.

**Evidens:** Beskrivelsene bygger på den statiske kartleggingen 2026-09-23 og tidligere dokumentert kilde-/testerfaring. Dokumentasjonsredigeringen er ikke en ny full engine-, parser- eller spillverifisering. Installert modversjon og samlet dedicated-/JIP-godkjenning er ikke etablert. «Design» er avklart hensikt, «Implementasjon» er kodebeskrivelse, «Observasjon» er rapportert runtime og «Uavklart» er en konkret begrensning eller manglende verifisering. Umerket teknisk beskrivelse angir implementasjonen, ikke et testbevis. Kildelenkene er tidligere grunnlag; kontroller relevant aktuell dokumentasjon ved tekniske konklusjoner.

## Felles prosjektkontekst

### Lagdeling, struktur og grensesnitt

- `framework/`: gjenbrukbar LMF-kode, organisert etter system. Mapper angir ikke execution context; guards, initpunkt og kontrakter avgjør dette.
- `settings/`: LMF-konfigurasjon for mission makers. Se settings-tabellen nedenfor.
- `description.ext`: LMF-delene registrerer CfgFunctions, XEH, objektsortering og notifications og må følge frameworket ved overføring. Resten er mission-oppsett.
- `init.sqf`, `initServer.sqf`, `initPlayerLocal.sqf`, `onFlare.sqs`, `mission/` og Eden er mission-integrasjon. `initPlayerLocal.sqf` inneholder bare kommentarer og er et ledig integrasjonspunkt.
- `mission.sqm` lagres bevisst ubinarisert som versjonskontrollert Eden-output. Agenter kan lese og undersøke filen, inkludert Eden-navn, init-felt, triggere og modulsynkronisering. Filen skal aldri redigeres direkte; endringer gjøres kun gjennom Eden Editor.

Funksjonsnavn er `lmf_<system>_fnc_<handling>`. Registrerte funksjonsklasser samsvarer med `fn_<handling>.sqf`; undermapper endrer ikke systemtaggen. Runtime-definerte helpers bruker samme navneform, men defineres ved sine initpunkter. Registrering er ikke en API-whitelist: offentlig bruk avgjøres av kontrakt, eksempler og kallesteder. Manglende public/private-markering er akseptert design, ikke et ombyggingsbehov.

Mapper/handlinger bruker camelCase og beskrivende hele ord med etablerte fagforkortelser. Script-/includefiler har beskrivende navn uten `fn_`; execution context alene er ikke tilstrekkelig navn. XEH-filene, config-headere og settings følger etablerte konvensjoner. Detaljerte navne- og kommentarregler står bare i `AGENTS.md`.

LMF 2.0.0s systemnavn er ikke bakoverkompatible, og legacy-aliaser finnes ikke. Ved overføring må framework, settings, LMF-config, missionkall og eventuelle Eden-kall kontrolleres samlet. Aktive framework-helpers/state bruker `lmf_`; `a2k_*` under framework finnes bare i utkommentert historisk medical-kode. Missionens egne `a2k_*` skal ikke omdøpes som LMF-opprydding.

### Initialisering og ventebetingelser

Start inspeksjon i `description.ext`, `framework/functions.hpp`, `framework/XEH_preInit.sqf` og `framework/XEH_postInit.sqf`. Scheduled arbeid kan fortsette parallelt; startrekkefølge er ikke fullføringsrekkefølge.

1. **Config/funksjoner:** `description.ext` inkluderer `framework/functions.hpp` og `framework/notifications/CfgNotifications.hpp`. CfgFunctions gjør registrerte funksjoner tilgjengelige på hver maskin; dette er ikke en broadcast.
2. **CBA preInit:** `framework/XEH_preInit.sqf` inkluderer mission-settings og fargekonstanter, setter versjon/admin-UID-er, laster AI-settings synkront og deretter BFT-helpers/serverevents. Konfigurasjonen opprettes lokalt på hver maskin.
3. **Missionens event scripts:** `initServer.sqf` og `initPlayerLocal.sqf` inneholder bare kommentarer; ingen mission-spesifikk spillerinitialisering eller designator er definert der.
4. **CBA postInit:** LMF bruker generell XEH `init` på alle maskintyper. Fellesdelen starter ACRE, Support, betinget Supply Drop/Forward Deploy og AI-NVG samt inkluderer curator-/medical-events. Serverdelen initialiserer/publiserer warmup og chatkanal, starter markører, tripflare og warmupfrist. Ikke-interface-maskiner avslutter deretter. Spillerdelen venter på `player`, setter `AIThinkOnlyLocal`, registrerer gruppevarsler/EH-er/loadout og starter klientmoduler.
5. **CBA InitPost:** CBA tømmer oppstartens InitPost-kø etter Extended PostInit. `description.ext` ruter til de fem `lmf_objectSorting_fnc_sort*`-funksjonene. AI på `var_enemySide` går til AI-init; spillergear initialiseres eksplisitt i postInit. Sivilgrenen sender lokal `lmf_ai_civ_listener`, uten mottaker i denne kodebasen. Kjøretøy/kasser matches på konfigurerte classnames. Senere skapte objekters InitPost utsettes til neste frame; kode rett etter spawning kan ikke anta fullført objektinit.
6. **`init.sqf`:** Filen inneholder bare en kort header og er et ledig integrasjonspunkt for missionkode og midlertidige tester. Eventuell AI-spawning må fortsatt serveravgrenses.

Initfragmenter tekstinkluderes og arver scope/guards; de skal ikke startes separat: `framework/admin/initCuratorEvents.sqf`, `framework/medical/initUnconsciousEvent.sqf`, `framework/warmup/initWarmupState.sqf`, `framework/chat/createChatChannel.sqf`, `framework/chat/initChatMessageHandler.sqf`, `framework/spectator/initSpectatorEvents.sqf` og `framework/respawn/initDeathFeedback.sqf`. Admin-dagboken inkluderes av briefing, markørfragmenter av markøroppstart, teksturer av klient-postInit.

**Klientens avhengighetskjede:** Narrativ intro setter lokal `lmf_player_introComplete` → arsenal, objekt-/rolleactions og `lmf_player_menuInit` kan registrere menyer → Mission Info venter på `lmf_player_arsenalInit` når arsenal er aktivert og på hele menysekvensen → infoscriptet avsluttes → intro-uniten får simulering tilbake. Introsignalet betyr ikke avsluttet warmup eller ferdig innfading. Warmup-panel/safety kjører parallelt.

`lmf_player_menuInit` registrerer **BFT → Support → JIP Teleport → Forward Deploy**. Support registrerer parent, aktivert Supply Drop og Mine Clearance i denne rekkefølgen. Helperne defineres i modulenes init og kalles én gang fra sekvensen etter nødvendig state. Alle fire hovedvalg er arvede ACE class self-actions på `CAManBase`. Andre modders rekkefølge omfattes ikke. Equipment-menyene er separate; spawner/rolleactions opprettes på objektene.

**Uavklart:** Helper-/state-ventingen har ingen timeout. Manglende helper eller replisert state kan holde igjen senere menyer, innfading og frigivelse. Dette er en kodeutledet avhengighet, ikke en observert oppstartsfeil.

Initgrunnlag: [BIKI Initialisation Order](https://community.bohemia.net/wiki/Initialisation_Order), [CBA XEH-guide](https://github.com/CBATeam/CBA_A3/wiki/Extended-Event-Handlers-%28new%29), [CBA postInit](https://github.com/CBATeam/CBA_A3/blob/master/addons/xeh/fnc_postInit.sqf), [CBA init](https://github.com/CBATeam/CBA_A3/blob/master/addons/xeh/fnc_init.sqf). CBA-kilden bekrefter PostInit før InitPost; faktisk rekkefølge med installert modpakke er ikke runtime-kontrollert.

### Settings, maskiner og delt state

| Konfigurasjon | Forbruk og scope |
|---|---|
| `settings/cfg_Mission.sqf` | Inkluderes i preInit; globale `var_*` opprettes lokalt på hver maskin. Ikke et serverreplikert settings-objekt. |
| `settings/cfg_AI.hpp` | Inkluderes bare av `framework/ai/loadSettings.sqf` i preInit. Private verdier samles i lokal `lmf_ai_config`, med omvendte classname-oppslag. Våpenmetadata caches ved bruk i `lmf_ai_weaponCache`. |
| `settings/cfg_Player.sqf` | Private verdier inkluderes i loadout, vehicle/supply-init og UI. Support inkluderer filen på serveren for Rifleman-side/loadout. |
| `settings/cfg_Briefing.sqf` | Private data inkluderes og formateres av `framework/briefing/createBriefing.sqf`. |
| `CBA_settings.sqf` | Separat missionkonfigurasjon aktivert fra `description.ext`; ikke del av settings-include-flyten. |

Private includes er avhengige av forbrukerens scope; ikke erstatt dem med funksjonskall uten kontraktvurdering. Endring av `var_*` eller `lmf_ai_config` under runtime er lokal inntil eksplisitt nettverkssynkronisering. AI-registerets store HashMap-nøkler er ikke omfattet av camelCase-omdøping.

**Design:** Produksjonsmiljøet er dedicated med JIP. `lmf_ai_fnc_isSpawner` bruker `isServer`; HC-spawning er bevisst deaktivert fordi dagens volum ikke forsvarer kompleksiteten. Inaktiv HC-kode beholdes. Ikke anta støtte for locality-overføring av aktive AI-sekvenser.

| State/system | Skriver og distribusjon |
|---|---|
| `lmf_warmup` | Initialiseres på server; manuell adminavslutning setter/publiserer også fra klient. Ikke rent serverautoritativ. |
| `lmf_chatChannel` | Server oppretter kanal og publiserer ID. |
| BFT `lmf_bft_state` | Server skriver offentlig state på gruppen; klientene tegner lokalt. |
| Supply Drop | Server eier kvote og `lmf_supplyDrop_nextRequest`, publiserer teller/frist; klient sender bestilling. |
| Support | Server eier config, pending og dispatch; publiserer `lmf_support_state` og `lmf_support_nextDispatch`. |
| Forward Deploy | Register i serverens `lmf_deploy_hash`; CBA server-events mottar ønsker. |
| `lmf_currentRole` | Gear på unitens eier; rollen publiseres på uniten. |
| Fire support | Serverlokal batteristate, offentlig `lmf_artilleryBusy` for klient/JIP. |

JIP bygger klientens briefing, actions og trackers fra oppstart og gjeldende state. Respawn er et separat forløp; klasse-actions kan overleve spillerobjektbytte, men parameterbinding til opprinnelig unit kan fortsatt begrense tilgjengeligheten. Engangsmeldinger/leveringssekvenser replayes ikke. Objektbundet persistent remote execution brukes blant annet til spawner-delete og BFT-objekttracking; sletting og gjentatte kall må vurderes mot JIP-ID-kontrakten, uten antakelse om rekkefølge mellom persistente kall.

`description.ext` har ingen mission-lokal `CfgRemoteExec`; effektiv engine-/server-/modpolicy avgjør eksponering. Klienter med interface aktiverer `AIThinkOnlyLocal` (dokumentert fra Arma 3 2.20); remote AI-targetdata kan derfor ikke forventes tilgjengelig der. Hosted har også interface og omfattes; dedicated/HC gjør ikke.

Eksterne kall finnes til CBA, ACE/ACEX, ACRE og LAMBS Danger. ZEN registreres bare hvis funksjonen finnes; øvrige avhengigheter har ikke tilsvarende generell availability-guard. Installerte versjoner er ikke fastslått.

Felles referanser: [Functions Library](https://community.bohemia.net/wiki/Arma_3%3A_Functions_Library), [PreProcessor](https://community.bohemia.net/wiki/PreProcessor_Commands), [private](https://community.bohemia.net/wiki/private), [Locality](https://community.bohemia.net/wiki/Locality_in_Multiplayer), [publicVariable](https://community.bohemia.net/wiki/publicVariable), [setVariable](https://community.bohemia.net/wiki/setVariable), [remoteExec](https://community.bohemia.net/wiki/remoteExec), [CfgRemoteExec](https://community.bohemia.net/wiki/CfgRemoteExec), [setMissionOptions](https://community.bohemia.net/wiki/setMissionOptions).

### Modulindeks og integrasjonspunkter

Stiene nedenfor er startpunkter, ikke en komplett filfortegnelse. Følg kall til avhengigheter før endringer i en kontrakt.

| Modulavsnitt | Startpunkt | Les også |
|---|---|---|
| AI-init, spawning og garrison | `framework/ai/fn_initUnit.sqf`, `framework/ai/spawning/` | Settings, gruppehåndtering, båt/heli/paradrop etter spawntype |
| AI-grupper, hunters og båter | `framework/ai/groups/`, `framework/ai/tasks/`, `framework/ai/boats/` | Spawning, BFT ved callsigns |
| Helikoptertransport | `framework/ai/spawning/fn_spawnVehicleQrf.sqf` | Gruppehåndtering/converge |
| Paradrop og Forward Deploy | `framework/paradrop/`, `framework/forwardDeploy/` | Spawning eller Supply Drop ved deres payloads; Forward Deploy kun ved uttrykkelig forespørsel, se avgrensningen øverst |
| Support og kartvalg | `framework/support/initSupport.sqf` | Supply Drop, equipment, radio, BFT, notifications |
| Supply Drop | `framework/supplyDrop/initSupplyDrop.sqf` | Support/kartvalg, paradrop, AI-callsign, BFT |
| BFT og kart | `framework/bft/`, `framework/map/configureMap.sqf` | Init/state, notifications |
| Spilleroppsett, asset spawnere og service | `framework/equipment/`, `framework/assetSpawner/`, `framework/vehicleService/` | Settings, objektsortering, intro; Vehicle Service kun ved uttrykkelig forespørsel, se avgrensningen øverst |
| Warmup, Mission Info og JIP-teleport | `framework/warmup/`, `framework/missionInfo/`, `framework/jipTeleport/` | Menykjeden, admin, equipment, Support/Supply Drop |
| Respawn, spectator, medical og hit-effekter | `framework/respawn/`, `framework/spectator/`, `framework/medical/` | Equipment, notifications |
| UI, briefing og gruppevarsler | `framework/notifications/`, `framework/briefing/`, `framework/groupNotifications/` | Intro, CBA player-events |
| Admin, chat og radio | `framework/admin/`, `framework/chat/`, `framework/radio/` | Warmup, spectator, remote-exec-policy |
| Fire support | `framework/ai/fireSupport/fn_fireSupportAtTarget.sqf` | Radio, BFT |

Eden-integrasjon: valgfrie `ammoSpawner`/`ammoPad`, `groundSpawner`/`groundPad`, `airSpawner`/`airPad`, `crateRoles`, `RRR` og `LAMBS_Hospital`; se spawner-/markørkode. Supply Drop forventer markøren `respawn`. Support krever objektet `lmf_supportStart`. Forward Deploy registrerer objektvariabelen `lmf_deploy_unowned` før postInit. JIP-teleport bruker unitens lagrede startposisjon, ikke respawn-markøren. Missionfilen kan inspiseres som tekst; plasseringer og integrasjon er ikke spillverifisert. `onFlare.sqs` videresender engine-eventet til `lmf_ai_fnc_onFlare`.

## Modulkontrakter

### AI-init, spawning og garrison

**Filer:** `framework/objectSorting/`, `framework/ai/fn_initUnit.sqf`, `framework/ai/fn_initGroundVehicle.sqf`, `framework/ai/fn_initAirVehicle.sqf`, `framework/ai/fn_initWaterVehicle.sqf`, `framework/ai/fn_buildWeaponLoadout.sqf`, `framework/ai/fn_manageNvg.sqf`, `framework/ai/eventHandlers/`, `framework/ai/spawning/`.

- Init fortsetter bare ved lokal unit/vehicle. Classname-oppslag i AI-registeret velger rolle/gear; soldatloadout bygges som Unit Loadout Array og påføres samlet. Attachment-/magasinoppslag caches. Hit-reaksjonen har lokal per-unit cooldown.
- NVG-manageren behandler eksisterende fiendtlig AI ved oppstart og deretter dag-/nattskifte; ny AI får nattens NVG i første loadout.
- `framework/ai/spawning/spawnDefinitions.sqf` er et include med vehicles/roller, gruppesammensetninger og privat `_typeMaker`. `spawning/` eier gruppeopprettelse; `tasks/` eier registrerte `task*`-entrypoints.
- `lmf_ai_fnc_getPlayerProximityState` brukes av infantry QRF/hunters, vehicle QRF og para QRF, ikke patrol/garrison. Den vurderer faktiske spillere via spillerens kjøretøy; nær bakke-spiller prioriteres over nær luft-spiller. Luftventingen godtar `airDistance` eller `groundClose`, med eksisterende 5/10-sekunderskontroller og uten cache mellom kontroller.
- Vehicle-QRF sender crew-classname som femte argument til `BIS_fnc_spawnCrew`: CARARMED/RIFLEMAN, APC/TANK/CREW, HELITRANSPORT/HELIATTACK/PILOT. UAV bruker separat `createVehicleCrew`.
- `spawnParadropQrf` er scheduled/serverbegrenset, eier fly/payload/tickets/oppfølging og delegerer unit-/objektslipp til paradrop. Dropzone er markør, trigger eller location; eneste støttede array er `[0,0,0]` for autonom modus. Autonom modus leser spawnobjektets retning før posisjonskonvertering; array-spawn får tilfeldig retning. Fast dropzone bestemmer retningen mot sonen. ZEN kan sende kallet bredt; `isSpawner` avgrenser utførelsen.

**Garrison-design og implementasjon:** Initialstilling bruker `insideBuilding > 0`; eventvalg bruker `== 1`, med `lmf_ai_fnc_hasOverheadCover` som fallback. Taktesten går fem meter fra øynene, VIEW/FIRE og deretter FIRE/NONE ved bom; også trekroner kan telle som dekning. Initialt velges 50/50 stående/knestående under tak og knestående/liggende ute. Dekkede eventvalg gir 50 % stående, 25 % ved høyst halv opprinnelig styrke, eller 15 % ved suppression >= 0.5; ellers knestående. Ukjent suppression endrer ikke tapsvalget.

FiredNear gjelder ikke-ledere til fots, med individuell 6–15-sekunders cooldown sjekket ved event; første event kan reagere straks. Utendørs stillingsvalg skjer bare ved første FiredNear. EnemyDetected har ingen slik cooldown og dobbelvekter liggende ute. Hvert fiendtlig FiredNear under 15 meter fra avfyringsstedet har separat 5 % bevegelsessjanse, uavhengig av cooldown; vennlige skudd kan påvirke stilling, men ikke denne bevegelsen. Stillhet gir ingen periodisk eksponering.

`lmf_ai_fnc_clearGarrisonStance` fjerner FiredNear/stillingsbinding ved bevegelse, død, overgivelse, reassignment og ny tasking. Frigitte forsvarere får ikke nye EnemyDetected-stillinger. FiredNear rydder også ved observerte eksterne PATH-, gruppe-, kjøretøy-, locality- eller captive-endringer. Ventende overgivelse stanser reaksjonene; fullført overgivelse gjenopprettes ikke automatisk.

Ved gruppetap, én–to levende og manglende støtte rundt den drepte er overgivelsessjansen felles 25 %. Hver kandidat må ha levende ikke-captive fiende innen 30 meter horisontalt både før og etter tilfeldig venting. Kjøretøysoldater inngår; sideforhold brukes uten krav om deteksjon/sikt. Avvist kandidat frigir ikke gruppestatus mens andre venter/har overgitt seg. Enslige uten overgivelse går til gruppehåndtering.

**Uavklart:** Garrison-reaksjonene er statisk kontrollert, ikke parser-/spillverifisert. State er serverlokal; HC-overføring/hot-reload støttes ikke. Dynamic Simulation-avstand er 1250 meter og garrison-grupper meldes inn, men global Eden-toggle og øvrige merkede grupper må undersøkes i Eden.

Grunnlag: [Event Handlers](https://community.bohemia.net/wiki/Arma_3%3A_Event_Handlers), [insideBuilding](https://community.bohemia.net/wiki/insideBuilding), [lineIntersectsSurfaces](https://community.bohemia.net/wiki/lineIntersectsSurfaces), [getSuppression](https://community.bohemia.net/wiki/getSuppression), [nearEntities](https://community.bohemia.net/wiki/nearEntities), [BIS_fnc_sideIsEnemy](https://community.bohemia.net/wiki/BIS_fnc_sideIsEnemy), [Dynamic Simulation](https://community.bohemia.net/wiki/Arma_3_Dynamic_Simulation).

### AI-grupper, hunters og båter

**Filer:** `framework/ai/groups/`, `framework/ai/tasks/fn_taskHunt.sqf`, `framework/ai/tasks/fn_taskConverge.sqf`, `framework/ai/tasks/fn_taskPatrol.sqf`, `framework/ai/boats/`.

`assignCallsign` er serverautoritativ, med lokal counter per reservert LMF-prefix og `setGroupIdGlobal`. Ugyldig gruppe, tomt prefix eller ikke-serverkall gir tom streng. Navnene er sekvensielle innen helperen; manuelt navngitte grupper kontrolleres ikke for kollisjon. Enslige støttede LMF-overlevende ungarrisones og joiner nærmeste kvalifiserte gruppe, ellers GUARD. `taskConverge` krever lokal gruppe; `taskPatrol` velger vannposisjoner når lederen sitter i Ship.

**Hunters:** `taskHunt` startes scheduled med `spawn`, søker hvert 30. sekund etter nærmeste faktiske ikke-sivile spiller med kjøretøyets bakkekontakt innen lederens radius og gir bevegelsesordrer. Ingen LAMBS taskRush eller rush-EH-er brukes. Spawnbeskyttelsen er 500 meter. Løkken krever mer enn én levende soldat. Spawneren lagrer lokal `lmf_ai_huntScript` og UnitKilled-handler samlet unscheduled; ved høyst én levende termineres jakt før reassignment/GUARD, LAMBS-deaktivering fjernes og gammel bevegelse erstattes. Gruppebytte følges av doFollow; huntergrupper er ikke selv join-mottakere. Ingen særbehandling av énmannsspawn.

Båthunter med mål reserverer landing før `landBoatGroup`; jaktordrer/GUARD holdes tilbake under landing. Etter frigitt flagg og leder til fots slettes landingswaypoints én gang ved neste jaktoppdatering, også uten mål. Uten mål gis doMove til soldatenes egne posisjoner; det gjenopprettes ikke GUARD etter avstigning. Grupper som ikke har landet beholder GUARD-fallback. Mislykket strandsøk kan prøves igjen; fastlåst landing har ingen ny timeout.

**Båtforløp:** `spawnBoatForGroup` brukes av patrol, infantry QRF og hunters ved vannspawn og kaller `initBoatAssault`. Landing fra EnemyDetected, converge og hunt reserverer `lmf_taskConverge_active` lokalt før helperkallet. Kontroll/reservasjon skjer samlet unscheduled; direkte kall til intern `landBoatGroup` må reserveres av kalleren. Flagget holdes gjennom tilfeldige avstigningsforsinkelser til ingen levende gruppemedlemmer sitter i båten eller båten er slettet. Slettet gruppe avslutter uten state-skriving; mislykket strandsøk frigir flagget og gir GUARD ved båten.

`findShorelinePosition` søker fra 500 meter rundt målet, dobler til kallers grense og bruker første treff som sentrum for et uavhengig 500-meters spredningssøk. Ved mislykket spredning brukes første treff; ved intet første treff returneres `[]`. Spredningen kan gå utenfor kallers radius. Resultatet forskyves 10 meter mot båten, høyde 0. Søket garanterer ikke nærmeste strand, sammenhengende kyst, landforbindelse eller farbar innseiling; båter deler ikke reservasjon/landingssted.

`initBoatAssault` har også en femsekunders lokal GUARD-kontroll: bakkekontakt og absolutt fart under 20 km/t utløser reservert `dismountBoatGroup` uten nytt strandsøk/waypointendring. Andre waypointtyper og flytende båter omfattes ikke. Kontrollen slutter ved utløsing, ingen levende i opprinnelig båt, ødelagt/slettet båt/gruppe eller tapt locality. Felles avstigning beholder leaveVehicle, AWARE, tilfeldig forsinkelse og røyk. QRF beholder GUARD; hunt rydder egne landingswaypoints.

**Observasjon/uavklart:** Tidligere båthunter landet, men ga fjerne steder og gjenværende GUARD. Gjeldende strandsøk/GUARD-retting og autonom avstigning er ikke spillverifisert; flere båter, siste overlevende og dedicated/JIP er uavklart. Støtte for eierskifte under landing er ikke etablert.

Grunnlag: [terminate](https://community.bohemia.net/wiki/terminate), [isNil](https://community.bohemia.net/wiki/isNil), [BIS_fnc_findSafePos](https://community.bohemia.net/wiki/BIS_fnc_findSafePos), [isTouchingGround](https://community.bohemia.net/wiki/isTouchingGround), [CBA venting](https://github.com/CBATeam/CBA_A3/blob/master/addons/common/fnc_waitUntilAndExecute.sqf).

### Helikoptertransport

**Fil:** `framework/ai/spawning/fn_spawnVehicleQrf.sqf`, med gruppe-/converge-helpers. **Design:** Bemannet transport fortsetter innsettingsforsøket; mislykket LZ-søk skal aldri sende passasjerene i retrett.

- Normal rute er TR UNLOAD ved dynamisk `Land_HelipadEmpty_F`, så MOVE 25 km bort med CARELESS/BLUE; infanteriet får GUARD. GETOUT/synkronisering/aktivering for infanteriet er utkommentert. Ikke gjeninnfør dette uten vurdering. Cargo assignes før moveInCargo; normal innsetting har ingen scriptet/tvungen utlasting.
- Scheduled LZ-søk rangerer åpne områder innen 500 meter, uten særskilt terrengstraff. Kandidaten kontrolleres mot helikoptertypen og krever 150–500 meter fra målet, land, objektklaring og gradientkrav. Ved bom gjentas søket etter fem sekunder uten forsøksgrense/radiusutvidelse. TR UNLOAD → MOVE bygges samlet unscheduled etter godkjent LZ. Helipaden brukes som posisjonsgrunnlag, ikke waypointAttachObject.
- Pilotgruppen lagrer cargo i `lmf_heliTransport_cargo`. `lmf_heliTransport_active` skjermer pilotwaypoints mot converge; infanteriets `lmf_heliTransport_vehicle` skjermer gruppen mens levende er om bord. Infanteriet er joinable, men mottar ikke overlevende før lederen er til fots. Ingen særprioritet for pilotene og ingen gjeninnført infanteri-UnitKilled-join-handler/lysoppsett.
- Femsekunders cleanup krever ingen spillere innen 5 km og ingen levende registrerte passasjerer om bord før heli/crew slettes. LZ-bom sletter ikke passasjerer. Helipad fjernes ved cleanup eller dødt/ikke-lokalt heli. Tickets teller opprinnelig crew også etter gruppebytte.
- En serversekvens hvert 10. sekund evakuerer ved lokal, immobil transport med bakkekontakt og 3D-fart under 1 m/s, eller når alt levende crew har forlatt den. `lmf_heliTransport_abandoned` avbryter LZ-søk; crew beholder tasking-sperren under avstigning. EH/waypoints fjernes én gang, AWARE/RED settes og leaveVehicle/unassignVehicle/doGetOut brukes uten moveOut eller gjentatte ordre. Passasjerer får utstigningsordre bare på bakken ved lav fart og beholder/får GUARD.
- Når alt levende crew er ute, frigjøres sperren og gruppesøk kjøres én gang: annen levende joinable gruppe på `var_enemySide`, leder innen 1500 meter og ikke over vann; transportinfanteriets leder må være til fots. Crew joiner samlet nærmeste kandidat, ellers GUARD. Ingen locality-overtakelse.
- Samme sekvens har hovering-workaround. To kvalifiserende målinger oppdaterer aktivt TR UNLOAD til samme posisjon. Krav: aktiv/ikke evakuert, lokale levende pilot/heli, canMove, pilot WAIT, luftbåren over 10 m ATL, fart under 1 m/s og landAt-modus None/tom. Flagget nullstilles etter inngrep eller bortfalt vilkår; vedvarende tilfeller kan oppfriskes hvert 20. sekund.

**Observasjon:** RPT viste TR UNLOAD/pilot WAIT; manuell waypointoppfriskning ga bevegelse. Brukertest viste bedre evakuering/crew-join. Dette fastslår ikke hover-årsak eller fullført innsetting.

**Uavklart:** Transporten er under utprøving. Automatisk workaround, join-kvalifisering og LZ-kvalitet er bare statisk kontrollert; samlet dedicated/JIP gjenstår. Ingen garanti for egnet LZ, kollisjonsfri landing eller fullføring. `canMove` er ikke rotorsensor og omfatter drivstoffmangel; velt med canMove true evakueres ikke. Bakkekontakt varierer med underlag. Bevisstløse/fastsittende kan bli igjen uten tvangsutlasting; ingen ny ordre gis hvis crew ikke kommer ut. BIKIs synkroniserte TR UNLOAD/GETOUT-oppskrift er ikke denne arbeidskopiens usynkroniserte variant.

Grunnlag: [Waypoints](https://community.bohemia.net/wiki/Waypoints), [selectBestPlaces](https://community.bohemia.net/wiki/selectBestPlaces), [findEmptyPosition](https://community.bohemia.net/wiki/findEmptyPosition), [isFlatEmpty](https://community.bohemia.net/wiki/isFlatEmpty), [canMove](https://community.bohemia.net/wiki/canMove), [getUnitState](https://community.bohemia.net/wiki/getUnitState), [landAt](https://community.bohemia.net/wiki/landAt), [setWaypointPosition](https://community.bohemia.net/wiki/setWaypointPosition).

### Paradrop og Forward Deploy

**Filer:** `framework/paradrop/`, `framework/forwardDeploy/initForwardDeploy.sqf`, `framework/forwardDeploy/fn_deployUnitsAndAssets.sqf`.

**Design:** `lmf_paradrop_fnc_paradropPassengers` er mission-entrypoint for eksisterende AI-styrt, serverlokalt fly/helikopter. Spillere er støttet som passasjerer; spillerpilot er ikke tilsiktet kontrakt. Flyet må være lokalt; callsign/BFT krever dagens serveroppsett.

Dropzone kan være markør/trigger. Kallinstansens høyde bakes inn i waypoint-statementet. Cargo-/FFV-units og øvrige om bord utenfor pilotens crew-gruppe slippes; flightcrew blir. AI-spawnere sender egne unitlister direkte til helperen og bruker ikke dette setevalget. Flysekvensen eier approach, slipp og retur; lokal cleanup har én 3-sekunders CBA-PFH per sekvens med eksisterende 5000-metersvilkår, adskilt fra avstignings-/returovervåking.

`dropUnit`, `dropUnitLocal`, `dropObject` og `fireCountermeasures` er interne helpers. Remote payloads rutes objektmålrettet uten persistent replay. Player-profilen har steerable fallskjerm, rød chemlight og prone etter utstigning. EJECT-spillere er skadebeskyttet fra før utkast til to sekunder etter registrert fallskjermutstigning, deretter allowDamage true uten bakkekontroll. Dette beskytter også vanlig skade under nedstigning, men fjerner ikke skader/sprett. EJECT-AI får skade på straks de er i fallskjerm; POSITION/BACKPACK har andre forløp. Para-QRF bruker ACE non-steerable backpack og gjenoppretter backpack/items.

`dropObject` håndterer luftplasserte objekter selv; ACE_CARGO delegerer release til intern `ace_cargo_fnc_paradropItem`, deretter orientering/fart/landing/cleanup. ACE_CARGO setter `allowDamage false` på objektets eier før de to overvåkingsscript­ene startes, uavhengig av valget for umiddelbar skadenullstilling. Bare landingsscriptet endrer deretter skadebeskyttelsen, til `true` ett sekund etter registrert bakkekontakt. Trefast-scriptet kontrollerer høyden hvert femte sekund, venter 15 sekunder etter under 25 meter og kobler fra fallskjermen hvis lasten fortsatt er over kallers høydeterskel; skadenullstillingene beholdes. Dette forutsetter uendret locality under slippet; sekvensen replayes ikke for JIP. **Avhengighetsforbehold:** ACE-kilden markerer funksjonen Public: No. Supply Drop er tidligere rapportert fungerende, men dette er ingen garanti på tvers av modversjoner.

Forward Deploy eier serverregister/beslutning; klientens meny registreres bare under warmup. Deployment-events skjuler unitbundet meny og fjerner kjøretøyactions. Ground deploy bruker eksisterende plassering/locality-routing; air deploy eier formasjon/høyde og delegerer payloads til paradrop. JIP etter warmup får ikke tilbudet. **Uavklart:** Direkte array-input/våpenvalg på spillere og EJECT-landingsmargin/skadereaktivering krever spillverifisering; ingen ny godkjenning av dedicated/JIP foreligger.

Grunnlag: [fullCrew](https://community.bohemia.net/wiki/fullCrew), [allowDamage](https://community.bohemia.net/wiki/allowDamage), [ACE Cargo-kilde](https://github.com/acemod/ACE3/blob/master/addons/cargo/functions/fnc_paradropItem.sqf), samt felles locality/remoteExec-referanser.

### Support og kartvalg

**Filer:** `framework/support/initSupport.sqf`, `framework/support/selectMinefield.sqf`, `framework/support/requestClearance.sqf`, `framework/support/findMinefield.sqf`, `framework/support/findStopPosition.sqf`, `framework/support/runClearance.sqf`, `framework/support/clearMinesWaypoint.sqf`. Avhengigheter: equipment/Rifleman, radio, notifications, AI-callsign og valgfri BFT; ikke AI-settings-registeret. Serveroppsettet ligger i `lmf_support_config`, ventende reservasjoner i `lmf_support_pending`.

**Felles kartvalg:** Support-parenten har ingen tjenestespesifikke tilgangskrav; ACE skjuler tom parent uten statement. Supply Drop og Mine Clearance kan velges med kartet åpent. Lokal `lmf_support_selecting` reserveres unscheduled på tvers av tjenestene og bekreftelsesdialogen. Bare første klikk aksepteres; Map-handler husker lukking også ved rask gjenåpning. Død/unitbytte avbryter, og handlere/posisjon/sperre ryddes. Et allerede åpent kart beholdes; et kart åpnet av tjenesten lukkes. REQUEST/CANCEL brukes, men **Supply Drop prøver nytt posisjonsvalg etter CANCEL**, mens **Mine Clearance avslutter**. Supply Drop beholder forsøksmarkør ti sekunder etter sendt bestilling. Serveren avgjør kvote/cooldown.

**Oppstart og bestilling:** Support startes med ett execVM i felles postInit, definerer runtime-helpers/events uten CfgFunctions og inngår i klientens menyventing. `var_supportClearanceLimit` og `var_supportVehicleClass` er mission-settings; lagstørrelse fire, cooldown 30 sekunder og Eden-navnet `lmf_supportStart` er faste. Rifleman definerer side/loadout. Startobjektets posisjon/retning leses ved bestilling; mission maker må sikre kjørbar/uhindret plassering. Kvoten 0 deaktiverer tjenesten.

Serverens `lmf_support_state = [remaining, searchRadius, side, enabled]` og `lmf_support_nextDispatch` publiseres til klienter/JIP. Samtidige lag er tillatt, uten kø eller aktiv-sperre. Server kontrollerer kvote minus lokal pending, reserverer og starter scheduled opprettelse. Ved vellykket innlasting frigis reservasjonen, kvoten trekkes og LUCKY-N/BFT-state tildeles samlet unscheduled. Oppsettfeil trekker ikke kvote, men beholder startet cooldown; ingen refusjon etter utsending. Gamle lag endrer aldri kvote ved tap/retur. Klienten kan kort vise allerede reservert kvote; server avviser overbestilling.

Mine Clearance krever nåværende gruppeleder, riktig side, langdistanseradio, kart og avsluttet warmup. Server kontrollerer leder/radio/side, kvote, landdestinasjon og oppsett på bestillingstidspunktet. Klienten kontrollerer publisert serverTime-frist før kartvalg; server kontrollerer igjen ved bekreftelse. Menyen følger spillerobjektbytte/JIP og tom kvote vises ved forsøk. Radiomeldinger går til støttesidens LRR-brukere, avvisning bare til forespørrer. En route / Area clear / No mines found er de normale radiomeldingene; tap, ufullført rydding og hjemkomst gir ingen melding. Oppsettfeil er systemfeedback.

**Lag og skytter:** Fire serverlokale soldater får Rifleman-loadout, engineering-traits og ToolKit, med AT-ryggsekk som fallback. Manglende verktøyplass/transport avviser før kvotetrekk. Et tilgjengelig hovedvåpensete bemannes ved minst to soldater; FFV brukes ikke. Alle er i hovedgruppen på utreise. Skytteren flyttes til separat gruppe under rydding, rydder aldri og joiner tilbake før retur med ingeniørenes kampbegrensninger. Bare hovedgruppen registrerer transporten og får BFT. Siste overlevende skytter flyttes direkte til førerplass i kjørbar transport uten levende fører; dette er eneste manuelle setebytte ved retur. Eventuell død fører tas ut først.

**Feltsøk og ankomst:** Ett privat øyeblikksbilde før spawning. Miner innen 100 meter horisontalt starter søket; kjeder med høyst 20 meter mellom miner utvider feltet. Verste fall er kvadratisk søk. Sentrum er XY-grensenes midtpunkt på bakken; BI-radius er største 3D-avstand til funnet mine pluss fem meter. BI kan også rydde andre miner omsluttet av sirkelen. Hull over 20 meter, flere startfelt og senere mineendringer har ingen særskilt rekonstruksjon. Uten treff kjøres vanlig utrykning/kvotetrekk, men worker hoppes over og No mines found meldes etter ankomst.

Stoppunkt beregnes én gang, 20 meter før nærmeste relevante mine fra start og bakover ved konflikt med andre 20-meterssoner; uten miner 40 meter før klikkpunktet. Ingen garanti for terreng/rute/klaring. Ankomst er fullført waypoint eller innen fem meter. Immobil transport eller død opprinnelig fører lar ingeniørene fortsette til fots; midlertidig tomt sete gjør ikke. Ingen transport-/avstignings-/returfrist.

**Arbeid:** Ingeniørenes kamp-AI og LAMBS Danger begrenses fra spawning; MOVE/PATH/ANIM/MINEDETECTION og COMMAND beholdes. HEARING-deaktivering krever Arma 3 2.22. Gruppen har AWARE, allowFleeing 0 og enableAttack false. Skyttergruppen beholder kampadferd under rydding. Automatisk combat-unloading deaktiveres og tidligere kjøretøyverdi gjenopprettes ved avslutning. Begrensningene garanterer ikke fravær av mottatt målinformasjon eller modinngrep.

Etter avstigning hindrer allowGetIn false ny innstigning. HOLD med rydderadius holdes aktivt mens wrapperen starter BIS_fnc_wpDemine via execVM i eget scheduled scope og venter på scriptDone. Ikke SCRIPTED-waypoint-callback. BI bruker waypoint-radius og clearUnknown=true. Wrapperen kontrollerer hvert sekund tildelt mine for levende lokale ingeniører og korrigerer avvikende MOVE-destinasjon med doMove. Den leser intern `BIS_fnc_wpDemine_mine`, basert på tidligere lokal BI-kildeinspeksjon, ikke dokumentert offentlig API. Korreksjonen stanser før retur og forklarer ikke runtime-årsaken til opprinnelige avvikende ordre.

BI-worker stoppes ved totalt ingeniørtap; skytter holdes utenfor workergruppen til slutt. Ingen omstart eller ryddefrist. Resultat krever levende ryddepersonell og ingen miner med 3D-avstand mindre enn radius. Dette er ikke identisk med horisontalt feltsøk/kartsirkel. Ubekreftet resultat gir RPT-linje. Utilgjengelige miner/arbeidsudyktig personell kan hindre progresjon.

**Resultat og retur:** Bekreftet rydding lager varig global grå FDiagonal-ellipse og liten «Cleared! (LUCKY-N)»-markør, også til JIP/alle sider. Senere minelegging oppdaterer ikke markørene. Ufullført rydding etter tap gir ingen klareringsmelding/markør. Ved retur aktiveres FSM for alle overlevende; ingeniører får UP/doFollow for å frigi BI-bevegelse. Øvrige kamp-/LAMBS-begrensninger beholdes. Kjørbar transport får GETIN festet til opprinnelig kjøretøy med waypointAttachVehicle, deretter MOVE hjem, konfigurert samlet før aktivering. Allerede ombord med levende fører gir bare MOVE. Arma fordeler vanlige seter; ingen egen innlastingsløkke, frist eller særregel for skadde. Førertap avbryter ikke retur; fotretur bare ved ikke-kjørbar transport.

Cleanup krever alle overlevende fysisk innen 100 meter horisontalt fra start. Transport slettes bare der og uten spillere om bord; waypointfullføring er ikke nok. Totalt personelltap avslutter lagets kjøring. Tapte kjøretøy/døde blir i felt; et fastlåst lag kan bli igjen uten å blokkere nye bestillinger.

**Observasjon/uavklart:** Rydding fungerte lokalt i tidligere versjon, mens innlasting/avgang/sletting også har feilet. Gjeldende kjede under ild, personelltap og immobilitet er ikke samlet spillverifisert; dedicated/JIP gjenstår. Intern BI-variabel og fysisk AI-pathfinding er vedlikeholds-/runtime-forbehold, ikke bekreftet kompatibilitetsfeil.

Grunnlag: [BIS_fnc_wpDemine](https://community.bohemia.net/wiki/BIS_fnc_wpDemine), [disableAI](https://community.bohemia.net/wiki/disableAI), [LAMBS-variabler](https://github.com/nk3nny/LambsDanger/wiki/variables), [expectedDestination](https://community.bohemia.net/wiki/expectedDestination), [scriptDone](https://community.bohemia.net/wiki/scriptDone), [waypointAttachVehicle](https://community.bohemia.net/wiki/waypointAttachVehicle), [ACE action-visning](https://github.com/acemod/ACE3/blob/master/addons/interact_menu/functions/fnc_collectActiveActionTree.sqf).

### Supply Drop

**Filer:** `framework/supplyDrop/initSupplyDrop.sqf`, `framework/supplyDrop/selectDropPosition.sqf`, `framework/supplyDrop/fn_deliverSupplies.sqf`. Les også felles kartvalg under Support og payload-/ACE-kontrakten under Paradrop.

- Klientens action er bundet til opprinnelig spillerobjekt. CBA server-event bestiller; serveren reserverer kvote og felles 30-sekunders cooldown før scheduled levering. Avvisning trekker ikke kvote eller forlenger frist. Klienten sjekker `lmf_supplyDrop_nextRequest` før kartvalg og ved bekreftelse; server sjekker igjen. Bekreftelseslyd kommer først ved serverens aksept.
- `lmf_remainingSuppDrops` og frist publiseres. JIP registrerer skjulte actions ved tom gjenværende kvote, slik at tilbakeføring kan gjenåpne menyen. Start med konfigurert kvote 0 starter ikke Supply Drop-modulen.
- Leveringen får serverens ATLAS-N; med BFT registreres gruppen med samme navn/flyikon. Crate-tracking startes én gang fra server med objektbundet JIP og felles sluttid. Ingen leveringssekvens replayes.
- `var_supplyDropDelivery` velger PARACHUTE eller SLINGLOAD; `var_suppDropPlane` velger transport. Direkte fireargumentskall/Zeus går utenom bestillingskvoten. Internt femte argument `[requester]` identifiserer reservert ordre også etter disconnect.
- Ugyldig modus, fly til slingload eller mislykket festing avbryter oppstart, tilbakefører reservert kvote og varsler bestiller/RPT; mislykket festing rydder skapte objekter. Cooldown beholdes. Direkte kall har ingen kvote å tilbakeføre.

**PARACHUTE:** Fly og heli bruker MOVE ved slippunkt (25 meters completion radius), deretter MOVE fem km frem. Under 50 meter horisontalt ryddes waypoints og doMove gis fem km frem før dropObject. Ønsket flyhøyde velges én gang, 125–225 meter, og beholdes gjennom retur; ingen høydebetingelse på slipp. Fly begrenses til 250 ved innflyging og 100 innen én km; heli får 150 innen én km. Returgrense er 999. FLY-spawn heves relativt med modelToWorld, ikke eksplisitt ATL. Last, flare og cleanup eies av leveringen; passasjerlogikk fra paradrop brukes ikke. Levende transport som aldri når slippsonen venter uten timeout; død bryter også ventingen og er ikke leveringsbekreftelse.

**SLINGLOAD:** Krever heli som kan løfte lasten. Transport spawnes uten fremdrift, ønsket høyde 100 og fartsgrense 120; setSlingLoad brukes før MOVE endres til UNHOOK. Ingen ACE-innlasting/fallskjerm. Normal avsetting får 60 sekunder fra første passering innen 250 meter horisontalt. Ved fortsatt forbindelse forsøkes frakobling, så ropeDestroy etter et halvt sekund om nødvendig. Samme forsøk ved uteblitt ankomst etter 600 sekunder eller dødt crew/transport; avsetting ved bestillingspunkt er da ikke garantert. Tidlig frakobling avslutter også innflygingsventing. Last beskyttes til frakoblet og bakke-/vannkontakt pluss ett sekund. Ingen automatisk plassøk eller fallback til fallskjerm; mission maker/spiller velger egnet transport/sted.

**Observasjon/uavklart:** Gjennomflyging er rapportert fungerende, men gjeldende kombinasjon av høyde/fart/rute er ikke spillverifisert. Slingload er statisk kontrollert, ikke parser-/spilltestet; avsetting, tvungen frakobling, skadebeskyttelse og JIP-synlighet er uavklart. Aktuelle last-/modklasser må legges til grunn.

Grunnlag: [flyInHeight](https://community.bohemia.net/wiki/flyInHeight), [limitSpeed](https://community.bohemia.net/wiki/limitSpeed), [CBA clearWaypoints](https://cbateam.github.io/CBA_A3/docs/files/ai/fnc_clearWaypoints-sqf.html), [setSlingLoad](https://community.bohemia.net/wiki/setSlingLoad), [Waypoints](https://community.bohemia.net/wiki/Waypoints), [ropeDestroy](https://community.bohemia.net/wiki/ropeDestroy). Enkelte tidligere locality-oppslag manglet; servereid transport/last er implementeringsforutsetningen, ikke et MP-testbevis.

### BFT og kart

**Filer:** `framework/bft/initGroupState.sqf`, `framework/bft/initGroupTracking.sqf`, `framework/bft/initUnitTracking.sqf`, `framework/bft/fn_trackObject.sqf`, `framework/map/configureMap.sqf`.

**Design:** Hover-visningens tre felt og full medlemsliste beholdes uten ekstra alive-filter; BFT skal ikke bekrefte tap. State tilhører gruppen, og nye grupper arver ikke gamle valg. Old-school map skjuler nye markører fra andre maskiner, også scriptmarkører; dette skal ikke begrenses til brukermarkører.

**Grupper:** PreInit definerer helpers/serverevents. `lmf_bft_fnc_setCallsign` tar `[gruppe, standardikon, callsign]`; `setIcon` endrer bare overstyring. Server validerer leder og oppdaterer samlet unscheduled. Offentlig `lmf_bft_state = [callsign, standardikon, overstyring]` er eneste klientgrunnlag; tom overstyring bruker standard, manglende/`[]` betyr ikke registrert. Ingen separat state-event, klientkopi eller revisjon. Klienten leser ved kartåpning og 1 Hz med åpent kart; bevegelse tegnes fra render-posisjoner. Gjentatt valg republiserer ikke, men gir svar; serverkall uten requester gir ikke feedback.

Callsign sjekkes mot state og groupId hos andre grupper på samme side med medlemmer. **Avklart etter dedicated-observasjon:** Tomme grupper blokkerer ikke. Ved overtakelse av navnet omdøpes kolliderende tom gruppe til ledig LMF EMPTY N og dens BFT-state nullstilles offentlig. Ingen gruppe slettes; senere medlemmer må velge navn. setGroupIdGlobal utføres direkte i samme serverbehandling uten CBAs next-frame-utsettelse. Eksterne navnesettere/Eden er missionmakerens ansvar.

`var_bftInfantry`, `var_bftGroundVehicles`, `var_bftAirVehicles` bygger Infantry/Vehicles/Air. Infantry får /6, /1–4, /1V–4V; øvrige får 1–4. Standardikoner er b_inf, b_motor_inf, b_armor og b_air; HQ er manuelt. Icon-menyen finnes for ledere før callsign, men avviser valg uten navn. Manuelt ikon beholdes ved navnebytte; Reset icon fjerner bare overstyring. Tom liste skjuler kategori; alle tomme skjuler valg, ikke tracking. Actions er arvede klasse-actions uten automatisk state-reset ved JIP/respawn. Vanlig venstreklikk hvor som helst avslutter follow; Ctrl-klikk på gruppeikon starter/bytter.

**Objekter:** `trackObject` fra server distribuerer objektbundet persistent oppstart med felles sluttid; direkte klientkall er lokale. ItemMap må være tildelt. Én klientliste/vedlikeholds-PFH og Draw per kartkontroll tegner med render-posisjon/-retning. Intervallargumentet styrer vedlikehold/opprydding, minimum 0,1 sekund, ikke bevegelsesoppdatering. Åpne display-/IGUI-kart oppdages ved registrering/kartåpning og hvert sekund mens tracking finnes. Nytt kall erstatter samme objekts oppføring. Skygge er enkel kontur/tekstskygge, ikke identisk native markørskygge.

**Uavklart:** Samtidige valg, tomgruppenavn/JIP, andre modkart og representativ ytelse er ikke fullt spillverifisert. Ny missionstart forutsettes; hot-reload av gamle EH-er støttes ikke.

Grunnlag: [setGroupIdGlobal](https://community.bohemia.net/wiki/setGroupIdGlobal), [CBA setCallsign](https://github.com/CBATeam/CBA_A3/blob/master/addons/common/fnc_setCallsign.sqf), [ACE interaction framework](https://ace3.acemod.org/wiki/framework/interactionmenu-framework), [drawIcon](https://community.bohemia.net/wiki/drawIcon), samt felles state/JIP-referanser.

### Spilleroppsett, asset spawnere og service

**Filer:** `framework/equipment/`, `framework/equipment/roles/`, `framework/playerVehicles/`, `framework/supplyCrates/`, `framework/assetSpawner/`, `framework/vehicleService/fn_serviceVehicle.sqf`.

Gear-/rollefunksjoner krever lokal unit, bruker cfg_Player og publiserer `lmf_currentRole`. Rolleoverstyring må følge `applyBaseLoadout`: pilot/helipilot setter onMapSingleClick etter basens verdi; medic setter trait etter basens nullstilling. Rollefunksjoner, rollevalg og personal arsenal tilhører equipment; objectSorting ruter kjøretøy/kasser til sine systemer.

Personal arsenal tilbyr startklassens konfigurerte hodeplagg og briller under warmup. Rolleverdien `[""]` arver Rifleman som i `applyBaseLoadout`, også for crew/piloter; AT-assistenten bruker sine egne `_ata*`-innstillinger. Utvalget bygges én gang og oppdateres ikke ved senere rollebytte via rollekassen. Available Optics bruker lokal `lmf_player_availableOptics`; egne crew-/pilotroller avslutter før optikkoppsettet. Arsenal/optics ligger under Equipment, med init etter introsignalet.

Spawner-actions er klientlokale på Eden-objekter. `spawnObjectAtPad` kjøres på bestillerklienten, sjekker området og skaper objektet der; dette er forskjellig fra serverens AI-/support-spawning. Delete-action distribueres med objektbundet JIP. Rolle-/spawner-markører inkluderes i serverens markørsekvens; teksturer i klientens postInit.

Vehicle service har innledende 0,25-sekunders ventekontroll bare når time <= 30 ved kall; senere kall får ikke denne pausen. **Uavklart:** RRR med fører/skytter på forskjellige klienter og eierskifte under service er ikke avklart i spill; ikke generaliser til at hele modulen feiler.

### Warmup, Mission Info og JIP-teleport

**Filer:** `framework/warmup/runIntroAndWarmup.sqf`, `framework/warmup/manageTimeAndWeather.sqf`, `framework/warmup/monitorWarmupDeadline.sqf`, `framework/missionInfo/showStartupInfo.sqf`, `framework/jipTeleport/initJipTeleport.sqf`, `framework/jipTeleport/fn_selectTeleportTarget.sqf`, `framework/jipTeleport/fn_hasEmptySeat.sqf`. Les oppstartskjeden før endring av intro/menyer.

**Warmup:** Server initialiserer state og lagrer/gjenoppretter dato/vær; setDate distribueres til alle ved reset. `var_maxWarmupTime` tolkes som numerisk MM:SS-frist i CBA_missionTime, ikke varighet fra klientinnlogging. Tom verdi deaktiverer frist. Server bruker >=, så et hoppet sekund mister ikke avslutningen. Panelet teller opp fra missionstart; med frist vises Ends at og farge følger gjenværende 300/180/60 sekunder. Uten frist følger farger medgåtte 600/900/1200 sekunder. To kolonseparerte deler sjekkes, men dette er ikke full numerisk validering. JIP starter ikke timeren på nytt. `lmf_admin_fnc_setPlayerSafety` brukes av warmup; ingen separat administrativ Safety On/Off eller samlet adminteleport finnes.

**Mission Info:** Starter én gang fra intro etter introsignalet, også JIP/deaktivert warmup. Venter på arsenal/menu-handles, starter BLACK IN med parameter 5 rett før eventuell lokal BIS_fnc_guiMessage og holder intro-uniten uten simulering til infoscriptet avsluttes. Ingen ekstra femsekundersventing. Død/tomt innhold utelater melding, men skal fortsatt gi innfading/frigivelse. Damage/våpen/camo endres ikke av frigivelsen. Warmup-safety/panel venter ikke på dialogen.

Innhold bygges én gang: arsenal/optics under warmup, konfigurert BFT-valg, Forward Deploy under warmup, aktivt JIP-tilbud og aktiverte støttetjenester. Supply Drop krever positiv replisert kvote og nevner kjøretøy bare ved aktivert/configurert kjøretøydrop. Mine Clearance vises til støttesiden uten krav om leder/radio og forklarer tom kvote. BFT/Forward Deploy forklarer lederbetjening til alle. Ingen gjenåpningsmeny, respawn-hook eller løpende oppdatering; informasjon kan bli utdatert mens åpen. LMF_LOGO defineres, men brukes ikke her.

**JIP-teleport:** Starter bare ved var_jipTp og didJIP. Tilbudet gjelder én vellykket teleport innen fem minutter fra initialisering, bundet til opprinnelig unit og lokal `lmf_jipStartPos`. Utløper permanent ved frist, død, unit/locality-bytte eller over 200 meter fra start, også Zeus-teleport. Kortlivet CBA-venting følger tilbudet uavhengig av meny. Respawn/retur til spawn fornyer ikke. Andre nyankomne ved spawn blokkerer ikke opprettelsen.

Målet er høyest rangerte levende ikke-virtuelle vennlige spiller utenfor startområdet med ledig kjøretøyplass eller egnet bakkeplass ved langsomt mål på land. Seat-helper avviser null/døde kjøretøy, soldater og fallskjermer. Flytting skjer på spillerens eier; feil beholder tilbudet bare innen opprinnelige vilkår og gjenoppretter tidligere damage-state.

**Uavklart:** Dialoglayout/UI-skala og oppstart/JIP-kjeden er ikke samlet spillverifisert. JIP-betjening og konkurranse om siste sete gjenstår på dedicated. Menyventingens blokkering er beskrevet i fellesdelen.

Grunnlag: [BIS_fnc_guiMessage](https://community.bohemia.net/wiki/BIS_fnc_guiMessage), [scriptDone](https://community.bohemia.net/wiki/scriptDone), [didJIP](https://community.bohemia.net/wiki/didJIP), [setDate](https://community.bohemia.net/wiki/setDate), [moveInAny](https://community.bohemia.net/wiki/moveInAny).

### Respawn, spectator, medical og hit-effekter

**Filer:** `framework/respawn/fn_onKilled.sqf`, `framework/respawn/fn_onRespawn.sqf`, `framework/spectator/initSpectatorEvents.sqf`, `framework/spectator/fn_showMedicalInfo.sqf`, `framework/medical/initTreatmentFeedback.sqf`, `framework/medical/initUnconsciousEvent.sqf`, `framework/hitEffects/fn_onHit.sqf`.

Killed-handler avviser utdatert player-unit før/etter forsinket spectator-oppstart, slik at rask respawn ikke åpner spectator igjen. Respawn reetablerer gear, kanaler, våpensikring, spectator-state og camo uten full player-init. Bare tekstverdien TICKETS testes i respawn-handleren; numerisk respawntid hopper over ticketmelding. Kvoten initialiseres fra settings og trekkes lokalt ved killed. **Designavklaring mangler:** Varig kvote per UID gjennom reconnect finnes ikke; per innlogging eller per mission må avklares før endring.

ACE Spectator-display lagres/ryddes ved load/unload. Medical-visning er displaybundet, oppdager target/alive ved 20 Hz, leser medical state ved 4 Hz og oppdaterer bare endret visning. Treatment-feedback bruker ace_treatmentStarted og lokal mottakercooldown uten publisert unit-state. Hele bevisstløshetshandleren, også AI-grenen, ligger i medical.

Player-hit starter scheduled fra Hit; kvalifisering/reservasjon av `lmf_player_isGettingHit` skjer samlet i isNil for å hindre parallelle sekvenser. Selve effekten/frigivelsen er scheduled.

**Observasjon/uavklart:** Flytting av ticketmelding til etter sikring/femsekundersventing ved innfading løste manglende melding i mission makers lokale test. Typekontroll, død/respawn-visning og dedicated/JIP er ikke samlet verifisert.

### UI, briefing og gruppevarsler

**Filer:** `framework/colors.hpp`, `framework/notifications/fn_showAceMessage.sqf`, `framework/notifications/defineNotificationFunctions.sqf`, `framework/notifications/CfgNotifications.hpp`, `framework/briefing/createBriefing.sqf`, `framework/groupNotifications/initGroupNotifications.sqf`.

**Palett:** colors.hpp eier felles blå/oransje/grønn/grå/rød/hvit. PreInit setter SQF-konstantene lokalt; notifications-config inkluderer samme header. HEX/RGBA må holdes synkronisert. Team-/kartfarger, medical-skala, warmup-trinn, panelalpha og effekter er modulspesifikke. Ingen nettverkssynkronisering/settings for paletten.

**ACE-feedback:** `lmf_notifications_fnc_showAceMessage` er lokal og avslutter uten interface/gyldig player. Kalleren eier innhold, tidspunkt og mottakerutvalg. Kontrakt: `[title, text, icon, height, width, sound, iconSize, isError]`; siste er valgfritt og endrer bare brødtekstens grunnfarge. Tomt ikon/tittel utelater tilhørende linjeskift. Høyde/bredde er boksdimensjoner, ikke varighet. Ingen kø eller JIP-replay; ACE-meldinger kan erstatte hverandre. `showRoleChangeMessage` har ett argument og delegerer visningen.

Designet er blått ikon/overskrift, hvit brødtekst, rød feilårsak og eventuelt hvit veiledning. Feilfarge/lyd er uavhengige. Avvisning bruker addItemFailed, bekreftelse beep, kartinstruksjon taskUpdated og radio TacticalPing4; passive negative meldinger er stille/røde. Hele setninger skilles med br uten avsluttende break; bevisste verdi/navnelinjer beholdes. BFT-gjenvalg er stille med grønn verdi; loadout/gruppeankomst er stille. Ticketmelding viser gjenværende tall på egen linje og har ingen eksplisitt femsekunders tømming. JIP-påminnelse, Mission Info, warmup, medical og BFT-hover/follow har egne visninger.

**Briefing:** `_thanks` i cfg_Briefing er `[navn, forklaring]`-par; tom forklaring utelater bindestrek, tom liste skjuler ikke Thanks. Personer ligger i settings, ikke hardkodet framework. Technical Info forklarer samme fem statiske Safe Start-felt: Map Access, Map Mode, Blue Force Tracker, Personal Radio og Respawn. Bygges ved briefing/JIP; ikke en løpende ticketoversikt.

**Gruppevarsler:** Synkron klientinit med dobbeltstart-guard registrerer mottaker straks og aktiverer avsender etter introsignalet. Vanlig oppstart lagrer gruppe stille; første JIP-ankomst varsles én gang. CBA player-event `group` følger medlemsbytte; lokal sist behandlet gruppe beholdes gjennom respawn. Nullgruppe ignoreres, samme respawngruppe gir intet nytt varsel, ny gruppe og retur etter registrert bytte varsles. Zeus remote-control for andre units ignoreres. Ingen egen polling/serverregister; svært korte bytter mellom CBA-observasjoner kan overses.

Avsender målretter ikke-persistent CBA-event mot gjeldende spillerleder; AI-leder/selvvarsling utelates. Mottaker sjekker fortsatt leder/gruppe og viser stille navn + joined your group uten overskrift. Ingen kø/historikk/videreruting; lederbytte under levering kan miste melding, samtidige ACE-meldinger kan erstatte den.

**Uavklart:** Gruppe-/ledereierskifte, faktisk JIP-levering og UI-skala er ikke dedicated-verifisert. Grunnlag: [ACE displayTextStructured](https://github.com/acemod/ACE3/blob/master/addons/common/functions/fnc_displayTextStructured.sqf), [CBA player-EH](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/fnc_addPlayerEventHandler.sqf), [CBA playerEvent](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/fnc_playerEvent.sqf), [CBA targetEvent](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/fnc_targetEvent.sqf).

### Admin, chat og radio

**Filer:** `framework/admin/checkAdminAccess.sqf`, `framework/admin/createAdminDiary.sqf`, `framework/chat/registerCommands.sqf`, `framework/chat/fn_bringIntoVehicle.sqf`, `framework/chat/fn_sendChatMessage.sqf`, `framework/radio/`.

**Avklart design:** De faste UID-ene for Alex2k, nkenny og Liquid Tracer er tilsiktet Nopryl-konfigurasjon for vedvarende teknisk/admin-tilgang, uavhengig av hvem som er innlogget som serveradmin. Identitetene beholdes både i `framework/XEH_preInit.sqf` og `description.ext`: listene betjener henholdsvis LMF-tilgang og debug-konsolltilgang. De er ikke scenario-rester eller foreldede standardverdier og skal ikke fjernes, konsolideres eller endres som del av repository-klargjøring.

PreInit definerer lokale `lmf_admin_uids` for disse tre. Disse får LMF-tilgang uten admininnlogging; innvalgte/innloggede serveradmins (> 0) og lokal SP/host-spiller støttes. Server slår opp UID på oppgitt unit; klient krever egen player. Nettverksstatuskravet gjelder bare MP. Zeus tildeles først ved valg av Zeus access. `description.ext` har separat enableDebugConsole-liste som vedlikeholdes selvstendig.

Chat velger CBA-nivå all bare på fast admins egen klient, ellers admin med CBAs login/logout-kontroll. heal/goto/bring/respawn har bare denne lokale autoriseringen; start/victory/defeat/respawnwave/performance delegerer til LMF-adminlagets egne kontroller. `/w` og `/zeus` bruker ikke-persistent global CBA-event, med mottaker bare på interface-maskiner. ACRE-kanalnavn initialiseres på alle; `lmf_radio_fnc_hasLongRangeRadio` brukes fra server og klient.

`#bring` til fots teleporterer som før. Fra kjøretøy målrettes helperen mot målspillerens klient med remoteExecCall. Samme levende adminkjøretøy kreves; bare ordinært cargo-sete velges, ikke driver/turret/FFV. Fullt kjøretøy avvises før flytting, allerede ombord blir sittende. Andre klienters samtidige setebruk reserveres ikke. Respawn-wave-dialog bruker aktivt ACE Spectator-display som parent; spillerutvalg hentes først ved OK før 30 sekunders respawntid sendes. Cancel sender intet.

**Uavklart:** Adminfunksjonene kontrollerer oppgitt unit, men sammenhengen med eventuell remote-avsender er ikke sikkerhetsverifisert. Effektiv remote-exec-policy/server/modoppsett avgjør faktisk eksponering. Tilgang uten innlogging, login/logout, respawn/JIP og bring-setekonkurranse er ikke spillverifisert.

Grunnlag: [enableDebugConsole](https://community.bohemia.net/wiki/Description.ext#enableDebugConsole), [CBA chat-handler](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/XEH_postInit.sqf), [fullCrew](https://community.bohemia.net/wiki/fullCrew), [remoteExecCall](https://community.bohemia.net/wiki/remoteExecCall).

### Fire support

**Fil:** `framework/ai/fireSupport/fn_fireSupportAtTarget.sqf`. Scheduled/serverbegrenset, for serverlokal AI med MK41 VLS eller artillery computer. Fjerde argument `_playerRequested` er false som standard; bare spillerbestilte angrep varsler eksisterende LRR-mottakere og får VLS-BFT. Utviklingsmissionen inneholder nå ingen designator eller autonomt init-kall til funksjonen. Spillerstyrte/remote turrets og eierskifte er ikke etablert støttet.

Busy-lock tas samlet i isNil; batteri/mål valideres igjen etter forberedelse. Offentlig `lmf_artilleryBusy` gir klient/JIP tilgjengelighet; serverlokal `lmf_fireSupportState` lagrer filter/teller/tider og fjernes med Fired-handler før cooldown. Artilleri velger magasin dynamisk og teller bare valgt magasin; VLS filtrerer weapon_VLS_01 og tilhørende magasiner.

Artilleri frigis ti sekunder etter siste skudd i full eller observert avsluttet delvis salvo; VLS 60 sekunder etter første bekreftede launch. Forberedelse kommer i tillegg, flytid forlenger ikke låsen. VLS har separat Splash-observatør, maksimalt 300 sekunder, uten tilgang til låsen. Splash betyr bare at prosjektilet er borte/ikke levende, ikke bekreftet treff. Artilleri har ingen flytsporing/Splash.

Shot/Missile away/Round away kommer ved første skudd; flerrunders artilleri får faktisk antall i Rounds complete. Battery standing by kommer ved frigivelse bare for levende/lokalt batteri. Launch-feil frigir straks feilen bekreftes. Tidsgrenser er åtte sekunder VLS, 30 artilleri og `30 max (_rounds * 15)` for salvo. Timeout betyr manglende bekreftelse, kansellerer ikke engine-ordre og sender ikke automatisk restsalvo. Meldinger replayes ikke; VLS-objekttracking har JIP.

**Uavklart:** Sen avfyring etter timeout, unitReady ved delvis salvo, samtidige bestillinger, filter/cooldown/meldingsrekkefølge og VLS-BFT/JIP er ikke spillverifisert. Tidligere BIKI fireAtTarget-side manglet locality/effect-markering; serverlokal implementasjon alene er ikke runtime-bevis.

Grunnlag: [fireAtTarget](https://community.bohemia.net/wiki/fireAtTarget), [doArtilleryFire](https://community.bohemia.net/wiki/doArtilleryFire), [unitReady](https://community.bohemia.net/wiki/unitReady), [Fired](https://community.bohemia.net/wiki/Arma_3:_Event_Handlers#Fired).
