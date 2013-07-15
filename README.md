Eve Online
==========

(the following is shamelessly stolen from [Wikipedia (30.08.2012)](http://en.wikipedia.org/wiki/Eve_online):

**Eve Online** (stylised **EVE Online**) is a video game by [CCP Games](http://en.wikipedia.org/wiki/CCP_Games). It is a player-driven, persistent-world MMORPG set in a science fiction space setting. Characters pilot customizable ships through a galaxy of over 7,500 star systems. Most star systems are connected to one or more other star systems by means of stargates. The star systems can contain moons, planets, stations, wormholes, asteroid belts and complexes.

Players of Eve Online can participate in a number of in-game professions and activities, including mining, piracy, manufacturing, trading, exploration, and combat (both player versus environment and player versus player). The character advancement system is based upon training skills in real time, even while not logged into the game.

mram-evedata, aka this gem
==========================

CCP Games releases a dump of the static database objects of the EVE Online Universe whenever there is a major expansion (additional game content). Information about this can be found [here](http://wiki.eve-id.net/CCP_Static_Data_Dump). Unfortunately, these data dumps come originally as a Microsoft SQL Server Backup file, which not many people consider to be optimal for using in their own portals/community websites/tools etc. Fortunately however, there are people in the community who convert these dumps to other SQL formats, like MySQL, PostgreSQL, and SQLite3.

This gem aims to lessen the burden of manually importing new dumps, and also provides an ActiveRecord "abstraction layer" of the data presented.

Disclaimer
==========

* i'm not a professional software developer, let alone a ruby/rails experienced programmer. i do this because i actually play EVE Online and because scripting and hacking together tools is a hobby of mine.
* all data/information/code is presented to you as is. it might work for you, it might not, it might kill your dog. use at your own risk, you have been warned.
* initially i planned to diversify this gem to support at least MySQL/PostgreSQL/SQLite, but since i myself only use MySQL for my current projects, i kind of just stuck with that for now.
* i also had plans to allow for the simultaneous use of different EVE-Db-Dump versions, but scrapped those due to time constraints. so only the latest dump is supported atm.
* i am **in no way affiliated with CCP Games**, all of the brands and names and whatnot are theirs and theirs only. insert the rest of the legal yadda yadda. i'm not doing this for profit.

Data to be imported
===================

The data this gem is downloading and importing is **not** assembled by me. i am merely providing a "glue layer" to use it easily and (somewhat) efficiently in a Rails application.
Currently, i am using [this guy's dump files](http://www.fuzzwork.co.uk/dump/) for the import, but this might change at any time.
UPDATE 12.07.2013: now using [this data source](http://evedump.icyone.net/odyssey-1.0.12-89967/)

How to begin
============

in your rails project base path (Rails.root), do:

1. create database config block
   > rails generate eve\_data:sample\_db\_config

2. modify the db cfg to your needs (in config/database.yml)

3. download the current data dump file
   > rake eve\_data:download

4. import the dump into your database
   > rake eve\_data:import


[TODO: LOTS!]
