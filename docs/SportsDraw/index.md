---
title: Sports Draw
---

# Sports Draw

## Intro
In 2022, after several years of threatening it, the [Northern Region Football](https://nrf.og.nz/) stopped managing the draw for the set of clubs
making up the Western Junior Framework.  This group is made up of a number of clubs in Auckland's western suburbs.  These clubs had banded together 
to run an in-house programme for the fun football age group (U6, U7 and U8), this programme had and works well for these clubs many of which can 
only field one or two teams at each age group, hardly enough for a mini football tournament the NRF was requiring.

The clubs decided instead to keep going with their programme.  The only real gap in admin that they had (they had been doing most of it anyway)
was the creation of the draw.  For two years they used an Excel spreadsheet, quite a good one, that generated the draws in a printable distributable
format.  But it had its down side, hard to work, easy to stuff up, needs a good computer.

Coupled with the need from above, with a sudden desire for me to refamiliarize myself with a tool set I haven't used in 10 years, I decided to put
this app together.  A simple scaffolded site with basically one single public page, shouldn't be too hard.

These pages document the administration side of this site.  Maybe I'll add some technical ones later, but for now... just the admin.

## Structure

The management of the draw is based around the _Competition_ this is the base, that determines the first and last day of the competition and the field
assignments.  From here the are a number of things that hang off this:

### [The Draw](thedraw.md)

:   The main screen of the draw.  Allows filtering for the competition and date.

### [Competition](competition.md)

:   Ok I said it above.  But it needs to be in here too.  The Competition is the base for the draw allowing all settings of the draw to be managed.
    The competition you are managing is stored in your profile so that the next time you come in (including just viewing the draw) you will be using 
    this competion.  The competition in your profile can be selected by clicking "select" on the competition management page, or by "editing" the competition
    from that same grid.

### [Teams](teams.md)

:   The teams competing in this competition.

### [Times](times.md)

:   The times for the games on the day, and the colour those time bands appear on the draw.

### [Non-playing days](noplaydays.md)

:   These are the days that the competition doesn't run, even though the day is between the start and end dates of the competition.
    For example, Easter weekend, School Holidays etc.

### [Generate Draw](generate.md)

:    This will trigger the generation (or regeneration) of the draw for or all game days that are greater than today.

