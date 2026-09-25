# Formål og nivå

Dette prosjektet brukes til utvikling av Arma 3-missions.

Jeg har laget Arma 3-missions siden 2013 og er erfaren med mission making, Eden Editor, SQF og generell Arma 3-logikk. Behandle meg som en erfaren mission maker og teknisk samarbeidspartner.

Ikke forklar grunnleggende konsepter med mindre jeg ber om det.

Prosjektet brukes blant annet til mission design, idéutvikling, SQF, debugging, utvikling av framework, briefings, dialog, worldbuilding og research.

# Oppdragsomfang og endringer

Når jeg ber om gjennomgang, vurdering, forklaring eller forslag, skal du ikke endre filer med mindre implementering allerede er avtalt i den pågående oppgaven.

Når jeg ber om implementering, gjennomfør innenfor det avtalte omfanget uten unødvendige bekreftelser. Hold separate forbedringsforslag utenfor endringen.

Feilretting, optimalisering og refaktorering skal som utgangspunkt bevare eksisterende gameplay, UI, informasjonsflyt og brukerbetjening. Ikke innfør designendringer som en del av teknisk opprydding. Tilsiktede begrensninger og særvalg skal ikke behandles som feil bare fordi en annen løsning virker mer generell eller ryddig.

Beskriv nødvendige oppførselsendringer uttrykkelig. Ikke skjul endret funksjonalitet, utseende eller betjening bak formuleringer som «opprydding» eller «forbedret robusthet».

Før du anbefaler ombygging av et fungerende system, beskriv det konkrete problemet, minste nyttige endring og kostnaden i kompleksitet, migrering og testing. Vurder eksplisitt om dagens løsning bør beholdes. Færre kodelinjer eller mer generell arkitektur er ikke alene tilstrekkelig begrunnelse.

Ved refaktorering skal du identifisere hvilken gameplay-hensikt koden ivaretar, og hvilke forskjeller som må bevares. Hvis ukjent hensikt er avgjørende for anbefalingen, still ett målrettet spørsmål før løsningen fastlegges. Ikke anta at like kodeblokker har samme kontrakt.

# Faste tekniske krav

Alle missions kjøres på dedicated server.

Alle missions skal støtte Join-in-Progress (JIP).

Dette er grunnleggende krav for all teknisk utvikling i prosjektet.

Når du foreslår, skriver eller vurderer tekniske løsninger, ta hensyn til Arma 3s faktiske multiplayer- og execution-modell. Løsningen skal fungere korrekt under reelle multiplayer-forhold, ikke bare i editoren eller i en enkel lokal test.

Tenk gjennom relevante forhold som locality, initialization, execution context, state og JIP uten å låse løsningen til bestemte mekanismer på forhånd.

Vurder ytelse, nettverksbruk, robusthet, lesbarhet og vedlikeholdbarhet i den graden det er relevant for problemet.

Ikke finn på Arma 3-kommandoer, SQF-syntaks, funksjoner eller engine behaviour. Hvis teknisk korrekthet er usikker, verifiser fremfor å gjette.

Ved debugging, forsøk å identifisere den faktiske årsaken til problemet fremfor bare å lage en workaround.

# Verifisering av Arma 3 engine behaviour

Når en teknisk vurdering avhenger av hva en Arma 3-kommando, funksjon eller engine-mekanisme faktisk gjør, skal den aktuelle informasjonen verifiseres mot den nåværende Bohemia Interactive Community Wiki:

https://community.bohemia.net/wiki/

Ikke stol utelukkende på innebygd modellkunnskap når oppdatert dokumentasjon kan undersøkes.

Ved bruk eller vurdering av SQF-kommandoer, undersøk den konkrete wiki-siden for kommandoen og kontroller relevante forhold som:

* syntaks og alternative syntaksformer
* argument- og returtyper
* locality
* local eller global effect
* execution context
* multiplayer-oppførsel
* server- og client-begrensninger
* versjonskrav og eventuell branch-avhengighet
* dokumenterte edge cases og relevante merknader

Skill mellom:

* dokumentert kommando- eller engine-oppførsel
* community-kommentarer og eksempler på wiki-en
* tolkninger basert på eksisterende LMF-kode
* antakelser som fortsatt krever testing

Community Wiki-en er en Bohemia-hostet, community-vedlikeholdt referanse og kan inneholde ufullstendig, uklar eller foreldet informasjon. Hvis dokumentasjonen er tvetydig, motsier eksisterende kode eller ikke dekker den aktuelle multiplayer-situasjonen, skal usikkerheten påpekes.

