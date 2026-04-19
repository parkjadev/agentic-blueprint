# Australian spelling wordlist

Each line: `us_variant → au_variant`. The check script uses this list to flag US-English variants. Add new entries in alphabetical order; keep a blank line between blocks for readability.

## -ize / -yze → -ise / -yse

analyze → analyse
apologize → apologise
authorize → authorise
categorize → categorise
criticize → criticise
customize → customise
emphasize → emphasise
finalize → finalise
generalize → generalise
harmonize → harmonise
initialize → initialise
minimize → minimise
modernize → modernise
normalize → normalise
optimize → optimise
organize → organise
prioritize → prioritise
realize → realise
recognize → recognise
standardize → standardise
summarize → summarise
synchronize → synchronise
utilize → utilise

## -or → -our

behavior → behaviour
color → colour
favor → favour
flavor → flavour
honor → honour
humor → humour
labor → labour
neighbor → neighbour
rumor → rumour

## -er → -re

center → centre
fiber → fibre
liter → litre
meter → metre (keep "meter" when it's a measuring device e.g. "water meter")
theater → theatre

## -ense → -ence (noun only)

defense → defence
license → licence (noun only — the verb stays "license")
offense → offence
pretense → pretence

## Doubled consonants before -ed / -ing / -er

canceled → cancelled
canceling → cancelling
modeled → modelled
modeling → modelling
traveled → travelled
traveling → travelling
traveler → traveller

## Miscellaneous

catalog → catalogue
dialog → dialogue
gray → grey
mold → mould
program → programme (only for broadcast schedules/curricula; keep "program" for software)
skeptical → sceptical

## Ignore list (case-sensitive, exact-match tokens inside code fencing)

These strings are allowed even when they look US-English, because they refer to external APIs, identifiers, or keywords:

- `color:` (CSS)
- `background-color:` (CSS)
- `text-align:` (CSS)
- `License:` (SPDX)
- `initialize()` (JavaScript/TypeScript lifecycle)
- `onInitialize` (framework callback)
- `normalize` (ICU / string normalisation APIs)
- `center` (CSS value)
