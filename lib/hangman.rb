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
    attr_accessor :saved_word, :saved_used_letters
  
    def initialize(saved_word, saved_used_letters)
      @saved_word = saved_word
      @saved_used_letters = saved_used_letters
    end
  
    def to_json(*args)
      {
        JSON.create_id => self.class.name,
        'saved_word' => saved_word,
        'saved_used_letters' => saved_used_letters
      }.to_json(*args)
    end
  
    def self.json_create(h)
      new(h['saved_word'], h['saved_used_letters'])
    end
  end

class StartMenu
    @@current_word = nil
    @@save_data = nil
    @@word_to_save = nil
    @@used_letters_to_save = nil
    @@used_letters = nil
        
    def start_menu
        
        puts "Hello there! Would you like to start a new game or load a previous save?"
        puts "Enter 'q' to quit at any time."
        input = ''

        while input != 'q' 
        input = gets.chomp.downcase
        
        if input == 'new'
            puts "You started a new game!"
            new_game()
            PlayGame.new.start_game
        elsif input == 'load'
            load_game()
            PlayGame.new.play
        elsif input == 'save'
            save_game()
            PlayGame.new.play
        elsif input == 'quit'
            quit_game()
        else
            puts "Please enter a valid option."
        end
    end

    end

    def new_game
        the_word = PlayGame.new.word_to_play
        PlayGame.new.set_current_word(the_word)
        PlayGame.new.set_used_letters([])
        PlayGame.new.set_new_game_available_letters()
        PlayGame.new.set_loaded_blanks()
        PlayGame.new.set_word_blanks()
        PlayGame.new.reset_strike()
        PlayGame.new.play()
        # file = File.new('save_file.txt', 'w')
        # file.write(the_word)
        # file.close

        puts the_word
    end

    def quit_game
        puts "Thanks for playing!"
        exit
    end

    def save_game
        @@save_data = StartMenu.new.get_save_data()
        @@word_to_save = @@save_data.saved_word
        @@used_letters_to_save = @@save_data.saved_used_letters

        if @@word_to_save
            a = GameState.new(@@word_to_save.chomp, @@used_letters_to_save)
            x = a.to_json
        
            save = SaveData.new(x)
            puts save, "This is save"
            file = File.new('save_file.txt', 'w')
            file.write(x)
            file.close
        elsif !@@word_to_save
            puts "There is nothing to save."
        end
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
        
            get_result = JSON.parse(save_data, create_additions: true)
            PlayGame.new.set_current_word(get_result.saved_word)
            PlayGame.new.set_used_letters(get_result.saved_used_letters)
            PlayGame.new.make_letters
            PlayGame.new.set_available_letters(get_result.saved_used_letters)
            PlayGame.new.set_word_blanks()
            PlayGame.new.reset_strike()
            PlayGame.new.set_loaded_blanks()

        elsif
            puts "There is nothing to load"
        end
    end

    def get_save_data
        PlayGame.new.ready_save()
    end
end


