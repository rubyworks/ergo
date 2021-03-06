# RELEASE HISTORY

## 0.4.0 / 2014-02-29

This major release renames the project from **Ergo** to **Rulebow**.
This will be the last name change. Promise. In addition a number of
other adjustments and code improvements have been made. This may be
the first release that's actually usable in production.

Changes:
 
* Rename project to Rulebow.
* Rename `book` method to `ruleset`.
* Rename `state` method to `fact`.
* Use single `Rulebook` file.


## 0.3.0 / 2013-02-13

Major release removes tasks. There are only rules now! In
addition *books* have been added which allow rules to be
grouped together. Oh! And you might have noticed the name
of the project has changed from *Fire* to *Ergo*.

Changes:

* Deprecate tasks.
* Add rule books.
* Rename project to Ergo.


## 0.2.0 / 2013-02-12

This is the last version with tasks. Tasks are being deprecated
for two reasons: a) they add a great deal of complexity to the
syntax and the implementation via their need for dependencies;
and b) tasks have proven to be an excuse for poorly designed 
rules, which, if properly written, would do the job just as well
if not better than any task. So it was decided that if tasks are
needed, then they should be provided via dedicated task system,
not via the rules system.

Changes:

* Default rule file is now `.fire/rules.rb` or `rules.rb`.
* Rules can depend on tasks using same hash notation as tasks.
* Modified the `#rule` method to define file rules given a string.
* Deprecated the `file` method for defining file rules.


## 0.1.0 / 2012-04-10

This is the initial release of Fire. Fire is state and rules-based
continuous integration and build tool.

Special thanks to Ari Brown for letting us take over the fire gem
for this project.

Changes:

* Happy first release day!

