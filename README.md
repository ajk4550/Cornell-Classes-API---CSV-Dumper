# Cornell-Classes-API---CSV-Dumper
Uses the API available at classes.cornell.edu to search for courses in your data list and add supplemental information. I was solving an issue where I had a list of course codes that I needed more information about such as the number of creids the course is. This script was thrown together to aid with this, hopefully you are able to tweak it to meet your needs.

## Getting Started

This program is meant to be a quick approach for working with Cornell's classes API. The issue with the API is that you cannot directly query for a course code, you need to query for the class level and search from there. There is no guarentee the course is offered on a given semester.

### Prerequisites

The program is built on ruby and uses the following ruby libraries: 

```
'net/http', 'uri', 'json', and 'csv'
```

### Running

The program can be run with:

```
$ ruby csv-course-dumper.rb
```

Running requires you to have a list of courses called raw_list. Note only the course code is actually used, however the program does split the course code from the overall title so that format is required or tweaking to the code will be necessary

```
$ cat raw_list.txt
AEM 3220: Digital Business Strategy
AEM 3251: The Business Laboratory and New Venture Management
AEM 3340: Women, Leadership & Entrepreneurship
```

## The result

After running the program, you will have a CSV file which by default include the course code, title, and number of credits

```
$ cat results.csv
class,title of course,credits
AEM 3220,Digital Business Strategy,3
AEM 3251,The Business Laboratory and New Venture Management,4
AEM 3340,"Women, Leadership, and Entrepreneurship",1
```

### Errors

It is possible that a course will not be found in the database. By default this program searches from SP18 - FA14. This can be tweaked in the code but the course info may be stale at that point.
I've also encountered errors while searching for courses in the wrong academic career. For example, when I searched for an ILRHR 6611 I get a 500 error. This will throw a JSON::Parse error which is somewhat handled. Those corses will need to manually be handled. Likely it is a graduate course and this program by default is just searching for undergraduate courses.

## Versioning

This is the first version of the tool, since this was a one time use script I do not plan on maintaining unless I need to use it more.

## Authors

* **Aaron Kaye** - [Portfolio](http://aaronkaye.com/)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
Here is the documentation to the API
https://classes.cornell.edu/content/SP18/api-details
* Hat tip to anyone who's code was used
* Inspiration
* etc
