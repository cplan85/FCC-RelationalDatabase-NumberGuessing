#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))

echo $RANDOM_NUMBER

EXECUTE_GAME() {

  USERNAME=$1
  echo " $USERNAME : MY ARGUMENT"

          echo "Guess the secret number between 1 and 1000:"
        read GAME_INPUT  
    
          while ! [[ "$GAME_INPUT" =~ ^[0-9]+$ ]]; do
        echo "That is not an integer, guess again:"
        read GAME_INPUT
        continue  # Repeat the loop
    done


    number_of_guesses=1;

    while [ "$GAME_INPUT" -ne "$RANDOM_NUMBER" ]; do

    if [ $GAME_INPUT -gt $RANDOM_NUMBER ]; 
    then
    echo "It's lower than that, guess again:"
    else
    echo "It's higher than that, guess again:"
    fi
    read GAME_INPUT
    # Increment the guess count
    number_of_guesses=$((number_of_guesses + 1))
done
  
  SAVE_GAME_PROGRESS $USERNAME $number_of_guesses
  echo "You guessed it in $number_of_guesses tries. The secret number was $RANDOM_NUMBER. Nice job!"

}

SAVE_GAME_PROGRESS() {

  local GAMEUSER=$1
  local NUMBERS_OF_GUESSES=$2
  local GAMEUSER_LOOKUP=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME_INPUT'")

   local NEW_USERID=$($PSQL "SELECT MAX(user_id) + 1 FROM users;")

  if [[ -z $GAMEUSER_LOOKUP ]]
      then
      INSERT_NEW_USER=$($PSQL "INSERT INTO users (user_id, username, games_played, best_game) VALUES ($NEW_USERID, '$GAMEUSER', 1, $NUMBERS_OF_GUESSES)")
      
      else
 local UPDATE_GAMES_PLAYED=$($PSQL "SELECT MAX(games_played) + 1 FROM users WHERE username='$USERNAME_INPUT'")
     UPDATE_USER=$($PSQL "UPDATE users SET games_played=$UPDATE_GAMES_PLAYED WHERE username='$USERNAME_INPUT'")
  fi

}

echo -e "Enter your username:"
read USERNAME_INPUT
 USERNAME_SELECTED_LOOKUP=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME_INPUT'")
    
            # if not available
  if [[ -z $USERNAME_SELECTED_LOOKUP ]]
      then
        # send to main menu
        echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."

        echo "Guess the secret number between 1 and 1000:"

        EXECUTE_GAME $USERNAME_INPUT
      
  
      else

       IFS="|" read -ra elements <<< "$USERNAME_SELECTED_LOOKUP"
    username="${elements[0]}"
    games_played="${elements[1]}"
    best_game="${elements[2]}"
        # get customer info
        echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
        
        EXECUTE_GAME $username
  fi