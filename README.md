# ActiveRecordLite

ActiveRecordLite is an an Object Relational Mapping system inspired by the functionality of ActiveRecord in Ruby on Rails.  ActiveRecordLite allows you to communicate with and manipulate data in a SQLite Database, as well as create objects corresponding to the database information.  Lastly, the user is able to create complex associtaions between objects to allow for clean and syntatical SQL queries to return relavent data.

## Description

#### Classes


##### DBConnection
 This class directly communicates with the SQLite Database.  Any communication to SQLite goes through this class.Methods include, but are not limited to:
* #open -- Generates SQLite Database from .sql file
* #execute/#execute2 -- Returns data from a table (with or without column names)
* #last_insert_row_id -- Adds data to specified table

##### SQLObject
 This class uses DBConnection to add and retrieve data specific to one table.  Methods include, but are not limited to:
 * #finalize! -- Creates methods for setting and getting data from table columns
 * #columns -- Returns column names of specified table
 * #where -- Allows user to search by custom SQL query
 * #find -- Search by id
 * #update/#insert -- Adds or updates data on given table

##### Associatable (module extended by SQLObject)
 This module allows the user to define several associations between tables in order to create cleaner and faster SQL queries.  Associatable also generates methods on the SQLObject to search by associations.  Associations available are:
 * #belongs_to -- Search a foreign table by a reference to a foreign key stored on the local table (returns one object)
 * #has_many -- Search a foreign table for references to a local key stored on the foreign table (returns multiple objects)
 * #has_one_through -- Search through a belongs_to association for a reference to a local key stored on a third-party table (returns one object)

# How to Run These Files
These files require Ruby to run. The best tutorial I've found is this: [Ruby Installation Tutorial](http://installrails.com/steps).  Also required is [SQLite](https://www.sqlite.org/).

Once Ruby is installed, download the files, bundle install, and load 'index.rb' in Ruby Console.  This sets up your SQLite Database, as well as loads all files and creates the following associations:
* A cat #belongs_to an owner
* A human #belongs_to a house
* A house #has_many an humans.
* A cat has a house (using #has_one_through).

### Using ActiveRecordLite

Feel free to use any of the methods found in the SQLObject class for creating, editing, or searching instances of Cat, House, or Human on the database.  You are also able to use the relationships to find a Cat's owner (for example).

Have fun!