Foreslå ved behov en minimal reproduksjon eller en test på dedicated server fremfor å presentere antatt engine behaviour som fakta.

Når en teknisk konklusjon bygger på wiki-dokumentasjon, oppgi hvilke kommando- eller temasider som ble brukt.

For ACE- og CBA-spesifikk oppførsel skal relevant dokumentasjon eller kildekode fra det aktuelle prosjektet undersøkes. BIKI alene er ikke tilstrekkelig for å fastslå mod-spesifikke kontrakter. Skill mellom dagens dokumentasjon/kildekode og den modversjonen missionen faktisk kjøres med når dette kan påvirke konklusjonen.

# Verifisering og rapportering

Skill tydelig mellom:

* statisk kodegjennomgang og kontroll av filreferanser
* parser-/syntakskontroll
* lokal test i Arma
* test på dedicated server med flere klienter og JIP

Oppgi hva som faktisk er kontrollert, hva kontrollen dokumenterer og hva som gjenstår. En bestått parserkontroll eller lokal test dokumenterer ikke korrekt multiplayer-oppførsel.

Skill mellom rapportert symptom, feil eller risiko utledet fra kode og årsak bekreftet gjennom runtime-observasjon. Ikke presenter en sannsynlig årsak som runtime-bekreftet.

Ved relevante endringer skal gjenstående spilltester beskrives kort og konkret, med utløsende situasjon og forventet resultat. Oppsummer hva som er endret og eventuelle følger for mission makers.

Etter større oppførselsendringer, anbefal en avgrenset spilltest før neste større ombygging av samme system. Bruk rapportert testsituasjon, forventet og faktisk oppførsel samt testmiljø som grunnlag for videre vurdering. Be bare om manglende testopplysninger når de er nødvendige for konklusjonen.

# Lambs Mission Framework

Alle missions bruker mitt eksisterende mission-framework, Lambs Mission Framework, forkortet LMF. Det er et stort framework som har blitt utviklet over mange år.

Ikke anta at funksjonalitet må bygges fra bunnen av. Når relevant, vurder hvordan en løsning passer inn i eksisterende LMF fremfor å lage et parallelt system.

Ikke anta hvordan LMF fungerer dersom du ikke har sett den relevante koden. Kode og konfigurasjon er source of truth for dagens implementasjon. Eksplisitte brukerkrav og avklarte designvalg beskriver tilsiktet oppførsel. Ved motstrid skal avviket synliggjøres; eksisterende kode er ikke automatisk ønsket oppførsel eller mandat til endring.

Hvis du mangler nødvendig LMF-kontekst for å kunne gi et sikkert svar, identifiser hva som mangler fremfor å dikte opp hvordan frameworket sannsynligvis fungerer.

Når ny funksjonalitet skal inn i LMF, behandle den som langsiktig og gjenbrukbar framework-kode, men unngå unødvendig abstraksjon og overengineering.

Aktive framework-helpers og framework-state skal bruke `lmf_`-prefiks og følge navngivningen i den relevante modulen. Mission-spesifikke `a2k_*`-helpers skal ikke omdøpes som del av generell LMF-opprydding.

## Navngivning i LMF

Navne- og kommentarreglene gjelder ny og endret kode innenfor oppgavens omfang. Eksisterende avvik utenfor dette omfanget skal ikke standardiseres uten avtale.

Lokale variabler, parametere og lokale kodevariabler bruker `_camelCase`, uten interne understreker. Dette gjelder også private innstillinger i `settings/`. Forkortelser behandles som ord: `_nvg`, `_apcCamo`, `_groupId`, `_rifleGlAmmo` og `_firedEh`. Samme identifikator skal ha samme skrivemåte i definisjoner og alle referanser, også i strenger med variabelnavn eller SQF-kode.

Globale LMF-navn bruker `lmf_camelCase` eller modulens etablerte `lmf_modul_camelCase`. Registrerte funksjoner bruker `lmf_modul_fnc_camelCase`, med samsvar mellom funksjonsklasse, `fn_*.sqf`-fil og kallesteder. Globale mission-settings beholder `var_camelCase`; intern framework-state bruker `lmf_`. Konstanter beholder `LMF_UPPER_SNAKE_CASE` som et uttrykkelig unntak.

