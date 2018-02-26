# Cornell Classes API - CSV Dumper
# Program used to query Cornells courses API for basic info
#
# This program requires a file called raw_list with this format:
# AEM 3220: Digital Business Strategy
# AEM 3251: The Business Laboratory and New Venture Management
# AEM 3340: Women, Leadership & Entrepreneurship
#
# This program will output its results to a file called results.csv
# Aaron Kaye, 2018

# Requiring basic libraries for making API call and file handling
require 'net/http'
require 'uri'
require 'json'
require 'csv'

def main
  # Building a list of course code from the raw list
  course_codes = []
  File.open('raw_list.txt', 'r') do |f|
    f.each_line do |line|
      course_codes.push(line.split(':')[0])
    end
  end

  initialize_csv # Opens a new CSV file and appends the headers
  api_caller(course_codes.uniq) # Call to our helper function
end

# Helper function for crafting API calls
def api_caller(codes)
  semester_searching = ['SP18', 'FA17', 'SP17', 'FA16', 'SP16', 'FA15', 'SP15', 'FA14'] # Semesters to search
  current_semester = 0 # Keeping track of the semester index
  not_found = [] # Courses that were not found in our search

  # Loop through each course code so we search for every course in our list
  codes.each do |c|
    args = [] # Empty our args to prepare seach params
    args.push(semester_searching[current_semester]) # Adding most recent semester to start
    actual_code = c.split(' ')[0] # Course Subject (e.g. AEM)
    actual_level = c.split(' ')[1] # Course Level (e,g, 2300)

    args.push(actual_code) # Adding the course code
    args.push("UG") # Adding undergraduate as the class level
    # Calculating the classLevel
    floor = (actual_level.to_i / 1000) * 1000 # Rounding down to nearest 1000th
    args.push(floor) # Adding the nearest class level

    searching = true
    course = nil
    while(searching)
      puts "Searching for: #{actual_code} #{actual_level} in #{semester_searching[current_semester]}"
      temp_courses = make_api_call(args) # Making the actual API call to Cornell
      sleep(1) # Sleep for a second in case the response is slow
      if temp_courses['status'] == 'success'
        # Query ran successfully
        # Searching for that specific course
        course = temp_courses['data']['classes'].select{ |course| course["catalogNbr"] == actual_level}.first
        searching = course.nil? # Not searching if course was found
        sleep(2) # Sleep for two seconds to avoid overloading Cornell's server
        if current_semester == semester_searching.length - 1
          # No more semesters left to search, stale class
          puts "Coundn't Find: #{actual_code} #{actual_level}"
          not_found.push("#{actual_code} #{actual_level}")
          searching = false
        end
        current_semester += 1 # Search in the next semester
        args = [semester_searching[current_semester], actual_code, "UG", floor] # Reset args with new semester
      else
        # Query was not run successfully, probably a 500 error from Cornell
        puts "Error finding: #{actual_code} #{actual_level}"
        searching = false
        not_found.push("#{actual_code} #{actual_level}")
      end
    end
    # Write the course to the CSV and reset the semester index for our next search
    write_to_file(course) unless course.nil?
    current_semester = 0
  end

  show_error_info(not_found)
end

# Function to make the API call and return a hash_response
# args[0] - Sem Year
# args[1] - Subject
# args[2] - Academic Career
# args[3] - classLevel
def make_api_call(args)
  uri = URI("https://classes.cornell.edu/api/2.0/search/classes.json?roster=#{args[0]}&subject=#{args[1]}&acadCareer[]=#{args[2]}&classLevels[]=#{args[3]}")
  begin
    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri

      response = http.request request # Net::HTTPResponse object
      hash_response = JSON.parse(response.body)
      hash_response
    end
  rescue JSON::ParserError
    {"status": "Error"} # Returning an empty hash
  end
end

# Initialize the CSV file with the approriate headers
def initialize_csv
  CSV.open("results.csv", "wb") do |csv|
    csv << ["class", "title of course", "credits"]
  end
end

# Function to write a course to the CSV
# course = A ruby hash of the course to add
def write_to_file(course)
  className = "#{course["subject"]} #{course["catalogNbr"]}"
  title = course["titleLong"]
  credits = course["enrollGroups"][0]["unitsMaximum"]
  CSV.open("results.csv", "a") do |csv|
    csv << [className, title, credits]
  end
end

def show_error_info(not_found)
  puts
  puts "======= ERROR INFO: ============="
  puts "The following courses were not found:"
  not_found.each do |nf|
    puts "#{nf}"
  end
  puts "================================"
end

main
