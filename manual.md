matchup league development manual/log/idk
last updated: 2.1.0.5

# table of contents

- goals
- checklist
- backlog
- version numbering
- console guide
- exit codes
- rating
- tournament
- player personalities
- misc

---

# goals

## commit goals

- pro level

## release goals

- switch to pro level
- add leagues

## version goals

- season 11 playable

---

# checklist

## after pulling commit

- update verison in main and manual

## before pushing commit

- double check 'after pulling commit'
- backup save default and canon files, delete other save files

## after beginning release

- reset commit number to 0

## before finishing release

- update readme
- make sure save files from previous release can transfer

# backlog

## pressing:

- record viewer

## technical

- clean up dupe code in editor tables
- save to usr instead of res
- neater columns

## content

- ability to delete entities
- dramatic reveal
- icons instead of letters for types
- team color outline around fighter cards

## settings to add

- play cpu games before or after user game

# verison numbering

in the example 1.2.3.4:
1 = build,
2 = version,
3 = release,
4 = commit

# console guide

number on the left is the current frame ID, which increases once each frame.
this number resets to 0 after 9999

## icons

- / comment, debug
- ^ system notificaiton
- . gentle reminder
- -     warning
- ! major warning, error
- !! high priority error
- ? huh?
- \> signal intercept

# exit codes

## Error codes

given when an unexpected or unwanted behavior is caught by the program.
negative number means program could not continue

0 no action
1 generic
2 UI-related
3 insufficient data
4 read/write
5 conflict
6 invalid
7 outdated
60 timeout
99 debug/placeholder

## exit codes

given when a task finishes without any caught warnings or errors

0 no action
1 success
2+ alternate outcome
99 debug/placeholder

# rating:

a quantitative way to measure an entity's value

## fighters

currently all types are weighted equally but ideally should be weighted by frequency
m = 1 / # of types
rating = (base / 10) + (strength _ m) - (weakness _ m)

## teams

average rating of fighters + (wins _ 25) + (ties _ 12.5)

## game

sum of team ratings

## league

average rating of teams

## rating scale

preserves an entity's rating in its current context
will be used to standardize across tiers and seasons
current scale: none
ideal scale: average A tier rating = 100

# player personalities

each player will have one overall archetype which is made of several subtypes
archetypes:

- user
- default
- cautious
- aggressive
- true arbitrary
- rational arbitrary
- short term
- long term

## subtypes

(user and arbitrary are the same in each one)

fighter value
rating
base
performance
mods
contract
age

team value
rating
performance

coaches give certain bonuses to your team

contract cost/length
trade value
offseason development

# tournament

## full bracket formula

The full bracket formula (2^ceil(log_2(t))) calculates the total number of teams and byes needed for a bracket
It essentially rounds the number of teams (t) up to the next number in the 2^x series (2, 4, 8, 16, 32, etc.)

quick log lesson:
Taking log_x(y) (log base x of a number y) gives you the amount of times you need to multiply x by itself
to get to y.
z = log_x(y) is the same thing as y = x^z
example: if you take log_2(35) you will get 5, since you need to multiply 2 by itself 5 times (2^5) to get 32.

- start by calculating the number of rounds needed by taking log base 2 of the number of teams.
- if this number is not a whole number, it is rounded up
- the resultant number, n, is the total number of rounds
- take 2^n to get the full bracket number

For example, in a tournament of 24 teams a:

- start with log_2(24), which rounds up to 5
- the full bracket number is 2^5, or 32
- meaning there will be 24 teams and 8 byes

## traditonal seeding formula

in a traditionally seeded tournament, the highest seed plays against the lowest seed, the second highest against the second
lowest, and so on
example: in a bracket of 8, the seed pairings are 1-8, 4-5, 2-7, 3-6
each pairing is ordered such that if the higher seed wins every time, this highest-lowest pattern will hold each round.
however, when the lower seed wins (or when byes are involved), some math is needed to determine who plays who

the formula for finding what seeds should match in any given round is s2 = n + 1 - s1
where n = number of teams & byes in current round (always in 2^x series), s1 is the current seed, s2 is the opponent seed

how the current round's opponent is computed:

- if the current seed is eliminated, replace with opponent from previous round (using these steps)
- calculate formula to get opponent seed
- if the opponent seed was already eliminated, use formula to find the opponent's opponent from the previous round
  (remember to double n)
- repeat until a non-eliminated seed is found

## tourney key

stored as an array [i, r] where i is the tourney id and r is the tourney round

# misc

entity relations stored as objects while game is running, when saving to file save the id only.
entities save the id of the higher relation in this hierarchy:

- level
- league
- team
- player
- fighter
- game

## game rounds

> = 1: regular season
> == 0: freeplay
> is an array: tournament