Etablerte modul-prefikser beholdes. CamelCase-standardisering gir ikke i seg selv grunnlag for å endre begreper, HashMap-nøkler, action-/event-/marker-/layer-ID-er, Eden-navn eller eksterne ACE-/CBA-/BIS-/modnavn. Engine- og callback-definerte variabler beholder kontraktens navn. Ved omdøping må inkluderingsscoper og alle relevante referanser kontrolleres for kollisjoner og brudd; endre ikke scope, verdier eller execution som del av navneendringen.

# Kommentarstil i LMF

Kommentarer i `framework/` og `settings/` skrives på engelsk, i vanlig setningsform og med ett mellomrom etter `//`. Kommentartekst, headertitler og seksjonsnavn begynner med stor forbokstav og bruker ellers vanlig setningsform. Ikke bruk gjennomgående versaler, gjennomgående små bokstaver eller stor forbokstav i hvert ord. Etablerte forkortelser, egennavn og kodeidentifikatorer beholder korrekt skrivemåte. Unngå dekorative bannere og generelle `INIT`-/`RETURN`-etiketter.

Et avgrenset unntak gjelder de tre hovedseksjonene i `framework/XEH_postInit.sqf`: `All machines`, `Server` og `Player clients`. Disse bruker én ASCII-kommentarlinje på formen `// --- All machines ---`, fylt ut med bindestreker til og med kolonne 100. Underseksjoner følger vanlig kommentarstil uten dekorative skiller.

Foretrekk én kort kommentarlinje direkte over koden når det er tilstrekkelig. Slå sammen seksjonsnavn og nødvendig veiledning, og unngå gjentakelser mellom filheader, seksjonskommentar og eksempel. Bruk flere linjer når kontrakten eller begrunnelsen trenger det; ikke press teksten sammen til uleselige langlinjer.

Alle kodefiler i `framework/` og `settings/` skal ha en `/* ... */`-filheader med en egen, kort og menneskelesbar tittellinje, etterfulgt av en beskrivelse av filens formål. Headeren skal tilføre formål eller kontrakt utover filnavnet. Det skal være nøyaktig én tom linje etter avsluttende `*/` før kode, preprosessordirektiver eller neste kommentar starter. Dokumenter relevante argumenter, returverdier, locality-/execution-krav og eventuelt et nyttig kalleksempel, uten obligatoriske tomme felt. For include-fragmenter beskrives inkluderingspunkt og arvede forutsetninger når dette er relevant. Vanlige kommentarer inne i filen bruker `//`.

Forklar hvorfor, begrensninger og spesielle verdier. Fjern kommentarer som bare gjentar navn eller selvforklarende kode. Behold mer veiledning i `settings/` enn i intern framework-kode, men samle gjentakelser. Dokumenter dagens oppførsel uten løpende refaktoreringshistorikk, og bevar forfatter- og kildekreditering. Bevisst utkommentert kode skal ikke aktiveres som del av kommentaropprydding.

# Enkelhet for mission makers

Mission makers forholder seg hovedsakelig til `settings/`. Prioriter forståelig konfigurasjon og gode standardverdier. Vanlig mission-oppsett skal ikke kreve endringer i `framework/`; mission-integrasjon hører fortsatt hjemme i missionens egne scripts og Eden.

Unngå nye innstillinger, kompatibilitetslag og omfattende logging uten et konkret behov. Legg kompleksiteten internt når det gjør det vanlige oppsettet enklere, men ikke bygg generelle systemer for hypotetiske behov.

Ved endring av eksisterende funksjonskall eller konfigurasjon, kontroller relevante kallesteder og beskriv nødvendig migrering kort. Ikke anta at ukjente kallesteder er verifisert.

# Bruk og vedlikehold av prosjektdokumentasjon

Før teknisk arbeid som involverer SQF, LMF, mission-initialisering, integrasjon, locality, multiplayer eller JIP, les fellesdelen av `LMF_OVERVIEW.md`, deretter avsnittene for berørte moduler og deres avhengigheter. Ved bred arkitekturgjennomgang eller uklart omfang leses hele oversikten. Uendret innhold som allerede finnes i tilgjengelig kontekst, trenger ikke hentes på nytt for hver melding; les på nytt når innholdet er endret eller nødvendig kontekst mangler.

`LMF_OVERVIEW.md` er agentens tekniske kart og varige prosjektkontekst, ikke en erstatning for kodeundersøkelse. Vesentlige tekniske konklusjoner skal verifiseres mot aktuell SQF, konfigurasjon og relevant engine-/moddokumentasjon etter reglene ovenfor.

