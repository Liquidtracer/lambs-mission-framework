# Instrukser for AI/Codex

## Samarbeid og oppdragsomfang

Behandle brukeren som en erfaren Arma 3-mission maker og teknisk samarbeidspartner. Ikke forklar grunnleggende konsepter uten at det er etterspurt. Svar forholdsvis konsist, men forklar viktige tradeoffs og begrensninger.

Ved gjennomgang, vurdering, forklaring eller forslag skal filer ikke endres med mindre implementering allerede er avtalt. Ved implementering, gjennomfør innenfor avtalt omfang uten unødvendige bekreftelser. Ikke utfør uvedkommende refaktorering, opprydding, modernisering eller redesign.

Bevar eksisterende gameplay, UI, informasjonsflyt og betjening med mindre en oppførselsendring er uttrykkelig bestilt. Beskriv nødvendige oppførselsendringer tydelig; ikke skjul dem som «opprydding» eller «robusthet». Tilsiktede særvalg er ikke feil bare fordi en annen løsning virker mer generell.

Før ombygging anbefales, identifiser det konkrete problemet, minste nyttige endring og kostnaden i kompleksitet, migrering og testing. Vurder om dagens løsning bør beholdes. Ved refaktorering må gameplay-hensikt og forskjeller mellom kontrakter bevares; still ett målrettet spørsmål hvis avgjørende hensikt er ukjent.

Behandle forslag under utforsking som hypoteser, ikke beslutninger. Utfordre med begrunnelse, skill teknisk mulighet fra anbefaling, og forklar hvorfor en anbefaling eventuelt endres.

## Dokumenter som skal leses

- Følg [docs/development.md](docs/development.md) for utviklingsprinsipper, navngivning, kommentarer, filheadere, testing og dokumentasjons-/changelog-policy.
- Før teknisk arbeid med SQF, LMF, initialisering, integrasjon, locality, multiplayer eller JIP: les fellesdelen av [docs/architecture.md](docs/architecture.md), deretter berørte modulavsnitt og avhengigheter. Les hele dokumentet ved bred arkitekturgjennomgang eller uklart omfang.
- Bruk [docs/mission-maker-reference.md](docs/mission-maker-reference.md) ved arbeid med mission-maker-rettede kall og konfigurasjon. Dette er den kanoniske praktiske referansen.
- Uendret innhold som allerede er tilgjengelig i konteksten trenger ikke leses på nytt. Arkitekturdokumentet er ikke obligatorisk for oppgaver som åpenbart ikke berører teknisk mission-funksjonalitet.

Dokumentasjonen erstatter ikke kodeundersøkelse. Oppdater berørte dokumenter ved avtalte kontrakts-/oppførselsendringer etter utviklingsguiden. Ved ren vurdering skal dokumentasjonsrettinger foreslås, ikke utføres. Ikke opprett nye dokumentasjonsfiler, reviewrapporter, endringslogger eller testplaner uten uttrykkelig bestilling; lever slike resultater i samtalen som standard.

## Kritiske tekniske krav

Dedicated server og Join-in-Progress (JIP) er grunnleggende krav. Ta hensyn til faktisk locality, initialisering, execution context, state og nettverksbruk; en løsning som bare virker i editoren er ikke tilstrekkelig.

Undersøk relevant LMF-kode før du beskriver eller endrer den. Bruk eksisterende framework fremfor å anta at et parallelt system må bygges. Kode/config beskriver implementasjonen; brukerkrav og avklarte designvalg beskriver hensikten. Synliggjør motstrid og manglende kontekst fremfor å gjette. Ved debugging, søk faktisk årsak fremfor bare en workaround.

Ikke finn på Arma 3-kommandoer, SQF-syntaks, funksjoner, engine- eller modoppførsel. Når en vurdering avhenger av engine-oppførsel, undersøk den konkrete siden i den aktuelle [Bohemia Interactive Community Wiki](https://community.bohemia.net/wiki/), inkludert relevante syntaks-, locality-, execution-, MP- og versjonsvilkår. For ACE/CBA-spesifikk oppførsel, bruk relevant prosjektdokumentasjon eller kildekode og skill aktuell upstream-kilde fra installert modversjon.

Oppgi kildesidene som brukes. Skill dokumentert kontrakt, community-kommentarer, kodeutledet tolkning og utestede antakelser. Påpek tvetydig eller mangelfull dokumentasjon; foreslå ved behov en minimal reproduksjon eller dedicated-test.

Skill uttrykkelig mellom statisk kode-/referansekontroll, parser-/syntakskontroll, lokal runtime-test, dedicated-test med flere klienter og JIP-test. Rapporter bare utført kontroll og hva den dokumenterer. En lokal test eller parserkontroll beviser ikke korrekt multiplayer-oppførsel. Skill rapportert symptom, kodeutledet risiko og runtime-bekreftet årsak; oppgi korte, konkrete gjenstående tester når relevant.

## Prosjektgrenser og beskyttet konfigurasjon

Både `framework/` og `settings/` er LMF: implementasjon og mission-maker-konfigurasjon. Rotfilene gir også utviklingsmission og integrasjon; `description.ext` er blandet. Klassifiser etter innhold, ikke bare plassering. Ikke flytt funksjonalitet mellom lagene som uvedkommende opprydding.

`mission.sqm` er bevisst ubinarisert og kan inspiseres, men må aldri redigeres direkte. Eden Editor er autoriteten for endringer. Beskriv nødvendige Eden-endringer for brukeren; oppgi manglende kontekst fremfor å anta innholdet.

Forward Deploy og Vehicle Service skal ikke gjennomgås eller endres uten uttrykkelig forespørsel, heller ikke i brede kartlegginger. Avgrensningen gjelder ikke den delte Paradrop-modulen eller øvrig kjøretøyinitialisering og asset spawnere. Bevar dokumentert designbegrunnelse og særvalg.

De konfigurerte Nopryl-UID-ene gir tilsiktet vedvarende teknisk/admin-tilgang. Listene i `framework/XEH_preInit.sqf` og `description.ext` betjener forskjellige tilgangssystemer. Ikke fjern, konsolider eller endre dem som opprydding.
