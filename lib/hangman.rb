# Things we need to store into a variable: 
# The current word
# The letters that the player has used
# The available letters

# Logic for the game:
# If there is no saved game, the player will simply be prompted to start a game.
# If there is a saved game, the player will be propted to start a new game or continue the previous game.
# In the game, the player will be shown a number of blanks and will be prompted to input a letter.
# If the letter is correct, all of the blanks that contain that letter will be filled.
# If the letter is not correct, the letter will be removed from the available letters and the player will receive a strike.
# The game will end when the player gets too many strikes or the player successfully guesses the word.

require 'json'

class GameState
    attr_accessor :current_word, :used_letters
  
    def initialize(current_word, used_letters)
      @current_word = current_word
      @used_letters = used_letters
    end
  
    def to_json(*args)
      {
        JSON.create_id => self.class.name,
        'current_word' => current_word,
        'used_letters' => used_letters
      }.to_json(*args)
    end
  
    def self.json_create(h)
      new(h['current_word'], h['used_letters'])
    end
  end

class StartMenu
    @@current_word = nil
    
    def start_menu
        if @@current_word
            puts true
        elsif !@@current_word
            puts false

        end
        puts "Hello there! Would you like to start a new game or load a previous save?"
        puts "Enter 'q' to quit at any time."
        input = ''

        while input != 'q' 
        input = gets.chomp.downcase
        
        if input == 'new'
            puts "You started a new game!"
            new_game
        elsif input == 'load'
            puts "You loaded the game!"
            load_game
        elsif input == 'save'
            puts "You saved the game!"
            save_game
        else
            puts "Please enter a valid option."
        end
    end

    end

    def new_game
        the_word = PlayGame.new.word_to_play
        @@current_word = the_word
        # file = File.new('save_file.txt', 'w')
        # file.write(the_word)
        # file.close

        puts @@current_word
    end

    def quit_game
        puts "Thanks for playing!"
        exit
    end

    def save_game
        a = GameState.new('artist', ['A', 'B', 'C'])
        x = a.to_json
        @@current_word = ''
        if @@current_word
            save = SavedGame.new(x)
            puts save, "This is save"
            file = File.new('save_file.txt', 'w')
            file.write(x)
            file.close
        elsif !@@current_word
            puts "There is nothing to save."
        end
        puts @@current_word
    end

    def load_game

        if File.exist?("save_file.txt")
            puts "The file exists!"
            save_data = File.open("save_file.txt", "r") do |x|
                begin
                result = x.readline
                rescue EOFError
                    puts "You reached the end"
                else
                    result
                end
            end 
        end
        puts save_data

        get_result = JSON.parse(save_data, create_additions: true)

        p get_result.used_letters
        p get_result.used_letters[1]
                
    end
end


class PlayGame 
    attr_reader :current_word, :available_letters

    @@strike_counter
    @@words_file_path = File.expand_path('lib/random_words.txt')
    @@available_letters_array = []

    def choose_word(path, line)
        result = ""

        File.open(path, "r") do |x|
            while line > 0
                line -= 1
                result = x.readline
            end
        end
        result
    end

    def random_word
        (rand(PlayGame.new.file_length(@@words_file_path)) + 1)
    end

    def word_to_play
        PlayGame.new.choose_word(@@words_file_path, random_word)
    end

    def file_length(path)
        word_count = 0
        file = File.open(path, "r")
    
        file.each do |x| 
            word_count += 1
        end  
        word_count
    end

    def play
        @@available_letters_array = PlayGame.new.make_letters()

    PlayGame.new.player_choice()
    
    
    @@available_letters_array = PlayGame.new.make_letters()
    p @@available_letters_array
    exit
    end

    def player_choice
        input = ''

        while input != '1'
            input = gets.chomp.upcase
                if @@available_letters_array.include?(input)
                    puts "It includes #{input}"
                    @@available_letters_array.slice!(@@available_letters_array.find_index(input),1)
                else
                    puts "That is not a valid letter."
                end
                p @@available_letters_array
                break if @@available_letters_array.length < 1
        end
    end

    def is_letter_correct?

    end

    def add_strike
        @@strike_counter += 1
    end

    def reset_strike
        @@strike_counter = 0
    end 

    def win_game
       puts "Hurray! You won the game!" 
    end

    def lose_game
        puts "Oh dear :/ You lost."
    end

    def make_letters
        uppercase_counter = 1
        uppercase_abc_array = []
        
        26.times do |x|
            uppercase_abc_array.push((x+65).chr)
        end
        uppercase_abc_array
    end
end

class SavedGame
    attr_accessor :saved_game_data

    def initialize(saved_game_data)
        @saved_game_data = saved_game_data
    end

    def saved_game_data
        @saved_game_data
    end
end
#StartMenu.new.start_menu()
#PlayGame.new.play()









#=> #<A:0x007f92cc8f37f0 @a=1, @b="a", @c=[1, 2, 3]>

#x = JSON.parse(a.to_json, create_additions: true)



StartMenu.new.load_game
   

            

           