Hvis oversikten er utdatert eller motsier koden, påpek avviket og skill mellom feil beskrivelse og implementasjon som avviker fra avklart design. Ved ren vurdering foreslås dokumentasjonsendringen uten å utføre den.

Ikke opprett nye dokumentasjonsfiler, reviewrapporter, endringslogger eller testplaner i prosjektet uten at jeg uttrykkelig ber om det. Lever slike resultater i samtalen som standard. Ikke gjør midlertidige arbeidsnotater til permanente prosjektdokumenter.

Når en avtalt implementering endrer arkitektur, initialisering, funksjonskontrakter eller dokumentert oppførsel, oppdater berørte deler av eksisterende `LMF_OVERVIEW.md`. Revider gjeldende beskrivelse på dens hovedsted og fjern utdatert dobbeltføring; ikke legg en ny endringsrapport ved siden av den gamle teksten. Bevar designbegrunnelser, tilsiktede særvalg og relevante uavklarte begrensninger.

`AGENTS.md` inneholder varige arbeidsregler. `LMF_OVERVIEW.md` beskriver arkitektur og modulkontrakter, med tydelig skille mellom besluttet design, implementasjon, rapportert runtime-observasjon og uavklart oppførsel. Prioriter entydig, relevant agentkontekst fremfor en bestemt lengde. Ikke bruk oversikten som løpende reviewrapport, endringslogg eller detaljert testplan.

`LMF_MM_FUNCTIONS.md` inneholder missionmaker-rettede kall og eksempler. Ved avtalt endring av dokumenterte entrypoints, argumenter eller kallkrav skal relevante eksempler kontrolleres og oppdateres. Detaljkontrakter hører også hjemme ved den aktuelle koden.

Det er ikke nødvendig å lese `LMF_OVERVIEW.md` for oppgaver som åpenbart ikke berører LMF eller teknisk mission-funksjonalitet, som ren tekstskriving, worldbuilding eller generell research.

## Endringslogg

`CHANGELOG.md` er en kort, menneskelesbar versjonsoversikt for LMF, ikke en arbeidslogg. Etter avtalt LMF-implementering skal du vurdere om utviklingsversjonen trenger en ny eller oppdatert oppføring. Vedlikeholdet inngår i implementeringen, men hver endring krever ikke et loggpunkt.

Logg nye eller fjernede funksjoner, merkbare endringer i gameplay eller betjening, viktige feilrettinger og vesentlige endringer i arkitektur eller konfigurasjon. Vurder betydningen for spillere og mission makers, ikke antall endrede kodelinjer. Rene dokumentasjons-, kommentar- og formateringsendringer, isolerte omdøpinger, lokal kodeopprydding og små tekst-, UI- eller timingjusteringer logges normalt ikke.

Bruk testen: Ville dette fortjent en plass i en kort «hva er nytt»-oppsummering sammenlignet med forrige utgivelse? Hvis nei, utelat punktet. Ved tvil, ikke legg til et nytt punkt. Samle relaterte endringer i ett punkt og oppdater eksisterende punkter i utviklingsversjonen fremfor å logge mellomsteg, følgefeil og finjusteringer separat. Logg bare gjennomførte endringer, ikke forslag, planer eller gjennomganger.

Skriv korte engelske punkter med ett av disse prefiksene:

* **Added:** Ny funksjonalitet.
* **Improved:** Vesentlig forbedring av eksisterende funksjonalitet eller struktur.
* **Tweaked:** Tilsiktet justering av oppførsel, balanse eller standardverdier.
* **Fixed:** Rettelse av feil eller utilsiktet oppførsel.
* **Removed:** Fjernet funksjonalitet eller støtte.

Beskriv resultatet fremfor interne arbeidssteg. Ikke lov bedre ytelse, bekreftet multiplayer-støtte eller vellykket testing uten grunnlag. Mission-spesifikke endringer hører ikke hjemme i LMF-loggen.

Hold nyeste versjon øverst, med én Markdown-overskrift per versjon, for eksempel `## LMF 2.0.0 — Unreleased`. Bruk punktlister som `- **Fixed:** Short description.`, tom linje etter overskrifter og mellom versjoner, og kodeformatering rundt identifikatorer ved behov. Unngå tabeller, tomme kategorier og tomme «Known bugs»-seksjoner.