class PlayGame 
    attr_reader :word_to_play, :used_letters

    @@strike_counter = 0
    @@words_file_path = File.expand_path('lib/random_words.txt')
    @@available_letters_array = []
    @@used_letters_array = []
    @@current_word = nil
    @@word_blanks = nil
    @@strikes_display = ''

    def ready_save
        SavedGame.new(@@current_word, @@used_letters_array)
    end

    def choose_word(path, line)
        result = ""

        File.open(path, "r") do |x|
            while line > 0
                line -= 1
                result = x.readline
            end
        end
        result.chomp
    end

    def random_word
        (rand(PlayGame.new.file_length(@@words_file_path)) + 1)
    end

    def word_to_play
        PlayGame.new.choose_word(@@words_file_path, random_word)
    end

    def set_current_word(word)
        @@current_word = word
    end

    def set_used_letters(used_letters)
        @@used_letters_array = used_letters
    end

    def set_available_letters(used_letters)
        new_used_letters_array = @@available_letters_array.each_with_index do |letter, index|
            used_letters.each do |used_letter| 
                if @@available_letters_array.include?(used_letter)
                    @@available_letters_array.slice!(@@available_letters_array.find_index(used_letter), 1)
                end
            end
        end
        @@available_letters_array = new_used_letters_array
    end

    def set_new_game_available_letters
        @@available_letters_array = make_letters()
    end

    def set_word_blanks()
        @@word_blanks = make_blanks(@@current_word)
    end

    def set_loaded_blanks()
        practice_word = @@current_word.upcase.split('')
        p practice_word
        used_letters = @@used_letters_array

        used_letters.each do |input|
            if !practice_word.include?(input)
                add_strikes_to_display()
            end

            practice_word.each_with_index do |letter, index|
                if input == letter
                    @@word_blanks[index] = letter
                end
            end
        end
        practice_word
    end

    def file_length(path)
        word_count = 0
        file = File.open(path, "r")
    
        file.each do |x| 
            word_count += 1
        end  
        word_count
    end

    def start_game
        @@available_letters_array = PlayGame.new.make_letters()
        PlayGame.new.set_current_word(PlayGame.new.word_to_play)
        @@word_blanks = PlayGame.new.make_blanks(@@current_word)
        @@strike_counter = 0
        @@strikes_display = ''

        play()

    end

    def play
        
        p @@current_word
        puts "Lets get ready to play!"
        
        input = ''
        while input != 'QUIT'
            p @@word_blanks
            p @@used_letters_array
            puts "Strikes: #{@@strikes_display}"
            input = gets.chomp.upcase
            player_choice(input)

            win_game if @@current_word == @@word_blanks
            lose_game if @@strike_counter >= 6
            break if @@current_word.upcase.split('') == @@word_blanks
            break if @@strike_counter >= 6

            StartMenu.new.start_menu if input == 'MENU'
        end
            
        play_again()

        exit
    end

    def word_maker_holder_method(input)
        
        practice_word = @@current_word.upcase.split('')
        p practice_word
        
        practice_word.each_with_index do |letter, index|
            if input == letter
                @@word_blanks[index] = letter
            end
        end
    end

    def matches_word(input)
        all_caps_current_word = @@current_word.upcase
        if !all_caps_current_word.include?(input)
            add_strikes_to_display()
        end
    end

    def add_strikes_to_display
        @@strike_counter += 1
        @@strikes_display += 'X'
    end

    def player_choice(input)
        if @@available_letters_array.include?(input)
            @@available_letters_array.slice!(@@available_letters_array.find_index(input),1)
            matches_word(input)
            word_maker_holder_method(input)
            @@used_letters_array.push(input)
        else
            puts "That is not a valid letter."
        end
    end

    def player_guess()
        @@strike_counter = 0
       
        player_choice(input)

        puts word_blanks.join('  ')
        
        PlayGame.new.play_again() if word_blanks == practice_word
    
    end

    def play_again
        puts "Wanna play again? (Y/N)"
        input = ''
        while true

            input = gets.chomp.upcase

            case(input)
                when 'Y' 
                    StartMenu.new.new_game()
                when 'N' 
                    StartMenu.new.quit_game()
                else 
                    puts "Please enter a valid option."
            end
        end
    end

    def make_blanks(word)
        p word
        blank_array = []
        word.length.times do 
            blank_array.push('_')
        end 
        blank_array
    end

    def reset_strike
        @@strike_counter = 0
        @@strikes_display = ''
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
        @@available_letters_array = uppercase_abc_array
        @@available_letters_array
    end

end

class SavedGame
    attr_accessor :saved_game_data

    def initialize(saved_word, saved_used_letters)
        @saved_word = saved_word
        @saved_used_letters = saved_used_letters
    end

    def saved_word
        @saved_word
    end

    def saved_used_letters
        @saved_used_letters
    end
end

class SaveData 
    def initialize(save_data)
        @save_data = save_data
    end
end

#StartMenu.new.start_menu()
   
PlayGame.new.start_game