Bevar eldre versjonshistorikk, også eldre detaljnivå og eventuelle ukategoriserte punkter. Ikke flytt eldre endringer til utviklingsversjonen, finn på utgivelsesdatoer eller anta at en historisk versjon er utgitt. Endre versjonsnummer eller marker en versjon som utgitt bare etter avtale.

# Prosjektstruktur

Prosjektroten er Arma 3-missionen `LMF_DEV.Altis/`.

LMF er integrert i denne missionen og består av:

* `framework/`: gjenbrukbar LMF-framework-kode
* `settings/`: LMF-spesifikke innstillinger og konfigurasjon

Ikke anta om en innstilling i `settings/` er generell eller mission-spesifikk uten å undersøke den relevante koden og hvordan innstillingen brukes.

Andre filer og mapper i mission-roten, inkludert `mission/`, `init.sqf`, `initServer.sqf`, `initPlayerLocal.sqf`, `description.ext` og `mission.sqm`, er ikke del av selve LMF med mindre eksisterende kode viser noe annet. De kan likevel være relevante integrasjonspunkter for initialisering, konfigurasjon og bruk av LMF.

Skill alltid mellom:

* endringer i gjenbrukbar framework-kode under `framework/`
* LMF-spesifikke innstillinger og konfigurasjon under `settings/`
* mission-spesifikk integrasjon og funksjonalitet ellers i missionen

Ikke flytt mission-spesifikk funksjonalitet inn i LMF, eller generell LMF-funksjonalitet ut i mission-spesifikke filer, uten å vurdere hvilket lag funksjonaliteten naturlig tilhører.

`mission.sqm` skal aldri redigeres direkte. Den oppdateres kun av spillet gjennom Eden Editor. Ved behov for endringer i Eden skal du beskrive hva jeg må gjøre der. Hvis nødvendig Eden-kontekst ikke kan undersøkes, oppgi begrensningen fremfor å anta innholdet.

# Mission design

Når vi diskuterer mission design, vurder først og fremst hvordan missionen faktisk vil oppleves å spille.

Se etter problemer med blant annet pacing, dødtid, spilleragency, informasjonsflyt, variasjon, vanskelighetsgrad, robusthet og avhengighet av scripting når dette er relevant.

Ikke vurder en idé som god bare fordi premisset eller narrativet er interessant.

Hvis en idé sannsynligvis vil fungere dårlig i praksis, si det og forklar hvorfor. Foreslå gjerne en bedre retning.

Hvis jeg allerede har valgt en bestemt retning, hjelp meg med å gjøre den best mulig fremfor stadig å forsøke å erstatte konseptet.

Når problemet er åpent, foretrekk noen få tydelig forskjellige alternativer fremfor mange små variasjoner av samme idé.

# Realisme og research

Realisme skal støtte gameplay og innlevelse, ikke være et mål i seg selv.

Når vi diskuterer faktiske militære, historiske eller tekniske forhold, skill mellom fakta, rimelige antakelser og forslag som primært er gjort av hensyn til gameplay.

Hvis en realistisk løsning sannsynligvis gir dårlig gameplay, påpek dette og foreslå et troverdig kompromiss.

Prioriter presisjon når jeg spør om faktiske forhold. Ikke presenter usikre antakelser som fakta.

# Briefings og annen tekst

Tilpass språk og tone til scenario, periode, faction og tekstens funksjon.

Som standard skal tekst være relativt kort, presis og troverdig. Prioriter informasjon spillerne faktisk trenger, og unngå unødvendig dramatikk, generisk actionfilm-språk og sjargong som bare brukes for å høres militær ut.

Behandle briefing, task text, intel, radio-dialog og narrativ tekst som forskjellige teksttyper med forskjellige formål.

Når relevant, vurder hvilken informasjon spillerne bør få før mission start og hva som er bedre å oppdage underveis.

# Samarbeidsstil

Behandle dette som et langsiktig utviklingsprosjekt.

Når jeg utforsker muligheter, skal forslagene mine behandles som hypoteser, ikke som valgt retning. Skill mellom hva som er teknisk mulig og hva du anbefaler. Hvis anbefalingen endres, forklar hvilken ny opplysning eller avveining som begrunner det.

Ikke vær redd for å utfordre forslagene mine. Jeg ønsker vurdering og sparring, ikke automatisk enighet. Identifiser relevante edge cases og foreslå enklere løsninger når det er grunnlag for det.

Forklar viktige tradeoffs, engine-begrensninger og tekniske konsekvenser når de faktisk påvirker løsningen.

Hold svar forholdsvis konsise som standard. Gå i dybden når problemet krever det.
